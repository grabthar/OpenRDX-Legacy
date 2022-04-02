-- OpenRDX
-- Sigg Rashgarroth EU

OmniDB = RegisterVFLModule({
	name = "OmniDB";
	title = i18n("OmniDB");
	description = "Omni DataBase for RDX";
	version = {1,0,0};
	parent = RDX;
});

local myGUID = nil;
local myname = string.lower(UnitName("player"));
local timeGC_default = 300;
local GUIDs = {};

local rowtype, sourceGUID, sourceName, targetGUID, targetName, amount, overhealing, spellname, spellid;
local srcGUID, tgtGUID;

local infotype = {};
infotype[1] = "dtaken";
infotype[2] = "ddone";
infotype[3] = "htaken";
infotype[4] = "hdone";
infotype[5] = "ohdone";
infotype[6] = "selfheal";

-- Get DB Size
local function OmniDBgetSize()
	return table.getn(GUIDs);
end

-- Return GUIDs
local function OmniDBgetGUIDs()
	return GUIDs;
end

-- Return one GUID
local function OmniDBgetGUID(guid, name, force)
	if not guid then return nil; end
	if (not GUIDs[guid]) and force then
		GUIDs[guid] = Omni.GUID:new(guid, name);
		--VFL.print(name .. " " .. guid);
	end
	return GUIDs[guid];
end

-- Remove one GUID
local function OmniDBremoveGUID(guid)
	local tmpGUID = OmniDBgetGUID(guid);
	if tmpGUID then
		tmpGUID:emptyINFO();
		tmpGUID:emptyCD();
		tmpGUID = nil;
		GUIDs[guid] = nil;
	end
	return true;
end

-- Empty GUIDs
local function OmniDBemptyGUIDs()
	for k,_ in pairs(GUIDs) do
		OmniDBremoveGUID(k);
	end
	return true;
end

-------------------------------------
-- Global high level functions
-------------------------------------

function OmniDB.GetGUID(guid)
	return OmniDBgetGUID(guid);
end

function OmniDB.GetGUIDInfo(guid, name)
	local tmpGUID = OmniDBgetGUID(guid, name, true);
	if not tmpGUID then return 0,0,0,0,0,0; end
	return tmpGUID:getGUIDData("dtaken"), tmpGUID:getGUIDData("ddone"), tmpGUID:getGUIDData("htaken"), tmpGUID:getGUIDData("hdone"), tmpGUID:getGUIDData("ohdone"), tmpGUID:getGUIDData("selfheal");
end

function OmniDB.ClearOmniData()
	VFLUI.MessageBox("Clear OmniDB data", "Do you want to reset? This will clear everyone omniDB.", nil, "No", nil, "Yes", OmniDBResetData);
end

----------------------------------------------
-- services
----------------------------------------------
local time, flag = 0, {};
local function OmniDBservice()
	VFL.empty(flag);
	--VFL.print("GUID size " .. VFL.tsize(GUIDs));
	for k,v in pairs(GUIDs) do
		-- remove tguid with time superior to tm_default
		time = (GetTime() - v:getObjectTime());
		if time > timeGC_default then table.insert(flag, v:getObjectGUID()); end
	end
	-- removing
	for _,w in pairs(flag) do
		OmniDBremoveGUID(w);
		--VFL.print("debug remove GUID " .. w);
	end
end
VFLP.RegisterFunc("RDX Omniscience", "GUID Database Service", OmniDBservice, true);

----------------------------------------------
-- Omnimeters events
----------------------------------------------

-- Omnimeters, Bind event omni
local pp = {};
pp.OmniDBUpdate = function(...)
	rowtype, sourceGUID, sourceName, targetGUID, targetName, amount, overhealing = select(2, ...);
	if amount then
		if rowtype == 1 then -- damagein
			tgtGUID = OmniDBgetGUID(targetGUID, targetName, true);
			tgtGUID:addGUIDData("dtaken", amount);
		elseif rowtype == 2 then -- damageout
			srcGUID = OmniDBgetGUID(sourceGUID, sourceName, true);
			srcGUID:addGUIDData("ddone", amount);
		elseif rowtype == 3 then -- healingin
			tgtGUID = OmniDBgetGUID(targetGUID, targetName, true);
			tgtGUID:addGUIDData("htaken", amount);
		elseif rowtype == 4 then -- healingout
			srcGUID = OmniDBgetGUID(sourceGUID, sourceName, true);
			srcGUID:addGUIDData("hdone", amount);
			if overhealing and (overhealing > 0) then
				srcGUID:addGUIDData("ohdone", overhealing);
			end
		elseif rowtype == 7 then -- healingself
			srcGUID = OmniDBgetGUID(sourceGUID, sourceName, true);
			srcGUID:addGUIDData("selfheal", amount);
		end
	end
end

----------------------------------------------
-- Omnimeters RPC
----------------------------------------------
local myInfos = {};

-- Omnimeters, send your data to all members
local function OmniDBSyncMeters()	
	local tmpGUID = OmniDBgetGUID(myGUID, myname, true); -- This line will also create it.
	VFL.empty(myInfos);
	myInfos.OmniDTaken = tmpGUID:getGUIDData("dtaken"); -- also update time of guid so ths GC won't remove it.
	myInfos.OmniDDone = tmpGUID:getGUIDData("ddone");
	myInfos.OmniHTaken = tmpGUID:getGUIDData("htaken");
	myInfos.OmniHDone = tmpGUID:getGUIDData("hdone");
	myInfos.OmniOHDone = tmpGUID:getGUIDData("ohdone");
	myInfos.OmniSHDone = tmpGUID:getGUIDData("selfheal");
	RPC_Group:Flash("OmniDBMeters", myInfos);
end

-- Omnimeters, receive data from all members
local function RPCOmniDBSyncMeters(ci, Infos)
	local unit = RPC.GetSenderUnit(ci);
	if (not unit) or (not unit:IsValid()) then return; end
	if unit.guid ~= myGUID then
		local tmpGUID = OmniDBgetGUID(unit.guid, unit.name, true);
		if tmpGUID then
			tmpGUID:setGUIDData("dtaken", Infos.OmniDTaken);
			tmpGUID:setGUIDData("ddone", Infos.OmniDDone);
			tmpGUID:setGUIDData("htaken", Infos.OmniHTaken);
			tmpGUID:setGUIDData("hdone", Infos.OmniHDone);
			tmpGUID:setGUIDData("ohdone", Infos.OmniOHDone);
			tmpGUID:setGUIDData("selfheal", Infos.OmniSHDone);
		end
	end
end

-- Omnimeters, function send a reset to all raid
local function OmniDBResetData()
	if not RDXPlayer:IsLeader() then return; end
	RPC_Group:Flash("ResetOmniLog");
end

-- Omnimeters, receive reset
local function RPCOmniDBResetData(ci)
	local unit = RPC.GetSenderUnit(ci);
	if (not unit) or (not unit:IsValid()) then return; end
	if not unit:IsLeader() then
		RPC:Debug(1, "Got ResetOmniDB from non-leader " .. unit.name);
		return; 
	end
	RDX.print("|cFFAAFF00Omniscience:|r |cFFFFFFFFReset OmniDB from " .. ci.sender);
	OmniDBemptyGUIDs();
end

----------------------------------------
-- Omnimeters Reset
----------------------------------------

function OmniDB.ResetDamageMeter()
	for k,v in pairs(GUIDs) do
		v:setGUIDData("dtaken", 0);
		v:setGUIDData("ddone", 0);
		v:setGUIDData("htaken", 0);
		v:setGUIDData("hdone", 0);
		v:setGUIDData("ohdone", 0);
		v:setGUIDData("selfheal", 0);
	end
	RDX.print(i18n("|cFFAAFF00Omniscience:|r |cFFFFFFFFReset OmniMeters"));
	return true;
end

----------------------------------------
-- Omnimeters Menu enable/disable sync
----------------------------------------

local function EnableSyncDamageMeter()
	RDXG.SyncOmniMeters = true;
	VFL.AdaptiveUnschedule("OmniDBSyncMeters");
	VFL.AdaptiveSchedule("OmniDBSyncMeters", 3, OmniDBSyncMeters);
	RPC_Group:Bind("OmniDBMeters", RPCOmniDBSyncMeters);
end

local function DisableSyncDamageMeter()
	RDXG.SyncOmniMeters = nil;
	VFL.AdaptiveUnschedule("OmniDBSyncMeters");
	RPC_Group:UnbindPattern("OmniDBMeters");
end

function OmniDB.ToggleSyncDamageMeter()
	if RDXG.SyncOmniMeters then
		DisableSyncDamageMeter();
		RDX.print(i18n("|cFFAAFF00Omniscience:|r |cFFFFFFFFDisable Sync OmniMeters"));
	else
		EnableSyncDamageMeter();
		RDX.print(i18n("|cFFAAFF00Omniscience:|r |cFFFFFFFFEnable Sync OmniMeters")); 
	end
end

function OmniDB.IsSyncDamageMeterActive()
	return RDXG.SyncOmniMeters;
end

---------------------------------------
-- Omnimeters Menu enable/disable
---------------------------------------

local function EnableDamageMeter()
	RDXG.UseOmniMeters = true;
	-- enable sync with raid members
	if RDXG.SyncOmniMeters then EnableSyncDamageMeter(); end
	-- enable listener to omni events
	OmniEvents:Bind("LOG_METERS", pp, pp.OmniDBUpdate, "OmniMeters");
	-- Activate RDX Omni unit
	RDX.OmniUnitEnable();
end

local function DisableDamageMeter()
	RDXG.UseOmniMeters = nil;
	-- disable sync with raid memebers
	DisableSyncDamageMeter();
	-- disable listener to omni events
	OmniEvents:Unbind("OmniMeters");
	-- Disable RDX Omni unit
	RDX.OmniUnitDisable()
end

function OmniDB.ToggleDamageMeter()
	if RDXG.UseOmniMeters then
		DisableDamageMeter();
		RDX.print(i18n("|cFFAAFF00Omniscience:|r |cFFFFFFFFDisable OmniMeters"));
	else
		EnableDamageMeter();
		RDX.print(i18n("|cFFAAFF00Omniscience:|r |cFFFFFFFFEnable OmniMeters")); 
	end
end

function OmniDB.IsDamageMeterActive()
	return RDXG.UseOmniMeters;
end

----------------------------------------------
-- OmniCooldowns
----------------------------------------------

local _sig_rdx_cooldown_star = RDXEvents:LockSignal("UNIT_COOLDOWN");
local sigcd = {};
local unitByGUID, cdInfo;

local function ProcessSig()
	for guid,_ in pairs(sigcd) do
		unitByGUID = RDX.GetUnitByGuid(guid);
		if unitByGUID then 
			_sig_rdx_cooldown_star:Raise(unitByGUID, unitByGUID.nid, 1);
			sigcd[guid] = nil;
		else
			unitByGUID = UnitGUID("target");
			-- TODO
			--if unitByGUID == guid then
			--	_sig_rdx_cooldown_star:Raise(unitByGUID, unitByGUID.nid, 1);
			--else
			--
			--end
		end
	end
end
local sigFrame = CreateFrame("Frame");
sigFrame:SetScript("OnUpdate", ProcessSig);

local cc = {};
cc.OmniCooldownsUpdate = function(...)
	--VFL.print("new cd");
	rowtype, sourceGUID, sourceName, targetGUID, targetName, spellname, spellid = select(2, ...);
	unitByGUID = OmniDBgetGUID(sourceGUID, sourceName, true);
	cdInfo = Omni.GetCooldownInfoBySpellid(spellid);
	if cdInfo then
		--VFL.print(spellname .. " " .. GetTime() + cdInfo.duration);
		if cdInfo.group then
			local cdgroup = Omni.GetGroupCooldowns(cdInfo.group);
			for f,v in pairs(cdgroup) do
				unitByGUID:SetCooldown(v.spellname, v.spellid, GetTime() + cdInfo.duration);
			end
		else
			unitByGUID:SetCooldown(spellname, spellid, GetTime() + cdInfo.duration);
		end
		sigcd[sourceGUID] = true;
	end
end

function RDX.UnitCooldown(uid, i)
	--VFL.print("call RDX.UnitCooldown");
	local guid = UnitGUID(uid);
	local name = UnitName(uid);
	if guid then
		unitByGUID = OmniDBgetGUID(guid, name, true);
		local cd = unitByGUID:GetCooldown(i);
		if cd and cd.spellid then
			cdInfo = Omni.GetCooldownInfoBySpellid(cd.spellid);
			--VFL.print("GetTime " .. GetTime());
			--VFL.print("expire " .. cd.expirationTime);
			local timeleft = cd.expirationTime - GetTime();
			if timeleft < 0 then timeleft = 0; end
			--VFL.print("RDX.UnitCooldown found");
			return true, cdInfo.spellname, cd.spellid, cdInfo.class, cdInfo.info, cdInfo.icon, cdInfo.duration, cd.expirationTime, timeleft;
		else
			return nil;
		end
	end
end

-- send an event when COOLDOWN is available.
-- no need !!!
--local function OmniDBCDservice()
--	for k,v in pairs(GUIDs) do
--		
--	end
--end
--VFLP.RegisterFunc("RDX Omniscience", "GUID CD Database Service", OmniDBCDservice, true);


----------------------------------------------
-- INIT
----------------------------------------------

RDXEvents:Bind("INIT_DEFERRED", nil, function()
	
	-- init guid
	myGUID = UnitGUID("player");
	
	-- bind : receive reset request
	RPC_Group:Bind("ResetOmniLog", RPCOmniDBResetData);
	
	-- omnimeters
	if RDXG.UseOmniMeters then
		EnableDamageMeter();
	end
	
	-- services
	VFL.AdaptiveSchedule("OmniDBservices", 30, OmniDBservice);
	-- launch the first time
	OmniDBservice();
	
	-- cooldown
	OmniEvents:Bind("LOG_COOLDOWNS", cc, cc.OmniCooldownsUpdate, "OmniCooldowns");
	
end);

