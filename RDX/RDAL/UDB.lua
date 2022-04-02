-- UDB.lua
-- RDX
-- (C)2006 Bill Johnson
--
-- The master unit database.
--
-- The primary responsibilities of the Unit Database are:
-- * Enforce the party/raid abstraction.
-- * Provide events for when people are added/removed from the group.
-- * Map units to ndata/edata.
-- * Promote WoW events to RDX events, intelligently up-converting unit references.
--

-- Imports
local tempty, strlower, strmatch, strgsub = VFL.empty, string.lower, string.match, string.gsub;

VFLP.RegisterCategory(i18n("RDX: UnitDB"));

------------------------------------------------------------------------------
-- Performance enhancements - precache commonly used signals
------------------------------------------------------------------------------
local _sig_rdx_debuff_star = RDXEvents:LockSignal("UNIT_DEBUFF_*");
local _sig_rdx_buff_star = RDXEvents:LockSignal("UNIT_BUFF_*");
local _sig_rdx_mybuff_star = RDXEvents:LockSignal("UNIT_MYBUFF_*");
local _sig_rdx_unit_health = RDXEvents:LockSignal("UNIT_HEALTH");
--local _sig_rdx_unit_mana = RDXEvents:LockSignal("UNIT_MANA");
-- add 3.0
local _sig_rdx_unit_power = RDXEvents:LockSignal("UNIT_POWER");
local _sig_rdx_unit_aura = RDXEvents:LockSignal("UNIT_AURA");
local _sig_rdx_unit_target = RDXEvents:LockSignal("UNIT_TARGET");
local _sig_rdx_unit_focus = RDXEvents:LockSignal("UNIT_FOCUS");
local _sig_rdx_unit_flags = RDXEvents:LockSignal("UNIT_FLAGS");
local _sig_rdx_unit_range = RDXEvents:LockSignal("UNIT_RANGED");
local _sig_rdx_unit_portrait_update = RDXEvents:LockSignal("UNIT_PORTRAIT_UPDATE");
local _sig_rdx_unit_xp_update = RDXEvents:LockSignal("UNIT_XP_UPDATE");
local _sig_rdx_unit_faction = RDXEvents:LockSignal("UNIT_FACTION");

local _sig_rdx_unit_entering_world = RDXEvents:LockSignal("UNIT_ENTERING_WORLD");
local _sig_rdx_unit_totem_update = RDXEvents:LockSignal("UNIT_TOTEM_UPDATE");

local _sig_rdx_unit_combo_update = RDXEvents:LockSignal("UNIT_COMBO_POINTS");

local _sig_rdx_unit_rune_power_update = RDXEvents:LockSignal("UNIT_RUNE_POWER_UPDATE");
local _sig_rdx_unit_rune_type_update = RDXEvents:LockSignal("UNIT_RUNE_TYPE_UPDATE");

local _sig_rdx_unit_buffweapon_update = RDXEvents:LockSignal("UNIT_BUFFWEAPON_UPDATE");

local _sig_rdx_unit_threat_situation_update = RDXEvents:LockSignal("UNIT_THREAT_SITUATION_UPDATE");

------------------------------------------------------------------------------
-- UNIT ID MAPPINGS/UNIT COUNTING
------------------------------------------------------------------------------
RDX.NUM_UNITS = 90; -- Number of internal unit structures.
local NUM_UNITS = RDX.NUM_UNITS;

----------- Party unit maps
-- player, party1..party4, pet, partypet1..partypet4
local party_id2num = {};
party_id2num["player"] = 1;
for i=1,4 do party_id2num["party" .. i] = i + 1; end
party_id2num["pet"] = 41;
for i=1,4 do party_id2num["partypet" .. i] = i + 41; end

for i=1,5 do party_id2num["arena" .. i] = 80 + i; end
for i=1,5 do party_id2num["arenapet" .. i] = 85 + i; end


local party_num2id = {};
party_num2id[1] = "player";
for i=1,4 do party_num2id[i+1] = "party" .. i; end
for i=6,40 do party_num2id[i] = false; end
party_num2id[41] = "pet";
for i=1,4 do party_num2id[41+i] = "partypet" .. i; end

for i=1,5 do party_num2id[80 + i] = "arena" .. i; end
for i=1,5 do party_num2id[85 + i] = "arenapet" .. i; end

----------- Raid unit maps
-- raid1..raid40, raidpet1..raidpet40
local raid_id2num = {};
for i=1,40 do raid_id2num["raid" .. i] = i; end
for i=1,40 do raid_id2num["raidpet" .. i] = 40 + i; end
for i=1,5 do raid_id2num["arena" .. i] = 80 + i; end
for i=1,5 do raid_id2num["arenapet" .. i] = 85 + i; end

local raid_num2id = {};
for i=1,40 do raid_num2id[i] = "raid" .. i; end
for i=1,40 do raid_num2id[40 + i] = "raidpet" .. i; end
for i=1,5 do raid_num2id[80 + i] = "arena" .. i; end
for i=1,5 do raid_num2id[85 + i] = "arenapet" .. i; end

----------- Arena unit maps
--local arena_id2num = {};
--for i=1,5 do arena_id2num["arena" .. i] = 80 + i; end
--for i=1,5 do arena_id2num["arenapet" .. i] = 85 + i; end

--local arena_num2id = {};
--for i=1,5 do arena_num2id[80 + i] = "arena" .. i; end
--for i=1,5 do arena_num2id[85 + i] = "arenapet" .. i; end

--------------------------------
local id2num, num2id = {}, {};

local function SetRaidIDDatabase()
	id2num = raid_id2num; num2id = raid_num2id;
end

local function SetPartyIDDatabase()
	id2num = party_id2num; num2id = party_num2id;
end

function RDX.GetNumberToUIDMap()
	return num2id;
end

function RDX.GetUIDToNumberMap()
	return id2num;
end

function RDX.NumberToUID(unum)
	return num2id[unum];
end

function RDX.UIDToNumber(uid)
	return id2num[uid] or 0;
end

-- Internal: raid or party status and member count
local function party_GetNumUnits()
	return GetNumPartyMembers() + 1;
end

local function raid_GetNumUnits()
	return GetNumRaidMembers();
end

--- @return The total number of units in the RDX unit database.
RDX.GetNumUnits = party_GetNumUnits;

local isRaid, isSolo = false, true;

--- Return TRUE iff we are currently in a raid group, nil otherwise.
function RDX.InRaid()	return isRaid; end
--- Return TRUE iff we are solo, nil otherwise.
function RDX.IsSolo() return isSolo; end
local IsSolo = RDX.IsSolo;

-- Arena

function RDX.ArenaNumberToUID(unum)
	return arena_num2id[unum];
end

function RDX.ArenaUIDToNumber(uid)
	return arena_id2num[uid] or 0;
end

-------------------------------------------------------------------
-- UNIT AURA METADATA
-------------------------------------------------------------------
-- Local override for debuff categorization.
-- Example: debuffCategoryOverride[i18n("arcane blast")] = "@other";
local debuffCategoryOverride = {};

-- The aura metadata caches.
local function GenMetadataCacheFuncs(ncache)
	local Set = function(texture, name, category, properName, properCategory, descr)
		if not name then return; end
		local x = { name = name, texture = texture, properName = properName, category = category, properCategory = properCategory, descr = descr };
		ncache[name] = x;
		return x;
	end

	local NGet = function(name) 
		return ncache[name]; 
	end

	return Set, NGet;
end

local buffCacheN = {};
local debuffCacheN = {};

local buffcache_set, buffcache_nget = GenMetadataCacheFuncs(buffCacheN);
local debuffcache_set, debuffcache_nget = GenMetadataCacheFuncs(debuffCacheN);

local name, lname, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable, testUnit, info, category;

local function UnitDebuffCache(TmpUnit, i)
	return TmpUnit:GetDeBuffCache(i);
end

-- INTERNAL: Get information about a debuff from a unit.
local function LoadDebuffFromUnit(uid, i, castable, cache)
	-- looking for unit in database RDX
	if cache then
		testUnit = RDX._ReallyFastProject(uid);
		if (not testUnit) then cache = false; end
	end
	
	if cache then
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitDebuffCache(testUnit, i);
	else
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitDebuff(uid, i, castable);
	end
	
	if (not name) then return nil; end
	lname = strlower(name);
	if expirationTime and expirationTime > 0 then timeLeft = expirationTime - GetTime(); end
	if (not count) or (count < 1) then count = 1; end
	
	-- Query cache; early out if we already have the infos.
	info = debuffcache_nget(lname);
	if info then
		return true, name, lname, info.category, info, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable;
	end
	-- Munge category
	category = debuffType;
	if debuffCategoryOverride[lname] then
		category = debuffCategoryOverride[lname];
	elseif category then
		category = "@" .. strlower(category);
	else
		category = "@other";
	end
	-- Stuff tooltip
	VFLTipTextLeft1:SetText(nil); VFLTipTextRight1:SetText(nil);
	VFLTipTextLeft2:SetText(nil);
	VFLTip:SetUnitDebuff(uid, i);
	-- Add to cache
	info = debuffcache_set(icon, lname, category, name, VFLTipTextRight1:GetText(), VFLTipTextLeft2:GetText());
	return true, name, lname, category, info, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable;
end
RDX.LoadDebuffFromUnit = LoadDebuffFromUnit;
--VFLP.RegisterFunc(i18n("RDX: UnitDB"), "LoadDebuffFromUnit", LoadDebuffFromUnit, true);
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "UnitDebuffCache", UnitDebuffCache, true);

-- INTERNAL: Get information about a buff from a unit.
local function UnitBuffCache(TmpUnit, i)
	return TmpUnit:GetBuffCache(i);
end

local function LoadBuffFromUnit(uid, i, castable, cache)
	-- looking for unit in database RDX
	if cache then
		testUnit = RDX._ReallyFastProject(uid);
		if (not testUnit) then cache = false; end
	end
	
	if cache then
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuffCache(testUnit, i);
	else
		name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff(uid, i, castable);
	end
	
	if (not name) then return nil; end
	lname = strlower(name);
	if expirationTime and expirationTime > 0 then timeLeft = expirationTime - GetTime(); end
	if (not count) or (count < 1) then count = 1; end
	
	-- Attempt to get buff data from the cache
	info = buffcache_nget(lname);
	if info then
		return true, name, lname, info.category, info, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable;
	else
		-- Stuff tooltip
		VFLTipTextLeft1:SetText(nil); VFLTipTextRight1:SetText(nil);
		VFLTipTextLeft2:SetText(nil);
		VFLTip:SetUnitBuff(uid, i);
		-- Write to cache and return
		info = buffcache_set(icon, lname, "@other", name, nil, VFLTipTextLeft2:GetText());
		return true, name, lname, "@other", info, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable;
	end
end
RDX.LoadBuffFromUnit = LoadBuffFromUnit;
--VFLP.RegisterFunc(i18n("RDX: UnitDB"), "LoadBuffFromUnit", LoadBuffFromUnit, true);
--VFLP.RegisterFunc(i18n("RDX: UnitDB"), "UnitBuff", UnitBuff, true);
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "UnitBuffCache", UnitBuffCache, true);

-- INTERNAL: Get information about weapons buff.
-- "MainHandSlot"
-- "SecondaryHandSlot"
local function scanHand(hand)
	VFLTip:SetOwner(UIParent, "ANCHOR_NONE");
	VFLTip:ClearLines();
	local idslot = GetInventorySlotInfo(hand);
	VFLTip:SetInventoryItem("player", idslot);
	local mytext, strfound = nil, nil;
	local buffname, buffrank, bufftex;
	for i = 1, VFLTip:NumLines() do
		mytext = getglobal("VFLTipTextLeft" .. i);
		strfound = strmatch(mytext:GetText(), "^(.*) %(%d+ [^%)]+%)$");
		if strfound then break; end
	end
	if strfound then
		strfound = strgsub(strfound, " %(%d+ [^%)]+%)", "");
		buffname, buffrank = strmatch(strfound, "(.*) (%d*)$");
		if not buffname then
			buffname, buffrank = strmatch(strfound, "(.*) ([IVXLMCD]*)$");
		end
		if not buffname then
			buffname, buffrank = strmatch(strfound, "(.*)(%d)");
			-- specific fucking french language langue de feu
			if buffname then
				local a = string.len(buffname);
				buffname = string.sub(buffname, 1, a - 2);
			else 
				buffname = strfound;
			end
			--if buffname then VFL.print(buffname); VFL.print(a); end
		end
		if not buffname then
			buffname = "unknown parse";
		end
		bufftex = GetInventoryItemTexture("player", idslot);
	end
	VFLTip:Hide();
	return buffname, buffrank, bufftex;
end;

local function LoadWeaponsBuff()
	local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo();
	--if (not hasMainHandEnchant) and (not hasOffHandEnchant) then return nil; end
	local mainHandBuffName, mainHandBuffRank, mainHandBuffStart, mainHandBuffDur, mainHandTex, mainHandBuffTex, offHandBuffName, offHandBuffRank, offHandBuffStart, offHandBuffDur, offHandTex, offHandBuffTex;
	if hasMainHandEnchant then
		mainHandBuffName, mainHandBuffRank, mainHandTex = scanHand("MainHandSlot");
		mainHandBuffDur, mainHandBuffTex = Logistics.getBuffWeaponInfo(mainHandBuffName);
		if mainHandBuffDur > 0 then
			mainHandBuffStart = GetTime() - (mainHandBuffDur - mainHandExpiration / 1000);
		else mainHandBuffStart = 0; end
	else
		mainHandBuffStart = 0;
		mainHandBuffDur = 0;
	end
	if hasOffHandEnchant then
		offHandBuffName, offHandBuffRank, offHandTex = scanHand("SecondaryHandSlot");
		offHandBuffDur, offHandBuffTex = Logistics.getBuffWeaponInfo(offHandBuffName);
		if offHandBuffDur > 0 then
			offHandBuffStart = GetTime() - (offHandBuffDur - offHandExpiration / 1000);
		else offHandBuffStart = 0; end
	else
		offHandBuffStart = 0;
		offHandBuffDur = 0;
	end
	return hasMainHandEnchant, mainHandBuffName, mainHandBuffRank, mainHandCharges, mainHandBuffStart, mainHandBuffDur, mainHandTex, mainHandBuffTex, hasOffHandEnchant, offHandBuffName, offHandBuffRank, offHandCharges, offHandBuffStart, offHandBuffDur, offHandTex, offHandBuffTex;
end
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "LoadWeaponsBuff", LoadWeaponsBuff, true);

RDX.LoadWeaponsBuff = LoadWeaponsBuff;

-- Debuff categories
RDXEvents:Bind("INIT_PRELOAD", nil, function()
	debuffCacheN["@curse"] = {	
		name = "@curse",
		texture = "Interface\\InventoryItems\\WoWUnknownItem01.blp",
		properName = i18n("(Any Curse)"),
		descr = i18n("Matches any curse."),
		set = RDX.GetDebuffSet("@curse"), isInvisible = true,
	};

	debuffCacheN["@magic"] = {
		name = "@magic",
		texture = "Interface\\InventoryItems\\WoWUnknownItem01.blp",
		properName = i18n("(Any Magic)"),
		descr = i18n("Matches any magic debuff."),
		set = RDX.GetDebuffSet("@magic"), isInvisible = true,
	};

	debuffCacheN["@poison"] = {
		name = "@poison",
		texture = "Interface\\InventoryItems\\WoWUnknownItem01.blp",
		properName = i18n("(Any Poison)"),
		descr = i18n("Matches any poison debuff."),
		set = RDX.GetDebuffSet("@poison"), isInvisible = true,
	};
	
	debuffCacheN["@disease"] = {
		name = "@disease",
		texture = "Interface\\InventoryItems\\WoWUnknownItem01.blp",
		properName = i18n("(Any Disease)"),
		descr = i18n("Matches any disease debuff."),
		set = RDX.GetDebuffSet("@disease"), isInvisible = true,
	};

	debuffCacheN["@other"] = {
		name = "@other",
		texture = "Interface\\InventoryItems\\WoWUnknownItem01.blp",
		properName = i18n("(Any Other)"),
		descr = i18n("Matches any debuff that is not disease, poison, magic, or curse."),
		set = RDX.GetDebuffSet("@other"), isInvisible = true,
	};
end);


------------- Metadata API --------------

--- @return A table containing information on the buff with the given texture, if seen this session.
-- Nil otherwise.
RDX.GetBuffInfoByName = buffcache_nget;
RDX.GetDebuffInfoByName = debuffcache_nget;

function RDX._GetBuffCache()
	return buffCacheN;
end

function RDX._GetDebuffCache()
	return debuffCacheN;
end

--- Reproduce an aura tooltip from an entry in an aura cache.
function RDX.ShowAuraTooltip(meta, frame, anchor)
	GameTooltip:SetOwner(frame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", frame, anchor);
	GameTooltip:ClearLines();
	GameTooltip:AddDoubleLine(meta.properName, meta.properCategory);
	GameTooltip:AddLine(meta.descr, 1, 1, 1, 1, true);
	GameTooltip:Show();
end

-------------------------------------------------------------------
-- EDATA
-- Edata = engine data = data that follows a unit around by ID number.
-------------------------------------------------------------------

-- Temporary touched matrix for edata
local _touched, _cattouched = {}, {};

-- Internal: Create a new engine data structure for the given unit.
local function NewEData(idx)
	local self = {};
	
	-- Custom fields
	local _efields = {};
	
	-- Use to send signal to set
	-- Buff/debuff lists
	local _buffsset, _debuffsset = {}, {};
	
	-- category lists
	local _debuffscat = {};
	
	-- Use by auracache
	local _buffscache, _debuffscache = {}, {};
	
	-- Store last spell and rank from UNIT_SPELLCAST_SENT
	local _spellrank = {};
	
	-- Fixed fields
	local group = 0;

	self.SetGroup = function(x, g) group = g; end
	self.GetGroup = function() return group; end
	
	local gid = 0;
	self.SetMemberGroupId = function(x, g) gid = g; end
	self.GetMemberGroupId = function() return gid; end

	self.IsPet = VFL.Noop;
	if(idx > 0) and (idx <= 40) then
		self.IsPet = VFL.Nil;
	elseif(idx > 40) and (idx <= 80) then
		self.IsPet = VFL.True;
	end
	
	self.IsArenaUnit = VFL.Noop;
	if(idx > 0) and (idx <= 80) then
		self.IsArenaUnit = VFL.Nil;
	elseif(idx > 80) and (idx <= 85) then
		self.IsArenaUnit = VFL.True;
	end
	
	local auraflag;

	self.HasDebuff = function(x, debuff)
				auraflag = false;
				for i=1,#_debuffscache do
					if _debuffscache[i].name == debuff then auraflag = true; end
				end
				if _debuffscat[debuff] then auraflag = true; end
				return auraflag;
			end
 	self.Debuffs = function() return _debuffscache; end

	self.HasBuff = function(x, buff)
				auraflag = nil;
				for i=1,#_buffscache do
					if _buffscache[i].name == buff then auraflag = true; end
				end
				return auraflag;
			end
	self.Buffs = function() return _buffscache; end
	
	self.HasMyBuff = function(x, mybuff) 
				auraflag = nil;
				for i=1,#_buffscache do
					if (_buffscache[i].name == mybuff) and (_buffscache[i].caster == "player") then auraflag = true; end
				end
				return auraflag;
			end
	self.GetDeBuffCache = function(x, i)
		local t = _debuffscache[i];
		if t and t.name then return t.name, t.rank, t.icon, t.count, t.debuffType, t.duration, t.expirationTime, t.caster, t.isStealable;
		else return nil, nil, nil, nil, nil, nil, nil, nil, nil;
		end
	end
	
	self.GetBuffCache = function(x, i)
		local t = _buffscache[i];
		if t and t.name then return t.name, t.rank, t.icon, t.count, t.debuffType, t.duration, t.expirationTime, t.caster, t.isStealable;
		else return nil, nil, nil, nil, nil, nil, nil, nil, nil;
		end
	end
	
	-- Process auras
	
	local uid, debuffchangeflag, buffchangeflag, i, name, lname, category, info, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable, found;
	
	self.ProcessAuras = function(rdxunit)
		debuffchangeflag, buffchangeflag, found = nil, nil, nil;
		uid = num2id[idx]; 
		tempty(_cattouched);

		RDX.BeginEventBatch();

		------------------ DEBUFFS
		-- Step 1 clear the cache
		for i=1, #_debuffscache do
			if _debuffscache[i].name then _debuffscache[i].name = nil; end
		end
		
		-- Step 2 feed the cache
		i = 1;
		while true do
			cont, name, _, category, info, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable = LoadDebuffFromUnit(uid, i, nil, false);
			if not cont then break; end
			
			if not _debuffscache[i] then _debuffscache[i] = {}; end
			
			_debuffscache[i].name = name;
			_debuffscache[i].rank = rank;
			_debuffscache[i].icon = icon;
			_debuffscache[i].count = count;
			_debuffscache[i].debuffType = debuffType;
			_debuffscache[i].duration = duration;
			_debuffscache[i].expirationTime = expirationTime;
			_debuffscache[i].caster = caster;
			_debuffscache[i].isStealable = isStealable;
			
			_cattouched[category] = true;
			
			-- Move on to next debuff
			i = i + 1;
		end
		
		-- Step 3
		-- parse the cache vs set for new debuff 
		for i=1, #_debuffscache do
			if _debuffscache[i].name then
				found = nil;
				for j=1, #_debuffsset do
					--if (_debuffsset[j].name == _debuffscache[i].name) and (_debuffsset[j].count == _debuffscache[i].count) and (_debuffsset[j].caster == _debuffscache[i].caster) and (_debuffsset[j].expirationTime == _debuffscache[i].expirationTime) then found = true; end
					if (_debuffsset[j].name == _debuffscache[i].name) and (_debuffsset[j].count == _debuffscache[i].count) and (_debuffsset[j].caster == _debuffscache[i].caster) then found = true; end
				end
				if not found then
					RDXEvents:Dispatch("UNIT_DEBUFF_" .. _debuffscache[i].name, rdxunit, _debuffscache[i].name, _debuffscache[i].count);
					--if rdxunit.name then VFL.print("|cFF00FF00sig +DEBUFF:|r" .. _debuffscache[i].name .. " " .. rdxunit.name); end
					debuffchangeflag = true;
				end
			end
		end
		
		-- Step 4
		-- parse the set vs cache for missing debuff
		for i=1, #_debuffsset do
			if _debuffsset[i].name then
				found = nil;
				for j=1, #_debuffscache do
					--if (_debuffsset[i].name == _debuffscache[j].name) and (_debuffsset[i].count == _debuffscache[j].count) and (_debuffsset[i].caster == _debuffscache[j].caster) and (_debuffsset[i].expirationTime == _debuffscache[j].expirationTime) then found = true; end
					if (_debuffsset[i].name == _debuffscache[j].name) and (_debuffsset[i].count <= _debuffscache[j].count) and (_debuffsset[i].caster == _debuffscache[j].caster) then found = true; end
				end
				if not found then
					RDXEvents:Dispatch("UNIT_DEBUFF_" .. _debuffsset[i].name, rdxunit, _debuffsset[i].name, 0);
					--if rdxunit.name then VFL.print("|cFF00FF00sig -DEBUFF:|r" .. _debuffsset[i].name .. " " .. rdxunit.name); end
					debuffchangeflag = true;
				end
			end
		end
		
		-- Step 5
		-- clear the set
		for i=1, #_debuffsset do
			_debuffsset[i].name = nil;
		end
		
		-- Step 6
		-- Update the set
		for i=1, #_debuffscache do
			if not _debuffsset[i] then _debuffsset[i] = {}; end
			_debuffsset[i].name = _debuffscache[i].name;
			_debuffsset[i].count = _debuffscache[i].count;
			_debuffsset[i].caster = _debuffscache[i].caster;
			_debuffsset[i].expirationTime = _debuffscache[i].expirationTime;
		end
		
		-- Mark category info
		for k,_ in pairs(_cattouched) do
			if _cattouched[k] and (not _debuffscat[k]) then
				_debuffscat[k] = true;
				RDXEvents:Dispatch("UNIT_DEBUFF_" .. k, rdxunit, k, 1);
				--VFL.print("sig +DEBUFF " .. k);
			end
		end
		
		for k,_ in pairs(_debuffscat) do
			if (not _cattouched[k]) and _debuffscat[k] then
				_debuffscat[k] = nil;
				RDXEvents:Dispatch("UNIT_DEBUFF_" .. k, rdxunit, k, 0);
				--VFL.print("sig -DEBUFF " .. k);
			end
		end
		
		------------------------- BUFFS
		
		-- Step 1 clear the cache
		for i=1, #_buffscache do
			if _buffscache[i].name then _buffscache[i].name = nil; end
		end
		
		-- Step 2 feed the cache
		i = 1;
		while true do
			cont, name, _, category, info, rank, icon, count, debuffType, duration, expirationTime, timeLeft, caster, isStealable = LoadBuffFromUnit(uid, i, nil, false);
			if not cont then break; end
			
			if not _buffscache[i] then _buffscache[i] = {}; end
			
			_buffscache[i].name = name;
			_buffscache[i].rank = rank;
			_buffscache[i].icon = icon;
			_buffscache[i].count = count;
			_buffscache[i].debuffType = debuffType;
			_buffscache[i].duration = duration;
			_buffscache[i].expirationTime = expirationTime;
			_buffscache[i].caster = caster;
			_buffscache[i].isStealable = isStealable;
			
			-- Move on to next debuff
			i = i + 1;
		end
		
		-- Step 3
		-- parse the cache vs set for new buff 
		for i=1, #_buffscache do
			if _buffscache[i].name then
				found = nil;
				for j=1, #_buffsset do
					--if (_buffsset[j].name == _buffscache[i].name) and (_buffsset[j].count == _buffscache[i].count) and (_buffsset[j].caster == _buffscache[i].caster) and (_buffsset[j].expirationTime == _buffscache[i].expirationTime) then found = true; end
					if (_buffsset[j].name == _buffscache[i].name) and (_buffsset[j].count == _buffscache[i].count) and (_buffsset[j].caster == _buffscache[i].caster) then found = true; end
				end
				if not found then
					RDXEvents:Dispatch("UNIT_BUFF_" .. _buffscache[i].name, rdxunit, _buffscache[i].name, _buffscache[i].count);
					--if rdxunit.name then VFL.print("|cFF00FF00sig +BUFF:|r" .. _buffscache[i].name .. " " .. rdxunit.name); end
					buffchangeflag = true;
					if _buffscache[i].caster == "player" then 
						RDXEvents:Dispatch("UNIT_MYBUFF_" .. _buffscache[i].name, rdxunit, _buffscache[i].name, _buffscache[i].count); 
						--VFL.print("sig +MYBUFF " .. _buffscache[i].name); 
					end
				end
			end
		end
		
		-- Step 4
		-- parse the set vs cache for missing buff
		for i=1, #_buffsset do
			if _buffsset[i].name then
				found = nil;
				for j=1, #_buffscache do
					--if (_buffsset[i].name == _buffscache[j].name) and (_buffsset[i].count == _buffscache[j].count) and (_buffsset[i].caster == _buffscache[j].caster) and (_buffsset[i].expirationTime == _buffscache[j].expirationTime) then found = true; end
					if (_buffsset[i].name == _buffscache[j].name) and (_buffsset[i].count <= _buffscache[j].count) and (_buffsset[i].caster == _buffscache[j].caster) then found = true; end
				end
				if not found then
					RDXEvents:Dispatch("UNIT_BUFF_" .. _buffsset[i].name, rdxunit, _buffsset[i].name, 0);
					--if rdxunit.name then VFL.print("|cFF00FF00sig -BUFF:|r" .. _buffsset[i].name .. " " .. rdxunit.name); end
					buffchangeflag = true;
					if _buffsset[i].caster == "player" then 
						RDXEvents:Dispatch("UNIT_MYBUFF_" .. _buffsset[i].name, rdxunit, _buffsset[i].name, 0); 
						--VFL.print("sig -MYBUFF " .. _buffsset[i].name); 
					end
				end
			end
		end
		
		-- Step 5
		-- clear the set
		for i=1, #_buffsset do
			_buffsset[i].name = nil;
		end
		
		-- Step 6
		-- Update the set
		for i=1, #_buffscache do
			if not _buffsset[i] then _buffsset[i] = {}; end
			_buffsset[i].name = _buffscache[i].name;
			_buffsset[i].count = _buffscache[i].count;
			_buffsset[i].caster = _buffscache[i].caster;
			_buffsset[i].expirationTime = _buffscache[i].expirationTime;
		end
		
		RDX.EndEventBatch();
		return debuffchangeflag, buffchangeflag;
	end
	
	self.GetLastSpellRank = function(a) return _spellrank[a]; end
	self.SetLastSpellRank = function(a, r) _spellrank[a] = r; end
	
	self.SetEField = function(x, f, v) _efields[f] = v; end
	self.GetEField = function(x, f) return _efields[f]; end
	self.EFields = function() return _efields; end

	RDXEvents:Dispatch("EDATA_CREATED", self, idx);

	return self;
end

-- Master edata table
local edata = {};

local function GetEData(i)
	return edata[i];
end

-- Edata[0] = empty, do-nothing edata.
local ed0 = NewEData(0);
ed0.ProcessAuras = VFL.Noop;
ed0.SetEField = VFL.Noop;
ed0.GetEField = VFL.Nil;
ed0.IsPet = VFL.False;
ed0.SetGroup = VFL.Noop;
ed0.GetGroup = VFL.Zero;
edata[0] = ed0;

-------------------------------------------------------------------
-- NDATA
-- Ndata = nominative data = data that follows a unit around by name.
-------------------------------------------------------------------
local function NewNData(name)
	local self = {};

	local _nfields = {};
	local leader, class = 0, 0;
	local feigned = nil;

	self.SetLeaderLevel = function(x, lv) leader = lv; end
	self.GetLeaderLevel = function(x) return leader; end
	self.IsLeader = function() return (leader > 0); end
	self.SetClassID = function(x, cn) class = cn; end
	self.GetClassID = function() return class; end
	self._SetFeigned = function(x, flg) feigned = flg; end
	self.IsFeigned = function() return feigned; end
	
	self.SetNField = function(x, f, v) _nfields[f] = v; end
	self.GetNField = function(x, f) return _nfields[f]; end
	self.NFields = function() return _nfields; end

	RDXEvents:Dispatch("NDATA_CREATED", self, name);

	return self;
end

-- Master ndata table
local ndata = {};

local function GetNData(name)
	local r = ndata[name];
	if not r then
		r = NewNData(name);
		ndata[name] = r;
	end
	return r;
end

-----------------------------------------------------------------
-- UNIT DATABASES
-----------------------------------------------------------------
-- UBI: Units by index
local ubi = {};
-- UBN: Units by name
local ubn = {};

local function ubn_to_ubi(x)
	return RDX.GetUnitByNumber(x.nid);
end
local function ubi_to_ubn(x)
	return RDX.GetUnitByName(x.name);
end

--- Get a reference to a unit by its unit number.
-- @param i The unit number to query.
-- @return A reference to the unit object with unit number i.
function RDX.GetUnitByNumber(i)
	if not i then return nil; end
	return ubi[i];
end

--- Get a reference to a unit by its name.
-- @param n The name (all lowercase) of the unit to query.
-- @return A reference to the unit object for the unit named n.
function RDX.GetUnitByName(n)
	if not n then return nil; end
	local r = ubn[n];
	if not r then
		r = RDX.Unit:new();	r.name = n; r:Invalidate();
		-- Apply nominative/indexed unit funcs
		r.GetNominativeUnit = VFL.Identity;
		r.IsNominativeUnit = VFL.True;
		r.GetIndexedUnit = ubn_to_ubi;
		r.IsIndexedUnit = VFL.Nil;
		-- BUGFIX: Defer this until after init.
		if RDX.initialized then VFL.mixin(r, GetNData(n), true); end
		ubn[n] = r;
	end
	return r;
end

-------------- Initial unit creation
-- Create the initial units by index
for i=1,NUM_UNITS do 
	local qq = RDX.Unit:new(); qq.nid = i; qq:Invalidate();
	-- Apply unit query functionality
	qq.GetNominativeUnit = ubi_to_ubn;
	qq.IsNominativeUnit = VFL.Nil;
	qq.GetIndexedUnit = VFL.Identity;
	qq.IsIndexedUnit = VFL.True;
	ubi[i] = qq;
end

-- The player unit. Refers to the player's RDX unit always.
RDXPlayer = RDX.GetUnitByName(strlower(UnitName("player")));

-- Defer the creation and application of edata and ndata until the VARS_LOADED phase.
-- This gives all mods a chance to load first.
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	-- Create and apply EData.
	for i=1,NUM_UNITS do
		edata[i] = NewEData(i);
		VFL.mixin(ubi[i], edata[i], true);
	end
	-- Create all NData that doesn't exist
	for n,unit in pairs(ubn) do VFL.mixin(unit, GetNData(n), true); end
end);

------------------------------------------------------------
-- UNIT_AURA HANDLING
------------------------------------------------------------
-- The queue of units whose auras are dirty
local auraq = {};
-- Perf: how many auras should I process per frame?
local aura_unitsPerUpdate = 4;
-- The queue of units whose buffs/debuffs need to be updated
local sigbuff, sigdebuff = {}, {};

-- Process sigbuff
local function ProcessSig()
	for un,_ in pairs(sigbuff) do
		_sig_rdx_buff_star:Raise(ubi[un], un, 1);
		--if ubi[un].name then VFL.print("|cFFFF0000sig UPDATE BUFF:|r" .. ubi[un].name); end
		sigbuff[un] = nil;
	end
	for un,_ in pairs(sigdebuff) do
		_sig_rdx_debuff_star:Raise(ubi[un], un, 1);
		--if ubi[un].name then VFL.print("|cFFFF0000sig UPDATE DEBUFF:|r" .. ubi[un].name); end
		sigdebuff[un] = nil;
	end
end
local sigFrame = CreateFrame("Frame");
sigFrame:SetScript("OnUpdate", ProcessSig);
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "ProcessSig", ProcessSig, true);

-- Process pending aura updates
local iaura, batchTrig, debuffFlag, buffFlag;
local function ProcessAuraQueue()
	iaura, batchTrig, debuffFlag, buffFlag = 1, nil, false, false;
	for un,_ in pairs(auraq) do
		if(iaura > aura_unitsPerUpdate) then break; end
		if not batchTrig then batchTrig = true; RDX.BeginEventBatch(); end
		debuffFlag, buffFlag = ubi[un]:ProcessAuras();
		auraq[un] = nil;
		iaura = iaura + 1;
		if buffFlag then sigbuff[un] = true; end
		if debuffFlag then sigdebuff[un] = true; end
	end
	if batchTrig then RDX.EndEventBatch(); end
end
local auraFrame = CreateFrame("Frame");
auraFrame:SetScript("OnUpdate", ProcessAuraQueue);
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "ProcessAuras", ProcessAuraQueue, true);

--- Force a reprocessing of auras for all valid units.
function RDX.FlushAuras()
	local u;
	tempty(auraq);
	for i=1,NUM_UNITS do
		u = RDX.GetUnitByNumber(i);
		if u:IsValid() then auraq[i] = true; end
	end
end
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "FlushAuras", RDX.FlushAuras, true);

-- On UNIT_AURA, add the aura'd unit to the aura queue.
WoWEvents:Bind("UNIT_AURA", nil, function()
	local x = id2num[arg1];
	if x then
		auraq[x] = true;
		_sig_rdx_unit_aura:Raise(ubi[x], x, arg1);
	end
end);

-- On PLAYER_ENTERING_WORLD, refresh all auras.
WoWEvents:Bind("PLAYER_ENTERING_WORLD", nil, RDX.FlushAuras);

-----------------------------------------------------------------
-- RAID ROSTER
-----------------------------------------------------------------

-- When the group is a party, get the roster info for the given unit.
local function party_GetRosterInfo(idx, uid)
	if not uid then return nil; end
	local class = UnitClass(uid);
	local llv = 0;
	if IsSolo() or UnitIsPartyLeader(uid) then llv = 2; end
	return UnitName(uid), llv, 1, UnitLevel(uid), nil, class;
end
local GetRosterInfo = VFL.Nil;

-- Main roster processing.
local _rtouched, _gtouched = {}, {};
function RDX.ProcessRoster()
	VFL.empty(_rtouched);
	VFL.empty(_gtouched);

	local roster_changed = nil;
	local my_ndata, my_edata;
	local iunit, uid, nunit;
	local name, leaderLevel, grp, level, class, classec, guid;
	local gid, mygidflag = 1, false;

	RDX.BeginEventBatch();

	-- Iterate over all valid units
	local n = RDX.GetNumUnits();
	RDX:Debug(2, "RDX.ProcessRoster(): processing ", n, " units.");
	for i=1,n do
		iunit = ubi[i];
		uid = RDX.NumberToUID(i);
		name, leaderLevel, grp, level, _, class = GetRosterInfo(i, uid);
		_, classec = UnitClass(uid);
		guid = UnitGUID(uid);
		-- if not guid then guid = "Unknown"; VFL.print(UnitName(uid) .. " guid unknown"); end
		-- gid (id in the group)
		gid = i - ((grp-1)*5);
		if gid == 1 then mygidflag = false; end
		if UnitIsUnit(uid, "player") then 
			mygidflag = true; gid = 0;
		elseif mygidflag then 
			gid = gid -1;
		end
		
		if (not name) or (name == "Unknown") then
			-- This unit is now invalid...
			iunit:Invalidate();
		else
			iunit.rosterName = name;
			name = strlower(UnitName(uid));
			-- Mark engine unit as valid
			iunit.uid = uid; 
			-- patch 2.4
			iunit.guid = guid;
			iunit.class = class;
			iunit.classec = classec;
			iunit:Validate();
			-- If engine unit has changed, schedule it for rediscovery
			if(iunit.name ~= name) then 
				RDX:Debug(7, "Roster: NID<", tostring(i), "> ", tostring(iunit.name), " -> ", tostring(name));
				iunit.name = name;
				-- When an engine unit changes identities, update auras too.
				auraq[i] = true;
				roster_changed = true; 
			end
			
			-- Acquire nominative unit and mark as valid
			nunit = RDX.GetUnitByName(name);
			nunit.rosterName = iunit.rosterName;
			nunit.uid = uid;
			-- patch 2.4
			nunit.guid = guid;
			nunit.class = class;
			nunit.classec = classec;
			nunit:Validate();
			
			if(nunit.nid ~= i) then nunit.nid = i; roster_changed = true; end
			-- Mark unit as touched this session
			_rtouched[name] = iunit;
			if guid then _gtouched[guid] = iunit; end
			
			-- Get unit data
			my_ndata = GetNData(name); my_edata = GetEData(i);

			-- Update unit data
			my_ndata.SetLeaderLevel(nil, leaderLevel);
			my_edata.SetGroup(nil, grp);
			my_edata.SetMemberGroupId(nil, gid);
			my_ndata.SetClassID(nil, RDXCT.GetClassID(classec));

			-- Attach new edata to nunit
			VFL.mixin(nunit, my_edata, true);			
			-- Atach new ndata to eunit
			VFL.mixin(iunit, my_ndata, true);
		end
	end

	-- Iterate over all invalid units
	if (n < 40) and (ubi[n+1]:_ValidMetatable()) then roster_changed = true; end
	for i=(n+1),40 do
		if ubi[i]:Invalidate() then
			RDX:Debug(7, "Roster: NID<", i, "> quashed.");
		end
	end

	-- Invalidate all nominative units no longer present
	for k,v in pairs(ubn) do
		if not _rtouched[k] then v:Invalidate(); end
	end

	-- Notify of a roster update
	if roster_changed then RDXEvents:Dispatch("ROSTER_NIDS_CHANGED", _rtouched); end
	RDXEvents:Dispatch("ROSTER_UPDATE", _rtouched);
	RDX.EndEventBatch();
end
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "ProcessRoster", RDX.ProcessRoster, true);

-- Pet processing
function RDX.ProcessPets()
	--VFL.CreatePeriodicLatch(1, function()
		--VFL.print("test");
		RDX:Debug(2, "Roster: ProcessPets()");
		local unit, uid, changed;
		changed = nil;
		for i=41,80 do
			unit = ubi[i]; uid = RDX.NumberToUID(i);
			if UnitExists(uid) then
				if not unit:IsValid() then
					unit:Validate();
					unit.uid = uid;
					unit.name = strlower(UnitName(uid));
					unit.guid = UnitGUID(uid);
					if not unit.guid then unit.guid = "Unknow pet"; end
					unit.class, unit.classec = UnitClass(uid);
					if not unit.class then unit.class = "Pet"; end
					if not unit.classec then unit.classec = "PET"; end
					auraq[i] = true; changed = true;
				end
			elseif unit:_ValidMetatable() then
				unit:Invalidate();
				changed = true;
			end
		end
		if changed then 
			RDX:Debug(2, "ROSTER_PETS_CHANGED");
			RDXEvents:Dispatch("ROSTER_PETS_CHANGED"); 
		end
	--end);
end
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "ProcessPets", RDX.ProcessPets, true);

-- Pets: whenever a major change in the raid roster happens, or a UNIT_PET happens
-- let's update the pets.
WoWEvents:Bind("UNIT_PET", nil, RDX.ProcessPets);

----------------------------------------------------------------------------
-- ROSTER EVENT BINDINGS
----------------------------------------------------------------------------
local SetRaid, SetNonRaid;

-- Called on the WoW RAID_ROSTER_UPDATE event.
-- Latched to prevent uberspam.
local OnRaidRosterUpdate = function()
	local n = GetNumRaidMembers();

	-- If we weren't in a raid, transition to raid status
	if not isRaid then
		if(n > 0) then SetRaid(); return; end
		RDX.ProcessRoster();
		return;
	end

	if(n == 0) then SetNonRaid(); return; end

	RDX.ProcessRoster();

end

-- Called on the WoW PARTY_MEMBERS_CHANGED event
-- Latched to prevent uberspam.
local OnPartyMembersChanged = VFL.CreatePeriodicLatch(1, function()
	if isRaid then return; end
	-- Check solo state
	local soloChanged = nil;
	local n = RDX.GetNumUnits();
	if n == 1 and (not isSolo) then
		isSolo = true; soloChanged = true;
	elseif n > 1 and isSolo then
		isSolo = false; soloChanged = true;
	end
	-- Process roster
	RDX.ProcessRoster();
	if soloChanged then RDXEvents:Dispatch("PARTY_IS_NONRAID"); end
end);

-- Internal: Flip between raid and nonraid status
function SetRaid()
	RDX:Debug(1, "SetRaid()");

	WoWEvents:Unbind("party_roster");
	
	isRaid = true; isSolo = false;
	SetRaidIDDatabase();
	RDX.GetNumUnits = raid_GetNumUnits;
	GetRosterInfo = GetRaidRosterInfo;

	RDX.BeginEventBatch();
	RDX.ProcessRoster();
	RDX.FlushAuras();
	RDX.EndEventBatch();

	RDXEvents:Dispatch("PARTY_IS_RAID");
end

function SetNonRaid(noReprocess)
	RDX:Debug(1, "SetNonRaid()");
	
	isRaid = nil;
	SetPartyIDDatabase();
	RDX.GetNumUnits = party_GetNumUnits;
	GetRosterInfo = party_GetRosterInfo;

	if RDX.GetNumUnits() == 1 then isSolo = true; else isSolo = false; end

	if not noReprocess then
		RDX.BeginEventBatch();
		RDX.ProcessRoster();
		RDX.FlushAuras();
		RDX.EndEventBatch();
	end

	WoWEvents:Bind("PARTY_MEMBERS_CHANGED", nil, OnPartyMembersChanged, "party_roster");

	RDXEvents:Dispatch("PARTY_IS_NONRAID");
end

-- Before everything loads, let's setup in a default nonraid state
RDXEvents:Bind("INIT_PRELOAD", nil, function()
	WoWEvents:Bind("RAID_ROSTER_UPDATE", nil, OnRaidRosterUpdate);
	SetNonRaid(true);
end);

-- After everything loads, let's double check our party/raid status.
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, OnRaidRosterUpdate);
-- add because the guid is not available at INIT_VARIABLES_LOADED with UnitGUID(uid) sigg
--RDXEvents:Bind("INIT_ROSTER", nil, OnRaidRosterUpdate);

------------------------------------------------------------
-- Arena roster
------------------------------------------------------------

-- Arena processing
--local ProcessArenaRoster = VFL.CreatePeriodicLatch(1, function()
local function ProcessArenaRoster()
	--RDX.printW("Roster: ProcessArenaRoster()");
	local unit, uid, changed;
	changed = nil;
	for i=81,85 do
		unit = ubi[i]; 
		uid = RDX.NumberToUID(i);
		if UnitExists(uid) then
			if not unit:IsValid() then
				unit:Validate();
				unit.uid = uid;
				unit.name = strlower(UnitName(uid));
				--VFL.print("UID name " .. unit.name);
				unit.guid = UnitGUID(uid);
				--VFL.print("GUID " .. unit.guid);
				if not unit.guid then unit.guid = "Unknow arena"; end
				unit.class, unit.classec = UnitClass(uid);
				if not unit.class then unit.class = "Arena"; end
				if not unit.classec then unit.classec = "ARENA"; end
				auraq[i] = true; changed = true;
			end
		elseif unit:_ValidMetatable() then
			unit:Invalidate();
			changed = true;
		end
	end
	if changed then 
		--RDX.printE("ARENA_ROSTER_CHANGED");
		--if InCombatLockdown() then RDX.printE("LOCKDOWN"); end
		RDXEvents:Dispatch("ARENA_ROSTER_CHANGED"); 
	end
end
--end);
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "ProcessArenaRoster", ProcessArenaRoster, true);

WoWEvents:Bind("ARENA_OPPONENT_UPDATE", nil, ProcessArenaRoster);

-- Arenapets processing
local ProcessArenaPets = VFL.CreatePeriodicLatch(1, function()
	RDX:Debug(2, "Roster: ProcessArenaPets()");
	local unit, uid, changed;
	changed = nil;
	for i=86,90 do
		unit = ubi[i]; 
		uid = RDX.NumberToUID(i);
		if UnitExists(uid) then
			if not unit:IsValid() then
				unit:Validate();
				unit.uid = uid;
				unit.name = strlower(UnitName(uid));
				unit.guid = UnitGUID(uid);
				if not unit.guid then unit.guid = "Unknow arena pet"; end
				unit.class, unit.classec = UnitClass(uid);
				if not unit.class then unit.class = "ArenaPet"; end
				if not unit.classec then unit.classec = "ARENAPET"; end
				auraq[i] = true; changed = true;
			end
		elseif unit:_ValidMetatable() then
			unit:Invalidate();
			changed = true;
		end
	end
	if changed then 
		RDX:Debug(2, "ARENA_ROSTER_PETS_CHANGED");
		RDXEvents:Dispatch("ARENA_ROSTER_PETS_CHANGED"); 
	end
end);
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "ProcessArenaPets", ProcessArenaPets, true);

--WoWEvents:Bind("UNIT_PET", nil, ProcessArenaPets);

------------------------------------------------------------
-- ROSTER LOOKUP AND INDEXING
-----------------------------------------------------------
--- Get the RDX Unit for this raider if he's in the raid; otherwise
-- return nil.
function RDX.GetUnitByNameIfInGroup(name)
	return _rtouched[name];
end

function RDX.UnitInGroup(uid)
	return (UnitInParty(uid) or UnitInRaid(uid));
end

function RDX.ProjectUnitID(uid)
	for i=1,NUM_UNITS do
		if UnitIsUnit(num2id[i] or "none", uid) then return ubi[i]; end
	end
end

function RDX._FastProject(uid)
	if not RDX.UnitInGroup(uid) then return nil; end
	local un = id2num[uid]; if not un then return nil; end
	return ubi[un];
end

function RDX._ReallyFastProject(uid)
	if not uid then return nil; end
	local un = id2num[uid]; if not un then return nil; end
	return ubi[un];
end


-- Get the RDX Unit for this raider if he's in the raid; otherwise
-- return nil, no PET
function RDX.GetUnitByGuidIfInGroup(guid)
	return _gtouched[guid];
end

-- not really fast but all and PET
function RDX.GetUnitByGuid(guid)
	for i,_ in pairs(ubi) do
		if not ubi[i].guid then ubi[i].guid = UnitGUID(ubi[i].uid); end
		if (ubi[i].guid == guid) then return ubi[i]; end
	end
end

--function RDX.TESTPrint()
--	for i,_ in pairs(ubi) do
--		if ubi[i].guid then VFL.print(ubi[i].guid); end
--	end
--end


-------------------------------
-- PROJECTIVE UNIT
-- A projective unit is a unit with a non-canonical id (i.e. not partyX or raidX)
-- that may or may not be equivalent to one of the canonical units. If it is,
-- there is a Project() operator that will figure out which one and match
-- edata and ndata appropriately.
-------------------------------
local function ProjUnit_Project(self)
	local uid, nid = self.uid, 0;
	-- Project
	if UnitExists(uid) then
		self.name = strlower(UnitName(uid));
		self.guid = UnitGUID(uid);
		self.class, self.classec = UnitClass(uid);
		for i=1,NUM_UNITS do
			if UnitIsUnit(num2id[i] or "none", uid) then nid = i; end
		end
	else
		self.name = "";
	end
	-- Store nid
	self.nid = nid;
	-- Get unit data
	VFL.mixin(self, GetEData(nid), true);
	if nid > 0 and nid < 41 then -- Only players in grp have ndata.
		VFL.mixin(self, GetNData(self.name), true);
	else
		VFL.mixin(self, GetNData(""), true);
	end
end

RDX.ProjectiveUnit = {};
function RDX.ProjectiveUnit:new()
	local x = RDX.Unit:new();
	x.uid = "none"; x.name = "unknown"; x.nid = 0; x.guid = "unknown";
	x.class = "unknown"; x.classec = "unknown";
	x._Project = ProjUnit_Project;
	x.Invalidate = VFL.Noop; x.Validate = VFL.Noop;

	return x;
end


------------------------------------------------------------
-- UNIT_HEALTH/UNIT_MANA HANDLING
------------------------------------------------------------

-- Propagate events only if they pertain to RDX-managed units, and
-- promote the units from raw unit IDs to full fledged RDX unit 
-- objects.
local function UnitHealthPropagator(arg1, predicted)
--~     if not predicted and GetCVarBool("predictedPower") and (arg1 == "player" or arg1 == "pet") then return; end 
	local x = id2num[arg1];
	if x then
		_sig_rdx_unit_health:Raise(ubi[x], x, arg1, UnitHealth(arg1), UnitHealthMax(arg1));
	end
end
local function UnitPowerPropagator(arg1, predicted)
--~     if not predicted and GetCVarBool("predictedPower") and (arg1 == "player" or arg1 == "pet") then return; end
	local x = id2num[arg1];
	if x then
		_sig_rdx_unit_power:Raise(ubi[x], x, arg1, UnitPower(arg1), UnitPowerMax(arg1));
	end
end

local function UnitMaxPowerPropagator()
	local x = id2num[arg1];
	if x then
		_sig_rdx_unit_power:Raise(ubi[x], x, arg1, UnitPower(arg1), UnitPowerMax(arg1));
	end
end

-- Raw bindings
WoWEvents:Bind("UNIT_HEALTH", nil, UnitHealthPropagator);
WoWEvents:Bind("UNIT_MAXHEALTH", nil, UnitHealthPropagator);

WoWEvents:Bind("UNIT_MANA", nil, UnitPowerPropagator);
WoWEvents:Bind("UNIT_MAXMANA", nil, UnitMaxPowerPropagator);
WoWEvents:Bind("UNIT_ENERGY", nil, UnitPowerPropagator);
WoWEvents:Bind("UNIT_MAXENERGY", nil, UnitMaxPowerPropagator);
WoWEvents:Bind("UNIT_RAGE", nil, UnitPowerPropagator);
WoWEvents:Bind("UNIT_MAXRAGE", nil, UnitMaxPowerPropagator);
WoWEvents:Bind("UNIT_RUNIC_POWER", nil, UnitPowerPropagator);
WoWEvents:Bind("UNIT_MAXRUNIC_POWER", nil, UnitMaxPowerPropagator);
--WoWEvents:Bind("UNIT_HAPPINESS", nil, UnitManaPropagator);
--WoWEvents:Bind("UNIT_MAXHAPPINESS", nil, UnitManaPropagator);
WoWEvents:Bind("UNIT_DISPLAYPOWER", nil, UnitMaxPowerPropagator);

------------------------------------------------------------------
-- FEIGN DEATH CHECKING
------------------------------------------------------------------
-- If a unit's health drops low, check it for the FeignDeath buff. If so, mark as feigned.
RDXEvents:Bind("UNIT_HEALTH", nil, function(u, un, uid, uh)
	if(uh < 2) and (not u:IsFeigned()) and (UnitIsFeignDeath(uid)) and (not u:IsPet()) then
		u:_SetFeigned(true);
		RDXEvents:Dispatch("UNIT_FEIGN_DEATH", u, un, uid, true);
	end
end);

-- When a FD unit's auras change, snap check to see if FD went away.
RDXEvents:Bind("UNIT_AURA", nil, function(u, un, uid)
	if u:IsFeigned() and (not UnitIsFeignDeath(uid)) and (not u:IsPet()) then
		u:_SetFeigned(nil);
		RDXEvents:Dispatch("UNIT_FEIGN_DEATH", u, un, uid, false);
	end
end);

--------------------------------------------
-- TOTEM EVENTS
--------------------------------------------

WoWEvents:Bind("PLAYER_ENTERING_WORLD", nil, function()
	_sig_rdx_unit_entering_world:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
end);

-- Target change
WoWEvents:Bind("PLAYER_TOTEM_UPDATE", nil, function()
	_sig_rdx_unit_totem_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
end);


--------------------------------------------
-- COMBO EVENTS
--------------------------------------------

-- fix 7.0.3_04, combo with pet and any unit
--local _, comboclass = UnitClass("player");
--if (comboclass == "ROGUE") or (comboclass == "DRUID") then

-- Target change	
WoWEvents:Bind("PLAYER_TARGET_CHANGED", nil, function()
	_sig_rdx_unit_combo_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
end);

WoWEvents:Bind("UNIT_COMBO_POINTS", nil, function()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_combo_update:Raise(ubi[x], x, arg1); end
end);

--end

--------------------------------------------
-- RUNES EVENTS
--------------------------------------------

WoWEvents:Bind("RUNE_POWER_UPDATE", nil, function()
	_sig_rdx_unit_rune_power_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
--VFL.print("RUNE_POWER_UPDATE sig");
end);

WoWEvents:Bind("RUNE_TYPE_UPDATE", nil, function()
	_sig_rdx_unit_rune_type_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
--VFL.print("RUNE_TYPE_UPDATE sig");
end);

--------------------------------------------
-- BUFF WEAPON EVENTS
--------------------------------------------

-- there is no event to track enchant weapons...
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	local timemh, timeoh = 0, 0;
	local hasMainHandEnchant, mainHandExpiration, hasOffHandEnchant, offHandExpiration
	VFL.AdaptiveSchedule("weaponsupdate_update", 1, function()
		hasMainHandEnchant, mainHandExpiration, _, hasOffHandEnchant, offHandExpiration = GetWeaponEnchantInfo();
		if hasMainHandEnchant then
			if mainHandExpiration > timemh then
				_sig_rdx_unit_buffweapon_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
			end
			timemh = mainHandExpiration;
		elseif timemh > 0 then
			_sig_rdx_unit_buffweapon_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
			timemh = 0;
		end
		if hasOffHandEnchant then
			if offHandExpiration > timeoh then
				_sig_rdx_unit_buffweapon_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
			end
			timeoh = offHandExpiration;
		elseif timeoh > 0 then
			_sig_rdx_unit_buffweapon_update:Raise(RDXPlayer, RDXPlayer.nid, RDXPlayer.uid);
			timeoh = 0;
		end
	end);
end);

--------------------------------------------
-- MISC EVENTS
--------------------------------------------
-- store spell and rank
-- disable 7.0.3
--[[ WoWEvents:Bind("UNIT_SPELLCAST_SENT", nil, function()
	if not arg1 then return; end
	local x = id2num[arg1];
	local un = ubi[x];
	if un then 
		if arg2 and arg3 then
			un.SetLastSpellRank(arg2, string.match(arg3, i18n("Rank (%d+)")));
		end
	end
end);]]

-- Powertype change
WoWEvents:Bind("UNIT_DISPLAYPOWER", nil, function()
	local x = RDX.GetUnitByNameIfInGroup(strlower(arg1));
	if x then
		RDXEvents:Dispatch("UNIT_DISPLAYPOWER", x, x.nid, arg1);
	end
end);

-- Target change
WoWEvents:Bind("UNIT_TARGET", nil, function()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_target:Raise(ubi[x], x, arg1); end
end);

-- Focus change
WoWEvents:Bind("UNIT_FOCUS", nil, function()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_focus:Raise(ubi[x], x, arg1); end
end);

-- Flags change (combat etc)
local function flagprop()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_flags:Raise(ubi[x], x, arg1); end
end
WoWEvents:Bind("UNIT_FLAGS", nil, flagprop);
WoWEvents:Bind("UNIT_DYNAMIC_FLAGS", nil, flagprop);

-- Rangedamage
local function rangeprop()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_range:Raise(ubi[x], x, arg1); end
end
WoWEvents:Bind("UNIT_RANGEDDAMAGE", nil, rangeprop);
WoWEvents:Bind("UNIT_RANGED_ATTACK_POWER", nil, rangeprop);

-- Portrait change.
WoWEvents:Bind("UNIT_PORTRAIT_UPDATE", nil, function()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_portrait_update:Raise(ubi[x], x, arg1); end
end);

-- XP
local function filter_xp_update()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_xp_update:Raise(ubi[x], x, arg1); end
end
WoWEvents:Bind("PLAYER_XP_UPDATE", nil, filter_xp_update);
WoWEvents:Bind("UPDATE_EXHAUSTION", nil, filter_xp_update);
WoWEvents:Bind("PLAYER_LEVEL_UP", nil, filter_xp_update);
WoWEvents:Bind("UNIT_PET_EXPERIENCE", nil, filter_xp_update);

-- faction change.
WoWEvents:Bind("UNIT_FACTION", nil, function()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_faction:Raise(ubi[x], x, arg1); end
end);

-- threat change.
WoWEvents:Bind("UNIT_THREAT_SITUATION_UPDATE", nil, function()
	local x = id2num[arg1];
	if x then _sig_rdx_unit_threat_situation_update:Raise(ubi[x], x, arg1); end
end);

-- Spell events
-- CAST_TIMER_UPDATE
local sigUNIT_CAST_TIMER_UPDATE = RDXEvents:LockSignal("UNIT_CAST_TIMER_UPDATE");
local function filter_cast_timer_start()
	local x = id2num[arg1];
	if x then sigUNIT_CAST_TIMER_UPDATE:Raise(ubi[x], x, arg1); end
end
WoWEvents:Bind("UNIT_SPELLCAST_CHANNEL_START", nil, filter_cast_timer_start);
WoWEvents:Bind("UNIT_SPELLCAST_CHANNEL_UPDATE", nil, filter_cast_timer_start);
WoWEvents:Bind("UNIT_SPELLCAST_DELAYED", nil, filter_cast_timer_start);
WoWEvents:Bind("UNIT_SPELLCAST_START", nil, filter_cast_timer_start);

-- CAST_TIMER_STOP
local sigUNIT_CAST_TIMER_STOP = RDXEvents:LockSignal("UNIT_CAST_TIMER_STOP");
local function filter_cast_timer_stop()
	local x = id2num[arg1];
	if x then sigUNIT_CAST_TIMER_STOP:Raise(ubi[x], x, arg1); end
end
WoWEvents:Bind("UNIT_SPELLCAST_CHANNEL_STOP", nil, filter_cast_timer_stop);
WoWEvents:Bind("UNIT_SPELLCAST_FAILED", nil, filter_cast_timer_stop);
WoWEvents:Bind("UNIT_SPELLCAST_INTERRUPTED", nil, filter_cast_timer_stop);
WoWEvents:Bind("UNIT_SPELLCAST_SUCCEEDED", nil, function()
	local spellName = UnitCastingInfo(arg1);
	if not spellName then
		spellName = UnitChannelInfo(arg1);
	end
	if not spellName then
		filter_cast_timer_stop();
	end
end);
WoWEvents:Bind("UNIT_SPELLCAST_STOP", nil, filter_cast_timer_stop);

----------------------
-- An easy little trick to compute player cast lag and expose it as a unitframe variable.
-- Obviously this ONLY makes sense on a player castbar; using it elsewhere will result in
-- complete and utter nonsense.
----------------------
local lagv = 0;

local function resetLag() 
	lagv = 0;
end

function RDX._GetLastSpellLag() if lagv < 10 then return lagv; else return 0; end end
WoWEvents:Bind("UNIT_SPELLCAST_SENT", nil, function() lagv = GetTime(); end);
WoWEvents:Bind("UNIT_SPELLCAST_START", nil, function()
	--VFL.Time.UnscheduleByName("castbarlag");
	--VFL.scheduleNamed("castbarlag", 1.2, function() 
	--	lagv = 0;
	--end)
	if arg1 == "player" then lagv = GetTime() - lagv; end
end);
WoWEvents:Bind("UNIT_SPELLCAST_CHANNEL_START", nil, function()
	if arg1 == "player" then lagv = 0; end
end);

--WoWEvents:Bind("UNIT_SPELLCAST_FAILED", nil, resetLag);
WoWEvents:Bind("UNIT_SPELLCAST_INTERRUPTED", nil, resetLag);
--WoWEvents:Bind("UNIT_SPELLCAST_SUCCEEDED", nil, resetLag);

-- Debugging
--[[
local function evcheck()
	VFL.print("Spell event for " .. arg1 .. ": " .. GetTime() .. " = " .. event);
end
WoWEvents:Bind("UNIT_SPELLCAST_SENT", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_START", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_CHANNEL_START", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_CHANNEL_STOP", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_FAILED", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_INTERRUPTED", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_SUCCEEDED", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_STOP", nil, evcheck);
WoWEvents:Bind("UNIT_SPELLCAST_DELAYED", nil, evcheck);
]]--

-----------------------------------------------------
-- ITERATORS
-- Iterate over the units in the raid.
-----------------------------------------------------
-- Return an iterator over the current group.
local function giter(_, i)
	i=i+1;
	local u = ubi[i];
	if u and u:IsCacheValid() then return i, u; end
	--if u and u:IsValid() then return i, u; end
end

function RDX.Raid()
	return giter, nil, 0;
end

-- Return an iterator for all, raids and pets
local function giter2(_, i)
	i=i+1;
	local u = ubi[i];
	if u and i < 81 then return i, u; end
end

function RDX.RaidAll()
	return giter2, nil, 0;
end

local function GroupStatelessIterator(gn, idx)
	local u = nil;
	while true do
		idx = idx + 1; u = ubi[idx];
		if (not u) or (not u:IsCacheValid()) then break; end
		--if (not u) or (not u:IsValid()) then break; end
		if (u:GetGroup() == gn) then return idx, u; end
	end
end

function RDX.Group(gn)
	if not gn then return giter, nil, 0; end
	return GroupStatelessIterator, gn, 0;
end

-- Return an iterator for arena
local function giter3(_, i)
	i=i+1;
	local u = ubi[80 + i];
	if u then return i, u; end
end

function RDX.ArenaGroup()
	return giter3, nil, 0;
end

-----------------------------------------------------------------
-- "DISRUPTIVE EVENTS"
-- Disruptive events are events that tend to require the whole
-- UI to rebuild itself. We consolidate them into one big event.
-----------------------------------------------------------------
local disrupt_flag, disrupt_lock = nil, nil;

local function Disruption()
	if not disrupt_lock then
		disrupt_lock = true;
		VFL.ZMSchedule(0.5, function()
			--RDX.print("Disruption");
			RDX:Debug(1,"|cFFFF00FFDisruption: ", tostring(event), "|r");
			RDXEvents:Dispatch("DISRUPT_SETS");
			RDXEvents:Dispatch("DISRUPT_SORTS");
			RDXEvents:Dispatch("DISRUPT_WINDOWS");
			disrupt_lock = nil;
		end);
	end
end
VFLP.RegisterFunc(i18n("RDX: UnitDB"), "Disruptions", Disruption, true);

local function Disruption_delay()
	--Disruption()
	if InCombatLockdown() then
		disrupt_flag = true; 
	else
		Disruption();
	end
end

VFLEvents:Bind("PLAYER_COMBAT", nil, function()
	if disrupt_flag then
		Disruption();
		disrupt_flag = nil;
	end
end);

WoWEvents:Bind("PLAYER_ENTERING_WORLD", nil, Disruption_delay);
RDXEvents:Bind("ROSTER_UPDATE", nil, Disruption_delay);
RDXEvents:Bind("ROSTER_PETS_CHANGED", nil, Disruption_delay);
RDXEvents:Bind("ARENA_ROSTER_CHANGED", nil, Disruption_delay);
RDXEvents:Bind("ARENA_ROSTER_PETS_CHANGED", nil, Disruption_delay);
VFLEvents:Bind("PLAYER_COMBAT", nil, Disruption_delay);

function RDX._Disrupt()
	RDX.print("Disruption");
	Disruption_delay();
end

