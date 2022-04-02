-- Metadata_*.lua
-- VFL
-- (C)2006 Bill Johnson and The VFL Project
--
-- CLASS METADATA FILE
--
-- The metadata format should be clear from examining the contents below. Note
-- that this file will only be loaded if the player is of the specified class.
-- 
local _,class = UnitClass("player");
if class == "DRUID" then
	RDXEvents:Bind("SPELLS_BUILD_CATEGORIES", nil, function()
		RDXSS.CategorizeClass(i18n("Abolish Poison"), "PERIODIC");
		RDXSS.CategorizeClass(i18n("Abolish Poison"), "CURE_POISON");
		RDXSS.CategorizeClass(i18n("Remove Curse"), "CURE_CURSE");
	end);
end

VFLUI.RegisterAbilIcon("Druid", "Mark of the Wild", "Spell_Nature_Regeneration");
