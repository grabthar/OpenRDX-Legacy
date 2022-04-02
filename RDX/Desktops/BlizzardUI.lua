-- BlizzardUI.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- OpenRDX
--
-- THIS FILE CONTAINS COPYRIGHTED CONTENT SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Stuff that doesn't have a home anywhere else.

-------------------------------------------------------------
-- Code/option to hide all the blizzard default unitframes.
-------------------------------------------------------------
local UFM_save;
local UFH_save

function RDXDK.HideBlizzardUnitframes()
	-- Hide player frame
	PlayerFrame:UnregisterAllEvents();
	PlayerFrameHealthBar:UnregisterAllEvents();
	PlayerFrameManaBar:UnregisterAllEvents();
	PlayerFrame:Hide();
	RuneFrame:UnregisterAllEvents();
	RuneFrame:Hide();
	
	UFM_save = UnitFrameManaBar_OnUpdate;
	UnitFrameManaBar_OnUpdate = VFL.Noop;
	UFH_save = UnitFrameHealthBar_OnUpdate;
	UnitFrameHealthBar_OnUpdate = VFL.Noop;

	-- Hide target frame
	TargetFrame:UnregisterAllEvents();
	TargetFrame:Hide();
	ComboFrame:UnregisterAllEvents();
	--ComboFrame:Hide();
	
	-- Hide focus frame
	FocusFrame:UnregisterAllEvents();
	FocusFrame:Hide();

	-- Hide party frames
	for i=1,4 do
		local x = getglobal("PartyMemberFrame" .. i);
		x:UnregisterAllEvents(); 
		x:Hide();
		x.saveShow = x.Show;
		x.Show = VFL.Noop;
	end
	UIParent:UnregisterEvent("RAID_ROSTER_UPDATE");
end

function RDXDK.ShowBlizzardUnitframes()
	-- PlayerFrame
	PlayerFrame:RegisterEvent("UNIT_LEVEL");
	PlayerFrame:RegisterEvent("UNIT_COMBAT");
	PlayerFrame:RegisterEvent("UNIT_FACTION");
	PlayerFrame:RegisterEvent("UNIT_MAXMANA");
	PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	PlayerFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
	PlayerFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
	PlayerFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	PlayerFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	PlayerFrame:RegisterEvent("PLAYER_UPDATE_RESTING");
	PlayerFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	PlayerFrame:RegisterEvent("PARTY_LEADER_CHANGED");
	PlayerFrame:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
	PlayerFrame:RegisterEvent("VOICE_START");
	PlayerFrame:RegisterEvent("VOICE_STOP");
	PlayerFrame:RegisterEvent("RAID_ROSTER_UPDATE");
	PlayerFrame:RegisterEvent("READY_CHECK");
	PlayerFrame:RegisterEvent("READY_CHECK_CONFIRM");
	PlayerFrame:RegisterEvent("READY_CHECK_FINISHED");
	PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
	PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE");
	PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE");
	PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
	PlayerFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
	
	-- Chinese playtime stuff
	PlayerFrame:RegisterEvent("PLAYTIME_CHANGED");
	
	PlayerFrame:RegisterEvent("UNIT_NAME_UPDATE");
	PlayerFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	PlayerFrame:RegisterEvent("UNIT_DISPLAYPOWER");
	PlayerFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	
	if UFM_save then
		UnitFrameManaBar_OnUpdate = UFM_save;
		UFM_save = nil;
	end
	if UFH_save then
		UnitFrameHealthBar_OnUpdate = UFH_save;
		UFH_save = nil;
	end

	-- PlayerFrameHealthBar
	if not GetCVarBool("predictedHealth") then
		PlayerFrameHealthBar:RegisterEvent("UNIT_HEALTH");
	end
	PlayerFrameHealthBar:RegisterEvent("UNIT_MAXHEALTH");

	-- PlayerFrameManaBar
	if not GetCVarBool("predictedPower") then
		PlayerFrameManaBar:RegisterEvent("UNIT_MANA");
		PlayerFrameManaBar:RegisterEvent("UNIT_RAGE");
		PlayerFrameManaBar:RegisterEvent("UNIT_FOCUS");
		PlayerFrameManaBar:RegisterEvent("UNIT_ENERGY");
		PlayerFrameManaBar:RegisterEvent("UNIT_HAPPINESS");
		PlayerFrameManaBar:RegisterEvent("UNIT_RUNIC_POWER");
	end
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXMANA");
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXRAGE");
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXFOCUS");
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXENERGY");
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXHAPPINESS");
	PlayerFrameManaBar:RegisterEvent("UNIT_MAXRUNIC_POWER");
	PlayerFrameManaBar:RegisterEvent("UNIT_DISPLAYPOWER");
	
	PlayerFrame:Show();
	
	RuneFrame:RegisterEvent("RUNE_POWER_UPDATE");
	RuneFrame:RegisterEvent("RUNE_TYPE_UPDATE");
	RuneFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	-- TargetFrame
	TargetFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	TargetFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	TargetFrame:RegisterEvent("UNIT_HEALTH");
	TargetFrame:RegisterEvent("UNIT_LEVEL");
	TargetFrame:RegisterEvent("UNIT_FACTION");
	TargetFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	TargetFrame:RegisterEvent("UNIT_AURA");
	TargetFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
	TargetFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	TargetFrame:RegisterEvent("RAID_TARGET_UPDATE");
	TargetFrame_Update(TargetFrame);
	
	-- ComboFrame
	ComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	ComboFrame:RegisterEvent("UNIT_COMBO_POINTS");
	
	-- FocusFrame
	FocusFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
	FocusFrame:RegisterEvent("UNIT_HEALTH");
	FocusFrame:RegisterEvent("UNIT_LEVEL");
	FocusFrame:RegisterEvent("UNIT_FACTION");
	FocusFrame:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");
	FocusFrame:RegisterEvent("UNIT_AURA");
	FocusFrame:RegisterEvent("PLAYER_FLAGS_CHANGED");
	FocusFrame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	FocusFrame:RegisterEvent("RAID_TARGET_UPDATE");
	FocusFrame_Update(FocusFrame);
	
	for i =1,4 do
		local x = getglobal("PartyMemberFrame" .. i);
		x.Show = x.saveShow;
		x.saveShow = VFL.Noop;
		x:RegisterEvent("PARTY_MEMBERS_CHANGED")
		x:RegisterEvent("PARTY_LEADER_CHANGED")
		x:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");
		x:RegisterEvent("MUTELIST_UPDATE");
		x:RegisterEvent("IGNORELIST_UPDATE");
		x:RegisterEvent("UNIT_FACTION");
		x:RegisterEvent("UNIT_AURA");
		x:RegisterEvent("UNIT_PET");
		x:RegisterEvent("VOICE_START");
		x:RegisterEvent("VOICE_STOP");
		x:RegisterEvent("VARIABLES_LOADED");
		x:RegisterEvent("VOICE_STATUS_UPDATE");
		x:RegisterEvent("READY_CHECK");
		x:RegisterEvent("READY_CHECK_CONFIRM");
		x:RegisterEvent("READY_CHECK_FINISHED");
		x:RegisterEvent("UNIT_ENTERED_VEHICLE");
		x:RegisterEvent("UNIT_EXITED_VEHICLE");
		x:RegisterEvent("UNIT_HEALTH");
		--UnitFrame_OnEvent("PARTY_MEMBERS_CHANGED")
		
		PartyMemberFrame_UpdateMember(x)
	end
	
	UIParent:RegisterEvent("RAID_ROSTER_UPDATE")
end

------------------------------------------------------------
-- Code/option to hide the blizzard auraframes
------------------------------------------------------------

function RDXDK.HideBlizzardAuraFrame()
	BuffFrame:Hide();
	TemporaryEnchantFrame:Hide();
	BuffFrame:UnregisterAllEvents();
end

function RDXDK.ShowBlizzardAuraFrame()
	BuffFrame:Show();
	TemporaryEnchantFrame:Show();
	BuffFrame:RegisterEvent("UNIT_AURA");
	BuffFrame_Update();
end

---------------------------------------------
-- Code/option to hide the blizzard castbar
---------------------------------------------
function RDXDK.HideBlizzardCastBar()
	CastingBarFrame:UnregisterAllEvents();
	PetCastingBarFrame:UnregisterAllEvents();
end

function RDXDK.ShowBlizzardCastBar()
	for _, x in ipairs { CastingBarFrame, PetCastingBarFrame } do
		x:RegisterEvent("UNIT_SPELLCAST_START");
		x:RegisterEvent("UNIT_SPELLCAST_STOP");
		x:RegisterEvent("UNIT_SPELLCAST_FAILED");
		x:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		x:RegisterEvent("UNIT_SPELLCAST_DELAYED");
		x:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
		x:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
		x:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
	end

	PetCastingBarFrame:RegisterEvent("UNIT_PET")
end

---------------------------------------------
-- Code/option to hide the blizzard minimap
---------------------------------------------
function RDXDK.HideBlizzardMinimap()
	MinimapCluster:UnregisterAllEvents();
	MinimapCluster:Hide();
end

function RDXDK.ShowBlizzardMinimap()
	MinimapCluster:RegisterEvent("ZONE_CHANGED");
	MinimapCluster:RegisterEvent("ZONE_CHANGED_INDOORS");
	MinimapCluster:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	MinimapCluster:Show();
	Minimap_Update();
end

-----------------------------------------------
-- Code/option to hide the blizzard mainframe
-----------------------------------------------

local mb_save = nil;

function RDXDK.HideBlizzardMainFrame()
	
	MainMenuBarArtFrame:UnregisterEvent("BAG_UPDATE");
	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");
	--MainMenuBarArtFrame:UnregisterEvent('KNOWN_CURRENCY_TYPES_UPDATE');
	--MainMenuBarArtFrame:UnregisterEvent('CURRENCY_DISPLAY_UPDATE');
	MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERING_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITING_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITED_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	
	MainMenuExpBar:UnregisterEvent("CVAR_UPDATE");
	MainMenuExpBar:UnregisterEvent("PLAYER_XP_UPDATE");
	
	MainMenuBar:Hide();
	
	MultiBarLeft:Hide();
	MultiBarRight:Hide();
	MultiBarBottomLeft:Hide();
	MultiBarBottomRight:Hide();
	mb_save = MultiActionBar_Update;
	MultiActionBar_Update = VFL.Noop;
	
	--VehicleMenuBarArtFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE");
	--VehicleMenuBarArtFrame:UnregisterEvent("UNIT_DISPLAYPOWER");
	--VehicleMenuBarArtFrame:Hide();
	
	--self:RegisterEvent("PLAYER_ENTERING_WORLD");
	--self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	--self:RegisterEvent("UPDATE_SHAPESHIFT_USABLE");
	--self:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
	--self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	--self:RegisterEvent("UPDATE_INVENTORY_ALERTS");	-- Wha?? Still Wha...
	--self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");

	---BonusActionBarFrame:UnregisterAllEvents();
	--self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	--self:RegisterEvent("ACTIONBAR_SHOWGRID");
	--self:RegisterEvent("ACTIONBAR_HIDEGRID");

	---PossessBarFrame:UnregisterAllEvents();
	--self:RegisterEvent("PLAYER_ENTERING_WORLD");
	--self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	--self:RegisterEvent("UNIT_AURA");
	--self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	
	--PossessBar_Update(false);
	
end

function RDXDK.ShowBlizzardMainFrame()

	MultiActionBar_Update = mb_save;
	MultiActionBar_Update();
	
	MainMenuBar:Show();
	
	MainMenuBarArtFrame:RegisterEvent("BAG_UPDATE");
	MainMenuBarArtFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	--MainMenuBarArtFrame:RegisterEvent('KNOWN_CURRENCY_TYPES_UPDATE');
	--MainMenuBarArtFrame:RegisterEvent('CURRENCY_DISPLAY_UPDATE');
	MainMenuBarArtFrame:RegisterEvent('UNIT_ENTERING_VEHICLE');
	MainMenuBarArtFrame:RegisterEvent('UNIT_ENTERED_VEHICLE');
	MainMenuBarArtFrame:RegisterEvent('UNIT_EXITING_VEHICLE');
	MainMenuBarArtFrame:RegisterEvent('PLAYER_ENTERING_WORLD');
	
	MainMenuExpBar:RegisterEvent("CVAR_UPDATE");
	MainMenuExpBar:RegisterEvent("PLAYER_XP_UPDATE");
	
	---ShapeshiftBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	---ShapeshiftBarFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS");
	---ShapeshiftBarFrame:RegisterEvent("UPDATE_SHAPESHIFT_USABLE");
	---ShapeshiftBarFrame:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
	---ShapeshiftBarFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	---ShapeshiftBarFrame:RegisterEvent("UPDATE_INVENTORY_ALERTS");	-- Wha?? Still Wha...
	---ShapeshiftBarFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	
	---BonusActionBarFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	---BonusActionBarFrame:RegisterEvent("ACTIONBAR_SHOWGRID");
	---BonusActionBarFrame:RegisterEvent("ACTIONBAR_HIDEGRID");
	
	---PossessBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	---PossessBarFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	---PossessBarFrame:RegisterEvent("UNIT_AURA");
	---PossessBarFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
end

-------------------------------------------------------
-- Code/option to set a higher strata to the chatframe
-------------------------------------------------------

function RDXDK.SetHighStrataChatFrame()
	if ChatFrameMenuButton then ChatFrameMenuButton:SetFrameStrata("HIGH"); end
	if ChatFrame1 then ChatFrame1:SetFrameStrata("HIGH"); end
	if ChatFrame1Tab then ChatFrame1Tab:SetFrameStrata("HIGH"); end
	if ChatFrame2 then ChatFrame2:SetFrameStrata("HIGH"); end
	if ChatFrame2Tab then ChatFrame2Tab:SetFrameStrata("HIGH"); end
	if ChatFrame3 then ChatFrame3:SetFrameStrata("HIGH"); end
	if ChatFrame3Tab then ChatFrame3Tab:SetFrameStrata("HIGH"); end
end

function RDXDK.SetBCKStrataChatFrame()
	if ChatFrameMenuButton then ChatFrameMenuButton:SetFrameStrata("BACKGROUND"); end
	if ChatFrame1 then ChatFrame1:SetFrameStrata("BACKGROUND"); end
	if ChatFrame1Tab then ChatFrame1Tab:SetFrameStrata("BACKGROUND"); end
	if ChatFrame2 then ChatFrame2:SetFrameStrata("BACKGROUND"); end
	if ChatFrame2Tab then ChatFrame2Tab:SetFrameStrata("BACKGROUND"); end
	if ChatFrame3 then ChatFrame3:SetFrameStrata("BACKGROUND"); end
	if ChatFrame3Tab then ChatFrame3Tab:SetFrameStrata("BACKGROUND"); end
end

------------------------------------------------------
-- Manager
------------------------------------------------------
-- deprecated

local dlg = nil;
function RDXDK.BlizzardManage()
	if dlg then return; end
	
	dlg = VFLUI.Window:new(UIParent);
	dlg:SetFrameStrata("FULLSCREEN");
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetBackdrop(VFLUI.DefaultDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(230); dlg:SetHeight(165);
	dlg:SetTitleColor(0,.6,0);
	dlg:SetText("Show/Hide Blizzard UI Element");
	
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	if RDXPM.Ismanaged("blizzard_desktop") then RDXPM.RestoreLayout(dlg, "blizzard_desktop"); end
	
	local txt_BUF = VFLUI.CreateFontString(dlg);
	txt_BUF:SetFontObject(Fonts.Default10);
	txt_BUF:SetJustifyH("CENTER");
	txt_BUF:SetJustifyV("CENTER");
	txt_BUF:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	txt_BUF:SetHeight(18); txt_BUF:SetWidth(150);
	txt_BUF:SetText("Hide UnitFrames");
	txt_BUF:Show();
	
	local chk_BUF = VFLUI.Checkbox:new(dlg);
	chk_BUF:SetPoint("LEFT", txt_BUF, "RIGHT");
	chk_BUF:SetHeight(16); chk_BUF:SetWidth(16);
	if RDXU.BlizzUI["noBUF"] then chk_BUF:SetChecked(true); else chk_BUF:SetChecked(); end
	chk_BUF:Show();
	
	local txt_BAF = VFLUI.CreateFontString(dlg);
	txt_BAF:SetFontObject(Fonts.Default10);
	txt_BAF:SetJustifyH("CENTER");
	txt_BAF:SetJustifyV("CENTER");
	txt_BAF:SetPoint("TOPLEFT", txt_BUF, "BOTTOMLEFT");
	txt_BAF:SetHeight(18); txt_BAF:SetWidth(150);
	txt_BAF:SetText("Hide AuraFrames");
	txt_BAF:Show();
	
	local chk_BAF = VFLUI.Checkbox:new(dlg);
	chk_BAF:SetPoint("LEFT", txt_BAF, "RIGHT");
	chk_BAF:SetHeight(16); chk_BAF:SetWidth(16);
	if RDXU.BlizzUI["noBAF"] then chk_BAF:SetChecked(true); else chk_BAF:SetChecked(); end
	chk_BAF:Show();
	
	local txt_BCB = VFLUI.CreateFontString(dlg);
	txt_BCB:SetFontObject(Fonts.Default10);
	txt_BCB:SetJustifyH("CENTER");
	txt_BCB:SetJustifyV("CENTER");
	txt_BCB:SetPoint("TOPLEFT", txt_BAF, "BOTTOMLEFT");
	txt_BCB:SetHeight(18); txt_BCB:SetWidth(150);
	txt_BCB:SetText("Hide CastBar");
	txt_BCB:Show();
	
	local chk_BCB = VFLUI.Checkbox:new(dlg);
	chk_BCB:SetPoint("LEFT", txt_BCB, "RIGHT");
	chk_BCB:SetHeight(16); chk_BCB:SetWidth(16);
	if RDXU.BlizzUI["noBCB"] then chk_BCB:SetChecked(true); else chk_BCB:SetChecked(); end
	chk_BCB:Show();
	
	local txt_MAP = VFLUI.CreateFontString(dlg);
	txt_MAP:SetFontObject(Fonts.Default10);
	txt_MAP:SetJustifyH("CENTER");
	txt_MAP:SetJustifyV("CENTER");
	txt_MAP:SetPoint("TOPLEFT", txt_BCB, "BOTTOMLEFT");
	txt_MAP:SetHeight(18); txt_MAP:SetWidth(150);
	txt_MAP:SetText("Hide Minimap");
	txt_MAP:Show();
	
	local chk_MAP = VFLUI.Checkbox:new(dlg);
	chk_MAP:SetPoint("LEFT", txt_MAP, "RIGHT");
	chk_MAP:SetHeight(16); chk_MAP:SetWidth(16);
	if RDXU.BlizzUI["noMAP"] then chk_MAP:SetChecked(true); else chk_MAP:SetChecked(); end
	chk_MAP:Show();
	
	local txt_BMF = VFLUI.CreateFontString(dlg);
	txt_BMF:SetFontObject(Fonts.Default10);
	txt_BMF:SetJustifyH("CENTER");
	txt_BMF:SetJustifyV("CENTER");
	txt_BMF:SetPoint("TOPLEFT", txt_MAP, "BOTTOMLEFT");
	txt_BMF:SetHeight(18); txt_BMF:SetWidth(150);
	txt_BMF:SetText("Hide MainFrame");
	txt_BMF:Show();
	
	local chk_BMF = VFLUI.Checkbox:new(dlg);
	chk_BMF:SetPoint("LEFT", txt_BMF, "RIGHT");
	chk_BMF:SetHeight(16); chk_BMF:SetWidth(16);
	if RDXU.BlizzUI["noBMF"] then chk_BMF:SetChecked(true); else chk_BMF:SetChecked(); end
	chk_BMF:Show();
	
	local txt_HCF = VFLUI.CreateFontString(dlg);
	txt_HCF:SetFontObject(Fonts.Default10);
	txt_HCF:SetJustifyH("CENTER");
	txt_HCF:SetJustifyV("CENTER");
	txt_HCF:SetPoint("TOPLEFT", txt_BMF, "BOTTOMLEFT");
	txt_HCF:SetHeight(18); txt_HCF:SetWidth(150);
	txt_HCF:SetText("Level up ChatFrame STRATA");
	txt_HCF:Show();
	
	local chk_HCF = VFLUI.Checkbox:new(dlg);
	chk_HCF:SetPoint("LEFT", txt_HCF, "RIGHT");
	chk_HCF:SetHeight(16); chk_HCF:SetWidth(16);
	if RDXU.BlizzUI["HCF"] then chk_HCF:SetChecked(true); else chk_HCF:SetChecked(); end
	chk_HCF:Show();
	
	local txt_Button = VFLUI.CreateFontString(dlg);
	txt_Button:SetFontObject(Fonts.Default10);
	txt_Button:SetJustifyH("RIGHT");
	txt_Button:SetJustifyV("CENTER");
	txt_Button:SetPoint("TOPLEFT", txt_HCF, "BOTTOMLEFT");
	txt_Button:SetHeight(18); txt_Button:SetWidth(150);
	txt_Button:SetText("OK will Reload your UI");
	txt_Button:Show();
	
	dlg:Show(.2, true);
	
	local esch = function()
		dlg:Hide(.2, true);
		VFL.ZMSchedule(.25, function()
			RDXPM.StoreLayout(dlg, "blizzard_desktop");
			dlg:Destroy(); dlg = nil;
		end);
	end
	VFL.AddEscapeHandler(esch);
	
	local btnClose = VFLUI.CloseButton:new(dlg);
	dlg:AddButton(btnClose);
	btnClose:SetScript("OnClick", function() VFL.EscapeTo(esch); end);
	
	-- OK
	local btnOK = VFLUI.OKButton:new(dlg);
	btnOK:SetHeight(25); btnOK:SetWidth(60);
	btnOK:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
	btnOK:SetText("OK"); btnOK:Show();
	btnOK:SetScript("OnClick", function()
		RDXU.BlizzUI["noBAF"] = chk_BAF:GetChecked();
		RDXU.BlizzUI["noBCB"] = chk_BCB:GetChecked();
		RDXU.BlizzUI["noBUF"] = chk_BUF:GetChecked();
		RDXU.BlizzUI["noMAP"] = chk_MAP:GetChecked();
		RDXU.BlizzUI["noBMF"] = chk_BMF:GetChecked();
		RDXU.BlizzUI["HCF"] = chk_HCF:GetChecked();
		-- Reload UI
		ReloadUI();
		VFL.EscapeTo(esch);
	end);

	-- Destructor
	dlg.Destroy = VFL.hook(function(s)
		VFLUI.ReleaseRegion(txt_BUF); txt_BUF = nil;
		chk_BUF:Destroy(); chk_BUF = nil;
		VFLUI.ReleaseRegion(txt_BAF); txt_BAF = nil;
		chk_BAF:Destroy(); chk_BAF = nil;
		VFLUI.ReleaseRegion(txt_BCB); txt_BCB = nil;
		chk_BCB:Destroy(); chk_BCB = nil;
		VFLUI.ReleaseRegion(txt_MAP); txt_MAP = nil;
		chk_MAP:Destroy(); chk_MAP = nil;
		VFLUI.ReleaseRegion(txt_BMF); txt_BMF = nil;
		chk_BMF:Destroy(); chk_BMF = nil;
		VFLUI.ReleaseRegion(txt_HCF); txt_HCF = nil;
		chk_HCF:Destroy(); chk_HCF = nil;
		VFLUI.ReleaseRegion(txt_Button); txt_Button = nil;
		btnOK:Destroy(); btnOK = nil;
	end, dlg.Destroy);
end

----------------------------
-- INIT
----------------------------

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	--if not RDXU.BlizzUI then RDXU.BlizzUI = {}; end
	--if RDXU.BlizzUI["noBAF"] then HideBlizzardAuraFrame(); end
	--if RDXU.BlizzUI["noBCB"] then HideBlizzardCastBar(); end
	--if RDXU.BlizzUI["noBUF"] then HideBlizzardUnitframes(); end
	--if RDXU.BlizzUI["noMAP"] then HideBlizzardMinimap(); end
	--if RDXU.BlizzUI["noBMF"] then HideBlizzardMainFrame(); end
	--if RDXU.BlizzUI["HCF"] then SetHighStrataChatFrame(); end
	
	RaidOptionsFrame_UpdatePartyFrames = VFL.Noop;
	
	-- debug event
	--local frame = CreateFrame('Frame')
	--frame:RegisterAllEvents()
	--frame:SetScript('OnEvent', function(self, event, ...) VFL.print("event " .. event); end )

end);



