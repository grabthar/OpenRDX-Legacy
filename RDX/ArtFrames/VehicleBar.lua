-- VehicleBar.lua
-- OpenRDX
-- Sigg Rashgarroth EU

local function _EmitCreateCode(objname, desc)
	local createCode = [[
local btnOwner = ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;

local h = VFLUI.AcquireFrame("Frame");
VFLUI.StdSetParent(h, btnOwner);
h:SetFrameLevel(btnOwner:GetFrameLevel());
RegisterStateDriver(h, "visibility", "[target=vehicle,exists]show;hide");

-- skin
local ffu = _G['VehicleMenuBarPitchUpButton'];
ffu:GetNormalTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Pitch-Up");
ffu:GetNormalTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125);
ffu:GetPushedTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Pitch-Down");
ffu:GetPushedTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125);
--ffu:Show();

local ffd = _G['VehicleMenuBarPitchDownButton'];
ffd:GetNormalTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-PitchDown-Up");
ffd:GetNormalTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125);
ffd:GetPushedTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-PitchDown-Down");
ffd:GetPushedTexture():SetTexCoord(0.21875, 0.765625, 0.234375, 0.78125);
--ffd:Show();

local ffl = _G['VehicleMenuBarLeaveButton'];
ffl:GetNormalTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up");
ffl:GetNormalTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375);
ffl:GetPushedTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down");
ffl:GetPushedTexture():SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375);
--ffl:Show();

h.OnEvent = function()
	if arg1 == "player" then
		if IsVehicleAimAngleAdjustable() then
			_G['VehicleMenuBarPitchUpButton']:Show()
			_G['VehicleMenuBarPitchDownButton']:Show()
		else
			_G['VehicleMenuBarPitchUpButton']:Hide()
			_G['VehicleMenuBarPitchDownButton']:Hide()
		end
	
		if CanExitVehicle() then
			_G['VehicleMenuBarLeaveButton']:Show()
		else
			_G['VehicleMenuBarLeaveButton']:Hide()
		end
	end
end
WoWEvents:Bind("UNIT_ENTERED_VEHICLE", nil, h.OnEvent, "VehicleBar");
h:Show();

local vehiclebar = RDXUI.AcquireVehiclebar();
if vehiclebar then
	for i=1, #vehiclebar do
		VFLUI.StdSetParent(vehiclebar[i], h);
		vehiclebar[i]:SetFrameLevel(h:GetFrameLevel());
		vehiclebar[i]:Show();
	end
	vehiclebar[1]:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
	for i=2, #vehiclebar do ]];
		local opri1, opri2, osec1, osec2, csx, csy, csxm, csym = '"RIGHT"', '"LEFT"', '"TOP"', '"BOTTOM"', -tonumber(desc.iconspx), 0, 0, -tonumber(desc.iconspy);
		if desc.orientation == "RIGHT" then
			opri1 = '"LEFT"'; opri2 = '"RIGHT"'; csx = tonumber(desc.iconspx); csy = 0;
		elseif desc.orientation == "DOWN" then
			opri1 = '"TOP"'; opri2 = '"BOTTOM"'; osec1 = '"LEFT"'; osec2 = '"RIGHT"'; csx = 0; csy = -tonumber(desc.iconspy); csxm = tonumber(desc.iconspx); csym = 0;
		elseif desc.orientation == "UP" then
			opri1 = '"BOTTOM"'; opri2 = '"TOP"'; osec1 = '"LEFT"'; osec2 = '"RIGHT"'; csx = 0; csy = tonumber(desc.iconspy); csxm = tonumber(desc.iconspx); csym = 0;
		end
		createCode = createCode .. [[vehiclebar[i]:SetPoint(]] .. opri1 .. [[, vehiclebar[i-1], ]] .. opri2 .. [[, ]] .. csx .. [[, ]] .. csy .. [[);]];
		createCode = createCode .. [[
	end
	frame.vehiclebar = vehiclebar;
	frame.headervehiclebar = h;
end
]];
	return createCode;
end

-------------------------------------
-- Bags bar
-------------------------------------

RDX.RegisterFeature({
	name = "vehiclebarold"; invisible = true; version = 1; title = i18n("Vehicle Bar"); category = i18n("Bars");
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

		------------------ On frame creation

		local createCode = _EmitCreateCode(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);
		
		------------------ On frame destruction.
		local destroyCode = [[
local vehiclebar = frame.vehiclebar;
if vehiclebar then RDXUI.ReleaseVehiclebar(vehiclebar); end
frame.vehiclebar = nil;
WoWEvents:Unbind("VehicleBar");
UnregisterStateDriver(frame.headervehiclebar, "visibility", "show");
frame.headervehiclebar:Hide();
frame.headervehiclebar:Destroy();
frame.headervehiclebar = nil;

]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		------------- Layout
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout")));
		
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local er = RDXUI.EmbedRight(ui, i18n("Orientation:"));
		local dd_orientation = VFLUI.Dropdown:new(er, RDXUI.OrientationDropdownFunction);
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
		
		function ui:GetDescriptor()
			return { 
				feature = "vehiclebarold"; version = 1;
				name = "vehiclebarold";
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				orientation = dd_orientation:GetSelection();
				iconspx = VFL.clamp(ed_iconspx.editBox:GetNumber(), -10, 200);
				iconspy = VFL.clamp(ed_iconspy.editBox:GetNumber(), -25, 200);
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "vehiclebarold"; version = 1; 
			name = "vehiclebar"; owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			orientation = "RIGHT"; iconspx = 2; iconspy = 0;
		};
	end;
});


-- Create function
-- doesn't work

local function _EmitCreateCode2(objname, desc, winpath)
	desc.nIcons = 3; desc.rows = 1;
	if not desc.size then desc.size = 36; end
	if not desc.ButtonSkinOffset or type(desc.ButtonSkinOffset) ~= "number" then desc.ButtonSkinOffset = 0; end
	local showkey = "nil"; if desc.showkey then showkey = "true"; end
	
	local createCode = [[
local abid = 1;
local showkey = ]] .. showkey .. [[;

local btn, btnOwner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;

local h = VFLUI.AcquireFrame("Frame");
VFLUI.StdSetParent(h, btnOwner);
h:SetFrameLevel(btnOwner:GetFrameLevel());
RegisterStateDriver(h, "visibility", "[target=vehicle,exists]show;hide");

frame.]] .. objname .. [[ = {};
local dabid = nil;

-- Create buttons
for i=1, ]] .. desc.nIcons .. [[ do
	btn = RDXUI.VehicleButton:new(h, abid, mddata_]] .. objname .. [[, ]] .. desc.ButtonSkinOffset .. [[, nil, nil, ]] .. desc.nIcons .. [[, nil, nil, nil, nil, nil);
	if btn then
		btn:SetWidth(]] .. desc.size .. [[); btn:SetHeight(]] .. desc.size .. [[);
		btn:Show();
]];
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.txtHotkey", desc.fontkey, nil, true);
		createCode = createCode .. [[
		if btn.Init then btn:Init(); end
		frame.]] .. objname .. [[[i] = btn;
		abid = abid + 1;
	else
		dabid = abid;
	end
end

h:Show();
frame.]] .. objname .. [[header = h;

]];
	createCode = createCode .. RDXUI.LayoutCodeMultiRows(objname, desc);
	createCode = createCode .. [[
if dabid then
	RDX.printE("Vehicle Buttons already used, See window ]] .. winpath ..[[");
end
]];
	return createCode;
end

RDX.RegisterFeature({
	name = "vehiclebar"; version = 1; title = i18n("Vehicle Bar"); category = i18n("Bars");
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
		if desc.fontkey and not VFLUI.isFacePathExist(desc.fontkey.face) then desc.fontkey = VFL.copy(Fonts.Default); end
		if not desc.externalButtonSkin then desc.externalButtonSkin = "Builtin:bs_default"; end
		local objname = "Bar_" .. desc.name;
		
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
		local createCode = _EmitCreateCode2(objname, desc, state:GetContainingWindowState():GetSlotValue("Path"));
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);
		
		------------------ On frame destruction.
		local destroyCode = [[
local btn = nil;
for i=1, ]] .. desc.nIcons .. [[ do
	btn = frame.]] .. objname .. [[[i]
	if btn then btn:Hide(); btn:Destroy(); btn = nil; end
end
UnregisterStateDriver(frame.]] .. objname .. [[header, "visibility", "show");
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
		local dd_orientation = VFLUI.Dropdown:new(er, RDXUI.OrientationDropdownFunction);
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
		
		-------------- END
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("End")));
		
		function ui:GetDescriptor()
			return { 
				feature = "vehiclebar"; version = 1;
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
				-- Display
				fontkey = fontkey:GetSelectedFont();
				showkey = chk_showkey:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		local fontk = VFL.copy(Fonts.Default); fontk.size = 8; fontk.justifyV = "TOP"; fontk.justifyH = "RIGHT";
		return { 
			feature = "vehiclebar";
			version = 1; 
			name = "vehiclebar", 
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			size = 36; rows = 1; orientation = "RIGHT"; iconspx = 5; iconspy = 0;
			externalButtonSkin = "Builtin:bs_default";
			ButtonSkinOffset = 0;
			fontkey = fontk;
		};
	end;
});

