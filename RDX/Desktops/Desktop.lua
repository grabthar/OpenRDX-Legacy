-- Desktop.lua
-- OpenRDX

-- The root Desktop dispatch table
-- Events :
-- DESKTOP_OPEN
-- DESKTOP_CLOSE
-- DESKTOP_REBUILD

DesktopEvents = DispatchTable:new();

-- Main currentDesktop Object
local currentDesktop = nil;
local currentpath = nil;

----------------------------------------------------
-- HIGH API Level
----------------------------------------------------

function RDXDK.GetCurrentDesktop()
	return currentDesktop;
end

function RDXDK.SetCurrentDesktop(dk)
	currentDesktop = dk;
end

function RDXDK.GetCurrentDesktopPath()
	if currentDesktop and currentDesktop._path then
		return currentDesktop._path;
	else
		return currentpath;
	end
end

function RDXDK.GetFrame(name)
	return currentDesktop:GetFrame(name);
end

function RDXDK.GetFrameList()
	return currentDesktop:GetFrameList();
end

function RDXDK.GetFrameProps(name)
	return currentDesktop:GetFrameProps(name);
end

function RDXDK.GetFramePropsList()
	return currentDesktop:GetFramePropsList();
end

function RDXDK.RebuildWindow(path)
	currentDesktop:RebuildWindow(path);
end

function RDXDK.RebuildAll()
	VFL.print("REBUILD ALL");
	currentDesktop:RebuildAll();
end

function RDXDK.ModifyDesktop()
	local md = RDXDB.GetObjectData(currentpath);
	RDXDK.EditDesktop(UIParent, currentpath, md);
end

function RDXDK._SaveFrameProps(posflag, frameProps)
	currentDesktop:_SaveFrameProps(posflag, frameProps);
end

function RDXDK._SaveFramePropsList(posflag)
	currentDesktop:_SaveFramePropsList(posflag);
end

function RDXDK.DUMP()
	currentDesktop:dump();
end

-- /script RDXDK.DUMP();

----------------------------------------
-- direct access
----------------------------------------

--function RDXDK._WriteFrameProps(frameProps)
--	currentDesktop:_WriteFrameProps(frameProps);
--end

-- direct open win the window list of from the main explorer DB

function RDXDK._OpenWindowRDX(path)
	local frameprops = RDXDK.GetFrameProps(path);
	-- try to see if the feature is already present
	if frameprops then
		local currentDesktop = RDXDK.GetCurrentDesktop();
		currentDesktop:OpenDesktop(path);
		if not RDXDK.IsDesktopLocked() then RDXDK.UnlockDesktop(); end
	else
		local _, _, _, ty = RDXDB.GetObjectData(path);
		-- add a new feature window to this desktop
		if ty == "Window" then
			RDXDK._AddWindowRDX(path);
		elseif ty == "StatusWindow" then
			RDXDK._AddStatusWindowRDX(path)
		else
			RDXDK._AddRegisteredWindowRDX(path);
		end
	end
end

function RDXDK._CloseWindowRDX(path)
	local frameprops = RDXDK.GetFrameProps(path);
	if frameprops then
		local currentDesktop = RDXDK.GetCurrentDesktop();
		currentDesktop:CloseDesktop(path);
	end
end

--local function _RebuildWindowRDX(path)
	--VFL.print(path);
	--local inst = RDXDB.GetObjectInstance(path, true);
	--if inst then
		--RDXDK._CloseWindowRDX(path);
		--RDXDK._OpenWindowRDX(path);
		--RDXDB.OpenObject(path, "Rebuild", inst);
		--RDXDK.RebuildDesktop(path);
	--end
--end

function RDXDK._AsyncRebuildWindowRDX(path)
	VFL.ZMSchedule(0.01, function()
		RDXDK.RebuildWindow(path);
	end);
end

-----------------------------------------------------------------
-- LOCKDOWN ACTION QUEUE
-- Execute a series of actions after combat lockdown ends.
-----------------------------------------------------------------

local caq = {};
function RDXDK.QueueLockdownAction(object, method, text)
	if not InCombatLockdown() then 
		method(object);
	else
		--if text then VFL.print(text); end
		if not caq[object] then caq[object] = method; end
	end
end

VFLEvents:Bind("PLAYER_COMBAT", nil, function(flag)
	if not flag then
		for k,v in pairs(caq) do
			v(k); caq[k] = nil;
		end
	end
end);

-----------------------------------------------------
-- functions
-----------------------------------------------------

local function ChangeDesktop(path, nosave)
	if RDX.IsDesktopEditorOpen() then RDX.CloseFeatureEditor(); end
	RDXDK:Debug(2, "change desktop " .. path);
	-- close
	if currentDesktop then
		RDXDB._RemoveInstance(currentDesktop._path, nosave);
	end
	
	RDXPM.GetMainPane():SetDesktopName("|cFFFF0000" .. path .. "|r", path);
	currentpath = path;
	-- open
	currentDesktop = RDXDB.GetObjectInstance(path);
	
	if not RDXDK.IsDesktopLocked() then
		RDXDK.UnlockDesktop();
	end
	
	if currentDesktop then
		RDXPM.GetMainPane():SetDesktopName("|cFF00FF00" .. path .. "|r", path);
	end
end
RDXDK._ChangeDesktop = ChangeDesktop;

-----------------------------------------
-- desktop change are lock under combat
-- change after combat
-----------------------------------------

local newpath;
function RDXDK.SecuredChangeDesktop(path, nosave)
	if not InCombatLockdown() then 
		ChangeDesktop(path, nosave); 
	else
		newpath = path;
	end
end

VFLEvents:Bind("PLAYER_COMBAT", nil, function(flag)
	if not flag and newpath then
		ChangeDesktop(newpath);
		newpath = nil;
	end
end);

----------------------------------------
-- command
----------------------------------------
RDX.RegisterSlashCommand("desktop", function(rest)
	local path = VFL.word(rest);
	if path then
		RDXDK.SecuredChangeDesktop(path);
	end
end);

----------------------------
-- INIT
----------------------------

RDXEvents:Bind("INIT_DESKTOP", nil, function()
	if not RDXU.Desktops then RDXU.Desktops = {}; end
	if not RDXU.Desktops2 then RDXU.Desktops2 = {}; end
	-- create solo, group, raid, inn and pvp desktop
	RDXDK.MakeDesktops();
	
	if RDXDK.IsAutoSwitchEnable() then 
		RDXDK.SwitchDesktop_Enable();
	else
		RDXDK.SwitchDesktop_Disable();
	end
	
end);
