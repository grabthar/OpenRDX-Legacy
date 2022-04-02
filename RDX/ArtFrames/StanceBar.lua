-- ActionBars.lua
-- OpenRDX
-- Sigg Rashgarroth EU

-- Create function

local function _EmitCreateCode(objname, desc)
	desc.nIcons = GetNumShapeshiftForms();
	local hidebs = "nil"; if desc.hidebs then hidebs = "true"; end
	local showkey = "nil"; if desc.showkey then showkey = "true"; end
	local showtooltip = "nil"; if desc.showtooltip then showtooltip = "true"; end
	local nRows = VFL.clamp(desc.rows, 1, 40);
	
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
local abid = 1;
local showkey = ]] .. showkey .. [[;
local btnOwner = ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
-- Main variable frame.
frame.]] .. objname .. [[ = {};

-- parent frame
local h = VFLUI.AcquireFrame("Frame");
VFLUI.StdSetParent(h, btnOwner);
h:SetFrameLevel(btnOwner:GetFrameLevel());

local dabid = false;

-- Create buttons
for i=1, ]] .. desc.nIcons .. [[ do
	local btn = RDXUI.StanceButton:new(h, abid, mddata_]] .. objname .. [[, ]] .. desc.ButtonSkinOffset .. [[, ]] .. hidebs .. [[, statesString, ]] .. desc.nIcons .. [[, ]] .. cdtext .. [[, ]] .. cdgfx .. [[, ]] .. cdGfxReverse .. [[, "]] .. cdTxtType .. [[", ]] .. cdHideTxt .. [[, ]] .. desc.cdoffx .. [[, ]] .. desc.cdoffy .. [[, ]] .. showkey .. [[, ]] .. showtooltip .. [[);
	if btn then
]];
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.txtHotkey", desc.fontkey, nil, true);
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.cd.fs", desc.cdFont, nil, true);
		createCode = createCode .. [[
		if btn.Init then btn:Init(); end
		btn:SetWidth(]] .. desc.size .. [[); btn:SetHeight(]] .. desc.size .. [[);
		btn:Show();
		frame.]] .. objname .. [[[i] = btn;
		abid = abid + 1;
	else
		dabid = true;
	end
end

h:Show();
frame.]] .. objname .. [[header = h;

if ]] .. desc.nIcons .. [[ > 0 then
]];
	createCode = createCode .. RDXUI.LayoutCodeMultiRows(objname, desc);
	createCode = createCode .. [[
end
if dabid then
	RDX.printW("Stance Button already used, See feature ]] .. desc.name ..[[");
end
]];
	return createCode;
end

local _orientations = {
	{ text = "RIGHT"},
	{ text = "DOWN"},
};
local function _dd_orientations() return _orientations; end

RDX.RegisterFeature({
	name = "stancebar"; version = 1; title = i18n("Stance Bar"); category = i18n("Bars");
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
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
		if not VFLUI.isFacePathExist(desc.fontkey.face) then desc.fontkey = VFL.copy(Fonts.Default); end
		local objname = "Bar_" .. desc.name;
		
		if desc.externalButtonSkin then
			local path = desc.externalButtonSkin; local afname = desc.name;
			state:GetContainingWindowState():Attach("Menu", true, function(win, mnu)
				table.insert(mnu, {
					text = i18n("Edit ButtonSkin: ") .. afname;
					OnClick = function()
						VFL.poptree:Release();
						RDXDB.OpenObject(path, "Edit");
					end;
				});
			end);
		end
		
		------------  On frame Closure
		local closureCode = [[ 
local mddata_]] .. objname .. [[ = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);

		------------------ On frame creation
		local createCode = _EmitCreateCode(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);
		
		------------------ On frame destruction.
		local destroyCode = [[
local btn = nil;
for i=1, ]] .. desc.nIcons .. [[ do
	btn = frame.]] .. objname .. [[[i]
	btn:ClearAllPoints();
	if btn then btn:Hide(); btn:Destroy(); btn = nil; end
end

frame.]] .. objname .. [[header:Hide();
frame.]] .. objname .. [[header:Destroy();
frame.]] .. objname .. [[header = nil;

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
		
		local chk_showtooltip = VFLUI.Checkbox:new(ui); chk_showtooltip:Show();
		chk_showtooltip:SetText(i18n("Show Tooltip"));
		if desc and desc.showtooltip then chk_showtooltip:SetChecked(true); else chk_showtooltip:SetChecked(); end
		ui:InsertFrame(chk_showtooltip);
		
		-------------- END
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("End")));
		
		function ui:GetDescriptor()
			return { 
				feature = "stancebar"; version = 1;
				name = ed_name.editBox:GetText();
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
				showtooltip = chk_showtooltip:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		local fontk = VFL.copy(Fonts.Default); fontk.size = 8; fontk.justifyV = "TOP"; fontk.justifyH = "RIGHT";
		local fontcd = VFL.copy(Fonts.Default); fontcd.size = 8; fontcd.justifyV = "CENTER"; fontcd.justifyH = "CENTER";
		return { 
			feature = "stancebar";
			version = 1; 
			name = "stancebar", 
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			size = 36; rows = 1; orientation = "RIGHT"; iconspx = 5; iconspy = 0;
			externalButtonSkin = "Builtin:bs_default";
			ButtonSkinOffset = 0;
			fontkey = fontk;
			cdFont = fontcd; cdTimerType = "COOLDOWN"; cdoffx = 0; cdoffy = 0;
			showkey = true;
			showtooltip = true;
		};
	end;
});

