-- RDX_localspelldb.lua
-- OpenRDX
--
-- This addon is just used to store local spell db
--

---------------------------------------------------
-- INIT
---------------------------------------------------
WoWEvents:Bind("VARIABLES_LOADED", nil, function()
	if not RDXLocalSpellDB then RDXLocalSpellDB = {}; end
end);
