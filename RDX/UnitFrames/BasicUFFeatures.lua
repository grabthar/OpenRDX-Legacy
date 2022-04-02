-- BasicUFFeatures.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- The basic unit frame features. (Baseframe, bars, text boxes.)

--

RDX.RegisterFeature({
	name = "Variable: Static Value";
	title = i18n("Variable: Static Value");
	category = i18n("Basics");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitClosure") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not desc.value then VFL.AddError(errs, i18n("Missing value")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("StaticVar_" .. desc.name);
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[ = ]] .. desc.value .. [[;
]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local value = VFLUI.LabeledEdit:new(ui, 100); value:Show();
		value:SetText(i18n("Variable Value"));
		if desc and desc.value then value.editBox:SetText(desc.value); end
		ui:InsertFrame(value);

		function ui:GetDescriptor()
			return {
				feature = "Variable: Static Value"; 
				name = name.editBox:GetText();
				value = value.editBox:GetText();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Variable: Static Value"; name = "staticValue"; value = 0 };
	end;
});

------------------ BASEFRAME
RDX.RegisterFeature({
	name = "base_default"; version = 1; title = i18n("Base Frame"); category = i18n("Basics");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitCreate") then return nil; end
		if not state:Slot("EmitDestroy") then return nil; end
		if state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if (not desc) or (not desc.w) or (not desc.h) then
			VFL.AddError(errs, i18n("Bad or missing width/height parameters."));
			return nil;
		end
		if desc.ph and state:Slot("Hotspot_") then
			VFL.AddError(errs, i18n("Duplicate primary hotspots."));
			return nil;
		end
		if desc.ph then state:AddSlot("Hotspot_"); end
		if (not desc.alpha) or (desc.alpha < 0.05) then
			desc.alpha = 1;
		end
		state:AddSlot("Base");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local alpha = desc.alpha or 1;
		local dx,dy = desc.w, desc.h;
		local createCode = [[
frame:SetWidth(]] .. dx .. [[); frame:SetHeight(]] .. dy .. [[);
frame:SetAlpha(]] .. alpha .. [[);
]];
		if desc.ph then
            local hlt = desc.hlt or "false";
			createCode = createCode .. [[
local btn = VFLUI.AcquireFrame("SecureUnitButton");
VFLUI.StdSetParent(btn, frame, 4);
btn:SetAttribute("useparent-unit", true); btn:SetAttribute("unit", nil);
btn:SetAttribute("useparent-unitsuffix", true); btn:SetAttribute("unitsuffix", nil);
btn:SetAllPoints(frame); btn:Show();
if not ]] .. hlt .. [[ then
btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
end
frame._phs = btn; frame:SetHotspot(nil, btn);
]];
			state:Attach("EmitDestroy", nil, function(code) code:AppendCode([[
frame._phs:Destroy(); frame._phs = nil;
]]); end);
		end -- if desc.ph
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:AddSlot("FrameDimensions");
		state:Attach(state:Slot("FrameDimensions"), nil, function() return dx,dy; end);
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local ed_width, ed_height = RDXUI.GenWidthHeightPortion(ui, desc, state);

		local ed_alpha = VFLUI.LabeledEdit:new(ui, 50); ed_alpha:Show();
		ed_alpha:SetText(i18n("Base alpha"));
		if desc and desc.alpha then ed_alpha.editBox:SetText(desc.alpha); end
		ui:InsertFrame(ed_alpha);

		local chk_ph = VFLUI.Checkbox:new(ui); 
		chk_ph:Show(); chk_ph:SetText(i18n("Auto-create primary hotspot"));
		if desc and desc.ph then chk_ph:SetChecked(true); end
		ui:InsertFrame(chk_ph);
        
		local chk_hlt = VFLUI.Checkbox:new(ui); 
		chk_hlt:Show(); chk_hlt:SetText(i18n("Disable highlight on mouseover"));
		if desc and desc.hlt then chk_hlt:SetChecked(true); end
		ui:InsertFrame(chk_hlt);

		function ui:GetDescriptor()
			local a = ed_alpha.editBox:GetNumber(); if not a then a = 1; end
			a = VFL.clamp(a, 0, 1);
			return { 
				feature = "base_default"; version = 1; 
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				alpha = a; ph = chk_ph:GetChecked(); hlt = chk_hlt:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "base_default"; version = 1;
			w = 90, h = 14, alpha = 1, ph = true;
		};
	end;
});

-- Update old baseframes
RDX.RegisterFeature({
	name = "Base Frame: Default"; version = 31337; invisible = true;
	IsPossible = VFL.Nil;
	VersionMismatch = function(desc)
		desc.feature = "base_default"; desc.version = 1; desc.ph = true;
		return true;
	end;
});

-------------------- HEALTH BAR
RDX.RegisterFeature({
	name = "Bar: RDX Unit HP Bar";
	category = i18n("Oldschool Unitframes");
	deprecated = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = __UFFrameCheck("Frame_");
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		if not desc.hostileColor then desc.hostileColor = _red; end

		-- Event hint
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local healthMask = mux:GetPaintMask("HEALTH");
		mux:Event_UnitMask("UNIT_HEALTH", healthMask);
		
		---- Generate the code.
		local createCode = [[
local bar = VFLUI.AcquireFrame("StatusBar");
bar:SetParent(frame); bar:SetFrameLevel(frame:GetFrameLevel() + (]] .. (desc.flo or -1) .. [[));
bar:SetWidth(]] .. desc.w .. [[); bar:SetHeight(]] .. desc.h .. [[);
bar:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
bar:SetStatusBarTexture("]] .. desc.texture .. [[");
bar:SetMinMaxValues(0,1); bar:Show();
frame.]] .. objname .. [[ = bar;
]];

		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];

		local cleanupCode = [[
frame.]] .. objname .. [[:SetValue(0);
]];

		-- Only paint if healthMask is set.
		local paintCode = [[
if unit:IsFeigned() then
	RDX.SetStatusBar(frame.]] .. objname .. [[, 1, _grey);
elseif not unit:IsOnline() then
	RDX.SetStatusBar(frame.]] .. objname .. [[, 0, _grey);
elseif UnitIsFriend(uid, "player") then
	RDX.SetStatusBar(frame.]] .. objname .. [[, unit:FracHealth(), ]] .. objname .. [[_c, ]] .. objname .. [[_fc);
else
	RDX.SetStatusBar(frame.]] .. objname .. [[, unit:FracHealth(), ]] .. objname .. [[_hc, ]] .. objname .. [[_fc);
end
]];

		local closureCode = [[
local ]] .. objname .. [[_c = ]] .. Serialize(desc.color) .. [[;
local ]] .. objname .. [[_fc = ]] .. Serialize(desc.fadeColor) .. [[;
local ]] .. objname .. [[_hc = ]] .. Serialize(desc.hostileColor) .. [[;
]];
		
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		state:Attach(state:Slot("EmitClosure"), true, function(code) code:AppendCode(closureCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_texture = VFLUI.LabeledEdit:new(ui, 200); ed_texture:Show();
		ed_texture:SetText(i18n("Texture (use double backslashes)"));
		if desc and desc.texture then ed_texture.editBox:SetText(desc.texture); end
		ui:InsertFrame(ed_texture);

		local ed_flo = VFLUI.LabeledEdit:new(ui, 50); ed_flo:Show();
		ed_flo:SetText(i18n("FrameLevel offset"));
		if desc and desc.flo then ed_flo.editBox:SetText(desc.flo); else ed_flo.editBox:SetText(-1); end
		ui:InsertFrame(ed_flo);

		local er = RDXUI.EmbedRight(ui, i18n("Color:"));
		local swatch_c = VFLUI.ColorSwatch:new(er);
		swatch_c:Show();
		if desc and desc.color then swatch_c:SetColor(explodeColor(desc.color)); end
		er:EmbedChild(swatch_c); er:Show();
		ui:InsertFrame(er);

		er = RDXUI.EmbedRight(ui, i18n("Hostile color:"));
		local swatch_hc = VFLUI.ColorSwatch:new(er);
		swatch_hc:Show();
		if desc and desc.hostileColor then swatch_hc:SetColor(explodeColor(desc.hostileColor)); end
		er:EmbedChild(swatch_hc); er:Show();
		ui:InsertFrame(er);

		er = RDXUI.EmbedRight(ui, i18n("Fade color:"));
		local swatch_fc = VFLUI.ColorSwatch:new(er);
		swatch_fc:Show();
		if desc and desc.fadeColor then swatch_fc:SetColor(explodeColor(desc.fadeColor)); end
		er:EmbedChild(swatch_fc); er:Show();
		ui:InsertFrame(er);
		
		function ui:GetDescriptor()
			return { 
				feature = "Bar: RDX Unit HP Bar";
				name = ed_name.editBox:GetText();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				texture = ed_texture.editBox:GetText(); 
				color = swatch_c:GetColor();
				fadeColor = swatch_fc:GetColor();
				hostileColor = swatch_hc:GetColor();
				flo = VFL.clamp(ed_flo.editBox:GetNumber(), -2, 5);
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Bar: RDX Unit HP Bar", name = "hpbar", w = 90, h = 14, anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 }, texture = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1", color = {r=0, g=0.5, b=0}, fadeColor = {r=1, g=0, b=0}, hostileColor = {r=0.86, g=0.36, b=0}, flo = -1 };
	end;
});

-------------------- MANA BAR
RDX.RegisterFeature({
	name = "Bar: RDX Unit Mana Bar";
	title = "Bar: RDX Unit Power Bar";
	category = i18n("Oldschool Unitframes"); deprecated = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = __UFFrameCheck("Frame_");
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;

		-- Event hint
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("POWER");
		mux:Event_UnitMask("UNIT_POWER", mask);
		
		---- Generate the code.
		local createCode = [[
local bar = VFLUI.AcquireFrame("StatusBar");
bar:SetParent(frame); bar:SetFrameLevel(frame:GetFrameLevel() + (]] .. (desc.flo or -1) .. [[));
bar:SetWidth(]] .. desc.w .. [[); bar:SetHeight(]] .. desc.h .. [[);
bar:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
bar:SetStatusBarTexture("]] .. desc.texture .. [[");
bar:SetMinMaxValues(0,1); bar:Show();
frame.]] .. objname .. [[ = bar;
]];

		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];

		local cleanupCode = [[
frame.]] .. objname .. [[:SetValue(0);
]];

		local paintCode = [[
if not unit:IsOnline() then
	RDX.SetStatusBar(frame.]] .. objname .. [[, 0, _grey);
else
	RDX.SetStatusBar(frame.]] .. objname .. [[, unit:FracPower(), ]] .. objname .. [[_cf(unit:PowerType()), ]] .. objname .. [[_fc);
end
]];

		local closureCode = [[
local ]] .. objname .. [[_mc = ]] .. Serialize(desc.manaColor) .. [[;
local ]] .. objname .. [[_ec = ]] .. Serialize(desc.energyColor) .. [[;
local ]] .. objname .. [[_rc = ]] .. Serialize(desc.rageColor) .. [[;
local ]] .. objname .. [[_ruc = ]] .. Serialize(desc.runeColor) .. [[;
local ]] .. objname .. [[_fc = ]] .. Serialize(desc.fadeColor) .. [[;
local function ]] .. objname .. [[_cf(et)
	if(et == 0) then
		return ]] .. objname .. [[_mc;
	elseif(et == 1) then
		return ]] .. objname .. [[_rc;
	elseif(et == 3) then
		return ]] .. objname .. [[_ec;
	elseif(et == 6) then
		return ]] .. objname .. [[_ruc;
	else
		return ]] .. objname .. [[_mc;
	end
end
]];
		
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		state:Attach(state:Slot("EmitClosure"), true, function(code) code:AppendCode(closureCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_texture = VFLUI.LabeledEdit:new(ui, 200); ed_texture:Show();
		ed_texture:SetText(i18n("Texture (use double backslashes)"));
		if desc and desc.texture then ed_texture.editBox:SetText(desc.texture); end
		ui:InsertFrame(ed_texture);

		local ed_flo = VFLUI.LabeledEdit:new(ui, 50); ed_flo:Show();
		ed_flo:SetText(i18n("FrameLevel offset"));
		if desc and desc.flo then ed_flo.editBox:SetText(desc.flo); else ed_flo.editBox:SetText(-1); end
		ui:InsertFrame(ed_flo);

		local er = RDXUI.EmbedRight(ui, i18n("Mana Color:"));
		local swatch_manac = VFLUI.ColorSwatch:new(er);
		swatch_manac:Show();
		if desc and desc.manaColor then swatch_manac:SetColor(explodeColor(desc.manaColor)); end
		er:EmbedChild(swatch_manac); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Energy Color:"));
		local swatch_energyc = VFLUI.ColorSwatch:new(er);
		swatch_energyc:Show();
		if desc and desc.energyColor then swatch_energyc:SetColor(explodeColor(desc.energyColor)); end
		er:EmbedChild(swatch_energyc); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Rage Color:"));
		local swatch_ragec = VFLUI.ColorSwatch:new(er);
		swatch_ragec:Show();
		if desc and desc.rageColor then swatch_ragec:SetColor(explodeColor(desc.rageColor)); end
		er:EmbedChild(swatch_ragec); er:Show();
		ui:InsertFrame(er);
		
		local er = RDXUI.EmbedRight(ui, i18n("Rune Color:"));
		local swatch_runec = VFLUI.ColorSwatch:new(er);
		swatch_runec:Show();
		if desc and desc.runeColor then swatch_runec:SetColor(explodeColor(desc.runeColor)); end
		er:EmbedChild(swatch_runec); er:Show();
		ui:InsertFrame(er);

		er = RDXUI.EmbedRight(ui, i18n("Fade color:"));
		local swatch_fc = VFLUI.ColorSwatch:new(er);
		swatch_fc:Show();
		if desc and desc.fadeColor then swatch_fc:SetColor(explodeColor(desc.fadeColor)); end
		er:EmbedChild(swatch_fc); er:Show();
		ui:InsertFrame(er);
		
		function ui:GetDescriptor()
			return { 
				feature = "Bar: RDX Unit Mana Bar";
				name = ed_name.editBox:GetText();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				texture = ed_texture.editBox:GetText(); 
				manaColor = swatch_manac:GetColor();
				energyColor = swatch_energyc:GetColor();
				rageColor = swatch_ragec:GetColor();
				fadeColor = swatch_fc:GetColor();
				runeColor = swatch_runec:GetColor();
				flo = VFL.clamp(ed_flo.editBox:GetNumber(), -2, 5);
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Bar: RDX Unit Mana Bar", name = "mpbar", w = 90, h = 14, anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 }, texture = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1", manaColor = {r=0, g=0, b=0.75}, rageColor = {r=1,g=0,b=0}, energyColor = {r=0.75,g=0.75,b=0}, runeColor = {r=0,g=0.75,b=1}, fadeColor = {r=1, g=0, b=0}, flo = -1 };
	end;
});

--------------------------------------------
-- XXX COMPAT: Replace old text features with new ones
--------------------------------------------
function _GenerateReplaceTextFeature(oldFeat, newFeatName, newFeatVers, hook)
	hook = hook or VFL.Noop;
	RDX.RegisterFeature({
		name = oldFeat; version = 31337;
		invisible = true;
		IsPossible = VFL.Nil;
		VersionMismatch = function(desc)
			-- Port the feature name
			desc.feature = newFeatName; desc.version = newFeatVers;
			-- Port the font.
			desc.font = VFL.copy(Fonts.Default);
			desc.font.size = desc.fontSize or 10;
			desc.font.justifyH = desc.halign;
			desc.font.justifyV = desc.valign;
			desc.fontFace = nil; desc.fontSize = nil; desc.halign = nil; desc.valign = nil;
			-- Run the extra hook
			hook(desc);
			return true;
		end;
	});
end

_GenerateReplaceTextFeature(i18n("HP%"), "txt_status", 1, function(desc) desc.ty = "hpp"; end);
_GenerateReplaceTextFeature(i18n("HP"), "txt_status", 1, function(desc) desc.ty = "hp"; end);
_GenerateReplaceTextFeature(i18n("HP Missing"), "txt_status", 1, function(desc) desc.ty = "hpm"; end);
_GenerateReplaceTextFeature(i18n("Mana%"), "txt_status", 1, function(desc) desc.ty = "mpp"; end);
_GenerateReplaceTextFeature(i18n("Mana"), "txt_status", 1, function(desc) desc.ty = "mp"; end);
_GenerateReplaceTextFeature(i18n("Mana Missing"), "txt_status", 1, function(desc) desc.ty = "mpm"; end);
_GenerateReplaceTextFeature(i18n("Group Number"), "txt_status", 1, function(desc) desc.ty = "gn"; end);
