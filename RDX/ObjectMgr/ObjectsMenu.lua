-- ObjectsMenu.lua
-- OpenRDX
--

RDXDB.ObjectMenu = RDX.Menu:new();
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	if RDX.IsRcvDisable() then
		ent.text = i18n("Sharing Packages |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("Sharing Packages |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); RDX.ToggleRcvPackage(); end;
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Open OOBE Manager");
	ent.OnClick = function() VFL.poptree:Release(); RDX.DropOOBE(); end;
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Open RDX Addons Updater");
	ent.OnClick = function() VFL.poptree:Release(); RDXDB.ToggleRAU(); end;
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Backup packages");
	ent.OnClick = function() VFL.poptree:Release(); RDX.BackupPackages(); end;
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Restore packages");
	ent.OnClick = function() VFL.poptree:Release(); RDX.RestorePackages(); end;
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("-------------");
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Master Reset RDX");
	ent.OnClick = function() VFL.poptree:Release(); RDX.MasterReset(); end;
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("-------------");
end);
RDXDB.ObjectMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Window Wizard");
	ent.OnClick = function() VFL.poptree:Release(); RDX.NewWindowWizard(); end;
end);

function RDXDB.ShowObjectMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	RDXDB.ObjectMenu:Open(VFL.poptree, nil);
end

--------------------------
-- MAIN buttons
--------------------------

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
RDXPM.RegisterMainButton({
	name = "package";
	id = 5;
	btype = "menu";
	title = i18n("Package Manager");
	desc = "Manage Your Packages";
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\database";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\down";
	IsToggle = VFL.Noop;
	OnClick = RDXDB.ShowObjectMenu;
});
RDXPM.RegisterMainButton({
	name = "explorer_package";
	id = 6;
	btype = "custom";
	title = i18n("Packages");
	desc = i18n("Open Packages Explorer");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\hd";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\hd";
	IsToggle = VFL.Noop;
	OnClick = RDXDB.ToggleObjectBrowser;
	OnDrag = VFL.Noop;
});
end);

--[[
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()

RDXPM.RegisterButton({
	name = "explorer_package";
	parent = "package";
	id = 21;
	btype = "custom";
	title = i18n("Packages");
	desc = i18n("Open Package Explorer");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\hd";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\hd";
	IsToggle = VFL.Noop;
	OnClick = RDXDB.ToggleObjectBrowser;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "rcvpck_package";
	parent = "package";
	id = 22;
	btype = "toggle";
	title = i18n("Packages");
	desc = i18n("Enable Receiving Packages");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\web";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\weblocked";
	IsToggle = RDX.IsRcvDisable;
	OnClick = RDX.ToggleRcvPackage;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "oobe_manager_package";
	parent = "package";
	id = 23;
	btype = "custom";
	title = i18n("Out of Box Experience");
	desc = i18n("Open OOBE Manager");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\documentsorcopy";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\documentsorcopy";
	IsToggle = VFL.Noop;
	OnClick = RDX.DropOOBE;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "backup_package";
	parent = "package";
	id = 24;
	btype = "custom";
	title = i18n("Recovery");
	desc = i18n("Backup Your Packages");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\saveas";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\saveas";
	IsToggle = VFL.Noop;
	OnClick = RDX.BackupPackages;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "restore_package";
	parent = "package";
	id = 25;
	btype = "custom";
	title = i18n("Recovery");
	desc = i18n("Restore Your Packages");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\cd";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\cd";
	IsToggle = VFL.Noop;
	OnClick = RDX.RestorePackages;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "reset_package";
	parent = "package";
	id = 26;
	btype = "custom";
	title = i18n("RESET");
	desc = i18n("Drop All Your Packages");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\bug";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\bug";
	IsToggle = VFL.Noop;
	OnClick = RDX.MasterReset;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "wwiz_package";
	parent = "package";
	id = 28;
	btype = "custom";
	title = i18n("Wizard");
	desc = i18n("Create Raid Window");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\wizard";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\wizard";
	IsToggle = VFL.Noop;
	OnClick = RDX.NewWindowWizard;
	OnDrag = VFL.Noop;
});

end);
]]
