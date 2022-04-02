-- Metadata_Cooldowns.lua
--
-- Definitions for common cooldowns from WoW.

local function spellNamebyId(spellId)
	local name = GetSpellInfo(spellId)
	return name
end

Logistics.RegisterSpellBasedCooldown("manat", i18n("Mana Tap"), 30, "Interface\\Icons\\Spell_Arcane_ManaTap");

-- Druid
Logistics.RegisterSpellBasedCooldown("inn", i18n("Innervate"), 6*60, "Interface\\Icons\\Spell_Nature_Lightning");
Logistics.RegisterSpellBasedCooldown("reb", i18n("Rebirth"), 30*60, "Interface\\Icons\\Spell_Nature_Reincarnation");
Logistics.RegisterSpellBasedCooldown("chalr", i18n("Challenging Roar"), 10*60, "Interface\\Icons\\Ability_Druid_ChallangingRoar");

-- Priest
Logistics.RegisterSpellBasedCooldown("pi", i18n("Power Infusion"), 3*60, "Interface\\Icons\\Spell_Holy_PowerInfusion");
Logistics.RegisterSpellBasedCooldown("lolwell", i18n("Lightwell"), 6*60, "Interface\\Icons\\Spell_Holy_SummonLightwell");
Logistics.RegisterSpellBasedCooldown("fw", i18n("Fear Ward"), 3*60, "Interface\\Icons\\Spell_Holy_Excorcism");
Logistics.RegisterSpellBasedCooldown("sp", i18n("Pain Suppression"), 2*60, "Interface\\Icons\\Spell_Holy_PainSupression");
Logistics.RegisterSpellBasedCooldown("sf", i18n("Shadowfiend"), 5*60, "Interface\\Icons\\Spell_Shadow_Shadowfiend");

-- Warrior
Logistics.RegisterSpellBasedCooldown("chal", i18n("Challenging Shout"), 10*60, "Interface\\Icons\\Ability_BullRush");
Logistics.RegisterSpellBasedCooldown("sw", i18n("Shield Wall"), 30*60, "Interface\\Icons\\Ability_Warrior_ShieldWall");
Logistics.RegisterSpellBasedCooldown("ret", i18n("Retaliation"), 30*60, "Interface\\Icons\\Ability_Warrior_Challange");
Logistics.RegisterSpellBasedCooldown("ls", i18n("Last Stand"), 8*60, "Interface\\Icons\\Spell_Holy_AshesToAshes");
Logistics.RegisterSpellBasedCooldown("shbash", i18n("Shield Bash"), 12, "Interface\\Icons\\Ability_Warrior_ShieldBash");
Logistics.RegisterSpellBasedCooldown("pummel", i18n("Pummel"), 10);
Logistics.RegisterQuasiSpellCooldown("lgg", i18n("Lifegiving Gem"), i18n("Gift of Life"), 5*60);
Logistics.RegisterSpellBasedCooldown("int", i18n("Intervene"), 30, "Interface\\Icons\\Ability_Warrior_VictoryRush");


-- Shaman
Logistics.RegisterSpellBasedCooldown("mtt", i18n("Mana Tide Totem"), 5*60, "Interface\\Icons\\Spell_Frost_SummonWaterElemental");
Logistics.RegisterSpellBasedCooldown("ns", i18n("Nature's Swiftness"), 3*60);
Logistics.RegisterSpellBasedCooldown("hero", i18n("Heroism"), 10*60, "Interface\\Icons\\Ability_Shaman_Heroism");
Logistics.RegisterSpellBasedCooldown("bl", i18n("Bloodlust"), 10*60, "Interface\\Icons\\Spell_Nature_BloodLust");
Logistics.RegisterSpellBasedCooldown("eshock", i18n("Earth Shock"), 6, "Interface\\Icons\\Spell_Nature_EarthShock");

-- Paladin
Logistics.RegisterSpellBasedCooldown("loh", i18n("Lay on Hands"), 60*60, "Interface\\Icons\\Spell_Holy_LayOnHands");
Logistics.RegisterSpellBasedCooldown("di", i18n("Divine Intervention"), 60*60, "Interface\\Icons\\Spell_Nature_TimeStop");
Logistics.RegisterSpellBasedCooldown("bop", i18n("Blessing of Protection"), 5*60, "Interface\\Icons\\Spell_Holy_SealOfProtection");
Logistics.RegisterSpellBasedCooldown("holsh", i18n("Holy Shock"), 6*60, "Interface\\Icons\\Spell_Holy_Shock");

-- Hunter
Logistics.RegisterSpellBasedCooldown("mis", i18n("Misdirection"), 2*60, "Interface\\Icons\\Ability_Hunter_Misdirection");
--Interface\Icons\Ability_GolemStormBolt

-- Mage
Logistics.RegisterSpellBasedCooldown("cs", i18n("Counterspell"), 30, "Interface\\Icons\\Spell_Frost_IceShock");

-- Rogue
Logistics.RegisterSpellBasedCooldown("kick", i18n("Kick"), 10, "Interface\\Icons\\Ability_Kick");

-- Soulstone
Logistics.RegisterCooldown({
	name = "ss";
	title = i18n("Soulstone");
	icon = "Interface\\Icons\\Spell_Shadow_SoulGem";
	_timer = -1;
	Initialize = VFL.Noop;
	IsPossible = function()
		local c = RDXPlayer:GetClassMnemonic();
		if(c == "WARLOCK") then return true; end
	end;
	Activate = function(self)
		Logistics._RegisterForUSS(self, i18n("Soulstone Resurrection"));		
	end;
	CooldownUsed = function(self)
		self._timer = GetTime() + 1800;
	end;
	GetValue = function(self)
		if self._timer < 0 then
			return -1,1800;
		else
			return VFL.clamp(self._timer - GetTime(), 0, 1800), 1800;
		end
	end;
});

-- Reinc
Logistics.RegisterCooldown({
	name = "reinc"; title = i18n("Reincarnation");
	icon = "Interface\\Icons\\Spell_Nature_AgitatingTotem";
	_timer = -1;
	Initialize = VFL.Noop;
	IsPossible = function()
		local c = RDXPlayer:GetClassMnemonic();
		if (c == "SHAMAN") then return true; end
	end;
	Activate = function(self)
		self._rank = VFL.GetPlayerTalentRank(i18n("Improved Reincarnation"));
		hooksecurefunc("UseSoulstone", function()
			if HasSoulstone() == i18n("Reincarnation") then self:CooldownUsed();	end
		end);
	end;
	CooldownUsed = function(self)
		self._timer = GetTime() + 3600 - (10 * self._rank);
	end;
	GetValue = function(self)
		if self._timer < 0 then
			return -1, 3600 - (10 * self._rank);
		else
			return VFL.clamp(self._timer - GetTime(), 0, 3600), 3600 - (10 * self._rank);
		end
	end;
});

--------------------------
-- New system
--------------------------
RDXEvents:Bind("INIT_SPELL", nil, function()
	
	Omni.RegisterSpellClassCooldown(47585, "PRIEST", 3*60); -- dispersion
	Omni.RegisterSpellClassCooldown(47788, "PRIEST", 3*60); -- gardian spirit
	Omni.RegisterSpellClassCooldown(14751, "PRIEST", 3*60); -- innerfocus
	Omni.RegisterSpellClassCooldown(64044, "PRIEST", 2*60); -- psychic horror
	Omni.RegisterSpellClassCooldown(15487, "PRIEST", 45); -- silence
	Omni.RegisterSpellClassCooldown(10060, "PRIEST", 2*60); -- power infusion
	Omni.RegisterSpellClassCooldown(33206, "PRIEST", 3*60); -- pain suppression
	Omni.RegisterSpellClassCooldown(586, "PRIEST", 30); -- fade
	Omni.RegisterSpellClassCooldown(6346, "PRIEST", 3*60); -- fear ward
	--Omni.RegisterSpellClassCooldown(8122, "PRIEST", 8); -- psychic scream 1
	--Omni.RegisterSpellClassCooldown(8124, "PRIEST", 8); -- psychic scream 2
	--Omni.RegisterSpellClassCooldown(10888, "PRIEST", 8); -- psychic scream 3
	Omni.RegisterSpellClassCooldown(10890, "PRIEST", 8); -- psychic scream 4
	Omni.RegisterSpellClassCooldown(34433, "PRIEST", 5*60); -- shadowfiend
	--Omni.RegisterSpellClassCooldown(2944, "PRIEST", 24); -- devouring plague 1
	--Omni.RegisterSpellClassCooldown(19276, "PRIEST", 24); -- devouring plague 2
	--Omni.RegisterSpellClassCooldown(19277, "PRIEST", 24); -- devouring plague 3
	--Omni.RegisterSpellClassCooldown(19278, "PRIEST", 24); -- devouring plague 4
	--Omni.RegisterSpellClassCooldown(19279, "PRIEST", 24); -- devouring plague 5
	--Omni.RegisterSpellClassCooldown(19280, "PRIEST", 24); -- devouring plague 6
	--Omni.RegisterSpellClassCooldown(25467, "PRIEST", 24); -- devouring plague 7
	--Omni.RegisterSpellClassCooldown(48299, "PRIEST", 24); -- devouring plague 8
	Omni.RegisterSpellClassCooldown(48300, "PRIEST", 24); -- devouring plague 9
	--Omni.RegisterSpellClassCooldown(33076, "PRIEST", 10); -- prayer of mending 1
	--Omni.RegisterSpellClassCooldown(48112, "PRIEST", 10); -- prayer of mending 2
	Omni.RegisterSpellClassCooldown(48113, "PRIEST", 10); -- prayer of mending 3
	--Omni.RegisterSpellClassCooldown(48089, "PRIEST", 6); -- cercle of healing 1
	--Omni.RegisterSpellClassCooldown(34863, "PRIEST", 6); -- cercle of healing 2
	--Omni.RegisterSpellClassCooldown(34864, "PRIEST", 6); -- cercle of healing 3
	--Omni.RegisterSpellClassCooldown(34865, "PRIEST", 6); -- cercle of healing 4
	--Omni.RegisterSpellClassCooldown(34866, "PRIEST", 6); -- cercle of healing 5
	--Omni.RegisterSpellClassCooldown(48088, "PRIEST", 6); -- cercle of healing 6
	Omni.RegisterSpellClassCooldown(48089, "PRIEST", 6); -- cercle of healing 7
	--Omni.RegisterSpellClassCooldown(48173, "PRIEST", 2*60); -- desperate prayer 1
	--Omni.RegisterSpellClassCooldown(19238, "PRIEST", 2*60); -- desperate prayer 2
	--Omni.RegisterSpellClassCooldown(19240, "PRIEST", 2*60); -- desperate prayer 3
	--Omni.RegisterSpellClassCooldown(19241, "PRIEST", 2*60); -- desperate prayer 4
	--Omni.RegisterSpellClassCooldown(19242, "PRIEST", 2*60); -- desperate prayer 5
	--Omni.RegisterSpellClassCooldown(19243, "PRIEST", 2*60); -- desperate prayer 6
	--Omni.RegisterSpellClassCooldown(25437, "PRIEST", 2*60); -- desperate prayer 7
	--Omni.RegisterSpellClassCooldown(48172, "PRIEST", 2*60); -- desperate prayer 8
	Omni.RegisterSpellClassCooldown(48173, "PRIEST", 2*60); -- desperate prayer 9
	Omni.RegisterSpellClassCooldown(64843, "PRIEST", 10*60); -- hymn divin
	Omni.RegisterSpellClassCooldown(64901, "PRIEST", 6*60); -- hymn of hope
	--Omni.RegisterSpellClassCooldown(48087, "PRIEST", 3*60); -- lightwell 1
	--Omni.RegisterSpellClassCooldown(27870, "PRIEST", 3*60); -- lightwell 2
	--Omni.RegisterSpellClassCooldown(27871, "PRIEST", 3*60); -- lightwell 3
	--Omni.RegisterSpellClassCooldown(28275, "PRIEST", 3*60); -- lightwell 4
	--Omni.RegisterSpellClassCooldown(48086, "PRIEST", 3*60); -- lightwell 5
	Omni.RegisterSpellClassCooldown(48087, "PRIEST", 3*60); -- lightwell 6
	--Omni.RegisterSpellClassCooldown(53007, "PRIEST", 10); -- penance 1
	--Omni.RegisterSpellClassCooldown(53005, "PRIEST", 10); -- penance 2
	--Omni.RegisterSpellClassCooldown(53006, "PRIEST", 10); -- penance 3
	--Omni.RegisterSpellClassCooldown(53007, "PRIEST", 10); -- penance 4
	--Omni.RegisterSpellClassCooldown(32379, "PRIEST", 12); -- shadow word death 1
	--Omni.RegisterSpellClassCooldown(32996, "PRIEST", 12); -- shadow word death 2
	--Omni.RegisterSpellClassCooldown(48157, "PRIEST", 12); -- shadow word death 3
	Omni.RegisterSpellClassCooldown(48158, "PRIEST", 12); -- shadow word death 4
	
	Omni.RegisterSpellClassCooldown(33831, "DRUID", 3*60); -- force of nature
	Omni.RegisterSpellClassCooldown(50334, "DRUID", 3*60); -- berserk
	Omni.RegisterSpellClassCooldown(17116, "DRUID", 3*60); -- natures switness
	Omni.RegisterSpellClassCooldown(61336, "DRUID", 3*60); -- survival instinct
	Omni.RegisterSpellClassCooldown(18562, "DRUID", 15); -- swiftmend
	Omni.RegisterSpellClassCooldown(6795, "DRUID", 8); -- growl
	Omni.RegisterSpellClassCooldown(5229, "DRUID", 60); -- enrage
	Omni.RegisterSpellClassCooldown(16979, "DRUID", 30); -- ferral charge bear
	Omni.RegisterSpellClassCooldown(49376, "DRUID", 30); -- ferral charge cat
	Omni.RegisterSpellClassCooldown(5209, "DRUID", 3*60); -- challenging roar
	Omni.RegisterSpellClassCooldown(6798, "DRUID", 60); -- bash 
	Omni.RegisterSpellClassCooldown(22842, "DRUID", 3*60); -- frenzied
	Omni.RegisterSpellClassCooldown(29166, "DRUID", 6*60); -- innervate
	Omni.RegisterSpellClassCooldown(22812, "DRUID", 60); -- barkskin
	Omni.RegisterSpellClassCooldown(9913, "DRUID", 10); -- prowl
	Omni.RegisterSpellClassCooldown(33357, "DRUID", 3*60); -- dash
	Omni.RegisterSpellClassCooldown(49802, "DRUID", 10); -- maim 
	Omni.RegisterSpellClassCooldown(48563, "DRUID", 6); -- Mangle bear
	Omni.RegisterSpellClassCooldown(48575, "DRUID", 10); -- cower 6
	Omni.RegisterSpellClassCooldown(53312, "DRUID", 60); -- nature s grasp 8
	--Omni.RegisterSpellClassCooldown(26994, "DRUID", 20*60); -- rebirth 1
	--Omni.RegisterSpellClassCooldown(26994, "DRUID", 20*60); -- rebirth 2
	--Omni.RegisterSpellClassCooldown(26994, "DRUID", 20*60); -- rebirth 3
	--Omni.RegisterSpellClassCooldown(26994, "DRUID", 20*60); -- rebirth 4
	--Omni.RegisterSpellClassCooldown(26994, "DRUID", 20*60); -- rebirth 5
	--Omni.RegisterSpellClassCooldown(26994, "DRUID", 20*60); -- rebirth 6
	Omni.RegisterSpellClassCooldown(48477, "DRUID", 20*60); -- rebirth 7
	--Omni.RegisterSpellClassCooldown(50213, "DRUID", 30); -- tiger s fury 1
	--Omni.RegisterSpellClassCooldown(50213, "DRUID", 30); -- tiger s fury 2
	--Omni.RegisterSpellClassCooldown(50213, "DRUID", 30); -- tiger s fury 3
	--Omni.RegisterSpellClassCooldown(50213, "DRUID", 30); -- tiger s fury 4
	--Omni.RegisterSpellClassCooldown(50213, "DRUID", 30); -- tiger s fury 5
	Omni.RegisterSpellClassCooldown(50213, "DRUID", 30); -- tiger s fury 6
	--Omni.RegisterSpellClassCooldown(53201, "DRUID", 1.5*60); -- starfall 1
	--Omni.RegisterSpellClassCooldown(53201, "DRUID", 1.5*60); -- starfall 2
	--Omni.RegisterSpellClassCooldown(53201, "DRUID", 1.5*60); -- starfall 3
	Omni.RegisterSpellClassCooldown(53201, "DRUID", 1.5*60); -- starfall 4
	--Omni.RegisterSpellClassCooldown(48446, "DRUID", 10*60); -- tranquility 1
	--Omni.RegisterSpellClassCooldown(48446, "DRUID", 10*60); -- tranquility 2
	--Omni.RegisterSpellClassCooldown(48446, "DRUID", 10*60); -- tranquility 3
	--Omni.RegisterSpellClassCooldown(48446, "DRUID", 10*60); -- tranquility 4
	--Omni.RegisterSpellClassCooldown(48446, "DRUID", 10*60); -- tranquility 5
	--Omni.RegisterSpellClassCooldown(48446, "DRUID", 10*60); -- tranquility 6
	Omni.RegisterSpellClassCooldown(48447, "DRUID", 10*60); -- tranquility 7
	--Omni.RegisterSpellClassCooldown(61384, "DRUID", 20); -- typhoon 1
	--Omni.RegisterSpellClassCooldown(61384, "DRUID", 20); -- typhoon 2
	--Omni.RegisterSpellClassCooldown(61384, "DRUID", 20); -- typhoon 3
	--Omni.RegisterSpellClassCooldown(53226, "DRUID", 20); -- typhoon 4
	Omni.RegisterSpellClassCooldown(61384, "DRUID", 20); -- typhoon 5
	--Omni.RegisterSpellClassCooldown(53251, "DRUID", 6); -- wild growth 1
	--Omni.RegisterSpellClassCooldown(53251, "DRUID", 6); -- wild growth 2
	--Omni.RegisterSpellClassCooldown(53249, "DRUID", 6); -- wild growth 3
	Omni.RegisterSpellClassCooldown(53251, "DRUID", 6); -- wild growth 4
	
	Omni.RegisterSpellClassCooldown(31687, "MAGE", 3*60); -- summon water elemental
	Omni.RegisterSpellClassCooldown(12042, "MAGE", 2*60); -- arcane power
	Omni.RegisterSpellClassCooldown(11958, "MAGE", 8*60); -- cold snap
	Omni.RegisterSpellClassCooldown(11129, "MAGE", 3*60); -- combustion
	Omni.RegisterSpellClassCooldown(44572, "MAGE", 30); -- deep freeze
	Omni.RegisterSpellClassCooldown(12472, "MAGE", 3*60); -- ice veins
	Omni.RegisterSpellClassCooldown(12043, "MAGE", 2*60); -- presence of mind
	Omni.RegisterSpellClassCooldown(1953, "MAGE", 15); -- blink
	Omni.RegisterSpellClassCooldown(12051, "MAGE", 4*60); -- evocation
	Omni.RegisterSpellClassCooldown(2139, "MAGE", 24); -- Counterspell
	Omni.RegisterSpellClassCooldown(45438, "MAGE", 5*60); -- Ice Block
	Omni.RegisterSpellClassCooldown(49361, "MAGE", 60); -- portal Stonard
	Omni.RegisterSpellClassCooldown(49360, "MAGE", 60); -- portal Therarmor
	Omni.RegisterSpellClassCooldown(32266, "MAGE", 60); -- portal Exodar
	Omni.RegisterSpellClassCooldown(11416, "MAGE", 60); -- portal ironforge
	Omni.RegisterSpellClassCooldown(11417, "MAGE", 60); -- portal Orgrimmar
	Omni.RegisterSpellClassCooldown(32267, "MAGE", 60); -- portal silvermoon
	Omni.RegisterSpellClassCooldown(10059, "MAGE", 60); -- portal stormwind
	Omni.RegisterSpellClassCooldown(11418, "MAGE", 60); -- portal undercity
	Omni.RegisterSpellClassCooldown(11419, "MAGE", 60); -- portal darnassus
	Omni.RegisterSpellClassCooldown(11420, "MAGE", 60); -- portal Thunder bluff
	Omni.RegisterSpellClassCooldown(33691, "MAGE", 60); -- portal shattrah alliance
	Omni.RegisterSpellClassCooldown(35717, "MAGE", 60); -- portal shattrah horde
	Omni.RegisterSpellClassCooldown(66, "MAGE", 3*60); -- invisibility
	Omni.RegisterSpellClassCooldown(53142, "MAGE", 60); -- Portal: Dalaran
	Omni.RegisterSpellClassCooldown(42917, "MAGE", 25); -- frost nova
	Omni.RegisterSpellClassCooldown(43010, "MAGE", 30); -- fire ward
	Omni.RegisterSpellClassCooldown(42931, "MAGE", 10); -- cone of cold
	Omni.RegisterSpellClassCooldown(43012, "MAGE", 30); -- frost ward
	Omni.RegisterSpellClassCooldown(42945, "MAGE", 30); -- blast wave
	Omni.RegisterSpellClassCooldown(42950, "MAGE", 20); -- dragon's breath
	Omni.RegisterSpellClassCooldown(42873, "MAGE", 8); -- fire blast
	Omni.RegisterSpellClassCooldown(43039, "MAGE", 30); -- Ice barrier
	Omni.RegisterSpellClassCooldown(55342, "MAGE", 3*60); -- Mirror Image
	Omni.RegisterSpellClassCooldown(58659, "MAGE", 5*60); -- ritual of refreshment
	
	Omni.RegisterSpellClassCooldown(19574, "HUNTER", 2*60); -- bestial wrath
	Omni.RegisterSpellClassCooldown(53209, "HUNTER", 10); -- chimera shot
	Omni.RegisterSpellClassCooldown(19577, "HUNTER", 60); -- Intimidation
	Omni.RegisterSpellClassCooldown(19503, "HUNTER", 30); -- Scatter shot
	Omni.RegisterSpellClassCooldown(34490, "HUNTER", 20); -- silencing shot
	Omni.RegisterSpellClassCooldown(13809, "HUNTER", 30, "trap"); -- frost trap
	Omni.RegisterSpellClassCooldown(5116, "HUNTER", 12); -- concussive shot
	Omni.RegisterSpellClassCooldown(20736, "HUNTER", 8); -- distracting shot
	Omni.RegisterSpellClassCooldown(781, "HUNTER", 25); -- disengage
	Omni.RegisterSpellClassCooldown(3045, "HUNTER", 5*60); -- rapid fire
	Omni.RegisterSpellClassCooldown(5384, "HUNTER", 30); -- feign death
	Omni.RegisterSpellClassCooldown(1543, "HUNTER", 20); -- flare
	Omni.RegisterSpellClassCooldown(3034, "HUNTER", 15); -- viper sting
	Omni.RegisterSpellClassCooldown(19263, "HUNTER", 1.5*60); -- Deterrence
	Omni.RegisterSpellClassCooldown(14311, "HUNTER", 30, "trap"); -- Freezing trap
	Omni.RegisterSpellClassCooldown(19801, "HUNTER", 8); -- tranquilizing shot
	Omni.RegisterSpellClassCooldown(34026, "HUNTER", 60); -- Kill command
	Omni.RegisterSpellClassCooldown(34600, "HUNTER", 30, "trap"); -- snake trap
	Omni.RegisterSpellClassCooldown(34477, "HUNTER", 30); -- misdirection
	Omni.RegisterSpellClassCooldown(53271, "HUNTER", 60); -- Master's call
	Omni.RegisterSpellClassCooldown(49067, "HUNTER", 30, "trap"); -- explosive trap
	Omni.RegisterSpellClassCooldown(48999, "HUNTER", 5); -- counterattack
	Omni.RegisterSpellClassCooldown(49056, "HUNTER", 30, "trap"); -- immolation trap
	Omni.RegisterSpellClassCooldown(49045, "HUNTER", 6); -- arcane shot
	Omni.RegisterSpellClassCooldown(49050, "HUNTER", 10); -- aimed shot
	Omni.RegisterSpellClassCooldown(63672, "HUNTER", 30); -- black arrow
	Omni.RegisterSpellClassCooldown(62757, "HUNTER", 30*60); -- call stabled pet
	Omni.RegisterSpellClassCooldown(60053, "HUNTER", 6); -- explosive shot
	Omni.RegisterSpellClassCooldown(60192, "HUNTER", 30); -- freezing arrow
	Omni.RegisterSpellClassCooldown(61006, "HUNTER", 15); -- kill shot
	Omni.RegisterSpellClassCooldown(53339, "HUNTER", 5); -- mongoose bite
	Omni.RegisterSpellClassCooldown(49012, "HUNTER", 60); -- wyvern sting
	
	Omni.RegisterSpellClassCooldown(17962, "WARLOCK", 10); -- conflagrate
	Omni.RegisterSpellClassCooldown(47193, "WARLOCK", 60); -- demonic empowerement
	Omni.RegisterSpellClassCooldown(18708, "WARLOCK", 15*60); -- fel domination
	Omni.RegisterSpellClassCooldown(59671, "WARLOCK", 15); -- Challenging howl
	Omni.RegisterSpellClassCooldown(1122, "WARLOCK", 20*60); -- Inferno 
	Omni.RegisterSpellClassCooldown(54785, "WARLOCK", 45); -- Demon charge
	Omni.RegisterSpellClassCooldown(29858, "WARLOCK", 5*60); -- Soulshatter
	Omni.RegisterSpellClassCooldown(47860, "WARLOCK", 2*60); -- Death coil
	Omni.RegisterSpellClassCooldown(47867, "WARLOCK", 60); -- curse of doom
	Omni.RegisterSpellClassCooldown(48020, "WARLOCK", 30); -- Demonic circle teleport
	Omni.RegisterSpellClassCooldown(58887, "WARLOCK", 5*60); -- Ritual of souls
	Omni.RegisterSpellClassCooldown(47827, "WARLOCK", 15); -- shadowburn
	Omni.RegisterSpellClassCooldown(61290, "WARLOCK", 15); -- shadowflame
	Omni.RegisterSpellClassCooldown(47847, "WARLOCK", 20); -- shadowfury
	
	Omni.RegisterSpellClassCooldown(46924, "WARRIOR", 1.5*60); -- bladestorm
	Omni.RegisterSpellClassCooldown(12809, "WARRIOR", 30); -- concussion blow
	Omni.RegisterSpellClassCooldown(12292, "WARRIOR", 3*60); -- death wish
	Omni.RegisterSpellClassCooldown(60970, "WARRIOR", 45); -- heroic fury 
	Omni.RegisterSpellClassCooldown(12975, "WARRIOR", 3*60); -- last stand
	Omni.RegisterSpellClassCooldown(12328, "WARRIOR", 30); -- sweeping strike
	Omni.RegisterSpellClassCooldown(46968, "WARRIOR", 20); -- shockwave
	Omni.RegisterSpellClassCooldown(2687, "WARRIOR", 60); -- blood rage
	Omni.RegisterSpellClassCooldown(355, "WARRIOR", 8); -- taunt
	Omni.RegisterSpellClassCooldown(7384, "WARRIOR", 5); -- overpower
	Omni.RegisterSpellClassCooldown(72, "WARRIOR", 12); -- shield bash
	Omni.RegisterSpellClassCooldown(694, "WARRIOR", 60); -- mocking blow
	Omni.RegisterSpellClassCooldown(2565, "WARRIOR", 60); -- skield block
	Omni.RegisterSpellClassCooldown(676, "WARRIOR", 60); -- disarm
	Omni.RegisterSpellClassCooldown(20230, "WARRIOR", 5*60); -- retaliation
	Omni.RegisterSpellClassCooldown(5246, "WARRIOR", 2*60); -- intimidating shout
	Omni.RegisterSpellClassCooldown(1161, "WARRIOR", 3*60); -- challenging shout
	Omni.RegisterSpellClassCooldown(871, "WARRIOR", 5*60); -- shieldwall
	Omni.RegisterSpellClassCooldown(20252, "WARRIOR", 30); -- intercept
	Omni.RegisterSpellClassCooldown(18499, "WARRIOR", 30); -- berseker rage
	Omni.RegisterSpellClassCooldown(1680, "WARRIOR", 10); -- wirlwind
	Omni.RegisterSpellClassCooldown(6552, "WARRIOR", 10); -- pummel
	Omni.RegisterSpellClassCooldown(11578, "WARRIOR", 15); -- charge
	Omni.RegisterSpellClassCooldown(1719, "WARRIOR", 5*60); -- recklessness
	Omni.RegisterSpellClassCooldown(23920, "WARRIOR", 10); -- spell reflection
	Omni.RegisterSpellClassCooldown(3411, "WARRIOR", 30); -- intervane
	Omni.RegisterSpellClassCooldown(64382, "WARRIOR", 5*60); -- shattering throw
	Omni.RegisterSpellClassCooldown(55694, "WARRIOR", 3*60); -- enrage regeneration
	Omni.RegisterSpellClassCooldown(47502, "WARRIOR", 6); -- thunder clap
	Omni.RegisterSpellClassCooldown(57755, "WARRIOR", 60); -- heroic throw
	Omni.RegisterSpellClassCooldown(47486, "WARRIOR", 6); -- mortal strike
	Omni.RegisterSpellClassCooldown(57823, "WARRIOR", 5); -- revenge
	Omni.RegisterSpellClassCooldown(47488, "WARRIOR", 6); -- shield slam
	
	Omni.RegisterSpellClassCooldown(50977, "DEATHKNIGHT", 60); -- Death gate
	Omni.RegisterSpellClassCooldown(49576, "DEATHKNIGHT", 35); -- Death grip
	Omni.RegisterSpellClassCooldown(46584, "DEATHKNIGHT", 3*60); -- raise dead
	Omni.RegisterSpellClassCooldown(47528, "DEATHKNIGHT", 10); -- mind freeze
	Omni.RegisterSpellClassCooldown(47476, "DEATHKNIGHT", 2*60); -- strangulate
	Omni.RegisterSpellClassCooldown(48792, "DEATHKNIGHT", 60); -- icebound fortitude
	Omni.RegisterSpellClassCooldown(45529, "DEATHKNIGHT", 60); -- blood tap
	Omni.RegisterSpellClassCooldown(56222, "DEATHKNIGHT", 8); -- dark command
	Omni.RegisterSpellClassCooldown(48743, "DEATHKNIGHT", 2*60); -- death pact
	Omni.RegisterSpellClassCooldown(48707, "DEATHKNIGHT", 45); -- anti magic cell
	Omni.RegisterSpellClassCooldown(61999, "DEATHKNIGHT", 15*60); -- raise ally
	Omni.RegisterSpellClassCooldown(47568, "DEATHKNIGHT", 5*60); -- empower rune weapon
	Omni.RegisterSpellClassCooldown(57623, "DEATHKNIGHT", 20); -- horn of winter
	Omni.RegisterSpellClassCooldown(42650, "DEATHKNIGHT", 20*60); -- army of the dead
	Omni.RegisterSpellClassCooldown(51328, "DEATHKNIGHT", 5); -- corps explosion
	Omni.RegisterSpellClassCooldown(49938, "DEATHKNIGHT", 10); -- d&d
	Omni.RegisterSpellClassCooldown(51411, "DEATHKNIGHT", 8); -- howling blast
	Omni.RegisterSpellClassCooldown(51052, "DEATHKNIGHT", 2*60); -- anti magic zone
	Omni.RegisterSpellClassCooldown(49222, "DEATHKNIGHT", 2*60); -- bone shield
	Omni.RegisterSpellClassCooldown(49028, "DEATHKNIGHT", 1.5*60); -- dancing rune
	Omni.RegisterSpellClassCooldown(49796, "DEATHKNIGHT", 2*60); -- deathchill
	Omni.RegisterSpellClassCooldown(63560, "DEATHKNIGHT", 10); -- goul frenzy
	Omni.RegisterSpellClassCooldown(49203, "DEATHKNIGHT", 60); -- Hungering cold
	Omni.RegisterSpellClassCooldown(49016, "DEATHKNIGHT", 3*60); -- hysteria
	Omni.RegisterSpellClassCooldown(49039, "DEATHKNIGHT", 3*60); -- lichborne
	Omni.RegisterSpellClassCooldown(49005, "DEATHKNIGHT", 3*60); -- mark of blood
	Omni.RegisterSpellClassCooldown(48982, "DEATHKNIGHT", 60); -- rune tap
	Omni.RegisterSpellClassCooldown(49206, "DEATHKNIGHT", 3*60); -- summon gargoyle
	Omni.RegisterSpellClassCooldown(51271, "DEATHKNIGHT", 2*60); -- unbreakable armor
	Omni.RegisterSpellClassCooldown(55233, "DEATHKNIGHT", 2*60); -- vampiric blood
	
	Omni.RegisterSpellClassCooldown(13750, "ROGUE", 3*60); -- adrenaline rush
	Omni.RegisterSpellClassCooldown(13877, "ROGUE", 2*60); -- blade flurry
	Omni.RegisterSpellClassCooldown(14177, "ROGUE", 3*60); -- coldblood
	Omni.RegisterSpellClassCooldown(14278, "ROGUE", 20); -- ghostly strike
	Omni.RegisterSpellClassCooldown(51690, "ROGUE", 2*60); -- killing spree
	Omni.RegisterSpellClassCooldown(14183, "ROGUE", 20); -- premeditation
	Omni.RegisterSpellClassCooldown(14185, "ROGUE", 10*60); -- preparation
	Omni.RegisterSpellClassCooldown(14251, "ROGUE", 6); -- riposte
	Omni.RegisterSpellClassCooldown(51713, "ROGUE", 2*60); -- shadow dance
	Omni.RegisterSpellClassCooldown(36554, "ROGUE", 30); -- shadowstep
	Omni.RegisterSpellClassCooldown(1776, "ROGUE", 10); -- gouge
	Omni.RegisterSpellClassCooldown(1766, "ROGUE", 10); -- kick
	Omni.RegisterSpellClassCooldown(51722, "ROGUE", 60); -- Dismantle
	Omni.RegisterSpellClassCooldown(1725, "ROGUE", 30); -- distract
	Omni.RegisterSpellClassCooldown(2094, "ROGUE", 3*60); -- blind
	Omni.RegisterSpellClassCooldown(26669, "ROGUE", 3*60); -- evasion
	Omni.RegisterSpellClassCooldown(8643, "ROGUE", 20); -- Kidney shot
	Omni.RegisterSpellClassCooldown(2983, "ROGUE", 3*60); -- sprint
	Omni.RegisterSpellClassCooldown(11305, "ROGUE", 3*60); -- sprint
	Omni.RegisterSpellClassCooldown(1787, "ROGUE", 10); -- stealth
	Omni.RegisterSpellClassCooldown(26889, "ROGUE", 3*60); -- vanish
	Omni.RegisterSpellClassCooldown(31224, "ROGUE", 1.5*60); -- Cloak of shadow
	Omni.RegisterSpellClassCooldown(57934, "ROGUE", 30); -- Tricks of the trade
	Omni.RegisterSpellClassCooldown(48659, "ROGUE", 10); -- feint
	
	Omni.RegisterSpellClassCooldown(16166, "SHAMAN", 3*60); -- elemental mastery
	Omni.RegisterSpellClassCooldown(51533, "SHAMAN", 3*60); -- ferral spirit
	Omni.RegisterSpellClassCooldown(16190, "SHAMAN", 5*60); -- mana tide totem
	Omni.RegisterSpellClassCooldown(16188, "SHAMAN", 3*60); -- nature swit
	Omni.RegisterSpellClassCooldown(30823, "SHAMAN", 2*60); -- shamanistic rage
	Omni.RegisterSpellClassCooldown(17364, "SHAMAN", 8); -- stormstrike
	Omni.RegisterSpellClassCooldown(55198, "SHAMAN", 3*60); -- tidal force
	Omni.RegisterSpellClassCooldown(57994, "SHAMAN", 6, "shock"); -- wind shock
	--Omni.RegisterSpellClassCooldown(556, "SHAMAN", 15*60); -- astral recall
	Omni.RegisterSpellClassCooldown(2484, "SHAMAN", 15); -- totem lien terrestre
	Omni.RegisterSpellClassCooldown(20608, "SHAMAN", 60*60); -- reincarnation
	Omni.RegisterSpellClassCooldown(2062, "SHAMAN", 20*60); -- earth elemental
	Omni.RegisterSpellClassCooldown(2894, "SHAMAN", 20*60); -- fire elemental
	Omni.RegisterSpellClassCooldown(2825, "SHAMAN", 5*60); -- bloodlust
	Omni.RegisterSpellClassCooldown(32182, "SHAMAN", 5*60); -- heroism
	--Omni.RegisterSpellClassCooldown(8056, "SHAMAN", 6, "shock"); -- frost shock 1
	--Omni.RegisterSpellClassCooldown(8058, "SHAMAN", 6, "shock"); -- frost shock 2
	--Omni.RegisterSpellClassCooldown(10472, "SHAMAN", 6, "shock"); -- frost shock 3
	--Omni.RegisterSpellClassCooldown(10473, "SHAMAN", 6, "shock"); -- frost shock 4
	--Omni.RegisterSpellClassCooldown(25464, "SHAMAN", 6, "shock"); -- frost shock 5
	--Omni.RegisterSpellClassCooldown(49235, "SHAMAN", 6, "shock"); -- frost shock 6
	Omni.RegisterSpellClassCooldown(49236, "SHAMAN", 6, "shock"); -- frost shock 7
	--Omni.RegisterSpellClassCooldown(5730, "SHAMAN", 15); -- stoneclaw 1
	--Omni.RegisterSpellClassCooldown(6390, "SHAMAN", 15); -- stoneclaw 2
	--Omni.RegisterSpellClassCooldown(6391, "SHAMAN", 15); -- stoneclaw 3
	--Omni.RegisterSpellClassCooldown(6392, "SHAMAN", 15); -- stoneclaw 4
	--Omni.RegisterSpellClassCooldown(10427, "SHAMAN", 15); -- stoneclaw 5
	--Omni.RegisterSpellClassCooldown(10428, "SHAMAN", 15); -- stoneclaw 6
	--Omni.RegisterSpellClassCooldown(25525, "SHAMAN", 15); -- stoneclaw 7
	--Omni.RegisterSpellClassCooldown(58580, "SHAMAN", 15); -- stoneclaw 8
	--Omni.RegisterSpellClassCooldown(58581, "SHAMAN", 15); -- stoneclaw 9
	Omni.RegisterSpellClassCooldown(58582, "SHAMAN", 15); -- stoneclaw 10
	--Omni.RegisterSpellClassCooldown(8042, "SHAMAN", 6, "shock"); -- earth shock 1
	--Omni.RegisterSpellClassCooldown(8044, "SHAMAN", 6, "shock"); -- earth shock 2
	--Omni.RegisterSpellClassCooldown(8045, "SHAMAN", 6, "shock"); -- earth shock 3
	--Omni.RegisterSpellClassCooldown(8046, "SHAMAN", 6, "shock"); -- earth shock 4
	--Omni.RegisterSpellClassCooldown(10412, "SHAMAN", 6, "shock"); -- earth shock 5
	--Omni.RegisterSpellClassCooldown(10413, "SHAMAN", 6, "shock"); -- earth shock 6
	--Omni.RegisterSpellClassCooldown(10414, "SHAMAN", 6, "shock"); -- earth shock 7
	--Omni.RegisterSpellClassCooldown(25454, "SHAMAN", 6, "shock"); -- earth shock 8
	--Omni.RegisterSpellClassCooldown(49230, "SHAMAN", 6, "shock"); -- earth shock 9
	Omni.RegisterSpellClassCooldown(49231, "SHAMAN", 6, "shock"); -- earth shock 10
	--Omni.RegisterSpellClassCooldown(421, "SHAMAN", 6); -- chain lightning 1
	--Omni.RegisterSpellClassCooldown(930, "SHAMAN", 6); -- chain lightning 2
	--Omni.RegisterSpellClassCooldown(2860, "SHAMAN", 6); -- chain lightning 3
	--Omni.RegisterSpellClassCooldown(10605, "SHAMAN", 6); -- chain lightning 4
	--Omni.RegisterSpellClassCooldown(25439, "SHAMAN", 6); -- chain lightning 5
	--Omni.RegisterSpellClassCooldown(25442, "SHAMAN", 6); -- chain lightning 6
	--Omni.RegisterSpellClassCooldown(49270, "SHAMAN", 6); -- chain lightning 7
	--Omni.RegisterSpellClassCooldown(49271, "SHAMAN", 6); -- chain lightning 8
	--Omni.RegisterSpellClassCooldown(1535, "SHAMAN", 15); -- fire nova 1
	--Omni.RegisterSpellClassCooldown(8498, "SHAMAN", 15); -- fire nova 2
	--Omni.RegisterSpellClassCooldown(8499, "SHAMAN", 15); -- fire nova 3
	--Omni.RegisterSpellClassCooldown(11314, "SHAMAN", 15); -- fire nova 4
	--Omni.RegisterSpellClassCooldown(11315, "SHAMAN", 15); -- fire nova 5
	--Omni.RegisterSpellClassCooldown(25546, "SHAMAN", 15); -- fire nova 6
	--Omni.RegisterSpellClassCooldown(25547, "SHAMAN", 15); -- fire nova 7
	--Omni.RegisterSpellClassCooldown(61649, "SHAMAN", 15); -- fire nova 8
	Omni.RegisterSpellClassCooldown(61657, "SHAMAN", 15); -- fire nova 9
	--Omni.RegisterSpellClassCooldown(8050, "SHAMAN", 6, "shock"); -- flammes shock 1
	--Omni.RegisterSpellClassCooldown(8052, "SHAMAN", 6, "shock"); -- flammes shock 2
	--Omni.RegisterSpellClassCooldown(8053, "SHAMAN", 6, "shock"); -- flammes shock 3
	--Omni.RegisterSpellClassCooldown(10447, "SHAMAN", 6, "shock"); -- flammes shock 4
	--Omni.RegisterSpellClassCooldown(10448, "SHAMAN", 6, "shock"); -- flammes shock 5
	--Omni.RegisterSpellClassCooldown(29228, "SHAMAN", 6, "shock"); -- flammes shock 6
	--Omni.RegisterSpellClassCooldown(25457, "SHAMAN", 6, "shock"); -- flammes shock 7
	--Omni.RegisterSpellClassCooldown(49232, "SHAMAN", 6, "shock"); -- flammes shock 8
	Omni.RegisterSpellClassCooldown(49233, "SHAMAN", 6, "shock"); -- flammes shock 9
	Omni.RegisterSpellClassCooldown(51514, "SHAMAN", 45); -- Hex
	--Omni.RegisterSpellClassCooldown(51505, "SHAMAN", 8); -- lava burst 1
	Omni.RegisterSpellClassCooldown(60043, "SHAMAN", 8); -- lava burst 2
	--Omni.RegisterSpellClassCooldown(61300, "SHAMAN", 6); -- riptide 1
	--Omni.RegisterSpellClassCooldown(61299, "SHAMAN", 6); -- riptide 2
	--Omni.RegisterSpellClassCooldown(61300, "SHAMAN", 6); -- riptide 3
	Omni.RegisterSpellClassCooldown(61301, "SHAMAN", 6); -- riptide 4
	--Omni.RegisterSpellClassCooldown(59158, "SHAMAN", 45); -- thunderstorm 1
	--Omni.RegisterSpellClassCooldown(59156, "SHAMAN", 45); -- thunderstorm 2
	--Omni.RegisterSpellClassCooldown(59158, "SHAMAN", 45); -- thunderstorm 3
	Omni.RegisterSpellClassCooldown(59159, "SHAMAN", 45); -- thunderstorm 4
	
	
	Omni.RegisterSpellClassCooldown(31821, "PALADIN", 2*60); -- aura mastery
	Omni.RegisterSpellClassCooldown(35395, "PALADIN", 6); -- crusader strike
	Omni.RegisterSpellClassCooldown(20216, "PALADIN", 2*60); -- divine favor
	Omni.RegisterSpellClassCooldown(31842, "PALADIN", 3*60); -- divine illumination
	Omni.RegisterSpellClassCooldown(64205, "PALADIN", 2*60); -- divine sacrifice
	Omni.RegisterSpellClassCooldown(53385, "PALADIN", 5); -- divine storm
	Omni.RegisterSpellClassCooldown(53595, "PALADIN", 6); -- hammer of the righteous
	Omni.RegisterSpellClassCooldown(20066, "PALADIN", 60); -- repentance
	Omni.RegisterSpellClassCooldown(20271, "PALADIN", 10, "judgement"); -- Judgement of light
	Omni.RegisterSpellClassCooldown(498, "PALADIN", 3*60); -- divine protection
	Omni.RegisterSpellClassCooldown(53408, "PALADIN", 10, "judgement"); -- Judgement of wisdom
	Omni.RegisterSpellClassCooldown(31789, "PALADIN", 8); -- Righteous defence
	Omni.RegisterSpellClassCooldown(62124, "PALADIN", 8); -- hand of reckoning
	Omni.RegisterSpellClassCooldown(1044, "PALADIN", 25); -- hand of freedom
	Omni.RegisterSpellClassCooldown(1038, "PALADIN", 2*60); -- hand of salvation
	Omni.RegisterSpellClassCooldown(53407, "PALADIN", 10, "judgement"); -- judgement of justice
	Omni.RegisterSpellClassCooldown(19752, "PALADIN", 20*60); -- divine intervention
	Omni.RegisterSpellClassCooldown(642, "PALADIN", 5*60); -- divine shield
	Omni.RegisterSpellClassCooldown(10278, "PALADIN", 5*60); -- hand of protection
	Omni.RegisterSpellClassCooldown(6940, "PALADIN", 2*60); -- hand of sacrifice
	Omni.RegisterSpellClassCooldown(10308, "PALADIN", 60); -- hammer of justice
	Omni.RegisterSpellClassCooldown(31884, "PALADIN", 3*60); -- avenging wrath
	Omni.RegisterSpellClassCooldown(54428, "PALADIN", 60); -- divine plea
	Omni.RegisterSpellClassCooldown(48817, "PALADIN", 30); -- holy wrath
	Omni.RegisterSpellClassCooldown(48788, "PALADIN", 20*60); -- lay on hands
	Omni.RegisterSpellClassCooldown(48801, "PALADIN", 15); -- exorcism
	Omni.RegisterSpellClassCooldown(48827, "PALADIN", 30); -- avenger s shield
	Omni.RegisterSpellClassCooldown(48819, "PALADIN", 8); -- consecration
	Omni.RegisterSpellClassCooldown(48806, "PALADIN", 6); -- hammer of wrath
	Omni.RegisterSpellClassCooldown(48952, "PALADIN", 8); -- holy shield
	Omni.RegisterSpellClassCooldown(48825, "PALADIN", 6); -- holy shock
	Omni.RegisterSpellClassCooldown(61411, "PALADIN", 6); -- Shield of rightenousness
	
	Omni.RegisterSpellRaceCooldown(7744, "Scourge", 2*60); -- volonte reprouve
	Omni.RegisterSpellRaceCooldown(20577, "Scourge", 2*60); -- canibalisme
	Omni.RegisterSpellRaceCooldown(20549, "Tauren", 2*60); -- Choc martial
end);
