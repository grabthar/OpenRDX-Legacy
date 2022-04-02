-- Obj_Desktop.lua
-- OpenRDX

RDXDK = RegisterVFLModule({
	name = "RDXDK";
	title = i18n("RDX Desktop Object");
	description = "RDX Desktop GUI Editor";
	version = {1,0,0};
	parent = RDX;
});
--RDXDK:ModuleSetDebugLevel(10);

----------------------------------------------------
-- Helper functions
----------------------------------------------------

--- Print an error message from inside compiled paint code.
local _err_norepeat = {};
setmetatable(_err_norepeat, {__mode = 'k'});
function RDXDK.PrintError(win, info, err)
	if (type(win) == "table") and (not _err_norepeat[win]) then
		_err_norepeat[win] = true;
		local ident, path = "<unknown>", "<unknown>";
		if (type(win._dk_name) == "string") then
			ident = win._dk_name;
		end
		if (type(win._path) == "string") then
			path = win._path;
		end
		VFL.TripError("RDX", i18n("Window <") .. ident .. i18n("> caused a paint error.", "Pointer: ") .. tostring(win) .. i18n("\nIdentity: ") .. ident ..i18n("\nPath: ") .. path .. i18n("\nError\n--------\n") .. err);
	end
end

--------------------------------------------
-- Desktop object
--------------------------------------------
RDXDK.Desktop = {};
function RDXDK.Desktop:new(parent)
	local self = VFLUI.AcquireFrame("Frame");
	if not parent then parent = UIParent; end
	self:SetParent(parent);
	
	local frameList, framePropsList = {}, {};
	
	function self:GetFrame(name)
		return frameList[name];
	end
	
	function self:GetFrameList()
		return frameList;
	end
	
	function self:GetFrameProps(name)
		return framePropsList[name];
	end
	
	function self:GetFramePropsList()
		return framePropsList;
	end
	
	local function WriteFrameProps(frameProps)
		RDX.SetFeatureData(self._path, frameProps.feature, "name", frameProps.name, frameProps);
	end
	
	local function WriteFramePropsList()
		for k,v in pairs(framePropsList) do
			RDX.SetFeatureData(self._path, v.feature, "name", v.name, v);
		end
	end
	
	function self:_SaveFrameProps(posflag, frameProps)
		if posflag then 
			local frame = frameList[frameProps.name];
			if frame then
				local rgn = frame:WMGetPositionalFrame();
				--if (not rgn) or (not rgn:GetLeft()) then return; end -- BUGFIX: sometimes there are no bdry coordinates?
				local l,t,r,b = GetUniversalBoundary(rgn);
				frameProps.l = l; frameProps.t = t; frameProps.r = r; frameProps.b = b;
			end
		end
		framePropsList[frameProps.name] = VFL.copy(frameProps);
		RDX.SetFeatureData(self._path, frameProps.feature, "name", frameProps.name, frameProps);
	end
	
	function self:_SaveFramePropsList(posflag)
		if posflag then 
			local rgn, l, t, r, b;
			for k,v in pairs(frameList) do
				rgn = v:WMGetPositionalFrame();
				--if (not rgn) or (not rgn:GetLeft()) then return; end -- BUGFIX: sometimes there are no bdry coordinates?
				l,t,r,b = GetUniversalBoundary(rgn);
				framePropsList[k].l = l; framePropsList[k].t = t; framePropsList[k].r = r; framePropsList[k].b = b;
			end
		end
		for _, frameProps in pairs(framePropsList) do
			RDX.SetFeatureData(self._path, frameProps.feature, "name", frameProps.name, frameProps);
		end
	end
	
	function self:RebuildWindow(id)
		if frameList[id] then
			DesktopEvents:Dispatch("DESKTOP_REBUILD", frameList, framePropsList, id);
			RDXDK.ResetDockGroupLayout(frameList[id]);
			RDXDK.LayoutDockGroup(frameList[id]);
		end
	end
	
	--function self:RebuildAll()
	--	DesktopEvents:Dispatch("DESKTOP_REBUILD", frameList, framePropsList);
		--RDXDK.ResetDockGroupLayout(frameList[id]);
		--RDXDK.LayoutDockGroup(frameList[id]);
		--RDXDK.LayoutAll();
	--end
	
	function self:ActivateDesktop()
		DesktopEvents:Dispatch("DESKTOP_ACTIVATE", framePropsList);
	end
	
	function self:OpenDesktop(id)
		DesktopEvents:Dispatch("DESKTOP_OPEN", frameList, framePropsList, id);
		RDXDK.LayoutAll();
	end
	
	function self:PostOpenDesktop()
		DesktopEvents:Dispatch("DESKTOP_POST_OPEN");
	end
	
	function self:CloseDesktop(id)
		DesktopEvents:Dispatch("DESKTOP_CLOSE", frameList, framePropsList, id);
	end
	
	function self:PreCloseDesktop(nosave)
		DesktopEvents:Dispatch("DESKTOP_PRE_CLOSE", nosave);
	end
	
	function self:DeactivateDesktop()
		DesktopEvents:Dispatch("DESKTOP_DEACTIVATE");
	end
	
	function self:LockDesktop()
		DesktopEvents:Dispatch("DESKTOP_LOCK", frameList, framePropsList);
	end
	
	function self:UnlockDesktop()
		DesktopEvents:Dispatch("DESKTOP_UNLOCK", frameList, framePropsList);
	end
	
	function self:dump()
		for k,v in pairs(framePropsList) do
			VFL.print(k);
			VFL.print(v.l);
		end
	end
	
	self.Destroy = VFL.hook(function(s)
		VFL.empty(frameList); framelist = nil;
		VFL.empty(framePropsList); framePropsList = nil;
		s.GetFrame = nil; s.GetFrameList = nil; 
		s.GetFrameProps = nil; s.GetFramePropsList = nil;
		s._WriteFrameProps = nil; WriteFramePropsList = nil;
		s.RebuildDesktop = nil; 
		s.OpenDesktop = nil; s.CloseDesktop = nil;
		s.LockDesktop = nil; s.UnlockDesktop = nil;
	end, self.Destroy);
	
	return self;
end

-----------------------------------
-- The desktop state
-----------------------------------
RDXDK.DesktopState = {};
function RDXDK.DesktopState:new()
	local st = RDX.ObjectState:new();
	
	st.OnResetSlots = function(state)
		state:AddSlot("Desktop", nil);
	end;
	
	st.Code = VFL.Snippet:new();
	
	st:Clear();
	return st;
end

-- A general state object to be reused by this engine
local dkState = RDXDK.DesktopState:new();
RDXDK._GetdkState = function() return dkState; end;

----------------------------------------------------------------------
-- Desktop meta-control 
----------------------------------------------------------------------
local function SetupDesktop(path, dk, desc)
	if (not path) or (not dk) or (not desc) then return nil; end
	
	-- init
	dkState:Clear();
	dkState:ResetSlots();
	
	-- Load the features
	dkState:LoadDescriptor(desc);
	local _errs = VFL.Error:new();
	if not dkState:ApplyAll(_errs, path) then
		_errs:ToErrorHandler("RDX", i18n("Could not build desktop at <") .. tostring(path) .. ">");
		return nil;
	end
	_errs = nil;
	
	local code = dkState.Code:GetCode();
	if RDXG.cdebug and RDXM_Debug.StoreCompiledObject then
		RDXM_Debug.StoreCompiledObject(path, code);
	end

	local f,err = loadstring(code);
	if not f then
		VFL.TripError("RDX", i18n("Could not compile desktop at <") .. tostring(path) .. ">", i18n("Error: ") .. err);
		return nil;
	else
		f();
		dk._f = f;
	end
	return true;
end

-------------------------------------------
-- DESKTOP EDITOR
-- just a modified feature editor for unitframe
-------------------------------------------
RDX.IsDesktopEditorOpen = RDX.IsFeatureEditorOpen;

function RDX.DesktopEditor(state, callback, augText)
	local dlg = RDX.FeatureEditor(state, callback, augText);
	if not dlg then return nil; end
	
	--RDXDB.TogglePreviewWindow();
	--RDXDB.PaintPreviewWindow(state);
	
	------ Close procedure
	dlg.Destroy = VFL.hook(function(s)
		--RDXDB.ClosePreviewWindow();
	end, dlg.Destroy);
end

local function EditDesktop(parent, path, md)
	if RDX.IsDesktopEditorOpen() then return; end
	dkState:LoadDescriptor(md.data);
	RDX.DesktopEditor(dkState, function(x) 
		md.data = x:GetDescriptor();
		RDXDB.NotifyUpdate(path);
	end, path);
end
RDXDK.EditDesktop = EditDesktop;

-- The Desktop object type.
RDXDB.RegisterObjectType({
	name = "Desktop";
	version = 2;
	isFeatureDriven = true;
	VersionMismatch = function(md)
		-- code update version 1 to version 2;
		md.version = 2;
		-- save md.data
		local tmpdata = nil;
		if md.data then
			tmpdata = VFL.copy(md.data);
			-- empty md.data
			VFL.empty(md.data);
		else
			md.data = {};
		end
		-- Add the first feature
		table.insert(md.data, { feature = "Desktop main"; title = "updated"; resolution = VFLUI.GetCurrentResolution(); uiscale = VFLUI.GetCurrentEffectiveScale();});
		-- convert all old data to features.
		for k,v in pairs(tmpdata) do
			-- remove dock (bugs from old desktop object)
			v.dgp = nil;
			if v.dock then VFL.empty(v.dock); v.dock = nil; end
			if k == "_root" then
				v.feature = "desktop_windowless";
				v.name = "desktop_bossmod";
				table.insert(md.data, v);
			elseif k == "_multi_track_window" then
				v.feature = "desktop_windowless";
				v.name = "desktop_multi_track";
				table.insert(md.data, v);
			elseif k == "_omni_live" then
				v.feature = "desktop_windowless";
				v.name = "desktop_omnilive";
				table.insert(md.data, v);
			elseif k == "_thw" then
				v.feature = "desktop_windowless";
				v.name = "desktop_healtarget";
				table.insert(md.data, v);
			elseif k == "_streams" then
				-- do nothing
				-- the RPC window is now manage by RDXPM
			elseif v.class == "gwin" then
				v.feature = "desktop_window";
				v.name = k;
				table.insert(md.data, v);
			elseif v.class == "statwin" then
				v.feature = "desktop_statuswindow";
				v.name = k;
				table.insert(md.data, v);
			else
				if k then RDX.printE("Error Unknown window " .. k .. " Send this message to OpenRDX Team"); end
			end
		end
		-- clear
		VFL.empty(tmpdata);
		tmpdata = nil;
		return true;
	end,
	New = function(path, md)
		md.version = 2;
	end,
	Edit = function(path, md, parent)
		EditDesktop(parent or UIParent, path, md);
	end;
	Instantiate = function(path, obj)
		if RDXDK.GetCurrentDesktop() then RDX.print("a desktop is already instantiated"); return nil; end
		local dk = RDXDK.Desktop:new(parent);
		-- Set the path
		dk._path = path;
		-- Attempt to setup the desktop; if it fails, just bail out.
		if not SetupDesktop(path, dk, obj.data) then dk:Destroy(); return nil; end
		-- Register the desktop
		RDXDK.SetCurrentDesktop(dk);
		-- Activate desktop
		dk:ActivateDesktop();
		-- Open the desktop
		dk:OpenDesktop();
		dk:PostOpenDesktop()
		return dk;
	end,
	Deinstantiate = function(instance, path, obj, nosave)
		-- Call Desktop lock and close
		--instance:LockDesktop();
		instance:PreCloseDesktop(nosave);
		instance:CloseDesktop(nil);
		instance:DeactivateDesktop();
		-- unregister desktop
		RDXDK.SetCurrentDesktop(nil);
		instance:Destroy();
		instance._path = nil; -- Remove the path previously stored
		instance._f = nil; -- Remove the function
	end,
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function()
				VFL.poptree:Release();
				EditDesktop(dlg, path, md);
			end
		});
		if RDXDK.GetCurrentDesktopPath() ~= path then 
			table.insert(mnu, {
				text = i18n("Activate"),
				OnClick = function()
					VFL.poptree:Release();
					RDXDK.SecuredChangeDesktop(path);
				end
			});
		else
			table.insert(mnu, {
				text = i18n("Rebuild Desktop"),
				OnClick = function()
					VFL.poptree:Release();
					RDXDK.SecuredChangeDesktop(path);
				end
			});
		end
		if not RDXDK.IsQuickDesktop(path) then
			table.insert(mnu, {
				text = i18n("Add to Quick Desktops");
				OnClick = function()
					VFL.poptree:Release();
					RDXDK.AddQuickDesktop(path);
				end;
			});
		end
	end,
});

-----------------------------------------------------------------
-- Update hooks - make sure when a desktop changes we reload it.
-----------------------------------------------------------------

RDXDBEvents:Bind("OBJECT_DELETED", nil, function(pkg, file, md)
	local path = RDXDB.MakePath(pkg,file);
	if md and md.ty == "Desktop" and path == RDXDK.GetCurrentDesktopPath() then
		RDXDK.SecuredChangeDesktop("desktops:default");
	end
end);

RDXDBEvents:Bind("OBJECT_UPDATED", nil, function(pkg, file) 
	local path = RDXDB.MakePath(pkg,file);
	local _,_,_,ty = RDXDB.GetObjectData(path)
	if ty == "Desktop" and path == RDXDK.GetCurrentDesktopPath() then RDXDK.SecuredChangeDesktop(path); end
end);



