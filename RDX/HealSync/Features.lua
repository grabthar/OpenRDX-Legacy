-- Features.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- UnitFrame and other features related to the Heal Sync system.

local bor = bit.bor;

------------------------------------------------------------------------
-- Healing Synchronization module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
--
-- Note:
--  Licensed exclusively to Raid Informatics
------------------------------------------------------------------------

--- Unit frame variables for predicted health valuation.
RDX.RegisterFeature({
	name = "var_pred_health";
	title = i18n("Vars: Predicted Health (ph, pfh, ih)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_ph") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_ph"); state:AddSlot("Var_pfh"); state:AddSlot("FracVar_pfh");
		state:AddSlot("Var_ih"); state:AddSlot("TextData_pheal");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local ph, _, pfh, ih = unit:AllSmartHealth();
local umh = unit:MissingHealth();
local pheal = "";
if umh and umh > 0 then pheal = strcolor(0.75,0,0) .. "-" .. umh; end
if ih and ih > 0 then pheal = strcolor(1,1,1) .. "+" .. ih .. " " .. pheal; end
]]); end);
		-- Event hinting
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_UnitMask("UNIT_HEALTH", mux:GetPaintMask("HEALTH"));
		mux:Event_UnitMask("UNIT_INCOMING_HEALS", mux:GetPaintMask("INCOMING_HEALS"));
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_pred_health" }; end
});

-- only my predicted health

RDX.RegisterFeature({
	name = "var_mypred_health";
	title = i18n("Vars: My Predicted Health (mph, mpfh, mih)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_mph") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_mph"); state:AddSlot("Var_mpfh"); state:AddSlot("FracVar_mpfh");
		state:AddSlot("Var_mih"); state:AddSlot("TextData_mpheal");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local mph, _, mpfh, mih = unit:MySmartHealth();
local mumh = unit:MissingHealth();
local mpheal = "";
if mumh and mumh > 0 then mpheal = strcolor(0.75,0,0) .. "-" .. mumh; end
if mih and mih > 0 then mpheal = strcolor(1,1,1) .. "+" .. mih .. " " .. mpheal; end
]]); end);
		-- Event hinting
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_UnitMask("UNIT_HEALTH", mux:GetPaintMask("HEALTH"));
		mux:Event_UnitMask("UNIT_INCOMING_HEALS", mux:GetPaintMask("INCOMING_HEALS"));
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_mypred_health" }; end
});

--- A unit frame feature that displays a small grid of incoming heals with castbars.

-- Acquire a cell for the inc. heal grid.
function IncHealGrid_AcqCell(grid, dx, dy)
	dx = tonumber(dx) or 20; dy = tonumber(dy) or 6;
	local f = VFLUI.AcquireFrame("Frame");
	VFLUI.StdSetParent(f, grid);
	f:SetHeight(dy); f:SetWidth(dx); f:Show();

	f.bar = VFLUI.AcquireFrame("StatusBar");
	VFLUI.StdSetParent(f.bar, f);
	f.bar:SetPoint("CENTER", f, "CENTER");
	f.bar:SetHeight(dy); f.bar:SetWidth(dx - 2);
	f.bar:SetBackdrop(VFLUI.WhiteBackdrop);
	f.bar:SetBackdropColor(0.3,0.3,0.3,0.4);
	f.bar:SetStatusBarTexture("Interface\\Addons\\RDX\\Skin\\bar_smooth");
	f.bar:SetMinMaxValues(0,1);
	f.bar:Show();

	f.name = VFLUI.CreateFontString(f.bar);
	f.name:SetPoint("CENTER", f.bar, "CENTER");
	f.name:SetHeight(dy); f.name:SetWidth(dx - 2); f.name:Show();
	VFLUI.SetFont(f.name, Fonts.Default, dy);

	f:SetScript("OnUpdate", function(s)
		local dt, intvl = s.time, s.interval;
		if dt then
			dt = dt - GetTime();
			if dt > 0 then
				s.bar:SetValue(1 - dt/intvl);
			else
				s.bar:SetValue(0);
			end
		else
			s.name:SetText(""); s.bar:SetValue(0);
		end
	end);

	f.Destroy = VFL.hook(function(s)
		s:SetScript("OnUpdate", nil);
		s.time = nil; s.interval = nil;
		s.name:Destroy(); s.name = nil;
		s.bar:Destroy(); s.bar = nil;
	end, f.Destroy);

	f.OnDeparent = f.Destroy;

	return f;
end

RDX.RegisterFeature({
	name = "inc_heal_grid"; version = 1;
	title = i18n("Incoming Heal Grid");
	category = i18n("Shaders");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		if state:Slot("Frame_incHealGrid") then return nil; end
		if flg then state:AddSlot("Frame_incHealGrid");	end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_incHealGrid";
		local w,h = tonumber(desc.w), tonumber(desc.h);
		if not w then w = 20; end
		if not h then h = 6; end

		local createCode = [[
local _f = VFLUI.Grid:new(frame);
_f:SetFrameLevel(frame:GetFrameLevel() + (]] .. desc.flOffset .. [[));
_f:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_f:Show();
frame.]] .. objname .. [[ = _f;
]];
		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[=nil;
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		-- Event hinting
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("INCOMING_HEALS");
		mux:Event_UnitMask("UNIT_INCOMING_HEALS", mask);
		mask = bor(mask, 1);

		-- Main paint
		local paintCode = [[
if band(paintmask, ]] .. mask .. [[) ~= 0 then
	local _f = frame.]] .. objname .. [[;
	_f:Size(unit:_CountIncHeals(), 1, IncHealGrid_AcqCell, ]] .. w .. [[, ]] .. h .. [[);
	local i = 1;
	for _,hentry in unit:_IterateIncHeals() do
		local cell = _f:GetCell(i,1);
		cell.bar:SetStatusBarColor(explodeColor(hentry.origin:GetClassColor()));
		cell.name:SetText(string.sub(hentry.origin:GetProperName(), 1, 4));
		cell.time = hentry.expire;
		cell.interval = hentry.expire - hentry.start;
		i = i + 1;
	end
end
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local ed_width, ed_height = RDXUI.GenWidthHeightPortion(ui, desc, state);
		
		local ed_width = VFLUI.LabeledEdit:new(ui, 50); ed_width:Show();
		ed_width:SetText(i18n("Width of bars"));
		if desc and desc.width then ed_width.editBox:SetText(desc.width); end
		ui:InsertFrame(ed_width);

		local ed_height = VFLUI.LabeledEdit:new(ui, 50); ed_height:Show();
		ed_height:SetText(i18n("Height of bars"));
		if desc and desc.height then ed_height.editBox:SetText(desc.height); end
		ui:InsertFrame(ed_height);

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_flOffset = VFLUI.LabeledEdit:new(ui, 50); ed_flOffset:Show();
		ed_flOffset:SetText(i18n("FrameLevel offset"));
		if desc and desc.flOffset then ed_flOffset.editBox:SetText(desc.flOffset); end
		ui:InsertFrame(ed_flOffset);

		function ui:GetDescriptor()
			local a = ed_flOffset.editBox:GetNumber(); if not a then a=0; end a = VFL.clamp(a, -2, 5);
			return { 
				feature = "inc_heal_grid"; version = 1;
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				flOffset = a; 
				anchor = anchor:GetAnchorInfo();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "inc_heal_grid"; version = 1;
			w = 20; h = 6;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPRIGHT", dx = 0, dy = 0}, 
			flOffset = 0
		};
	end;
});
