-- Layouts.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- OpenRDX
-- Original code from WindowManager
-- Layout functions
-- 

----------------------------------------------------------
-- UNLAYOUT CODE
----------------------------------------------------------
local function UnlayoutFrame(frame)
	if frame._dk_drag then frame:WMStopDrag(true); end
	frame:WMGetPositionalFrame():ClearAllPoints();
	frame._dk_layout = nil;
	return true;
end
RDXDK.UnlayoutFrame = UnlayoutFrame;

local function ResetDockGroupLayout(frame)
	local frameprops = RDXDK.GetFrameProps(frame._dk_name);
	local fplist = RDXDK.GetlistDockGroup(frameprops);
	for _,fp in pairs(fplist) do
		if RDXDK.GetFrame(fp.name) then
			UnlayoutFrame(RDXDK.GetFrame(fp.name));
		end
	end
	return true;
end
RDXDK.ResetDockGroupLayout = ResetDockGroupLayout;

----------------------------------------------------------
-- LAYOUT CODE
----------------------------------------------------------

local function LayoutFrame(frame)
	RDXDK:Debug(4, "LayoutFrame(".. frame._dk_name ..")");
	-- If this window doesn't need to be laid out, don't.
	if frame._dk_nolayout or frame._dk_layout then return true; end
	
	-- Don't layout secure windows during ICLD
	if frame.secure and InCombatLockdown() then return true; end
	
	-- Get Frameprops
	local frameprops = RDXDK.GetFrameProps(frame._dk_name);
	
	-- Apply scale, alpha, stratum, level
	frame:SetScale(frameprops.scale);
	frame:SetAlpha(frameprops.alpha);
	frame:SetFrameStrata(frameprops.strata);
	
	-- Clear preexisting layout.
	frame:WMGetPositionalFrame():ClearAllPoints();
	
	-- If we're docked...
	local di = RDXDK.GetDockPoints(frameprops);
	if di and (not RDXDK.IsDGP(frameprops)) then
		-- For each neighbor...
		for localPoint, remoteInfo in pairs(di) do
			local otherframe = RDXDK.GetFrame(remoteInfo.id);
			local otherframeprops = RDXDK.GetFrameProps(remoteInfo.id);
			-- If the neighbor was successfully laid out...
			if otherframe and otherframe._dk_layout then
				RDXDK:Debug(8, "* docking " .. frameprops.name .. ":" .. localPoint .. " to " .. otherframeprops.name .. ":" .. remoteInfo.point);
				-- Dock us!
				frame:SetClampedToScreen(nil);
				local actualLocalPoint, dxl, dyl = frame:WMGetDockSourcePoint(localPoint);
				local actualRemotePoint, dxr, dyr = otherframe:WMGetDockTargetPoint(remoteInfo.point);
				frame:WMGetPositionalFrame():SetPoint(actualLocalPoint, otherframe:WMGetPositionalFrame(), actualRemotePoint, dxl+dxr, dyl+dyr);
				-- We're done!
				frame._dk_layout = true;
			end
		end
	else
		--frame:SetClampedToScreen(frameprops.cts);
		frame:WMGetPositionalFrame():SetClampedToScreen(frameprops.cts);
		local ap, l = frameprops.ap, frameprops.l;
		if l then
			--if not ap then ap = GetBoxQuadrantbyPosition(frameprops.l, frameprops.t, frameprops.r, frameprops.b); end
			if not ap or ap == "Auto" then ap = "TOPLEFT"; end
			RDXDK:Debug(4, "Position(".. ap ..",".. frameprops.l ..")");
			SetAnchorFramebyPosition(frame:WMGetPositionalFrame(), ap, frameprops.l, frameprops.t, frameprops.r, frameprops.b);
		else
			frame:WMGetPositionalFrame():SetPoint("CENTER", UIParent, "CENTER");
		end
		frame._dk_layout = true; 
	end
	return true;
end

local function LayoutDockGroup(frame)
	RDXDK:Debug(4, "LayoutDockGroup(".. frame._dk_name ..")");
	local frameprops = RDXDK.GetFrameProps(frame._dk_name);
	if frameprops and RDXDK.IsDocked(frameprops) then
		-- Find the dock group's parent; start there.
		local dgpframeprops = RDXDK.FindDockGroupParent(frameprops);
		if not dgpframeprops then
			RDXDK:Debug(4, "LayoutDockGroup(".. frame._dk_name .."): window doesn't have a DGP.");
			dgpframeprops = frameprops;
			RDXDK.MakeDockGroupParent(dgpframeprops); 
		end
		local fplist, fplistmissed = RDXDK.GetlistDockGroup(dgpframeprops);
		local save = nil;
		for _,fp in pairs(fplist) do
			RDXDK:Debug(4, "LayoutDockGroup(".. fp.name .."): layout.");
			if RDXDK.GetFrame(fp.name) then 
				LayoutFrame(RDXDK.GetFrame(fp.name));
			--else
			--	VFL.print("problem with " .. fp.name);
			--	RDXDK.ClearDockPointByName(dgpframeprops, fp.name);
			--	if RDXDK.IsDGP(fp) then RDXDK.SetDGP(dgpframeprops, nil); end
			--	save = true;
			end
		end
		for name,_ in pairs(fplistmissed) do
			RDXDK:Debug(4, "LayoutDockGroup Missed(".. name .."): layout.");
			RDXDK.ClearDockPointByName(dgpframeprops, name);
			save = true;
		end
		if #fplist == 1 then RDXDK.SetDGP(dgpframeprops, nil); dgpframeprops.dock = nil; save = true; end
		if save then RDXDK._SaveFrameProps(true, dgpframeprops); end
	else
		LayoutFrame(frame);
	end
end
RDXDK.LayoutDockGroup = LayoutDockGroup;

-- Layout all windows
local function LayoutAll()
	local frameList = RDXDK.GetFrameList();
	for _,frame in pairs(frameList) do
		if (not frame._dk_nolayout) and (not frame._dk_layout) then
			LayoutDockGroup(frame);
		end
	end
end
RDXDK.LayoutAll = LayoutAll;