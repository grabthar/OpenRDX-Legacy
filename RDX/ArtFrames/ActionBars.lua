-- ActionBars.lua
-- OpenRDX
-- Sigg Rashgarroth EU

-- Create function

local function _EmitCreateCode(objname, desc, winpath)
	local hidebs = "nil"; if desc.hidebs then hidebs = "true"; end
	local showkey = "nil"; if desc.showkey then showkey = "true"; end
	local showtooltip = "nil"; if desc.showtooltip then showtooltip = "true"; end
	local nRows = VFL.clamp(desc.rows, 1, 40);
	local useheader = "true"; if (not desc.headerstateType) or desc.headerstateType == "None" then useheader = "nil"; end
	local headerstate = "nil";
	if desc.headerstateType == "Custom" then 
		headerstate = desc.headerstateCustom;
	else
		headerstate = __RDXGetStates(desc.headerstateType);
	end
	if desc.headerstate then headerstate = desc.headerstate; end
	
	local cdTimerType = "COOLDOWN"; if desc.cdTimerType then cdTimerType = desc.cdTimerType; end
	local cdtext, cdgfx, cdGfxReverse, cdTxtType, cdHideTxt = "false", "false", "true", "MinSec", "0"; 
	if desc.cdTimerType == "COOLDOWN" then cdtext = "false"; cdgfx = "true"; 
	elseif desc.cdTimerType == "TEXT" then cdtext = "true"; cdgfx = "false";
	elseif desc.cdTimerType == "COOLDOWN&TEXT" then cdtext = "true"; cdgfx = "true";
	end
	if desc.cdGfxReverse then cdGfxReverse = "false"; end
	if desc.cdTxtType then cdTxtType = desc.cdTxtType; end
	if desc.cdHideTxt then cdHideTxt = desc.cdHideTxt; end
	
	local createCode = [[
-- variables
local abid = ]] .. desc.abid .. [[;
local btnOwner = ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
-- Main variable frame.
frame.]] .. objname .. [[ = {};

-- parent frame
local h = nil;
if ]] .. useheader .. [[ then
	h = __RDXCreateHeaderHandlerAttribute("]] .. headerstate .. [[");
	VFLUI.StdSetParent(h, btnOwner);
	h:SetFrameLevel(btnOwner:GetFrameLevel());
else
	h = btnOwner;
end
local dabid = nil;

-- Create buttons
for i=1, ]] .. desc.nIcons .. [[ do
	local btn = RDXUI.ActionButton:new(h, abid, mddata_]] .. objname .. [[, ]] .. desc.ButtonSkinOffset .. [[, ]] .. hidebs .. [[, "]] .. headerstate .. [[", ]] .. desc.nIcons .. [[, ]] .. cdtext .. [[, ]] .. cdgfx .. [[, ]] .. cdGfxReverse .. [[, "]] .. cdTxtType .. [[", ]] .. cdHideTxt .. [[, ]] .. desc.cdoffx .. [[, ]] .. desc.cdoffy .. [[, ]] .. showkey .. [[, ]] .. showtooltip .. [[);
]];
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.txtCount", desc.fontcount, nil, true);
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.txtMacro", desc.fontmacro, nil, true);
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.txtHotkey", desc.fontkey, nil, true);
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.cd.fs", desc.cdFont, nil, true);
		createCode = createCode .. [[
	if not btn.error then
		if btn.Init then btn:Init(); end
	else
		dabid = abid;
	end
	btn:SetWidth(]] .. desc.size .. [[); btn:SetHeight(]] .. desc.size .. [[);
	btn:Show();
	frame.]] .. objname .. [[[i] = btn;
	abid = abid + 1;
end

if ]] .. useheader .. [[ then 
	frame.]] .. objname .. [[header = h;
end

]];
	createCode = createCode .. RDXUI.LayoutCodeMultiRows(objname, desc);
	createCode = createCode .. [[
if dabid then
	RDX.printE("Action Button ".. dabid .." already used, See window ]] .. winpath ..[[");
end
]];
	return createCode;
end
-- { text = "Stealth"},
local _states = {
	{ text = "None"},
	{ text = "Defaultui"},
	{ text = "Actionbar"},
	{ text = "Stance"},
	{ text = "Shift"},
	{ text = "Ctrl"},
	{ text = "Alt"},
	{ text = "Custom"},
};
local function _dd_states() return _states; end

local _orientations = {
	{ text = "RIGHT"},
	{ text = "DOWN"},
};
local function _dd_orientations() return _orientations; end

RDX.RegisterFeature({
	name = "actionbar"; version = 1; title = i18n("Action Bar"); category = i18n("Bars");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		if desc.headerstateType == "Custom" then
			local test = __RDXconvertStatesTable(desc.headerstateCustom);
			if #test == 0 then VFL.AddError(errs, i18n("Custom definition invalid")); return nil; end 
		end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		if not VFLUI.isFacePathExist(desc.fontkey.face) then desc.fontkey = VFL.copy(Fonts.Default); end
		if not VFLUI.isFacePathExist(desc.fontmacro.face) then desc.fontmacro = VFL.copy(Fonts.Default); end
		if not VFLUI.isFacePathExist(desc.fontcount.face) then desc.fontcount = VFL.copy(Fonts.Default); end
		local objname = "Bar_" .. desc.name;
		
		local useheader = "true"; if (not desc.headerstateType) or desc.headerstateType == "None" then useheader = "nil"; end
		
		--if desc.externalButtonSkin then
		--	local path = desc.externalButtonSkin; local afname = desc.name;
		--	state:GetContainingWindowState():Attach("Menu", true, function(win, mnu)
		--		table.insert(mnu, {
		--			text = i18n("Edit ButtonSkin: ") .. afname;
		--			OnClick = function()
		--				VFL.poptree:Release();
		--				RDXDB.OpenObject(path, "Edit");
		--			end;
		--		});
		--	end);
		--end
		
		------------  On frame Closure
		local closureCode = [[ 
local mddata_]] .. objname .. [[ = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);

		------------------ On frame creation
		
		local createCode = _EmitCreateCode(objname, desc, state:GetContainingWindowState():GetSlotValue("Path"));
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);
		
		------------------ On frame destruction.
		local destroyCode = [[
for i=1, ]] .. desc.nIcons .. [[ do
	local btn = frame.]] .. objname .. [[[i];
	if btn then btn:ClearAllPoints(); btn:Hide(); btn:Destroy(); btn = nil; end
end
if ]] .. useheader .. [[ then 
	frame.]] .. objname .. [[header:Destroy();
	frame.]] .. objname .. [[header = nil;
end
frame.]] .. objname .. [[ = nil;
]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		------------- Core
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Core Parameters")));

		local ed_name = VFLUI.LabeledEdit:new(ui, 100); ed_name:Show();
		ed_name:SetText(i18n("Name"));
		ed_name.editBox:SetText(desc.name);
		ui:InsertFrame(ed_name);
		
		local ed_id = VFLUI.LabeledEdit:new(ui, 50); ed_id:Show();
		ed_id:SetText(i18n("Begin Action Bar Buttons ID (1 - 120)"));
		if desc and desc.abid then ed_id.editBox:SetText(desc.abid); else ed_id.editBox:SetText("1"); end
		ui:InsertFrame(ed_id);
		
		local ed_nbar = VFLUI.LabeledEdit:new(ui, 50); ed_nbar:Show();
		ed_nbar:SetText(i18n("Max Action Bar Buttons"));
		if desc and desc.nIcons then ed_nbar.editBox:SetText(desc.nIcons); end
		ui:InsertFrame(ed_nbar);
		
		-------------- State
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("States")));
		local er = RDXUI.EmbedRight(ui, i18n("States type:"));
		local _dd_states = VFLUI.Dropdown:new(er, _dd_states);
		_dd_states:SetWidth(100); _dd_states:Show();
		if desc and desc.headerstateType then 
			_dd_states:SetSelection(desc.headerstateType); 
		else
			_dd_states:SetSelection("None");
		end
		er:EmbedChild(_dd_states); er:Show();
		ui:InsertFrame(er);
		
		local ed_custom = VFLUI.LabeledEdit:new(ui, 300); ed_custom:Show();
		ed_custom:SetText(i18n("Custom definition"));
		if desc and desc.headerstateCustom then 
			ed_custom.editBox:SetText(desc.headerstateCustom);
		else
			_dd_states:SetSelection("");
		end
		ui:InsertFrame(ed_custom);
		
		local stxt = VFLUI.SimpleText:new(ui, 1, 200); stxt:Show();
		local str = "Current State:\n";
		if desc.headerstateType ~= "Custom" then
			str = str .. __RDXGetStates(desc.headerstateType);
		else 
			str = str .. desc.headerstateCustom;
		end
		
		stxt:SetText(str);
		ui:InsertFrame(stxt);

		------------- Layout
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout")));
		
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_rows = VFLUI.LabeledEdit:new(ui, 50); ed_rows:Show();
		ed_rows:SetText(i18n("Row size"));
		if desc and desc.rows then ed_rows.editBox:SetText(desc.rows); end
		ui:InsertFrame(ed_rows);

		local er = RDXUI.EmbedRight(ui, i18n("Orientation:"));
		local dd_orientation = VFLUI.Dropdown:new(er, _dd_orientations);
		dd_orientation:SetWidth(75); dd_orientation:Show();
		if desc and desc.orientation then 
			dd_orientation:SetSelection(desc.orientation); 
		else
			dd_orientation:SetSelection("RIGHT");
		end
		er:EmbedChild(dd_orientation); er:Show();
		ui:InsertFrame(er);
		
		local ed_iconspx = VFLUI.LabeledEdit:new(ui, 50); ed_iconspx:Show();
		ed_iconspx:SetText(i18n("Action Bar Buttons spacing width"));
		if desc and desc.iconspx then ed_iconspx.editBox:SetText(desc.iconspx); else ed_iconspx.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspx);
		
		local ed_iconspy = VFLUI.LabeledEdit:new(ui, 50); ed_iconspy:Show();
		ed_iconspy:SetText(i18n("Action Bar Buttons spacing height"));
		if desc and desc.iconspy then ed_iconspy.editBox:SetText(desc.iconspy); else ed_iconspy.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspy);
		
		local ed_size = VFLUI.LabeledEdit:new(ui, 50); ed_size:Show();
		ed_size:SetText(i18n("Action Bar Buttons Size"));
		if desc and desc.size then ed_size.editBox:SetText(desc.size); end
		ui:InsertFrame(ed_size);
		
		-------------- ButtonSkin or Frame
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Button Skin")));
		
		local erbs = RDXUI.EmbedRight(ui, i18n("Button Skin :"));
		local file_extBS = RDXDB.ObjectFinder:new(erbs, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "ButtonSkin$")); end);
		file_extBS:SetWidth(200); file_extBS:Show();
		erbs:EmbedChild(file_extBS); erbs:Show();
		ui:InsertFrame(erbs);
		if desc.externalButtonSkin then file_extBS:SetPath(desc.externalButtonSkin); end
		
		local ed_bs = VFLUI.LabeledEdit:new(ui, 50); ed_bs:Show();
		ed_bs:SetText(i18n("Button Skin Size Offset :"));
		if desc and desc.ButtonSkinOffset then ed_bs.editBox:SetText(desc.ButtonSkinOffset); end
		ui:InsertFrame(ed_bs);
		
		local chk_hidebs = VFLUI.Checkbox:new(ui); chk_hidebs:Show();
		chk_hidebs:SetText(i18n("Hide empty button"));
		if desc and desc.hidebs then chk_hidebs:SetChecked(true); else chk_hidebs:SetChecked(); end
		ui:InsertFrame(chk_hidebs);
		
		-------------- COOLDOWN
		local er_cdTimerType, dd_cdTimerType, chk_cdGfxReverse, ed_cdHideTxt, er_cdFont, dd_cdFont, er_cdTxtType, dd_cdTxtType, ed_cdoffx, ed_cdoffy = RDXUI.GenCooldownPortion(ui, desc);
		
		-------------- Display
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Display")));
		
		local er_st = RDXUI.EmbedRight(ui, i18n("Font Key"));
		local fontkey = VFLUI.MakeFontSelectButton(er_st, desc.fontkey); fontkey:Show();
		er_st:EmbedChild(fontkey); er_st:Show();
		ui:InsertFrame(er_st);
		
		local chk_showkey = VFLUI.Checkbox:new(ui); chk_showkey:Show();
		chk_showkey:SetText(i18n("Show Key Binding"));
		if desc and desc.showkey then chk_showkey:SetChecked(true); else chk_showkey:SetChecked(); end
		ui:InsertFrame(chk_showkey);
		
		local er_st = RDXUI.EmbedRight(ui, i18n("Font Macro"));
		local fontmacro = VFLUI.MakeFontSelectButton(er_st, desc.fontmacro); fontmacro:Show();
		er_st:EmbedChild(fontmacro); er_st:Show();
		ui:InsertFrame(er_st);
		
		local er_st = RDXUI.EmbedRight(ui, i18n("Font Count"));
		local fontcount = VFLUI.MakeFontSelectButton(er_st, desc.fontcount); fontcount:Show();
		er_st:EmbedChild(fontcount); er_st:Show();
		ui:InsertFrame(er_st);
		
		local chk_showtooltip = VFLUI.Checkbox:new(ui); chk_showtooltip:Show();
		chk_showtooltip:SetText(i18n("Show Tooltip"));
		if desc and desc.showtooltip then chk_showtooltip:SetChecked(true); else chk_showtooltip:SetChecked(); end
		ui:InsertFrame(chk_showtooltip);
		
		-------------- END
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("End")));
		
		function ui:GetDescriptor()
			return { 
				feature = "actionbar"; version = 1;
				name = ed_name.editBox:GetText();
				abid = VFL.clamp(ed_id.editBox:GetNumber(), 1, 120);
				nIcons = VFL.clamp(ed_nbar.editBox:GetNumber(), 1, 40);
				headerstateType = _dd_states:GetSelection();
				headerstateCustom = ed_custom.editBox:GetText();
				-- layout
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				rows = VFL.clamp(ed_rows.editBox:GetNumber(), 1, 40);
				orientation = dd_orientation:GetSelection();
				iconspx = VFL.clamp(ed_iconspx.editBox:GetNumber(), -20, 200);
				iconspy = VFL.clamp(ed_iconspy.editBox:GetNumber(), -20, 200);
				size = VFL.clamp(ed_size.editBox:GetNumber(), 20, 100);
				-- Skin
				externalButtonSkin = file_extBS:GetPath();
				ButtonSkinOffset = VFL.clamp(ed_bs.editBox:GetNumber(), 0, 50);
				hidebs = chk_hidebs:GetChecked();
				-- Cooldown
				cdTimerType = dd_cdTimerType:GetSelection();
				cdGfxReverse = chk_cdGfxReverse:GetChecked();
				cdHideTxt = ed_cdHideTxt.editBox:GetText();
				cdFont = dd_cdFont:GetSelectedFont();
				cdTxtType = dd_cdTxtType:GetSelection();
				cdoffx = VFL.clamp(ed_cdoffx.editBox:GetNumber(), -50, 50);
				cdoffy = VFL.clamp(ed_cdoffy.editBox:GetNumber(), -50, 50);
				-- Display
				fontkey = fontkey:GetSelectedFont();
				showkey = chk_showkey:GetChecked();
				fontmacro = fontmacro:GetSelectedFont();
				fontcount = fontcount:GetSelectedFont();
				showtooltip = chk_showtooltip:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		local fontk = VFL.copy(Fonts.Default); fontk.size = 8; fontk.justifyV = "TOP"; fontk.justifyH = "RIGHT";
		local fontm = VFL.copy(Fonts.Default); fontm.size = 8; fontm.justifyV = "BOTTOM"; fontm.justifyH = "CENTER";
		local fontc = VFL.copy(Fonts.Default); fontc.size = 8; fontc.justifyV = "BOTTOM"; fontc.justifyH = "RIGHT";
		local fontcd = VFL.copy(Fonts.Default); fontcd.size = 8; fontcd.justifyV = "CENTER"; fontcd.justifyH = "CENTER";
		return { 
			feature = "actionbar";
			version = 1; 
			name = "barbut2", 
			abid = 1;
			headerstateType = "None";
			headerstateCustom = "";
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			nIcons = 12; size = 36; rows = 1; orientation = "RIGHT"; iconspx = 5; iconspy = 0;
			externalButtonSkin = "Builtin:bs_default";
			ButtonSkinOffset = 0;
			fontkey = fontk;
			fontmacro = fontm;
			fontcount = fontc;
			cdFont = fontcd; cdTimerType = "COOLDOWN"; cdoffx = 0; cdoffy = 0;
			showkey = true;
			showtooltip = true;
		};
	end;
});

