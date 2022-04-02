-- Text.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Unit frame features that add text to various places on the unit frame.

local function _EmitCreateFontString(desc)
	return [[
local txt = VFLUI.CreateFontString(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
txt:SetWidth(]] .. desc.w .. [[); txt:SetHeight(]] .. desc.h .. [[);
]];
end

--- Scripted custom text.
RDX.RegisterFeature({
	name = "txt_custom";	version = 1;	multiple = true;
	title = i18n("Custom Text");	category = i18n("Text");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Text_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then 
			state:AddSlot("Text_" .. desc.name);
			state:AddSlot("TextCustom_" .. desc.name);
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		if not VFLUI.isFacePathExist(desc.font.face) then desc.font.face = "Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf"; end
		local tname = RDXUI.ResolveTextReference(desc.name);
		local colorVar, colorBoo = strtrim(desc.color or ""), "false";
		if colorVar ~= "" then colorBoo = "true"; end 
		
		---- Generate the code.
		local closureCode = [[
local text = "";
]];
		
		local createCode = _EmitCreateFontString(desc) .. [[
txt:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
]] .. VFLUI.GenerateSetFontCode("txt", desc.font, nil, true) .. [[
txt:Show();
]] .. tname .. [[ = txt;
]];

		local destroyCode = [[
]] .. tname .. [[:Destroy(); 
]] .. tname .. [[ = nil;
]];

		local cleanupCode = [[
]] .. tname .. [[:SetText("");
]];

		-- Apply the custom code.
		local md,_,_,ty = RDXDB.GetObjectData(desc.script);
		if (md) and (ty == "Script") and (md.data) and ( md.data.script) then
			local paintCode = [[
text = ]] .. (desc.useNil and 'nil' or '""') .. [[;

]] .. md.data.script .. [[

if text then ]] .. tname .. [[:SetText(text); 
	if ]] .. colorBoo .. [[ then ]] .. tname .. [[:SetTextColor(explodeRGBA(]] ..colorVar .. [[)); end 
end
]];
			state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		end
		
		state:Attach(state:Slot("EmitClosure"), true, function(code) code:AppendCode(closureCode); end);
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local er = RDXUI.EmbedRight(ui, i18n("Font"));
		local fontsel = VFLUI.MakeFontSelectButton(er, desc.font); fontsel:Show();
		er:EmbedChild(fontsel); er:Show();
		ui:InsertFrame(er);

		local chk_useNil = VFLUI.Checkbox:new(ui); 
		chk_useNil:Show(); chk_useNil:SetText(i18n("Preserve existing content if text local variable is undefined"))
		if desc and desc.useNil then chk_useNil:SetChecked(true); end
		ui:InsertFrame(chk_useNil);

		local scriptsel = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "Script")); end);
		scriptsel:SetLabel(i18n("Script object")); scriptsel:Show();
		if desc and desc.script then scriptsel:SetPath(desc.script); end
		ui:InsertFrame(scriptsel);
		
		local colorVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Color variable"), state, "ColorVar_");
		if desc and desc.color then colorVar:SetSelection(desc.color); end 

		function ui:GetDescriptor()
			local scolorVar = strtrim(colorVar:GetSelection() or "");
			if scolorVar == "" then scolorVar = nil; end 
			return { 
				feature = "txt_custom"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				font = fontsel:GetSelectedFont();
				useNil = chk_useNil:GetChecked();
				script = scriptsel:GetPath();
				color = scolorVar;
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "txt_custom", version = 1,
			name = "customText", w = 50, h = 14, owner = "Base",
			anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 }, 
			font = VFL.copy(Fonts.Default);
		};
	end;
});

-- Static text.
RDX.RegisterFeature({
	name = "txt_static";	version = 1;	multiple = true;
	title = i18n("Static Text");	category = i18n("Text");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		if (not desc.txt) then
			VFL.AddError(errs, i18n("Invalid texte")); return nil;
		end
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Text_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then 
			state:AddSlot("Text_" .. desc.name);
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		if not VFLUI.isFacePathExist(desc.font.face) then desc.font.face = "Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf"; end
		local tname = RDXUI.ResolveTextReference(desc.name);
		local colorVar, colorBoo = strtrim(desc.color or ""), "false";
		if colorVar ~= "" then colorBoo = "true"; end
		
		---- Generate the code.
		local createCode = _EmitCreateFontString(desc) .. [[
txt:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
]] .. VFLUI.GenerateSetFontCode("txt", desc.font, nil, true) .. [[
txt:Show();
]] .. tname .. [[ = txt;
]];
		local destroyCode = [[
]] .. tname .. [[:Destroy(); 
]] .. tname .. [[ = nil;
]];
		local cleanupCode = [[
]] .. tname .. [[:SetText("");
]];
		-- Apply the static text
		local paintCode = [[
]] .. tname .. [[:SetText("]] .. desc.txt .. [[");
if ]] .. colorBoo .. [[ then
	]] .. tname .. [[:SetTextColor(explodeRGBA(]] .. colorVar .. [[));
end
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local er = RDXUI.EmbedRight(ui, i18n("Font"));
		local fontsel = VFLUI.MakeFontSelectButton(er, desc.font); fontsel:Show();
		er:EmbedChild(fontsel); er:Show();
		ui:InsertFrame(er);

		local txt = VFLUI.LabeledEdit:new(ui, 200);
		txt:SetText(i18n("Static Text"));
		txt:Show();
		if desc and desc.txt then txt.editBox:SetText(desc.txt); end
		ui:InsertFrame(txt);
		
		local colorVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Color variable"), state, "ColorVar_");
		if desc and desc.color then colorVar:SetSelection(desc.color); end

		function ui:GetDescriptor()
			local scolorVar = strtrim(colorVar:GetSelection() or "");
			if scolorVar == "" then scolorVar = nil; end
			return { 
				feature = "txt_static"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				font = fontsel:GetSelectedFont();
				txt =  txt.editBox:GetText();
				color = scolorVar;
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "txt_static", version = 1,
			name = "staticText", w = 50, h = 14, owner = "Base",
			anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 }, 
			font = VFL.copy(Fonts.Default);
		};
	end;
});

--- Dynamic text.
RDX.RegisterFeature({
	name = "txt_dyn"; version = 1; multiple = true;
	title = i18n("Info Text"); category = i18n("Text");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		if (not desc.txt) or (not state:Slot("TextData_" .. desc.txt)) then
			VFL.AddError(errs, i18n("Invalid texte object pointer.")); return nil;
		end
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Text_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then
			state:AddSlot("Text_" .. desc.name);
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		if not VFLUI.isFacePathExist(desc.font.face) then desc.font.face = "Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf"; end
		local tname = RDXUI.ResolveTextReference(desc.name);
		local colorVar, colorBoo = strtrim(desc.color or ""), "false";
		if colorVar ~= "" then colorBoo = "true"; end
		---- Generate the code.
		local createCode = _EmitCreateFontString(desc) .. [[
txt:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
]] .. VFLUI.GenerateSetFontCode("txt", desc.font, nil, true) .. [[
txt:Show();
]] .. tname .. [[ = txt;
]];
		local destroyCode = [[
]] .. tname .. [[:Destroy();
]] .. tname .. [[ = nil;
]];
		local cleanupCode = [[
]] .. tname .. [[:SetText("");
]];
		-- Apply the static
		local paintCode = [[
]] .. tname .. [[:SetText(]] .. desc.txt .. [[);
if ]] .. colorBoo .. [[ then
	]] .. tname .. [[:SetTextColor(explodeRGBA(]] .. colorVar .. [[));
end
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local er = RDXUI.EmbedRight(ui, i18n("Font"));
		local fontsel = VFLUI.MakeFontSelectButton(er, desc.font); fontsel:Show();
		er:EmbedChild(fontsel); er:Show();
		ui:InsertFrame(er);

		local txt = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Texte"), state, "TextData_");
		if desc and desc.txt then txt:SetSelection(desc.txt); end
		
		local colorVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Color variable"), state, "ColorVar_");
		if desc and desc.color then colorVar:SetSelection(desc.color); end

		function ui:GetDescriptor()
			local scolorVar = strtrim(colorVar:GetSelection() or "");
			if scolorVar == "" then scolorVar = nil; end
			return { 
				feature = "txt_dyn"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				font = fontsel:GetSelectedFont();
				txt =  txt.editBox:GetText();
				color = scolorVar;
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "txt_dyn", version = 1,
			name = "infoText", w = 50, h = 14, owner = "Base",
			anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 }, 
			font = VFL.copy(Fonts.Default);
		};
	end;
});

-------------------- NAMEPLATE
RDX.RegisterFeature({
	name = "txt_np"; version = 1; multiple = true;
	title = i18n("Nameplate");
	category = i18n("Text");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if (not desc) then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Text_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		state:AddSlot("Text_" .. desc.name);
		return flg;
	end;
	ApplyFeature = function(desc, state)
		if not VFLUI.isFacePathExist(desc.font.face) then desc.font.face = "Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf"; end
		local tname = RDXUI.ResolveTextReference(desc.name);

		-- Text
		local textExpr;
		if desc.trunc then
			textExpr = "unit:GetProperName():sub(1, " .. desc.trunc .. ")";
		else
			textExpr = "unit:GetProperName()";
		end
		
		-- Color
		local colorclassBoo, colorVar, colorBoo = "false", strtrim(desc.color or ""), "false";
		if desc.classColor then colorclassBoo = "true"; end
		if colorVar ~= "" then colorBoo = "true"; end

		local createCode = _EmitCreateFontString(desc) .. [[
txt:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
]] .. VFLUI.GenerateSetFontCode("txt", desc.font, nil, true) .. [[
txt:Show();
]] .. tname .. [[ = txt;
]];

		local destroyCode = [[
]] .. tname .. [[:Destroy();
]] .. tname .. [[ = nil;
]];

		local cleanupCode = [[
]] .. tname .. [[:SetText("");
]] .. tname .. [[:SetTextColor(1,1,1,1);
]];

		local paintCode = [[
if UnitExists(uid) then
	]] .. tname .. [[:SetText(]] .. textExpr .. [[);
else
	]] .. tname .. [[:SetText("");
end
if ]] .. colorclassBoo .. [[ then
	]] .. tname .. [[:SetTextColor(explodeColor(unit:GetClassColor()));
end

if ]] .. colorBoo .. [[ then
	]] .. tname .. [[:SetTextColor(explodeRGBA(]] .. colorVar .. [[));
end

]];

		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local er = RDXUI.EmbedRight(ui, i18n("Font"));
		local fontsel = VFLUI.MakeFontSelectButton(er, desc.font); fontsel:Show();
		er:EmbedChild(fontsel); er:Show();
		ui:InsertFrame(er);

		local ed_trunc = VFLUI.LabeledEdit:new(ui, 50); ed_trunc:Show();
		ed_trunc:SetText(i18n("Max name length (blank = no truncation)"));
		if desc and desc.trunc then ed_trunc.editBox:SetText(desc.trunc); end
		ui:InsertFrame(ed_trunc);

		local chk_colorclass = VFLUI.Checkbox:new(ui); chk_colorclass:Show();
		chk_colorclass:SetText(i18n("Use class color"));
		if desc and desc.classColor then chk_colorclass:SetChecked(true); else chk_colorclass:SetChecked(); end
		ui:InsertFrame(chk_colorclass);
		
		local colorVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Color variable"), state, "ColorVar_");
		if desc and desc.color then colorVar:SetSelection(desc.color); end

		function ui:GetDescriptor()
			local trunc = tonumber(ed_trunc.editBox:GetText());
			if trunc then trunc = VFL.clamp(trunc, 1, 50); end
			local scolorVar = strtrim(colorVar:GetSelection() or "");
			if scolorVar == "" then
				scolorVar = nil;
			end
			return { 
				feature = "txt_np"; version = 1;
				trunc = trunc;
				classColor = chk_colorclass:GetChecked();
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				font = fontsel:GetSelectedFont();
				color = scolorVar;
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "txt_np"; version = 1;
			name = "np", w = 50, h = 14, owner = "Base",
			anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 };
			font = VFL.copy(Fonts.Default); 
		};
	end;
});

------------------------------------------------
-- COMPATIBILITY: Port old text features over
------------------------------------------------
_GenerateReplaceTextFeature(i18n("Custom Text"), "txt_custom", 1);
_GenerateReplaceTextFeature(i18n("Nameplate"), "txt_np", 1);

