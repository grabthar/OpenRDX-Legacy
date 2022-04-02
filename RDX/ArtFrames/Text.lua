-- Text.lua
-- OpenRDX
-- Daniel LY
-- Sigg / Rashgarroth EU
--
-- Art frame Text

local function _EmitCreateFontString(desc)
	return [[
local txt = VFLUI.CreateFontString(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
txt:SetWidth(]] .. desc.w .. [[); txt:SetHeight(]] .. desc.h .. [[);
]];
end

--- Scripted custom text.
RDX.RegisterFeature({
	name = "txtart_custom";	version = 1;	multiple = true;
	title = i18n("Custom Text");	category = i18n("Text");
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		if not VFLUI.isFacePathExist(desc.font.face) then VFL.AddError(errs, i18n("Font path not found.")); return nil; end
		
		local md,_,_,ty = RDXDB.GetObjectData(desc.script);
		if not (md) or (ty ~= "Script") or (not md.data) or (not md.data.script) then VFL.AddError(errs, i18n("Invalid script pointer.")); return nil; end
		
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
		local objname = "Text_" .. desc.name;
		local md = RDXDB.GetObjectData(desc.script);
		
		---- Generate the code.
		local createCode = _EmitCreateFontString(desc) .. [[
txt:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
]] .. VFLUI.GenerateSetFontCode("txt", desc.font, nil, true) .. [[
txt:Show();
frame.]] .. objname .. [[ = txt;

local text = "";
local function artf_]] .. objname .. [[ ()
	]] .. md.data.script .. [[
	if text then frame.]] .. objname .. [[:SetText(text); end
end

VFL.AdaptiveSchedule("artf_]] .. objname .. [[", ]] .. desc.delay .. [[, artf_]] .. objname .. [[);
]];

		local destroyCode = [[
VFL.AdaptiveUnschedule("artf_]] .. objname .. [[");
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];

		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		
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

		--local chk_useNil = VFLUI.Checkbox:new(ui); 
		--chk_useNil:Show(); chk_useNil:SetText(i18n("Preserve existing content if text local variable is undefined"))
		--if desc and desc.useNil then chk_useNil:SetChecked(true); end
		--ui:InsertFrame(chk_useNil);
		
		local delay = VFLUI.LabeledEdit:new(ui, 50); delay:Show();
		delay:SetText(i18n("Update period"));
		if desc and desc.delay then delay.editBox:SetText(desc.delay); end
		ui:InsertFrame(delay);

		local scriptsel = RDXDB.ObjectFinder:new(ui, function(_,_,d) return d and (d.ty == "Script"); end);
		scriptsel:SetLabel(i18n("Script object")); scriptsel:Show();
		if desc and desc.script then scriptsel:SetPath(desc.script); end
		ui:InsertFrame(scriptsel);

		function ui:GetDescriptor()
			return { 
				feature = "txtart_custom"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				font = fontsel:GetSelectedFont();
				--useNil = chk_useNil:GetChecked();
				delay = delay.editBox:GetText();
				script = scriptsel:GetPath();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "txtart_custom", version = 1,
			name = "customText", w = 50, h = 14, owner = "Base",
			anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 }, 
			font = VFL.copy(Fonts.Default); delay = 0.5,
		};
	end;
});


--- Dynamic text.
RDX.RegisterFeature({
	name = "txtart_dyn"; version = 1; multiple = true; invisible = true;
	title = i18n("Info Text"); category = i18n("Text");
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		if not VFLUI.isFacePathExist(desc.font.face) then VFL.AddError(errs, i18n("Font path not found.")); return nil; end
		-- Verify our texte
		if (not desc.txt) or (not state:Slot("Txt_" .. desc.txt)) then
			VFL.AddError(errs, i18n("Invalid texte object pointer.")); return nil;
		end
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then
			state:AddSlot("Frame_" .. desc.name);
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local colorVar, colorBoo = strtrim(desc.color or ""), "false";
		if colorVar ~= "" then colorBoo = "true"; end
		---- Generate the code.
		local createCode = _EmitCreateFontString(desc) .. [[
txt:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
]] .. VFLUI.GenerateSetFontCode("txt", desc.font, nil, true) .. [[
txt:Show();
frame.]] .. objname .. [[ = txt;

local function artf_]] .. objname .. [[ ()
	frame.]] .. objname .. [[:SetText(]] .. desc.txt .. [[);
	if ]] .. colorBoo .. [[ then
		frame.]] .. objname .. [[:SetTextColor(explodeRGBA(]] .. colorVar .. [[));
	end
end

VFL.AdaptiveSchedule("artf_]] .. objname .. [[", ]] .. desc.delay .. [[, artf_]] .. objname .. [[);
]];
		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];

		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		
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

		local txt = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Texte"), state, "Txt_");
		if desc and desc.txt then txt:SetSelection(desc.txt); end
		
		local colorVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Color variable"), state, "ColorVar_");
		if desc and desc.color then colorVar:SetSelection(desc.color); end
		
		local delay = VFLUI.LabeledEdit:new(ui, 50); delay:Show();
		delay:SetText(i18n("Update period"));
		if desc and desc.delay then delay.editBox:SetText(desc.delay); end
		ui:InsertFrame(delay);

		function ui:GetDescriptor()
			local scolorVar = strtrim(colorVar:GetSelection() or "");
			if scolorVar == "" then scolorVar = nil; end
			return { 
				feature = "txtart_dyn"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				font = fontsel:GetSelectedFont();
				txt =  txt.editBox:GetText();
				color = scolorVar;
				delay = delay.editBox:GetText();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "txtart_dyn", version = 1,
			name = "infoText", w = 50, h = 14, owner = "Base",
			anchor = { lp = "LEFT", af = "Base", rp = "LEFT", dx = 0, dy = 0 }, 
			font = VFL.copy(Fonts.Default); delay = 0.5,
		};
	end;
});
