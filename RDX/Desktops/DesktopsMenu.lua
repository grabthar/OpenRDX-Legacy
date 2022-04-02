-- DesktopsMenu
-- OpenRDX
-- 

RDXDK.DesktopMenu = RDX.Menu:new();
RDXDK.DesktopMenu:RegisterMenuFunction(function(ent)
	if not RDXDK.IsAutoSwitchEnable() then
		ent.text = i18n("AutoSwitch |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("AutoSwitch |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); RDXDK.ToggleAutoSwitchDesktop(); end;
end);
RDXDK.DesktopMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Open Autoswitch Manager");
	ent.OnClick = function() VFL.poptree:Release(); RDXDK.DesktopsManage(); end;
end);
-- deprecated
--RDXDK.DesktopMenu:RegisterMenuFunction(function(ent)
--	ent.text = i18n("Open Blizzard UI Manager");
--	ent.OnClick = function() VFL.poptree:Release(); RDXDK.BlizzardManage(); end;
--end);
RDXDK.DesktopMenu:RegisterMenuEntry("Desktop", true, function(tree, frame)
	local mnu = {};
	--table.insert(mnu, { text = "Rebuild desktop", OnClick = function() VFL.poptree:Release(); RDXDK.RebuildDesktop(); end });
	--table.insert(mnu, { text = "Reset desktop", OnClick = function() VFL.poptree:Release(); RDXDK.DeskReset(); end });
	--table.insert(mnu, { text = "Clear desktop", OnClick = function() VFL.poptree:Release(); RDXDK.DeskClear(); end });
	table.insert(mnu, { text = "Modify desktop", OnClick = function() VFL.poptree:Release(); RDXDK.ModifyDesktop(); end });
	tree:Expand(frame, mnu);
end);
RDXDK.DesktopMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("-------------");
end);
RDXDK.DesktopMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Reload UI");
	ent.OnClick = function() VFL.poptree:Release(); RDXDK.ReloadUI(); end;
end);

function RDXDK.ShowDesktopMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	RDXDK.DesktopMenu:Open(VFL.poptree, nil);
end

--------------------------
-- MAIN buttons
--------------------------

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()

RDXPM.RegisterMainButton({
	name = "desktop";
	id = 1;
	btype = "menu";
	title = i18n("Desktop and UI Manager");
	desc = "Modify Your Interface";
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\paint";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\paint";
	IsToggle = VFL.Noop;
	OnClick = RDXDK.ShowDesktopMenu;
});

RDXPM.RegisterMainButton({
	name = "lockunlock_desktop";
	id = 2;
	btype = "toggle";
	title = i18n("Toggle Desktop Lock");
	desc = i18n("Lock/Unlock the desktop");
	IsToggle = RDXDK.IsDesktopLocked;
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\file";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\filelocked";
	OnClick = RDXDK.ToggleDesktopLock;
});

RDXPM.RegisterMainButton({
	name = "bindings_desktop";
	id = 3;
	btype = "toggle";
	title = i18n("Toggle Desktop Bindings");
	desc = i18n("Lock/Unlock bindings");
	IsToggle = RDXDK.IsKeyBindingsLocked;
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\key";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\lock";
	OnClick = RDXDK.ToggleKeyBindingsLock;
});

RDXPM.RegisterMainButton({
	name = "windowslist_desktop";
	id = 4;
	btype = "custom";
	title = i18n("Window List");
	desc = "View the current windows available to OpenRDX";
	IsToggle = VFL.Noop;
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\gotoapp";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\gotoapp";
	OnClick = RDXDK.ToggleWindowList;
	OnDrag = VFL.Noop;
});

end);

--------------------------
-- MENU
--------------------------
--[[
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()

RDXPM.RegisterButton({
	name = "autoswitch_desktop_toggle";
	parent = "desktop";
	id = 1;
	btype = "toggle";
	title = i18n("Toggle Autoswitch Desktops");
	desc = i18n("Enable/Disable autoswitching of desktops");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\folderlocked";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\foldermove";
	IsToggle = RDXDK.IsAutoSwitchEnable;
	OnClick = RDXDK.ToggleAutoSwitchDesktop;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "autoswitch_desktop_manager";
	parent = "desktop";
	id = 2;
	btype = "custom";
	title = i18n("Open Autoswitch Desktop Manager");
	desc = i18n("Open the autoswitch manager");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\folderopenb";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\folderopenb";
	IsToggle = VFL.Noop;
	OnClick = RDXDK.DesktopsManage;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "lockunlock_desktop";
	parent = "desktop";
	id = 3;
	btype = "toggle";
	title = i18n("Toggle Desktop Lock");
	desc = i18n("Lock/Unlock the desktop");
	IsToggle = RDXDK.IsDesktopLocked;
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\file";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\filelocked";
	OnClick = RDXDK.ToggleDesktopLock;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "modify_desktop";
	parent = "desktop";
	id = 4;
	btype = "custom";
	title = i18n("Desktop Editor");
	desc = i18n("Open the desktop editor");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\edit";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\edit";
	IsToggle = VFL.Noop;
	OnClick = VFL.Noop;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "windowslist_desktop";
	parent = "desktop";
	id = 5;
	btype = "custom";
	title = i18n("Window List");
	desc = "View the current windows available to OpenRDX";
	IsToggle = VFL.Noop;
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\gotoapp";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\gotoapp";
	OnClick = RDXDK.WindowList;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "rebuild_desktop";
	parent = "desktop";
	id = 6;
	btype = "custom";
	title = i18n("Rebuild Desktop");
	desc = i18n("Rebuild the desktop");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\refresh";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\refresh";
	IsToggle = VFL.Noop;
	OnClick = RDXDK.RebuildAll;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "reset_desktop";
	parent = "desktop";
	id = 7;
	btype = "custom";
	title = i18n("Reset Desktop");
	desc = i18n("Reset the desktop");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\pastfile";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\pasfile";
	IsToggle = VFL.Noop;
	OnClick = RDXDK.DeskReset;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "clear_desktop";
	parent = "desktop";
	id = 8;
	btype = "custom";
	title = i18n("Clear Desktop");
	desc = i18n("Clear the desktop");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\deletefile";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\deletefile";
	IsToggle = VFL.Noop;
	OnClick = RDXDK.DeskClear;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "blizzard_desktop_manager";
	parent = "desktop";
	id = 9;
	btype = "custom";
	title = i18n("Blizzard UI Manager");
	desc = "Select which Blizzard UI elements to hide or show";
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\cut";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\refresh";
	IsToggle = VFL.Noop;
	OnClick = RDXDK.BlizzardManage;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "explorer_desktop";
	parent = "desktop";
	id = 10;
	btype = "custom";
	title = i18n("Package Explorer");
	desc = i18n("Open the package explorer");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\hd";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\hd";
	IsToggle = VFL.Noop;
	OnClick = RDXDB.ToggleObjectBrowser;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "reload_desktop";
	parent = "desktop";
	id = 19;
	btype = "custom";
	title = i18n("Reload UI");
	desc = i18n("Reload the UI");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\next";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\next";
	IsToggle = VFL.Noop;
	OnClick = RDXDK.ReloadUI;
	OnDrag = VFL.Noop;
});

end);
]]