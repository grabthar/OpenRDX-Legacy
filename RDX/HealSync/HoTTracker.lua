-- HoTTracker.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL. UNLICENSED COPYING IS PROHIBITED.
--
-- Creates a new set class for tracking the current player's HoT spells.

------------------------
-- HoT database
------------------------
local hotSpells = {};
local hotSets = {};
local hotMenu = {};
local hotTimes ={};



function HealSync.AddHoT(id, spell, timer)
	local set = RDX.Set:new();
	set.name = "HoT<" .. spell .. ">";
	set._spell = spell;	set._timer = timer;
	RDX.RegisterSet(set);
	hotSets[id] = set; hotSpells[spell] = set;
	table.insert(hotMenu, {
		text = spell; value= id;
	});
end

local hotMasterSet=RDX.Set:new();
hotMasterSet.name = "All Hots";
RDX.RegisterSet(hotMasterSet);


for i=1, 40 do
    hotTimes[i] = {0,0};
end

-----------------------------------------------
-- Setclass
-----------------------------------------------
RDX.RegisterSetClass({
	name = "myhot";
	title = i18n("Has my Heal-over-Time");
	GetUI = function(parent, desc)
		local id, text = next(hotSets); text = text._spell;
		if desc and desc.hotid and hotSets[desc.hotid] then
			id = desc.hotid; text = hotSets[id]._spell;
		end
		local ui = VFLUI.Dropdown:new(parent, function() return hotMenu; end);
		ui:RawSetSelection(text, id); ui:Show();
		function ui:GetDescriptor()
			local _,val = self:GetSelection();
			return { class = "myhot", hotid = val };
		end
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil end, ui.Destroy);
		return ui;
	end;
	FindSet = function(desc)
		if desc and desc.hotid then return hotSets[desc.hotid]; end
	end;
});

RDX.RegisterSetClass({
	name = "myhot2";
	title = i18n("Has my HOT (multi)");
	GetUI = RDX.TrivialSetFinderUI("myhot2");
	FindSet = function() return hotMasterSet; end;
});

-----------------------------------------------
-- Cast detection
-----------------------------------------------
local targ, spell;
-- When we cast a hot, setup the state vector
WoWEvents:Bind("UNIT_SPELLCAST_SENT", nil, function()
	if hotSpells[arg2] then
		spell = arg2; targ = string.lower(arg4);
	end
end);

-- Reset the internal statevector on spell fail
WoWEvents:Bind("UNIT_SPELLCAST_FAILED", nil, function()
	if(arg1 == "player") then targ = nil; spell = nil; end
end);


-- When the hot succeeds, act on the statevector
local GetUnit = RDX.GetUnitByNameIfInGroup;
WoWEvents:Bind("UNIT_SPELLCAST_SUCCEEDED", nil, function()
	if targ and spell and (arg2 == spell) then
		-- Locate the hotset we will be modifying
		local set = hotSpells[spell]; if not set then return; end
		-- Locate the player we will be adding/removing
		local player = GetUnit(targ); if not player then return; end
		player = player.nid;
		local v = set:_IsMemberByNid(player);
		local time=GetTime();
		if v then
			-- Person is already in set, Remove the old HOT schedule
			VFL.ZMUnschedule(v);
			-- Reschedule them and update their set entry
			local closure = player;
			set:_Poke(player, VFL.ZMSchedule(set._timer, function() set:_Set(closure, false); end));
		else
			-- Person is not in set, put them there.
			local closure = player;
			set:_Set(player, VFL.ZMSchedule(set._timer, function() set:_Set(closure, false); end));
		end

		--Custom shit
		local v = hotMasterSet:_IsMemberByNid(player);
		if v then
			-- Person is already in set, Remove the old HOT schedule
			VFL.ZMUnschedule(v);
			VFL.ZMUnschedule(hotTimes[player][2]);
			-- Reschedule them and update their set entry
			local closure = player;
			hotMasterSet:_Poke(player, VFL.ZMSchedule(set._timer, function() hotMasterSet:_Set(closure, false); end));
			hotTimes[player][1]=time;
			hotTimes[player][2]=VFL.ZMSchedule(set._timer, function() hotTimes[player][1]=0; end);
		else
			-- Person is not in set, put them there.
			local closure = player;
			hotMasterSet:_Set(player, VFL.ZMSchedule(set._timer, function() hotMasterSet:_Set(closure, false); end));
			hotTimes[player][1]=time;
			hotTimes[player][2]=VFL.ZMSchedule(set._timer, function() hotTimes[player][1]=0; end);
		end
	end
	targ=nil; spell=nil;
end);