-- Log.lua
-- RDX - Project Omniscience
-- (C)2006 Bill Johnson
--
-- Combat logging facilities for Project Omniscience.

-- Imports
local match, gmatch, lower = string.find, string.gmatch, string.lower;
local GetUnitByName = RDX.GetUnitByNameIfInGroup;

-- The Omniscience log
local omniLog, logCap = {}, 3000;
local omniLogPet, logCapPet = {}, 3000;
local omniLogAll, logCapAll = {}, 3000;

--- Get the Omniscience local log table.
function Omni.GetLog()
	return Omni_Logs;
end

function Omni.GetLogPet()
	return omniLogPet;
end

function Omni.GetLogAll()
	return omniLogAll;
end

local logTrigger = OmniEvents:LockSignal("LOG_ROW_ADDED");
local logTriggerMeters = OmniEvents:LockSignal("LOG_METERS");
local logTriggerHealSync = OmniEvents:LockSignal("LOG_HEALSYNC");
local logTriggerBossmods = OmniEvents:LockSignal("LOG_BOSSMODS");
local logTriggerCooldowns = OmniEvents:LockSignal("LOG_COOLDOWNS");
local logTriggerAll = OmniEvents:LockSignal("LOGALL_ROW_ADDED");

-------------------------------------------
-- LOOKUP METADATA: BUFFS TO TRACK
-- Omniscience doesn't ordinarily record buffs because the log would be overspammed
-- with buff info. Certain exceptions (shield wall, last stand, etc.) are recorded here.
-------------------------------------------
--[[
local trackedBuffs = {};
trackedBuffs[i18n("Shield Block")] = true;
trackedBuffs[i18n("Shield Wall")] = true;
trackedBuffs[i18n("Gift of Life")] = true;
trackedBuffs[i18n("Last Stand")] = true;
trackedBuffs[i18n("Power Word: Shield")] = true;
Omni.trackedBuffs = trackedBuffs;
]]--

-------------------------------------------
-- LOOKUP METADATA: DAMAGE TYPES
-------------------------------------------
local dmgToType = {};
Omni.dmgToType = dmgToType;
local typeToDmg = {};
Omni.typeToDmg = typeToDmg;

--[[ 
1 = Physical
2 = Holy
3 = Fire
4 = Nature
5 = Frost
6 = Shadow
7 = Arcane
]]

local dmgTypeColors = {
	[1] = { r=1, g=1, b=0 }, [2] = { r=1, g=1, b=.7 }, [3] = { r=.95, g=.3, b= 0 }, 
	[4] = { r=.65, g=.9, b=.25 }, [5] = { r=.25, g=.9, b=.92 }, [6] = { r=.5, g=.13, b=.58 },
	[7] = { r=1, g=1, b=1 },
};

function Omni.GetDamageTypeColor(idx)
	if not idx then return dmgTypeColors[1]; end
	local ret = dmgTypeColors[idx];
	if not ret then return dmgTypeColors[1]; end
	return ret;
end

local unknown = i18n("Unknown");
function Omni.GetDamageTypeName(idx)
	if not idx then return unknown; end
	local ret = typeToDmg[idx];
	if not ret then return unknown; end
	return ret;
end

-------------------------------------------------
-- LOOKUP METADATA: LOG ROW TYPES
-- (1 = damage in, 2 = damage out, 3 = healing in, 4 = healing out) 
-- (5 = debuff applied, 6 = debuff removed, 7 = healing self, 8 = healing))
-- (11 = in combat, 12 = out of combat, 13 = enc start, 14 = enc stop)
-- (15 = enter bg, 16 = leave bg, 17 = killing blow, 18 = your death)
-------------------------------------------------

local rowTypeColors = {
	[1] = {r=.75, g=0, b=0}, [2] = {r=.9, g=.5, b=0},
	[3] = {r=0, g=1, b=0}, [4] = {r=.25, g=.7, b=1},
	[5] = {r=1,g=0,b=0}, [6] = {r=0.5,g=0.9,b=0},
	[7] = {r=0,g=1,b=.35}, [8] = {r=0,g=1,b=0.35},
	[9] = {r=0,g=1,b=0.75}, [10] = {r=1,g=0.5,b=0.75},
	[11] = {r=0.6,g=0.6,b=0}, [12] = {r=0.6,g=0.6,b=0},
	[13] = {r=1,g=1,b=1}, [14] = {r=1,g=1,b=1},
	[15] = {r=1,g=1,b=1}, [16] = {r=1,g=1,b=1},
	[17] = {r=0,g=0.5,b=0}, [18] = {r=0.5,g=0,b=0},
	[19] = {r=1,g=1,b=1}, [20] = {r=1,g=1,b=1},
	[21] = {r=.75, g=0, b=0}, [22] = {r=.9, g=.5, b=0},
	[28] = {r=0, g=0.9, b=0.4}, [29] = {r=0.9, g=.4, b=0},
	[30] = {r=1, g=1, b=1},
};

local rowTypes = {
	[1] = "DamageIn", [2] = "DamageOut", 
	[3] = "HealingIn", [4] = "HealingOut",
	[5] = "+Debuff", [6] = "-Debuff", 
	[7] = "HealingSelf", [8] = "Healing",
	[9] = "+Buff", [10] = "-Buff",
	[11] = "+Combat", [12] = "-Combat", 
	[13] = "+Encounter", [14] = "-Encounter", 
	[15] = "+Battleground", [16] = "-Battleground", 
	[17] = "Killing Blow", [18] = "Death", 
	[19] = "Perform", [20] = "Cast", 
	[21] = "CastMob", [22] = "CastMobSuccess",
	[23] = "+BuffMob", [24] = "-BuffMob",
	[25] = "+DebuffMob", [26] = "-DebuffMob",
	[27] = "CastSucess", 
	[28] = "Interrupt", -- raid member interrupts mob
	[29] = "InterruptMob",  -- mob interrupts a member
	[30] = "Summon",  
};

local typeToRow = VFL.invert(rowTypes);

function Omni.GetMap_IndexToRowType() return rowTypes; end
function Omni.GetMap_RowTypeToIndex() return typeToRow; end

local myRowType = {
	[1] = true, [2] = true, 
	[3] = true, [4] = true,
	[5] = true, [6] = true, 
	[7] = true, [8] = true,
	[9] = true, [10] = true,
	[11] = true, [12] = true, 
	[13] = true, [14] = true, 
	[15] = true, [16] = true, 
	[17] = true, [18] = true, 
	[19] = true, [20] = true, 
	[21] = false, [22] = false,
	[23] = false, [24] = false,
	[25] = false, [26] = false,
	[27] = false, [28] = true,
	[29] = false, [30] = false,
}

function Omni.GetRowTypeColor(idx)
	if not idx then return rowTypeColors[7]; end
	local ret = rowTypeColors[idx];
	return ret or rowTypeColors[7];
end

function Omni.GetRowType(idx)
	return rowTypes[idx] or "unknown";
end

-- An "impulse" is an event that actually does damage or healing...
local impulseTypes = { [1] = "DamageIn", [2] = "DamageOut", [3] = "HealingIn", [4] = "HealingOut", [7] = "HealingSelf", [8] = "Healing" };
function Omni.GetImpulseType(idx)
	if not idx then return nil; end
	return impulseTypes[idx];
end

-- Determine if a row has a source/target
function Omni.RowHasActors(idx)
	return (idx == 1) or (idx == 2) or (idx == 3) or (idx == 4) or (idx == 7) or (idx == 8) or (idx == 16) or (idx == 21) or (idx == 22);
end

-- If the actor is the SOURCE for this row type, return true.
function Omni.RowActorIsSource(idx)
	return (idx == 1) or (idx == 3) or (idx == 7) or (idx == 18) or (idx == 21);
end

-- If the actor is the TARGET for this row type, return true
function Omni.RowActorIsTarget(idx)
	return (idx == 2) or (idx == 4) or (idx == 16) or (idx == 22);
end


-------------------------------------------------------------------
-- LOOKUP METADATA: EXTENDED INFO
-- (1 = miss, 2 = dodge, 3 = parry, 4 = block, 5 = resist, 6 = crit)
-- (7 = absorb, 8 = crush, 9 = glance)
-------------------------------------------------------------------
local xiTypes = {};
Omni.xiTypes = xiTypes;
local i_xiTypes = {};
Omni.i_xiTypes = i_xiTypes;

function Omni.GetXiType(idx)
	if not idx then return nil; end
	return xiTypes[idx];
end

-- The following types represent "failures"
local failTypes = {
	[1] = "miss", [2] = "dodge", [3] = "parry", [4] = "block",
	[5] = "resist", [7] = "absorb",  [10] = "immune", [11] = "reflect",
	[12] = "evade",
};
function Omni.GetFailType(idx)
	return failTypes[idx];
end

-- Determine if a row is a crit.
function Omni.IsCritRow(row) return (row.e == 6); end

--- Get the miscellaneous string from a log row.
function Omni.GetMiscString(row)
	if not row then return ""; end
	local str = "";
	if row.absorb then str = str .. "A[|cFFFFFF00" .. row.absorb .. "|r] "; end
	if row.resist then str = str .. "R[|cFFFFFF00" .. row.resist .. "|r] "; end
	if row.block then str = str .. "B[|cFFFFFF00" .. row.block .. "|r] "; end
	if row.oh then str = str .. "OH[|cFF00FF00" .. row.oh .. "|r] "; end
	if row.ok then str = str .. "OK[|cFFF00000" .. row.ok .. "|r] "; end
	return str;
end

----------------------------------------------------------------------
-- LOGGING CORE
----------------------------------------------------------------------
-- Adds a row to the Omniscience combat log.
-- y = Type
-- c = Actor (Target of outgoing or source of incoming effects) no more sigg
-- s = Source
-- r = Target
-- sg = Sourceguid
-- rg = Targetguid
-- a = Ability (Name of ability or spell)
-- b = Ability Id or spell Id
-- k = rank spell
-- x = Amount
-- z = overkill or overhealing
-- d = Damage type
-- dot = dot
-- hot = hot
-- di = dist
-- e = Extension type
-- m = Mitigation table
local n, row, MyGUID, ignore;
function Omni.AddLogRow(y, s, r, sg, rg, a, b, x, z, d, dot, hot, dist, e, mt1, mn1, mt2, mn2, mt3, mn3)
	
	-- healsync
	if ((y == 4) or (y == 7)) and sg == MyGUID and (e ~= 6) then 
		logTriggerHealSync:Raise(a, x);
	end
	
	-- meters
	if RDXG.UseOmniMeters and ((y == 1) or (y == 2) or (y == 3) or (y == 4) or (y == 7)) then
		logTriggerMeters:Raise(y, sg, s, rg, r, x, oh);
	end
	
	-- bossmods
	--if ((y == 1) or (y == 5) or (y == 6) or (y == 9) or (y == 10) or (y == 17) or (y == 18) or (y == 21) or (y == 22) or (y == 23)) then
		logTriggerBossmods:Raise(y, s, sg, r, rg, a, b, dot);
	--end
	
	if b and ((y == 22) or (y == 27)) then
		--VFL.print("raise log " .. y .. " spellname " .. a .. " spellid " .. b);
		logTriggerCooldowns:Raise(y, sg, s, rg, r, a, b);
	end
	
	
	-- log only your logs
	ignore = nil;
	if y == 3 and sg == MyGUID then ignore = true; end
	if y == 4 and rg == MyGUID then ignore = true; end
	
	if RDXU.omniSL and (not ignore) and (myRowType[y]) and (sg == MyGUID or rg == MyGUID) then
		n, row = #Omni_Logs, nil;
		-- Recycle a log row if possible.
		if(n >= logCap) then row = table.remove(Omni_Logs, 1); VFL.empty(row); else row = {}; end
		row.t = GetTimeTenths();
		-- For damage out, add overkill
		if (y == 2) then 
			if z and tonumber(z) and (z >= 1) then row.ok = z; end
		-- For healing out, add overhealing
		elseif (y == 4) then
			local tu = GetUnitByName(lower(r));
			if tu and tu:IsCacheValid() then
				if z and tonumber(z) and (z >= 1) then row.oh = z; end
				row.uh = tu:Health(); row.uhm = tu:MaxHealth();
			end
		-- For damage in and healing in types, record local health
		elseif (y == 1) or (y == 3) or (y == 7) then
			row.uh = UnitHealth("player"); row.uhm = UnitHealthMax("player");
			-- oh overhealing
			if (y ~= 1) and z and tonumber(z) and (z >= 1) then row.oh = z; end
		end
		
		--row.k = 0;
		-- For Healing out, damage out, get rank spell if possible
		--if(y == 2) or (y == 4) or (y == 7) then
		--	local tu = GetUnitByName(lower(s));
		--	if tu and tu:IsValid() then
		--		if a and a ~= "" then
		--			row.k = tu.GetLastSpellRank(a) or 0;
		--		end
		--	end
		--end
		
		row.y = tonumber(y);
		row.s = s;
		row.r = r;
		row.sg = sg;
		row.rg = rg;
		row.a = a;
		row.b = b;
		row.x = tonumber(x);
		row.d = tonumber(d);
		row.dot =  tonumber(dot);
		row.hot =  tonumber(hot);
		row.di =  tonumber(dist);
		row.e = tonumber(e);
		if mt1 then row[mt1] = mn1; end
		if mt2 then row[mt2] = mn2; end
		if mt3 then row[mt3] = mn3; end
		
		table.insert(Omni_Logs, row);
		
		if RDXU.omniLW then logTrigger:Raise(Omni_Logs, row); end
	
	end
	
end
local AddLogRow = Omni.AddLogRow;

VFLP.RegisterFunc("RDX Omniscience", "Omni Log", Omni.AddLogRow, true);

-- Affliction table for debuff counting
local afflic = {}
local function Afflicted(abil, stacks)
	if(stacks == 1) then
		AddLogRow(5, nil, nil, abil);
	else
		AddLogRow(5, nil, nil, abil .. " (" .. stacks .. ")");
	end
	afflic[abil] = true;
end
local buff = {};
local function Buffed(abil, stacks)
--	if not trackedBuffs[abil] then return; end
	if stacks == 1 then
		AddLogRow(9, nil, nil, abil);
	else
		AddLogRow(9, nil, nil, abil .. " (" .. stacks .. ")");
	end
	buff[abil] = true;
end
local function Unafflicted(abil)
	if afflic[abil] then
		afflic[abil] = nil;
		AddLogRow(6, nil, nil, abil);
	elseif buff[abil] then
		buff[abil] = nil;
		AddLogRow(10, nil, nil, abil);
	end
end
Omni._Afflicted = Afflicted; Omni._Buffed = Buffed; Omni._Unafflicted = Unafflicted;

-----------------------------------------
-- PARSING CORE
-- The following table is populated by locale-specific parsing code
-- (e.g. Parse_enUS.lua)
-----------------------------------------
Omni.ParseFuncs = {};
RDXEvents:Bind("INIT_DEFERRED", nil, function()
	MyGUID = UnitGUID("player");
end);
