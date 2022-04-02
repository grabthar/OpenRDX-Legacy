-- Cooldowns.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED CONTENT SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Cooldown handling.

-- Imports
local floor = math.floor;

-- Cooldown registry
local cds = {};
-- My cooldowns
local mycds = {};

------------------------------------------
-- Cooldown set core
--
-- Three set classes:
-- Cooldown possible (*, cd) - member iff some data on the given CD has been received
-- Cooldown available (cd) - member iff the given CD is available
-- Cooldown unavailable(cd) - member iff the given CD is unavailable.
------------------------------------------
local cdp, cda, cdu = {}, {}, {};

local function GetCDSet(cat, cd)
	local x = cat[cd];
	if x then return x; end
	ty = "CooldownP";
	if(cat == cda) then
		ty = "CooldownA";
	elseif(cat == cdu) then
		ty = "CooldownU";
	end
	x = RDX.NominativeSet:new();
	x.name = ty .. "<" .. cd .. ">";
	cat[cd] = x; RDX.RegisterSet(x);
	return x;
end
GetCDSet(cdp, "*");

--------------------------
-- Cooldown RPC input handler
--------------------------
local function SetCooldownValue(unit, ucd, cd, cRem, cDur)
	if not cds[cd] then return; end -- Security: don't allow pollution with cooldowns that don't exist.
	local n = unit.name; if not n then return; end

	-- Get the cooldown entry.
	local x = ucd[cd];
	if not x then
		x = {
			duration = -1;
			remaining = -1;
			estExp = -1;
		};
		ucd[cd] = x;
		-- If it didn't exist, make it and add us to possible CDs.
		GetCDSet(cdp, "*"):AddName(n);
		GetCDSet(cdp, cd):AddName(n);
	end

	-- Get old data
	local oldrem = x.remaining;
	-- If the state of the CD has changed, notify.
	if (cRem == 0) and (oldrem ~= 0) then
		RDXEvents:Dispatch("UNIT_COOLDOWN_AVAIL", unit, cd);
		x.estExp = 0;
	elseif(cRem > 0) and (oldrem < 1) then
		RDXEvents:Dispatch("UNIT_COOLDOWN_UNAVAIL", unit, cd);
		x.estExp = floor(GetTime()) + cRem + 1;
	elseif(cRem < 0) then -- Unknown cooldown value.
		GetCDSet(cda, cd):RemoveName(n);
		GetCDSet(cdu, cd):RemoveName(n);
		x.estExp = -1;
	end
	-- Update data
	x.duration = cDur; x.remaining = cRem
end

-- The CDX protocol
-- string format: (cid currentTime maxTime) ...
-- e.g. "ss 1203 1800 reb 902 1800" etc.
local function RPC_CDX(ci, str)
	if type(str) ~= "string" then return; end
	local unit = RPC.GetSenderUnit(ci); if not unit then return; end
	local ucd = unit:GetNField("cooldowns");
	if not ucd then ucd = {}; unit:SetNField("cooldowns", ucd); end
	for cd,rem,dur in str:gmatch("(%w+) ([%-%d]+) ([%-%d]+)") do
		rem = tonumber(rem); dur = tonumber(dur);
		if rem and dur then SetCooldownValue(unit, ucd, cd, rem, dur); end
	end
end
RPC_Group:Bind("cdx", RPC_CDX);

RDXEvents:Bind("UNIT_COOLDOWN_AVAIL", nil, function(unit, cd)
	local n = unit.name; if not n then return; end
	GetCDSet(cda, cd):AddName(n);
	GetCDSet(cdu, cd):RemoveName(n);
end);

RDXEvents:Bind("UNIT_COOLDOWN_UNAVAIL", nil, function(unit, cd)
	local n = unit.name; if not n then return; end
	GetCDSet(cda, cd):RemoveName(n);
	GetCDSet(cdu, cd):AddName(n);
end);

--------------------------------------
-- Cooldown RPC output
--------------------------------------

--- Broadcast the value for a cooldown directly.
function Logistics.BroadcastCooldown(name, rem, dur)
	rem = tonumber(rem); dur = tonumber(dur);
	if (not rem) or (not dur) then return; end
	rem = floor(rem); dur = floor(dur);
	RPC_Group:Invoke("cdx", name .. " " .. rem .. " " .. dur);
end

--- Broadcast all possible cooldowns.
local function BroadcastCDs()
	local i, str = 0, "";
	for name,cdef in pairs(mycds) do
		i=i+1;
		local rem, dur = cdef:GetValue();
		rem = floor(rem); dur = floor(dur);
		if(dur < 1) then dur = -1; end
		str = str .. name .. " " .. rem .. " " .. dur .. " ";
	end
	if i>0 then 
		RPC_Group:Invoke("cdx", str); 
	end
end

-------------------------------------
-- UI/Exports
-------------------------------------
local cdmnu = {};
local cdmnu_star = { { text = "(any)", value = "*" } };
local function _AddCDToMenu(value, text)
	local t = { text = text, value = value };
	table.insert(cdmnu, t);
	table.insert(cdmnu_star, t);
end

RDX.RegisterSetClass({
	name = "cd_poss";
	title = "Cooldown Possible";
	GetUI = function(parent, desc)
		local c_text, c_value = "(any)", "*";
		if desc and desc.cd and desc.cd ~= "*" and cds[desc.cd] then
			c_value = desc.cd; c_text = cds[desc.cd].title;
		end
		local ui = VFLUI.Dropdown:new(parent, function() return cdmnu_star; end);
		ui:RawSetSelection(c_text, c_value); ui:Show();
		function ui:GetDescriptor()
			local _,val = self:GetSelection();
			return { class = "cd_poss", cd = val };
		end
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil end, ui.Destroy);
		return ui;
	end;
	FindSet = function(desc)
		if (not desc) or (not desc.cd) then return nil; end
		return GetCDSet(cdp, desc.cd);
	end;
});

RDX.RegisterSetClass({
	name = "cd_avail";
	title = "Cooldown Available";
	GetUI = function(parent, desc)
		local c_text, c_value = "", "";
		if desc and desc.cd and cds[desc.cd] then
			c_value = desc.cd; c_text = cds[desc.cd].title;
		end
		local ui = VFLUI.Dropdown:new(parent, function() return cdmnu; end);
		ui:RawSetSelection(c_text, c_value); ui:Show();
		function ui:GetDescriptor()
			local _,val = self:GetSelection();
			return { class = "cd_avail", cd = val };
		end
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil end, ui.Destroy);
		return ui;
	end;
	FindSet = function(desc)
		if (not desc) or (not desc.cd) then return nil; end
		return GetCDSet(cda, desc.cd);
	end;
});

RDX.RegisterSetClass({
	name = "cd_unavail";
	title = "Cooldown Unavailable";
	GetUI = function(parent, desc)
		local c_text, c_value = "", "";
		if desc and desc.cd and cds[desc.cd] then
			c_value = desc.cd; c_text = cds[desc.cd].title;
		end
		local ui = VFLUI.Dropdown:new(parent, function() return cdmnu; end);
		ui:RawSetSelection(c_text, c_value); ui:Show();
		function ui:GetDescriptor()
			local _,val = self:GetSelection();
			return { class = "cd_unavail", cd = val };
		end
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil end, ui.Destroy);
		return ui;
	end;
	FindSet = function(desc)
		if (not desc) or (not desc.cd) then return nil; end
		return GetCDSet(cdu, desc.cd);
	end;
});

------------------------------------------
-- Cooldown registration
--
-- Fields of a cooldown:
-- name (string) - the canonical name of the cooldown
-- title (string, i18n) - the title of the cooldown
-- icon (string) - the texture file for the cooldown
-- Initialize (function nil->nil) - Called when RDX initializes; do prep work
--   here.
-- IsPossible (function nil->boolean) - Return TRUE iff the player has the
--   associated spell/ability.
-- Activate (function nil->nil) - Called to notify your application that the
--   cooldown is being monitored.
-- GetValue (function nil->(number, number)) - Returns the number of seconds
--   left on the cooldown, followed by the length of the cooldown in seconds.
--   Should return "0" for the first argument if the cooldown is currently
--   available, "-1" for unknown.
-- CooldownUsed (function nil->nil) - Generic detection routine that fires
--   when the system detects the cooldown has been used.
------------------------------------------
function Logistics.RegisterCooldown(tbl)
	if (type(tbl) ~= "table") then error("Usage: RegisterCooldown(tbl)"); end
	if (not tbl.name) or (not tbl.title) then error("Missing cooldown name"); end
	if cds[tbl.name] then error("Duplicate cooldown registration " .. tbl.name); end
	cds[tbl.name] = tbl;
	_AddCDToMenu(tbl.name, tbl.title);
	return true;
end

function Logistics.GetCooldownInfo(name)
	if not name then return nil; end
	return cds[name];
end

local ic_un = "Interface\\InventoryItems\\WoWUnknownItem01.blp";

function Logistics.GetCooldownIcon(name)
	if not name then return nil; end
	return cds[name].icon or ic_un;
end

-----------------------------------------
-- Cooldown initialization
-----------------------------------------
RDXEvents:Bind("INIT_DEFERRED", nil, function()
	-- For each registered cooldown...
	for k,cd in pairs(cds) do
		cd:Initialize(); cd.Initialize = nil;
		-- If possible for this character...
		if cd:IsPossible() then
			mycds[k] = cd; -- Add to my cooldowns
			cd:Activate(); -- Activate.
		end
	end

	-- Start periodic broadcasts
	VFL.AdaptiveSchedule(nil, 60, BroadcastCDs);
end);

-----------------------------------
-- EXTRA API
-----------------------------------
--- Generic unknown value function.
function Logistics.UnknownCooldown() return -1,-1; end

-----------------------------------
-- SPELL-DRIVEN COOLDOWNS
-----------------------------------
local sdc = {};

local function UpdateSDC(cdef)
	Logistics.BroadcastCooldown(cdef.name, cdef:GetValue());
end

local function ActivateSDC(cdef)
	local rem, dur = cdef:GetValue();
	if rem > 0 then
		if cdef._localSched then
			VFL.ZMUnschedule(cdef._localSched); cdef._localSched = nil;
		end
		cdef._localSched = VFL.ZMSchedule(rem + 1.5, function()
			UpdateSDC(cdef);
		end);
	end
	Logistics.BroadcastCooldown(cdef.name, rem, dur);
end

WoWEvents:Bind("UNIT_SPELLCAST_SUCCEEDED", nil, function()
	if arg1 ~= "player" then return; end
	local cdef = sdc[arg2];
	if cdef then
		cdef:CooldownUsed();
		-- BUGFIX: Delay for 1 second here so that WoW "figures out" that the cooldown has been used.
		VFL.ZMSchedule(1, function()
			ActivateSDC(cdef);
		end);
	end
end);

--- Externally register a spell for spellcast_succeeded notification.
function Logistics._RegisterForUSS(cdef, spell)
	sdc[spell] = cdef;
end

--- Standard spell-driven cooldowns can use this boilerplate code, which will automatically
-- drive them.
function Logistics.RegisterSpellBasedCooldown(name, spell, maxv, icon)
	local spell_id = nil;
	maxv = VFL.clamp(maxv, 1, 1000000);
	local cd = {
		name = name;
		title = spell;
		icon = icon;
		IsPossible = function(self)
			spell_id = RDXSS.GetBestSpellID(spell);
			if spell_id then 
				Logistics._RegisterForUSS(self, spell);
				self.GetValue = function()
					local s,d = GetSpellCooldown(spell_id, BOOKTYPE_SPELL);
					if s>0 and d>1 then
						maxv = d;
						return VFL.clamp(d-(GetTime()-s), 0, 1000000), d;
					else
						return 0, maxv;
					end
				end
				return true;
			end
		end;
		Initialize = VFL.Noop;
		Activate = VFL.Noop;
		CooldownUsed = VFL.Noop;
		GetValue = Logistics.UnknownCooldown;
	};
	Logistics.RegisterCooldown(cd);
	return cd;
end

-----------------------------------
-- QUASISPELL COOLDOWNS
-- Can be used for items that trigger SPELLCAST_SUCCEEDED.
-----------------------------------
function Logistics.RegisterQuasiSpellCooldown(name, cdTitle, spell, maxv, icon)
	Logistics.RegisterCooldown({
		name = name;
		title = cdTitle;
		icon = icon;
		_timer = -1;
		Initialize = function(self)
			Logistics._RegisterForUSS(self, spell);
		end;
		IsPossible = VFL.Nil;
		Activate = VFL.Noop;
		CooldownUsed = function(self)
			self._timer = GetTime() + maxv;
		end;
		GetValue = function(self)
			if self._timer < 0 then
				return -1,maxv;
			else
				return VFL.clamp(self._timer - GetTime(), 0, maxv), maxv;
			end
		end;
	});
end

-----------------------------------------------
-- COOLDOWN VARIABLES
-- Allows unit frames to be constructed that display a cooldown value.
-----------------------------------------------
RDX.RegisterFeature({
	name = "Variables: Cooldown Info";
	title = "Vars: Cooldown Info";
	category =  i18n("Variables: Unit Status");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)		
		if not desc then VFL.AddError(errs, i18n( "No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if not cds[desc.cd or ""] then VFL.AddError(errs,  i18n("Invalid cooldown.")); return nil;	end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("BoolVar_" .. desc.name .. "_avail");
		state:AddSlot("FracVar_" .. desc.name .. "_frac");
		state:AddSlot("Var_" .. desc.name .. "_time");
		state:AddSlot("Txt_" .. desc.name .. "_name");
		state:AddSlot("Txt_" .. desc.name .. "_timeSMS");
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- On closure, acquire the set locally
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode("local " .. desc.name .. " = RDX.FindSet(" .. Serialize(desc.set) .. ");");
		end);
		-- On paint preamble, create flag and grade variables
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[_avail, ]] .. desc.name .. [[_frac, ]] .. desc.name .. [[_time, nd, ne, ]] .. desc.name .. [[_name = nil, 0, 0, unit:GetNField("cooldowns"), 0, "";
if nd then nd = nd[']] .. desc.cd .. [[']; end
if nd then
	ne = nd.estExp;
	]] .. desc.name .. [[_name = "]] .. desc.cd .. [[";
	if ne == 0 then
		]] .. desc.name .. [[_avail = true;
		]] .. desc.name .. [[_frac = 1;
	elseif ne > 0 then
		]] .. desc.name .. [[_time = VFL.clamp(ne - GetTime(), 0, 10000000);
		]] .. desc.name .. [[_frac = 1 - VFL.clamp(]] .. desc.name .. [[_time / nd.duration, 0, 1);
	end
	]] .. desc.name .. [[_timeSMS = VFL.Time.FormatSmartMinSec(]] .. desc.name .. [[_time);
end
]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText("Variable Name");
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local cd = VFLUI.Dropdown:new(parent, function() return cdmnu; end); cd:Show();
		ui:InsertFrame(cd);
		local c_text, c_value = "", "";
		if desc and desc.cd and cds[desc.cd] then c_value = desc.cd; c_text = cds[desc.cd].title; end
		cd:RawSetSelection(c_text, c_value);

		function ui:GetDescriptor()
			local _,val = cd:GetSelection();
			return {
				feature = "Variables: Cooldown Info"; name = name.editBox:GetText(); cd = val;
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Variables: Cooldown Info"; name = "cd"; };
	end;
});

--- Unit frame cooldown icon by Sigg

RDX.RegisterFeature({
	name = "tex_cooldown";
	title = i18n("Cooldown Icon");
	deprecated = true;
	category = i18n("Textures");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		-- Verify our owner frame exists
		if (not desc.owner) or ((desc.owner ~= "Base") and (not state:Slot("Subframe_" .. desc.owner))) then
			VFL.AddError(errs, i18n("Owner frame does not exist.")); return nil;
		end
		if not cds[desc.cd] then 
			VFL.AddError(errs,  i18n("Invalid cooldown.")); return nil;
		end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
	local objname = "Frame_" .. desc.name;

		------------------ On frame creation
		local createCode = [[
local _t = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.]] .. objname .. [[ = _t;
_t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_t:SetWidth(]] .. desc.w .. [[); _t:SetHeight(]] .. desc.h .. [[);
_t:SetVertexColor(1,1,1,1);
_t:SetTexture(Logistics.GetCooldownIcon("]] .. desc.cd .. [["));
_t:Hide();
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

		------------------ On frame destruction.
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode([[
VFLUI.ReleaseRegion(frame.]] .. objname .. [[);
frame.]] .. objname .. [[ = nil;
]]); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.]] .. objname .. [[:Hide();
]]); end);

		------------------ On paint.
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[
local nd, ne = unit:GetNField("cooldowns"), 0;
if nd then nd = nd[']] .. desc.cd .. [[']; end
if nd then
	ne = nd.estExp;
	if ne == 0 then
		frame.]] .. objname .. [[:Show();
	else
		frame.]] .. objname .. [[:Hide();
	end
else
	frame.]] .. objname .. [[:Hide();
end

]]); end);
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Drawlayer
		local er = RDXUI.EmbedRight(ui, i18n("Draw layer:"));
		local drawLayer = VFLUI.Dropdown:new(er, RDXUI.DrawLayerDropdownFunction);
		drawLayer:SetWidth(100); drawLayer:Show();
		if desc and desc.drawLayer then drawLayer:SetSelection(desc.drawLayer); else drawLayer:SetSelection("ARTWORK"); end
		er:EmbedChild(drawLayer); er:Show();
		ui:InsertFrame(er);

		-- Anchor
		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);
		
		-- CD
		local cd = VFLUI.Dropdown:new(parent, function() return cdmnu; end); cd:Show();
		ui:InsertFrame(cd);
		local c_text, c_value = "", "";
		if desc and desc.cd and cds[desc.cd] then c_value = desc.cd; c_text = cds[desc.cd].title; end
		cd:RawSetSelection(c_text, c_value);
		
		function ui:GetDescriptor()
			local _,val = cd:GetSelection();
			return { 
				feature = "tex_cooldown", name = ed_name.editBox:GetText(), owner = owner:GetSelection();
				drawLayer = drawLayer:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				cd = val;
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "tex_cooldown", name = "cdi", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
		};
	end;
});
