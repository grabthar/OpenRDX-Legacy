-- Time.lua
-- VFL
-- (C)2006 Bill Johnson and The VFL Project
--
-- Time-related functions

if not VFL.Time then VFL.Time={}; end

-- Localize functions to prevent table lookups
local mathdotfloor = math.floor;
local mathdotmodf = math.modf;
local blizzGetTime = GetTime;
local tempty, tinsert, tremove, tsort = VFL.empty, table.insert, table.remove, table.sort;
local strmatch = string.match;

--- Gets the kernel time with 1/10th second precision.
-- @return The kernel time in tenths-of-a-second.
function GetTimeTenths()
	return mathdotmodf(blizzGetTime()*10);
end

-----------------------------------------------
-- TIMERS
-----------------------------------------------
-- Countup timer
if not VFL.CountUpTimer then VFL.CountUpTimer={}; end


-- Create a new countup timer
function VFL.CountUpTimer:new()
	local s = {};

	local baseline, t0 = 0, nil;
	function s:Start() t0 = GetTime(); end
	function s:Get()
		if t0 then return baseline + (GetTime() - t0); else return baseline; end
	end
	function s:Stop()
		baseline = self:Get(); t0 = nil;
	end
	function s:Reset() baseline = 0; t0 = nil; end
	function s:IsRunning() return t0; end

	return s;
end

----------------------------------------------------------------------------------------------
-- ADAPTIVE SCHEDULER
--
-- The adaptive scheduler is a system designed to improve the performance impact
-- of frequently-recurring (subsecond precison) tasks.
--
-- It works by assigning tasks to "slots" within the 1-second interval, then sweeping
-- over those slots and running the tasks. Each task receives a random offset that ensures
-- it does not collide with other tasks. It also reduces overhead by not "thrashing" schedule entries.
--
-- Moreover, when FPS drops below a user definable number, the adaptive staggered scheduler
-- automatically "dilates" the schedule to slow everything down.
----------------------------------------------------------------------------------------------
VFLP.RegisterCategory("VFL Scheduler");

local aix, dilation, idilation = 1, 1, 1;
local ads = {};

--- Adaptive-schedule a recurring process.
function VFL.AdaptiveSchedule(id, interval, func, ...)
	if(not interval) or (interval <= 0.02) then
		error("VFL.AdaptiveSchedule: Must provide an interval larger than 0.02 seconds.");
	end
	if not func then
		error("VFL.AdaptiveSchedule: Must provide a function to schedule.");
	end
	local t = GetTime() + math.random(0, math.floor(interval*100))/100;
	local stbl = {
		id = id;
		interval = interval;
		x = 0;
		func = func;
		start = t;
        last = t;
	};
	for i=1,select("#",...) do stbl[i] = select(i,...); end
	table.insert(ads, stbl);
	return stbl;
end

--- Change the dilation of the adaptive scheduler
function VFL.SetScheduleDilation(d)
	if(not d) or (d < 0.1) then error("invalid dilation"); end
	dilation = d; idilation = 1/d;
end

--- Unschedule by ID from the adaptive scheduler
function VFL.AdaptiveUnschedule(id)
	VFL.filterInPlace(ads, function(x)
		return x.id ~= id;
	end);
end

-- The internals of the adaptive scheduler
local tas, target_timescale;
local function _AS()
	tas = GetTime();
	for i,entry in ipairs(ads) do
		-- Target timescale is the number of times this function SHOULD have run.
		target_timescale = mathdotfloor( (tas - entry.start) / (entry.interval * dilation) );
		if( (entry.x * idilation) < target_timescale ) then
			entry.func(unpack(entry), (tas - entry.last));
			entry.x = (target_timescale + .0001) * dilation;
			entry.last = tas;
		end
	end	
end
local asframe = CreateFrame("Frame");
asframe:SetScript("OnUpdate", _AS);
VFLP.RegisterFunc("VFL Scheduler", "Adaptive load", _AS, true);

-----------------------------------------------------------------
-- ZERO-MEMORY SCHEDULER
--
-- The zero-memory scheduler is an alternative scheduling implementation
-- for "one-off" scheduling tasks.
--
-- It allocates zero tables and one table entry at schedule time, using
-- nearly no memory and performing very little work. However, its cycle
-- time is linear in the size of the schedule table. Moreover, entities
-- scheduled with ZMSchedule can only be directly unscheduled by handle,
-- creating the need for an API layer on top of ZMSchedule for more
-- complex cases.
-----------------------------------------------------------------
local zmt, zfunq = {}, {};

--- Schedule func to be executed dt seconds from now.
-- Returns a handle for later descheduling.
function VFL.ZMSchedule(dt, func)
	local tt, i = mathdotfloor((GetTime() + dt) * 1000), 0;
	while zmt[tt+i] do i=i+1; end
	zmt[tt+i] = func;
	return tt+i;
end
VFLP.RegisterFunc("VFL Scheduler", "ZM create", VFL.ZMSchedule, nil);

--- Unschedule a function scheduled by ZMSchedule. You must pass
-- the return value from ZMSchedule as the handle.
function VFL.ZMUnschedule(handle)
	zmt[handle] = nil;
end

-- The internals of the ZM scheduler.
local tzm, izm;
local function _ZM()
	tzm, izm = mathdotfloor(GetTime() * 1000), 0;
	-- Need to separate descheduling from execution due to Lua's
	-- fail-on-insert iterators. First build up a queue (using
	-- a preallocated array, no temp tables!)
	for st,func in pairs(zmt) do
		if(tzm > st) then
			izm=izm+1; zfunq[izm] = func;
			zmt[st] = nil;
		end
	end
	-- Now run the queue, emptying it as we go.
	for j=1,izm do
		zfunq[j](); zfunq[j] = nil;
	end
end
local zmframe = CreateFrame("Frame");
zmframe:SetScript("OnUpdate", _ZM);
VFLP.RegisterFunc("VFL Scheduler", "ZM load", _ZM, true);

function zmtest(n)
	for i=1,n do
		local qq=i;
		VFL.ZMSchedule(5, function() VFL.print("ZMSchedule " .. qq); end);
	end
end

-----------------------------------------------------------------
-- NEXT-FRAME SCHEDULER
--
-- Schedule something to happen on the next frame.
-----------------------------------------------------------------
local nfFrame, nfFunc, nfq = {}, {}, {};
local frameCounter = 0;

local inf;
local function _NF()
	frameCounter = frameCounter + 1;
	inf = 0;
	for k,v in pairs(nfFrame) do
		if v <= frameCounter then
			inf = inf + 1; nfq[inf] = nfFunc[k];
			nfFrame[k] = nil; nfFunc[k] = nil;
		end
	end
	for j=1,inf do nfq[j](); nfq[j] = nil; end
end
local NFFrame = CreateFrame("Frame");
NFFrame:SetScript("OnUpdate", _NF);
VFLP.RegisterFunc("VFL Scheduler", "NextFrame load", _NF, true);

function VFL.NextFrame(id, func)
	if nfFrame[id] then return; end
	nfFrame[id] = frameCounter + 1;
	nfFunc[id] = func;
end

function VFL.GetFrameCounter() return frameCounter; end

-----------------------------------------------------------------
-- STANDARD SCHEDULER
-----------------------------------------------------------------
-- The schedule table
local sched, schedx = {}, {};
local function timeSort(x1,x2) return x1.t > x2.t; end

-- The schedule executive
local nsc, m0sc, m1sc, tsc, xsc, zsc;
local function Sched()
	-- Indices
	nsc, m0sc, m1sc, tsc = #sched, 0, (#schedx + 1), GetTime();
	-- Start at the beginning
	xsc, zsc = sched[nsc], nil;
	-- For each scheduled object that's past-due
	while (xsc and xsc.t <= tsc) do
		-- We want to move it to the execution queue at spot "m0".
		-- If there's something already there, move it to spot "m1".
		m0sc = m0sc + 1; zsc = schedx[m0sc]; schedx[m0sc] = xsc;
		if zsc then schedx[m1sc] = zsc; m1sc = m1sc + 1; end
		-- Remove it from the schedule
		sched[nsc] = nil;
		-- Move on
		nsc=nsc-1; xsc = sched[nsc];
	end
	-- For every object added to the execution queue
	for i=1,m0sc do
		-- Retrieve and execute
		xsc = schedx[i]; 
		if xsc.func then xsc.func(unpack(xsc)); end
		-- Recycle it
		tempty(xsc);
	end
end
local schedframe = CreateFrame("Frame");
schedframe:SetScript("OnUpdate", Sched);
VFLP.RegisterFunc("VFL Scheduler", "Sched load", Sched, true);

-- The schedule allocator.
-- We look at the last object in the execution queue. If it's empty
-- we reuse, otherwise create.
local function SchedAlloc()
	local n = #schedx;
	local ret = schedx[n];
	if ret and (not ret.t) then
		schedx[n] = nil; return ret;
	else
		return {};
	end
end
VFLP.RegisterFunc("VFL Scheduler", "Sched create", SchedAlloc, nil);

--- Schedule a function to be executed dt sec in the future.
function VFL.schedule(dt, func, ...)
	local x = SchedAlloc();
	x.func = func; x.t = GetTime() + dt;
	for i=1,select("#", ...) do	x[i] = select(i, ...); end
	tinsert(sched, x);
	tsort(sched, timeSort);
	return x;
end

--- Schedule a function to be executed dt sec in the future.
-- Associates a name with the scheduled event that allows it to be
-- revoked.
function VFL.scheduleNamed(name, dt, func, ...)
	local x = SchedAlloc();
	x.name = name; x.func = func; x.t = GetTime() + dt;
	for i=1,select("#", ...) do	x[i] = select(i, ...); end
	tinsert(sched, x); 
	tsort(sched, timeSort);
	return x;
end

--- Unschedule a function by pattern match on the name
-- WARNING: This function is slow enough where it shouldn't be called on
-- a per-frame basis.
function VFL.unschedulePattern(ptn)
	for _,se in pairs(sched) do
		if se.name and strmatch(se.name, ptn) then se.func = nil;	end
	end
end

-- COMPAT: old syntax
VFL.Time.CreateScheduleEntry = VFL.scheduleNamed;

--- Deschedule a previously scheduled entry.
function VFL.deschedule(se)
	if not se then return; end
	se.func = nil;
end
VFL.unschedule = VFL.deschedule;

-- Return the countdown to an event, in seconds
function VFL.Time.GetEventCountdown(ev)
	return ev.t - GetTime();
end;

-- Find an event by name
function VFL.Time.FindEventByName(name)
	for i=1,#sched do
		if sched[i].name == name then return sched[i]; end
	end
	return nil;
end

-- Remove an event by name
function VFL.Time.UnscheduleByName(name)
	VFL.filterInPlace(sched, function(x) return x.name ~= name; end);
end
VFL.unscheduleNamed = VFL.Time.UnscheduleByName;

-- Schedule by name if not already scheduled
function VFL.scheduleExclusive(name, dt, func, ...)
	if not VFL.Time.FindEventByName(name) then
		VFL.scheduleNamed(name, dt, func, ...);
	end
end

function test_sched(qq_i)
	if not qq_i then qq_i = 0; end
	if (qq_i % 10) == 0 then VFL.print("second " .. qq_i/10); end
	VFL.schedule(.1, test_sched, qq_i + 1);
end

---------------------------
-- PERIODIC LATCH
-- A periodic latch prevents the underlying function from running
-- more often than once every N seconds.
---------------------------
--- Create a "periodic latch" around a function. The periodic latch guarantees that a function
-- won't be called more often than the period, and if the function should be spammed multiple
-- times, it'll be called again the end of the period.
-- Returns a "terminate" function that can be used in the event of a shutdown to destroy the latch.
function VFL.CreatePeriodicLatch(period, f)
	local latch, deferred, unlatch, go = nil, nil, nil, nil;
	local dargtbl = {};
	
	function unlatch()
		latch = nil;
		if deferred then 
			f(unpack(dargtbl));
			for k in pairs(dargtbl) do dargtbl[k] = nil; end
			deferred = nil;
		end
	end

	function go(...)
		if not latch then
			f(...);
			deferred = nil; latch = true;
			VFL.ZMSchedule(period, unlatch);
		else
			if not deferred then
				deferred = true;
				for i=1,select("#",...) do dargtbl[i] = select(i,...); end
			end
		end
	end

	local function terminate()
		deferred = nil; for k in pairs(dargtbl) do dargtbl[k] = nil; end
		go = VFL.Noop; unlatch = VFL.Noop; f = VFL.Noop;
	end
	
	return go, terminate;
end

----------------------------------------------------------------
-- PARSING, FORMATTING
----------------------------------------------------------------
-- Convert elapsed seconds to elapsed hours, minutes, seconds
function VFL.Time.GetHMS(sec)
	local min = math.floor(sec/60); sec = VFL.mmod(sec, 60);
	local hr = math.floor(min/60); min = VFL.mmod(min, 60);
	return { hour = hr; min = min; sec = sec; };
end

-- Convert (hours, minutes, seconds) to seconds
function VFL.Time.HMSToSec(hms)
	return (hms.hour * 3600) + (hms.min * 60) + hms.sec;
end

-- Format a seconds time as min:sec
function VFL.Time.FormatMinSec(sec)
	local min = math.floor(sec/60); sec = VFL.mmod(sec, 60);
	return string.format("%d:%02d", min, sec);
end
-- Format seconds as hh:mm:ss
function VFL.Time.FormatHMS(sec)
	local min = math.floor(sec/60); sec = VFL.mmod(sec, 60);
	local hr = math.floor(min/60); min = VFL.mmod(min, 60);
	return string.format("%02d:%02d:%02d", hr, min, sec);
end

function VFL.Time.FormatSmartMinSec(sec)
	if sec < 0 then return "*"; end
	local min = math.floor(sec/60); sec = VFL.mmod(sec, 60);
	local hr = math.floor(min/60); min = VFL.mmod(min, 60);
	if hr > 0 then
		return string.format("%dh%02dm", hr, min);
	elseif min > 0 then
		return string.format("%dm%02ds", min, sec);
	else
		return string.format("%0.1fs", sec);
	end
end

function VFL.Time.ParseHMS(str)
	local h,m,s = string.match(str, "(%d+):(%d+):(%d+)");
	h = tonumber(h); m = tonumber(m); s = tonumber(s);
	if (not h) or (not m) or (not s) then return nil; else return h,m,s; end
end

--- Format very small time periods as a string.
function VFL.Time.FormatMicro(time)
	if(time < .001) then
		return string.format("%d|cFF444444\194\181s|r", math.floor(time * 1000000));
	elseif(time < .1) then
		return string.format("%0.2f|cFFAAAAAAms|r", time * 1000);
	else
		return string.format("%0.2f|cFFFFFFFFs|r", time);
	end
end

----------------------------------------------------------------
-- EPOCH
-- An epoch is a specified "zero point" in time, and tools to
-- transform time based around that zero point.
----------------------------------------------------------------
VFL.Epoch = {};
VFL.Epoch.__index = VFL.Epoch;

function VFL.Epoch:new()
	local self = {};
	setmetatable(self, VFL.Epoch);
	return self;
end

--- Establish an epoch using an exact minute (hh:mm:00.00)
function VFL.Epoch:Synchronize(kernelTime, localTime, serverHr, serverMin)
	-- First priority is to compute the discrepancy between our estimate of the
	-- server time, and the actual server time.
	
	-- Get our estimate of the server's time
	local estServerDate = date("*t", localTime + VFL.GetServerTimeOffset());

	-- Assuming our estimate isn't too far off, the EXACT server time can be
	-- obtained by setting the hour, minute, second fields appropriately
	estServerDate.hour = serverHr;
	estServerDate.min = serverMin;
	estServerDate.sec = 0;
	self.serverTime = time(estServerDate);

	self.localTime = localTime;
	self.kernelTime = kernelTime;
end

--- Get the discrepancy between server and local time as it was when
-- this epoch was synchronized.
function VFL.Epoch:GetLocalTimeCorrection()
	return self.serverTime - self.localTime - VFL.GetServerTimeOffset();
end

--- Get the discrepancy between kernel and server time, such that
-- kernelTime + GetKernelTimeCorrection() = serverTime
function VFL.Epoch:GetKernelTimeCorrection()
	return self.serverTime - self.kernelTime;
end

--- Get the server time according to this epoch.
function VFL.Epoch:GetServerTime()
	return (GetTime() - self.kernelTime) + self.serverTime;
end

--- Convert a time to epochal server time.
function VFL.Epoch:KernelToServerTime(ktime)
	return (ktime - self.kernelTime) + self.serverTime;
end

-- Print debug information about an epoch.
function VFL.Epoch:Dump()
	VFL:Debug(1, "Epoch: kernelTime(" .. self.kernelTime .. ") = localTime(" .. self.localTime ..") = serverTime(" .. self.serverTime ..") = epochTime(0)");
	local kNow, sh, sm = GetTime(), GetGameTime();
	local eSvrTm = self.serverTime + (kNow - self.kernelTime);
	local eSvrDate = date(nil, eSvrTm);
	VFL:Debug(1, "* Epochal serverTime [" .. eSvrDate .. "] -- source " .. eSvrTm);
	VFL:Debug(1, "* Actual serverTime: " .. sh .. ":" .. sm);
	VFL:Debug(1, "* Exact discrepancy: " .. (self.serverTime - self.localTime - VFL.GetServerTimeOffset()));
end

----------------------------------------------------------------
-- UNIVERSAL TIME
----------------------------------------------------------------
-- System epoch management
local lastmin, sysEpoch, tz, kernelToServer = nil, nil, 0, 0;

--- Get the hourly offset from local time to server time.
-- @return the number of seconds X satisfying ServerTime = LocalTime + X
function VFL.GetServerTimeOffset() 
	return tz * 3600;
end

local function TimeFixUpdate()
	-- Check the game time
	local h,m = GetGameTime();
	-- If the minute ticked, we have a time fix!
	if(m ~= lastmin) then
		local kernelTime, localTime = GetTime(), time();
		sysEpoch = VFL.Epoch:new();
		sysEpoch:Synchronize(kernelTime, localTime, h, m);
		VFL:Debug(1,"System epoch established!");
		sysEpoch:Dump();
		kernelToServer = sysEpoch:GetKernelTimeCorrection();
		VFLEvents:Dispatch("SYSTEM_EPOCH_ESTABLISHED", sysEpoch);
	else
		-- Keep spamming time checks (we need 0.1 sec precision)
		VFL.ZMSchedule(0.1, TimeFixUpdate);
	end
end
local function SetupSysEpoch()
	VFL:Debug(1, "* Establishing system epoch.");
	_, lastmin = GetGameTime();
	TimeFixUpdate();
end

--- Get the VFL system epoch.
function VFL.GetSystemEpoch()
	return sysEpoch;
end

--- Initialize the VFL kernel's timing subsystem.
function VFL.InitTime()
	VFL:Debug(1, "VFL.InitTime(): Initializing timing subsystem.");

	-- Mark the current time.
	local now, sh, sm = time(), GetGameTime();
	local today = date("*t");

	-- Mmmkay, we need to figure out the offset in hours between local time and server time.
	-- Let's pick the number that is LESS THAN 12 HOURS that gives us the best fit.
	-- Compute the difference between the server hour and the current hour mod 24 hours.
	-- Use minutes for higher precision.
	tz = VFL.mod( (sh*60 + sm) - ((today.hour*60) + today.min), 24*60);
	-- If the value is more than 12 hours, go the other way round the clock instead.
	if(tz > 720) then
		tz = -VFL.mod( ((today.hour * 60) + today.min) - (sh*60 + sm) , 24*60);
	end
	-- Convert back to hours.
	tz = VFL.round(tz/60);
	-- Print info
	VFL.print("|cFFFFFFFF[VFL]|r Local time is |cFF00FF00" .. today.hour .. ":" .. today.min .. "|r, server time is |cFF00FF00" .. sh .. ":" .. sm .. "|r");
	VFL.print("|cFFFFFFFF[VFL]|r Autodetected time difference: Server = Local + |cFF00FF00" .. tz .. " hours|r");
	-- Allow the timezone to be directly overridden.
	if VFLConfig.overrideTZ then
		tz = VFLConfig.overrideTZ;
		VFL.print("|cFFFFFFFF[VFL]|r Override timezone: |cFF00FF00" .. tz .. " hours|r");
	end

	-- Figure out the projected server time based on the server time offset.
	local projServerTime = now + VFL.GetServerTimeOffset();
	local projServerDate = date("*t", projServerTime);
	projServerDate.hour = sh; projServerDate.min = sm;
	local serverTime = time(projServerDate);
	
	-- Verify that the estimated server time is somewhat accurate.
	-- If not, demand the user set the offset.
	local diff = math.abs(projServerTime - serverTime);
	VFL:Debug(1, "* Time discrepancy of " .. diff .. "s detected.");
	if(diff > 3600) then
		VFL.print("|cFFFFFFFF[VFL]|r Clock discrepancy of |cFFFF0000" .. diff .. " seconds|r detected. Your time zone may be set incorrectly. Use /timezone to set your timezone manually.");
	end

	-- Get a time fix
	SetupSysEpoch();
end

--- Get the UTC server time.
function VFL.GetServerTime()
	return GetTime() + kernelToServer;
end

-- Manual timezone setup
SLASH_TIMEZONE1 = "/timezone";
SlashCmdList["TIMEZONE"] = function(arg)
	if(arg == "clear") then VFLConfig.overrideTZ = nil; return; end
	local n = tonumber(arg)
	if not n then
		local sh, sm = GetGameTime();
		local today = date("*t");
		VFL.print("|cFFFFFFFF[VFL]|r Local time is |cFF00FF00" .. today.hour .. ":" .. today.min .. "|r, server time is |cFF00FF00" .. sh .. ":" .. sm .. "|r");
		VFL.print("|cFFFFFFFF[VFL]|r Current timezone value: Server = Local + |cFF00FF00" .. tz .. " hours|r");
		VFL.print("|cFFFFFFFF[VFL]|r Type |cFF00FF00/timezone NNN|r to forcibly change the timezone, where NNN is the number of hours difference between the server and you.");
	else
		tz = VFL.clamp(n,-24,24);
		VFLConfig.overrideTZ = tz;
		SetupSysEpoch();
	end
end
