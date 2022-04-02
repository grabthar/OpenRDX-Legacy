
-- FeatureEditor.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
-- 
-- The dialog box for editing an ObjectState's features.

local dlg = nil;

function RDX.IsFeatureEditorOpen() return dlg; end

local features = {};
local pfeatures = {}; -- DragDrop system: possible features now in a separate table.

local category_color = {r=.5,g=.4,b=.35};
local addfeature_color = {r=0.3, g=0.7, b=0.5};

local AddFeatureDragContext = VFLUI.DragContext:new();
local MoveFeatureDragContext = VFLUI.DragContext:new();

-- Drag start helpers
local function AddFeatureDragStart(btn)
   if btn.feat then
      RDX:Debug(1, ("AddFeatureDragStart for feature %s"):format(tostring(btn.feat.title)));
      local proxy = VFLUI.CreateGenericDragProxy(btn, btn.text:GetText(), btn.feat);
      AddFeatureDragContext:Drag(btn, proxy);
   end
end
local function MoveFeatureDragStart(btn)
   if btn.idx then
      RDX:Debug(1, ("MoveFeatureDragStart at index %s"):format(tostring(btn.idx)));
      local proxy = VFLUI.CreateGenericDragProxy(btn, btn.text:GetText(), btn.idx);
      MoveFeatureDragContext:Drag(btn, proxy);
   end
end

function RDX.FeatureEditor(state, callback, augText)
   if (dlg) or (not state) then return nil; end
   
   dlg = VFLUI.Window:new(UIParent); dlg:SetFrameStrata("FULLSCREEN");
   VFLUI.Window.SetDefaultFraming(dlg, 24);
   dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
   dlg:SetTitleColor(0,.6,0);
   dlg:SetText(i18n("Feature Editor: ") .. augText);
   dlg:SetWidth(700); dlg:SetHeight(500);
   dlg:SetPoint("CENTER", UIParent, "CENTER");
   dlg:Show();
   -- OpenRDX 7.1 RDXPM
   if RDXPM.Ismanaged("FeatureEditor") then RDXPM.RestoreLayout(dlg, "FeatureEditor"); end
   VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
   local ca = dlg:GetClientArea();

   -- Predeclarations
   local featList, possibleFeatList, sf, ui;
   local activeFeat;
   local RebuildFeatureList, RebuildActiveFeatureList, RebuildPossibleFeatureList, SetActiveFeature, HideErrors, ShowErrors;

   ------ Helper functions   
   local function AddFeatureAt(feat, idx)
      -- Spin up the state to the target index.
      state:InSituState(idx);
      -- Check possibility of feature
      if not feat.IsPossible(state) then
         VFLUI.MessageBox(i18n("Error"), i18n("Feature is not possible at that position."));
         return;
      end
      -- Create and add the descriptor.
      local desc = feat.CreateDescriptor(state);
      table.insert(state.features, idx, desc);
      state.featuresByName[feat.name] = true;
      -- Check to see if our active feature needs moved
      if activeFeat and activeFeat >= idx then
         activeFeat = activeFeat + 1;
      end
      -- Restore the full in-situ state
      state:InSituState();
      -- Rebuild the feature list
      RebuildFeatureList();
   end

   local function ResetFeatureUI()
      if ui then
         ui:Hide();
         sf:SetScrollChild(nil);
         ui.GetDescriptor = nil; -- BUGFIX: Remove the GetDescriptor from a feature UI before freeing it.
         ui:Destroy();
         ui = nil;
      end
   end

   -- Get the currently-edited state
   function dlg:GetActiveState() return state; end

   -- Callback: save the current feature
   local function SaveActiveFeature(nofeedback)
      if (not activeFeat) or (not ui) then return; end
      -- Find the feature on the local state; if not found, fail out.
      local fd = state:_GetFeatureByIndex(activeFeat);
      if not fd then return; end
      local feat = RDX.GetFeatureByDescriptor(fd);
      if not feat then return; end
      -- Get the edited data from the feature UI, and save it.
      local descr = ui:GetDescriptor();
      feat = RDX.GetFeatureByDescriptor(descr);
      state:_SaveFeatureByIndex(activeFeat, descr);
      -- 6.4.9
      RDXDB.PaintPreviewWindow(state);
      --if callback then callback(state); end
      -- If we were asked for feedback, give it.
      if not nofeedback then
         state:InSituState(activeFeat);
         vflErrors:Clear();
         if state:_ExposeFeatureInSitu(descr, feat, vflErrors) then
         else
            ShowErrors(vflErrors);
         end
      end
   end

   -- Callback: select a new active feature.
   function SetActiveFeature(idx, force)
      -- Activate the feature only if required
      if activeFeat == idx and not force then return; end
      -- Save outstanding changes to the previous feature
      SaveActiveFeature(true);
      -- Find the feature on the local state; if not found, fail out.
      local fd = state:_GetFeatureByIndex(idx);
      if not fd then return; end
      local feat = RDX.GetFeatureByDescriptor(fd);
      if not feat then return; end
      -- Update the active feature. Rebuild the feature list.
      activeFeat = idx;
      state:InSituState(activeFeat);
      RebuildFeatureList();
      -- Now build the feature config UI.
      ResetFeatureUI();   
      if (not feat.UIFromDescriptor) then return; end -- no UI
      ui = feat.UIFromDescriptor(fd, sf, state); if not ui then return; end
      -- Layout and show the feature config UI.
      ui.isLayoutRoot = true;
      ui:SetParent(sf); sf:SetScrollChild(ui);
      ui:SetWidth(sf:GetWidth());
      if ui.DialogOnLayout then ui:DialogOnLayout(); end
      ui:Show();
      -- If there are any errors, show them
      state:InSituState(activeFeat);
      vflErrors:Clear();
      if state:_ExposeFeatureInSitu(fd, feat, vflErrors) then
         HideErrors();
      else
         ShowErrors(vflErrors);
      end
   end
   function dlg:SetActiveFeature(idx) SetActiveFeature(idx); end
   
      -- Remove the feature at the given index. Anything that depended on this
   -- feature will be blasted as well.
   local function RemoveFeatureAt(idx)
      -- Remove the feature
      local qq = state:Features();
      local x = table.remove(qq, idx); if not x then return; end
      -- Check our active feature; if this was it make sure to unset it
      if activeFeat then
         if activeFeat == idx then
            ResetFeatureUI(); HideErrors();
            activeFeat = nil;
         elseif activeFeat > idx then
            activeFeat = activeFeat - 1;
         end
      end
      -- Rebuild the state.
      state:Clear();
      -- Readd each feature one at a time
      for ix,ft in ipairs(qq) do state:AddFeatureInSitu(ft); end
      -- Rebuild the list
      RebuildFeatureList();
      -- 6.4.9
      RDXDB.PaintPreviewWindow(state);
   end
   
   -- Move a feature from one index to another
   local function MoveFeature(src, dest)
      if (src < 1) or (src == dest) then return; end -- nothing to do
      local qq = state:Features();
      if dest > #qq then dest = #qq + 1; end -- out of bounds
      local tmp = table.remove(qq, src); -- delete the source feature
      table.insert(qq, dest, tmp); -- move it to the destination
      -- We want our active feature after the operation to be the same
      -- as before.
      if activeFeat then
         if(activeFeat == src) then
            activeFeat = dest;
         else
            -- First we're "deleting" the source feature
            if src < activeFeat then activeFeat = activeFeat - 1; end
            -- Then we're "adding" a feature at the destination.
            if dest <= activeFeat then activeFeat = activeFeat + 1; end
         end
      end
      RebuildFeatureList();
   end

   -- Export the active feature to disk at the given location.
   local function ExportFeatureTo(file)
      RDX:Debug(1, "ExportFeatureTo " .. tostring(file));
      local qq = state:Features();
      if (not activeFeat) or (not qq[activeFeat]) then return; end
      file = RDXDB.TouchObject(file);
      if not file then
         -- TODO: error message here? shouldn't really ever happen but who knows.
         return;
      end
      -- Check file integrity
      if(file.ty == "Typeless") then file.ty = "FeatureData"; file.version = 1; end
      if(file.ty ~= "FeatureData") then
         VFLUI.MessageBox("Error", i18n("Cannot overwrite a non-FeatureData object with FeatureData. Delete it first."));
         return;
      end
      -- Write the data
      file.data = VFL.copy(qq[activeFeat]);
   end

   -- Import a feature from disk, adding it to the end of the featurelist.
   local function ImportFeatureFrom(file)
      RDX:Debug(1, "ImportFeatureFrom " .. tostring(file));
      local md = RDXDB.GetObjectData(file);
      -- Sanity check.
      if(type(md) ~= "table") or (md.ty ~= "FeatureData") or (type(md.data) ~= "table") or (type(md.data.feature) ~= "string") then
         VFLUI.MessageBox(i18n("Error"), i18n("Not a valid FeatureData file.")); return;
      end
      -- Import it.
      -- We'll VFL.copy() it just to be safe.
      state:AddFeature(VFL.copy(md.data));
      RebuildFeatureList();
   end
   
   -- Callback for when a drag-and-drop feature is dropped on another
   -- feature.
   local function FeatureDropOn(target, proxy, _, context)
      local src, dest = proxy.data, target.idx;
      -- The destination should always be a numbered cell in the feature editor
      if (type(dest) ~= "number") then return; end
      -- Fork depending on which context we're in
      if context == AddFeatureDragContext then
         -- Source data should be an actual feature entity.
         AddFeatureAt(src, dest);
      elseif context == MoveFeatureDragContext then
         -- Source should be a numbered feature
         if (type(src) ~= "number") then return; end
         if(src == dest) then
            -- Drag without a move, must have been just a click.
            -- Activate the feature.
            SetActiveFeature(src); return;
         end
         MoveFeature(src, dest);
      end
   end
   
   -- Callback when a feature is dragged from the active list and dropped
   -- on the trash.
   local function FeatureDropTrash(_, proxy, _, context)
      -- Check to make sure this is an active feature being dragged
      if context ~= MoveFeatureDragContext then return; end
      -- Get the drag source
      local src = proxy.data;
      -- Should be a numbered feature
      if type(src) ~= "number" then return; end
      -- Delete it.
      RemoveFeatureAt(src);
   end
   
   ------ The active feature list.
   -- Create the active-feature buttons.
   local function GetActiveFeatureButton()
      local btn = VFLUI.Selectable:new();
      btn.OnDrop = FeatureDropOn;
      AddFeatureDragContext:RegisterDragTarget(btn);
      MoveFeatureDragContext:RegisterDragTarget(btn);
      btn:RegisterForClicks("LeftButtonDown");
      btn:SetScript("OnClick", MoveFeatureDragStart);
      
      btn.Destroy = VFL.hook(btn.Destroy, function(x)
         AddFeatureDragContext:UnregisterDragTarget(x);
         MoveFeatureDragContext:UnregisterDragTarget(x);
         x.OnDrop = nil;
         x.idx = nil;
      end);
      btn.OnDeparent = btn.Destroy;
      return btn;
   end
   
   featList = VFLUI.List:new(dlg, 12, GetActiveFeatureButton);
   featList:SetPoint("TOPLEFT", ca, "TOPLEFT");
   featList:SetWidth(200); featList:SetHeight(448);
   featList:Rebuild(); featList:Show();
   featList:SetDataSource(function(cell, data, pos)
      cell.text:SetText(data.text);
      cell.idx = data.idx;
      if activeFeat and (data.idx == activeFeat) then
         cell.selTexture:SetVertexColor(0,0,0.6); cell.selTexture:Show();
      elseif data.hlt then
         cell.selTexture:SetVertexColor(data.hlt.r, data.hlt.g, data.hlt.b); cell.selTexture:Show();
      else
         cell.selTexture:Hide();
      end
   end, VFL.ArrayLiterator(features));
   
   function RebuildActiveFeatureList()
      VFL.empty(features);
      local feats, feat, text = state:Features();
      for idx,fd in ipairs(feats) do
         state:InSituState(idx);
         feat = RDX.GetFeatureByDescriptor(fd);
         if not feat then
            text = i18n("(Invalid!)");
         elseif not feat.IsPossible(state) then
            text = ("|cFFFF0000%s|r"):format(feat.title);
         elseif not state:_ExposeFeatureInSitu(fd, feat) then
            text = ("|cFFFFFF00%s|r"):format(feat.title);
         elseif feat.deprecated then
            text = ("|cFFDD0077%s|r"):format(feat.title);
         else
            text = feat.title;
         end
         table.insert(features, {idx=idx, text=text});
      end
      table.insert(features, {idx=#feats+1, hlt=addfeature_color, text = "(drag new feature here)"});
      featList:Update();
   end
   
   ------ The possible features list
   local function GetPossibleFeatureButton()
      local btn = VFLUI.Selectable:new();
      btn:RegisterForClicks("LeftButtonDown");
      btn:SetScript("OnClick", AddFeatureDragStart);
      btn.Destroy = VFL.hook(btn.Destroy, function(x)
         x.feat = nil;
      end);
      btn.OnDeparent = btn.Destroy;
      return btn;
   end
   
   possibleFeatList = VFLUI.List:new(dlg, 12, GetPossibleFeatureButton);
   possibleFeatList:SetPoint("TOPRIGHT", ca, "TOPLEFT", -10, 0);
   possibleFeatList:SetWidth(200); possibleFeatList:SetHeight(448);
   possibleFeatList:Rebuild(); possibleFeatList:Show();
   possibleFeatList:SetDataSource(function(cell, data, pos)
      cell.text:SetText(data.text);
      cell.feat = data.feat;
      if data.hlt then
         cell.selTexture:SetVertexColor(data.hlt.r, data.hlt.g, data.hlt.b); cell.selTexture:Show();
      else
         cell.selTexture:Hide();
      end
   end, VFL.ArrayLiterator(pfeatures));
   
   local possibleFeatureBackdrop = VFLUI.AcquireFrame("Frame");
   possibleFeatureBackdrop:SetParent(dlg);
   possibleFeatureBackdrop:SetPoint("TOPLEFT", possibleFeatList, "TOPLEFT", -5, 5);
   possibleFeatureBackdrop:SetPoint("BOTTOMRIGHT", possibleFeatList, "BOTTOMRIGHT", 5, -5);
   possibleFeatureBackdrop:SetBackdrop(VFLUI.DarkDialogBackdrop);
   possibleFeatureBackdrop:Show();
   
   function RebuildPossibleFeatureList()
      VFL.empty(pfeatures);
      state:InSituState();
      -- Sort the features by category, then name.
      local flist = RDX._GetFeatureArray();
      table.sort(flist, function(f1, f2)
         if(f1.category == f2.category) then
            return (f1.title < f2.title);
         else
            return (f1.category < f2.category);
         end
      end);
      -- Traverse the list in order, inserting a category-header whenever the category changes.
      local curCat, text = "";
      for idx,feat in ipairs(flist) do
         if state:IsFeaturePossible(feat) and (not feat.invisible) then
            if(feat.category ~= curCat) then
               table.insert(pfeatures, {text = feat.category, hlt = category_color}); curCat = feat.category;
            end
            local txt = feat.title;
            if feat.deprecated then txt = ("|cFFDD0077%s|r"):format(txt); end
            table.insert(pfeatures, { text = txt, feat = feat });
         end
      end
      possibleFeatList:Update();
   end
   

   function RebuildFeatureList()
      RebuildActiveFeatureList();
      RebuildPossibleFeatureList();
   end
   dlg.RebuildFeatureList = RebuildFeatureList;

   ------ The feature config ui.
   sf = VFLUI.VScrollFrame:new(dlg);
   sf:SetWidth(470); sf:SetHeight(440);
   sf:SetPoint("TOPLEFT", featList, "TOPRIGHT");
   sf:Show();

   ------ The error frame
   local el = VFLUI.List:new(dlg, 10, VFLUI.Selectable.AcquireCell);
   local function elad(cell, data)
      cell.text:SetText(data);
      if(data ~= "Errors") then
         cell.selTexture:Hide();
      else
         cell.selTexture:SetVertexColor(0.75,0,0); cell.selTexture:Show();
      end
   end;
   el:SetPoint("TOPLEFT", sf, "BOTTOMLEFT");
   el:SetWidth(470); el:SetHeight(100); el:Rebuild(); el:Hide();
   function HideErrors()
      sf:SetHeight(440); el:Hide();
   end
   function ShowErrors(err)
      sf:SetHeight(340); el:Show();
      local ec, et = err:Count(), err:ErrorTable();
      el:SetDataSource(elad, function() return ec + 1; end, function(x)
         if(x == 1) then return "Errors"; else return et[x-1]; end
      end);
   end

   ------ Save/revert buttons
   local btnSave = VFLUI.Button:new(dlg);
   btnSave:SetHeight(25); btnSave:SetWidth(65);
   btnSave:SetPoint("BOTTOMRIGHT", ca, "BOTTOMRIGHT");
   btnSave:SetText(i18n("Save")); btnSave:Show();
   btnSave:SetScript("OnClick", function() SetActiveFeature(activeFeat, true); end);

   local btnRevert = VFLUI.Button:new(dlg);
   btnRevert:SetHeight(25); btnRevert:SetWidth(65);
   btnRevert:SetPoint("RIGHT", btnSave, "LEFT");
   btnRevert:SetText(i18n("Revert")); btnRevert:Show();
   btnRevert:SetScript("OnClick", function()
      local ix = activeFeat;
      if ix then
         SetActiveFeature(nil); SetActiveFeature(ix);
      end
   end);

   local btnRemove = VFLUI.Button:new(dlg);
   btnRemove:SetHeight(25); btnRemove:SetWidth(200);
   btnRemove:SetPoint("BOTTOMLEFT", ca, "BOTTOMLEFT");
   btnRemove:SetText(i18n("Trash")); btnRemove:Show();
   btnRemove:SetScript("OnClick", function()
      local ix = activeFeat;
      if ix then
         SetActiveFeature(nil); RemoveFeatureAt(ix);
      end
   end);
   -- Setup the drag/drop trash.
   btnRemove.OnDrop = FeatureDropTrash;
   MoveFeatureDragContext:RegisterDragTarget(btnRemove);
   
   local btnImport = VFLUI.Button:new(dlg);
   btnImport:SetHeight(25); btnImport:SetWidth(65);
   btnImport:SetPoint("RIGHT", btnRevert, "LEFT");
   btnImport:SetText(i18n("Import")); btnImport:Show();
   btnImport:SetScript("OnClick", function()
      local xp = RDXDB.ExplorerPopup(this);
      xp:SetPoint("BOTTOMLEFT", this, "TOPLEFT"); xp:Show();
      xp:SetFileFilter(function(_,_,md) if type(md) == "table" then return (md.ty == "FeatureData"); end; end); xp:Rebuild();
      xp:EnableFeedback(function(zz) ImportFeatureFrom(zz:GetPath()); end);
   end);

   local btnExport = VFLUI.Button:new(dlg);
   btnExport:SetHeight(25); btnExport:SetWidth(65);
   btnExport:SetPoint("RIGHT", btnImport, "LEFT");
   btnExport:SetText(i18n("Export")); btnExport:Show();
   btnExport:SetScript("OnClick", function()
      local xp = RDXDB.ExplorerPopup(this);
      xp:SetPoint("BOTTOMLEFT", this, "TOPLEFT"); xp:Show();
      xp:SetFileFilter(VFL.True); xp:Rebuild();
      xp:EnableFeedback(function(zz) ExportFeatureTo(zz:GetPathRaw()); end);
   end);


   ------ Close procedure
   dlg.Destroy = VFL.hook(function(s)
      -- Remove exposed API
      s.SetActiveFeature = nil; s.RebuildFeatureList = nil;
      s.GetActiveState = nil;

      -- Tear down controls
      ResetFeatureUI();
      featList:Destroy(); featList = nil;
      possibleFeatList:Destroy(); possibleFeatList = nil;
      possibleFeatureBackdrop:Destroy(); possibleFeatureBackdrop = nil;
      el:Destroy(); el = nil;
      -- Trash the trash button
      MoveFeatureDragContext:UnregisterDragTarget(btnRemove);
      btnRemove.OnDrop = nil;
      btnRemove:Destroy(); btnRemove = nil;
      -- Trash other buttons
      btnSave:Destroy(); btnSave = nil;
      btnRevert:Destroy(); btnRevert = nil;
      btnImport:Destroy(); btnImport = nil;
      btnExport:Destroy(); btnExport = nil;
      sf:Destroy(); sf = nil;
   end, dlg.Destroy);

   local function Close()
      -- Save the active feature before exiting
      SaveActiveFeature(true);
      -- new 7.1 sigg store editors position
      RDXPM.StoreLayout(dlg, "FeatureEditor");
      dlg:Destroy(); dlg = nil;
      if callback then callback(state); end
   end

   local closebtn = VFLUI.CloseButton:new()
   closebtn:SetScript("OnClick", Close);
   dlg:AddButton(closebtn);

   RebuildFeatureList();

   return dlg;
end 

function RDX.CloseFeatureEditor()
	dlg:Destroy(); dlg = nil;
end
