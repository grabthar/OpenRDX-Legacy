-- Orphanage.lua
-- VFL
-- (C)2005-2006 Bill Johnson and the VFL Project
--
-- Stuff that doesn't quite fit in anywhere else.
local strformat, strrep = string.format, string.rep;
local max, abs, floor, ceil = math.max, math.abs, math.floor, math.ceil;
local round = VFL.round;

--- Returns a function that generates an increasing series of numbered
-- tokens beginning with the given prefix string.
function VFL.GenerateSequencer(prefix)
	local i = 0;
	return function()
		i=i+1; return prefix .. i;
	end
end

--- Pad a stringified number with zeroes.
function VFL.zeropad(n, pad, zprefix, nprefix)
	local nstr = strformat("%d", n);
	return zprefix .. strrep("0", max(pad - strlen(nstr), 0)) .. nprefix .. nstr;
end

----------------------------------------------------
-- Convert a number to a string formatted as K(ilo) or M(ega)
----------------------------------------------------
function Kay(n)
	local an = abs(n);
	if an < 1000 then
		return strformat("%d", n);
	elseif an < 100000 then
		return strformat("%0.1fk", n/1000);
	else
		return strformat("%0.2fm", n/1000000);
	end
end

-----------------------------------------------------
-- Convert a number of seconds to Xh, Xm, or Xs depending on magnitude
-----------------------------------------------------
function Emm(n)
	if n < 60 then
		return floor(n) .. "s";
	elseif n < 3600 then
		return round(n/60) .. "m";
	else
		return round(n/3600) .. "h";
	end
end

function Hundredths(t)
	return strformat("%0.2f", t);
end

function VFL.Tenths(t)
	return strformat("%0.1f", t);
end

function VFL.NumberFloor(t)
	return floor(t);
end

--------------------------------------------
-- CODE SNIPPET OBJECT
--
-- The Snippet object allows the on-the-fly assembly of a snippet of code.
--------------------------------------------
VFL.Snippet = {};
function VFL.Snippet:new()
	local self, code = {}, "";
	function self:AppendCode(x) code = code .. x; end
	function self:PrependCode(x) code = x .. code; end
	function self:AppendSnippet(s) code = code .. s:GetCode(); end
	function self:PrependSnippet(s) code = s:GetCode() .. code; end
	function self:GetCode() return code; end
	function self:Clear() code = ""; end
	return self;
end

---------------------------------------------
-- Code viewer
---------------------------------------------
function VFL.Debug_ShowCode(code)
	-- Add line numbers to the passed code
	local ln = 1;
	code = "|cFF00FF00001|r " .. string.gsub(code, "\n", function() 
		ln = ln + 1; 
		return string.format("\n|cFF00FF00%03d|r ", ln);
	end);

	-- Create a simple display window for the code.
	local win = VFLUI.Window:new(UIParent);
	win:SetFrameStrata("FULLSCREEN_DIALOG");
	VFLUI.Framing.Default(win, 18);
	win:SetText("Code Viewer"); win:SetTitleColor(0.6, 0, 0);
	win:SetWidth(510); win:SetHeight(385); win:SetPoint("CENTER", UIParent, "CENTER");
	VFLUI.Window.StdMove(win, win:GetTitleBar());
	win:Show();

	local f = VFLUI.TextEditor:new(win:GetClientArea());
	f:SetWidth(500); f:SetHeight(350);
	f:SetPoint("CENTER", win:GetClientArea(), "CENTER");
	f:SetText(code);
	f:Show();

	local esch = function()
		f:Destroy(); f = nil; win:Destroy(); win = nil;
	end;
	VFL.AddEscapeHandler(esch);
	local closebtn = VFLUI.CloseButton:new();
	closebtn:SetScript("OnClick", function() VFL.EscapeTo(esch); end);
	win:AddButton(closebtn);
end

----------------------------------------------
-- Raid Icon colors
----------------------------------------------
VFL_RaidIconColor = {};
for i=1,8 do
	VFL_RaidIconColor[i] = UnitPopupButtons["RAID_TARGET_" .. i].color;
end

------------------------------------------------
-- Combat and Battleground Detection
------------------------------------------------
local inCombat = nil;
function VFL._ForceCombatFlag(f)
	if f and (not inCombat) then
		inCombat = true;
		VFL:Debug(1, "********** VFL combat flag TRUE *************");
		VFLEvents:Dispatch("PLAYER_COMBAT", true);
	elseif (not f) and inCombat then
		inCombat = nil;
		VFL:Debug(1, "********** VFL combat flag FALSE *************");
		VFLEvents:Dispatch("PLAYER_COMBAT", nil);
	end
end

WoWEvents:Bind("PLAYER_REGEN_DISABLED", nil, function() VFL._ForceCombatFlag(true); end);
WoWEvents:Bind("PLAYER_REGEN_ENABLED", nil, function() VFL._ForceCombatFlag(nil); end);

function VFL.PlayerInCombat() return InCombatLockdown(); end

-- Bg detection
local inBG = nil;
local function SetBGFlag(f)
	if f and (not inBG) then
		inBG = true;
		VFLEvents:Dispatch("PLAYER_IN_BATTLEGROUND", true);
	elseif (not f) and inBG then
		inBG = nil;
		VFLEvents:Dispatch("PLAYER_IN_BATTLEGROUND", nil);
	end
end

-- Arena detection
local inA = nil;
local function SetAFlag(f)
	if f and (not inA) then
		inA = true;
		VFLEvents:Dispatch("PLAYER_IN_ARENA", true);
	elseif (not f) and inA then
		inA = nil;
		VFLEvents:Dispatch("PLAYER_IN_ARENA", nil);
	end
end

function VFL.InBattleground()
	--return (MiniMapBattlefieldFrame.status == "active") and select(2,IsInInstance()) == "pvp";
	return select(2,IsInInstance()) == "pvp";
end

function VFL.InArena()
	--return (MiniMapBattlefieldFrame.status == "active") and select(2, IsInInstance()) == "arena";
	return select(2, IsInInstance()) == "arena";
end

WoWEvents:Bind("UPDATE_BATTLEFIELD_STATUS", nil, function()
	if VFL.InBattleground() then
		SetBGFlag(true);
	else
		SetBGFlag(nil);
	end
	if VFL.InArena() then
		SetAFlag(true);
	else
		SetAFlag(nil);
	end
end);

function VFL.GetBGName(name)
	-- remove any dash
	local _, _, bg_name = string.find(name, "^(.*)-(.*)$");
	-- Record the target
	if bg_name then return bg_name; else return name; end
end

--- Wildcard converter. Converts "simple" wildcard strings using * as a wildcard
-- into Lua regular expressions.
function VFL.WildcardToRegex(wc)
	local ret = string.gsub(wc, "[^%w]", function(m)
		if(m == "*") then return ".*"; else return "%" .. m; end
	end);
	return ret;
end

--- Determine if the player is the class given.
function VFL.PlayerClassIs(class)
	local _,c = UnitClass("player");
	return (c == class);
end

--- Determine the player's rank in the talent with the specified name.
-- Returns 0 if they don't have the talent trained.
function VFL.GetPlayerTalentRank(talent)
	for tab=1,GetNumTalentTabs() do
		for talentID=1,GetNumTalents(tab) do
			local name,_,_,_,rank = GetTalentInfo(tab, talentID);
			if name == talent then return rank;	end
		end
	end
	return 0;
end

-------------------------------------------------------
-- For some reason, Blizzard decided to break unit suffixing conventions by
-- replacing "raidXXpet" with "raidpetXX" (why, Blizzard, why?)
-- To make things worse, there's no such thing as "playerpet"; instead, it's just
-- "pet".
-- This function fixes that.
-------------------------------------------------------
local _pettbl = {};
_pettbl["playerpet"] = "pet";
for i=1,5 do
	_pettbl["party" .. i .. "pet"] = "partypet" .. i;
end
for i=1,40 do
	_pettbl["raid" .. i .. "pet"] = "raidpet" .. i;
end

function VFL.ResolvePetUID(uid)
	local pt = _pettbl[uid]; if pt then return pt; else return uid; end
end

local _ownertbl = {};
_ownertbl["pet"] = "player";
for i=1,5 do
	_ownertbl["partypet" .. i] = "party" .. i;
end
for i=1,40 do
	_ownertbl["raidpet" .. i] = "raid" .. i;
end

function VFL.GetPetOwnerUID(puid)
	if not puid then return; end
	return _ownertbl[puid];
end

-- Extract a unit from a secure button, properly accounting for pets.
function VFL.GetSecureButtonUnit(self, button)
	local unit = SecureButton_GetModifiedAttribute(self, "unit", button);
	if unit then
		local unitsuffix = SecureButton_GetModifiedAttribute(self, "unitsuffix", button);
		if unitsuffix then
			unit = unit .. unitsuffix;
			local pt = _pettbl[unit]; if pt then return pt; end
		end
		return unit;
	end
end

