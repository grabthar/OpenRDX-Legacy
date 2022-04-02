-- DebugMenu.lua
-- OpenRDX
--

-- /console taintLog 1

RDXM_Debug.DebugMenu = RDX.Menu:new();
-- deprecated
--RDXM_Debug.DebugMenu:RegisterMenuFunction(function(ent)
--	if not RDXM_Debug.IsAuraCacheActive() then
--		ent.text = i18n("Aura cache |cFFFF0000[OFF]|r");
--	else
--		ent.text = i18n("Aura cache |cFF00FF00[ON]|r");
--	end
--	ent.OnClick = function() VFL.poptree:Release(); RDXM_Debug.ToggleAuraCache(); end;
--end);
RDXM_Debug.DebugMenu:RegisterMenuFunction(function(ent)
	if not RDX.IsFullDisableBlizzard() then
		ent.text = i18n("Full disable Blizzard |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("Full disable Blizzard |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); RDX.ToggleFullDisableBlizzard(); end;
end);
RDXM_Debug.DebugMenu:RegisterMenuFunction(function(ent)
	if not RDXM_Debug.IsStoreCompilerActive() then
		ent.text = i18n("Store code compiler |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("Store code compiler |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); RDXM_Debug.ToggleStoreCompiler(); end;
end);
RDXM_Debug.DebugMenu:RegisterMenuFunction(function(ent)
	if not RDXM_Debug.IsStoreLocalSpellDB() then
		ent.text = i18n("Store Local Spell DB |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("Store Local Spell DB |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); RDXM_Debug.ToggleStoreLocalSpellSB(); end;
end);
RDXM_Debug.DebugMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Open Set Debugger");
	ent.OnClick = function() VFL.poptree:Release(); RDXM_Debug.SetDebugger(); end;
end);
RDXM_Debug.DebugMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Disrupt signal");
	ent.OnClick = function() VFL.poptree:Release(); RDX._Disrupt(); end;
end);
if VFLP and VFLP.ToggleProfiler then
RDXM_Debug.DebugMenu:RegisterMenuFunction(function(ent)
	if not VFLP.IsProfilerShown() then
		ent.text = i18n("RDX Profiler |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("RDX Profiler |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); VFLP.ToggleProfiler(); end;
end);
end
function RDXM_Debug.ShowDebugMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	RDXM_Debug.DebugMenu:Open(VFL.poptree, nil);
end

--------------------------
-- MAIN buttons
--------------------------
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
RDXPM.RegisterMainButton({
	name = "performance";
	id = 11;
	btype = "menu";
	title = i18n("Performance and Debug");
	desc = i18n("Analyze your RDX");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\configure";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\configure";
	IsToggle = VFL.Noop;
	OnClick = RDXM_Debug.ShowDebugMenu;
});
end);

--[[
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()

RDXPM.RegisterButton({
	name = "auracache_toggle";
	parent = "performance";
	id = 101;
	btype = "toggle";
	title = i18n("Unit Aura Cache");
	desc = i18n("Enable/Disable Aura Cache");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\fav";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\favadd";
	IsToggle = RDXM_Debug.IsAuraCacheActive;
	OnClick = RDXM_Debug.ToggleAuraCache;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "storecompiler_toggle";
	parent = "performance";
	id = 102;
	btype = "toggle";
	title = i18n("Code compiler");
	desc = i18n("Enable/Disable store code compiler");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\trash";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\trashb";
	IsToggle = RDXM_Debug.IsStoreCompilerActive;
	OnClick = RDXM_Debug.ToggleStoreCompiler;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "setdebugger_performance";
	parent = "performance";
	id = 103;
	btype = "custom";
	title = i18n("Set Debug");
	desc = i18n("Open Set Debugger");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\printpreview";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\printpreview";
	IsToggle = VFL.Noop;
	OnClick = RDXM_Debug.SetDebugger;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "disrupt_performance";
	parent = "performance";
	id = 104;
	btype = "custom";
	title = i18n("Disrupt");
	desc = i18n("Disrupt signal");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\bug";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\bug";
	IsToggle = VFL.Noop;
	OnClick = RDX._Disrupt;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "profiler_toggle";
	parent = "performance";
	id = 105;
	btype = "toggle";
	title = i18n("RDX Profiler");
	desc = i18n("Show/Hide Profiler");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\gotoapp";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\app";
	IsToggle = RDXM_Debug.IsProfilerShown;
	OnClick = RDXM_Debug.ToggleProfiler;
	OnDrag = VFL.Noop;
});

end);
]]