----------------------------------------------------------------------
-- An iconic representation of Unit status icon for player frame. (made by superraider)
----------------------------------------------------------------------
RDX.RegisterFeature({
   name = "Player Status Icon";
   category = i18n("Icon");
   IsPossible = function(state)
      if not state:Slot("UnitFrame") then return nil; end
      if not state:Slot("Base") then return nil; end
      return true;
   end;
   ExposeFeature = function(desc, state, errs)
      if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
      local flg = true;
      flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
      flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
      flg = flg and __UFOwnerCheck(desc.owner, state, errs);
      if flg then state:AddSlot("Frame_" .. desc.name); end
      return flg;
   end;
   ApplyFeature = function(desc, state)
      local objname = "Frame_" .. desc.name;
      local ebs = "false"; if (desc.externalButtonSkin) then ebs = "true"; end
      
      ------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then
			closureCode = closureCode .. [[ local mddata = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
			state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);
		end

      ------------------ On frame creation
      local createCode = [[
local _t = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.]] .. objname .. [[ = _t;
_t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_t:SetWidth(]] .. desc.w .. [[); _t:SetHeight(]] .. desc.h .. [[);
_t:SetVertexColor(1,1,1,1);
_t:SetTexture("Interface\\CharacterFrame\\UI-StateIcon");
_t:Hide();

if ]] .. ebs .. [[ then
	local _bck = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
	VFLUI.SetTexture(_bck, mddata.backdrop);
	_bck:SetDrawLayer(mddata.dd_backdrop);
	_bck:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
	_bck:SetWidth(]] .. desc.w .. [[); _bck:SetHeight(]] .. desc.h .. [[);
	_bck:Hide();
	frame.]] .. objname .. [[_backdrop = _bck;
	
	local _n = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
	VFLUI.SetTexture(_n, mddata.normal);
	_n:SetDrawLayer(mddata.dd_normal);
	_n:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
	_n:SetWidth(]] .. desc.w .. [[); _n:SetHeight(]] .. desc.h .. [[);
	_n:Hide();
	frame.]] .. objname .. [[_normal = _n;
	
	local _g = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
	VFLUI.SetTexture(_g, mddata.gloss);
	_g:SetDrawLayer(mddata.dd_gloss);
	_g:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
	_g:SetWidth(]] .. desc.w .. [[); _g:SetHeight(]] .. desc.h .. [[);
	_g:Hide();
	frame.]] .. objname .. [[_gloss = _g;
end
]];
      state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

      ------------------ On frame destruction.
      state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode([[
VFLUI.ReleaseRegion(frame.]] .. objname .. [[);
frame.]] .. objname .. [[ = nil;
if ]] .. ebs .. [[ then
	VFLUI.ReleaseRegion(frame.]] .. objname .. [[_backdrop);
	frame.]] .. objname .. [[_backdrop = nil;
	VFLUI.ReleaseRegion(frame.]] .. objname .. [[_normal);
	frame.]] .. objname .. [[_normal = nil;
	VFLUI.ReleaseRegion(frame.]] .. objname .. [[_gloss);
	frame.]] .. objname .. [[_gloss = nil;
end
]]); end);
      state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.]] .. objname .. [[:Hide();
if ]] .. ebs .. [[ then
	frame.]] .. objname .. [[_backdrop:Hide();
	frame.]] .. objname .. [[_normal:Hide();
	frame.]] .. objname .. [[_gloss:Hide();
end
]]); end);

      ------------------ On paint.
      state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[
local _name = UnitName(uid);
if UnitAffectingCombat(uid) then
   frame.]] .. objname .. [[:Show();
   frame.]] .. objname .. [[:SetTexCoord(0.5, 1, 0, 0.5);
   if ]] .. ebs .. [[ then
   		frame.]] .. objname .. [[_backdrop:Show();
		frame.]] .. objname .. [[_normal:Show();
		frame.]] .. objname .. [[_gloss:Show();
    end
elseif (RDXPlayer.rosterName == _name) and IsResting() then
   frame.]] .. objname .. [[:Show();
   frame.]] .. objname .. [[:SetTexCoord(0, 0.5, 0, 0.421875)
   if ]] .. ebs .. [[ then
   		frame.]] .. objname .. [[_backdrop:Show();
		frame.]] .. objname .. [[_normal:Show();
		frame.]] .. objname .. [[_gloss:Show();
   end
else
   frame.]] .. objname .. [[:Hide();
   if ]] .. ebs .. [[ then
   		frame.]] .. objname .. [[_backdrop:Hide();
		frame.]] .. objname .. [[_normal:Hide();
		frame.]] .. objname .. [[_gloss:Hide();
	end
end
_name = nil;
]]); end);

      local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
      mux:Event_MaskAll("PLAYER_UPDATE_RESTING", 2);
      return true;
   end;
   UIFromDescriptor = function(desc, parent, state)
      local ui = VFLUI.CompoundFrame:new(parent);

      -- Name/width/height
      local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

      -- Owner
      local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
      if desc and desc.owner then owner:SetSelection(desc.owner); end

      -- Drawlayer
      local er = RDXUI.EmbedRight(ui, "Draw layer:");
      local drawLayer = VFLUI.Dropdown:new(er, RDXUI.DrawLayerDropdownFunction);
      drawLayer:SetWidth(100); drawLayer:Show();
      if desc and desc.drawLayer then drawLayer:SetSelection(desc.drawLayer); else drawLayer:SetSelection("ARTWORK"); end
      er:EmbedChild(drawLayer); er:Show();
      ui:InsertFrame(er);

      -- Anchor
      local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
      anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
      if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
      ui:InsertFrame(anchor);
      
	local chk_bs = RDXUI.CheckEmbedRight(ui, i18n("Use Button Skin"));
	local file_extBS = RDXDB.ObjectFinder:new(chk_bs, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "ButtonSkin$")); end);
	file_extBS:SetWidth(200); file_extBS:Show();
	chk_bs:EmbedChild(file_extBS); chk_bs:Show();
	ui:InsertFrame(chk_bs);
	if desc.externalButtonSkin then
		chk_bs:SetChecked(true); file_extBS:SetPath(desc.externalButtonSkin);
	else
		chk_bs:SetChecked();
	end
		
      function ui:GetDescriptor()
         local name = ed_name.editBox:GetText();
	 local ebs = nil;
	 if chk_bs:GetChecked() then ebs = file_extBS:GetPath(); end
         return {
            feature = "Player Status Icon", name = name, owner = owner:GetSelection();
            drawLayer = drawLayer:GetSelection();
           --w = VFL.clamp(ed_width.editBox:GetNumber(), 0, 1000);
            --h = VFL.clamp(ed_height.editBox:GetNumber(), 0, 1000);
	    w = ed_width:GetSelection();
				h = ed_height:GetSelection();
            anchor = anchor:GetAnchorInfo();
	    externalButtonSkin = ebs;
         };
      end

      return ui;
   end;
   CreateDescriptor = function()
      return {
         feature = "Player Status Icon", name = "sti", owner = "Base", drawLayer = "ARTWORK";
        w = 14; h = 14;
         anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
      };
   end;
}); 
