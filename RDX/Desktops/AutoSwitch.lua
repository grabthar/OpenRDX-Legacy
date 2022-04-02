-- OpenRDX
-- Sigg Rashgarroth EU
-- Desktop Main function
-- Autoswitch

----------------------------------
-- DESKTOP Autoswitch
----------------------------------

local function createDesktop(name)
	local mde = RDXDB.TouchObject("desktops:" .. RDX.pspace .. "_" .. name);
	if not mde.data then
	mde.data = {};
	mde.ty = "Desktop"; 
	mde.version = 2;
	table.insert(mde.data, { feature = "Desktop main"; title = RDX.pspace .. "_" .. name; resolution = VFLUI.GetCurrentResolution(); uiscale = VFLUI.GetCurrentEffectiveScale();});
	end;
end

function RDXDK.MakeDesktops()
local mde = RDXDB.TouchObject("desktops:default");
if not mde.data then
mde.data = {};
mde.ty = "Desktop"; 
mde.version = 2;
table.insert(mde.data, { feature = "Desktop main"; title = "default"; resolution = VFLUI.GetCurrentResolution(); uiscale = VFLUI.GetCurrentEffectiveScale();});
end;

createDesktop("inn");
createDesktop("solo");
createDesktop("group");
createDesktop("raid");
createDesktop("pvp");
createDesktop("arena");

createDesktop("inn2");
createDesktop("solo2");
createDesktop("group2");
createDesktop("raid2");
createDesktop("pvp2");
createDesktop("arena2");

if not RDXU.Desktops then RDXU.Desktops = {}; end
if not RDXU.Desktops["InnDesktop"] then RDXU.Desktops["InnDesktop"] = "desktops:" .. RDX.pspace .. "_inn"; end
if not RDXU.Desktops["SoloDesktop"] then RDXU.Desktops["SoloDesktop"] = "desktops:" .. RDX.pspace .. "_solo"; end
if not RDXU.Desktops["GroupDesktop"] then RDXU.Desktops["GroupDesktop"] = "desktops:" .. RDX.pspace .. "_group"; end
if not RDXU.Desktops["RaidDesktop"] then RDXU.Desktops["RaidDesktop"] = "desktops:" .. RDX.pspace .. "_raid"; end
if not RDXU.Desktops["PvpDesktop"] then RDXU.Desktops["PvpDesktop"] = "desktops:" .. RDX.pspace .. "_pvp"; end
if not RDXU.Desktops["ArenaDesktop"] then RDXU.Desktops["ArenaDesktop"] = "desktops:" .. RDX.pspace .. "_arena"; end

if not RDXU.Desktops2 then RDXU.Desktops2 = {}; end
if not RDXU.Desktops2["InnDesktop"] then RDXU.Desktops2["InnDesktop"] = "desktops:" .. RDX.pspace .. "_inn2"; end
if not RDXU.Desktops2["SoloDesktop"] then RDXU.Desktops2["SoloDesktop"] = "desktops:" .. RDX.pspace .. "_solo2"; end
if not RDXU.Desktops2["GroupDesktop"] then RDXU.Desktops2["GroupDesktop"] = "desktops:" .. RDX.pspace .. "_group2"; end
if not RDXU.Desktops2["RaidDesktop"] then RDXU.Desktops2["RaidDesktop"] = "desktops:" .. RDX.pspace .. "_raid2"; end
if not RDXU.Desktops2["PvpDesktop"] then RDXU.Desktops2["PvpDesktop"] = "desktops:" .. RDX.pspace .. "_pvp2"; end
if not RDXU.Desktops2["ArenaDesktop"] then RDXU.Desktops2["ArenaDesktop"] = "desktops:" .. RDX.pspace .. "_arena2"; end

if not RDXU.DesktopsTrigger then 
	RDXU.DesktopsTrigger = {};
	RDXU.DesktopsTrigger["InnDesktop"] = true;
	RDXU.DesktopsTrigger["SoloDesktop"] = true;
	RDXU.DesktopsTrigger["GroupDesktop"] = true;
	RDXU.DesktopsTrigger["RaidDesktop"] = true;
	RDXU.DesktopsTrigger["PvpDesktop"] = true;
	RDXU.DesktopsTrigger["ArenaDesktop"] = true;
end

end;

local function SwitchDesktop(path, nosave)
	local dk = nil;
	RDXU.ActiveTalentGroup = GetActiveTalentGroup();
	if RDXU.ActiveTalentGroup == 1 then
		dk = RDXU.Desktops;
	elseif RDXU.ActiveTalentGroup == 2 then
		dk = RDXU.Desktops2;
	else
		dk = RDXU.Desktops;
	end
	if RDXU.autoSwitchDesk then
		if VFL.InArena() then
			if RDXU.DesktopsTrigger["ArenaDesktop"] then
				if path then dk["ArenaDesktop"] = path; end
				if RDXDK.GetCurrentDesktopPath() ~= dk["ArenaDesktop"] then
					RDXDK.SecuredChangeDesktop(dk["ArenaDesktop"], nosave);
					--RDX.print("Change desktop " .. dk["ArenaDesktop"]);
				end
			else
				RDXDK.SecuredChangeDesktop(dk["SoloDesktop"], nosave);
			end
		elseif VFL.InBattleground() then
			if RDXU.DesktopsTrigger["PvpDesktop"] then
				if path then dk["PvpDesktop"] = path; end
				if RDXDK.GetCurrentDesktopPath() ~= dk["PvpDesktop"] then
					RDXDK.SecuredChangeDesktop(dk["PvpDesktop"], nosave);
					--RDX.print("Change desktop " .. dk["PvpDesktop"]);
				end
			else
				RDXDK.SecuredChangeDesktop(dk["SoloDesktop"], nosave);
			end
		elseif RDX.InRaid() then
			if RDXU.DesktopsTrigger["RaidDesktop"] then	
				if path then dk["RaidDesktop"] = path; end
				if RDXDK.GetCurrentDesktopPath() ~= dk["RaidDesktop"] then
					RDXDK.SecuredChangeDesktop(dk["RaidDesktop"], nosave);
					--RDX.print("Change desktop " .. dk["RaidDesktop"]);
				end
			else
				RDXDK.SecuredChangeDesktop(dk["SoloDesktop"], nosave);
			end
		elseif RDX.IsSolo() then
			if path then dk["SoloDesktop"] = path; end
			if RDXDK.GetCurrentDesktopPath() ~= dk["SoloDesktop"] then
				RDXDK.SecuredChangeDesktop(dk["SoloDesktop"], nosave);
				--RDX.print("Change desktop " .. dk["SoloDesktop"]);
			end
		elseif (RDX.GetNumUnits() > 1) then
			if RDXU.DesktopsTrigger["GroupDesktop"] then
				if path then dk["GroupDesktop"] = path; end
				if RDXDK.GetCurrentDesktopPath() ~= dk["GroupDesktop"] then
					RDXDK.SecuredChangeDesktop(dk["GroupDesktop"], nosave);
					--RDX.print("Change desktop " .. dk["GroupDesktop"]);
				end
			else
				RDXDK.SecuredChangeDesktop(dk["SoloDesktop"], nosave);
			end
		end
	else
		if path then dk["SoloDesktop"] = path; end
		if RDXDK.GetCurrentDesktopPath() ~= dk["SoloDesktop"] then
			RDXDK.SecuredChangeDesktop(dk["SoloDesktop"], nosave);
		end
	end
end

local function SwitchDesktopdelay()
	VFL.ZMSchedule(1, function()  SwitchDesktop(); end);
end

local function SwitchDesktop_Enable()
	RDXU.autoSwitchDesk = true;
	RDXEvents:Bind("PARTY_IS_RAID", nil, function() SwitchDesktop(); end,"RDX_ChangeDesk");
	RDXEvents:Bind("PARTY_IS_NONRAID", nil, function() SwitchDesktop(); end, "RDX_ChangeDesk");
	VFLEvents:Bind("PLAYER_IN_ARENA", nil, function(flag) if flag then SwitchDesktop(); end; end, "RDX_ChangeDesk");
	VFLEvents:Bind("PLAYER_IN_BATTLEGROUND", nil, function(flag) if flag then SwitchDesktop(); end; end, "RDX_ChangeDesk");
	WoWEvents:Unbind("RDX_Talent_ChangeDesk"); 
	WoWEvents:Bind("PLAYER_TALENT_UPDATE", nil, function() if (RDXU.ActiveTalentGroup ~= GetActiveTalentGroup()) then SwitchDesktop(nil, true); end; end, "RDX_Talent_ChangeDesk");
	SwitchDesktop();
end;
RDXDK.SwitchDesktop_Enable = SwitchDesktop_Enable;

local function SwitchDesktop_Disable()
	RDXU.autoSwitchDesk = false;
	RDXEvents:Unbind("RDX_ChangeDesk");
	VFLEvents:Unbind("RDX_ChangeDesk");
	--WoWEvents:Unbind("RDX_ChangeDesk");
	WoWEvents:Unbind("RDX_Talent_ChangeDesk");
	WoWEvents:Bind("PLAYER_TALENT_UPDATE", nil, function() if (RDXU.ActiveTalentGroup ~= GetActiveTalentGroup()) then SwitchDesktop(nil, true); end; end, "RDX_Talent_ChangeDesk");
	SwitchDesktop();
end;
RDXDK.SwitchDesktop_Disable = SwitchDesktop_Disable;

function RDXDK.ToggleAutoSwitchDesktop()
	if RDXU.autoSwitchDesk then
		RDX.print(i18n("Disable Auto Switch Desktop"));
		SwitchDesktop_Disable();
	else
		RDX.print(i18n("Enable Auto Switch Desktop"));
		SwitchDesktop_Enable();
	end
end

function RDXDK.IsAutoSwitchEnable()
	if RDXU then return RDXU.autoSwitchDesk; else return nil; end
end

function RDXDK.SetSwichDesktop(path)
	SwitchDesktop(path);
end

-- Show a window for selecting desktops autoswitch
local dlg = nil;
function RDXDK.DesktopsManage()
	if dlg then return; end
	
	local dk = nil;
	if GetActiveTalentGroup() == 1 then
		dk = RDXU.Desktops;
	elseif GetActiveTalentGroup() == 2 then
		dk = RDXU.Desktops2;
	else
		dk = RDXU.Desktops;
	end
	
	dlg = VFLUI.Window:new(UIParent);
	dlg:SetFrameStrata("FULLSCREEN");
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetBackdrop(VFLUI.DefaultDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(380); dlg:SetHeight(200);
	dlg:SetTitleColor(0,.6,0);
	dlg:SetText("Manage Auto Switch Desktops");

	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	if RDXPM.Ismanaged("autoswitch_desktop") then RDXPM.RestoreLayout(dlg, "autoswitch_desktop"); end
	
	local inn = RDXDB.ObjectFinder:new(dlg, function(p,f,md) return (md and type(md) == "table" and md.ty=="Desktop"); end);
	inn:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	inn:SetWidth(342); inn:Show();
	inn:SetLabel("Inn Desktop:");
	inn:SetPath(dk["InnDesktop"]);
	
	local chk_inn = VFLUI.Checkbox:new(dlg);
	chk_inn:SetPoint("LEFT", inn, "RIGHT");
	chk_inn:SetHeight(16); chk_inn:SetWidth(16);
	if RDXU.DesktopsTrigger["InnDesktop"] then chk_inn:SetChecked(true); else chk_inn:SetChecked(); end
	chk_inn:Show();
	
	local solo = RDXDB.ObjectFinder:new(dlg, function(p,f,md) return (md and type(md) == "table" and md.ty=="Desktop"); end);
	solo:SetPoint("TOPLEFT", inn, "BOTTOMLEFT");
	solo:SetWidth(342); solo:Show();
	solo:SetLabel("Solo Desktop:");
	solo:SetPath(dk["SoloDesktop"]);
	
	local chk_solo = VFLUI.Checkbox:new(dlg);
	chk_solo:SetPoint("LEFT", solo, "RIGHT");
	chk_solo:SetHeight(16); chk_solo:SetWidth(16);
	if RDXU.DesktopsTrigger["SoloDesktop"] then chk_solo:SetChecked(true); else chk_solo:SetChecked(); end
	chk_solo:Show();
	
	local group = RDXDB.ObjectFinder:new(dlg, function(p,f,md) return (md and type(md) == "table" and md.ty=="Desktop"); end);
	group:SetPoint("TOPLEFT", solo, "BOTTOMLEFT");
	group:SetWidth(342); group:Show();
	group:SetLabel("Group Desktop:");
	group:SetPath(dk["GroupDesktop"]);
	
	local chk_group = VFLUI.Checkbox:new(dlg);
	chk_group:SetPoint("LEFT", group, "RIGHT");
	chk_group:SetHeight(16); chk_group:SetWidth(16);
	if RDXU.DesktopsTrigger["GroupDesktop"] then chk_group:SetChecked(true); else chk_group:SetChecked(); end
	chk_group:Show();
	
	local raid = RDXDB.ObjectFinder:new(dlg, function(p,f,md) return (md and type(md) == "table" and md.ty=="Desktop"); end);
	raid:SetPoint("TOPLEFT", group, "BOTTOMLEFT");
	raid:SetWidth(342); raid:Show();
	raid:SetLabel("Raid Desktop:");
	raid:SetPath(dk["RaidDesktop"]);
	
	local chk_raid = VFLUI.Checkbox:new(dlg);
	chk_raid:SetPoint("LEFT", raid, "RIGHT");
	chk_raid:SetHeight(16); chk_raid:SetWidth(16);
	if RDXU.DesktopsTrigger["RaidDesktop"] then chk_raid:SetChecked(true); else chk_raid:SetChecked(); end
	chk_raid:Show();
	
	local pvp = RDXDB.ObjectFinder:new(dlg, function(p,f,md) return (md and type(md) == "table" and md.ty=="Desktop"); end);
	pvp:SetPoint("TOPLEFT", raid, "BOTTOMLEFT");
	pvp:SetWidth(342); pvp:Show();
	pvp:SetLabel("PVP Desktop:");
	pvp:SetPath(dk["PvpDesktop"]);
	
	local chk_pvp = VFLUI.Checkbox:new(dlg);
	chk_pvp:SetPoint("LEFT", pvp, "RIGHT");
	chk_pvp:SetHeight(16); chk_pvp:SetWidth(16);
	if RDXU.DesktopsTrigger["PvpDesktop"] then chk_pvp:SetChecked(true); else chk_pvp:SetChecked(); end
	chk_pvp:Show();
	
	local arena = RDXDB.ObjectFinder:new(dlg, function(p,f,md) return (md and type(md) == "table" and md.ty=="Desktop"); end);
	arena:SetPoint("TOPLEFT", pvp, "BOTTOMLEFT");
	arena:SetWidth(342); arena:Show();
	arena:SetLabel("Arena Desktop:");
	arena:SetPath(dk["ArenaDesktop"]);
	
	local chk_arena = VFLUI.Checkbox:new(dlg);
	chk_arena:SetPoint("LEFT", arena, "RIGHT");
	chk_arena:SetHeight(16); chk_arena:SetWidth(16);
	if RDXU.DesktopsTrigger["ArenaDesktop"] then chk_arena:SetChecked(true); else chk_arena:SetChecked(); end
	chk_arena:Show();
	
	dlg:Show(.2, true);
	
	local esch = function()
		dlg:Hide(.2, true);
		VFL.ZMSchedule(.25, function()
			RDXPM.StoreLayout(dlg, "autoswitch_desktop");
			dlg:Destroy(); dlg = nil;
		end);
	end
	VFL.AddEscapeHandler(esch);
	
	local btnClose = VFLUI.CloseButton:new(dlg);
	dlg:AddButton(btnClose);
	btnClose:SetScript("OnClick", function() VFL.EscapeTo(esch); end);
	
	-- OK
	local btnOK = VFLUI.OKButton:new(dlg);
	btnOK:SetHeight(25); btnOK:SetWidth(60);
	btnOK:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
	btnOK:SetText("OK"); btnOK:Show();
	btnOK:SetScript("OnClick", function()
		local dk = nil;
		if GetActiveTalentGroup() == 1 then
			dk = RDXU.Desktops;
		elseif GetActiveTalentGroup() == 2 then
			dk = RDXU.Desktops2;
		else
			dk = RDXU.Desktops;
		end
		dk["InnDesktop"] = inn:GetPath();
		RDXU.DesktopsTrigger["InnDesktop"] = chk_inn:GetChecked();
		dk["SoloDesktop"] = solo:GetPath();
		RDXU.DesktopsTrigger["SoloDesktop"] = chk_solo:GetChecked();
		dk["GroupDesktop"] = group:GetPath();
		RDXU.DesktopsTrigger["GroupDesktop"] = chk_group:GetChecked();
		dk["RaidDesktop"] = raid:GetPath();
		RDXU.DesktopsTrigger["RaidDesktop"] = chk_raid:GetChecked();
		dk["PvpDesktop"] = pvp:GetPath();
		RDXU.DesktopsTrigger["PvpDesktop"] = chk_pvp:GetChecked();
		dk["ArenaDesktop"] = arena:GetPath();
		RDXU.DesktopsTrigger["ArenaDesktop"] = chk_arena:GetChecked();
		if RDXU.autoSwitchDesk then SwitchDesktop(); end
		VFL.EscapeTo(esch);
	end);

	-- Destructor
	dlg.Destroy = VFL.hook(function(s)
		inn:Destroy(); inn = nil;
		chk_inn:Destroy(); chk_inn = nil;
		solo:Destroy(); solo = nil;
		chk_solo:Destroy(); chk_solo = nil;
		group:Destroy(); group = nil;
		chk_group:Destroy(); chk_group = nil;
		raid:Destroy(); raid = nil;
		chk_raid:Destroy(); chk_raid = nil;
		pvp:Destroy(); pvp = nil;
		chk_pvp:Destroy(); chk_pvp = nil;
		arena:Destroy(); arena = nil;
		chk_arena:Destroy(); chk_arena = nil;
		btnOK:Destroy(); btnOK = nil;
	end, dlg.Destroy);
end
