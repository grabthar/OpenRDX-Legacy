-- Desktop_StatusWindows.lua
-- OpenRDX

----------------------------------
-- win
----------------------------------

RDX.RegisterFeature({
	name = "desktop_statuswindow",
	title = i18n("OpenRDX Status Window");
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
	frameList[name] = CreateElement(framep, name, function(x) return RDXDB.GetObjectInstance(x); end, id);
end, encid);

DesktopEvents:Bind("DESKTOP_CLOSE", nil, function(frameList, framepropsList, id)
	local frame, framep = frameList[name], framepropsList[name];
	if DeleteElement(frame, framep, name, function(x, y) RDXDB._RemoveInstance(name); end, id) then
		frameList[name] = nil;
	end
end, encid);

DesktopEvents:Bind("DESKTOP_REBUILD", nil, function(frameList, framepropsList, id)
	if id and (name == id) and frameList[name] then
		local md = RDXDB.GetObjectData(name);
		if md and md.data then
			RDX.SetupStatusWindow(name, frameList[name], md.data);
		end
	end
end, encid);

DesktopEvents:Bind("DESKTOP_LOCK", nil, function(frameList, framepropsList)
	if frameList[name] then
		frameList[name]:Lock();
		RDXDK.SavePosition(frameList[name], framepropsList[name]);
	end
end, encid);

DesktopEvents:Bind("DESKTOP_UNLOCK", nil, function(frameList, framepropsList)
	if frameList[name] then
		frameList[name]:Unlock();
	end
end, encid);

		]]);
		return true;
	end,
	UIFromDescriptor = RDXUI.defaultUIFromDescriptor;
	CreateDescriptor = function()
		return {
			feature = "desktop_statuswindow";
			open = true;
			scale = 1;
			alpha = 1;
			strata = "MEDIUM";
			anchor = "TOPLEFT";
		}; 
	end;
});

-- direct function access

function RDXDK._AddStatusWindowRDX(path)
	local ret = {
		feature = "desktop_statuswindow";
		name = path;
		open = true;
		scale = 1;
		alpha = 1;
		strata = "MEDIUM";
		anchor = "TOPLEFT";
	};
	-- this function add a new feature to the object and signal a update
	RDX.AddFeatureData(RDXDK.GetCurrentDesktopPath(), "desktop_statuswindow", "name", path, ret)
end

function RDXDK._RemoveStatusWindowRDX(path)
	-- todo
end
