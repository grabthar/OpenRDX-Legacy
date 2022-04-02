-- Desktop_WindowsLess.lua
-- OpenRDX
-- Use to register frame to be manage by RDX

-------------------------------------------------------------------
-- WINDOWLESS, register any external frame to be manage by RDXDK
-------------------------------------------------------------------
local classes = {};

function RDXDK.RegisterWindowLess(tbl)
	if (not tbl) or (not tbl.name) then RDX.printW(i18n("attempt to register anonymous WindowLess")); return; end
	local n = tbl.name;
	if classes[n] then RDX.printW(i18n("Duplicate registration WindowLess ") .. tbl.name); return; end
	classes[n] = tbl;
end

function RDXDK.GetWindowLess(cn)
	if not cn then return nil; end
	return classes[cn];
end

function RDXDK._GetWindowsLess()
	return classes;
end

RDX.RegisterFeature({
	name = "desktop_windowless",
	title = i18n("Registered Window");
	category = i18n("Windows");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("Desktop") then return nil; end
		if not state:Slot("Desktop main") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if not __DesktopCheck_Name(desc, state, errs) then return nil; end
		return true;
	end,
	ApplyFeature = function(desc, state)
		state.Code:AppendCode([[
		
local name = "]] .. desc.name .. [[";
local frameprops = ]] .. Serialize(desc) .. [[;

DesktopEvents:Bind("DESKTOP_ACTIVATE", nil, function(framepropsList)
	framepropsList[name] = frameprops;
end, encid);
		
DesktopEvents:Bind("DESKTOP_OPEN", nil, function(frameList, framepropsList, id)
	local framep = framepropsList[name];
	local wless = RDXDK.GetWindowLess(name);
	if wless and not frameList[name] then
		frameList[name] = CreateElement(framep, name, wless.Open, id);
	end
end, encid);

DesktopEvents:Bind("DESKTOP_CLOSE", nil, function(frameList, framepropsList, id)
	local frame, framep = frameList[name], framepropsList[name];
	local wless = RDXDK.GetWindowLess(name);
	if DeleteElement(frame, framep, name, wless.Close, id) then
		frameList[name] = nil;
	end
end, encid);

DesktopEvents:Bind("DESKTOP_LOCK", nil, function(frameList, framepropsList)
	if frameList[name] then
		RDXDK.UnimbueOverlay(frameList[name]);
		RDXDK.SavePosition(frameList[name], framepropsList[name]);
	end
end, encid);

DesktopEvents:Bind("DESKTOP_UNLOCK", nil, function(frameList, framepropsList)
	if frameList[name] then
		RDXDK.ImbueOverlay(frameList[name]);
	end
end, encid);
		]]);
		
		return true;
	end,
	UIFromDescriptor = RDXUI.defaultUIFromDescriptor;
	CreateDescriptor = function()
		return {
			feature = "desktop_windowless";
			open = true;
			scale = 1;
			alpha = 1;
			strata = "MEDIUM";
			anchor = "TOPLEFT";
		}; 
	end;
});

-- direct function access

function RDXDK._AddRegisteredWindowRDX(path)
	local ret = {
		feature = "desktop_windowless";
		name = path;
		open = true;
		scale = 1;
		alpha = 1;
		strata = "MEDIUM";
		anchor = "TOPLEFT";
	};
	-- this function add a new feature to the object and signal a update
	RDX.AddFeatureData(RDXDK.GetCurrentDesktopPath(), "desktop_windowless", "name", path, ret)
end

function RDXDK._RemoveRegisteredWindow(path)
	-- todo
end