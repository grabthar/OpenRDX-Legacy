-- OmniscienceMenu.lua
-- OpenRDX
--

Omni.OmniMenu = RDX.Menu:new();
Omni.OmniMenu:RegisterMenuFunction(function(ent)
	if not Omni.IsLiveWindowOpen() then
		ent.text = i18n("Combat Logs Window |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("Combat Logs Window |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); Omni.ToggleLiveWindow(); end;
end);
Omni.OmniMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Query logs of raid members");
	ent.OnClick = function() VFL.poptree:Release(); Omni.ToggleOmniSearch(); end;
end);
Omni.OmniMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Open Analyser logs");
	ent.OnClick = function() VFL.poptree:Release(); Omni.ToggleOmniBrowser(); end;
end);
Omni.OmniMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("-------------");
end);
Omni.OmniMenu:RegisterMenuEntry("Damage Meter", true, function(tree, frame)
	local mnu, omniTextFlag, syncomniTextFlag = {}, "", "";
	if not OmniDB.IsDamageMeterActive() then omniTextFlag = "|cFFFF0000[OFF]|r"; else omniTextFlag = "|cFF00FF00[ON]|r"; end
	if not OmniDB.IsSyncDamageMeterActive() then syncomniTextFlag = "|cFFFF0000[OFF]|r"; else syncomniTextFlag = "|cFF00FF00[ON]|r"; end
	table.insert(mnu, { text = i18n("Damage Meter ") .. omniTextFlag, OnClick = function() VFL.poptree:Release(); OmniDB.ToggleDamageMeter(); end });
	table.insert(mnu, { text = i18n("Sync with members ") .. syncomniTextFlag, OnClick = function() VFL.poptree:Release(); OmniDB.ToggleSyncDamageMeter(); end });
	table.insert(mnu, { text = i18n("Reset"), OnClick = function() VFL.poptree:Release(); OmniDB.ResetDamageMeter(); end });
	tree:Expand(frame, mnu);
end);
Omni.OmniMenu:RegisterMenuFunction(function(ent)
	if not RDXU.omniSL then
		ent.text = i18n("Storage logs |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("Storage logs |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); if RDXU.omniSL then RDXU.omniSL = nil; else RDXU.omniSL = true; end end;
end);
Omni.OmniMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Reset GUID Database");
	ent.OnClick = function() VFL.poptree:Release(); OmniDB.ClearOmniData(); end;
end);

function Omni.ShowOmniMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	Omni.OmniMenu:Open(VFL.poptree, nil);
end

--------------------------
-- MAIN buttons
--------------------------

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
RDXPM.RegisterMainButton({
	name = "omniscience";
	id = 7;
	btype = "menu";
	title = i18n("Omniscience");
	desc = i18n("Combat Log");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\find";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\find";
	IsToggle = VFL.Noop;
	OnClick = Omni.ShowOmniMenu;
});
end);

--[[
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()

RDXPM.RegisterButton({
	name = "livewindow_omniscience";
	parent = "omniscience";
	id = 41;
	btype = "toggle";
	title = i18n("Live window");
	desc = i18n("Open your combat logs");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\lock";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\favb";
	IsToggle = Omni.IsLiveWindowOpen;
	OnClick = Omni.ToggleLiveWindow;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "searchlogs_omniscience";
	id = 42;
	parent = "omniscience";
	btype = "custom";
	title = i18n("Query");
	desc = i18n("Search logs on the raid");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\networksearch";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\networksearch";
	IsToggle = VFL.Noop;
	OnClick = Omni.DoOmniSearch;
});

RDXPM.RegisterButton({
	name = "browser_omniscience";
	id = 43;
	parent = "omniscience";
	btype = "custom";
	title = i18n("Browser");
	desc = i18n("Open yours logs Analyser");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\infoabout";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\infoabout";
	IsToggle = VFL.Noop;
	OnClick = Omni.Open;
});

RDXPM.RegisterButton({
	name = "omnimeters_toggle";
	parent = "omniscience";
	id = 44;
	btype = "toggle";
	title = i18n("GUID Database");
	desc = i18n("Enable/Disable Damage/Heal meters");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\network";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\networkoptions";
	IsToggle = OmniDB.IsDamageMeterActive;
	OnClick = OmniDB.ToggleDamageMeter;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "reset_omnidb";
	parent = "omniscience";
	id = 45;
	btype = "custom";
	title = i18n("GUID Database");
	desc = i18n("Reset Database");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\delete";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\delete";
	IsToggle = VFL.Noop;
	OnClick = OmniDB.ClearOmniData;
	OnDrag = VFL.Noop;
});

end);
]]