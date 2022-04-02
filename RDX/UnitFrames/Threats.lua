-- Threats.lua
-- OpenRDX
--
-- Sigg Rashgarroth EU
--

local clamp, tsort, tinsert, strlower = VFL.clamp, table.sort, table.insert, string.lower;
local sig_unit_threat = RDXEvents:LockSignal("UNIT_THREAT");

-- Signal an update to ALL player threat.
-- There is no event for one unit fire when rawthread change erf
local function GlobalThreatUpdate()
	RDX.BeginEventBatch();
	for _,unit in RDX.Raid() do
		sig_unit_threat:Raise(unit, unit.nid, unit.uid);
	end
	RDX.EndEventBatch();
end

---------------------------------------------------
-- INIT
---------------------------------------------------
local function InitThreat()
	VFL.AdaptiveUnschedule("threat_target");
	VFL.AdaptiveSchedule("threat_target", 0.5, GlobalThreatUpdate);
end

RDXEvents:Bind("INIT_DEFERRED", nil, InitThreat);

----------------------------------------------------------
-- UNIT API MODS
-- Add functions to the Unit objects to query their threat.
----------------------------------------------------------
local isTanking, state, scaledPercent, rawPercent, threatValue;

local function GetThreatInfo(rdxunit)
	if not UnitExists("target") then return nil, nil, 0, 0, 0; end
	isTanking, state, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation(rdxunit.uid, "target");
	if scaledPercent then scaledPercent = scaledPercent / 100; else scaledPercent = 0; end
	if rawPercent then rawPercent = rawPercent / 100; else rawPercent = 0; end
	return isTanking, state, scaledPercent, rawPercent, threatValue;
end

RDX.Unit.GetThreatInfo = function(self)
   isTanking, state, scaledPercent, rawPercent, threatValue = GetThreatInfo(self);
   return isTanking, state, scaledPercent, rawPercent, threatValue;
end;

RDX.Unit.FracThreat = function(self)
   _, _, _, rawPercent = GetThreatInfo(self);
   return rawPercent;
end;

RDX.Unit.FracThreatScaled = function(self)
   _, _, scaledPercent = GetThreatInfo(self);
   return scaledPercent;
end;

--VFLP.RegisterFunc(i18n("RDX: UnitDB"), "UnitDetailedThreatSituation", UnitDetailedThreatSituation, true);

------------------------------------------------
-- THREAT UNITFRAME VARS
------------------------------------------------
--- Unit frame variables for predicted health valuation.
RDX.RegisterFeature({
	name = "var_threat";
	title = i18n("Vars: Threat (threat, fthreat)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_threat") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_threat"); state:AddSlot("TextData_threat_value");
		state:AddSlot("FracVar_fthreat"); state:AddSlot("TextData_threat_info");
		state:AddSlot("BoolVar_bthreat");
		state:AddSlot("FracVar_fthreatscale"); state:AddSlot("TextData_threatscale_info");
		state:AddSlot("BoolVar_bthreatscale");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local _, _, fthreatscale, fthreat, threat_value = unit:GetThreatInfo();
local bthreat, bthreatscale = nil, nil;
local threat_info = "";
local threatscale_info = "";
if fthreat and fthreat > 0 then
	bthreat = true;
	threat_info = strformat("%d%%",(fthreat * 100));
end
if fthreatscale and fthreatscale > 0 then
	bthreatscale = true;
	threatscale_info = strformat("%d%%",(fthreatscale * 100));
end
]]); end);
		-- Event hinting
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_UnitMask("UNIT_THREAT", mux:GetPaintMask("THREAT"));
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local stxt = VFLUI.SimpleText:new(ui, 3, 200); stxt:Show();
		local str = "This feature contains a refresh function that will repaint your window every 0.5 secondes.\n";
		str = str .. "It is strongly recommend to use it in his own window.";
		str = str .. "OpenRDX Team";
		
		stxt:SetText(str);
		ui:InsertFrame(stxt);

		function ui:GetDescriptor()
			return {feature = "var_threat"};
		end
		
		return ui;
	end;
	CreateDescriptor = function() return { feature = "var_threat" }; end
});

----------------------------------------------------------
-- THREAT FILTER
----------------------------------------------------------
RDX.RegisterFilterComponent({
   name = "threat", title = i18n("Threat"), category = i18n("Unit Status"),
   UIFromDescriptor = function(desc, parent)
      local ui = RDXUI.FilterDialogFrame:new(parent);
      ui:SetText(i18n("Threat")); ui:Show();
      local container = VFLUI.CompoundFrame:new(ui);
      ui:SetChild(container); container:Show();

      local lb = VFLUI.LabeledEdit:new(container, 50);
      container:InsertFrame(lb);
      lb:SetText("Lower bound"); lb.editBox:SetText(desc[2]);
      lb:Show();
      local ub = VFLUI.LabeledEdit:new(container, 50);
      container:InsertFrame(ub);
      ub:SetText("Upper bound"); ub.editBox:SetText(desc[3]);
      ub:Show();

      ui.GetDescriptor = function(x)
         local lwr = lb.editBox:GetNumber(); if (not lwr) or (lwr < 0) then lwr = 0; end
         local upr = ub.editBox:GetNumber(); if (not upr) or (upr < 0) then upr = 1; end
         if(upr < lwr) then local temp = upr; upr = lwr; lwr = temp; end
         return {"threat", lwr, upr};
      end

      return ui;
   end,
   GetBlankDescriptor = function() return {"threat", 0, 1}; end,
   FilterFromDescriptor = function(desc, metadata)
      local lb, ub, vexpr = desc[2], desc[3];
      lb = VFL.clamp( lb, 0, 1);
      ub = VFL.clamp( ub, 0, 1);
      vexpr = "(unit:FracThreat())";
      -- Generate the closures/locals
      local vC = RDX.GenerateFilterUpvalue();
      table.insert(metadata, { class = "LOCAL", name = vC, value = vexpr });
      -- Generate the filtration expression.
      return "((" .. vC .. " >= " .. lb ..") and (" .. vC .. " <= " .. ub .."))";
   end;
   ValidateDescriptor = VFL.True;
   SetsFromDescriptor = VFL.Noop;
   EventsFromDescriptor = function(desc, metadata)
      RDX.FilterEvents_UnitUpdate(metadata, "UNIT_THREAT");
   end;
});

RDX.RegisterFilterComponent({
   name = "threatscaled", title = i18n("Threat Scale"), category = i18n("Unit Status"),
   UIFromDescriptor = function(desc, parent)
      local ui = RDXUI.FilterDialogFrame:new(parent);
      ui:SetText(i18n("Threat Scale")); ui:Show();
      local container = VFLUI.CompoundFrame:new(ui);
      ui:SetChild(container); container:Show();

      local lb = VFLUI.LabeledEdit:new(container, 50);
      container:InsertFrame(lb);
      lb:SetText("Lower bound"); lb.editBox:SetText(desc[2]);
      lb:Show();
      local ub = VFLUI.LabeledEdit:new(container, 50);
      container:InsertFrame(ub);
      ub:SetText("Upper bound"); ub.editBox:SetText(desc[3]);
      ub:Show();

      ui.GetDescriptor = function(x)
         local lwr = lb.editBox:GetNumber(); if (not lwr) or (lwr < 0) then lwr = 0; end
         local upr = ub.editBox:GetNumber(); if (not upr) or (upr < 0) then upr = 1; end
         if(upr < lwr) then local temp = upr; upr = lwr; lwr = temp; end
         return {"threatscaled", lwr, upr};
      end

      return ui;
   end,
   GetBlankDescriptor = function() return {"threatscaled", 0, 1}; end,
   FilterFromDescriptor = function(desc, metadata)
      local lb, ub, vexpr = desc[2], desc[3];
      lb = VFL.clamp( lb, 0, 1);
      ub = VFL.clamp( ub, 0, 1);
      vexpr = "(unit:FracThreatScaled())";
      -- Generate the closures/locals
      local vC = RDX.GenerateFilterUpvalue();
      table.insert(metadata, { class = "LOCAL", name = vC, value = vexpr });
      -- Generate the filtration expression.
      return "((" .. vC .. " >= " .. lb ..") and (" .. vC .. " <= " .. ub .."))";
   end;
   ValidateDescriptor = VFL.True;
   SetsFromDescriptor = VFL.Noop;
   EventsFromDescriptor = function(desc, metadata)
      RDX.FilterEvents_UnitUpdate(metadata, "UNIT_THREAT");
   end;
});

----------------------------------------------------------
-- THREAT SORT
----------------------------------------------------------
RDX.RegisterSortOperator({
   name = "threat";
   title = i18n("Raw Threat");
   category = i18n("Status");
   EmitLocals = function(desc, code, vars)
      if not vars["threat"] then
         vars["threat"] = true;
         code:AppendCode([[
local threat1,threat2 = u1:FracThreat(), u2:FracThreat();
]]);
      end
   end;
   EmitCode = function(desc, code, context)
      code:AppendCode([[
if(threat1 == threat2) then
]]);
      RDX._SortContinuation(context);
      code:AppendCode([[else
]]);
      if desc.reversed then
         code:AppendCode([[return threat1 < threat2;]]);
      else
         code:AppendCode([[return threat1 > threat2;]]);
      end
code:AppendCode([[
end
]]);
   end;
   GetUI = RDX.TrivialSortUI("threat", "Raw Threat");
   GetBlankDescriptor = function() return {op = "threat"}; end;
   Events = function(desc, ev)
      ev["UNIT_THREAT"] = true;
   end;
});

RDX.RegisterSortOperator({
   name = "threatscaled";
   title = i18n("Scaled Threat");
   category = i18n("Status");
   EmitLocals = function(desc, code, vars)
      if not vars["threatscaled"] then
         vars["threatscaled"] = true;
         code:AppendCode([[
local threatscaled1,threatscaled2 = u1:FracThreatScaled(), u2:FracThreatScaled();
]]);
      end
   end;
   EmitCode = function(desc, code, context)
      code:AppendCode([[
if(threatscaled1 == threatscaled2) then
]]);
      RDX._SortContinuation(context);
      code:AppendCode([[else
]]);
      if desc.reversed then
         code:AppendCode([[return threatscaled1 < threatscaled2;]]);
      else
         code:AppendCode([[return threatscaled1 > threatscaled2;]]);
      end
code:AppendCode([[
end
]]);
   end;
   GetUI = RDX.TrivialSortUI("threatscaled", "Scaled Threat");
   GetBlankDescriptor = function() return {op = "threatscaled"}; end;
   Events = function(desc, ev)
      ev["UNIT_THREAT"] = true;
   end;
});