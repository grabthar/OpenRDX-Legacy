-- DataEngine.lua
-- RDX
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- The Data Engine consists of a package of window features enabling the binding of
-- WoW events to triggers, and the repainting of windows based on the firing of those
-- triggers.

------------------------------------
-- The "Set" Data Source
-- Binds a set to this window as its data source.
------------------------------------
RDX.RegisterFeature({
	name = "Data Source: Set",
	title = "Data Source: Set",
	category = "Data Source";
	IsPossible = function(state)
		if not state:Slot("UnitWindow") then return nil; end
		if not state:Slot("UnitFrame") then return nil; end
		if state:Slot("DataSource") then return nil; end
		if state:Slot("IsSingleUnitFrame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("DataSource");
		if desc and desc.set then
			local path = desc.set;
			local set = RDX.FindSet(path);
			if not set then
				VFL.AddError(errs, i18n("Set pointer is invalid."));
				return nil;
			end
			-- Forward the set export to the ExposeFeature portion, so that features down
			-- the chain can access it.
			state:AddSlot("SetDataSource");
			state:Attach(state:Slot("SetDataSource"), nil, function() return set; end);
			state:AddSlot("DataSourceIterator");
			state:AddSlot("DataSourceSize");
			return true;
		else
			VFL.AddError(errs, i18n("Missing set pointer."));
			return nil;
		end
	end;
	ApplyFeature = function(desc, state)
		local set = RDX.FindSet(desc.set);
	
		-- Basics: bind set iterator and size functions.
		state:_Attach(state:Slot("DataSourceIterator"), nil, function() return set:Iterator(); end);
		state:_Attach(state:Slot("DataSourceSize"), nil, function() return set:GetSize(); end);

		local mux = state:GetSlotValue("Multiplexer");
		mux:Event_SetDataSource(set);

		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = RDX.SetFinder:new(parent);
		if desc.set then ui:SetDescriptor(desc.set); end
		ui:Show();

		local oldGetDescriptor = ui.GetDescriptor; -- lawl
		function ui:GetDescriptor()
			return {feature = "Data Source: Set", set = oldGetDescriptor() };
		end

		ui.Destroy = VFL.hook(function(s)
			s.Verify = nil; s.GetDescriptor = nil;
		end, ui.Destroy);

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Data Source: Set"}; end,
});

------------------------------------
-- The "Set" secure Data Source
-- Binds a set to this window as its data source.
------------------------------------
RDX.RegisterFeature({
	name = "Data Source: Secure Set",
	title = "Data Source: Secure Set",
	category = "Data Source";
	IsPossible = function(state)
		if not state:Slot("UnitWindow") then return nil; end
		if not state:Slot("UnitFrame") then return nil; end
		if state:Slot("DataSource") then return nil; end
		if state:Slot("IsSingleUnitFrame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("DataSource");
		state:AddSlot("SecureDataSource");
		if desc and desc.set then
			local path = desc.set;
			local set = RDX.FindSet(path);
			if not set then
				VFL.AddError(errs, i18n("Set pointer is invalid."));
				return nil;
			end
			-- Forward the set export to the ExposeFeature portion, so that features down
			-- the chain can access it.
			state:AddSlot("SetDataSource");
			state:Attach(state:Slot("SetDataSource"), nil, function() return set; end);
			state:AddSlot("DataSourceIterator");
			state:AddSlot("DataSourceSize");
			return true;
		else
			VFL.AddError(errs, i18n("Missing set pointer."));
			return nil;
		end
	end;
	ApplyFeature = function(desc, state)
		local set = RDX.FindSet(desc.set);
	
		-- Basics: bind set iterator and size functions.
		state:_Attach(state:Slot("DataSourceIterator"), nil, function() return set:Iterator(); end);
		state:_Attach(state:Slot("DataSourceSize"), nil, function() return set:GetSize(); end);

		local mux = state:GetSlotValue("Multiplexer");
		mux:Event_SetDataSource(set);

		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = RDX.SetFinder:new(parent);
		if desc.set then ui:SetDescriptor(desc.set); end
		ui:Show();

		local oldGetDescriptor = ui.GetDescriptor; -- lawl
		function ui:GetDescriptor()
			return {feature = "Data Source: Secure Set", set = oldGetDescriptor() };
		end

		ui.Destroy = VFL.hook(function(s)
			s.Verify = nil; s.GetDescriptor = nil;
		end, ui.Destroy);

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Data Source: Secure Set"}; end,
});

------------------------------------
-- The "Sort" Data Source
-- Binds a Sort to this window as its data source.
------------------------------------
local function _exposeSort(desc, state, errs)
	if desc and desc.sortPath then
		local _,_,_,ty = RDXDB.GetObjectData(desc.sortPath);
		if (not ty) or (not string.find(ty, "Sort$")) then
			VFL.AddError(errs, i18n("Sort pointer is invalid."));
			return nil;
		end
		local sort = RDXDB.GetObjectInstance(desc.sortPath);
		if not sort then
			VFL.AddError(errs, i18n("Could not instantiate Sort object."));
			return nil;
		end
		local set = sort:GetUnderlyingSet();
		if not set then
			VFL.AddError(errs, i18n("Could not get underlying set for Sort object."));
			return nil;
		end
		state:AddSlot("DataSource"); state:AddSlot("SetDataSource"); state:AddSlot("SortDataSource");
		state:AddSlot("DataSourceIterator");
		state:AddSlot("DataSourceSize");
		state:Attach(state:Slot("SetDataSource"), nil, function() return set; end);
		state:Attach(state:Slot("SortDataSource"), nil, function() return sort; end);
		return true;
	else
		VFL.AddError(errs, i18n("Missing sort pointer."));
		return nil;
	end
end

local function _applySort(desc, state)
	local sort = RDXDB.GetObjectInstance(desc.sortPath);

	-- Basic accessor slots.
	state:Attach(state:Slot("DataSourceIterator"), nil, function() return sort:Iterator(); end);
	state:Attach(state:Slot("DataSourceSize"), nil, function() return sort:GetSize(); end);

	local mux = state:GetSlotValue("Multiplexer");
	mux:Event_SortDataSource(sort);

	return true;
end

RDX.RegisterFeature({
	name = "Data Source: Sort",
	title = "Data Source: Sort",
	category = i18n("Data Source");
	IsPossible = function(state)
		if not state:Slot("UnitWindow") then return nil; end
		if not state:Slot("UnitFrame") then return nil; end
		if state:Slot("DataSource") then return nil; end
		if state:Slot("IsSingleUnitFrame") then return nil; end
		return true;
	end,
	ExposeFeature = _exposeSort;
	ApplyFeature = _applySort;
	UIFromDescriptor = function(desc, parent)
		local ui = RDXDB.ObjectFinder:new(parent, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "Sort$")); end);
		ui:SetLabel(i18n("Sort object"));
		if desc and desc.sortPath then ui:SetPath(desc.sortPath); end

		function ui:GetDescriptor()
			return {feature = "Data Source: Sort", sortPath = self:GetPath()};
		end
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil; end, ui.Destroy);

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Data Source: Sort"}; end,
});

RDX.RegisterFeature({
	name = "Data Source: Secure",
	title = "Data Source: Secure Sort",
	category = i18n("Data Source");
	IsPossible = function(state)
		if not state:Slot("UnitWindow") then return nil; end
		if not state:Slot("UnitFrame") then return nil; end
		if state:Slot("DataSource") then return nil; end
		if state:Slot("IsSingleUnitFrame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if not _exposeSort(desc, state, errs) then return nil; end
		state:AddSlot("SecureDataSource");
		return true;
	end;
	ApplyFeature = _applySort;
	UIFromDescriptor = function(desc, parent)
		local ui = RDXDB.ObjectFinder:new(parent, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "SecureSort$")); end);
		ui:SetLabel(i18n("Secure sort"));
		if desc and desc.sortPath then ui:SetPath(desc.sortPath); end

		function ui:GetDescriptor()
			return {feature = "Data Source: Secure", sortPath = self:GetPath()};
		end
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil; end, ui.Destroy);

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Data Source: Secure"}; end,
});

-------------------------------------------------
-- MULTIPLEXER ARGUMENTS FEATURE - Modifies the default parameters of the window's underlying multiplexer.
-------------------------------------------------
RDX.RegisterFeature({
	name = "mp_args"; title = i18n("Multiplexer Parameters"); category = i18n("Repaint Events"); version = 1;
	IsPossible = function(state)
		-- Make sure this is a window.
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("Create") then return nil; end if not state:Slot("Destroy") then return nil; end
		if not state:Slot("Show") then return nil; end if not state:Slot("Hide") then return nil; end
		if state:Slot("MultiplexerArgs") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("MultiplexerArgs");
		state:AddSlot("DefaultPaintMask");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local mux = state:GetSlotValue("Multiplexer");
		mux:SetPeriod(desc.period);
		if tonumber(desc.dpm1) then
			state:SetSlotValue("DefaultPaintMask", tonumber(desc.dpm1));
		else
			state:SetSlotValue("DefaultPaintMask", 0);
		end

		return true;
	end;
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Option: periodic or not
		local chk_periodic = VFLUI.Checkbox:new(ui); chk_periodic:Show();
		local ed_period = VFLUI.Edit:new(chk_periodic); 
		ed_period:SetHeight(24); ed_period:SetWidth(50); ed_period:Show();
		ed_period:SetPoint("RIGHT", chk_periodic, "RIGHT");
		chk_periodic.Destroy = VFL.hook(function() ed_period:Destroy(); end, chk_periodic.Destroy);
		chk_periodic:SetText(i18n("Period (in seconds):"));
		if desc and desc.period then 
			chk_periodic:SetChecked(true); ed_period:SetText(desc.period);
		else 
			chk_periodic:SetChecked();
		end
		ui:InsertFrame(chk_periodic);

		local ed_dpm = VFLUI.LabeledEdit:new(ui, 50);
		ed_dpm:SetText(i18n("Default paint mask")); ed_dpm:Show();
		if desc and tonumber(desc.dpm1) then 	
			ed_dpm.editBox:SetText(desc.dpm1);
		else
			ed_dpm.editBox:SetText(0);
		end
		ui:InsertFrame(ed_dpm);

		function ui:GetDescriptor()
			local period = nil; 
			if chk_periodic:GetChecked() then 
				period = VFL.clamp(ed_period:GetNumber(), .01, 5);
			end
			local dpm = tonumber(ed_dpm.editBox:GetText()) or 0;
			return { 
				feature = "mp_args"; version = 1; 
				period = period;
				dpm1 = dpm;
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "mp_args"; version = 1; period = .075; dpm1 = 0;
		};
	end;
});

-- Update old multiplexers
RDX.RegisterFeature({
	name = "mp_periodic";	version = 31337;
	invisible = true; IsPossible = VFL.Nil;
	VersionMismatch = function(desc)
		desc.feature = "mp_args"; desc.version = 1;
		return true;
	end;
});


RDX.RegisterFeature({
	name = "Periodic Multiplexer"; version = 31337;
	invisible = true;
	IsPossible = VFL.Nil;
	VersionMismatch = function(desc)
		desc.feature = "mp_args"; desc.version = 1; desc.period = 0.075;
		return true;
	end;
});

RDX.RegisterFeature({
	name = "Null Multiplexer"; version = 31337;
	invisible = true; IsPossible = VFL.Nil;
	VersionMismatch = function(desc)
		desc.feature = "mp_args"; desc.version = 1; desc.period = nil;
		return true;
	end;
});

--- The No Event Hinting feature - disables event hinting on the underlying window.
RDX.RegisterFeature({
	name = "No Hinting";
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Layout") then return nil; end
		if state:Slot("ArtWindow") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		return true;
	end;
	ApplyFeature = function(desc, state)
		local mux = state:GetSlotValue("Multiplexer");
		mux:SetNoHinting(true);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "No Hinting"; }; end;
});

----------------------------------------------------------------------
-- EVENT BINDINGS
----------------------------------------------------------------------
local numToSlot = { "RepaintAll", "RepaintLayout", "RepaintSort", "RepaintData" };
local slotToNum = VFL.invert(numToSlot);

-- Create the generic UI that allows the selection of an event to bind to.
function RDXUI.GenerateEventBindingSlotSelector(parent, feature, selection)
	local self = VFLUI.RadioGroup:new(parent);
	self:SetLayout(4,1);
	self.buttons[1]:SetText(i18n("RepaintAll"));
	self.buttons[2]:SetText(i18n("RepaintLayout"));
	self.buttons[3]:SetText(i18n("RepaintSort"));
	self.buttons[4]:SetText(i18n("RepaintData"));

	if selection then
		self:SetValue(slotToNum[selection] or 1);
	else
		self:SetValue(1);
	end

	function self:GetDescriptor()
		return {feature = feature, slot = (numToSlot[self:GetValue()] or "RepaintAll")};
	end

	self.Destroy = VFL.hook(function(s)
		s.GetDescriptor = nil;
	end, self.Destroy);

	return self;
end

-- An event trigger that periodically triggers a RepaintAll.
RDX.RegisterFeature({
	name = "Event: Periodic Repaint",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("RepaintAll") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		if not state:Slot("Destroy") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("RepaintAllArgs");
		if desc and desc.interval and desc.slot then
			return true;
		else
			VFL.AddError(errs, i18n("Missing parameters."));
			return nil;
		end
	end;
	ApplyFeature = function(desc, state)
		local schedEnt, updater, interval = nil, VFL.Noop, desc.interval;
		schedEnt = "pra" .. math.random(1, 1000000000);
		local slot = desc.slot;
		state:Attach("Show", true, function(w)
			VFL.AdaptiveSchedule(schedEnt, interval, w[slot]); 
		end);
		-- When we hide, disable the updates
		state:Attach("Hide", true, function() VFL.AdaptiveUnschedule(schedEnt); end);
		state:Attach("Destroy", true, function() VFL.AdaptiveUnschedule(schedEnt); end);

		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);

		local rg_slot = VFLUI.RadioGroup:new(parent);
		rg_slot:SetLayout(4,1);
		rg_slot.buttons[1]:SetText(i18n("RepaintAll"));
		rg_slot.buttons[2]:SetText(i18n("RepaintLayout"));
		rg_slot.buttons[3]:SetText(i18n("RepaintSort"));
		rg_slot.buttons[4]:SetText(i18n("RepaintData"));
		if desc.slot then
			rg_slot:SetValue(slotToNum[desc.slot] or 1);
		else
			rg_slot:SetValue(1);
		end
		ui:InsertFrame(rg_slot);

		local iv = VFLUI.LabeledEdit:new(ui, 50);
		iv:SetText(i18n("Update interval (sec)")); iv:Show();
		if desc and desc.interval then 
			iv.editBox:SetText(desc.interval);
		end
		ui:InsertFrame(iv);

		function ui:GetDescriptor()
			return {
				feature = "Event: Periodic Repaint"; 
				interval = iv.editBox:GetNumber();
				slot = (numToSlot[rg_slot:GetValue()] or "RepaintAll")
			};
		end

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Event: Periodic Repaint", interval=0.1, slot = "RepaintAll"}; end,	
});

-----------------------------------------------------------------------
-- MANUAL EVENTS
-----------------------------------------------------------------------
--- Event: Show = fires whenever the window is freshly shown
RDX.RegisterFeature({
	name = "Event: Show",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("EventMultiplexer") then return nil; end
		return true;
	end,
	ExposeFeature = VFL.True;
	ApplyFeature = function(desc, state)
		-- On show, update
		local slot = desc.slot;
		state:_Attach(state:Slot("Show"), true, function(w) w[slot](); end);
		return true;
	end,
	Verify = VFL.True,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateEventBindingSlotSelector(parent, "Event: Show", desc.slot);
	end,
	CreateDescriptor = function() return {feature = "Event: Show", slot = "RepaintAll"}; end
});

--- Event: Set Delta = fires whenever the underlying set changes its content
RDX.RegisterFeature({
	name = "Event: Set Delta"; category = i18n("Repaint Events");
	invisible = true;
	IsPossible = VFL.True;
	ExposeFeature = VFL.True;
	ApplyFeature = VFL.True;
	Verify = VFL.True;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return {feature = "Event: Set Delta"}; end
});

--- Event: External Set Delta = fires whenever some external set changes its content.
RDX.RegisterFeature({
	name = "Event: External Set Delta",
	category = i18n("Repaint Events");
	multiple = true,
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if desc and desc.set then
			local set = RDX.FindSet(desc.set);
			if not set then
				VFL.AddError(errs, i18n("Invalid set pointer."));
				return nil;
			end
			return true;
		else
			VFL.AddError(errs, i18n("Bad or missing set pointer"));
			return nil;
		end
	end;
	ApplyFeature = function(desc, state)
		-- Assemble required metadata
		local set = RDX.FindSet(desc.set);
		local slot = desc.slot;
		-- On show, bind events
		state:_Attach(state:Slot("Show"), true, function(w)
			local f = w[slot];
			if f then set:ConnectDelta(w, f); end
		end);
		-- On hide, unbind events
		state:_Attach(state:Slot("Hide"), true, function(w)
			set:RemoveDelta(w);
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);
		local setsel = RDX.SetFinder:new(ui); setsel:Show();
		if desc.set then setsel:SetDescriptor(desc.set); end
		ui:InsertFrame(setsel);
		local slotsel = RDXUI.GenerateEventBindingSlotSelector(parent, nil, desc.slot);
		ui:InsertFrame(slotsel);

		function ui:GetDescriptor()
			return { feature = "Event: External Set Delta";
				set = setsel:GetDescriptor(), slot = (numToSlot[slotsel:GetValue()] or "RepaintAll") };
		end

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Event: External Set Delta", slot = "RepaintAll"}; end
});

--- Event: UNIT_HEALTH = fires whenever UNIT_HEALTH occurs for an event in the set
RDX.RegisterFeature({
	name = "Event: UNIT_HEALTH",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("SetDataSource") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		if not state:Slot("EventMultiplexer") then return nil; end
		return true;
	end,
	ExposeFeature = VFL.True;
	ApplyFeature = function(desc, state)
		-- Assemble required metadata
		local set = (state:GetSlotFunction("SetDataSource"))(); if not set then return nil; end
		local slot = desc.slot;
		-- On show, bind events
		state:_Attach(state:Slot("Show"), true, function(w)
			local f = w[slot];
			RDXEvents:Bind("UNIT_HEALTH", nil, function(unit)
				if set:IsMember(unit) then f(); end
			end, w);
		end);
		-- On hide, unbind events
		state:_Attach(state:Slot("Hide"), true, function(w)
			RDXEvents:Unbind(w, "UNIT_HEALTH");
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateEventBindingSlotSelector(parent, "Event: UNIT_HEALTH", desc.slot);
	end,
	CreateDescriptor = function() return {feature = "Event: UNIT_HEALTH", slot = "RepaintAll"}; end
});

--- Event: UNIT_POWER = fires whenever UNIT_POWER occurs for an event in the set
RDX.RegisterFeature({
	name = "Event: UNIT_POWER",
	title = "Event: UNIT_POWER",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("SetDataSource") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		if not state:Slot("EventMultiplexer") then return nil; end
		return true;
	end,
	ExposeFeature = VFL.True;
	ApplyFeature = function(desc, state)
		-- Assemble required metadata
		local set = (state:GetSlotFunction("SetDataSource"))(); if not set then return nil; end
		local slot = desc.slot;
		-- On show, bind events
		state:_Attach(state:Slot("Show"), true, function(w)
			local f = w[slot];
			RDXEvents:Bind("UNIT_POWER", nil, function(unit)
				if set:IsMember(unit) then f(); end
			end, w);
		end);
		-- On hide, unbind events
		state:_Attach(state:Slot("Hide"), true, function(w)
			RDXEvents:Unbind(w, "UNIT_POWER");
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateEventBindingSlotSelector(parent, "Event: UNIT_POWER", desc.slot);
	end,
	CreateDescriptor = function() return {feature = "Event: UNIT_POWER", slot = "RepaintAll"}; end
});

--- Event: ROSTER_UPDATE = fires whenever ROSTER_UPDATE occurs
RDX.RegisterFeature({
	name = "Event: ROSTER_UPDATE"; invisible = true;
	IsPossible = VFL.True;
	ExposeFeature = VFL.True;
	ApplyFeature = VFL.True;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return {feature = "Event: ROSTER_UPDATE"}; end
});

--- Event: RDX Aura Delta = fires whenever the RDX Aura information for a unit in this set changes.
RDX.RegisterFeature({
	name = "Event: RDX Aura Delta",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("SetDataSource") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		if not state:Slot("EventMultiplexer") then return nil; end
		return true;
	end,
	ExposeFeature = VFL.True;
	ApplyFeature = function(desc, state)
		-- Assemble required metadata
		local set = (state:GetSlotFunction("SetDataSource"))(); if not set then return nil; end
		local slot = desc.slot;
		-- On show, bind events
		state:_Attach(state:Slot("Show"), true, function(w)
			local f = w[slot];
			local function updater(unit)
				if set:IsMember(unit) then f(); end
			end
			RDXEvents:Bind("UNIT_BUFF_*", nil, updater, w);
			RDXEvents:Bind("UNIT_DEBUFF_*", nil, updater, w);
		end);
		-- On hide, unbind events
		state:_Attach(state:Slot("Hide"), true, function(w)
			RDXEvents:Unbind(w, "UNIT_BUFF_*");
			RDXEvents:Unbind(w, "UNIT_DEBUFF_*");
		end);
		return true;
	end,
	Verify = VFL.True,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateEventBindingSlotSelector(parent, "Event: RDX Aura Delta", desc.slot);
	end,
	CreateDescriptor = function() return {feature = "Event: RDX Aura Delta"}; end
});

--- Event: PLAYER_TARGET_CHANGED
RDX.RegisterFeature({
	name = "Event: PLAYER_TARGET_CHANGED",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		return true;
	end,
	ExposeFeature = VFL.True;
	ApplyFeature = function(desc, state)
		-- Assemble required metadata
		local slot = desc.slot;
		-- On show, bind events
		state:_Attach(state:Slot("Show"), true, function(w)
			if w[slot] then	WoWEvents:Bind("PLAYER_TARGET_CHANGED", nil, w[slot], w);	end
		end);
		-- On hide, unbind events
		state:_Attach(state:Slot("Hide"), true, function(w)
			WoWEvents:Unbind(w, "PLAYER_TARGET_CHANGED");
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateEventBindingSlotSelector(parent, "Event: PLAYER_TARGET_CHANGED", desc.slot);
	end,
	CreateDescriptor = function() return {feature = "Event: PLAYER_TARGET_CHANGED"}; end
});

--- Event: PLAYER_FOCUS_CHANGED
RDX.RegisterFeature({
	name = "Event: PLAYER_FOCUS_CHANGED",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		return true;
	end,
	ExposeFeature = VFL.True;
	ApplyFeature = function(desc, state)
		-- Assemble required metadata
		local slot = desc.slot;
		-- On show, bind events
		state:_Attach(state:Slot("Show"), true, function(w)
			if w[slot] then	WoWEvents:Bind("PLAYER_FOCUS_CHANGED", nil, w[slot], w);	end
		end);
		-- On hide, unbind events
		state:_Attach(state:Slot("Hide"), true, function(w)
			WoWEvents:Unbind(w, "PLAYER_FOCUS_CHANGED");
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateEventBindingSlotSelector(parent, "Event: PLAYER_FOCUS_CHANGED", desc.slot);
	end,
	CreateDescriptor = function() return {feature = "Event: PLAYER_FOCUS_CHANGED"}; end
});

RDX.RegisterFeature({
	name = "Event: UNIT_TARGET_CHANGED",
	category = i18n("Repaint Events");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		if not state:Slot("Show") then return nil; end
		if not state:Slot("Hide") then return nil; end
		return true;
	end,
	ExposeFeature = VFL.True;
	ApplyFeature = function(desc, state)
		-- Assemble required metadata
		local slot = desc.slot;
		-- On show, bind events
		state:_Attach(state:Slot("Show"), true, function(w)
			if w[slot] then	WoWEvents:Bind("UNIT_TARGET", nil, w[slot], w);	end
		end);
		-- On hide, unbind events
		state:_Attach(state:Slot("Hide"), true, function(w)
			WoWEvents:Unbind(w, "UNIT_TARGET");
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateEventBindingSlotSelector(parent, "Event: UNIT_TARGET_CHANGED", desc.slot);
	end,
	CreateDescriptor = function() return {feature = "Event: UNIT_TARGET_CHANGED"}; end
});
