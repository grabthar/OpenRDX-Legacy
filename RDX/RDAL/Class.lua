-- Class.lua
-- OpenRDX
-- 

RDXCT = RegisterVFLModule({
	name = "RDXCT";
	title = "RDX CLASS TALENT";
	description = "RDX CLASS TALENT";
	version = {1,0,0};
	parent = RDX;
});

-----------------------------------
-- Metadata about WoW classes.
-----------------------------------

local idToClass = { 
	"PRIEST", "DRUID", "PALADIN", 
	"SHAMAN", "WARRIOR", "WARLOCK", 
	"MAGE", "ROGUE", "HUNTER", "DEATHKNIGHT"
};
local classToID = VFL.invert(idToClass);

local idToLocalName = { 
	i18n("Priest"), i18n("Druid"), i18n("Paladin"), 
	i18n("Shaman"), i18n("Warrior"), i18n("Warlock"), 
	i18n("Mage"), i18n("Rogue"), i18n("Hunter"), 
	i18n("DeathKnight");
};
local localNameToID = VFL.invert(idToLocalName);

local idToClassColor = {};
for i=1,10 do
	idToClassColor[i] = RAID_CLASS_COLORS[idToClass[i]];
end
local nameToClassColor = RAID_CLASS_COLORS;

local _grey = { r=.5, g=.5, b=.5};

local classIcons = {
	["WARRIOR"] = {0, 0.25, 0, 0.25},
	["MAGE"] = {0.25, 0.49609375, 0, 0.25},
	["ROGUE"] = {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"] = {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"] = {0, 0.25, 0.25, 0.5},
	["SHAMAN"] = {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"] = {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"] = {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"] = {0, 0.25, 0.5, 0.75},
	["DEATHKNIGHT"]	= {0.25, .5, 0.5, .75},
	["PETS"] = {0, 1, 0, 1},
	["MAINTANK"] = {0, 1, 0, 1},
	["MAINASSIST"] = {0, 1, 0, 1}
};
local class_un = {0, 0, 0, 0};

--- Retrieve the class ID for the class with the given proper name.
-- The proper name is the SECOND parameter returned from UnitClass(), and is
-- the fully capitalized English name of the class (e.g. "WARRIOR", "PALADIN")
function RDXCT.GetClassID(cn) return classToID[cn] or 0; end

-- Given the class ID, retrieve the proper classname
function RDXCT.GetClassMnemonic(cid) return idToClass[cid] or "UNKNOWN"; end

--- Given the class ID, retrieve the localized name for the class.
function RDXCT.GetClassName(cid) return idToLocalName[cid] or i18n("Unknown"); end

--- Given the class ID, retrieve the class color as an RGB table.
function RDXCT.GetClassColor(cid) return idToClassColor[cid] or _grey; end
function RDXCT.GetClassColorFromEn(en) return nameToClassColor[en] or _grey; end

--- Given a *VALID* unit ID, get its class color.
function RDX.GetUnitClassColor(uid)
	local _,cn = UnitClass(uid);
	local id = classToID[cn];
	if not id then return _grey; end
	return idToClassColor[id] or _grey;
end

-- need find the points
function RDXCT.GetClassIcon(cn)
	return classIcons[cn] or class_un;
end

--------------------------------------------------------------
-- Metadata about WoW sub classes (talent)
-------------------------------------------------------------

local idToLocalsubclass = { 
	i18n("PRIEST_Discipline"), i18n("PRIEST_Holy"), i18n("PRIEST_Shadow"),
	i18n("DRUID_Balance"), i18n("DRUID_Feral Combat"), i18n("DRUID_Restoration"),
	i18n("PALADIN_Holy"), i18n("PALADIN_Protection"), i18n("PALADIN_Retribution"),
	i18n("SHAMAN_Elemental"), i18n("SHAMAN_Enhancement"), i18n("SHAMAN_Restoration"),
	i18n("WARRIOR_Arms"), i18n("WARRIOR_Fury"), i18n("WARRIOR_Protection"),
	i18n("WARLOCK_Affliction"), i18n("WARLOCK_Demonology"), i18n("WARLOCK_Destruction"),
	i18n("MAGE_Arcane"), i18n("MAGE_Fire"), i18n("MAGE_Frost"),
	i18n("ROGUE_Assassination"), i18n("ROGUE_Combat"), i18n("ROGUE_Subtlety"),
	i18n("HUNTER_Beast Mastery"), i18n("HUNTER_Marksmanship"), i18n("HUNTER_Survival"),
	i18n("DEATHKNIGHT_Blood"), i18n("DEATHKNIGHT_Frost"), i18n("DEATHKNIGHT_Unholy"),
};
local localsubclassToID = VFL.invert(idToLocalsubclass);
local _unsubclass = "Unknown";

local idToSubClassColor = { 
	RAID_CLASS_COLORS["PRIEST"], RAID_CLASS_COLORS["PRIEST"], RAID_CLASS_COLORS["PRIEST"],
	RAID_CLASS_COLORS["DRUID"], RAID_CLASS_COLORS["DRUID"], RAID_CLASS_COLORS["DRUID"],
	RAID_CLASS_COLORS["PALADIN"], RAID_CLASS_COLORS["PALADIN"], RAID_CLASS_COLORS["PALADIN"],
	RAID_CLASS_COLORS["SHAMAN"], RAID_CLASS_COLORS["SHAMAN"], RAID_CLASS_COLORS["SHAMAN"],
	RAID_CLASS_COLORS["WARRIOR"], RAID_CLASS_COLORS["WARRIOR"], RAID_CLASS_COLORS["WARRIOR"],
	RAID_CLASS_COLORS["WARLOCK"], RAID_CLASS_COLORS["WARLOCK"], RAID_CLASS_COLORS["WARLOCK"],
	RAID_CLASS_COLORS["MAGE"], RAID_CLASS_COLORS["MAGE"], RAID_CLASS_COLORS["MAGE"],
	RAID_CLASS_COLORS["ROGUE"], RAID_CLASS_COLORS["ROGUE"], RAID_CLASS_COLORS["ROGUE"],
	RAID_CLASS_COLORS["HUNTER"], RAID_CLASS_COLORS["HUNTER"], RAID_CLASS_COLORS["HUNTER"],
	RAID_CLASS_COLORS["DEATHKNIGHT"], RAID_CLASS_COLORS["DEATHKNIGHT"], RAID_CLASS_COLORS["DEATHKNIGHT"],
};
local localSubClassColorToID = VFL.invert(idToSubClassColor);
local _unsbColor = { r=.5, g=.5, b=.5};

local idToTexture = {};
idToTexture[1] = "Interface\\Icons\\Spell_Holy_PowerInfusion";
idToTexture[2] = "Interface\\Icons\\Spell_Holy_HolyBolt";
idToTexture[3] = "Interface\\Icons\\Spell_Shadow_ShadowWordPain";
idToTexture[4] = "Interface\\Icons\\Spell_Nature_Preservation";
idToTexture[5] = "Interface\\Icons\\Ability_Racial_BearForm";
idToTexture[6] = "Interface\\Icons\\Spell_Nature_HealingTouch";
idToTexture[7] = "Interface\\Icons\\Spell_Holy_HolyGuidance";
idToTexture[8] = "Interface\\Icons\\SPELL_HOLY_DEVOTIONAURA";
idToTexture[9] = "Interface\\Icons\\Spell_Holy_AuraOfLight";
idToTexture[10] = "Interface\\Icons\\Spell_Nature_Lightning";
idToTexture[11] = "Interface\\Icons\\Spell_Nature_LightningShield";
idToTexture[12] = "Interface\\Icons\\Spell_Nature_MagicImmunity";
idToTexture[13] = "Interface\\Icons\\Ability_MeleeDamage";
idToTexture[14] = "Interface\\Icons\\Ability_Warrior_InnerRage";
idToTexture[15] = "Interface\\Icons\\Ability_Warrior_DefensiveStance";
idToTexture[16] = "Interface\\Icons\\Spell_Shadow_DeathCoil";
idToTexture[17] = "Interface\\Icons\\Spell_Shadow_Metamorphosis";
idToTexture[18] = "Interface\\Icons\\Spell_Shadow_RainOfFire";
idToTexture[19] = "Interface\\Icons\\Spell_Arcane_Blast";
idToTexture[20] = "Interface\\Icons\\Spell_Fire_FlameBolt";
idToTexture[21] = "Interface\\Icons\\Spell_Frost_FrostBolt02";
idToTexture[22] = "Interface\\Icons\\Ability_Rogue_Eviscerate";
idToTexture[23] = "Interface\\Icons\\Ability_BackStab";
idToTexture[24] = "Interface\\Icons\\Ability_Rogue_MasterOfSubtlety";
idToTexture[25] = "Interface\\Icons\\Ability_Hunter_BeastTaming";
idToTexture[26] = "Interface\\Icons\\Ability_Marksmanship";
idToTexture[27] = "Interface\\Icons\\Ability_Hunter_SwiftStrike";
idToTexture[28] = "Interface\\Icons\\Spell_Deathknight_BloodPresence";
idToTexture[29] = "Interface\\Icons\\Spell_Deathknight_FrostPresence";
idToTexture[30] = "Interface\\Icons\\Spell_Deathknight_UnholyPresence";

local _unsbTex = "Interface\\InventoryItems\\WoWUnknownItem01.blp";


function RDXCT.GetIdSubClassByLocal(scn)
	return localsubclassToID[scn] or 0;
end

function RDXCT.GetLocalSubclassById(scid)
	return idToLocalsubclass[scid] or _unsubclass;
end

function RDXCT.GetColorSubClassByLocal(scn)
	local idn = localsubclassToID[scn];
	if not idn then return _unsbColor; end
	return idToSubClassColor[idn] or _unsbColor;
end

function RDXCT.GetColorSubClassById(id)
	return idToSubClassColor[id] or _unsbColor;
end

function RDXCT.GetTextureSubClassByLocal(scn)
	local idn = localsubclassToID[scn];
	if not idn then return _unsbTex; end
	return idToTexture[idn] or _unsbTex;
end

function RDXCT.GetTextureSubClassById(id)
	return idToTexture[id] or _unsbTex;
end


