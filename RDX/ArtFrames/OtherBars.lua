-- OtherBars.lua
-- OpenRDX
-- Sigg / rashgarroth EU

----------------------------
--  Special bars
----------------------------

RDXUI.OtherBars = {};

-----------------------------
-- bagsbar -
-----------------------------

local function CreateKeyRing()
local f = CreateFrame("CheckButton", "VFLItemKeyButton", nil, "ItemButtonTemplate");
	--VFLUI._FixFontObjectNonsense(f);
	f:RegisterForClicks('anyUp');
	f:Hide();
	f:SetScript("OnClick", function()
		if CursorHasItem() then
			PutKeyInKeyRing();
		else
			ToggleKeyRing();
		end
	end)
	f:SetScript("OnReceiveDrag", function()
		if CursorHasItem() then
			PutKeyInKeyRing();
		end
	end)
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");

		local color = HIGHLIGHT_FONT_COLOR;
		GameTooltip:SetText(KEYRING, color.r, color.g, color.b);
		GameTooltip:AddLine();
	end)
	f:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)
	getglobal(f:GetName() .. "IconTexture"):SetTexture("Interface\\Icons\\Spell_Nature_MoonKey");
	return f;
end

local bagsbarflag = false;

local bagsButtons = {
	CreateKeyRing(),
	CharacterBag3Slot,
	CharacterBag2Slot,
	CharacterBag1Slot,
	CharacterBag0Slot,
	MainMenuBarBackpackButton
}

function RDXUI.AcquireBagsBar()
	local bagsBar = {};
	MainMenuBar_UpdateKeyRing = VFL.Zero;
	KeyRingButton:Hide();
	if not bagsbarflag then
		local mbt = nil;
		for i=1, #bagsButtons do
			mbt = bagsButtons[i];
			mbt:ClearAllPoints();
			bagsBar[i] = mbt;
		end
		bagsbarflag = true;
	else
		bagsBar = RDXUI.OtherBars["bagsbar"];
		RDXUI.OtherBars["bagsbar"] = nil;
	end

	return bagsBar;
end;


function RDXUI.ReleaseBagsBar(bagsBar)
	if (not bagsBar) then return; end
	for i=1, #bagsBar do
		bagsBar[i]:ClearAllPoints();
		bagsBar[i]:Hide();
	end
	RDXUI.OtherBars["bagsbar"] = bagsBar;
	bagsBar = nil;
	return true;
end;

----------------------------------------------------------------------
-- MicroMenu bar
----------------------------------------------------------------------

local menuBarflag = false;

local microButtons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	TalentMicroButton,
	AchievementMicroButton,
	QuestLogMicroButton,
	SocialsMicroButton,
	PVPMicroButton,
	LFGMicroButton,
	MainMenuMicroButton,
	HelpMicroButton
}

if UnitLevel("player") < 10 then
local microButtons = {
	CharacterMicroButton,
	SpellbookMicroButton,
	QuestLogMicroButton,
	AchievementMicroButton,
	SocialsMicroButton,
	PVPMicroButton,
	LFGMicroButton,
	MainMenuMicroButton,
	HelpMicroButton
}
end

function RDXUI.AcquireMicroMenu()
	local menuBar = {};
	if not menuBarflag then
		local mbt = nil;
		for i=1, #microButtons do
			mbt = microButtons[i];
			mbt:ClearAllPoints();
			menuBar[i] = mbt;
		end
		UpdateTalentButton();
		menuBarflag = true;
	else
		menuBar = RDXUI.OtherBars["micromenu"];
		RDXUI.OtherBars["micromenu"] = nil;
	end
	
	return menuBar;
end


function RDXUI.ReleaseMicroMenu(menuBar)
	if (not menuBar) then return; end
	for i=1, #menuBar do
		menuBar[i]:ClearAllPoints();
		menuBar[i]:Hide();
	end
	RDXUI.OtherBars["micromenu"] = menuBar;
	menuBar = nil;
	return true;
end

----------------------------------------------------------------------
-- Vehicle bar
----------------------------------------------------------------------

local vehicleBarflag = false;

local vehicleButtons = {
	VehicleMenuBarPitchUpButton, 
	VehicleMenuBarPitchDownButton,
	VehicleMenuBarLeaveButton
}

function RDXUI.AcquireVehiclebar()
	local vehicleBar = {};
	if not vehicleBarflag then
		local mbt = nil;
		for i=1, #vehicleButtons do
			mbt = vehicleButtons[i];
			mbt:ClearAllPoints();
			vehicleBar[i] = mbt;
		end
		vehicleBarflag = true;
	else
		vehicleBar = RDXUI.OtherBars["vehiclebar"];
		RDXUI.OtherBars["vehiclebar"] = nil;
	end
	
	return vehicleBar;
end


function RDXUI.ReleaseVehiclebar(vehicleBar)
	if (not vehicleBar) then return; end
	for i=1, #vehicleBar do
		vehicleBar[i]:ClearAllPoints();
		vehicleBar[i]:Hide();
	end
	RDXUI.OtherBars["vehiclebar"] = vehicleBar;
	vehicleBar = nil;
	return true;
end

