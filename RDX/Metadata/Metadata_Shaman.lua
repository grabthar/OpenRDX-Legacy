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
if class == "SHAMAN" then
	RDXEvents:Bind("SPELLS_BUILD_CATEGORIES", nil, function()
		RDXSS.CategorizeClass(i18n("Cure Poison"), "CURE_POISON");
		RDXSS.CategorizeClass(i18n("Cure Disease"), "CURE_DISEASE");
	end);
end
