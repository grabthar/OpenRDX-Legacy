-- Core.lua
-- OpenRDX - Raid Data Exchange
-- Sigg

-----------------------------------------
-- Menu Bossmods
-----------------------------------------
RDXBossmods = {};
RDXBossmods.menu = RDX.Menu:new();
RDX.RegisterMainMenuEntry("Bossmods", true, function(tree,frame) RDXBossmods.menu:Open(tree, frame); end);

