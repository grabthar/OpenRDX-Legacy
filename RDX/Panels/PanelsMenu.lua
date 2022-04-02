-- PanelsMenu.lua
-- OpenRDX

RDXPM.ThirdPartyMenu = RDX.Menu:new();

--- Register an entry on the RDX 3Party menu whose values are determined by function.
-- The function should accept a menu entry table and update the text, OnClick, etc as appropriate.
function RDXPM.RegisterThirdPartyMenuFunction(func)
	return RDXPM.ThirdPartyMenu:RegisterMenuFunction(func);
end

--- Register an entry on the RDX main menu. 
--
-- When clicked, the entry will
-- invoke the given function, passing in the menu and the attach frame
-- as parameters for the purpose of spawning a submenu.
--
-- If isSubmenu is true, the menu entry will be decorated like a submenu
-- entry. isSubmenu causes no functional change.
function RDXPM.RegisterThirdPartyMenuEntry(title, isSubmenu, fn)
	return RDXPM.ThirdPartyMenu:RegisterMenuEntry(title, isSubmenu, fn);
end

function RDXPM.ShowThirdPartyMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	RDXPM.ThirdPartyMenu:Open(VFL.poptree, nil);
end

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
--[[
RDXPM.RegisterMainButton({
	name = "main";
	id = 120;
	btype = "default";
	title = i18n("Main options");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\home";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\down";
	desc = "Main Options";
	OnClick = VFL.Noop;
});
]]

RDXPM.RegisterMainButton({
	name = "thirdParty";
	id = 9;
	btype = "custom";
	title = i18n("Third party addons");
	desc = i18n("Third party addons");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\fav";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\fav";
	IsToggle = VFL.Noop;
	OnClick = RDXPM.ShowThirdPartyMenu;
});

RDXPM.RegisterMainButton({
	name = "hidepanel";
	id = 200;
	btype = "custom";
	title = i18n("Minimize the main panel");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\delete";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\down";
	desc = "";
	OnClick = RDXPM.Minimize;
});

end);

