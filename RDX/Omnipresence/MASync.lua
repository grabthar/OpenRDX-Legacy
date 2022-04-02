-- RDX6_MASync.lua
-- RDX - Raid Data Exchange
-- (C)2006 Will Dobbins
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--

function Logistics.AddAssist(name)
	if name == nil and (UnitInRaid("target") or UnitInParty("target")) then
		name = UnitName("target");
	end
	if(name) then
	    name = string.lower(name);
		local win_set = RDXDB.GetObjectInstance("default:assists");
		win_set:AddName(name);
		local assist_set = RDXDB.GetObjectData("default:assists");
		table.insert(assist_set.data, name);
		if RDXPlayer:IsLeader() then
		    RPC_Group:Flash("sync_assist", assist_set.data);
		end
	else
		VFL.print("Target someone!");
	end
end

function Logistics.DropAssist(name)
	
	if name == nil then name = UnitName("target"); end
	if(name) then
	    name = string.lower(name);
	    local win_set = RDXDB.GetObjectInstance("default:assists");
	    win_set:RemoveName(name);
		local assist_set = RDXDB.GetObjectData("default:assists");
		for k, v in pairs(assist_set.data) do
		    if v == name then
		        table.remove(assist_set.data, k);
			end
		end
		if RDXPlayer:IsLeader() then
		    RPC_Group:Flash("sync_assist", assist_set.data);
		end
	else
		VFL.print("Target someone!");
	end
end

function Logistics.SyncAssists()

	if not RDXPlayer:IsLeader() then return; end
	local assist_set = RDXDB.GetObjectData("default:assists");
	if assist_set then
		RPC_Group:Flash("sync_assist", assist_set.data);
 	end
end

function Logistics.ClearAssists()
	
	local assist_set = RDXDB.GetObjectData("default:assists");
	assist_set.data = {};
	local win_set = RDXDB.GetObjectInstance("default:assists");
	win_set:ClearNames();
	if RDXPlayer:IsLeader() then
		RPC_Group:Flash("sync_assist", assist_set.data);
	end
end

local function RPCSyncAssists(commInfo, names)
	local unit = RPC.GetSenderUnit(commInfo);
	if not unit then return; end

	win_set = RDXDB.GetObjectInstance("default:assists");
	assist_set = RDXDB.GetObjectData("default:assists");
	if not assist_set then VFL.print("assist set not found"); return; end
	assist_set.data = names;
	win_set:ClearNames();
	for k, v in pairs(names) do
	    win_set:AddName(v);
	end
	local ap = RDXDB.CheckObject("Desktops:win_assist", "Window");
	if ap then
		ap = "Desktops:win_assist";
	else
		ap = RDXDB.CheckObject("Builtin:win_assist", "Window");
		if ap then
			ap = "Builtin:win_assist";
		end
	end
	if ap ~= nil then
		RDXDB.OpenObject(ap);
	end
end

---------------------------------------------------
-- RDX INTEGRATION
---------------------------------------------------
--local function MAMenu(tree, frame)
--	local mnu = {};
--	table.insert(mnu, {text = "Add Target to Assists", OnClick = function() AddAssist(); tree:Release(); end});
--	table.insert(mnu, {text = "Remove Target from Assists", OnClick = function() DropAssist(); tree:Release(); end});
--	table.insert(mnu, {text = "Sync Assists", OnClick = function() SyncAssists(); tree:Release(); end});
--	table.insert(mnu, {text = "-------------"});
--	table.insert(mnu, {text = "Clear Assists", OnClick = function() ClearAssists(); tree:Release(); end});
--	tree:Expand(frame, mnu);
--end;
--Logistics.AssistMenu:RegisterMenuEntry("Assists", true, MAMenu);

--[[
Logistics.AssistMenu = RDX.Menu:new();
Logistics.AssistMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Add Target to Assists");
	ent.OnClick = function() VFL.poptree:Release(); AddAssist(); end;
end);
Logistics.AssistMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Remove Target from Assists");
	ent.OnClick = function() VFL.poptree:Release(); DropAssist(); end;
end);
Logistics.AssistMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Sync Assists");
	ent.OnClick = function() VFL.poptree:Release(); SyncAssists(); end;
end);
Logistics.AssistMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("-------------");
	--ent.OnClick = function() VFL.poptree:Release(); AddAssist(); end;
end);
Logistics.AssistMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Clear Assists");
	ent.OnClick = function() VFL.poptree:Release(); ClearAssists(); end;
end);

function Logistics.ShowAssistMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	Logistics.AssistMenu:Open(VFL.poptree, nil);
end
]]
--------------------------------------------------
-- SLASH COMMANDS
--------------------------------------------------
SLASH_RDX6_MASYNC1 = "/rdxsa";
SlashCmdList["RDX6_MASYNC"] = function(arg)
	local _,_,cmd = string.find(arg, "^(%w+)");
	local _,_,name = string.find(arg, "(%w+)$"); -- I'm sure this could be done more efficiently by someone more
	if cmd == name then name = nil; end          -- more familiar with find function :P
	if(cmd == "add") then
		Logistics.AddAssist(name);
	elseif(cmd == "drop") then
		Logistics.DropAssist(name);
	elseif(cmd == "sync") then
		Logistics.SyncAssists();
	elseif(cmd == "clear") then
		Logistics.ClearAssists();
	else
		VFL.print("ERROR: Usage: /rdxsa add [playername]");
		VFL.print("              /rdxsa drop [playername]");
		VFL.print("              /rdxsa sync");
		VFL.print("              /rdxsa clear");
		VFL.print("arg was ", arg);
	end
end

--------------------------------------------------
-- Bind RPC's
--------------------------------------------------
RPC_Group:Bind("sync_assist", RPCSyncAssists);

