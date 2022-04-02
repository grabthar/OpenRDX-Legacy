-- IncHealingSet.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Special set class containing all units who are currently casting heals on a
-- given unit.

------------------------------------------------------------------------
-- Healing Synchronization module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
--
-- Note:
--  Licensed exclusively to Raid Informatics
------------------------------------------------------------------------

-------------------------
-- Incoming Healing set class - the set of all healers healing a given target.
-------------------------
-- Periodic updater queue. Sets with non primary unit IDs require periodic updating
-- rather than event-driven updating.
local updateq = {};
local function UpdateQueue()
	for set,_ in pairs(updateq) do
		if set:IsOpen() then set:_Update(); end
	end
end
local function IncRef(set)
	local psz = VFL.tsize(updateq);
	updateq[set] = true;
	VFL.AdaptiveUnschedule("_healset");
	if psz == 0 then VFL.AdaptiveSchedule("_healset", .1, UpdateQueue); end
end
local function DecRef(set)
	updateq[set] = nil;
	if VFL.tsize(updateq) == 0 then VFL.AdaptiveUnschedule("_healset"); end
end

-- Create an incoming heal set
local function CreateIncHealSet(name)
	local self = RDX.Set:new();
	self.name = "IncHealing<" .. name .. ">";
		
	-- do what it says, call when healdb_updated
	local function UpdateHealers(x)
		local n = UnitName(name) or name;
		if not n then return; end
		n = RDX.GetUnitByNameIfInGroup(string.lower(n));
		if not n then return; end
		local hh = n:_HealersNIDHash();
		if not hh then return; end
		RDX.BeginEventBatch();
		for i=1,40 do x:_Set(i, hh[i]);	end
		RDX.EndEventBatch();
	end
	self._Update = UpdateHealers;

	-- The function invoked when a HealDB event triggers.
	local function OnIncomingHealsChanged(x, unit)
		if (unit.name == name) then UpdateHealers(x);	end
	end

	-- On deactivate, unbind us from everything
	self._OnDeactivate = function(x) RDXEvents:Unbind(x); WoWEvents:Unbind(x); end
	
	-- Bind/unbind events on act/deact, depending on the unit input
	if name == "target" then
		self._OnActivate = function(x)
			WoWEvents:Bind("PLAYER_TARGET_CHANGED", x, UpdateHealers, x);
			RDXEvents:Bind("UNIT_INCOMING_HEALS", x, UpdateHealers, x);
			UpdateHealers(x);
		end;
	elseif RDX.GetUnitByNameIfInGroup(name) then
		self._OnActivate = function(x)
			RDXEvents:Bind("UNIT_INCOMING_HEALS", x, OnIncomingHealsChanged, x);
			UpdateHealers(x);
		end;
	else
		self._OnActivate = function(x)
			RDXEvents:Bind("UNIT_INCOMING_HEALS", x, UpdateHealers, x);
			UpdateHealers(x);
		end;
	end

	return self;
end

--- Get a set of the healers healing the given target.
local hsets = {};
function RDX.GetIncHealSet(name)
	local ret = hsets[name];
	if not ret then
		ret = CreateIncHealSet(name);
		RDX.RegisterSet(ret);
		hsets[name] = ret;
	end
	return ret;
end

RDX.RegisterSetClass({
	name = "incheals",
	title = i18n("Incoming Heals"),
	GetUI = function(parent, desc)
		local ui = VFLUI.LabeledEdit:new(parent, 150);
		ui:SetText(i18n("Target name or unitid to track: \"Gibybo\", \"target\", \"focus\", etc")); ui:Show();
		if desc and desc.target then ui.editBox:SetText(desc.target); end

		ui.GetDescriptor = function(x)
			local t = ui.editBox:GetText();
			if(not t) or (t == "") then return nil; end
			t = string.lower(t);
			return {class = "incheals", target = t};
		end;

		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil; end, ui.Destroy);

		return ui;
	end,
	FindSet = function(desc)
		if (not desc) or (not desc.target) then return nil; end
		return RDX.GetIncHealSet(desc.target);
	end
}); 

-- Xenios

RDX.RegisterFilterComponent({
    name = "incHeal", title = "incHeal", category = "Auras",
    UIFromDescriptor = function(desc, parent)
        local ui = RDXUI.FilterDialogFrame:new(parent);
        ui:SetText("incHeal"); ui:Show();
        ui.GetDescriptor = function() return {"incHeal"}; end;
        return ui;
    end,
    GetBlankDescriptor = function() return {"incHeal"}; end,
    FilterFromDescriptor = function(desc, metadata)
        table.insert(metadata, {class = "LOCAL", name = "heal", value = "(unit:IncomingHealth())"})
        return "(heal > 0)"
    end,
    EventsFromDescriptor = function(desc, metadata)
        RDX.FilterEvents_UnitUpdate(metadata, "UNIT_INCOMING_HEALS");
    end,
    SetsFromDescriptor = VFL.Noop,
    ValidateDescriptor = VFL.True,
});

