-- omniscience
-- OpenRDX
-- (C)2007 Sigg / Rashgarroth eu

-- this file contains the ndata for damage meter for the UnitDB.

local sig_unit_omnisc = RDXEvents:LockSignal("UNIT_OMNISC");
local interval_update = 2;

----------------------------------------------------------
-- UNIT API MODS
----------------------------------------------------------

local ddone_max, hdone_max, dtaken_max, htaken_max, ohdone_max = 1, 1, 1, 1, 1;
local ddone_total, hdone_total, dtaken_total, htaken_total, ohdone_total = 0, 0, 0, 0, 0;
local tmpddone_max, tmphdone_max, tmpdtaken_max, tmphtaken_max, tmpohdone_max = 1, 1, 1, 1, 1;
local tmpddone_total, tmphdone_total, tmpdtaken_total, tmphtaken_total, tmpohdone_total = 0, 0, 0, 0, 0;
local omniddone, omnihdone, omnidtaken, omnihtaken, omniohdone = 0, 0, 0, 0, 0;
local lastddone, dps, lastdps, lasthdone, hps, lasthps = 0, 0, 0, 0, 0, 0;

RDX.Unit.OmniGetInfo = function()
	return 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0;
end

-- DDone  Damage done
-- HDone  Healing done
-- DTaken Damage taken
-- HTaken Healing taken
-- OHDone OverHealing done

RDX.Unit.OmniResetInfo = VFL.Zero;
RDX.Unit.OmniDDone = VFL.Zero;
RDX.Unit.OmniHDone = VFL.Zero;
RDX.Unit.OmniDTaken = VFL.Zero;
RDX.Unit.OmniHTaken = VFL.Zero;
RDX.Unit.OmniOHDone = VFL.Zero;
RDX.Unit.OmniDPS = VFL.Zero;
RDX.Unit.OmniHPS = VFL.Zero;

-- EDATA extension data for a unit by id
RDXEvents:Bind("EDATA_CREATED", nil, function(edata, idx)
	
	local t = {};
	t.ddone = 0;
	t.hdone = 0;
	t.dtaken = 0;
	t.htaken = 0;
	t.ohdone = 0;
	t.dps = 0;
	t.hps = 0;
	
	edata.OmniGetInfo = function()
		return t.ddone, t.hdone, t.dtaken, t.htaken, t.ohdone, ddone_max, hdone_max, dtaken_max, htaken_max, ohdone_max, ddone_total, hdone_total, dtaken_total, htaken_total, ohdone_total, t.dps, t.hps;
	end;
	
	edata.OmniResetInfo = function()
		t.ddone = 0; 
		t.hdone = 0; 
		t.dtaken = 0; 
		t.htaken = 0;
		t.ohdone = 0;
		t.dps = 0;
		t.hps = 0;
	end;
	
	edata.OmniDDone = function() return t.ddone; end;
	edata.OmniHDone = function() return t.hdone; end
	edata.OmniDTaken = function() return t.dtaken; end
	edata.OmniHTaken = function() return t.htaken; end
	edata.OmniOHDone = function() return t.ohdone; end
	edata.OmniDPS = function() return t.dps; end
	edata.OmniHPS = function() return t.hps; end
	
	edata.OmniSetDDone = function(am) t.ddone = am; end
	edata.OmniSetHDone = function(am) t.hdone = am; end
	edata.OmniSetDTaken = function(am) t.dtaken = am; end
	edata.OmniSetHTaken = function(am) t.htaken = am; end
	edata.OmniSetOHDone = function(am) t.ohdone = am; end
	edata.OmniSetDPS = function(am) t.dps = am; end
	edata.OmniSetHPS = function(am) t.hps = am; end
	
	edata:SetEField("omniscience", t);
end);

-----------------------------------------------------
-- damagemeter
-----------------------------------------------------

-- function uploadDamagefromOmniDB and aggregate data
local SAMPLESIZE = 5; 
local fWeight = ( (SAMPLESIZE-1)/SAMPLESIZE );
local sWeight = 1 - fWeight;

local function uploadInfofromOmniDB()
	tmpddone_total, tmphdone_total, tmpdtaken_total, tmphtaken_total, tmpohdone_total = 0, 0, 0, 0, 0;
	tmpddone_max, tmphdone_max, tmpdtaken_max, tmphtaken_max, tmpohdone_max = 1, 1, 1, 1, 1;
	omniddone, omnihdone, omnidtaken, omnihtaken, omniohdone = 0, 0, 0, 0, 0;
	for _,unit in RDX.RaidAll() do
		if unit:IsCacheValid() then
			omnidtaken, omniddone, omnihtaken, omnihdone, omniohdone = OmniDB.GetGUIDInfo(unit.guid, unit.name);
			tmpddone_total = tmpddone_total + omniddone;
			tmphdone_total = tmphdone_total + omnihdone;
			tmpdtaken_total = tmpdtaken_total + omnidtaken;
			tmphtaken_total = tmphtaken_total + omnihtaken;
			tmpohdone_total = tmpohdone_total + omniohdone;
			if (omniddone > tmpddone_max) then tmpddone_max = omniddone; end
			if (omnihdone > tmphdone_max) then tmphdone_max = omnihdone; end
			if (omnidtaken > tmpdtaken_max) then tmpdtaken_max = omnidtaken; end
			if (omnihtaken > tmphtaken_max) then tmphtaken_max = omnihtaken; end
			if (omniohdone > tmpohdone_max) then tmpohdone_max = omniohdone; end
			
			lastddone = unit.OmniDDone();
			lasthdone = unit.OmniHDone();
			lastdps = unit.OmniDPS();
			lasthps = unit.OmniHPS();
			dps = (omniddone - lastddone) / interval_update;
			hps = (omnihdone - lasthdone) / interval_update;
			if lastdps < 50 then
				unit.OmniSetDPS(dps);
			else
				unit.OmniSetDPS((lastdps * fWeight) + (dps * sWeight));
			end
			if lasthps < 50 then
				unit.OmniSetHPS(hps);
			else
				unit.OmniSetHPS((lasthps * fWeight) + (hps * sWeight));
			end
			
			unit.OmniSetDDone(omniddone);
			unit.OmniSetHDone(omnihdone);
			unit.OmniSetDTaken(omnidtaken);
			unit.OmniSetHTaken(omnihtaken);
			unit.OmniSetOHDone(omniohdone);
		end
	end
	ddone_total, hdone_total, dtaken_total, htaken_total, ohdone_total = tmpddone_total, tmphdone_total, tmpdtaken_total, tmphtaken_total, tmpohdone_total;
	ddone_max, hdone_max, dtaken_max, htaken_max, ohdone_max = tmpddone_max, tmphdone_max, tmpdtaken_max, tmphtaken_max, tmpohdone_max;
	
	RDX.BeginEventBatch();
	for _,unit in RDX.RaidAll() do
		if unit:IsCacheValid() then
			sig_unit_omnisc:Raise(unit, unit.nid, unit.uid);
		end
	end
	RDX.EndEventBatch();
end

VFLP.RegisterFunc("RDX Omniscience", "OmniMeters update", uploadInfofromOmniDB, true);

------------------------------------------------
-- INIT
------------------------------------------------
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	if RDXG.UseOmniMeters then RDX.OmniUnitEnable(); end
end);

-----------------------------------------------
-- Omnimeters enable/disable
-----------------------------------------------
function RDX.OmniUnitEnable()
	VFL.AdaptiveUnschedule("OmniUnit_update");
	VFL.AdaptiveSchedule("OmniUnit_update", interval_update, uploadInfofromOmniDB);
end

function RDX.OmniUnitDisable()
	VFL.AdaptiveUnschedule("OmniUnit_update");
end

------------------------------------------------
-- Omniscience UNITFRAME VARS
------------------------------------------------
--- Unit frame variables for Omniscience data.

RDX.RegisterFeature({
	name = "var_omniscience";
	title = i18n("Vars: OmniMeters (damage,healing,overhealing/done,taken)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_damagedone") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_damagedone"); state:AddSlot("Var_healingdone"); state:AddSlot("Var_damagetaken"); state:AddSlot("Var_healingtaken"); state:AddSlot("Var_overhealingdone");
		state:AddSlot("BoolVar_bdamagedone"); state:AddSlot("BoolVar_bhealingdone"); state:AddSlot("BoolVar_bdamagetaken"); state:AddSlot("BoolVar_bhealingtaken"); state:AddSlot("BoolVar_boverhealingdone");
		state:AddSlot("FracVar_fdamagedone"); state:AddSlot("FracVar_fhealingdone"); state:AddSlot("FracVar_fdamagetaken"); state:AddSlot("FracVar_fhealingtaken"); state:AddSlot("FracVar_foverhealingdone");
		state:AddSlot("TextData_damagedone_text"); state:AddSlot("TextData_healingdone_text"); state:AddSlot("TextData_damagetaken_text"); state:AddSlot("TextData_healingtaken_text"); state:AddSlot("TextData_overhealingdone_text");
		state:AddSlot("TextData_dps_text"); state:AddSlot("TextData_hps_text");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitClosure"), true, function(code) code:AppendCode([[
local damagedone, healingdone, damagetaken, healingtaken, overhealingdone, damagedone_max, healingdone_max, damagetaken_max, healingtaken_max, overhealingdone_max, damagedone_total, healingdone_total, damagetaken_total, healingtaken_total, overhealingdone_total, dps, hps;
local bdamagedone, bhealingdone, bdamagetaken, bhealingtaken, boverhealingdone = false, false, false, false, false;
local damagedone_text, healingdone_text, damagetaken_text, healingtaken_text, overhealingdone_text = "", "", "", "", "";
local dps_text, hps_text = "", "";
local fdamagedone, fhealingdone, fdamagetaken, fhealingtaken, foverhealingdone;
]]); 		
		end);
		
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
damagedone, healingdone, damagetaken, healingtaken, overhealingdone, damagedone_max, healingdone_max, damagetaken_max, healingtaken_max, overhealingdone_max, damagedone_total, healingdone_total, damagetaken_total, healingtaken_total, overhealingdone_total, dps, hps = unit:OmniGetInfo();
bdamagedone, bhealingdone, bdamagetaken, bhealingtaken, boverhealingdone = false, false, false, false, false;
damagedone_text, healingdone_text, damagetaken_text, healingtaken_text, overhealingdone_text = "", "", "", "", "";
dps_text, hps_text = "", "";
if dps and dps > 0 then dps_text = strformat("%d", dps) .. "dps"; end
if hps and hps > 0 then hps_text = strformat("%d", hps) .. "hps"; end
if damagedone and (damagedone > 0) then 
	bdamagedone = true;
	damagedone_text = damagedone .. " / " .. strformat("%.1f", VFL.clamp(damagedone/damagedone_total, 0, 1) * 100) .. "%";
end
if healingdone and (healingdone > 0) then 
	bhealingdone = true;
	healingdone_text = healingdone .. " / " .. strformat("%.1f", VFL.clamp(healingdone/healingdone_total, 0, 1) * 100) .. "%";
end
if damagetaken and (damagetaken > 0) then 
	bdamagetaken = true;
	damagetaken_text = damagetaken .. " / " .. strformat("%.1f", VFL.clamp(damagetaken/damagetaken_total, 0, 1) * 100) .. "%";
end
if healingtaken and (healingtaken > 0) then 
	bhealingtaken = true;
	healingtaken_text = healingtaken .. " / " .. strformat("%.1f", VFL.clamp(healingtaken/healingtaken_total, 0, 1) * 100) .. "%";
end
if overhealingdone and (overhealingdone > 0) then
	boverhealingdone = true;
	overhealingdone_text = overhealingdone .. " / " .. strformat("%.1f", VFL.clamp(overhealingdone/overhealingdone_total, 0, 1) * 100) .. "%";
end
fdamagedone, fhealingdone, fdamagetaken, fhealingtaken, foverhealingdone = VFL.clamp(damagedone/damagedone_max, 0, 1), VFL.clamp(healingdone/healingdone_max, 0, 1), VFL.clamp(damagetaken/damagetaken_max, 0, 1), VFL.clamp(healingtaken/healingtaken_max, 0, 1), VFL.clamp(overhealingdone/overhealingdone_max, 0, 1);

]]); end);
		-- Event hinting
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("UNIT_OMNISC", mux:GetPaintMask("OMNISC"));
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local stxt = VFLUI.SimpleText:new(ui, 3, 200); stxt:Show();
		local str = "This feature contains a refresh function that will repaint your window every 3 secondes.\n";
		str = str .. "It is strongly recommend to use it in his own window.";
		str = str .. "OpenRDX Team";
		
		stxt:SetText(str);
		ui:InsertFrame(stxt);

		function ui:GetDescriptor()
			return {feature = "var_omniscience"};
		end
		
		return ui;
	end;
	CreateDescriptor = function() return { feature = "var_omniscience" }; end
});

----------------------------------------------------------
-- OMNISCIENCE FILTER
----------------------------------------------------------
RDX.RegisterFilterComponent({
	name = "omniscience", title = i18n("Omniscience..."), category = i18n("Unit Status"),
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Omniscience...")); ui:Show();
		local container = VFLUI.CompoundFrame:new(ui);
		ui:SetChild(container); container:Show();

		local perc_numer = VFLUI.RadioGroup:new(container);
		container:InsertFrame(perc_numer);
		perc_numer:SetLayout(5, 1);
		perc_numer.buttons[1]:SetText(i18n("Damage Done"));
		perc_numer.buttons[2]:SetText(i18n("Healing Done"));
		perc_numer.buttons[3]:SetText(i18n("Damage Taken"));
		perc_numer.buttons[4]:SetText(i18n("Healing Taken"));
		perc_numer.buttons[5]:SetText(i18n("Overhealing Done"));
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
			return {"omniscience", perc_numer:GetValue(), lwr, upr};
		end

		return ui;
	end,
	GetBlankDescriptor = function() return {"omniscience", 1, 10000, 10000000}; end,
	FilterFromDescriptor = function(desc, metadata)
		local lb, ub, vexpr = desc[3], desc[4];
		-- Figure out which stat we want to use
		if desc[2] == 1 then -- damage done
			vexpr = "(unit:OmniDDone())";
		elseif desc[2] == 2 then -- healing done
			vexpr = "(unit:OmniHDone())";
		elseif desc[2] == 3 then -- damage taken
			vexpr = "(unit:OmniDTaken())";
		elseif desc[2] == 4 then -- healing taken
			vexpr = "(unit:OmniHTaken())";
		elseif desc[2] == 5 then -- overhealing done
			vexpr = "(unit:OmniOHDone())";
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
		RDX.FilterEvents_FullUpdate(metadata, "UNIT_OMNISC");
	end;
});

----------------------------------------------------------
-- Omniscience SORT
----------------------------------------------------------
RDX.RegisterSortOperator({
	name = "omnidamagedone";
	title = i18n("Omni Damage Done");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["omnidamagedone"] then
			vars["omnidamagedone"] = true;
			code:AppendCode([[
local damagedone1,damagedone2 = u1:OmniDDone(), u2:OmniDDone();
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
	GetUI = RDX.TrivialSortUI("omnidamagedone", i18n("Omni Damage Done"));
	GetBlankDescriptor = function() return {op = "omnidamagedone"}; end;
	Events = function(desc, ev) 
		ev["UNIT_OMNISC"] = true;
	end;
});

RDX.RegisterSortOperator({
	name = "omnihealingdone";
	title = i18n("Omni Healing Done");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["omnihealingdone"] then
			vars["omnihealingdone"] = true;
			code:AppendCode([[
local healingdone1,healingdone2 = u1:OmniHDone(), u2:OmniHDone();
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
	GetUI = RDX.TrivialSortUI("omnihealingdone", i18n("Omni Healing Done"));
	GetBlankDescriptor = function() return {op = "omnihealingdone"}; end;
	Events = function(desc, ev) 
		ev["UNIT_OMNISC"] = true;
	end;
});

RDX.RegisterSortOperator({
	name = "omnidamagetaken";
	title = i18n("Omni Damage Taken");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["omnidamagetaken"] then
			vars["omnidamagetaken"] = true;
			code:AppendCode([[
local damagetaken1,damagetaken2 = u1:OmniDTaken(), u2:OmniDTaken();
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
	GetUI = RDX.TrivialSortUI("omnidamagetaken", i18n("Omni Damage Taken"));
	GetBlankDescriptor = function() return {op = "omnidamagetaken"}; end;
	Events = function(desc, ev) 
		ev["UNIT_OMNISC"] = true;
	end;
});

RDX.RegisterSortOperator({
	name = "omnihealingtaken";
	title = i18n("Omni Healing Taken");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["omnihealingtaken"] then
			vars["omnihealingtaken"] = true;
			code:AppendCode([[
local healingtaken1,healingtaken2 = u1:OmniHTaken(), u2:OmniHTaken();
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
	GetUI = RDX.TrivialSortUI("omnihealingtaken", i18n("Omni Healing Taken"));
	GetBlankDescriptor = function() return {op = "omnihealingtaken"}; end;
	Events = function(desc, ev) 
		ev["UNIT_OMNISC"] = true;
	end;
});

RDX.RegisterSortOperator({
	name = "omnioverhealingdone";
	title = i18n("Omni Overhealing Done");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["omnioverhealingdone"] then
			vars["omnioverhealingdone"] = true;
			code:AppendCode([[
local overhealingdone1,overhealingdone2 = u1:OmniOHDone(), u2:OmniOHDone();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(overhealingdone1 == overhealingdone2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return overhealingdone1 < overhealingdone2;]]);
		else
			code:AppendCode([[return overhealingdone1 > overhealingdone2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("omnioverhealingdone", i18n("Omni Overhealing Done"));
	GetBlankDescriptor = function() return {op = "omnioverhealingdone"}; end;
	Events = function(desc, ev) 
		ev["UNIT_OMNISC"] = true;
	end;
});


