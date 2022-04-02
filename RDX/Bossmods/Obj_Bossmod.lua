-- Obj_Bossmod.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED CONTENT SUBJECT TO THE TERMS OF A
-- SEPARATE LICENSE. UNLICENSED COPYING IS PROHIBITED.

------------------------------------------------------------------------
-- GUI Bossmods module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
--
-- Note:
--  Licensed exclusively to Raid Informatics
------------------------------------------------------------------------

RDXBM = RegisterVFLModule({
	name = "RDXBM";
	title = i18n("RDX Bossmod Object");
	description = "RDX Bossmod GUI Editor";
	version = {1,0,0};
	parent = RDX;
});
--[[ I don't think these are needed...
local abilityEvents = {
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES",
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES",
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS",
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", 
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF",
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE",
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF",
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF",
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS",
	"CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE",
	"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
};]]--

local msgEvents = {
	"CHAT_MSG_RAID_BOSS_EMOTE",
    "CHAT_MSG_MONSTER_EMOTE",
    "CHAT_MSG_MONSTER_SAY",
    "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_MONSTER_YELL",
	-- "CHAT_MSG_SAY", good for debugging
};
--[[
function RDXBM.BindAbilityEvents(encid, BossmodEvents)
	local n = #abilityEvents
	for i=1,n do
		WoWEvents:Bind(abilityEvents[i], nil, function()
			BossmodEvents:Dispatch("ABILITY");
		end, encid);
	end	
	BossmodEvents:LockSignal("ABILITY");
end]]

function RDXBM.BindAbilityEvents2(encid, BossmodEvents)
	local pp = {};
	pp.oevent = function(...)
		local rowtype, source, sourceGUID, target, targetGUID, spellname, spellid, dot = select(2, ...);
		BossmodEvents:Dispatch("OMNI", rowtype, source, sourceGUID, target, targetGUID, spellname, spellid, dot);
	end
	OmniEvents:Bind("LOG_BOSSMODS", pp, pp.oevent, encid);
	BossmodEvents:LockSignal("OMNI");
end

function RDXBM.BindMsgEvents(encid, BossmodEvents)
	local n = #msgEvents;
	for i=1,n do
		WoWEvents:Bind(msgEvents[i], nil, function()
			BossmodEvents:Dispatch("MSG");
		end, encid);
	end
	BossmodEvents:LockSignal("MSG");
end

function RDXBM.EventIsLocal(event, state)
	if string.match(event, "^MSG") or string.match(event, "^OMNI") then return true; end
	if event == "START" or event == "STOP" or event == "ACTIVATE" or event == "DEACTIVATE" then 
	return true; end
	for _,desc in ipairs(state.features) do
		if desc.devent and desc.devent == event then
			return true;
		end
	end

	return false;
end


function RDXBM._GetEventCache()
	local db = {};
	local bmState = RDXBM.GetbmState();
	for feat,desc in ipairs(bmState.features) do
		if desc.devent and desc.devent ~= "" then
			if VFL.vfind(db, desc.devent) == nil then
				table.insert(db, desc.devent);
			end
		end
	end
--	table.insert(db, "ACTIVATE") this can't really be used by non-script objects
	table.insert(db, "START")
	table.insert(db, "STOP")
	table.insert(db, "DEACTIVATE")
	if bmState:Slot("BasicEvents") then
		--table.insert(db, "ABILITY");
		table.insert(db, "MSG");
		table.insert(db, "OMNI");
	end
	return db;
end

function RDXBM.EventCachePopup(db, callback, frame, point, dx, dy)
	local qq = {};
	for _,v in pairs(db) do
		local dbEntry = v;
		table.insert(qq, {
			text = v;
			OnClick = function()
				VFL.poptree:Release();
				callback(dbEntry);
			end
		});
	end
	table.sort(qq, function(x1,x2) return tostring(x1.text) < tostring(x2.text); end);
	table.insert(qq, { text = i18n("WoWEvents not listed...") });
	VFL.poptree:Begin(200, 12, frame, point, dx, dy);
	VFL.poptree:Expand(nil, qq, 20);
end

function RDXBM.CreateEventEdit(parent, text)
	local ui = VFLUI.LabeledEdit:new(parent, 200);
	ui:SetText(text); ui:Show();
	
	local btn = VFLUI.Button:new(ui);
	btn:SetHeight(25); btn:SetWidth(25); btn:SetText("...");
	btn:SetPoint("RIGHT", ui.editBox, "LEFT"); btn:Show();
	btn:SetScript("OnClick", function()
		RDXBM.EventCachePopup(RDXBM._GetEventCache(), function(x) 
			if x then ui.editBox:SetText(x); end
		end, btn, "CENTER");
	end);
	
	ui.Destroy = VFL.hook(function(s)
			btn:Destroy(); btn = nil;
	end, ui.Destroy);
	
	return ui;
end

local AlertID = 9999
--Unique ID's to track alerts for quashing
function RDXBM.GetUniqueAlertID()
	AlertID = AlertID + 1;
	return AlertID;
end

-------------------------------------------
-- BOSSMOD EDITOR
-- just a modified feature editor for bossmods
-------------------------------------------
RDX.IsBossmodEditorOpen = RDX.IsFeatureEditorOpen;

function RDX.BossmodEditor(state, callback, augText)
	local dlg = RDX.FeatureEditor(state, callback, augText);
	if not dlg then return nil; end

	local function GetMobName()
		for idx,fd in ipairs(dlg:GetActiveState():Features()) do
			if fd.feature == "Register Encounter" and fd.bossname then
				return fd.bossname;
			end
		end
		return nil;
	end
	
	local btnToggleListMode = VFLUI.Button:new(dlg);
	btnToggleListMode:SetHeight(25); btnToggleListMode:SetWidth(100);
	btnToggleListMode:SetPoint("BOTTOM", dlg:GetClientArea(), "BOTTOM");
	btnToggleListMode:SetText(i18n("Ability Tracker")); btnToggleListMode:Show();
	btnToggleListMode:SetScript("OnClick", function()
		RDXBM.ToggleTrackerWindow(); 
		local bn = GetMobName(); 
		if bn then RDXBM.SetTrackerWindow(bn, i18n("Choose Ability"));
		else RDXBM.SetTrackerWindow(i18n("<choose mob>"), i18n("Choose Ability")); end
	end);
	

	------ Close procedure
	dlg.Destroy = VFL.hook(function(s)
		btnToggleListMode:Destroy(); btnToggleListMode = nil;
		RDXBM.CloseTrackerWindow();
	end, dlg.Destroy);
end

-------------------------------
-- The universal bossmod state
-------------------------------
RDX.BossmodState = {};
function RDX.BossmodState:new()
	local st = RDX.ObjectState:new();

	st.OnResetSlots = function(state)
		-- Mark this state as a Bossmod
		state:AddSlot("Bossmod", nil);
	end
	
	st.Code = VFL.Snippet:new();
	
	st:Clear();
	return st;
end

local bmState = RDX.BossmodState:new();
RDXBM.GetbmState = function() return bmState; end;

----------------------------------------------------------------------
-- The Bossmod filetype
----------------------------------------------------------------------
local function SetupBossmod(path, desc)
	if (not path) or (not desc) then return nil; end
	-- Load the features.
	bmState:LoadDescriptor(desc);
	bmState:ResetSlots();
		
	local pkg, obj = RDXDB.ParsePath(path);
	
	local errObj = VFL.Error:new();
	errObj:Clear();
	
	local feat = nil;
	for idx,featDesc in ipairs(bmState.features) do
		feat = RDX.GetFeatureByDescriptor(featDesc);
		if feat then
			if errObj then errObj:SetContext(feat.name); end
			if feat.IsPossible(bmState) then
				if feat.ExposeFeature(featDesc, bmState, errObj) then
					feat.ApplyFeature(featDesc, bmState, pkg, obj);
				else
					VFL.AddError(errObj, i18n("Feature options contain errors. Check the Bossmod Editor."));
				end
			else
				VFL.AddError(errObj, i18n("Feature cannot be added. Check that the prerequisites are met."));
			end
		else
			errObj:SetContext(nil);
		end
	end
	
	local code = bmState.Code:GetCode();
	local encid = "bm_"..pkg..obj;
	local setback = false;
	
	local f,err = loadstring(code);
	if not f then
		VFL.TripError("RDX", i18n("Could not compile bossmod at <") .. tostring(path) .. ">", i18n("Error: ") .. err);
	else
		f();
	end
end

local function EditBossmod(parent, path, md)
	if RDX.IsBossmodEditorOpen() then return; end
	bmState:LoadDescriptor(md.data);
	RDX.BossmodEditor(bmState, function(x)
		md.data = x:GetDescriptor();
		RDX.QuashAlertsByPattern("^bm_test");
		RDXDB.NotifyUpdate(path);
	end, path);
end


RDXDB.RegisterObjectType({
	name = "Bossmod";
	New = function(path, md)
		md.version = 1;
	end;
	Edit = function(path, md, parent)
		EditBossmod(parent or UIParent, path, md);
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function()
				VFL.poptree:Release();
				EditBossmod(dlg, path, md);
			end
		});
	end;
});

-- Dangerous object filter registration: bossmods could contain lua code.
RDX.RegisterDangerousObjectFilter({
	matchType = "Bossmod";
	Filter = VFL.True;
});

------------------------------------------
-- Update hooks - make sure when a bossmod changes we reload it.
------------------------------------------
RDXDBEvents:Bind("OBJECT_DELETED", nil, function(pkg, file, md)
	if md and md.ty == "Bossmod" then
		RDX.UnregisterEncounter("bm_"..pkg..file);
	end
end);
RDXDBEvents:Bind("OBJECT_MOVED", nil, function(pkg, file, newpkg, newfile, md)
	if md and md.ty == "Bossmod" then
		RDX.UnregisterEncounter("bm_"..pkg..file);
	end
end);
RDXDBEvents:Bind("OBJECT_CREATED", nil, function(pkg, file) 
	local path = RDXDB.MakePath(pkg,file);
	local obj,_,_,ty = RDXDB.GetObjectData(path)
	if ty == "Bossmod" then	SetupBossmod(path, obj.data) end
end);
RDXDBEvents:Bind("OBJECT_UPDATED", nil, function(pkg, file) 
	local path = RDXDB.MakePath(pkg,file);
	local obj,_,_,ty = RDXDB.GetObjectData(path)
	if ty == "Bossmod" then	SetupBossmod(path, obj.data) end
end);

-----------------------------------------
-- Register Bossmod Objects as Encounters
-----------------------------------------
-- run on UI load 
local function ApplyBossmods()
	for pkgName,pkg in pairs(RDXData) do
		for objName,obj in pairs(pkg) do
			if type(obj) == "table" and obj.ty == "Bossmod" then 
				local path = RDXDB.MakePath(pkgName, objName);
				SetupBossmod(path, obj.data)
			end
		end
	end
end
RDX.ApplyBossmods = ApplyBossmods;
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	RDX.ApplyBossmods();
end);

