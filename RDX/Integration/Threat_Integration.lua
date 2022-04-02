-- Threat_Integration.lua
-- RDX - Raid Data Exchange
-- 
-- Pull data from Threat-2.0 library and use it to drive RDX sorts,
-- sets, and variables.

-- Modify by SaT|Brainn
-- Modify by taelnia

local clamp, tsort, tinsert, strlower = VFL.clamp, table.sort, table.insert, string.lower;
local UnitGUID = UnitGUID;
local GetUnitByGUID = RDX.GetUnitByGuid;
local sig_unit_threat = RDXEvents:LockSignal("UNIT_THREAT");

-- Ace threat lib handlers
local Threat = nil;

-----------------------------
-- THREAT MOB CHECKER
-- Check which mob we should be watching threat on. Constantly updated
-- because of the lack of targettarget events.
-----------------------------
local threatUnit, threatGUID, tankUnit, tankGUID;

-- Signal an update to ALL player threat.
local function GlobalThreatUpdate()
   RDX.BeginEventBatch();
   for _,unit in RDX.Raid() do
      sig_unit_threat:Raise(unit, unit.nid, unit.uid);
   end
   RDX.EndEventBatch();
end

-- Figure out who the tank is.
local function FindTank(forceGTU)
   -- Verify the existence of the tank unit.
   local x = nil;
   if (threatGUID and tankUnit and UnitIsFriend("player", tankUnit)) then
      -- The tank exists.
      x = UnitGUID(tankUnit);
--[[ Temporarily disabled until we can figure out a better way to do this
      -- Now let's sanity check his threat
      -- Figure out the max threat.
      local maxThreat, maxThreater = Threat:GetMaxThreatOnTarget(threatUnitName);
      if maxThreat < 1 then maxThreat = 1; end -- no division by 0
      -- Figure out tank threat, if it's less than 75% of the max threat, the mob is just
      -- randomly targeting someone else in the raid.
      local tankThreat = Threat:GetThreat(x, threatUnitName);
      -- If the mob is RSTS-ing, use the max threat target as the tank temporarily.
      if (tankThreat / maxThreat) < .76 then x = maxThreater; end
]]--
   else
      -- The tank doesn't exist at all, just use the max threat target.
      if threatGUID then
         _, x = Threat:GetMaxThreatOnTarget(threatGUID);
      end
   end
   -- If we changed tanks since the last threat update, then update all threat.
   if(x ~= tankGUID) then
      tankGUID = x;   forceGTU = true;
   end
   if forceGTU then GlobalThreatUpdate(); end
end

local function SetThreatUnit()
   local x = nil;
   -- Verify the threat unit, and that it's nonfriendly
   if (threatUnit and (not UnitIsFriend("player", threatUnit))) then
      x = UnitGUID(threatUnit);
   else
      tankUnit = nil;
   end
   -- If the threat unit has changed, find the tank again.
   if threatGUID ~= x then
      threatGUID = x;   FindTank(true);
   end
end

local function ThreatMobUpdater(arg1)
   -- If we were called via targeting update, ignore nonplayer target changes
   if arg1 and arg1 ~= "player" then return; end
   -- No target = no threat assessment
   if not UnitExists("target") then
      threatUnit = nil;
      SetThreatUnit();
   end
   -- If target is hostile, use it, else use targettarget.
   if UnitIsFriend("player", "target") then
      threatUnit = "targettarget"; tankUnit = "targettargettarget";
      SetThreatUnit();
   else
      threatUnit = "target"; tankUnit = "targettarget";
      SetThreatUnit();
   end
   FindTank();
end

---------------------------------------------------
-- ACE THREAT API HACKS
---------------------------------------------------
local function InitAceThreat()
   RDX.print("Threat-2.0 integration enabled.")
   Threat:RegisterCallback("ThreatUpdated", function(_, sguid)
      if sguid == tankGUID then
         GlobalThreatUpdate();
      else
         local unit = GetUnitByGUID(sguid);
         if not unit then return; end
         sig_unit_threat:Raise(unit, unit.nid, unit.uid);
      end
   end);

   WoWEvents:Bind("UNIT_TARGET", nil, ThreatMobUpdater);
   VFL.AdaptiveSchedule("threat_target", 0.5, ThreatMobUpdater);
end

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
   if not LibStub then return; end
   Threat = LibStub:GetLibrary("Threat-2.0", true);
   if not Threat then return; end
   InitAceThreat();
end);

----------------------------------------------------------
-- UNIT API MODS
-- Add functions to the Unit objects to query their threat.
----------------------------------------------------------
local function GetThreatInfo(rdxunit, targetGUID)
   if (not Threat) or (not tankGUID) then return 0, 1; end
   local mt = Threat:GetThreat(tankGUID, targetGUID);
   if mt < 1 then mt = 1; end
   local pt = Threat:GetThreat(rdxunit:GetGuid(), targetGUID);
   local ptps = Threat:GetTPS(rdxunit:GetGuid(), targetGUID) or 0;
   return pt, mt, ptps;
end

RDX.Unit.GetThreatInfo = function(self)
   local t, mt, tps = GetThreatInfo(self, threatGUID);
   return t, mt, t/mt, tps;
end;

RDX.Unit.FracThreat = function(self)
   local t, mt = GetThreatInfo(self, threatGUID);
   return t/mt;
end;

------------------------------------------------
-- THREAT UNITFRAME VARS
------------------------------------------------
--- Unit frame variables for predicted health valuation.
RDX.RegisterFeature({
   name = "var_threat";
   title = i18n("Vars: Threat-2.0 (threat, fthreat, maxthreat)");
   category = i18n("Variables: Unit Status");
   IsPossible = function(state)
      if not state:Slot("EmitPaintPreamble") then return nil; end
      if state:Slot("Var_threat") then return nil; end
      return true;
   end;
   ExposeFeature = function(desc, state, errs)
      state:AddSlot("Var_threat"); state:AddSlot("FracVar_fthreat"); state:AddSlot("Var_maxthreat");
      state:AddSlot("FracVar_fthreat130"); state:AddSlot("Var_tps"); state:AddSlot("Txt_threat_info");
      return true;
   end;
   ApplyFeature = function(desc, state)
      state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local strformat = string.format;
local threat, maxthreat, fthreat, tps = unit:GetThreatInfo();
local fthreat130 = VFL.clamp(fthreat / 1.3, 0, 1);
if not tps then tps = "0"; end
if not fthreat then fthreat = "0"; end
local threat_info =  strformat("%d",tps) .. " | " .. strformat("%d",(fthreat * 100)) .. "%";
]]); end);
      -- Event hinting
      local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
      mux:Event_UnitMask("UNIT_THREAT", mux:GetPaintMask("THREAT"));
   end;
   UIFromDescriptor = VFL.Nil;
   CreateDescriptor = function() return { feature = "var_threat" }; end
});

----------------------------------------------------------
-- THREAT FILTER
----------------------------------------------------------
RDX.RegisterFilterComponent({
   name = "threat", title = i18n("Threat..."), category = "Unit Status",
   UIFromDescriptor = function(desc, parent)
      local ui = RDXUI.FilterDialogFrame:new(parent);
      ui:SetText(i18n("Threat...")); ui:Show();
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

----------------------------------------------------------
-- THREAT SORT
----------------------------------------------------------
RDX.RegisterSortOperator({
   name = "threat";
   title = "Threat";
   category = "Status";
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
   GetUI = RDX.TrivialSortUI("threat", "Threat");
   GetBlankDescriptor = function() return {op = "threat"}; end;
   Events = function(desc, ev)
      ev["UNIT_THREAT"] = true;
   end;
});