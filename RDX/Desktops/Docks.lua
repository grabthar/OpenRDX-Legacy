-- Dock.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- OpenRDX
-- Original code from WindowManager
-- Dock is used to dock frame together
-- This file contains functions to manipulate frameprops table (frame properties)
-- 

----------------------------------------------------------
-- DOCK HELPER
----------------------------------------------------------

-- Determine if this frame can dock
local function IsICanDockToOther(frameprops)
	if frameprops.noattach then return nil; end
	return true;
end

-- Determine if other frame can dock me
local function IsOtherCanDockToMe(frameprops)
	if frameprops.nohold then return nil; end
	return true;
end

-- Determine if this frame is the dockgroup parent
local function IsDGP(frameprops)
	return frameprops.dgp;
end
RDXDK.IsDGP = IsDGP;

--- Set this frame's DGP status
local function SetDGP(frameprops, val)
	frameprops.dgp = val;
end
RDXDK.SetDGP = SetDGP;

--- Create a docking entry for this frame.
local function CreateDockEntry(frameprops, localPoint, remoteID, remotePoint)
	if not frameprops.dock then frameprops.dock = {}; end
	frameprops.dock[localPoint] = { id = remoteID, point = remotePoint };
end

-- Determine if this frame is docked
local function IsDocked(frameprops)
	local d = frameprops.dock;
	if not d then return nil; end
	if(VFL.tsize(d) > 0) then return true; else return nil; end
end
RDXDK.IsDocked = IsDocked;

--- Get the dockpoint table for this frame.
local function GetDockPoints(frameprops)
	return frameprops.dock;
end
RDXDK.GetDockPoints = GetDockPoints;

--- Clear a specific dock point on tihs frame.
local function ClearDockPoint(frameprops, pt)
	if frameprops.dock then frameprops.dock[pt] = nil; end
end

local function ClearDockPointByName(frameprops, name)
	if frameprops.dock then 
		for k,v in pairs (frameprops.dock) do
			if v.id == name then frameprops.dock[k] = nil; end
		end
	end
end
RDXDK.ClearDockPointByName = ClearDockPointByName;

--- Undock a window from this frame, verifying identity.
local function UndockOther(frameprops, localPoint, otherframeprops)
	if not frameprops.dock then return; end
	local di = frameprops.dock[localPoint];
	if di and (di.id == otherframeprops.name) then
		RDXDK:Debug(7, "remove remote <" .. frameprops.name .. "> dock");
		frameprops.dock[localPoint] = nil;
	end
end

-------------------------------------
-- DOCK CORE
-------------------------------------

-- Helpers for IterateDockGroup
local function IDGRecursive(frameprops, fn, touched, missed)
	-- Don't recurse over windows already visited
	if touched[frameprops.name] then return; end
	-- Do the operation
	fn(frameprops); touched[frameprops.name] = true;
	--RDXDK.SavePosition(RDXDK.GetFrame(frameprops.name), frameprops, true);
	-- Recurse
	local di = GetDockPoints(frameprops);
	if not di then return; end
	for _,ri in pairs(di) do
		local fp = RDXDK.GetFrameProps(ri.id);
		if fp then 
			IDGRecursive(fp, fn, touched, missed);
		else
			missed[ri.id] = true;
		end
	end
end

-- Iterate over all windows in the dock group of the given window, calling the 
-- function fn for each.
local _idg_touched = {};
local function IterateDockGroup(frameprops, fn)
	VFL.empty(_idg_touched);
	local _idg_missed = {};
	IDGRecursive(frameprops, fn, _idg_touched, _idg_missed);
	return _idg_missed;
end

-- Make frame the parent of its dock group
local function MakeDockGroupParent(frameprops)
	if IsDocked(frameprops) then
		IterateDockGroup(frameprops, function(x) SetDGP(x, nil); end);		
		SetDGP(frameprops, true);
	else
		SetDGP(frameprops, nil);
	end
	-- save
	RDXDK._SaveFramePropsList(false);
end
RDXDK.MakeDockGroupParent = MakeDockGroupParent;

-- Find the parent of frame's dock group.
local function FindDockGroupParent(frameprops)
	local ret = nil;
	if IsDocked(frameprops) then
		IterateDockGroup(frameprops, function(x) 
			if(IsDGP(x)) then ret = x; end 
		end);
	end
	return ret;
end
RDXDK.FindDockGroupParent = FindDockGroupParent;

-- Clear the parent of frame's dock group
local function ClearDockGroupParent(frameprops)
	IterateDockGroup(frameprops, function(x) SetDGP(x, nil); end);
end

-- Determine if two windows are in the same dock group
local function Interdocked(frameprops1, frameprops2)
	local ret = nil;
	IterateDockGroup(frameprops1, function(x) if (x == frameprops2) then ret = true; end end);
	return ret;
end

-- return the list of object in this dockgroup
local function GetlistDockGroup(frameprops)
	local fplist = {};
	local fplistmissed = IterateDockGroup(frameprops, function(x) if x.open then table.insert(fplist, x); end; end);
	return fplist, fplistmissed;
end
RDXDK.GetlistDockGroup = GetlistDockGroup;

----------------------------------------------------------
-- UNDOCK
----------------------------------------------------------

local function CompletelyUndock(frameprops, bump)
	-- Save my last known good position
	--RDXDK.SavePosition(RDXDK.GetFrame(frameprops.name), frameprops, true);
	-- If I was the DGP, get rid of it.
	SetDGP(frameprops, nil);
	-- Undock all attached windows.
	local di = GetDockPoints(frameprops);
	if di then
		-- For each dock point...
		for lp,ri in pairs(di) do
			-- Remove the local docking
			di[lp] = nil;
			-- Try to get the remote window...
			local fp = RDXDK.GetFrameProps(ri.id);
			if fp then
				-- Remove the reciprocal docking entry.
				UndockOther(fp, ri.point, frameprops);
				-- Try to find the remote window's dock parent. If it doesnt' have one,
				-- make IT into the new docking parent!
				if IsDocked(fp) then
					if not FindDockGroupParent(fp) then 
						RDXDK:Debug(7, "Undock(<" .. frameprops.name .. ">): undockee <" .. fp.name .. "> is dock-orphaned; promoting to DGP.");
						MakeDockGroupParent(fp);
					end
				else
					fp.dock = nil;
					fp.dgp = nil;
				end
				RDXDK._SaveFrameProps(false, fp);
			end
		end
	end
	frameprops.dock = nil;
	if bump then
		local t, l = frameprops.t, frameprops.l;
		if t then t = t - 5; end
		if l then l = l + 5; end
		frameprops.t, frameprops.l = t, l;
	end
	RDXDK._SaveFrameProps(false, frameprops);
end
RDXDK.CompletelyUndock = CompletelyUndock;

----------------------------------------------------------
-- DOCK CODE
----------------------------------------------------------

-- Distance functions
local dockDistance = 15;
local dist = function(x1, y1, x2, y2)
	if not x2 then x2 = 0; y2 = 0; end
	local dx, dy = x2-x1, y2-y1; 
	return math.sqrt(dx*dx + dy*dy);
end

local function DoDock(frameprops1, pt1, frameprops2, pt2)
	RDXDK:Debug(8, "->DoDock(" .. frameprops1.name .. "," .. pt1 .. ":" .. frameprops2.name .. "," .. pt2);
	-- Get the docking info
	local di1, di2 = GetDockPoints(frameprops1), GetDockPoints(frameprops2);
	-- Check if this docking has already been made.
	if (di1 and di2) and (di1[pt1] and di2[pt2]) then
		if (di1[pt1].id == frameprops2.name) and (di2[pt2].id == frameprops1.name) then
			RDXDK:Debug(8, "* Dock already made.");
			return true;
		end
	end
	-- If the docking hasn't already been made, but either of the two dock points are occupied, reject.
	if (di1 and di1[pt1]) or (di2 and di2[pt2]) then
		RDXDK:Debug(8, "* Dockpoint already occupied.");
		return false;
	end

	-- The "source" window loses its dock ancestry
	ClearDockGroupParent(frameprops1);
	-- Generate the new docking structure.
	CreateDockEntry(frameprops1, pt1, frameprops2.name, pt2);
	CreateDockEntry(frameprops2, pt2, frameprops1.name, pt1);

	-- If there wasn't already a remote docking structure, create it.
	if not FindDockGroupParent(frameprops2) then 
		RDXDK:Debug(8, "* Making " .. frameprops2.name .. " the DGP.");
		MakeDockGroupParent(frameprops2); 
	end
	
	-- write
	RDXDK._SaveFrameProps(nil, frameprops1);
	RDXDK._SaveFrameProps(nil, frameprops2);
	
	RDXDK:Debug(8, "* Docked.");
	return true;
end

-- Check if a dock should be considered legal between the docker and the target
local function IsDockLegal(dockerprops, targetprops)
	-- Can't dock to self.
	if dockerprops == targetprops then return false; end
	-- No-layout flag on docker = no good.
	--if docker._wm_nolayout then return false; end
	-- If docker is secure and we're locked down, no good.
	--if docker.secure and InCombatLockdown() then return false; end
	-- Local checks
	if not IsOtherCanDockToMe(targetprops) then return false; end
	if not IsOtherCanDockToMe(dockerprops) then return false; end
	-- Sometimes windows don't have coordinates; reject these windows.
	--if (not docker:WMGetDockBoundary()) or (not target:WMGetDockBoundary()) then return false; end
	-- OK
	return true;
end

-- Check if the docker is in dock interaction range of the target.
local function Check2DockInteraction(dockerprops, targetprops)
	RDXDK:Debug(7, "CheckDockInteraction(" .. dockerprops.name .. ", " .. targetprops.name .. ")");
	if not IsDockLegal(dockerprops, targetprops) then return false; end
	if Interdocked(dockerprops, targetprops) then return false; end
	-- Honor noattach and nohold flags.
	local dLeft, dTop, dRight, dBottom = GetUniversalBoundary(RDXDK.GetFrame(dockerprops.name));
	local tLeft, tTop, tRight, tBottom = GetUniversalBoundary(RDXDK.GetFrame(targetprops.name));
	-- Check if my topleft is near his bottomleft (bottom edge join)
	if (dist(dLeft, dTop, tLeft, tBottom) < dockDistance) then
		RDXDK:Debug(7, "* TOPLEFT->BOTTOMLEFT (Bottom edge join)");
		return DoDock(dockerprops, "TOPLEFT", targetprops, "BOTTOMLEFT");
	end
	-- Check if my topleft is near his topright (right edge join)
	if (dist(dLeft, dTop, tRight, tTop) < dockDistance) then
		RDXDK:Debug(7, "* TOPLEFT->TOPRIGHT (Right edge join)");
		return DoDock(dockerprops, "TOPLEFT", targetprops, "TOPRIGHT");
	end
	-- Check if my bottomleft is near his topleft (top edge join)
	if (dist(dLeft, dBottom, tLeft, tTop) < dockDistance) then
		RDXDK:Debug(7, "* BOTTOMLEFT->TOPLEFT (Top edge join)");
		return DoDock(dockerprops, "BOTTOMLEFT", targetprops, "TOPLEFT");
	end
	-- Check if my topright is near his topleft (left edge join)
	if (dist(dRight, dTop, tLeft, tTop) < dockDistance) then
		RDXDK:Debug(7, "* TOPRIGHT->TOPLEFT (Left edge join)");
		return DoDock(dockerprops, "TOPRIGHT", targetprops, "TOPLEFT");
	end
	-- Check if my bottomright is near his topright (left edge join)
	if (dist(dRight, dBottom, tRight, tTop) < dockDistance) then
		RDXDK:Debug(7, "* BOTTOMRIGHT->TOPRIGHT (Top edge join)");
		return DoDock(dockerprops, "BOTTOMRIGHT", targetprops, "TOPRIGHT");
	end
	-- No dice.
	return nil;
end

local function CheckDockInteraction(frameprops)
	local framepropslist = RDXDK.GetFramePropsList();
	for name,props in pairs(framepropslist) do
		if props.open then -- check only with open frame
			if Check2DockInteraction(frameprops, props) then return true; end
		end
	end
	return nil;
end
RDXDK.CheckDockInteraction = CheckDockInteraction;

