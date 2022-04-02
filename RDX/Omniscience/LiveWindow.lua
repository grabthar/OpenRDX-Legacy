-- LiveWindow.lua
-- RDX - Project Omniscience
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED CONTENT. COPYING IS PROHIBITED WITHOUT
-- A SEPARATE LICENSE.
--
-- The Omniscience Live combat log window.

local min,max = math.min, math.max;

local olw = nil;
local olw_lines, olw_width = 20, 346;
local olw_bkd = { r=0,g=0,b=0,a=0.1 };
local zeropad = VFL.zeropad;

local colspec = {
	{ title = "Time", width = 45},
	{ title = "HP", width = 75},
	{ title = "Amt", width = 40},
	{ title = "Misc", width = 160},
};

local function LastNLiterator(array, n)
	local function sz()
		return min(#array, n);
	end
	local function get(i)
		local z = #array;
		if(z < n) then
			return array[i];
		else
			return array[z - n + i];
		end
	end
	return sz, get;
end

------------------ Paint function
local function LWApplyData(cell, data, pos)
	local cols = cell.col;
	local tm, hp, amt, rest = cols[1], cols[2], cols[3], cols[4];
	local rowType = data.y;
	local tbl = Omni.localLog;
	local str = nil;
	
	-- Time
	local stWhole, stFrac = VFL.modf( (tbl.timeOffset + data.t) / 10);
	local str = date("%M:%S", stWhole);
	str = str .. string.format(".%1d", stFrac * 10);
	tm:SetText("|cFFAAAAAA" .. str .. "|r");

	-- Amt
	if data.x then
		str = strtcolor(Omni.GetRowTypeColor(rowType)) .. tostring(data.x);
		if Omni.IsCritRow(data) then
			amt:SetFont(Fonts.Default.face, 12);
			str = str .. "!";
		else
			amt:SetFont(Fonts.Default.face, 10);
		end
		amt:SetText(str .. "|r");
	else
		amt:SetText("");
	end

	-- HP
	if data.uh then
		local pct = VFL.clamp(data.uh / data.uhm, 0, 1);
		tempcolor:blend(_red, _green, pct);
		hp:SetText(zeropad(data.uh, 5, "|cFF333333", "|r" .. tempcolor:GetFormatString()) .. "|r/" .. zeropad(data.uhm, 5, "|cFF333333", "|r"));
	else
		hp:SetText("");
	end

	-- Rest
	str = Omni.GetAbilityString(data, rowType) .. "|r";
	local str2 = Omni.GetXiType(data.e);
	if str2 then
		str = str .. " |cFF00FFFF[|r" .. str2 .. "|cFF00FFFF]|r " .. Omni.GetMiscString(data);
	else
		str = str .. " " .. Omni.GetMiscString(data);
	end
	rest:SetText(str);
end

------------------------ Layout/setup functions
local function SetupLiveWindow()
	if not olw then return; end
	local tbl = olw.table;

	olw:SetBackdropColor(explodeRGBA(olw_bkd));
	olw:Accomodate(olw_width, (olw_lines * 10) + 2);
	tbl:SetWidth(olw_width); tbl:SetHeight((olw_lines * 10) + 2);
	tbl:Rebuild();
	tbl:SetDataSource(LWApplyData, LastNLiterator(Omni.GetLog(), olw_lines));
	Omni._ApplyColSpecToList(tbl, colspec);
end

local function ChangeNumLines_callback(val)
	if not olw then return; end
	val = tonumber(val);
	if not val then return; end
	val = VFL.clamp(val, 1, 50);
	RDXU.omniLW = val; olw_lines = val;
	SetupLiveWindow();
end

local function ChangeBkdColor_callback(r,g,b,a)
	olw_bkd.r = r; olw_bkd.g = g; olw_bkd.b = b; olw_bkd.a = a;
	RDXU.omniLWcolor = olw_bkd;
	SetupLiveWindow();
end

------------------------- Open/close functions
local function OpenLiveWindow()
	if olw then return; end

	olw = VFLUI.Window:new(UIParent); olw:SetFrameStrata("MEDIUM");
	olw:SetMovable(true);
	olw:SetFraming(VFLUI.Framing.Sleek);
	olw:SetTitleColor(0,.6,0); 
	olw:SetBackdropColor(explodeRGBA(olw_bkd));
	olw:SetText("Omniscience Live");
	olw:SetPoint("CENTER", UIParent, "CENTER");
	olw:Accomodate(olw_width, 10);
	olw:Show();

	-- Window menu
	function olw:_WindowMenu(mnu)
		table.insert(mnu, { text = "Rows...", OnClick = function()
			VFL.poptree:Release();
			VFLUI.MessageBox("Rows", "Enter number of rows to display:", "", "OK", ChangeNumLines_callback);
		end });
		table.insert(mnu, { text = "Background Color...", OnClick = function()
			VFL.poptree:Release();
			VFLUI.ColorPicker(olw, ChangeBkdColor_callback, VFL.Noop, VFL.Noop, explodeRGBA(olw_bkd));
		end });
	end

	-- Forbid docking
	--olw.WMCanOtherDockToMe = VFL.Nil;
	--olw.WMCanIDockToOther = VFL.Nil;
	
	RDXDK.StdMove(olw, olw:GetTitleBar(), function()
		Omni.Open(); Omni.SetActiveTable(Omni.localLog);
	end)
	
	--olw:GetTitleBar():SetScript("OnMouseUp", function()
	--	if(arg1 == "LeftButton") then
	--		Omni.Open(); Omni.SetActiveTable(Omni.localLog);
	--	end
	--end);

	-- The table
	local ctlTbl = VFLUI.List:new(olw, 10, function(x) return Omni._CreateCell(x, "Frame"); end);
	ctlTbl:SetScrollBarEnabled(nil);
	ctlTbl:SetPoint("TOPLEFT", olw:GetClientArea(), "TOPLEFT");
	ctlTbl:Show();
	olw.table = ctlTbl;

	OmniEvents:Bind("LOG_ROW_ADDED", ctlTbl, ctlTbl.Update, olw);

	olw.Destroy = VFL.hook(function(s)
		OmniEvents:Unbind(s);
		s.table:Destroy(); s.table = nil;
	end, olw.Destroy);
end

function Omni.CloseLiveWindow()
	if not olw then return; end
	olw:Destroy(); olw = nil;	
	RDXU.omniLW = nil;
end

function Omni.OpenLiveWindow()
	if olw then return; end
	olw_lines = RDXU.omniLW; if not olw_lines then olw_lines = 20; end
	OpenLiveWindow(); SetupLiveWindow();
	RDXU.omniLW = olw_lines;
	return olw;
end

function Omni.ToggleLiveWindow()
	if Omni.IsLiveWindowOpen() then 
		--RDXDK._CloseWindowRDX("desktop_omnilive");
		RDXDK.QueueLockdownAction("desktop_omnilive", RDXDK._CloseWindowRDX);
		RDX.print(i18n("|cFFAAFF00Omniscience:|r |cFFFFFFFFClose Live Window")); 
	else
		--RDXDK._OpenWindowRDX("desktop_omnilive");
		RDXDK.QueueLockdownAction("desktop_omnilive", RDXDK._OpenWindowRDX);
		RDX.print(i18n("|cFFAAFF00Omniscience:|r |cFFFFFFFFOpen Live Window"));
	end
end

function Omni.IsLiveWindowOpen()
	if olw then return true else return nil; end
end

