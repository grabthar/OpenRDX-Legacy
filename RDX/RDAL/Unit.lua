-- Unit.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- Unit data structures for RDX6.
--
-- There are two ways of referencing a unit: by explicit name, and by raid number.
-- When a unit is referenced by number, the object created points directly to the
-- underlying WoW unit "raidX" or "partyX." When a unit is referenced by name, a
-- "shadow object" is created which is updated on every ROSTER_UPDATE impulse to
-- point to the appropriate unit.
--
-- Each unit has two types of data, "engine data" and "nominative data." 
-- Nominative data is data associated to the unit by name, and will travel with the 
-- unit as its ID changes.
-- 
-- Engine data is data associated to the unit ID "raidX" or "partyX" and will stick
-- to that ID. (e.g. auras etc.)

local _grey = { r=.5, g=.5, b=.5};

------------------------------------------------
-- SPECIALIZED METATABLES
-- These allow us to "hot-switch" an already existing unit to a new
-- API instantaneously.
------------------------------------------------
RDX.InvalidUnit = {};
RDX.InvalidUnit.__index = RDX.InvalidUnit;

----------------------------------------
-- CORE METATABLE
----------------------------------------
-- Whenever a method is added to RDX.Unit, add it to the other unit metatables as well
RDX.Unit = setmetatable({}, {
	__newindex = function(tbl, key, val)
		rawset(tbl, key, val);
		rawset(RDX.InvalidUnit, key, val);
	end;
});
rawset(RDX.Unit, "__index", RDX.Unit);

function RDX.Unit:new()
	local self = {};
	setmetatable(self, RDX.Unit);
	return self;
end

-------------------------------------------------------------
-- CORE UNIT INFO API
-------------------------------------------------------------
--- Determine if this unit is using the "valid unit" metatable.
RDX.Unit._ValidMetatable = VFL.True;

--- Return TRUE iff this unit is valid. A valid unit is one that's in the raid group
-- and whose vital statistics are accessible to the engine.
-- @return TRUE iff this unit is valid.
function RDX.Unit:IsValid()
	return UnitExists(self.uid);
end

-- Test by sigg, the IsCacheValid return false when the unit is invalidate by the roster
function RDX.Unit:IsCacheValid()
	return true;
end

--- Invalidates the underlying unit. Subsequent calls to IsValid() will return false.
function RDX.Unit:Invalidate()
	self.uid = "none";
	setmetatable(self, RDX.InvalidUnit);
	return true;
end
RDX.Unit.Validate = VFL.Noop;

--- @return The name of this unit, in internal (lowercased) form
function RDX.Unit:GetName()
	return self.name or "unknown";
end

--- @return The proper in-game name of this unit.
function RDX.Unit:GetProperName()
	return UnitName(self.uid) or "Unknown";
end

--- @return The guid of this unit. patch 2.4
function RDX.Unit:GetGuid()
	if self.guid then 
		return self.guid;
	else
		return UnitGUID(self.uid)
	end
end

--- @return The proper in game guid of this unit. patch 2.4
function RDX.Unit:GetProperGuid()
	return UnitGUID(self.uid) or "Unknown";
end

--- @return The WoW unit ID of this unit.
function RDX.Unit:GetUnitID()
	return self.uid or "none";
end

--- @return TRUE iff this unit is in the data range of the WoW engine.
function RDX.Unit:IsInDataRange()
	return UnitIsVisible(self.uid);
end

--- @return TRUE iff this unit is in the data range of the WoW engine.
function RDX.Unit:IsInRange()
	return UnitInRange(self.uid);
end

--- @return the fundamental numeric ID of the unit.
function RDX.Unit:GetNumber()
	return self.nid or 0;
end

--- @return Class information about the unit
function RDX.Unit:GetClass()
	local ret = UnitClass(self.uid or "none") or "None";
	return ret; 
end
function RDX.Unit:GetClassMnemonic()
	local _,ret = UnitClass(self.uid or "none");
	return ret or "NONE";
end
function RDX.Unit:GetClassID()
	return 0;
end
function RDX.Unit:GetClassColor()
	local _,mnem = UnitClass(self.uid or "none");
	if mnem then
		return RAID_CLASS_COLORS[mnem] or _grey;
	else
		return _grey;
	end
end

--- @return TRUE iff this unit is a pet
function RDX.Unit:IsPet()
	return nil;
end

--- @return The owner unit of this unit, if it is a pet. NIL if cannot be resolved.
function RDX.Unit:GetOwnerUnit()
	local n = self.nid;
	if n and n > 40 and n < 81 then
		return RDX.GetUnitByNumber(n-40);
	end
end

--- @return TRUE iff this unit is a arenaUnit
function RDX.Unit:IsArenaUnit()
	return nil;
end

--- @return TRUE iff this unit is an Assistant Leader or Leader of the raid group.
function RDX.Unit:IsLeader()
	return nil;
end

--- Get the leader level of the unit, as per the convention of GetRaidRosterInfo.
function RDX.Unit:GetLeaderLevel() return 0; end

--- Get the group number of this unit, as returned by GetRaidRosterInfo.
function RDX.Unit:GetGroup() return 0; end

--- Get the group member of this unit.
function RDX.Unit:GetMemberGroupId() return 0; end

--- @return TRUE iff this unit is the same unit as the given RDX unit.
function RDX.Unit:IsSameUnit(u2)
	return UnitIsUnit(self.uid, u2.uid);
end

-------------------------------------------
-- NOMINATIVE/INDEXICAL TRANSFORMS
-------------------------------------------
--- @return A unit reference equivalent to this unit, but nominative in scope.
function RDX.Unit:GetNominativeUnit()
	return self;
end
function RDX.Unit:IsNominativeUnit()
	return nil;
end

--- @return A unit reference equivalent to this unit, but indexical in scope.
function RDX.Unit:GetIndexedUnit()
	return self;
end
function RDX.Unit:IsIndexedUnit()
	return nil;
end

--- @return The nominative field structure of the unit or NIL if none.
function RDX.Unit:GetNField(fld)
	return nil;
end
--- @return The engine field structore of the unit or NIL if none.
function RDX.Unit:GetEField(fld)
	return nil
end

------------------------------------------------------------
-- UNIT HP DATA.
------------------------------------------------------------
--- @return The current HP of the unit as reported by the WoW engine.
function RDX.Unit:Health()
	if self:IsFeigned() then return 1; end
	return UnitHealth(self.uid or "none");
end
--- @return The max HP of the unit as reported by the WoW engine.
function RDX.Unit:MaxHealth()
	if self:IsFeigned() then return 1; end
	return UnitHealthMax(self.uid or "none");
end
--- @return The fractional HP of the unit as reported by the WoW engine.
function RDX.Unit:FracHealth()
	if self:IsFeigned() then return 1; end
	local uid = self.uid or "none";
	local a,b = UnitHealth(uid),UnitHealthMax(uid);
	if(b<1) then return 0; end
	a=a/b;
	if a<0 then return 0 elseif a>1 then return 1; else return a; end
end
--- @return The number of missing HP of the unit as reported by the WoW engine.
function RDX.Unit:MissingHealth()
	if self:IsFeigned() then return 0; end
	local uid = self.uid or "none";
	return UnitHealthMax(uid) - UnitHealth(uid);
end
--- @return The fraction of the unit's missing HP as reported by the WoW engine.
function RDX.Unit:FracMissingHealth()
	if self:IsFeigned() then return 0; end
	local uid = self.uid or "none";
	local a,b = UnitHealth(uid),UnitHealthMax(uid);
	if(b<1) then return 0; end
	a=(b-a)/b;
	if a<0 then return 0; elseif a>1 then return 1; else return a; end
end
--- @return TRUE iff the unit is dead.
function RDX.Unit:IsDead()
	return (not self:IsFeigned()) and (UnitIsDeadOrGhost(self.uid));
end
--- @return TRUE iff the unit is feigning death.
function RDX.Unit:IsFeigned()
	return nil;
end
--- @return TRUE iff the unit is online
function RDX.Unit:IsOnline()
	return UnitIsConnected(self.uid or "none");
end
--- @return TRUE iff the unit is incapacitated (offline, dead, feigned)
function RDX.Unit:IsIncapacitated()
	local uid = self.uid or "none";
	if (self:IsFeigned()) or (UnitIsDeadOrGhost(uid)) or (not UnitIsConnected(uid)) then return true; else return nil; end
end

---------------------------------------------------------------
-- UNIT MP DATA.
---------------------------------------------------------------
--- @return the WoW Powertype of the unit ("MANA" 0, "RAGE" 1, "ENERGY" 2, "FOCUS" 3)

function RDX.Unit:PowerType()
	return UnitPowerType(self.uid or "none");
end
--[[
--- @return the current Mana of the unit.
function RDX.Unit:Mana()
	return UnitMana(self.uid or "none");
end
--- @return the max Mana of the unit.
function RDX.Unit:MaxMana()
	return UnitManaMax(self.uid or "none");
end
--- @return the fractional Mana of the unit.
function RDX.Unit:FracMana()
	local uid = self.uid or "none";
	local a,b = UnitMana(uid),UnitManaMax(uid);
	if(b<1) then return 0; end
	a=a/b;
	if a<0 then return 0; elseif a>1 then return 1; else return a; end
end
--- @return the missing Mana of the unit.
function RDX.Unit:MissingMana()
	local uid = self.uid or "none";
	return UnitManaMax(uid) - UnitMana(uid);
end
--- @return the fraction of missing Mana of the unit.
function RDX.Unit:FracMissingMana()
	local uid = self.uid or "none";
	local a,b = UnitMana(uid),UnitManaMax(uid);
	if(b<1) then return 0; end
	a = (b-a)/b;
	if a<0 then return 0; elseif a>1 then return 1; else return a; end
end
]]
---------------------------------------------------------------
-- UNIT Power DATA.3.0
---------------------------------------------------------------
--- @return the current Power of the unit.
function RDX.Unit:Power()
	return UnitPower(self.uid or "none");
end
--- @return the max Power of the unit.
function RDX.Unit:MaxPower()
	return UnitPowerMax(self.uid or "none");
end
--- @return the fractional Power of the unit.
function RDX.Unit:FracPower()
	local uid = self.uid or "none";
	local a,b = UnitPower(uid), UnitPowerMax(uid);
	if(b<1) then return 0; end
	a=a/b;
	if a<0 then return 0; elseif a>1 then return 1; else return a; end
end
--- @return the missing Power of the unit.
function RDX.Unit:MissingPower()
	local uid = self.uid or "none";
	return UnitPowerMax(self.uid) - UnitPower(self.uid);
end
--- @return the fraction of missing Power of the unit.
function RDX.Unit:FracMissingPower()
	local uid = self.uid or "none";
	local a,b = UnitPower(self.uid), UnitPowerMax(self.uid);
	if(b<1) then return 0; end
	a = (b-a)/b;
	if a<0 then return 0; elseif a>1 then return 1; else return a; end
end

------------------------------------------------
-- INVALID UNIT API
------------------------------------------------
RDX.InvalidUnit._ValidMetatable = VFL.False;
RDX.InvalidUnit.IsValid = VFL.False;
RDX.InvalidUnit.IsCacheValid = VFL.False;
RDX.InvalidUnit.Invalidate = VFL.Noop;
function RDX.InvalidUnit:Validate()
	setmetatable(self, RDX.Unit);
	return true;
end;
function RDX.InvalidUnit:GetName() return "unknown"; end
RDX.InvalidUnit.IsInDataRange = VFL.Nil;
RDX.InvalidUnit.GetNumber = VFL.One;
RDX.InvalidUnit.GetOwnerUnit = VFL.Nil;
RDX.InvalidUnit.IsSameUnit = VFL.False;

RDX.InvalidUnit.Health = VFL.Zero;
RDX.InvalidUnit.MaxHealth = VFL.One;
RDX.InvalidUnit.FracHealth = VFL.Zero;
RDX.InvalidUnit.MissingHealth = VFL.Zero;
RDX.InvalidUnit.FracMissingHealth = VFL.Zero;
RDX.InvalidUnit.IsDead = VFL.False;
RDX.InvalidUnit.IsFeigned = VFL.False;
RDX.InvalidUnit.IsOnline = VFL.False;
RDX.InvalidUnit.IsIncapacitated = VFL.True;

function RDX.InvalidUnit:PowerType() return "MANA"; end
--RDX.InvalidUnit.Mana = VFL.Zero;
--RDX.InvalidUnit.MaxMana = VFL.Zero;
--RDX.InvalidUnit.FracMana = VFL.One;
--RDX.InvalidUnit.MissingMana = VFL.Zero;
--RDX.InvalidUnit.FracMissingMana = VFL.Zero;
RDX.InvalidUnit.Power = VFL.Zero;
RDX.InvalidUnit.MaxPower = VFL.Zero;
RDX.InvalidUnit.FracPower = VFL.One;
RDX.InvalidUnit.MissingPower = VFL.Zero;
RDX.InvalidUnit.FracMissingPower = VFL.Zero;

------------------------------------------------
-- TEMPORARY UNIT
-- This unit is used when no internal unit matches, but the Unit API is required
-- nevertheless. (eg. assist windows and the like)
------------------------------------------------
RDX.tempUnit = RDX.Unit:new();
RDX.tempUnit.nid = 0;
RDX.tempUnit.name = "unknown";
RDX.tempUnit.uid = "none";
RDX.tempUnit.guid = "unknown";
RDX.tempUnit.class = "unknown";
RDX.tempUnit.classec = "unknown";

RDX.tempUnit.Invalidate = VFL.Noop;
RDX.tempUnit.Validate = VFL.Noop;

------------------------------------------------
-- Raw unit data accessors (Blizz UID -> data)
------------------------------------------------
function RDX.RawFracHealth(uid)
	local mh = UnitHealthMax(uid);
	if(mh < 1) then mh = 1; end
	return VFL.clamp(UnitHealth(uid)/mh, 0, 1);
end

--function RDX.RawFracMana(uid)
--	local mh = UnitManaMax(uid);
--	if(mh < 1) then mh = 1; end
--	return VFL.clamp(UnitMana(uid)/mh, 0, 1);
--end

function RDX.RawFracPower(uid)
	local mh = UnitPowerMax(uid);
	if(mh < 1) then mh = 1; end
	return VFL.clamp(UnitPower(uid)/mh, 0, 1);
end
