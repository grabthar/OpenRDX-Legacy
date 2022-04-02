-- AggroSet.lua
-- RDX
-- (C)2007 Raid Informatics
--
-- A set class matching all people who are being targeted by a hostile entity.

-- Locals
local aggromap = {};
local aggroUpdatePeriod = 0.2;
local strlower = string.lower;
local GetUnitByName = RDX.GetUnitByNameIfInGroup;
local GetUnitByNumber = RDX.GetUnitByNumber;

-- The aggro map is the "feeder" for the aggro set.
local unit, uid, t, tt;
local function UpdateAggroMap()
	for i=1,40 do aggromap[i] = false; end
	for i=1,40 do
		unit = GetUnitByNumber(i);
		if unit:IsCacheValid() then
		--if unit:IsValid() then
			uid = unit.uid; t = uid .. "target"; tt = t .. "target";
			-- "Target" must be hostile and "targettarget" must be friendly
			if UnitExists(tt) and UnitIsEnemy(uid, t) and UnitIsFriend(uid, tt) then
				-- If so "targettarget" has aggro.
				unit = GetUnitByName(strlower(UnitName(tt)));
				if unit then aggromap[unit.nid] = true;	end
			end
		end
	end
end

-- The set
local aggroSet = RDX.Set:new();
aggroSet.name = "Has Aggro<>";
RDX.RegisterSet(aggroSet);

local function UpdateAggroSet()
	UpdateAggroMap();
	for i=1,40 do aggroSet:_Set(i, aggromap[i]); end
end

function aggroSet:_OnActivate()
	VFL.AdaptiveUnschedule("AggroUpdate");
	VFL.AdaptiveSchedule("AggroUpdate", aggroUpdatePeriod, UpdateAggroSet);
end
function aggroSet:_OnDeactivate()
	VFL.AdaptiveUnschedule("AggroUpdate");
end

RDX.RegisterSetClass({
	name = "ags"; title = i18n("Has Aggro");
	GetUI = RDX.TrivialSetFinderUI("ags");
	FindSet = function() return aggroSet; end;
});

-------------------------------------------------------
-- Combat Set
-------------------------------------------------------

local combatmap = {};
local combatUpdatePeriod = 0.2;

-- The aggro map is the "feeder" for the aggro set.
local unit1;
local function UpdateCombatMap()
	for i=1,40 do combatmap[i] = false; end
	for i=1,40 do
		unit1 = GetUnitByNumber(i);
		if unit1:IsCacheValid() and UnitAffectingCombat(unit1.uid) then
			aggromap[unit1.nid] = true;
		end
	end
end

local combatSet = RDX.Set:new();
combatSet.name = "In Combat<>";
RDX.RegisterSet(combatSet);


local function UpdateCombatSet()
	UpdateCombatMap();
	for i=1,40 do combatSet:_Set(i, combatmap[i]); end
end

function combatSet:_OnActivate()
	VFL.AdaptiveUnschedule("CombatUpdate");
	VFL.AdaptiveSchedule("CombatUpdate", combatUpdatePeriod, UpdateCombatSet);
end
function combatSet:_OnDeactivate()
	VFL.AdaptiveUnschedule("CombatUpdate");
end

RDX.RegisterSetClass({
	name = "combatset"; title = i18n("In Combat");
	GetUI = RDX.TrivialSetFinderUI("combatset");
	FindSet = function() return combatSet; end;
});

