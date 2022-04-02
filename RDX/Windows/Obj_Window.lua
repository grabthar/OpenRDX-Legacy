-- Obj_Window.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- This file contains copyrighted and licensed content. Unlicensed copying is prohibited.
-- See the accompanying LICENSE file for license terms.
--
-- Backend, registration and user interface for the Window object type.

--------------------------------------------------
-- The generic RDX Window object.
-- Provides slots for Create, Destroy, Show, and Hide events.
-- Based on the VFL Window object, which allows custom
-- framing.
--------------------------------------------------
RDX.Window = {};
function RDX.Window:new(parent)
	local self = VFLUI.InvertedControlWindow:new(parent);

	local hide, show, destroy, update = VFL.Noop, VFL.Noop, VFL.Noop, VFL.Noop;
	
	-- Properly invoke destructors.
	local function ProperDestroy()
		self._WindowMenu = nil;
		self:SetScript("OnUpdate", nil);
		if self:IsShown() and hide then hide(self); end
		if destroy then destroy(self); end
		if self.Multiplexer then self.Multiplexer:Close(self); self.Multiplexer = nil; end
		self.RepaintLayout = nil; self.RepaintSort = nil; self.RepaintData = nil; self.RepaintAll = nil;
		hide = nil; show = nil; destroy = nil; update = nil;
	end
	
	function self:UnloadState()
		self:SetClient(nil);
		ProperDestroy();
		self:TearDown();
	end

	function self:LoadState(state)
		self.RepaintAll = state:GetSlotFunction("RepaintAll");
		self.RepaintLayout = state:GetSlotFunction("RepaintAll"); -- COMPAT
		self.RepaintData = state:GetSlotFunction("RepaintData");
		self.RepaintSort = state:GetSlotFunction("RepaintSort");
		-- Run assembly functions
		(state:GetSlotFunction("Assemble"))(state, self);
		(state:GetSlotFunction("Create"))(self);
		-- Get API
		hide = state:GetSlotFunction("Hide");	show = state:GetSlotFunction("Show");
		update = state:GetSlotFunction("Update");	destroy = state:GetSlotFunction("Destroy");
		-- Bind API to window.
		if self:IsShown() then show(self); end
		self:SetScript("OnHide", hide);	self:SetScript("OnShow", show);
		if update ~= VFL.Noop then self:SetScript("OnUpdate", update); end
	end
	
	function self:Unlock()
		if not self.tf then
			local tf, w, h = VFLUI.AcquireFrame("Button"), 0, 0;
			
			if self:WMGetPositionalFrame():GetHeight() < 1 then h = 20; end
			if self:WMGetPositionalFrame():GetWidth() < 1 then w = 20; end
			
			tf:SetPoint("TOPLEFT", self:WMGetPositionalFrame(), "TOPLEFT", -w, h);
			tf:SetPoint("BOTTOMRIGHT", self:WMGetPositionalFrame(), "BOTTOMRIGHT", w, -h);
			tf:SetFrameStrata("HIGH");
			tf:SetFrameLevel(self:GetFrameLevel()+5);
			--tf:GetScale(frame:GetEffectiveScale());
			tf:SetBackdrop(VFLUI.BlueDialogBackdrop);
			tf:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			tf:SetAlpha(1);
			RDXDK.StdMove(self, tf, nil)
			tf:Show();
			
			-- Now for the font
			local tfIdent = VFLUI.CreateFontString(tf);
			tfIdent:SetPoint("CENTER", tf, "CENTER");
			tfIdent:SetWidth(tf:GetWidth()+200); 
			tfIdent:SetHeight(tf:GetHeight()-5);
			tfIdent:SetJustifyV("CENTER");
			tfIdent:SetJustifyH("CENTER");
			tfIdent:SetFontObject(Fonts.Default10);
			tfIdent:SetText(self._path);
			tfIdent:SetAlpha(1);
			tfIdent:Show();
			
			tf:Show(.2, true);
			
			self.tf = tf;
			self.tfIdent = tfIdent;
		end
	end
	
	function self:Lock()
		if self.tf then
			VFLUI.ReleaseRegion(self.tfIdent);
			self.tfIdent = nil;
			self.tf:Destroy();
			self.tf = nil;
		end
	end

	self.Destroy = VFL.hook(function(s)
		s:Lock();
		ProperDestroy();
		s.UnloadState = nil; s.LoadState = nil; s.Multiplexer = nil; 
		s.Lock = nil; s.Unlock = nil;
	end, self.Destroy);

	return self;
end

-----------------------------------------------
-- The WindowState for a generic window.
-----------------------------------------------
RDX.WindowState = {};
function RDX.WindowState:new()
	local st = RDX.ObjectState:new();
	st.OnResetSlots = function(state)
		state:AddSlot("Create", true);
		state:AddSlot("Hide", true);
		state:AddSlot("Show", true);
		state:AddSlot("Destroy", true);
		state:AddSlot("Update", true);
		state:AddSlot("Window", nil);
	end;
	st:Clear();
	return st;
end

RDX.GenericWindowState = {};
function RDX.GenericWindowState:new()
	local st = RDX.ObjectState:new();
	st.OnResetSlots = function(state)
		state:AddSlot("Create", true); state:AddSlot("Hide", true);	state:AddSlot("Show", true);
		state:AddSlot("Destroy", true);	state:AddSlot("Update", true); state:AddSlot("Window", nil);
		--state:AddSlot("UnitWindow", nil);
		state:AddSlot("Menu");
		-- Each window gets a new multiplexer
		state:SetSlotValue("Multiplexer", RDX.Multiplexer:new());
		-- On assembly, open the multiplexer.
		state:Attach(state:Slot("Assemble"), true, function(s,w)
			-- Apply the multiplexer to the window.
			local mux = s:GetSlotValue("Multiplexer");
			w.Multiplexer = mux;
			mux:SetPeriod(nil);
			mux:Open(w);
			-- Compat.
			w.RepaintLayout = w.RepaintAll;

			s:Attach("Create", true, function(theWindow)
				theWindow.Multiplexer:Bind(theWindow);
			end);
			s:Attach("Show", true, function(theWindow)
				-- On show, always repaint all.
				theWindow.RepaintAll();
			end);
			s:Attach("Destroy", true, function(theWindow)
				theWindow.Multiplexer:Unbind(theWindow);
			end);

			-- Attach downstream menu hooks to WMMenu.
			w._WindowMenu = s:GetSlotFunction("Menu");
		end);	
	end
	st:Clear();
	return st;
end

-- A general state object to be reused by this engine
local state = RDX.GenericWindowState:new();
RDX._exportedWindowState = RDX.GenericWindowState:new();

-- Error compilation, create a blank window
local function CreateErrWindow(state)
	state:AddFeature({feature = "Frame: Lightweight", title = i18n("Error compilation")});
	state:_SetSlotFunction("SetTitleText", VFL.Noop);
	state:AddFeature({feature = "UnitFrame", design = "Builtin:uf_hp_default"});
	state:AddFeature({feature = "layout_single_unitframe", unit = "player", clickable = true});
end

-----------------------------------------------------------
-- Window meta-control
-----------------------------------------------------------
-- Master priming function for compiling windows.
local function SetupWindow(path, win, desc)
	if (not win) or (not desc) then return nil; end
	RDX:Debug(5, "SetupWindow<", tostring(path), ">");
	
	-- lock
	win:Lock();
	-- Quash the old window
	win:UnloadState();

	-- Load the features.
	state:LoadDescriptor(desc);
	local _errs = VFL.Error:new();
	if not state:ApplyAll(_errs, path) then
		local feat = RDX.GetFeatureData(path, "UnitFrame");
		if not feat then feat = RDX.GetFeatureData(path, "ArtFrame"); end
		if not feat then feat = RDX.GetFeatureData(path, "Assist Frames"); end
		if not feat then VFL.TripError("RDX", i18n("Could not build window at <") .. tostring(path) .. ">.", i18n("The window at <") .. tostring(path) .. i18n("> is missing a Frame type feature")); return nil; end
		local upath = feat["design"];
		_errs:ToErrorHandler("RDX", i18n("Could not build window at <") .. tostring(path) .. ">");
		--return nil;
		state:ResetSlots();
		CreateErrWindow(state);
		
		local desPkg, desFile = RDXDB.ParsePath(upath);
		state:_Attach(state:Slot("Create"), true, function(w)
			-- When the window's underlying unitframe is updated, rebuild it.
			RDXDBEvents:Bind("OBJECT_UPDATED", nil, function(up, uf)
				if(up == desPkg) and (uf == desFile) then RDXDK.QueueLockdownAction(w._path, RDXDK._AsyncRebuildWindowRDX); end
			end, w._path .. upath);
		end);
		state:_Attach(state:Slot("Destroy"), true, function(w)
			-- Unbind us from the database update events
			RDXDBEvents:Unbind(w._path .. upath);
		end);
		
		-- Make a menu for editing the unitframe type.
		state:Attach("Menu", true, function(win, mnu)
			table.insert(mnu, {
				text = i18n("Edit Original UnitFrame");
				OnClick = function()
					VFL.poptree:Release();
					RDXDB.OpenObject(upath, "Edit");
				end;
			});
		end);
	end
	_errs = nil;

	-- Sanity check; make sure there are layouts and frames
	if (not state:Slot("Frame")) or (not state:Slot("Layout")) then
		VFL.TripError("RDX", i18n("Cannot open window <") .. tostring(path) .. ">.", i18n("The window at <") .. tostring(path) .. i18n("> is missing a Frame or Layout."));
		return nil;
	end

	-- If we are in combat, and the pre- or post-build window is Secure, we can't rebuild it.
	if (win.secure or state:Slot("SecureSubframes")) and InCombatLockdown() then
		VFL.TripError("RDX", i18n("Attempt to build secure window while in combat."), i18n("Could not build secure window at <") .. tostring(path) .. i18n(">. Player was in combat."));
		return nil;
	end
	if state:Slot("SecureSubframes") then win.secure = true; else win.secure = nil; end

	-- Setup the new window
	win._path = path;
	
	-- Apply the features to the window. If the window will be secure, mark it so.
	win:LoadState(state);
	-- Show the new window.
	win:Show();
	if not RDXDK.IsDesktopLocked() then
		win:Unlock();
	end
	
	-- specific window need a rebuild at launch time.
	if state:Slot("WindowOpenDelay") then
		RDXEvents:Unbind(win._path);
		RDXEvents:Bind("INIT_POST_DESKTOP", nil, function()
			RDXDK.QueueLockdownAction(win._path, RDXDK._AsyncRebuildWindowRDX);
		end, win._path);
	end
	
	-- Destroy the state to prevent memory leakage
	state:Clear();

	return true;
end
RDX.SetupWindow = SetupWindow;

-- Called after the Feature Editor is closed. Repopulates the window.
local function UpdateWindowAfterEdit(path, md, newState)
	md.data = newState:GetDescriptor();
	RDXDK.QueueLockdownAction(path, RDXDK._AsyncRebuildWindowRDX);
end

-- Open the feature editor for the window.
local function EditWindow(path, md)
	if not RDX.IsFeatureEditorOpen() then
		state:Rebuild(md.data, path);
		RDX.FeatureEditor(state, function(x) UpdateWindowAfterEdit(path, md, x); end, path);
	end
end
RDX.EditWindow = EditWindow;

-- The "gwin" generic window class.
--[[RDXDK.RegisterWindowClass({
	name = "gwin",
	Open = function(id)
		if not RDXDB.CheckObject(id, "Window") then return nil; end
		RDX:Debug(5, "Open window<", id, ">");
		return RDXDB.GetObjectInstance(id);
	end,
	Close = function(win, id)
		if win.secure and InCombatLockdown() then
			VFL.TripError("RDX", i18n("Could not close secure window at path <") .. id .. ">", i18n("Player was in combat."));
			return nil;
		end
		RDX:Debug(5, "Close window<", id, ">");
		RDXDB._RemoveInstance(id);
		return true;
	end,
	Rebuild = function(win, id)
		RDX:Debug(5, "Rebuild window<", id, ">");
		local md = RDXDB.GetObjectData(id);
		if (not md) or (not md.data) then return; end
		SetupWindow(id, win, md.data);
	end,
	Props = function(win, id, mnu)
		table.insert(mnu, {
			text = i18n("Edit Window"),
			OnClick = function()
				VFL.poptree:Release();
				local md = RDXDB.GetObjectData(id);
				if md then EditWindow(id, md); end
			end
		});
		table.insert(mnu, {
			text = i18n("Rebuild"),
			OnClick = function()
				VFL.poptree:Release();
				local cls = win:WMGetClass();
				if cls then
					cls.Rebuild(win, id);
				end
			end
		});
	end
});]]

-- The Window object type.
RDXDB.RegisterObjectType({
	name = "Window";
	isFeatureDriven = true;
	New = function(path, md)
		md.version = 1;
	end,
	Edit = function(path, md)
		EditWindow(path, md);
	end,
	Open = function(path, md)
		RDX:Debug(5, "Open WindowObject<", path, ">");
		if not RDXDB.GetObjectInstance(path, true) then
			--RDXDK._OpenWindowRDX(path);
			RDXDK.QueueLockdownAction(path, RDXDK._OpenWindowRDX, "Open Window " .. path);
		end
	end,
	Close = function(path, md)
		local inst = RDXDB.GetObjectInstance(path, true);
		if inst then 
			--RDXDK._CloseWindowRDX(path);
			RDXDK.QueueLockdownAction(path, RDXDK._CloseWindowRDX, "Close Window " .. path);
		end
	end,
	Instantiate = function(path, md)
		local w = RDX.Window:new(RDXParent); w:Show();
		-- Attempt to setup the window; if it fails, just bail out.
		if not SetupWindow(path, w, md.data) then w:Destroy(); return nil; end
		RDXDK.StdMove(w, w:GetTitleBar());
		return w;
	end,
	Deinstantiate = function(instance, path, md)
		instance:Destroy();
		instance._path = nil; -- Remove the path previously stored
	end,
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function()
				VFL.poptree:Release();
				RDXDB.OpenObject(path, "Edit", md);
			end
		});
		if not RDXDB.PathHasInstance(path) then
			table.insert(mnu, {
				text = i18n("Open"),
				OnClick = function()
					VFL.poptree:Release();
					RDXDB.OpenObject(path, "Open");
				end
			});
		else
			table.insert(mnu, {
				text = i18n("Close"),
				OnClick = function()
					VFL.poptree:Release();
					RDXDB.OpenObject(path, "Close");
				end
			});
		end
	end,
});
