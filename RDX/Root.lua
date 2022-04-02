-- Root.lua
-- RDX - Raid Data Exchange
-- (C)2005 Bill Johnson
--
-- Event dispatcher, core simple functions, loaded before all other scripts
--

RDX = RegisterVFLModule({
	name = "RDX";
	description = "Raid Data Exchange";
	parent = VFL;
});
RDX:LoadVersionFromTOC("RDX");
--RDX:ModuleSetDebugLevel(6);

-- The module tablespace
RDXM = {};

----------------------------
-- KEYBINDING NAMES
----------------------------
BINDING_HEADER_RDX = "RDX";
BINDING_NAME_RDXHIDEUI = i18n("Show/Hide RDX");
BINDING_NAME_RDXMENU = i18n("Open RDX Main Menu");
BINDING_NAME_RDXEXPLORER = i18n("Open RDX Explorer");
BINDING_NAME_RDXWL = i18n("Window List");
BINDING_NAME_RDXROSTER = i18n("Open Roster Window");

----------------------------
-- EVENT DISPATCHER
----------------------------
RDXEvents = DispatchTable:new();
RDXEvents.name = "RDXEvents";

-------------------
-- UI SUPPORT FUNCTIONS
-------------------
-- Spam RDX-type chat
function RDX.print(str)
	VFL.print("* |cFFAAAAAAOpenRDX:|r " .. str);
end

function RDX.printI(str)
	VFL.print("* |cFFAAAAAAOpenRDX|r |cFF00FF00INFO:|r " .. str);
end

function RDX.printW(str)
	VFL.print("* |cFFAAAAAAOpenRDX|r |cFFFFFF00WARNING:|r" .. str);
end

function RDX.printE(str)
	VFL.print("* |cFFAAAAAAOpenRDX|r |cFFFF0000ERROR:|r" .. str);
end

-- Generate a unique ID number
function RDX.GenerateUniqueID()
	return math.random(10000000);
end

-------------------------
-- SOME GLOBAL COLORS
-------------------------
_red = {r=0.9,g=0,b=0,a=1};
_yellow = {r=1,g=1,b=0,a=1};
_orange = {r=1,g=0.5,b=0,a=1};
_green = {r=0,g=0.5,b=0,a=1};
_blue = {r=0, g=0, b=1, a = 1};
_white = {r=1,g=1,b=1,a=1};
_black = {r=0,g=0,b=0,a=1};
_alphaBlack = {r=0,g=0,b=0,a=.5};
_grey = {r=.3, g=.3, b=.3, a=1};
_dcyan = {r=0, g=.6, b=.6, a=1};
_midgrey = {r=.5, g=.5, b=.5, a=1};
_alphafull = {r=0, g=0, b=0, a=0};

-- boomy, kids or classic
RDX._skin = "boomy";

