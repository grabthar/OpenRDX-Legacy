-- Filters.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Filters and Sorts related to the heal sync system.

------------------------------------------------------------------------
-- Healing Synchronization module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
--
-- Note:
--  Licensed exclusively to Raid Informatics
------------------------------------------------------------------------

-- Predicted HP filter
RDX.RegisterFilterComponent({
	name = "shp", title = i18n("Predicted HP..."), category = i18n("Unit Status"),
	UIFromDescriptor = function(desc, parent)
		return RDXUI._GenHPMPFilterUI(desc, parent, i18n("Predicted HP..."), "shp");
	end,
	GetBlankDescriptor = function() return {"shp", 1, 1, 0, 100}; end,
	FilterFromDescriptor = function(desc, metadata)
		local lb, ub, vexpr = desc[4], desc[5], "unit:SmartHealth()";
		-- Figure out whether we want fractional health or total health
		if desc[2] == 1 then -- current
			if desc[3] == 1 then -- current percentage
				lb = VFL.clamp( (lb/100), 0, 1);
				ub = VFL.clamp( (ub/100), 0, 1);
				vexpr = "(unit:FracSmartHealth())";
			else -- current total
				vexpr = "(unit:SmartHealth())";
			end
		elseif desc[2] == 2 then -- missing
			if desc[3] == 1 then -- missing percentage
				lb = VFL.clamp( (lb/100), 0, 1);
				ub = VFL.clamp( (ub/100), 0, 1);
				vexpr = "(1 - unit:FracSmartHealth())";
			else -- missing total
				vexpr = "(unit:MaxHealth() - unit:SmartHealth())";
			end
		elseif desc[2] == 3 then -- max
			vexpr = "(unit:MaxHealth())";
		end
		-- Generate the closures/locals
		local vL, vU, vC = RDX.GenerateFilterUpvalue(), RDX.GenerateFilterUpvalue(), RDX.GenerateFilterUpvalue();
		table.insert(metadata, { class = "CLOSURE", name = vL, script = vL .. "=" .. desc[4] .. ";" });
		table.insert(metadata, { class = "CLOSURE", name = vU, script = vU .. "=" .. desc[5] .. ";" });
		table.insert(metadata, { class = "LOCAL", name = vC, value = vexpr });
		-- Generate the filtration expression.
		return "((" .. vC .. " >= " .. lb ..") and (" .. vC .. " <= " .. ub .."))";
	end;
	ValidateDescriptor = VFL.True;
	SetsFromDescriptor = VFL.Noop;
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_UnitUpdate(metadata, "UNIT_HEALTH");
		RDX.FilterEvents_UnitUpdate(metadata, "UNIT_INCOMING_HEALS");
	end;
});

-- HP% sort.
RDX.RegisterSortOperator({
	name = "shpp";
	title = i18n("Predicted HP%");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["hh"] then
			vars["hh"] = true;
			code:AppendCode([[
local hh1,hh2 = u1:FracSmartHealth(), u2:FracSmartHealth();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(hh1 == hh2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return hh1 > hh2;]]);
		else
			code:AppendCode([[return hh1 < hh2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("shpp", "Predicted HP%");
	GetBlankDescriptor = function() return {op = "shpp"}; end;
	Events = function(desc, ev) 
		ev["UNIT_HEALTH"] = true;
		ev["UNIT_INCOMING_HEALS"] = true;
	end;
});

-- HP sort.
RDX.RegisterSortOperator({
	name = "shp";
	title = i18n("Predicted HP");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["hnfh"] then
			vars["hnfh"] = true;
			code:AppendCode([[
local hnfh1,hnfh2 = u1:SmartHealth(), u2:SmartHealth();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(hnfh1 == hnfh2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return hnfh1 > hnfh2;]]);
		else
			code:AppendCode([[return hnfh1 < hnfh2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("shp", "Predicted HP");
	GetBlankDescriptor = function() return {op = "shp"}; end;
	Events = function(desc, ev) 
		ev["UNIT_HEALTH"] = true;
		ev["UNIT_INCOMING_HEALS"] = true;
	end;
});
