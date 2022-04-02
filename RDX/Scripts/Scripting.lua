-- Scripting.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- The Script object type, and various automated handling for the Scripts 
-- package.

-- Edit dialog for scripts
local function EditScriptDialog(parent, path, md)
	-- Sanity checks
	if (not path) or (not md) or (not md.data) then return nil; end
	local ctype, font = nil, nil;

	local dlg = VFLUI.Window:new(parent);
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetTitleColor(0,0,.6);
	dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(500); dlg:SetHeight(500);
	dlg:SetText(i18n("Text Editor: ") .. path);
	dlg:Show();
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());

	local editor = VFLUI.TextEditor:new(dlg, ctype, font);
	editor:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	editor:SetWidth(490); editor:SetHeight(430); editor:Show();
	editor:SetText(md.data.script or "");
	editor:GetEditWidget():SetFocus();

	local esch = function() dlg:Destroy(); end
	VFL.AddEscapeHandler(esch);

	local btnClose = VFLUI.CloseButton:new(dlg);
	dlg:AddButton(btnClose);
	btnClose:SetScript("OnClick", function() VFL.EscapeTo(esch); end);

	local btnOK = VFLUI.OKButton:new(dlg);
	btnOK:SetText(i18n("OK")); btnOK:SetHeight(25); btnOK:SetWidth(75);
	btnOK:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
	btnOK:Show();
	btnOK:SetScript("OnClick", function()
		md.data.script = editor:GetText() or "";
		VFL.EscapeTo(esch);
	end);

	dlg.Destroy = VFL.hook(function(s)
		btnOK:Destroy(); btnOK = nil;
		editor:Destroy(); editor = nil;
	end, dlg.Destroy);
end

-- Script RDX object registration
RDXDB.RegisterObjectType({
	name = "Script";
	New = function(path, md)
		md.version = 1;
	end;
	Open = function(path, md, arg)
		if not md.data.script then return nil; end
		if type(arg) ~= "string" then arg = ""; end
		local f,err = loadstring(arg .. "\n" .. md.data.script);
		if f then f(); else
			VFL.TripError("RDX", i18n("Script error at <") .. path .. ">", err); return;
		end
	end;
	Edit = function(path, md, parent)
		EditScriptDialog(parent or UIParent, path, md);
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Run"),
			OnClick = function() 
				VFL.poptree:Release();
				RDXDB.OpenObject(path);
			end
		});
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function() 
				VFL.poptree:Release(); 
				EditScriptDialog(dlg, path, md); 
			end
		});
	end;
});

-- Macro RDX object registration
RDXDB.RegisterObjectType({
	name = "Macro";
	New = function(path, md)
		md.version = 1;
	end;
	Edit = function(path, md, parent)
		EditScriptDialog(parent or UIParent, path, md);
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function() 
				VFL.poptree:Release(); 
				EditScriptDialog(dlg, path, md); 
			end
		});
	end;
});

-- Dangerous object filter registration: scripts should always be viewed as dangerous.
RDX.RegisterDangerousObjectFilter({
	matchType = "Script";
	Filter = VFL.True;
});
RDX.RegisterDangerousObjectFilter({
	matchType = "Macro";
	Filter = VFL.True;
});

--------------------------------------
-- SCRIPT EVENT HANDLING
--------------------------------------

-- Create our scripts package at DB load if it doesn't exist
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	RDXDB.GetOrCreatePackage("Scripts");
end);

-- When we login (post DB load) run our auto_USER script.
-- Also run all autoexec scripts in sub-packages.
RDXEvents:Bind("INIT_POST_DATABASE_LOADED", nil, function()
	RDXDB.OpenObject("Scripts:auto_u_" .. RDX.pspace);
	local aex = nil;
	for pkg,dir in pairs(RDXDB.GetPackages()) do
		aex = dir["autoexec"];
		if aex and aex.ty == "Script" and RDXDB.GetPackageMetadata(pkg, "infoRunAutoexec") then
			RDXDB.OpenObject(pkg .. ":autoexec", "Open", "local pkg = '" .. pkg .. "';");
		end
	end
end);

-- When we switch encounters, first run our auto_ENCOUNTER script, then our auto_ENCOUNTER_USER
-- script.
RDXEvents:Bind("ENCOUNTER_CHANGED", nil, function(enc)
	if not (RDXDB.OpenObject("Scripts:auto_e_" .. enc) or RDXDB.OpenObject("Scripts:auto_e_" .. enc .. "_u_" .. RDX.pspace)) then
		RDXDB.OpenObject("Scripts:auto_e_default");
		RDXDB.OpenObject("Scripts:auto_e_default_u_" .. RDX.pspace);
	end
end);

------------------------------------
-- SCRIPTING MENU
------------------------------------
local function CreateScriptAt(path)
	local pkg, file = RDXDB.ParsePath(path);
	RDXDB.CreateObject(pkg, file, "Script");
	RDXDB.OpenObject(path, "Edit");
end

local function DeleteObjectAt(opath)
	VFLUI.MessageBox(i18n("Delete: ") .. opath, i18n("Are you sure you want to delete the object at ") .. opath .. i18n("?"), nil, i18n("Cancel"), VFL.Noop, i18n("OK"), function() RDXDB.DeleteObject(opath); end);
end

local function ScriptMenuEntry(mnu, menuObj, spath, sname)
	if RDXDB.CheckObject(spath, "Script") then
		table.insert(mnu, {text = i18n("Edit ") .. sname, OnClick = function()
			menuObj:Release();
			RDXDB.OpenObject(spath, "Edit");
		end});
		table.insert(mnu, {text = i18n("Clear ") .. sname, OnClick = function()
			menuObj:Release();
			DeleteObjectAt(spath);
		end});
	else
		table.insert(mnu, {text = i18n("Create ") .. sname, OnClick = function()
			menuObj:Release();
			CreateScriptAt(spath);
		end});
	end
end

local function AssociateDesktop()
	local dtp = RDXDK.GetCurrentDesktopPath();
	if not dtp then
		RDX.print(i18n("***WARNING***: Could not determine current desktop. Taking no action.")); return;
	end
	local spath = "Scripts:auto_e_" .. RDX.GetActiveEncounter() .. "_u_" .. RDX.pspace;
	if not RDXDB.CheckObject(spath, "Script") then
		local p,f = RDXDB.ParsePath(spath);
		RDXDB.CreateObject(p, f, "Script");
	end
	local md = RDXDB.GetObjectData(spath);
	md.data.script = [[RDXDK.SecuredChangeDesktop("]] .. dtp .. [[");]];
end

local function ScriptMenu(menu, cell)
	local mnu = {};
	ScriptMenuEntry(mnu, menu, "Scripts:auto_u_" .. RDX.pspace, i18n("user script"));
	ScriptMenuEntry(mnu, menu, "Scripts:auto_e_" .. RDX.GetActiveEncounter(), i18n("encounter script"));
	ScriptMenuEntry(mnu, menu, "Scripts:auto_e_" .. RDX.GetActiveEncounter() .. "_u_" .. RDX.pspace, i18n("user-encounter script"));
	table.insert(mnu, { text = i18n("Associate Desktop to Encounter"), OnClick = function()
		menu:Release();
		AssociateDesktop();
	end});
	menu:Expand(cell, mnu);
end

RDXEvents:Bind("INIT_PRELOAD", nil, function()
	RDX.RegisterMainMenuEntry(i18n("Scripts"), true, ScriptMenu);
end);
