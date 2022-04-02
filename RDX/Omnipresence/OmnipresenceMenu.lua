-- OmnipresenceMenu.lua
-- OpenRDX
--

Logistics.MainMenu = RDX.Menu:new();
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Check RDX Version");
	ent.OnClick = function() VFL.poptree:Release(); RDX.VersionCheck_Start(); end;
end);
Logistics.MainMenu:RegisterMenuEntry("Assist", true, function(tree, frame)
	local mnu = {};
	table.insert(mnu, { text = "Add Target to Assists", OnClick = function() VFL.poptree:Release(); Logistics.AddAssist(); end });
	table.insert(mnu, { text = "Remove Target from Assists", OnClick = function() VFL.poptree:Release(); Logistics.DropAssist(); end });
	table.insert(mnu, { text = "Sync Assists", OnClick = function() VFL.poptree:Release(); Logistics.SyncAssists(); end });
	table.insert(mnu, { text = "|cFFAAAAAA--------------|r" });
	table.insert(mnu, { text = "Clear Assists", OnClick = function() VFL.poptree:Release(); Logistics.ClearAssists(); end });
	tree:Expand(frame, mnu);
end);
Logistics.MainMenu:RegisterMenuEntry("Raid Invites", true, function(tree, frame)
	local mnu = {};
	--table.insert(mnu, {text = "Mass Invite", OnClick = function() RDXI_Invite(); tree:Release(); end});
	table.insert(mnu, {text = "Disband Raid", OnClick = function() Logistics.Disband(); tree:Release(); end});
	table.insert(mnu, {text = "Toggle Keyword Invite", OnClick = function() Logistics.ToggleKeyword(); tree:Release(); end});
	table.insert(mnu, {text = "Change Keyword", OnClick = function() Logistics.SetKeyword(); tree:Release(); end});
	table.insert(mnu, {text = "Request Invite", OnClick = function() Logistics.RequestInvite(); tree:Release(); end});
	--table.insert(mnu, {text = "Set Min. Invite Level", OnClick = function() Logistics.SetMinLevel(); tree:Release(); end});
	table.insert(mnu, {text = "Remote Logout", OnClick = function() Logistics.BootAfk(); tree:Release(); end});
	tree:Expand(frame, mnu);
end);
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Check Durability");
	ent.OnClick = function() VFL.poptree:Release(); Logistics.DuraCheck_Start(); end;
end);
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Check Resist");
	ent.OnClick = function() VFL.poptree:Release(); Logistics.ResistCheck_Start(); end;
end);
Logistics.MainMenu:RegisterMenuEntry("Check Inventory", true, function(tree, frame)
	local mnu = {};
	table.insert(mnu, { text = "Custom...", OnClick = function() VFL.poptree:Release(); Logistics.InvCheckFrontend(); end });
	table.insert(mnu, { text = "*potion*", OnClick = function() VFL.poptree:Release(); Logistics.DoInvCheck("*potion*"); end });
	table.insert(mnu, { text = "*healthstone*", OnClick = function() VFL.poptree:Release(); Logistics.DoInvCheck("*healthstone*"); end });
	table.insert(mnu, { text = "|cFFAAAAAARecent searches:|r" });
	if RDXU and RDXU.icMRU then
		for k,v in ipairs(RDXU.icMRU) do
			table.insert(mnu, { text = k .. ". " .. v, OnClick = function() VFL.poptree:Release(); Logistics.DoInvCheck(v); end });
		end
	end
	tree:Expand(frame, mnu);
end);
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Check Ready");
	ent.OnClick = function() VFL.poptree:Release(); Logistics.ReadyCheck(); end;
end);
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Poll");
	ent.OnClick = function() VFL.poptree:Release(); Logistics.CustomPollDlg(); end;
end);
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("-------------");
end);
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	if not HealSync.IsTargetHealingOpen() then
		ent.text = i18n("Target Heal Window |cFFFF0000[OFF]|r");
	else
		ent.text = i18n("Target Heal Window |cFF00FF00[ON]|r");
	end
	ent.OnClick = function() VFL.poptree:Release(); HealSync.ToggleTargetHealingWindow(); end;
end);
Logistics.MainMenu:RegisterMenuFunction(function(ent)
	ent.text = i18n("Open the roster");
	ent.OnClick = function() VFL.poptree:Release(); RDX.OpenRosterWindow(); end;
end);

function Logistics.ShowLogisticsMenu()
	VFL.poptree:Begin(160, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
	Logistics.MainMenu:Open(VFL.poptree, nil);
end

--------------------------
-- MAIN buttons
--------------------------

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
RDXPM.RegisterMainButton({
	name = "omnipresence";
	id = 8;
	btype = "menu";
	title = i18n("Omnipresence");
	desc = "Query your raid members";
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\groupofusers";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\groupofusers";
	IsToggle = VFL.Noop;
	OnClick = Logistics.ShowLogisticsMenu;
});

end);

--[[
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()

RDXPM.RegisterButton({
	name = "checkdurability_omnipresence";
	id = 61;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Query");
	desc = i18n("Check Durability on the raid");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\user";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\user";
	IsToggle = VFL.Noop;
	OnClick = Logistics.DuraCheck_Start;
});

RDXPM.RegisterButton({
	name = "checkresist_omnipresence";
	id = 62;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Query");
	desc = i18n("Check Resist on the raid");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\userb";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\userb";
	IsToggle = VFL.Noop;
	OnClick = Logistics.ResistCheck_Start;
});

RDXPM.RegisterButton({
	name = "inventory_omnipresence";
	id = 63;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Query");
	desc = i18n("Inventory of your raid");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\find";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\find";
	IsToggle = VFL.Noop;
	OnClick = Logistics.ShowInventoryMenu;
});


RDXPM.RegisterButton({
	name = "readycheck_omnipresence";
	id = 64;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Query");
	desc = i18n("Check Ready on the raid");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\accept";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\accept";
	IsToggle = VFL.Noop;
	OnClick = Logistics.ReadyCheck;
});

RDXPM.RegisterButton({
	name = "poll_omnipresence";
	id = 65;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Query");
	desc = i18n("Poll on the raid");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\help";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\help";
	IsToggle = VFL.Noop;
	OnClick = Logistics.CustomPollDlg;
});

RDXPM.RegisterButton({
	name = "targetheal_omnipresence";
	parent = "omnipresence";
	id = 66;
	btype = "toggle";
	title = i18n("Target Heal Window");
	desc = i18n("Monitor incoming heal on unit");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\deleteuser";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\adduser";
	IsToggle = HealSync.IsTargetHealingOpen;
	OnClick = HealSync.ToggleTargetHealingWindow;
	OnDrag = VFL.Noop;
});

RDXPM.RegisterButton({
	name = "assist_omnipresence";
	id = 67;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Assist");
	desc = i18n("Manage Assist team");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\fav";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\fav";
	IsToggle = VFL.Noop;
	OnClick = Logistics.ShowAssistMenu;
});

RDXPM.RegisterButton({
	name = "roster_omnipresence";
	id = 68;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Roster");
	desc = i18n("Open your roster");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\pictures";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\pictures";
	IsToggle = VFL.Noop;
	OnClick = RDX.OpenRosterWindow;
});

RDXPM.RegisterButton({
	name = "checkversion_omnipresence";
	id = 69;
	parent = "omnipresence";
	btype = "custom";
	title = i18n("Query");
	desc = i18n("Check RDX Version on the raid");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\websearch";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\websearch";
	IsToggle = VFL.Noop;
	OnClick = RDX.VersionCheck_Start;
});

end);
]]
