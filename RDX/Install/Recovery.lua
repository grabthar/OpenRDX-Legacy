-- RDX6_Recovery.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- The Restore module is designed to provide facilities for backing up, restoring,
-- and troubleshooting the RDX saved data structures.

-- Show a window for selecting packages.

local dlg = nil;
local function ShowPackageListWindow(title, text, src, callback)
	if dlg then return; end
	if not callback then callback = VFL.Noop; end

	-- From the source array, build a local array of packages
	local pkgs = {};
	if src then
		for k,_ in pairs(src) do
			if k ~= "Builtin" then
				table.insert(pkgs, {pkg = k});
			end
		end
	end
	table.sort(pkgs, function(p1,p2) return p1.pkg < p2.pkg; end);
	
	dlg = VFLUI.Window:new(UIParent);
	dlg:SetFrameStrata("FULLSCREEN");
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetBackdrop(VFLUI.DefaultDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(250); dlg:SetHeight(250);
	dlg:SetTitleColor(0,.6,0);
	dlg:SetText(title);
	
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	if RDXPM.Ismanaged("recovery_manager") then RDXPM.RestoreLayout(dlg, "recovery_manager"); end

	local txt = VFLUI.CreateFontString(dlg);
	txt:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	txt:SetWidth(240); txt:SetHeight(30);
	txt:SetJustifyH("LEFT"); txt:SetJustifyV("TOP");
	txt:SetFontObject(Fonts.Default10);
	txt:Show(); txt:SetText(text);

	local pkgList = VFLUI.List:new(dlg, 12, function(parent)
		local c = VFLUI.Checkbox:new(parent);
		c.OnDeparent = c.Destroy;
		return c;
	end);
	pkgList:SetPoint("TOPLEFT", txt, "BOTTOMLEFT");
	pkgList:SetWidth(240); pkgList:SetHeight(156);
	pkgList:Rebuild(); pkgList:Show();
	pkgList:SetDataSource(function(cell, data, pos)
		cell:SetText(data.pkg);
		cell:SetChecked(data.sel);
		cell.check:SetScript("OnClick", function() data.sel = this:GetChecked(); end);
	end, VFL.ArrayLiterator(pkgs));
	pkgList:Update();
	
	dlg:Show(.2, true);
	
	local esch = function()
		dlg:Hide(.2, true);
		VFL.ZMSchedule(.25, function()
			RDXPM.StoreLayout(dlg, "recovery_manager");
			dlg:Destroy(); dlg = nil;
		end);
	end
	VFL.AddEscapeHandler(esch);

	-- OK/Cancel etc
	local btnCancel = VFLUI.CancelButton:new(dlg);
	btnCancel:SetHeight(25); btnCancel:SetWidth(60);
	btnCancel:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
	btnCancel:SetText("Cancel"); btnCancel:Show();
	btnCancel:SetScript("OnClick", function()
		VFL.EscapeTo(esch);
		callback(nil);
	end);

	local btnOK = VFLUI.OKButton:new(dlg);
	btnOK:SetHeight(25); btnOK:SetWidth(60);
	btnOK:SetPoint("RIGHT", btnCancel, "LEFT");
	btnOK:SetText("OK"); btnOK:Show();
	btnOK:SetScript("OnClick", function()
		local psel = {};
		for k,v in pairs(pkgs) do
			if v.sel then psel[v.pkg] = true; end
		end
		VFL.EscapeTo(esch);
		callback(psel);
	end);

	local btnNone = VFLUI.Button:new(dlg);
	btnNone:SetHeight(25); btnNone:SetWidth(60);
	btnNone:SetPoint("RIGHT", btnOK, "LEFT");
	btnNone:SetText("None"); btnNone:Show();
	btnNone:SetScript("OnClick", function()
		for _,v in pairs(pkgs) do v.sel = nil; end
		pkgList:Update();
	end);

	local btnAll = VFLUI.Button:new(dlg);
	btnAll:SetHeight(25); btnAll:SetWidth(60);
	btnAll:SetPoint("RIGHT", btnNone, "LEFT");
	btnAll:SetText("All"); btnAll:Show();
	btnAll:SetScript("OnClick", function()
		for _,v in pairs(pkgs) do v.sel = true; end
		pkgList:Update();
	end);

	-- Destructor
	dlg.Destroy = VFL.hook(function(s)
		btnCancel:Destroy(); btnOK:Destroy(); btnNone:Destroy(); btnAll:Destroy();
		btnCancel = nil; btnOK = nil; btnNone = nil; btnAll = nil;
		VFLUI.ReleaseRegion(txt); txt = nil;
		pkgList:Destroy(); pkgList = nil;
	end, dlg.Destroy);
end

----------------------------------------------------
-- BACKUP
----------------------------------------------------
local function DoBackup(ary)
	if not ary then return; end
	RDXBackup = {};
	for pkgName,_ in pairs(ary) do
		if RDXData[pkgName] then
			RDXBackup[pkgName] = VFL.copy(RDXData[pkgName]);
		end
	end
	ReloadUI();
end

function RDX.BackupPackages()
	--VFL.poptree:Release();
	ShowPackageListWindow("Backup", "Select packages to back up.\n|cFFFF0000WARNING: Existing backups will be overwritten.\nThe UI will be reloaded.|r", RDXData, DoBackup)
end

----------------------------------------------------
-- RESTORE
----------------------------------------------------
local function DoRestore(ary)
	if not ary then return; end
	for pkgName,_ in pairs(ary) do
		if RDXBackup[pkgName] then
			RDXData[pkgName] = VFL.copy(RDXBackup[pkgName]);
		end
	end
	ReloadUI();
end

function RDX.RestorePackages()
	--VFL.poptree:Release();
	ShowPackageListWindow("Restore", "Select packages to restore.\n|cFFFF0000WARNING: Existing RDX database will be overwritten.\nThe UI will be reloaded.|r", RDXBackup, DoRestore)
end

---------------------------------------------------
-- MASTER RESET
---------------------------------------------------
local function DoMasterReset()
	RDXData = {}; RDXSession = {}; ReloadUI();
end

function RDX.MasterReset()
	VFL.poptree:Release();
	VFLUI.MessageBox("Master Reset", "Do you want to master reset? This will clear the RDX database, and restore all RDX settings to their defaults.", nil, "No", nil, "Yes", DoMasterReset);
end

local function DoReinstall()
	RDXU.installers = nil; RDXG.oobe = nil; RDXU.oobe = nil;
	ReloadUI();
end

local function Reinstall()
	VFL.poptree:Release();
	VFLUI.MessageBox(i18n("Reinstall"), i18n("Are you sure you want to re-run all installers? (The UI will be reloaded."), nil, i18n("No"), VFL.Noop, i18n("Yes"), DoReinstall);
end;

---------------------------------------------------
-- INIT
---------------------------------------------------
WoWEvents:Bind("VARIABLES_LOADED", nil, function()
	if not RDXBackup then RDXBackup = {}; end
end);

---------------------------------------------------
-- MENU
---------------------------------------------------
--if RDX and RDX.RegisterMainMenuEntry then
--	local function BackupMenu(tree, frame)
--		local mnu = {};
		--table.insert(mnu, {text = i18n("Backup..."), OnClick = Backup});
		--table.insert(mnu, {text = i18n("Restore..."), OnClick = Restore});
		--table.insert(mnu, {text = i18n("Reinstall OOBE..."), OnClick = Reinstall});
		--table.insert(mnu, {text = i18n("Reload UI..."), OnClick = ReloadUI});
		--table.insert(mnu, {text = i18n("------------"), OnClick = VFL.Zero});
		--table.insert(mnu, {text = i18n("Master Reset"), OnClick = MasterReset});
--		tree:Expand(frame, mnu);
--	end;
--	RDX.RegisterMainMenuEntry(i18n("Recovery"), true, BackupMenu);
--end

--------------------------------------------------
-- SLASH COMMANDS
--------------------------------------------------
SLASH_RDXRECOVER1 = "/rdxrecover";
SlashCmdList["RDXRECOVER"] = function(arg)
	if(arg == "backup") then
		Backup();
	elseif(arg == "restore") then
		Restore();
	elseif(arg == "reset") then
		MasterReset();
	else
		RDX.printE("Usage: /rdxrecover [backup,restore,reset]");
	end
end
