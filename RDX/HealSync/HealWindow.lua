-- HealWindow.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
-- 
-- A builtin window that monitors incoming healing on your target, or on
-- yourself if you have no target.

------------------------------------------------------------------------
-- Healing Synchronization module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
--   Version: 0.9
--
-- Note:
--  Licensed exclusively to Raid Informatics
------------------------------------------------------------------------
local GetUnitByName = RDX.GetUnitByNameIfInGroup;
local strlower = string.lower;
local currentUnit = "target";

local function ResolveUnit()
	local u = currentUnit;
	if (u == "target") or (u == "focus") then 
		u = UnitName(u);
		if u then u = strlower(u); end
	end
	if u then
		u = GetUnitByName(u);
		if u then return u; else return RDXPlayer; end
	end
end

local _green = { r=.1, g=1, b=.1 };
local _yellow = { r=.6, g=.6, b=0 };
local function BarColor(uid)
	if UnitIsUnit(uid, "player") then return _green; else return _yellow; end
end

local function Count()
	local u = ResolveUnit();
	if not u then return 0; else return u:_CountIncHeals(); end
end

local function Iter()
	local u = ResolveUnit();
	if not u then return VFL.Nil; else return u:_IterateIncHeals(); end
end

local thw;
local function OpenTargetHealingWindow()
	if thw then return; end

	thw = RDX.Window:new(RDXParent);

	local state = RDX.GenericWindowState:new();
	
	-- Add window frame
	state:AddFeature({feature = "Frame: Lightweight", title = i18n("Heals: Unknown")});
	state:_SetSlotFunction("SetTitleText", VFL.Noop);
	
	-- ApplyData invokes a user provided function
	state:AddSlot("_ApplyData");
	state:_SetSlotFunction("_ApplyData", function(frame, _, healInfo)
		local u = healInfo.origin; if not u:IsValid() then return; end
		local ratio, cval, maxc, ttxt, spell, eta, t = 1, 0, 3, "*", "", 0, GetTime();
		_, _, spell, _, _, eta = UnitCastingInfo(u.uid)
		if spell then
			cval = (eta/1000) - t;
			ratio = VFL.clamp(cval/maxc, 0, 1);
			ttxt = string.format("%0.1f", cval);
		else spell = ""; end
		frame.bar:SetStatusBarColor(explodeColor(BarColor(u.uid)));
		frame.bar:SetValue(1-ratio);
		frame.text1:SetTextColor(explodeColor(u:GetClassColor()));
		frame.text1:SetText(u:GetProperName() .. " (" .. spell .. " +" .. healInfo.value .. ")");
		frame.text2:SetText(ttxt);
	end);
	
	-- Add generic subframe
	state:AddFeature({feature = "Generic Subframe", w = 180, h = 16, tdx = 150});
	
	-- DataSource
	state:AddSlot("DataSource");
	state:AddSlot("DataSourceIterator");
	state:_SetSlotFunction("DataSourceIterator", Iter);
	state:AddSlot("DataSourceSize");
	state:_SetSlotFunction("DataSourceSize", Count);
	
	-- Layout
	state:AddFeature({feature = "Grid Layout", cols = 1, axis = 1, dxn = 1});
	
	-- Others features
	state:GetSlotValue("Multiplexer"):SetPeriod(nil);
	state:GetSlotValue("Multiplexer"):SetNoHinting(true);
	state:AddFeature({feature = "Event: Periodic Repaint", slot = "RepaintData", interval = 0.075}); 
	state:AddSlot("Menu");
	state:_SetSlotFunction("Menu", function(win, mnu)
		table.insert(mnu, {
			text = i18n("Watch Focus");
			OnClick = function()
				VFL.poptree:Release();
				HealSync.SetHealingWindowTarget("focus");
			end;
		});
		table.insert(mnu, {
			text = i18n("Watch Target");
			OnClick = function()
				VFL.poptree:Release();
				HealSync.SetHealingWindowTarget("target");
			end;
		});
		table.insert(mnu, {
			text = i18n("Watch Name") .. "...";
			OnClick = function()
				VFL.poptree:Release();
				VFLUI.MessageBox(i18n("Watch Name"), i18n("Enter name to watch:"), "", "OK", HealSync.SetHealingWindowTarget);
			end;
		});
	end);
	thw:SetMovable(true);
	thw:LoadState(state);

	-- On repaint, update the title bar with the name of the person whose heals we're watching
	thw.RepaintAll = VFL.hook(function()
		local u = ResolveUnit();
		if u and u:IsValid() then 
			thw:SetText(i18n("Heals: ") .. u:GetProperName()); 
		else
			thw:SetText(i18n("Heals: Unknown"));
		end
	end, thw.RepaintAll);
	
	state = nil;
	thw:Show();

	RDXEvents:Bind("UNIT_INCOMING_HEALS", nil, thw.RepaintAll, thw);
	RDXEvents:Bind("DISRUPT_WINDOWS", nil, thw.RepaintAll, thw);
	WoWEvents:Bind("PLAYER_TARGET_CHANGED", nil, thw.RepaintAll, thw);
	WoWEvents:Bind("PLAYER_FOCUS_CHANGED", nil, thw.RepaintAll, thw);
	
	return thw;
end
RDX.OpenTargetHealingWindow = OpenTargetHealingWindow;

local function CloseTargetHealingWindow()
	if not thw then return; end
	RDXEvents:Unbind(thw); WoWEvents:Unbind(thw);
	thw:Destroy(); thw = nil;
end
RDX.CloseTargetHealingWindow = CloseTargetHealingWindow;

------------------------------------------------------
-- ADMIN FUNCTIONS
------------------------------------------------------
function HealSync.SetHealingWindowTarget(unit)
	if type(unit) ~= "string" then return; end
	unit = strlower(unit);
	RDXU.TargetHealing = unit;
	currentUnit = unit;
	if thw then thw:RepaintAll(); end
end

function HealSync.ToggleTargetHealingWindow()
	if RDXU.TargetHealing then
		RDX.print(i18n("Target Healing Window disabled"));
		RDXU.TargetHealing = nil;
		--RDXDK._CloseWindowRDX("desktop_healtarget");
		RDXDK.QueueLockdownAction("desktop_healtarget", RDXDK._CloseWindowRDX);
	else
		RDX.print(i18n("Target Healing Window enabled"));
		RDXU.TargetHealing = "target"; currentUnit = "target";
		--RDXDK._OpenWindowRDX("desktop_healtarget");
		RDXDK.QueueLockdownAction("desktop_healtarget", RDXDK._OpenWindowRDX);
	end
end

function HealSync.IsTargetHealingOpen()
	if RDXU.TargetHealing then return true; else return nil; end
end

----------------------------
-- INIT
----------------------------
RDXEvents:Bind("INIT_DESKTOP", nil, function()
	-- Restore the previous status of the window
	--if RDXU.TargetHealing then
	--	currentUnit = RDXU.TargetHealing;
	--	OpenTargetHealingWindow();	
	--end
end);
