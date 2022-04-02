-- ProfilerStubs.lua
-- VFL
-- (C)2005-2007 Bill Johnson and the VFL Project
--
-- APIs for instrumenting code for profiling.
--
-- Individual pieces of code can register themselves for profile monitoring
-- by using these APIs. These functions are intelligently converted to NOOPs based
-- on whether or not full script profiling is enabled and will not hurt performance
-- when profiling is disabled.
--
-- The actual profiler is contained in the VFL_Profiler mod which must be installed
-- separately.

VFLP = {};
VFLP.Events = DispatchTable:new();

-- Object profiling data storage
local fcats = {};
local flist = {};
VFLP._fcats = fcats;
VFLP._flist = flist;

local ecats = {};
local elist = {};
VFLP._ecats = ecats;
VFLP._elist = elist;

local pcats = {};
local plist = {};
VFLP._pcats = pcats;
VFLP._plist = plist;

-- Enabled state of profiling = cvar value at UI load time.
local isEnabled = 0;
local success,x = pcall(GetCVar, "scriptProfile");
if success == true then
	isEnabled = tonumber(x);
end

--- Determine if profiling is enabled.
function VFLP.IsEnabled()
	if (isEnabled == 0) then return false; else return true; end
end

--- Stub functions
VFLP.RegisterCategory = VFL.Noop;
VFLP.UnregisterCategory = VFL.Noop;
VFLP.RegisterFunc = VFL.Noop;
VFLP.RegisterFrame = VFL.Noop;
VFLP.UnregisterObject = VFL.Noop;

VFLP.RegisterEventCategory = VFL.Noop;
VFLP.RegisterEvent = VFL.Noop;
VFLP.UnregisterEvent = VFL.Noop;

VFLP.RegisterPoolCategory = VFL.Noop;
VFLP.RegisterPool = VFL.Noop;
VFLP.UnregisterPool = VFL.Noop;

if VFLP.IsEnabled() then
	-- If enabled, replace stubs with real stuff

--- Register a profiling category. All functions have a category; the parent category
-- totals up the usages of all subfunctions.
function VFLP.RegisterCategory(name)
	if (type(name) ~= "string") or (fcats[name]) then return; end
	fcats[name] = true;
	table.insert(flist, {
		type = "category"; category = name; title = name; 
		calls = 0; lastCalls = 0; raCalls =0;
		CPU = 0; lastCPU = 0; raCPU = 0;
	});
end
VFLP.RegisterCategory("Uncategorized");

--- Unregister a profiling category; Also implicitly unregisters all functions in that
-- category.
function VFLP.UnregisterCategory(name)
	if (type(name) ~= "string") or (name == "Uncategorized") or (not fcats[name]) then return; end
	VFL.filterInPlace(flist, function(x) return (x.category ~= name); end);
	fcats[name] = nil;
	VFLP.Events:Dispatch("PROFILE_OBJECTS_CHANGED");
end

--- Register a function in the given category.
function VFLP.RegisterFunc(category, title, f, includeSubs)
	if (type(f) ~= "function") then return; end
	if (type(category) ~= "string") or (not fcats[category]) then category = "Uncategorized"; end
	local idx,u = 0, nil;
	for i in ipairs(flist) do
		u = flist[i];
		if (u.type == "category") and (u.category == category) then idx = i; break; end
	end
	if idx > 0 then
		table.insert(flist, idx + 1, {
			type = "function"; category = category; title = title;
			object = f; includeSubObjects = includeSubs; 
			calls = 0; lastCalls = 0; raCalls = 0;
			CPU = 0; lastCPU = 0; raCPU = 0;
		});
		VFLP.Events:Dispatch("PROFILE_OBJECTS_CHANGED");
	end
end

--- Register a frame in the given category
function VFLP.RegisterFrame(category, title, f, includeSubs)
	if (type(f) ~= "table") or (not f.GetFrameType) then return; end
	if (type(category) ~= "string") or (not fcats[category]) then category = "Uncategorized"; end
	local idx,u = 0, nil;
	for i in ipairs(flist) do
		u = flist[i];
		if (u.type == "category") and (u.category == category) then idx = i; break; end
	end
	if idx > 0 then
		table.insert(flist, idx + 1, {
			type = "frame"; category = category; title = title;
			object = f; includeSubObjects = includeSubs;
			calls = 0; lastCalls = 0; raCalls = 0;
			CPU = 0; lastCPU = 0; raCPU = 0;
		});
		VFLP.Events:Dispatch("PROFILE_OBJECTS_CHANGED");
	end
end

--- Remove a frame or function previously registered.
function VFLP.UnregisterObject(obj)
	if obj == nil then return; end
	if (VFL.removeFieldMatches(flist, "object", obj) > 0) then
		VFLP.Events:Dispatch("PROFILE_OBJECTS_CHANGED");
	end
end

------------------------------event
function VFLP.RegisterEventCategory(name)
	if (type(name) ~= "string") or (ecats[name]) then return; end
	ecats[name] = true;
	table.insert(elist, {
		type = "category"; category = name; title = name; 
		calls = 0; lastCalls = 0; raCalls =0;
		CPU = 0; lastCPU = 0; raCPU = 0;
	});
end
VFLP.RegisterEventCategory("Uncategorized");

--- Register a event in the given category.
function VFLP.RegisterEvent(category, title, f)
	if (type(title) ~= "string") then return; end
	if (type(category) ~= "string") or (not ecats[category]) then category = "Uncategorized"; end
	local idx,u = 0, nil;
	for i in ipairs(elist) do
		u = elist[i];
		if (u.type == "category") and (u.category == category) then idx = i; break; end
	end
	if idx > 0 then
		table.insert(elist, idx + 1, {
			type = "event"; category = category; title = title;
			object = f;
			calls = 0; lastCalls = 0; raCalls = 0;
			CPU = 0; lastCPU = 0; raCPU = 0;
		});
		VFLP.Events:Dispatch("PROFILE_OBJECTS_CHANGED");
	end
end

---------------------------------------- pool
--- Register a profiling category. All functions have a category; the parent category
-- totals up the usages of all subfunctions.
function VFLP.RegisterPoolCategory(name)
	if (type(name) ~= "string") or (pcats[name]) then return; end
	pcats[name] = true;
	table.insert(plist, {
		type = "category"; category = name; title = name; 
		create = 0; use = 0; available = 0; jail = 0;
	});
end
--VFLP.RegisterPoolCategory("Uncategorized");

--- Register a function in the given category.
-- todo

------------- Register some common Lua routines to see how they're doing
VFLP.RegisterCategory("Lua Core");
VFLP.RegisterFunc("Lua Core", "string.find", string.find, nil);
VFLP.RegisterFunc("Lua Core", "string.match", string.match, nil);
VFLP.RegisterFunc("Lua Core", "string.gmatch", string.gmatch, nil);
VFLP.RegisterFunc("Lua Core", "string.format", string.format, nil);
VFLP.RegisterFunc("Lua Core", "string.lower", string.lower, nil);
VFLP.RegisterFunc("Lua Core", "table.sort", table.sort, nil);
VFLP.RegisterFunc("Lua Core", "table.insert", table.insert, nil);
VFLP.RegisterFunc("Lua Core", "table.remove", table.remove, nil);

VFLP.RegisterEventCategory("WoWEvents");
VFLP.RegisterEvent("WoWEvents", "UNIT_AURA", UNIT_AURA);
--VFLP.RegisterEvent("WoWEvents", "COMBAT_LOG_EVENT_UNFILTERED", "COMBAT_LOG_EVENT_UNFILTERED");

end -- (if VFLP.IsEnabled())
