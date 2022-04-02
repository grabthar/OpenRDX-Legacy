-- MainMenu.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- Functions for manipulating, displaying, and accessing the RDX6 main menu.

local _submenu_color = {r=0.2, g=0.9, b=0.9};

----------------------------------------------------
-- MENU OBJECT
----------------------------------------------------
RDX.Menu = {};
RDX.Menu.__index = RDX.Menu;

function RDX.Menu:new()
	local x = {};
	x.mm = {};
	x.entries = {};
	setmetatable(x, RDX.Menu);
	return x;
end

function RDX.Menu:RegisterMenuFunction(func)
	if type(func) ~= "function" then return; end
	table.insert(self.mm, func);
	return true;
end

function RDX.Menu:RegisterMenuEntry(title, isSubmenu, fn)
	if (not title) or (not fn) then return nil; end
	if isSubmenu then
		self:RegisterMenuFunction(function(entry)
			entry.text = title;
			entry.color = _submenu_color;
			entry.isSubmenu = true;
			entry.OnClick = function() fn(VFL.poptree, this); end;
		end);
	else
		self:RegisterMenuFunction(function(entry)
			entry.text = title;
			entry.OnClick = function() fn(VFL.poptree, this); end;
		end);
	end
	return true;
end

function RDX.Menu:Open(tree, frame)
	local i = 0;
	local mm, entries = self.mm, self.entries;
	for _,func in ipairs(mm) do
		i=i+1;
		if not entries[i] then entries[i] = {}; end
		VFL.empty(entries[i]);
		func(entries[i]);
	end
	for j,_ in ipairs(entries) do if j > i then entries[j] = nil; end end
	tree:Expand(frame, entries);
end

---------------------------------------------------------
-- THE MAIN MENU
--------------------------------------------------------
RDX.mainMenu = RDX.Menu:new();

--- Register an entry on the RDX main menu whose values are determined by function.
-- The function should accept a menu entry table and update the text, OnClick, etc as appropriate.
function RDX.RegisterMainMenuFunction(func)
	return RDX.mainMenu:RegisterMenuFunction(func);
end

--- Register an entry on the RDX main menu. 
--
-- When clicked, the entry will
-- invoke the given function, passing in the menu and the attach frame
-- as parameters for the purpose of spawning a submenu.
--
-- If isSubmenu is true, the menu entry will be decorated like a submenu
-- entry. isSubmenu causes no functional change.
function RDX.RegisterMainMenuEntry(title, isSubmenu, fn)
	return RDX.mainMenu:RegisterMenuEntry(title, isSubmenu, fn);
end

--- Show the RDX main menu at the current mouse position.
function RDX.ShowMainMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	RDX.mainMenu:Open(VFL.poptree, nil);
end

--------------------------------------------------------
-- THE SYSTEM MENU
--------------------------------------------------------
--RDX.systemMenu = RDX.Menu:new();
--RDX.RegisterMainMenuEntry(i18n("System"), true, function(tree, frame) RDX.systemMenu:Open(tree, frame); end);

--------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------
-- The minimize button on the toolbar.
--[[
local minbtn = VFLUI.AcquireFrame("Button");
local mbtex = VFLUI.CreateTexture(minbtn);
mbtex:SetAllPoints(minbtn);
mbtex:Show();
minbtn:SetHighlightTexture(mbtex);
mbtex:SetBlendMode("DISABLE");
if RDX._skin == "boomy" then
	minbtn:SetNormalTexture("Interface\\Addons\\RDX\\Skin\\boomy\\delete");
	mbtex:SetTexture("Interface\\Addons\\RDX\\Skin\\boomy\\delete");
elseif RDX._skin == "kids" then
	minbtn:SetNormalTexture("Interface\\Addons\\RDX\\Skin\\kids\\x");
	mbtex:SetTexture("Interface\\Addons\\RDX\\Skin\\kids\\x");
else
	minbtn:SetNormalTexture("Interface\\Addons\\RDX\\Skin\\x");
	mbtex:SetTexture("Interface\\Addons\\RDX\\Skin\\x");
end
mbtex:SetVertexColor(0.6, 0, 0);
minbtn:SetScript("OnClick", function() RDX.Minimize(); end);]]

-- The menu button on the toolbar.
local menubtn = VFLUI.AcquireFrame("Button");
local mbtex = VFLUI.CreateTexture(menubtn);
mbtex:SetAllPoints(menubtn);
mbtex:Show();
menubtn:SetHighlightTexture(mbtex);
mbtex:SetBlendMode("DISABLE");
if RDX._skin == "boomy" then
	menubtn:SetNormalTexture("Interface\\Addons\\RDX\\Skin\\boomy\\home");
	mbtex:SetTexture("Interface\\Addons\\RDX\\Skin\\boomy\\home");
elseif RDX._skin == "kids" then
	menubtn:SetNormalTexture("Interface\\Addons\\RDX\\Skin\\kids\\kfm-home");
	mbtex:SetTexture("Interface\\Addons\\RDX\\Skin\\kids\\kfm-home");
else
	menubtn:SetNormalTexture("Interface\\Addons\\RDX\\Skin\\menu");
	mbtex:SetTexture("Interface\\Addons\\RDX\\Skin\\menu");
end
mbtex:SetVertexColor(0, 0.6, 0.6);
menubtn:SetScript("OnClick", function() RDX.ShowMainMenu(); end);

-- Defer slightly so the menu button is at the end.
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	--RDX.AddToolbarButton(minbtn, true);
	RDX.AddToolbarButton(menubtn, true); 
end);

