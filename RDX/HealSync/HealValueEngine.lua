-- HealValueEngine.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--

------------------------------------------------------------------------
-- Healing Synchronization module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
--
-- Note:
--  Licensed exclusively to Raid Informatics
------------------------------------------------------------------------

-- This code uses the average value of your heals sampled over time to estimate
-- the value of future heals.

-- This is the training rate at which RDX learns the value of your heals.
-- Lower number = faster, higher number = more refined
local SAMPLESIZE = 5; 

--- Adds a data point to the heal values database.
function HealSync.AddHealValueDataPoint(spell, rank, value)
	if not HealSync.IsDirectHeal(spell) then return; end
	if not rank then rank = ""; end
	spell = spell .. "_" .. rank;
	local fWeight = ( (SAMPLESIZE-1)/SAMPLESIZE );
	local sWeight = 1 - fWeight;
	-- If nonexistent, stuff with initial value
	local oldv = RDXU.HealDB[spell];
	if not oldv then RDXU.HealDB[spell] = value; return; end
	-- Otherwise take weighted avg.
	RDXU.HealDB[spell] = (oldv * fWeight) + (value * sWeight);
end

--- Get the expected average value of the given heal.
function HealSync.GetHealValue(spell, rank)
	if not rank then rank = ""; end
	spell = spell .. "_" .. rank;
	return RDXU.HealDB[spell] or 0;
end

--- Get the cast time for a heal
function HealSync.GetHealCastTime(spell, rank)
	if not rank then rank = ""; end
	spell = spell .. "_" .. rank;
	return RDXU.HealCastTime[spell] or 3;
end

function HealSync.SetHealCastTime(spell, rank, time)
	if not rank then rank = ""; end
	spell = spell .. "_" .. rank;
	RDXU.HealCastTime[spell] = time;
end

--- Create the database if it doesn't exist at load time
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	if not RDXU.HealDB then RDXU.HealDB = {}; end
	if not RDXU.HealCastTime then RDXU.HealCastTime = {}; end
end);
