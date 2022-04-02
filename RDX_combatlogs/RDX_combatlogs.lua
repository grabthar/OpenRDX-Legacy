-- RDX_combatlogs.lua
-- OpenRDX
--
--
Omni_Logs = {};

---------------------------------------------------
-- INIT
---------------------------------------------------
WoWEvents:Bind("VARIABLES_LOADED", nil, function()
	if not Omni_SavedTables then Omni_SavedTables = {}; end
end);

