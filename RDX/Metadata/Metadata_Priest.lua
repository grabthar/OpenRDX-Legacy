-- Metadata_Priest.lua
-- VFL
-- (C)2006 Bill Johnson and The VFL Project
--
-- CLASS METADATA FILE
--
-- The metadata format should be clear from examining the contents below. Note
-- that this file will only be loaded if the player is of the specified class.
-- 
local _,class = UnitClass("player");
if class == "PRIEST" then
	RDXEvents:Bind("SPELLS_BUILD_CATEGORIES", nil, function()
		RDXSS.CategorizeClass(i18n("Dispel Magic"), "DIRECT");
		RDXSS.CategorizeClass(i18n("Dispel Magic"), "CURE_MAGIC");
		RDXSS.CategorizeClass(i18n("Cure Disease"), "DIRECT");
		RDXSS.CategorizeClass(i18n("Cure Disease"), "CURE_DISEASE");
		RDXSS.CategorizeClass(i18n("Abolish Disease"), "PERIODIC");
		RDXSS.CategorizeClass(i18n("Abolish Disease"), "CURE_DISEASE");
	end);
end

VFLUI.RegisterAbilIcon("Priest", "Prayer of Fortitude", "Spell_Holy_PrayerOfFortitude");
VFLUI.RegisterAbilIcon("Priest", "Shadow Protection", "Spell_Holy_PrayerofShadowProtection");
VFLUI.RegisterAbilIcon("Priest", "Prayer of Spirit", "Spell_Holy_PrayerofSpirit");
