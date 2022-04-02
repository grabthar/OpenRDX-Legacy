-- AuraCache.lua
-- OpenRDX
-- 

-- The aura cache is implemented in the roster UDB.lua
-- Aura are stored in the unit
--[[ 
--deprecated

local function EnableAuraCache()
	RDXG.UseAuraCache = true;
end

local function DisableAuraCache()
	RDXG.UseAuraCache = nil;
end

function RDXM_Debug.ToggleAuraCache()
	if RDXG.UseAuraCache then
		DisableAuraCache();
		RDX.print(i18n("Disable RDX Aura cache"));
	else
		EnableAuraCache();
		RDX.print(i18n("Enable RDX Aura cache"));
	end
end

function RDXM_Debug.IsAuraCacheActive()
	return RDXG.UseAuraCache;
end
]]
