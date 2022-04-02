-- SWStats_Integration.lua
-- Clockwork - Overrated - Korgath
--
-- Pull data from a running instance of SWStats and use it to drive RDX sorts,
-- sets, and variables.

local clamp, tsort, tinsert, strlower = VFL.clamp, table.sort, table.insert, string.lower;
local GetUnitByName = RDX.GetUnitByNameIfInGroup;
local sig_unit_swstats = RDXEvents:LockSignal("UNIT_SWSTATS");
local sig_any_swstats = RDXEvents:LockSignal("SWSTATS_UPDATED");

----------------------------------------------------------
-- UNIT API MODS
-- Add functions to the Unit objects to query their SWStats info.
----------------------------------------------------------
RDX.Unit.GetSWStatsInfo = function()
	return 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0;
end;
RDX.Unit.DamageDone = VFL.Zero;
RDX.Unit.HealingDone = VFL.Zero;
RDX.Unit.DamageTaken = VFL.Zero;
RDX.Unit.HealingTaken = VFL.Zero;

local damagedone_max, healingdone_max, damagetaken_max, healingtaken_max = 1, 1, 1, 1;
local damagedone_total, healingdone_total, damagetaken_total, healingtaken_total = 0, 0, 0, 0;

RDXEvents:Bind("NDATA_CREATED", nil, function(ndata, name)
	local t = {};

	t.damagedone = 0; t.healingdone = 0; t.damagetaken = 0; t.healingtaken = 0;

	ndata.GetSWStatsInfo = function(x)
		return t.damagedone, t.healingdone, t.damagetaken, t.healingtaken, damagedone_max, healingdone_max, damagetaken_max, healingtaken_max, damagedone_total, healingdone_total, damagetaken_total, healingtaken_total;
	end;
	ndata.DamageDone = function()
		return t.damagedone;
	end;
	ndata.HealingDone = function()
		return t.healingdone;
	end
	ndata.DamageTaken = function()
		return t.damagetaken;
	end
	ndata.HealingTaken = function()
		return t.healingtaken;
	end

	ndata:SetNField("swstats", t);
end);

----------------------------------------------------------
-- SWSTATS HACKS
-- Find SWStats and pump the data into RDX if possible.
----------------------------------------------------------
local deltatbl = {};
local function updateswstats()
	-- Reset totals
	damagedone_max = 1;	healingdone_max = 1; damagetaken_max = 1;	healingtaken_max = 1;
	damagedone_total = 0;	healingdone_total = 0; damagetaken_total = 0;	healingtaken_total = 0;

	local anyChange = false;

	for _,unit in RDX.Group() do
		local x,name = unit:GetNField("swstats"), unit:GetProperName();
		if x then
			if not x.index then x.index = SW_StrTable:getID(name); end
			local index = x.index;
			if index then
				local unitData = SW_DataCollection.activeSegment[index];
				if unitData then
					local change,y = false,0;

					-- dmg done
					y = unitData:getDmgDone();
					if x.damagedone ~= y then x.damagedone = y; change = true; end
					if y > damagedone_max then damagedone_max = y; end
					damagedone_total = damagedone_total + y;
					-- healing done
					y = unitData:getEffectiveHealDone();
					if x.healingdone ~= y then x.healingdone = y; change = true; end
					if y > healingdone_max then healingdone_max = y; end
					healingdone_total = healingdone_total + y;
					-- dmg taken
					y = unitData:getDmgRecieved();
					if x.damagetaken ~= y then x.damagetaken = y; change = true; end
					if y > damagetaken_max then damagetaken_max = y; end
					damagetaken_total = damagetaken_total + y;
					-- healing taken
					y = unitData:getEffectiveHealRecieved();
					if x.healingtaken ~= y then x.healingtaken = y; change = true; end
					if y > healingtaken_max then healingtaken_max = y; end
					healingtaken_total = healingtaken_total + y;
					

					if change then 
						deltatbl[unit] = true; anyChange = true; 
					end
				else -- if unitData
					x.damagedone = 0; x.healingdone = 0; x.damagetaken = 0; x.healingtaken = 0;
				end -- if unitData
			end -- if index
		end -- if x
	end -- for _,unit in RDX.Group()

	for k in pairs(deltatbl) do
		deltatbl[k] = nil;
		sig_unit_swstats:Raise(k, k.nid, k.uid);
	end
	if anyChange then sig_any_swstats:Raise(); end
end

-- Main init, find SWStats
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	if (type(SW_DataCollection) == "table") then
		RDX.print(i18n("SWStats found. Watching SWStats data"));
		VFL.AdaptiveSchedule("sws_update", 0.5, updateswstats);
	end
end);

------------------------------------------------
-- SWSTATS UNITFRAME VARS
------------------------------------------------
--- Unit frame variables for SWStats data.
RDX.RegisterFeature({
	name = "var_swstats";
	title = i18n("Vars: SWStats (damage,healing/done,taken)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_damagedone") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_damagedone"); state:AddSlot("Var_healingdone"); state:AddSlot("Var_damagetaken"); state:AddSlot("Var_healingtaken");
		state:AddSlot("FracVar_fdamagedone"); state:AddSlot("FracVar_fhealingdone"); state:AddSlot("FracVar_fdamagetaken"); state:AddSlot("FracVar_fhealingtaken"); 
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local damagedone, healingdone, damagetaken, healingtaken, damagedone_max, healingdone_max, damagetaken_max, healingtaken_max, damagedone_total, healingdone_total, damagetaken_total, healingtaken_total = unit:GetSWStatsInfo();
--VFL.print("dd : " .. damagedone);
--VFL.print("ddmax : " .. damagedone_max);
--VFL.print("ddtotale : " .. damagedone_total);
local fdamagedone, fhealingdone, fdamagetaken, fhealingtaken = VFL.clamp(damagedone/damagedone_max, 0, 1), VFL.clamp(healingdone/healingdone_max, 0, 1), VFL.clamp(damagetaken/damagetaken_max, 0, 1), VFL.clamp(healingtaken/healingtaken_max, 0, 1);
]]); end);
		-- Event hinting
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("SWSTATS_UPDATED", mux:GetPaintMask("SWSTATS"));
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_swstats" }; end
});

----------------------------------------------------------
-- SWSTATS FILTER
----------------------------------------------------------
RDX.RegisterFilterComponent({
	name = "swstats", title = i18n("SWStats..."), category = i18n("Unit Status"),
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("SWStats...")); ui:Show();
		local container = VFLUI.CompoundFrame:new(ui);
		ui:SetChild(container); container:Show();

		local perc_numer = VFLUI.RadioGroup:new(container);
		container:InsertFrame(perc_numer);
		perc_numer:SetLayout(4, 4);
		perc_numer.buttons[1]:SetText(i18n("Damage Done"));
		perc_numer.buttons[2]:SetText(i18n("Healing Done"));
		perc_numer.buttons[3]:SetText(i18n("Damage Taken"));
		perc_numer.buttons[4]:SetText(i18n("Healing Taken"));
		perc_numer:SetValue(desc[2]);
		perc_numer:Show();

		local lb = VFLUI.LabeledEdit:new(container, 50);
		container:InsertFrame(lb);
		lb:SetText(i18n("Lower bound")); lb.editBox:SetText(desc[3]);
		lb:Show();
		local ub = VFLUI.LabeledEdit:new(container, 50);
		container:InsertFrame(ub);
		ub:SetText(i18n("Upper bound")); ub.editBox:SetText(desc[4]);
		ub:Show();

		ui.GetDescriptor = function(x)
			local lwr = lb.editBox:GetNumber(); if (not lwr) or (lwr < 0) then lwr = 0; end
			local upr = ub.editBox:GetNumber(); if (not upr) or (upr < 0) then upr = 1; end
			if(upr < lwr) then local temp = upr; upr = lwr; lwr = temp; end
			return {"swstats", perc_numer:GetValue(), lwr, upr};
		end

		return ui;
	end,
	GetBlankDescriptor = function() return {"swstats", 1, 10000, 10000000}; end,
	FilterFromDescriptor = function(desc, metadata)
		local lb, ub, vexpr = desc[3], desc[4];
		-- Figure out which stat we want to use
		if desc[2] == 1 then -- damage done
			vexpr = "(unit:DamageDone())";
		elseif desc[2] == 2 then -- healing done
			vexpr = "(unit:HealingDone())";
		elseif desc[2] == 3 then -- damage taken
			vexpr = "(unit:DamageTaken())";
		elseif desc[2] == 4 then -- healing taken
			vexpr = "(unit:HealingTaken())";
		end
		-- Generate the closures/locals
		local vC = RDX.GenerateFilterUpvalue();
		table.insert(metadata, { class = "LOCAL", name = vC, value = vexpr });
		-- Generate the filtration expression.
		return "((" .. vC .. " >= " .. lb ..") and (" .. vC .. " <= " .. ub .."))";
	end;
	ValidateDescriptor = VFL.True;
	SetsFromDescriptor = VFL.Noop;
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_FullUpdate(metadata, "SWSTATS_UPDATED");
	end;
});

----------------------------------------------------------
-- SWSTATS SORT
----------------------------------------------------------
RDX.RegisterSortOperator({
	name = "swstatsdamagedone";
	title = i18n("SWStats Damage Done");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["swstatsdamagedone"] then
			vars["swstatsdamagedone"] = true;
			code:AppendCode([[
local damagedone1,damagedone2 = u1:DamageDone(), u2:DamageDone();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(damagedone1 == damagedone2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return damagedone1 < damagedone2;]]);
		else
			code:AppendCode([[return damagedone1 > damagedone2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("swstatsdamagedone", i18n("SWStats Damage Done"));
	GetBlankDescriptor = function() return {op = "swstatsdamagedone"}; end;
	Events = function(desc, ev) 
		ev["SWSTATS_UPDATED"] = "NOUNIT";
	end;
});

RDX.RegisterSortOperator({
	name = "swstatshealingdone";
	title = i18n("SWStats Healing Done");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["swstatshealingdone"] then
			vars["swstatshealingdone"] = true;
			code:AppendCode([[
local healingdone1,healingdone2 = u1:HealingDone(), u2:HealingDone();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(healingdone1 == healingdone2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return healingdone1 < healingdone2;]]);
		else
			code:AppendCode([[return healingdone1 > healingdone2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("swstatshealingdone", i18n("SWStats Healing Done"));
	GetBlankDescriptor = function() return {op = "swstatshealingdone"}; end;
	Events = function(desc, ev) 
		ev["SWSTATS_UPDATED"] = "NOUNIT";
	end;
});

RDX.RegisterSortOperator({
	name = "swstatsdamagetaken";
	title = i18n("SWStats Damage Taken");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["swstatsdamagetaken"] then
			vars["swstatsdamagetaken"] = true;
			code:AppendCode([[
local damagetaken1,damagetaken2 = u1:DamageTaken(), u2:DamageTaken();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(damagetaken1 == damagetaken2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return damagetaken1 < damagetaken2;]]);
		else
			code:AppendCode([[return damagetaken1 > damagetaken2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("swstatsdamagetaken", i18n("SWStats Damage Taken"));
	GetBlankDescriptor = function() return {op = "swstatsdamagetaken"}; end;
	Events = function(desc, ev) 
		ev["SWSTATS_UPDATED"] = "NOUNIT";
	end;
});

RDX.RegisterSortOperator({
	name = "swstatshealingtaken";
	title = i18n("SWStats Healing Taken");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["swstatshealingtaken"] then
			vars["swstatshealingtaken"] = true;
			code:AppendCode([[
local healingtaken1,healingtaken2 = u1:HealingTaken(), u2:HealingTaken();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(healingtaken1 == healingtaken2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return healingtaken1 < healingtaken2;]]);
		else
			code:AppendCode([[return healingtaken1 > healingtaken2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("swstatshealingtaken", i18n("SWStats Healing Taken"));
	GetBlankDescriptor = function() return {op = "swstatshealingtaken"}; end;
	Events = function(desc, ev) 
		ev["SWSTATS_UPDATED"] = "NOUNIT";
	end;
});
