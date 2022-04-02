-- StatusBars.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Allows any Texture to be used as a StatusBar.


local function NEditor(ctr, nC, label, ew)
	label = label or ""; ew = ew or 50;
	
	local f = VFLUI.AcquireFrame("Frame");
	VFLUI.StdSetParent(f, ctr);
	f:SetHeight(25);
	f.DialogOnLayout = VFL.Noop; f:Show();

	local t1 = VFLUI.CreateFontString(f);
	t1:SetFontObject(Fonts.Default10); t1:SetWidth(150); t1:SetHeight(25);
	t1:SetJustifyH("LEFT");
	t1:SetPoint("LEFT", f, "LEFT");
	t1:SetText(label); t1:Show();

	f.edit = {};
	local af = t1;
	for i=1,nC do
		local ed = VFLUI.Edit:new(f);
		ed:SetHeight(25); ed:SetWidth(ew);
		ed:SetPoint("LEFT", af, "RIGHT", 1, 0); ed:Show();
		af = ed; f.edit[i] = ed;
	end

	function f:SetNumbers(n1,n2,n3,n4)
		if n1 and self.edit[1] then self.edit[1]:SetText(n1); end
		if n2 and self.edit[2] then self.edit[2]:SetText(n2); end
		if n3 and self.edit[3] then self.edit[3]:SetText(n3); end
		if n4 and self.edit[4] then self.edit[4]:SetText(n4); end
	end
	
	function f:GetNumbers(cmin, cmax)
		local n = {};
		for i=1,nC do
			n[i] = VFL.clamp(self.edit[i]:GetNumber(), cmin, cmax);
		end
		return n[1], n[2], n[3], n[4];
	end

	f.Destroy = VFL.hook(function(s)
		s.SetNumbers = nil; s.GetNumbers = nil;
		for _,editor in pairs(s.edit) do editor:Destroy(); end
		VFLUI.ReleaseRegion(t1);
		s.edit = nil;
	end, f.Destroy);

	return f;
end


RDX.RegisterFeature({
	name = "StatusBar Texture Map";
	category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not desc.flag then desc.flag = "true"; end
		if not RDXUI.IsValidBoolVar(desc.flag, state) then
			VFL.AddError(errs, i18n("Invalid flag variable.")); return nil;
		end
		-- Verify our texture
		if (not desc.texture) or (not state:Slot("Texture_" .. desc.texture)) then
			VFL.AddError(errs, i18n("Invalid texture object pointer.")); return nil;
		end
		-- Verify our blend fraction
		if (not desc.frac) or (not state:Slot("FracVar_" .. desc.frac)) then
			VFL.AddError(errs, i18n("Invalid blend fraction variable.")); return nil;
		end
		if (not desc.color) or (not state:Slot("ColorVar_" .. desc.color)) then
			VFL.AddError(errs, i18n("Invalid color variable.")); return nil;
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		local objname = RDXUI.ResolveTextureReference(desc.texture);
		local paintCode = [[
if ]] .. desc.flag .. [[ then
	]] .. objname .. [[:Show();
	]] .. objname .. [[:SetWidth(lerp1(]] .. desc.frac .. "," .. desc.w1 .. "," .. desc.w2 .. [[));
	]] .. objname .. [[:SetHeight(lerp1(]] .. desc.frac .. "," .. desc.h1 .. "," .. desc.h2 .. [[));
	]] .. objname .. [[:SetTexCoord(lerp4(]] .. desc.frac .. "," .. desc.l1 .. "," .. desc.l2 .. "," .. desc.r1 .. "," .. desc.r2 .. "," .. desc.b1 .. "," .. desc.b2 .. "," .. desc.t1 .. "," .. desc.t2 .. [[));
	]] .. objname .. [[:SetVertexColor(explodeRGBA(]] .. desc.color .. [[));
else
	]] .. objname .. [[:Hide();
end
]];
		local cleanupCode = [[
]] .. objname .. [[:Hide();
]];
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local flag = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Show condition variable"), state, "BoolVar_", nil, "true", "false");
		if desc and desc.flag then flag:SetSelection(desc.flag); end

		local texture = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Texture"), state, "TexVar_");
		if desc and desc.texture then texture:SetSelection(desc.texture); end

		local frac = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Fraction variable"), state, "FracVar_");
		if desc and desc.frac then frac:SetSelection(desc.frac); end
		
		local color = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Color variable"), state, "ColorVar_");
		if desc and desc.color then color:SetSelection(desc.color); end
		
		local wh1 = NEditor(ui, 2, i18n("Empty width/height"), 50);
		if desc then wh1:SetNumbers(desc.w1, desc.h1); end
		ui:InsertFrame(wh1);

		local wh2 = NEditor(ui, 2, i18n("Full width/height"), 50);
		if desc then wh2:SetNumbers(desc.w2, desc.h2); end
		ui:InsertFrame(wh2);

		local tc1 = NEditor(ui, 4, i18n("Empty texcoords (l,b,r,t)"), 50);
		if desc then tc1:SetNumbers(desc.l1, desc.b1, desc.r1, desc.t1); end
		ui:InsertFrame(tc1);

		local tc2 = NEditor(ui, 4, i18n("Full texcoords (l,b,r,t)"), 50);
		if desc then tc2:SetNumbers(desc.l2, desc.b2, desc.r2, desc.t2); end
		ui:InsertFrame(tc2);

		function ui:GetDescriptor()
			local w1,h1 = wh1:GetNumbers(0.1, 1000);
			local w2,h2 = wh2:GetNumbers(0.1, 1000);
			local l1,b1,r1,t1 = tc1:GetNumbers(0, 1);
			local l2,b2,r2,t2 = tc2:GetNumbers(0, 1);
			return {
				feature = "StatusBar Texture Map";
				flag = flag:GetSelection();
				texture = texture:GetSelection(); frac = frac:GetSelection(); color = color:GetSelection();
				w1 = w1; h1 = h1; w2 = w2; h2 = h2;
				l1 = l1; r1 = r1; b1 = b1; t1 = t1;
				l2 = l2; r2 = r2; b2 = b2; t2 = t2;
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "StatusBar Texture Map";
			flag = "true";
			w1 = 0.1; h1 = 14; w2 = 90; h2 = 14;
			l1 = 0; r1 = 0; b1 = 0; t1 = 1;
			l2 = 0; r2 = 1; b2 = 0; t2 = 1;
		};
	end;
});

-----------------------------------------------------------
-- A premade status bar.
-----------------------------------------------------------
local tbl_hvert = { {text = "HORIZONTAL"}, {text = "VERTICAL"} };
local function hvert_gen() return tbl_hvert; end

RDX.RegisterFeature({
	name = "statusbar_horiz"; version = 1;
	title = i18n("Status Bar"); category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if desc.frac and desc.frac ~= "" then
			if not tonumber(desc.frac) and not (state:Slot("FracVar_" .. desc.frac)) then 
				VFL.AddError(errs, i18n("Invalid frac value")); flg = nil;
			end
		end
		if flg then 
			state:AddSlot("StatusBar_" .. desc.name);
			state:AddSlot("Frame_" .. desc.name);
		end
		if desc.colorVar and (not state:Slot("ColorVar_" .. desc.colorVar)) then
			VFL.AddError(errs, i18n("Invalid color variable.")); flg = nil;
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		-- Closure
		if desc.color1 then
			local closureCode = [[
local c1_]] .. objname .. " = " .. Serialize(desc.color1) .. [[
local c2_]] .. objname .. " = " .. Serialize(desc.color2) .. [[
]];
			state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);
		end -- if desc.color1

		-- Creation
		local orientation = "HORIZONTAL";
		if desc.orientation == "VERTICAL" then orientation = "VERTICAL"; end
		local reduce = desc.reduce or "false";
		local createCode = [[
local _t = VFLUI.StatusBarTexture:new(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[, ]] ..reduce..[[);
frame.]] .. objname .. [[ = _t;
_t:SetOrientation("]] .. orientation .. [[");
_t:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_t:SetWidth(]] .. desc.w .. [[); _t:SetHeight(]] .. desc.h .. [[);
_t:Show();
]];
		createCode = createCode .. VFLUI.GenerateSetTextureCode("_t", desc.texture);
		if desc.color1 then createCode = createCode .. [[
_t:SetColors(c1_]] .. objname .. [[, c2_]] .. objname .. [[);
]];
		end
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);

		-- Cleanup
		local cleanupCode = [[
frame.]] .. objname .. [[:SetValue(0);
]];
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);

		-- Paint (only apply paint code if the fraction exists)
		local frac = strtrim(desc.frac or "");
		local colorVar = strtrim(desc.colorVar or "");
		local paintCode;
		if frac ~= "" then
			paintCode = [[
local ac = 0.2;
if ]] .. desc.frac .. [[ == 1 or ]] .. desc.frac .. [[ == 0 then ac = nil; else ac = 0.2; end
]];
			if desc.interpolate then
				if desc.color1 then paintCode = paintCode .. [[
frame.]] .. objname .. [[:SetValue(]] .. desc.frac .. [[,ac);
]];
                		else paintCode = paintCode .. [[
frame.]] .. objname .. [[:SetValueAndColorTable(]] .. desc.frac .. [[, ]] .. desc.colorVar .. [[,ac);
]];
                		end
			else
				if desc.color1 then paintCode = [[
frame.]] .. objname .. [[:SetValue(]] .. desc.frac .. [[);
]];
                		else paintCode = [[
frame.]] .. objname .. [[:SetValueAndColorTable(]] .. desc.frac .. [[, ]] .. desc.colorVar .. [[);
]];
                		end
			end
			state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		elseif colorVar ~= "" then
			paintCode = [[
frame.]] .. objname .. [[:SetColorTable(]] .. desc.colorVar .. [[);
]];
			state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		end
		-- Destroy
		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Anchor
		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		-- Orientation
		local er = RDXUI.EmbedRight(ui, i18n("Orientation:"));
		local dd_orientation = VFLUI.Dropdown:new(er, hvert_gen);
		dd_orientation:SetWidth(100); dd_orientation:Show();
		if desc and desc.orientation then 
			dd_orientation:SetSelection(desc.orientation); 
		else
			dd_orientation:SetSelection("HORIZONTAL");
		end
		er:EmbedChild(dd_orientation); er:Show();
		ui:InsertFrame(er);

		-- Texture
		local er = RDXUI.EmbedRight(ui, i18n("Texture"));
		local tsel = VFLUI.MakeTextureSelectButton(er, desc.texture); tsel:Show();
		er:EmbedChild(tsel); er:Show();
		ui:InsertFrame(er);

		-- Statusbar-specific parameters
		local frac = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Fraction variable"), state, "FracVar_");
		if desc and desc.frac then frac:SetSelection(desc.frac); end
		
		local colorVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Use color variable"), state, "ColorVar_");
		if desc and desc.colorVar then colorVar:SetSelection(desc.colorVar); end

		local color1 = RDXUI.GenerateColorSwatch(ui, i18n("Static empty color"));
		if desc and desc.color1 then color1:SetColor(explodeRGBA(desc.color1)); end

		local color2 = RDXUI.GenerateColorSwatch(ui, i18n("Static full color"));
		if desc and desc.color2 then color2:SetColor(explodeRGBA(desc.color2)); end
        
        local chk_interpolate = VFLUI.Checkbox:new(ui); chk_interpolate:Show();
        chk_interpolate:SetText(i18n("Smooth bar value changes over time"));
        if desc and desc.interpolate then chk_interpolate:SetChecked(true); else chk_interpolate:SetChecked(); end
        ui:InsertFrame(chk_interpolate);
        
        local chk_reduce = VFLUI.Checkbox:new(ui); chk_reduce:Show();
        chk_reduce:SetText(i18n("Always reduce status bar texture from top to bottom, if vertical"));
        if desc and desc.reduce then chk_reduce:SetChecked(true); else chk_reduce:SetChecked(); end
        ui:InsertFrame(chk_reduce);
        
		function ui:GetDescriptor()
			local scolorVar = strtrim(colorVar:GetSelection() or "");
			local scolor1, scolor2 = nil, nil;
			if scolorVar == "" then
				scolorVar = nil;
				scolor1 = color1:GetColor(); scolor2 = color2:GetColor();
			end

			return {
				feature = "statusbar_horiz"; version = 1;
				name = ed_name.editBox:GetText();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				orientation = dd_orientation:GetSelection();
				texture = tsel:GetSelectedTexture();
				frac = frac:GetSelection();
				colorVar = scolorVar; color1 = scolor1; color2 = scolor2;
				interpolate = chk_interpolate:GetChecked();
				reduce = chk_reduce:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "statusbar_horiz"; version = 1;
			name = "statusBar";
			w = 90; h = 14; owner = "Base"; 
			orientation = "HORIZONTAL";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			texture = VFL.copy(VFLUI.defaultTexture);
		};
	end;
});
