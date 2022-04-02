-- Init.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- Initialization code.
--
RDX.initialized = false;

local initd = nil;

--- Is RDX initialized?
-- @return TRUE iff all RDX initialization procedures are complete.
function RDX.IsInitialized()
	return initd;
end

-- Preload: Called when RDX is finished loading, before saved variables and before modules.
local function Preload()
	RDX:Debug(2, "Init: Preload()");

	-- Player name
	RDX.pn = string.lower(UnitName("player"));
	local rn = string.lower(GetRealmName());
	-- BUGFIX: Quash all non-alpha-numerics in realmname, replace with underscores
	-- BUGFIX: ruRU ignore
	if GetLocale() ~= "ruRU" then
		rn = string.gsub(rn, "[^%w_]", "_");
	end
	rn = string.gsub(rn, "[ ]", "_");
	RDX.pspace = RDX.pn .. "_" .. rn;
	RDX.initialized = true; initd = true;

	-- Raise preload event, then destroy all bindings (preload never happens again)
	RDXEvents:Dispatch("INIT_PRELOAD");
	RDXEvents:DeleteKey("INIT_PRELOAD");
	
end

-- VariablesLoaded: Called on VARIABLES_LOADED, that is to say after ALL addons have been loaded.
local function VariablesLoaded()
	RDX:Debug(2, "Init: VariablesLoaded()");

	-- Session variables
	if not RDXSession then RDXSession = {}; end
	-- RDXG (Global session variables)
	if not RDXSession.global then RDXSession.global = {}; end
	RDXG = RDXSession.global;
	-- RDXU (User session variables)
	if not RDXSession[RDX.pspace] then RDXSession[RDX.pspace] = {}; end
	RDXU = RDXSession[RDX.pspace];

	RDXEvents:Dispatch("INIT_VARIABLES_LOADED");
	RDXEvents:DeleteKey("INIT_VARIABLES_LOADED");

	RDXEvents:Dispatch("INIT_POST_VARIABLES_LOADED");
	RDXEvents:DeleteKey("INIT_POST_VARIABLES_LOADED");
	
	RDXEvents:Dispatch("INIT_DESKTOP");
	RDXEvents:DeleteKey("INIT_DESKTOP");
	
	VFL.ZMSchedule(0.1, function()
		-- GetCompanionInfo is not available at INIT_VARIABLES_LOADED
		RDXEvents:Dispatch("INIT_SPELL");
		RDXEvents:DeleteKey("INIT_SPELL");
		
		-- guid is not available at INIT_VARIABLES_LOADED
		--RDXEvents:Dispatch("INIT_ROSTER");
		--RDXEvents:DeleteKey("INIT_ROSTER");
		
		RDXEvents:Dispatch("INIT_POST_DESKTOP");
		RDXEvents:DeleteKey("INIT_POST_DESKTOP");
	end);

	VFL.ZMSchedule(4, function()
		RDXEvents:Dispatch("INIT_DEFERRED");
		RDXEvents:DeleteKey("INIT_DEFERRED");
	end);
end

-- Bind initialization events DEPRECATED
WoWEvents:Bind("VARIABLES_LOADED", nil, VariablesLoaded);

-- fix a bug with desktop not really ready at INIT DESKTOP
WoWEvents:Bind("KNOWLEDGE_BASE_SYSTEM_MOTD_UPDATED", nil, function()
	VFL.ZMSchedule(1, function()
		RDXDK.SecuredChangeDesktop(RDXDK.GetCurrentDesktopPath());
	end);
end);

------------------------------- Last function that runs should always be Preload() ------------------------------
Preload();
