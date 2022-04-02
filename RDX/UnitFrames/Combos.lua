-------------------------------
-- ComboPoints Anchor helper
-------------------------------
local function ComboAnchorHelper(i, spacex, spacey, orient, name)
   local ix = i-1;
   if orient == "DOWN" then
      return "'TOP', _t" .. ix .. ", 'BOTTOM', " .. spacex .. ", " .. -spacey;
   elseif orient == "UP" then
      return "'BOTTOM', _t" .. ix .. ", 'TOP', " .. spacex .. ", " .. spacey;
   elseif orient == "LEFT" then
      return "'RIGHT', _t" .. ix .. ", 'LEFT', " .. -spacex .. ", " .. spacey;
   elseif orient == "RIGHT" then
      return "'LEFT', _t" .. ix .. ", 'RIGHT', " .. spacex .. ", " .. spacey;
   end
end

local _orientations = {
   { text = "LEFT" },
   { text = "RIGHT"},
   { text = "DOWN"},
   { text = "UP" },
};
local function _dd_orientations() return _orientations; end

local function _GenerateSetTextureCode(obj, descr)
   local ret = "";
   if descr.color then
      local c = descr.color;
      ret = obj .. ":SetTexture(" .. c.r .. "," .. c.g .. "," .. c.b .. "," .. c.a .. "); ";
   elseif descr.path then
      ret = obj .. ":SetTexture(" .. string.format("%q", descr.path) .. "); ";
   end
   ret = ret .. obj .. ":SetBlendMode(" .. string.format("%q", descr.blendMode) .. "); ";
   if descr.vertexColor then
      local c = descr.vertexColor;
      ret = ret .. obj .. ":SetVertexColor(" .. c.r .. "," .. c.g .. "," .. c.b .. "," .. c.a .. [[);
]];
   else
      ret = ret .. obj .. [[:SetVertexColor(1,1,1,1);
]];
   end

   return ret;
end

-----------------------------
-- Combo Points: Iconic (fridgid)
-- Displays 5 'icons' of the same texture which appear
-- based on combo points; each texture has its own color
-----------------------------
RDX.RegisterFeature({
   name = "icp"; version = 1; title = i18n("Combo Points: Iconic"); category = i18n("Textures");
   IsPossible = function(state)
      if not state:Slot("UnitFrame") then return nil; end
      if not state:Slot("Base") then return nil; end
      return true;
   end;
   ExposeFeature = function(desc, state, errs)
      if not desc then VFL.AddError(errs, "Missing descriptor."); return nil; end
      -- Verify our owner frame exists
      if (not desc.owner) or ((desc.owner ~= "Base") and (not state:Slot("Subframe_" .. desc.owner))) then
         VFL.AddError(errs, "Owner frame does not exist."); return nil;
      end
      local flg = true;
      flg = flg and __UFFrameCheck_Proto("Tex_", desc, state, errs);
      flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
      if flg then
         state:AddSlot("Tex_" .. desc.name .. "1");
         state:AddSlot("Tex_" .. desc.name .. "2");
         state:AddSlot("Tex_" .. desc.name .. "3");
         state:AddSlot("Tex_" .. desc.name .. "4");
         state:AddSlot("Tex_" .. desc.name .. "5");
      end
      return flg;
   end;
   ApplyFeature = function(desc, state)
      ------------------ On frame creation
      local createCode = [[
local _t1 = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.Tex_]] .. desc.name .. [[1 = _t1;
_t1:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t1:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_t1:SetWidth(]] .. desc.w .. [[); _t1:SetHeight(]] .. desc.h .. [[);
_t1:Hide();
]];
      createCode = createCode .. _GenerateSetTextureCode("_t1", desc.texture);
      createCode = createCode .. [[
--_t1:SetVertexColor(]]..desc.cp1.r..[[,]]..desc.cp1.g..[[,]]..desc.cp1.b..[[,]]..desc.cp1.a..[[);
local _t2 = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.Tex_]] .. desc.name .. [[2 = _t2;
_t2:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t2:SetPoint(]] .. ComboAnchorHelper(2, desc.spacex, desc.spacey, desc.orientation, desc.name) .. [[);
_t2:SetWidth(]] .. desc.w .. [[); _t2:SetHeight(]] .. desc.h .. [[);
_t2:Hide();
]];
      createCode = createCode .. _GenerateSetTextureCode("_t2", desc.texture);
      createCode = createCode .. [[
--_t1:SetVertexColor(]]..desc.cp2.r..[[,]]..desc.cp2.g..[[,]]..desc.cp2.b..[[,]]..desc.cp2.a..[[);
local _t3 = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.Tex_]] .. desc.name .. [[3 = _t3;
_t3:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t3:SetPoint(]] .. ComboAnchorHelper(3, desc.spacex, desc.spacey, desc.orientation, desc.name) .. [[);
_t3:SetWidth(]] .. desc.w .. [[); _t3:SetHeight(]] .. desc.h .. [[);
_t3:Hide();
]];
      createCode = createCode .. _GenerateSetTextureCode("_t3", desc.texture);
      createCode = createCode .. [[
--_t1:SetVertexColor(]]..desc.cp3.r..[[,]]..desc.cp3.g..[[,]]..desc.cp3.b..[[,]]..desc.cp3.a..[[);
local _t4 = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.Tex_]] .. desc.name .. [[4 = _t4;
_t4:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t4:SetPoint(]] .. ComboAnchorHelper(4, desc.spacex, desc.spacey, desc.orientation, desc.name) .. [[);
_t4:SetWidth(]] .. desc.w .. [[); _t4:SetHeight(]] .. desc.h .. [[);
_t4:Hide();
]];
      createCode = createCode .. _GenerateSetTextureCode("_t4", desc.texture);
      createCode = createCode .. [[
--_t1:SetVertexColor(]]..desc.cp4.r..[[,]]..desc.cp4.g..[[,]]..desc.cp4.b..[[,]]..desc.cp4.a..[[);
local _t5 = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.Tex_]] .. desc.name .. [[5 = _t5;
_t5:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t5:SetPoint(]] .. ComboAnchorHelper(5, desc.spacex, desc.spacey, desc.orientation, desc.name) .. [[);
_t5:SetWidth(]] .. desc.w .. [[); _t5:SetHeight(]] .. desc.h .. [[);
_t5:Hide();

local comboPoints = 0;
]];
      createCode = createCode .. _GenerateSetTextureCode("_t5", desc.texture);
      createCode = createCode .. [[
--_t1:SetVertexColor(]]..desc.cp5.r..[[,]]..desc.cp5.g..[[,]]..desc.cp5.b..[[,]]..desc.cp5.a..[[);
]];
      state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

      ------------------ On frame destruction.

      state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode([[
frame.Tex_]] .. desc.name .. [[1:Destroy(); frame.Tex_]] .. desc.name .. [[1 = nil;
frame.Tex_]] .. desc.name .. [[2:Destroy(); frame.Tex_]] .. desc.name .. [[2 = nil;
frame.Tex_]] .. desc.name .. [[3:Destroy(); frame.Tex_]] .. desc.name .. [[3 = nil;
frame.Tex_]] .. desc.name .. [[4:Destroy(); frame.Tex_]] .. desc.name .. [[4 = nil;
frame.Tex_]] .. desc.name .. [[5:Destroy(); frame.Tex_]] .. desc.name .. [[5 = nil;
]]); end);


      state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.Tex_]] .. desc.name .. [[1:Hide();
frame.Tex_]] .. desc.name .. [[2:Hide();
frame.Tex_]] .. desc.name .. [[3:Hide();
frame.Tex_]] .. desc.name .. [[4:Hide();
frame.Tex_]] .. desc.name .. [[5:Hide();
]]); end);

         ------------------ On paint.
      local paintCode = [[
if (uid == "target") then 
	comboPoints = GetComboPoints("player");
else
	comboPoints = GetComboPoints(uid);
end
]];

if desc.setup then
   paintCode = paintCode .. [[
comboPoints = 5;
]];
end
      paintCode = paintCode .. [[
if comboPoints then
   local frame = {   frame.Tex_]] .. desc.name .. [[1,
         frame.Tex_]] .. desc.name .. [[2,
         frame.Tex_]] .. desc.name .. [[3,
         frame.Tex_]] .. desc.name .. [[4,
         frame.Tex_]] .. desc.name .. [[5
   };
   local __cp = {   ]]..desc.cp1.r..[[, ]]..desc.cp1.g..[[, ]]..desc.cp1.b..[[, ]]..desc.cp1.a..[[,
         ]]..desc.cp2.r..[[, ]]..desc.cp2.g..[[, ]]..desc.cp2.b..[[, ]]..desc.cp2.a..[[,
         ]]..desc.cp3.r..[[, ]]..desc.cp3.g..[[, ]]..desc.cp3.b..[[, ]]..desc.cp3.a..[[,
         ]]..desc.cp4.r..[[, ]]..desc.cp4.g..[[, ]]..desc.cp4.b..[[, ]]..desc.cp4.a..[[,
         ]]..desc.cp5.r..[[, ]]..desc.cp5.g..[[, ]]..desc.cp5.b..[[, ]]..desc.cp5.a..[[
   };
   local _w,_h = ]] .. desc.w .. [[, ]] .. desc.h .. [[;

   if comboPoints == 0 then
      for i=1,5 do
         frame[i]:Hide();
      end
   elseif comboPoints > 0 then
      for i=1, comboPoints do
         local xi = (i*4)-4;
         local w,x,y,z = xi+1, xi+2, xi+3, xi+4;
         frame[i]:Show();
         frame[i]:SetWidth(_w); frame[i]:SetHeight(_h);
         frame[i]:SetVertexColor(__cp[w], __cp[x], __cp[y], __cp[z]);
      end
      if comboPoints < 5 then
         for i=5,(comboPoints + 1) do
            frame[i]:Hide();
         end
      end
   end
end
]];

      state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
      local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
      mux:Event_MaskAll("UNIT_COMBO_POINTS", 2);

      return true;
   end;
   UIFromDescriptor = function(desc, parent, state)
      local ui = VFLUI.CompoundFrame:new(parent);

      -- Name/width/height
      local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

      -- Owner
      local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
      if desc and desc.owner then owner:SetSelection(desc.owner); end

      -- Anchor
      local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
      anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
      if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
      ui:InsertFrame(anchor);

      -- Drawlayer
      local er = RDXUI.EmbedRight(ui, "Draw layer:");
      local drawLayer = VFLUI.Dropdown:new(er, RDXUI.DrawLayerDropdownFunction);
      drawLayer:SetWidth(100); drawLayer:Show();
      if desc and desc.drawLayer then drawLayer:SetSelection(desc.drawLayer); else drawLayer:SetSelection("ARTWORK"); end
      er:EmbedChild(drawLayer); er:Show();
      ui:InsertFrame(er);

      -- Texture
      local er = RDXUI.EmbedRight(ui, "Texture");
      local tsel = VFLUI.MakeTextureSelectButton(er, desc.texture); tsel:Show();
      er:EmbedChild(tsel); er:Show();
      ui:InsertFrame(er);

      local er = RDXUI.EmbedRight(ui, "Orientation:");
      local dd_orientation = VFLUI.Dropdown:new(er, _dd_orientations);
      dd_orientation:SetWidth(75); dd_orientation:Show();
      if desc and desc.orientation then
         dd_orientation:SetSelection(desc.orientation);
      else
         dd_orientation:SetSelection("RIGHT");
      end
      er:EmbedChild(dd_orientation); er:Show();
      ui:InsertFrame(er);

      local ed_spacex = VFLUI.LabeledEdit:new(ui, 50); ed_spacex:Show();
      ed_spacex:SetText("Texture Spacing Offset X/Y");
      if desc and desc.spacex then ed_spacex.editBox:SetText(desc.spacex); end
      ui:InsertFrame(ed_spacex);

      local ed_spacey = VFLUI.LabeledEdit:new(ui, 50); ed_spacey:Show();
      ed_spacey:SetText("Texture Y Offset");
      if desc and desc.spacey then ed_spacey.editBox:SetText(desc.spacey); end
      ui:InsertFrame(ed_spacey);
      
      local cp1 = RDXUI.GenerateColorSwatch(ui, "Combo Point 1 Color");
      if desc and desc.cp1 then cp1:SetColor(explodeRGBA(desc.cp1)); end
      local cp2 = RDXUI.GenerateColorSwatch(ui, "Combo Point 2 Color");
      if desc and desc.cp2 then cp2:SetColor(explodeRGBA(desc.cp2)); end
      local cp3 = RDXUI.GenerateColorSwatch(ui, "Combo Point 3 Color");
      if desc and desc.cp3 then cp3:SetColor(explodeRGBA(desc.cp3)); end
      local cp4 = RDXUI.GenerateColorSwatch(ui, "Combo Point 4 Color");
      if desc and desc.cp4 then cp4:SetColor(explodeRGBA(desc.cp4)); end
      local cp5 = RDXUI.GenerateColorSwatch(ui, "Combo Point 5 Color");
      if desc and desc.cp5 then cp5:SetColor(explodeRGBA(desc.cp5)); end

      local chk_setup = VFLUI.Checkbox:new(ui);
      chk_setup:Show(); chk_setup:SetText("Setup Mode (Shows All Combo Textures)");
      if desc and desc.setup then chk_setup:SetChecked(true); end
      ui:InsertFrame(chk_setup);

      function ui:GetDescriptor()
         return {
            feature = "icp"; version = 1;
            name = ed_name.editBox:GetText();
            owner = owner:GetSelection();
            drawLayer = drawLayer:GetSelection();
            texture = tsel:GetSelectedTexture();
            w = ed_width:GetSelection();
	h = ed_height:GetSelection();
            anchor = anchor:GetAnchorInfo();
            setup = chk_setup:GetChecked();
            orientation = dd_orientation:GetSelection();
            spacex = VFL.clamp(ed_spacex.editBox:GetNumber(), -50, 50);
            spacey = VFL.clamp(ed_spacey.editBox:GetNumber(), -50, 50);
            cp1 = cp1:GetColor(); cp2 = cp2:GetColor(); cp3 = cp3:GetColor();
            cp4 = cp4:GetColor(); cp5 = cp5:GetColor();
         };
      end

      return ui;
   end;
   CreateDescriptor = function()
      return {
         feature = "icp"; version = 1;
         name = "icp1", owner = "Base", drawLayer = "ARTWORK";
         texture = VFL.copy(VFLUI.defaultTexture);
           w = 20; h = 20;
         anchor = { lp = "BOTTOMLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 15};
         orientation = "RIGHT";
         spacex = 0; spacey = 0;
         setup = false;
         cp1 = {r=1,g=1,b=1,a=1};
         cp2 = {r=1,g=1,b=1,a=1};
         cp3 = {r=1,g=1,b=1,a=1};
         cp4 = {r=1,g=1,b=1,a=1};
         cp5 = {r=1,g=1,b=1,a=1};
      };
   end;
});
