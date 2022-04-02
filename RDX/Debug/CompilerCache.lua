-- CompilerCache.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- A system for storing compiled code generated by RDX internals and retrieving
-- it for later viewing.
local ccCache = {};

-- Store the cache for public access
RDXM_Debug.ccCache = ccCache;

function RDXM_Debug.StoreCompiledObject(key, value)
	ccCache[key] = value;
end

-- Register a menu hook to view compiled code on path entries that have it.
RDXDB.RegisterObjectMenuHandler(function(mnu, opath, dialog)
	if ccCache[opath] then
		local x = tostring(ccCache[opath]);
		table.insert(mnu, {
			text = "View Compiled Code...";
			OnClick = function() VFL.poptree:Release(); VFL.Debug_ShowCode(x);	end;
		});
	end
end);

local function EnableStoreCompiler()
	RDXG.cdebug = true;
end

local function DisableStoreCompiler()
	RDXG.cdebug = nil;
end

function RDXM_Debug.ToggleStoreCompiler()
	if RDXG.cdebug then
		DisableStoreCompiler();
		RDX.print(i18n("Disable Store Compiler"));
	else
		EnableStoreCompiler();
		RDX.print(i18n("Enable Store compiler"));
	end
end

function RDXM_Debug.IsStoreCompilerActive()
	return RDXG.cdebug;
end

-----------------------------------
-- init
-----------------------------------

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	if RDXG.cdebug then 
		EnableStoreCompiler(); 
		RDX.printW("Store Compiler code Activated !!!");
	end
end);
