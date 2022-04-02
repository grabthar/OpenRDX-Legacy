-- Parse.lua
-- RDX - Project Omniscience
-- (C)2006 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL. COPYING IS PROHIBITED WITHOUT
-- A SEPARATE LICENSE.
--
-- Universal parsing code.

local parseFunc = Omni.ParseFuncs;
local AddLogRow = Omni.AddLogRow;
local AddLogRow2 = Omni.AddLogRow2;

local function GetParseFunc(f)
	return parseFunc[f] or VFL.Noop;
end

local function InCombat()
	AddLogRow(11);
end
local function OutOfCombat()
	AddLogRow(12);
end

-- Bind to Encounter Start/Stop in RDX
local function StartEncounter(ename)
	AddLogRow(13, nil, ename);
	--AddLogRow2(13, nil, ename);
end
local function StopEncounter(ename)
	AddLogRow(14, nil, ename);
	--AddLogRow2(14, nil, ename);
end

--- Enable or disable Omniscience combat logging.
-- @param x If TRUE, logging is enabled; if FALSE, disabled.
local logging = nil;
function Omni.SetLogging(x)
	if x and (not logging) then
		logging = true;
		--if RDXG.UseMiniParser then 
		--	WoWEvents:Bind("COMBAT_LOG_EVENT_UNFILTERED", nil, Omni.MiniParser, "Omni");
		--else
			WoWEvents:Bind("COMBAT_LOG_EVENT_UNFILTERED", nil, Omni.StandardParser, "Omni");
			-- COMBAT FLAG
			WoWEvents:Bind("PLAYER_REGEN_DISABLED", nil, InCombat, "Omni");
			WoWEvents:Bind("PLAYER_REGEN_ENABLED", nil, OutOfCombat, "Omni");
			-- START/STOP ENC
			RDXEvents:Bind("ENCOUNTER_STARTED", nil, StartEncounter, "Omni");
			RDXEvents:Bind("ENCOUNTER_STOPPED", nil, StopEncounter, "Omni");
		--end
	else
		logging = nil;
		WoWEvents:Unbind("Omni");
		RDXEvents:Unbind("Omni");
	end
end

--test
--WoWEvents:Bind("COMBAT_LOG_EVENT_UNFILTERED", nil, Omni.Parse_generic, "Omni2");
function Omni.IsLogging() return logging; end

-- Only start logging when the system timer is established.
--VFLEvents:Bind("SYSTEM_EPOCH_ESTABLISHED", nil, function() 
RDXEvents:Bind("INIT_DEFERRED", nil, function()
Omni.SetLogging(true); 
--RDX.print("|cFFAAFF00Omniscience:|r |cFFFFFFFFstart logging ");
end);
