-- OpenRDX
-- Sigg Rashgarroth


local function EnableFullDisableBlizzard()
	
	ActionButton_OnLoad = VFL.Noop;
	ActionButton_OnEvent = VFL.Noop;
	ActionButton_Update = VFL.Noop;
	ActionButton1:UnregisterAllEvents();
	ActionButton2:UnregisterAllEvents();
	ActionButton3:UnregisterAllEvents();
	ActionButton4:UnregisterAllEvents();
	ActionButton5:UnregisterAllEvents();
	ActionButton6:UnregisterAllEvents();
	ActionButton7:UnregisterAllEvents();
	ActionButton8:UnregisterAllEvents();
	ActionButton9:UnregisterAllEvents();
	ActionButton10:UnregisterAllEvents();
	ActionButton11:UnregisterAllEvents();
	ActionButton12:UnregisterAllEvents();
	
	BonusActionBar_OnLoad = VFL.Noop;
	BonusActionBar_OnEvent = VFL.Noop;
	BonusActionBar_OnUpdate = VFL.Noop;
	BonusActionButton1:UnregisterAllEvents();
	BonusActionButton2:UnregisterAllEvents();
	BonusActionButton3:UnregisterAllEvents();
	BonusActionButton4:UnregisterAllEvents();
	BonusActionButton5:UnregisterAllEvents();
	BonusActionButton6:UnregisterAllEvents();
	BonusActionButton7:UnregisterAllEvents();
	BonusActionButton8:UnregisterAllEvents();
	BonusActionButton9:UnregisterAllEvents();
	BonusActionButton10:UnregisterAllEvents();
	BonusActionButton11:UnregisterAllEvents();
	BonusActionButton12:UnregisterAllEvents();
	BonusActionBarFrame:UnregisterAllEvents();
	BonusActionBarFrame:Hide();
	
	ShapeshiftBar_OnLoad = VFL.Noop;
	ShapeshiftBar_OnEvent = VFL.Noop;
	ShapeshiftBar_Update = VFL.Noop;
	ShapeshiftButton1:UnregisterAllEvents();
	ShapeshiftButton2:UnregisterAllEvents();
	ShapeshiftButton3:UnregisterAllEvents();
	ShapeshiftButton4:UnregisterAllEvents();
	ShapeshiftButton5:UnregisterAllEvents();
	ShapeshiftButton6:UnregisterAllEvents();
	ShapeshiftButton7:UnregisterAllEvents();
	ShapeshiftButton8:UnregisterAllEvents();
	ShapeshiftButton9:UnregisterAllEvents();
	ShapeshiftButton10:UnregisterAllEvents();
	ShapeshiftBarFrame:UnregisterAllEvents();
	ShapeshiftBarFrame:Hide();
	
	PossessBar_OnLoad = VFL.Noop;
	PossessBar_OnEvent = VFL.Noop;
	PossessBar_Update = VFL.Noop;
	PossessButton1:UnregisterAllEvents();
	PossessButton2:UnregisterAllEvents();
	PossessBarFrame:UnregisterAllEvents();
	PossessBarFrame:Hide();
	
	BuffFrame_OnLoad = VFL.Noop;
	BuffFrame_OnEvent = VFL.Noop;
	BuffFrame_OnUpdate = VFL.Noop;
	AuraButton_Update = VFL.Noop;
	AuraButton_OnUpdate = VFL.Noop;
	BuffFrame:UnregisterAllEvents();
	BuffFrame:Hide();
	
	TemporaryEnchantFrame_OnUpdate = VFL.Noop;
	TempEnchantButton_OnLoad = VFL.Noop;
	TempEnchantButton_OnUpdate = VFL.Noop;
	TempEnchant1:Hide();
	TempEnchant2:Hide();
	TemporaryEnchantFrame:UnregisterAllEvents();
	TemporaryEnchantFrame:Hide();
	
	CastingBarFrame_OnLoad = VFL.Noop;
	CastingBarFrame_OnEvent = VFL.Noop;
	CastingBarFrame_OnUpdate = VFL.Noop;
	CastingBarFrame:UnregisterAllEvents();
	CastingBarFrame:Hide();
	
	ComboFrame_OnEvent = VFL.Noop;
	ComboFrame_Update = VFL.Noop;
	ComboFrame:UnregisterAllEvents();
	ComboFrame:Hide();
	
	FocusFrame_OnLoad = VFL.Noop;
	FocusFrame_OnEvent = VFL.Noop;
	FocusFrame_Update = VFL.Noop;
	FocusFrame_OnUpdate = VFL.Noop;
	FocusFrame_HealthUpdate = VFL.Noop;
	FocusFrame:UnregisterAllEvents();
	FocusFrame:Hide();
	--FocusPortrait:UnregisterAllEvents();
	FocusFrameHealthBar:UnregisterAllEvents();
	--FocusFrameHealthBarText:UnregisterAllEvents();
	FocusFrameManaBar:UnregisterAllEvents();
	--FocusFrameManaBarText:UnregisterAllEvents();
	
	Focus_Spellbar_OnLoad = VFL.Noop;
	Focus_Spellbar_OnEvent = VFL.Noop;
	FocusFrameSpellBar:UnregisterAllEvents();
	FocusFrameSpellBar:Hide();
	
	FocusFrameDebuff1:UnregisterAllEvents();
	FocusFrameDebuff2:UnregisterAllEvents();
	FocusFrameDebuff3:UnregisterAllEvents();
	FocusFrameDebuff4:UnregisterAllEvents();
	FocusFrameDebuff5:UnregisterAllEvents();
	FocusFrameDebuff6:UnregisterAllEvents();
	FocusFrameDebuff7:UnregisterAllEvents();
	FocusFrameDebuff8:UnregisterAllEvents();
	
	FocusFrameNumericalThreat:UnregisterAllEvents();
	
	TargetofFocus_OnLoad = VFL.Noop;
	TargetofFocus_Update = VFL.Noop;
	TargetofFocusFrame:UnregisterAllEvents();
	TargetofFocusFrame:Hide();
	TargetofFocusHealthBar:UnregisterAllEvents();
	TargetofFocusManaBar:UnregisterAllEvents();
	TargetofFocusFrameDebuff1:UnregisterAllEvents();
	TargetofFocusFrameDebuff2:UnregisterAllEvents();
	TargetofFocusFrameDebuff3:UnregisterAllEvents();
	TargetofFocusFrameDebuff4:UnregisterAllEvents();
	
	MainMenuBar_OnLoad = VFL.Noop;
	MainMenuBar_OnEvent = VFL.Noop;
	--MainMenuBarArtFrame:UnregisterAllEvents();
	MainMenuBarArtFrame:UnregisterEvent("BAG_UPDATE");
	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");
	--MainMenuBarArtFrame:UnregisterEvent('KNOWN_CURRENCY_TYPES_UPDATE');
	--MainMenuBarArtFrame:UnregisterEvent('CURRENCY_DISPLAY_UPDATE');
	MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERING_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("UNIT_ENTERED_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITING_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("UNIT_EXITED_VEHICLE");
	MainMenuBarArtFrame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	MainMenuBarArtFrame:Hide();
	
	ExhaustionTick_OnLoad = VFL.Noop;
	ExhaustionTick_OnEvent = VFL.Noop;
	MainMenuExpBar_Update = VFL.Noop;
	MainMenuExpBar:UnregisterAllEvents();
	MainMenuExpBar:Hide();
	ExhaustionTick:UnregisterAllEvents();
	ExhaustionTick:Hide();
	MainMenuBar:UnregisterAllEvents();
	MainMenuBar:Hide();
	
	--MainMenuBarBagButtons todo
	--MainMenuBarMicroButtons todo
	--Minimap todo
	-- MirrorTimer todo
	
	MultiActionBar_Update = VFL.Noop;
	MultiActionBarFrame_OnLoad = VFL.Noop;
	MultiBarBottomLeft:UnregisterAllEvents();
	MultiBarBottomLeft:Hide();
	MultiBarBottomLeftButton1:UnregisterAllEvents();
	MultiBarBottomLeftButton2:UnregisterAllEvents();
	MultiBarBottomLeftButton3:UnregisterAllEvents();
	MultiBarBottomLeftButton4:UnregisterAllEvents();
	MultiBarBottomLeftButton5:UnregisterAllEvents();
	MultiBarBottomLeftButton6:UnregisterAllEvents();
	MultiBarBottomLeftButton7:UnregisterAllEvents();
	MultiBarBottomLeftButton8:UnregisterAllEvents();
	MultiBarBottomLeftButton9:UnregisterAllEvents();
	MultiBarBottomLeftButton10:UnregisterAllEvents();
	MultiBarBottomLeftButton11:UnregisterAllEvents();
	MultiBarBottomLeftButton12:UnregisterAllEvents();
	MultiBarBottomRight:UnregisterAllEvents();
	MultiBarBottomRight:Hide();
	MultiBarBottomRightButton1:UnregisterAllEvents();
	MultiBarBottomRightButton2:UnregisterAllEvents();
	MultiBarBottomRightButton3:UnregisterAllEvents();
	MultiBarBottomRightButton4:UnregisterAllEvents();
	MultiBarBottomRightButton5:UnregisterAllEvents();
	MultiBarBottomRightButton6:UnregisterAllEvents();
	MultiBarBottomRightButton7:UnregisterAllEvents();
	MultiBarBottomRightButton8:UnregisterAllEvents();
	MultiBarBottomRightButton9:UnregisterAllEvents();
	MultiBarBottomRightButton10:UnregisterAllEvents();
	MultiBarBottomRightButton11:UnregisterAllEvents();
	MultiBarBottomRightButton12:UnregisterAllEvents();
	MultiBarRight:UnregisterAllEvents();
	MultiBarRight:Hide();
	MultiBarRightButton1:UnregisterAllEvents();
	MultiBarRightButton2:UnregisterAllEvents();
	MultiBarRightButton3:UnregisterAllEvents();
	MultiBarRightButton4:UnregisterAllEvents();
	MultiBarRightButton5:UnregisterAllEvents();
	MultiBarRightButton6:UnregisterAllEvents();
	MultiBarRightButton7:UnregisterAllEvents();
	MultiBarRightButton8:UnregisterAllEvents();
	MultiBarRightButton9:UnregisterAllEvents();
	MultiBarRightButton10:UnregisterAllEvents();
	MultiBarRightButton11:UnregisterAllEvents();
	MultiBarRightButton12:UnregisterAllEvents();
	MultiBarLeft:UnregisterAllEvents();
	MultiBarLeft:Hide();
	MultiBarLeftButton1:UnregisterAllEvents();
	MultiBarLeftButton2:UnregisterAllEvents();
	MultiBarLeftButton3:UnregisterAllEvents();
	MultiBarLeftButton4:UnregisterAllEvents();
	MultiBarLeftButton5:UnregisterAllEvents();
	MultiBarLeftButton6:UnregisterAllEvents();
	MultiBarLeftButton7:UnregisterAllEvents();
	MultiBarLeftButton8:UnregisterAllEvents();
	MultiBarLeftButton9:UnregisterAllEvents();
	MultiBarLeftButton10:UnregisterAllEvents();
	MultiBarLeftButton11:UnregisterAllEvents();
	MultiBarLeftButton12:UnregisterAllEvents();
	
	PartyMemberFrame_OnLoad = VFL.Noop;
	PartyMemberFrame_OnEvent = VFL.Noop;
	PartyMemberFrame_OnUpdate = VFL.Noop;
	PartyMemberFrame_UpdateMember = VFL.Noop;
	PartyMemberFrame1:UnregisterAllEvents();
	PartyMemberFrame1:Hide();
	PartyMemberFrame2:UnregisterAllEvents();
	PartyMemberFrame2:Hide();
	PartyMemberFrame3:UnregisterAllEvents();
	PartyMemberFrame3:Hide();
	PartyMemberFrame4:UnregisterAllEvents();
	PartyMemberFrame4:Hide();
	
	PartyMemberFrame_UpdatePet = VFL.Noop;
	PartyMemberFrame1PetFrame:UnregisterAllEvents();
	PartyMemberFrame1PetFrame:Hide();
	PartyMemberFrame2PetFrame:UnregisterAllEvents();
	PartyMemberFrame2PetFrame:Hide();
	PartyMemberFrame3PetFrame:UnregisterAllEvents();
	PartyMemberFrame3PetFrame:Hide();
	PartyMemberFrame4PetFrame:UnregisterAllEvents();
	PartyMemberFrame4PetFrame:Hide();
	
	PetActionButton_OnLoad = VFL.Noop;
	PetActionButton_OnEvent = VFL.Noop;
	PetActionButton1:UnregisterAllEvents();
	PetActionButton2:UnregisterAllEvents();
	PetActionButton3:UnregisterAllEvents();
	PetActionButton4:UnregisterAllEvents();
	PetActionButton5:UnregisterAllEvents();
	PetActionButton6:UnregisterAllEvents();
	PetActionButton7:UnregisterAllEvents();
	PetActionButton8:UnregisterAllEvents();
	PetActionButton9:UnregisterAllEvents();
	PetActionButton10:UnregisterAllEvents();
	PetActionBar_OnLoad = VFL.Noop;
	PetActionBar_OnEvent = VFL.Noop;
	PetActionBarFrame_OnUpdate = VFL.Noop;
	PetActionBarFrame:UnregisterAllEvents();
	PetActionBarFrame:Hide();
	
	PetFrame_OnLoad = VFL.Noop;
	PetFrame_OnEvent = VFL.Noop;
	PetFrame_OnUpdate = VFL.Noop;
	PetFrame:UnregisterAllEvents();
	PetFrame:Hide();
	PetFrameHealthBar:UnregisterAllEvents();
	PetFrameManaBar:UnregisterAllEvents();
	PetFrameHappiness:UnregisterAllEvents();
	PetCastingBarFrame_OnLoad = VFL.Noop;
	PetCastingBarFrame_OnEvent = VFL.Noop;
	PetCastingBarFrame:UnregisterAllEvents();
	PetCastingBarFrame:Hide();
	
	PlayerFrame_OnLoad = VFL.Noop;
	PlayerFrame_OnEvent = VFL.Noop;
	PlayerFrame_OnUpdate = VFL.Noop;
	PlayerFrame:UnregisterAllEvents();
	PlayerFrame:Hide();
	PlayerFrameHealthBar:UnregisterAllEvents();
	UnitFrameHealthBar_OnValueChanged = VFL.Noop;
	PlayerFrameManaBar:UnregisterAllEvents();
	
	RuneButton_OnLoad = VFL.Noop;
	RuneButton_OnUpdate = VFL.Noop;
	RuneButtonIndividual1:UnregisterAllEvents();
	RuneButtonIndividual2:UnregisterAllEvents();
	RuneButtonIndividual3:UnregisterAllEvents();
	RuneButtonIndividual4:UnregisterAllEvents();
	RuneButtonIndividual5:UnregisterAllEvents();
	RuneButtonIndividual6:UnregisterAllEvents();
	RuneFrame_OnLoad = VFL.Noop;
	RuneFrame_OnEvent = VFL.Noop;
	RuneFrame:UnregisterAllEvents();
	RuneFrame:Hide();
	
	TargetFrame_OnLoad = VFL.Noop;
	TargetFrame_OnEvent = VFL.Noop;
	TargetFrame_OnUpdate = VFL.Noop;
	TargetFrame_HealthUpdate = VFL.Noop;
	TargetFrame:UnregisterAllEvents();
	TargetFrame:Hide();
	TargetFrameHealthBar:UnregisterAllEvents();
	TargetFrameManaBar:UnregisterAllEvents();
	TargetFrameSpellBar:UnregisterAllEvents();
	
	TargetofTarget_OnLoad = VFL.Noop;
	TargetofTarget_Update = VFL.Noop;
	TargetofTargetFrame:UnregisterAllEvents();
	TargetofTargetFrame:Hide();
	TargetofTargetHealthBar:UnregisterAllEvents();
	TargetofTargetHealthCheck = VFL.Noop;
	TargetofTargetManaBar:UnregisterAllEvents();
	
	TextStatusBar_OnEvent = VFL.Noop;
	TextStatusBar_OnValueChanged = VFL.Noop;
	
	HealthBar_OnValueChanged = VFL.Noop;
	
	UnitFrame_OnEvent = VFL.Noop;
	UnitFrame_Update = VFL.Noop;
	UnitFrameHealthBar_OnEvent = VFL.Noop;
	UnitFrameHealthBar_OnUpdate = VFL.Noop;
	UnitFrameHealthBar_OnValueChanged = VFL.Noop;
	UnitFrameManaBar_OnEvent = VFL.Noop;
	UnitFrameManaBar_OnUpdate = VFL.Noop;
	UnitFrameThreatIndicator_OnEvent = VFL.Noop;
	
	VehicleMenuBar_OnLoad = VFL.Noop;
	VehicleMenuBar_OnEvent = VFL.Noop;
	VehicleMenuBarPitch_OnLoad = VFL.Noop;
	VehicleMenuBarPitch_OnEvent = VFL.Noop;
	VehicleMenuBar:UnregisterAllEvents();
	VehicleMenuBar:Hide();
	VehicleMenuBarActionButton1:UnregisterAllEvents();
	VehicleMenuBarActionButton2:UnregisterAllEvents();
	VehicleMenuBarActionButton3:UnregisterAllEvents();
	VehicleMenuBarActionButton4:UnregisterAllEvents();
	VehicleMenuBarActionButton5:UnregisterAllEvents();
	VehicleMenuBarActionButton6:UnregisterAllEvents();
	VehicleMenuBarHealthBar:UnregisterAllEvents();
	VehicleMenuBarPowerBar:UnregisterAllEvents();
	
	--VehicleSeatIndicator_OnEvent todo
	
	RDXG.IsFDB = true;
end

local function DisableFullDisableBlizzard()
	RDXG.IsFDB = false;
	ReloadUI();
end

function RDX.IsFullDisableBlizzard()
	if RDXG then 
		if type(RDXG.IsFDB) ~= "boolean" then 
			VFL.print("pas boolean");
			RDXG.IsFDB = true; 
		end
		return RDXG.IsFDB; 
	end
end
                                      
function RDX.ToggleFullDisableBlizzard()
	if not RDX.IsFullDisableBlizzard() then
		EnableFullDisableBlizzard();
		RDX.print(i18n("Full disable Blizzard"));
	else 
		DisableFullDisableBlizzard();
	end
end

RDXEvents:Bind("INIT_DESKTOP", nil, function()
	if RDX.IsFullDisableBlizzard() then
		EnableFullDisableBlizzard();
	end
end);