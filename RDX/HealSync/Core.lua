-- Core.lua
-- OpenRDX - Raid Data Exchange
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--

------------------------------------------------------------------------
-- Healing Synchronization module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
------------------------------------------------------------------------

HealSync = RegisterVFLModule({
	name = "HealSync";
	title = i18n("HealSync");
	description = "Incoming Heals DB for RDX6";
	version = {1,0,0};
	parent = RDX;
});

-- alleviate visual lag (actually server -> client lag) between
-- the time a heal finishes and the time the HP is added to the unit
local function GetVisualComp()
--	local _,_,latency = GetNetStats();
--	return math.min( (latency/1000) - 0.05, 0);
	return 0.2;
end

-- Signal locking for performance enhancement
local _sig_rdx_unit_heals = RDXEvents:LockSignal("UNIT_INCOMING_HEALS");

---------------------------------
-- Healing spell metadata
---------------------------------
local directHeals = {};
function HealSync.RegisterDirectHealSpell(spell)
	directHeals[spell] = true;
end
function HealSync.IsDirectHeal(spell) return directHeals[spell or ""]; end
function HealSync._GetDirectHeals() return directHeals; end

local ignoreDirectHeals = {};
function HealSync.RegisterIgnoreDHSbyBuff(spell, buff)
	table.insert(ignoreDirectHeals, {spell, buff});
end
local IIDHS, IIbuffname = nil, nil;
function HealSync.IsIgnoreDHSbyBuff(spell)
	IIDHS = nil;
	for _,v in ipairs(ignoreDirectHeals) do
		--VFL.print(spell .. " " .. v[1]);
		if spell == v[1] then
			IIbuffname = GetSpellInfo(v[2]);
			--VFL.print("search " .. IIbuffname);
			if RDXPlayer:HasBuff(IIbuffname) then IIDHS = true; end
		end
	end
	return IIDHS;
end

------------------------------------
-- Unit API mods
-----------------------------------
RDX.Unit.IncomingHealth = VFL.Zero;
RDX.Unit.MyIncomingHealth = VFL.Zero;
RDX.Unit._Healers = VFL.Nil;
RDX.Unit._HealersNIDHash = VFL.Nil;
RDX.Unit._AddIncHeal = VFL.Noop;
RDX.Unit._StopIncHeal = VFL.Noop;
RDX.Unit._CountIncHeals = VFL.Zero;
RDX.Unit._IterateIncHeals = function() return VFL.Nil; end;
RDX.Unit._AdjustIncHeals = VFL.Noop;

function RDX.Unit:SmartHealth()
	return self:IncomingHealth() + self:Health();
end

function RDX.Unit:FracSmartHealth()
	local ih, h, mh = self:IncomingHealth(), self:Health(), self:MaxHealth();
	if(mh <= 1) then return 0; end
	h = (h+ih)/mh;
	if h<0 then return 0; elseif h>1 then return 1; else return h; end
end

function RDX.Unit:AllSmartHealth()
	local ih, h, mh = self:IncomingHealth(), self:Health(), self:MaxHealth();
	if(mh <= 1) then return 1, 1, 0; end
	h = h+ih; local x = h/mh;
	if x<0 then
		return h, mh, 0, ih;
	elseif x>1 then
		return h, mh, 1, ih;
	else
		return h, mh, x, ih;
	end
end

function RDX.Unit:MySmartHealth()
	local ih, h, mh = self:MyIncomingHealth(), self:Health(), self:MaxHealth();
	if(mh <= 1) then return 1, 1, 0; end
	h = h+ih; local x = h/mh;
	if x<0 then
		return h, mh, 0, ih;
	elseif x>1 then
		return h, mh, 1, ih;
	else
		return h, mh, x, ih;
	end
end

-------------------------------------------------
-- INCOMING HEALS DATABASE
-- We will store this as ndata on the unit and let the RDX core take
-- care of the hassle of tracking everything by name.
-------------------------------------------------
local tempTbl = {};

-- Heal stateless iterator function
local function HealIter(heals, i)
	local t = GetTime();
	i=i+1; local u = heals[i];
	while (u and u.expire < t) do i=i+1; u = heals[i]; end
	if u then return i, u; end
end

-- Heal sort function
local function HealSort(h1, h2)
	return h1.expire < h2.expire;
end

-- Helper functions to store/cancel individual heals
local function HealComplete(unit, hentry)
	hentry.sched = nil; hentry.expire = 0;
--	VFL.print("HealComplete FROM " .. hentry.origin.name .. " TO " .. unit.name);
	_sig_rdx_unit_heals:Raise(unit, unit.nid, unit.uid);
end
local function HealStore(unit, ih, hentry, t, origin, value, expire, propagate, adjust)
	-- Update the data
	hentry.start = t;
	hentry.value = value; hentry.expire = expire; hentry.origin = origin;
	hentry.needsAdj = nil;
	table.sort(ih, HealSort);
	-- Schedule the completion event
	if hentry.sched then VFL.unschedule(hentry.sched); hentry.sched = nil; end
	hentry.sched = VFL.schedule(expire - t, HealComplete, unit, hentry);
	-- Raise the heals changed event
	if propagate then _sig_rdx_unit_heals:Raise(unit, unit.nid, unit.uid); end
end
local function HealCancel(unit, ih, hentry, propagate)
--	VFL.print("HealCancel FROM " .. hentry.origin.name .. " TO " .. unit.name .. " expiry " .. (GetTime() - hentry.expire));
	hentry.expire = 0;
	VFL.unschedule(hentry.sched); hentry.sched = nil;
	if propagate then _sig_rdx_unit_heals:Raise(unit, unit.nid, unit.uid); end
end


RDXEvents:Bind("NDATA_CREATED", nil, function(ndata)
	local ih = {};

	-- Add an incoming heal to this unit.
	ndata._AddIncHeal = function(x, origin, value, expire, adjust)
		local n, t = origin.name, GetTime();
		-- Case 1: if the origin already has a heal on this guy reuse it.
		-- If it's not expired yet, cancel it.
		for _,hentry in ipairs(ih) do
			if hentry.origin.name == n then
				if(hentry.expire >= t) then HealCancel(x, ih, hentry); end
				HealStore(x, ih, hentry, t, origin, value, expire, true, adjust);
				return hentry;
			end
		end
		-- Case 2: Recycle some expired entry
		for _,hentry in ipairs(ih) do
			if hentry.expire < t then
				HealStore(x, ih, hentry, t, origin, value, expire, true, adjust);
				return hentry;
			end
		end
		-- Case 3: make a new entry
		local hentry = {}; table.insert(ih, hentry);
		HealStore(x, ih, hentry, t, origin, value, expire, true, adjust);
		return hentry;
	end

	-- Stop an incoming heal on this unit.
	ndata._StopIncHeal = function(x, origin)
		local n, t = origin.name, (GetTime() + GetVisualComp() + 0.3);
		for _,hentry in ipairs(ih) do
			if (hentry.expire > t) and (hentry.origin.name == n) then
				HealCancel(x, ih, hentry, true);
				return true;
			end
		end
		return false;
	end

	-- Get the total incoming heals on this unit.
	ndata.IncomingHealth = function()
		local ret, t = 0, GetTime();
		for _,hentry in ipairs(ih) do
			if hentry.expire >= t then ret = ret + hentry.value; end
		end
		return math.floor(ret);
	end
	
	-- Get my incoming heals on this unit. sigg
	ndata.MyIncomingHealth = function()
		local ret, t = 0, GetTime();
		for _,hentry in ipairs(ih) do
			if (hentry.expire >= t) and (hentry.origin.name == RDXPlayer.name) then ret = hentry.value; end
		end
		return math.floor(ret);
	end

	-- Get a list containing the RDX units of all healers healing this unit.
	ndata._Healers = function()
		local t = GetTime();
		VFL.empty(tempTbl);
		for _,hentry in ipairs(ih) do
			if hentry.expire >= t then
				local u = hentry.origin;
				table.insert(tempTbl, u);
			end
		end
		return tempTbl;
	end

	-- Get a mapping (nid->true/false) depending on whether or not the given nid
	-- is healing this guy or not.
	ndata._HealersNIDHash = function()
		local t = GetTime();
		for i=1,40 do tempTbl[i] = false; end
		for _,hentry in ipairs(ih) do
			if hentry.expire >= t then
				local u = hentry.origin;
				if u and u:IsValid() then
					tempTbl[u.nid] = true;
				end
			end
		end
		return tempTbl;
	end

	-- Count and iterate over incoming heals on this target.
	ndata._CountIncHeals = function()
		local ret, t = 0, GetTime();
		for _,hentry in ipairs(ih) do
			if hentry.expire >= t then ret = ret + 1; end
		end
		return ret;
	end
	ndata._IterateIncHeals = function()
		return HealIter, ih, 0;
	end

	ndata:SetNField("incheals", ih);
end);

--------------------------------------------------------------------
-- LOCAL CAST DRIVER
-- Intercept local spellcasts, determine if they are heals, and
-- act accordingly on them.
--------------------------------------------------------------------
local rankPattern = i18n("Rank (%d+)"); 
--local healPattern = i18n("^Your (.+) heals (.+) for (%d+)."); 
--local critPattern = i18n("critically$"); 

-- Store data about the last healing spell we've casted
local last_spell, last_rank, last_target, isgroup, isbind = nil, nil, nil, nil, nil;

-- On SPELLCAST_SENT, store info about the target of our spell, etc.
local function OnSpellcastSent()
	--VFL.print("spell " .. arg2 .. " target " .. arg4);
	last_spell = nil; last_rank = nil; last_target = nil; isgroup = false; isbind = false;
	-- If it's not a heal spell we don't need to be here.
	if not directHeals[arg2] then return; end
	if HealSync.IsIgnoreDHSbyBuff(arg2) then return; end
	
	-- Record the target
	last_target = string.lower(VFL.GetBGName(arg4));
	
	-- Make sure the guy is in our raid; if not this is irrelevant.
	if not RDX.GetUnitByNameIfInGroup(last_target) then
		last_target = nil; return;
	end
	if (arg2 == i18n("Prayer of Healing")) then isgroup = true; end
	if (arg2 == i18n("Binding Heal")) then isbind = true; end
	
	-- Record the spell name/rank
	last_spell = arg2;
	last_rank = string.match(arg3, rankPattern);
	last_rank = tonumber(last_rank) or 0;
	-- Dispatch the RPC.
	local _,_,latency = GetNetStats();
	RPC.Invoke("hsync", last_target, math.floor(HealSync.GetHealValue(last_spell, last_rank)), HealSync.GetHealCastTime(last_spell, last_rank), latency, isgroup, isbind);
end

-- On SPELLCAST_START, measure cast time
local function OnSpellcastStart()
	if(arg1 ~= "player") or (not last_target) then return; end
	local spell, rank, _, _, _, eta = UnitCastingInfo("player");
	local rankp = string.match(rank, rankPattern);
	if (not spell) or (spell ~= last_spell) then return; end
	eta = (eta / 1000) - GetTime();
	HealSync.SetHealCastTime(spell, rankp, eta);
end

-- On SPELL_SELF_BUFF, parse out the healing info.
local pp = {};
pp.ParseHealValue = function(...)
	local spell, amt = select(2, ...);
	--VFL.print(spell);
	--VFL.print(amt);
	if (not spell) or (spell ~= last_spell) then return; end
	HealSync.AddHealValueDataPoint(last_spell, last_rank, tonumber(amt));
end


--------------------------------------------------------------------
-- REMOTE CAST DRIVER
-- Intercept the RPCs caused by the local cast driver and handle them
-- accordingly. Also, catch SPELLCAST_STOPs and SPELLCAST_INTERRUPTEDs
-- and preempt existing heals in these cases.
--------------------------------------------------------------------

-- Incoming RPC handler
local function ProcessRemoteSpell(ci, targ, value, casttime, latency, isgroup, isbind)
	local origin = RPC.GetSenderUnit(ci);
	--VFL.print("receive " .. origin.name .. " target " .. targ);
	if (not origin) or (not origin:IsValid()) then return; end
	latency = tonumber(latency); if not latency then latency = 0; end
	latency = latency / 1000;
	local adjust, t = nil, GetTime();

	-- Store our last heal on the unit object.
	origin:SetNField("lastHealTarget", targ);
	origin:SetNField("lastHealTime", t);
	origin:SetNField("lastbind", isbind);

	-- Try to use UnitCastingInfo() to get the cast time. Maybe the RPC arrived late enough.
	-- If it fails, use the other side's provided value.
	local eta;
	_,_,_,_,_,eta = UnitCastingInfo(origin.uid);
	if eta then
		eta = (eta / 1000) + GetVisualComp();
	else
		-- Factor in a round-trip latency for the spellcast going to the server and the response coming back to the client.
		eta = casttime + t + 2*latency + GetVisualComp();
	end

	-- Group vs. single target case; in group case, add an incoming heal to everyone
	-- in my group.
	if isgroup then
		local targetUnit = RDX.GetUnitByNameIfInGroup(targ);
		if targetUnit then
			RDX.BeginEventBatch();
			local gn = targetUnit:GetGroup(); if not gn then return; end
			for _,membergpUnit in RDX.Group(gn) do
				if membergpUnit:IsInRange() then
					membergpUnit:_AddIncHeal(origin, value, eta, adjust);
				end
			end
			RDX.EndEventBatch();
		end
	else
		local targetUnit = RDX.GetUnitByNameIfInGroup(targ);
		if targetUnit then targetUnit:_AddIncHeal(origin, value, eta, adjust); end
		if isbind then 
			if origin:IsInRange() then origin:_AddIncHeal(origin, value, eta, adjust); end
		end
	end
end

-- On SPELLCAST_STOP, RPC that we're done.
local function OnSpellcastStop()
	-- Only trigger for translatable units
	local un = RDX.UIDToNumber(arg1); if not un then return; end
	local origin = RDX.GetUnitByNumber(un); if not origin then return; end

	-- Retrieve the last heal target of this unit
	local htarg, htime, bind = origin:GetNField("lastHealTarget"), origin:GetNField("lastHealTime"), origin:GetNField("lastbind");
	-- If it doesn't exist or it was too long ago, ignore
	if(not htarg) or (not htime) or (math.abs(htime - GetTime()) > 3.5) then return; end
	-- Resolve the targets
	if htarg == "_group" then
		RDX.BeginEventBatch();
		for _,unit in RDX.Group() do unit:_StopIncHeal(origin); end
		RDX.EndEventBatch();
	else
		htarg = RDX.GetUnitByNameIfInGroup(htarg);
		if htarg then htarg:_StopIncHeal(origin); end
		if bind then origin:_StopIncHeal(origin); end
	end
end

-----------------------------------------------------------
-- INIT
-----------------------------------------------------------
RDXEvents:Bind("INIT_POST_VARIABLES_LOADED", nil, function()
	WoWEvents:Bind("UNIT_SPELLCAST_SENT", nil, OnSpellcastSent);
	WoWEvents:Bind("UNIT_SPELLCAST_START", nil, OnSpellcastStart);
	--WoWEvents:Bind("CHAT_MSG_SPELL_SELF_BUFF", nil, ParseHealValue);
	OmniEvents:Bind("LOG_HEALSYNC", pp, pp.ParseHealValue);
	WoWEvents:Bind("UNIT_SPELLCAST_STOP", nil, OnSpellcastStop);
	WoWEvents:Bind("UNIT_SPELLCAST_INTERRUPTED", nil, OnSpellcastStop);
	RPC.Bind("hsync", ProcessRemoteSpell);
end);

