-- Totem engine
-- OpenRDX
-- (C)2007 Sigg / Rashgarroth eu

-- Patch 2.4
--[[local sig_unit_totemearth_update = RDXEvents:LockSignal("UNIT_CAST_TOTEMEARTH_UPDATE");
local sig_unit_totemair_update = RDXEvents:LockSignal("UNIT_CAST_TOTEMAIR_UPDATE");
local sig_unit_totemwater_update = RDXEvents:LockSignal("UNIT_CAST_TOTEMWATER_UPDATE");
local sig_unit_totemfire_update = RDXEvents:LockSignal("UNIT_CAST_TOTEMFIRE_UPDATE");
local sig_unit_totem_stop = RDXEvents:LockSignal("UNIT_CAST_TOTEM_STOP");

-- METADATA table
earth = {};
air = {};
water = {};
fire = {};

function Logistics.registerTotem(name, element, duration, icon)
	if element == "earth" then
		t = {};
		t.duration = duration;
		t.icon = icon;
		if earth[name] then error("Duplicate totem registration " .. name); end
		earth[name] = t;
	elseif element == "fire" then
		t = {};
		t.duration = duration;
		t.icon = icon;
		if fire[name] then error("Duplicate totem registration " .. name); end
		fire[name] = t;
	elseif element == "water" then
		t = {};
		t.duration = duration;
		t.icon = icon;
		if water[name] then error("Duplicate totem registration " .. name); end
		water[name] = t;
	elseif element == "air" then
		t = {};
		t.duration = duration;
		t.icon = icon;
		if air[name] then error("Duplicate totem registration " .. name); end
		air[name] = t;
	end
	return true;
end;

local earthtic = {};
local firetic = {};
local watertic = {};
local airtic ={};

function Logistics.getTotemEarth()
	local aname, aicon, atimestart, aduration = "", "", 0, 0;
	local ttime = math.modf(GetTime());
	if earthtic.duration and (earthtic.duration > 0) then
		if ttime > earthtic.timestart + earthtic.duration then
			earthtic.duration = 0;
		else
			aname = earthtic.name
			aicon = earthtic.icon;
			atimestart = earthtic.timestart;
			aduration = earthtic.duration;
		end
		
	end
	return aname, aicon, atimestart, aduration;
end;

function Logistics.getTotemAir()
	local aname, aicon, atimestart, aduration = "", "", 0, 0;
	local ttime = math.modf(GetTime());
	if airtic.duration and (airtic.duration > 0) then
		if ttime > airtic.timestart + airtic.duration then
			airtic.duration = 0;
		else
			aname = airtic.name
			aicon = airtic.icon;
			atimestart = airtic.timestart;
			aduration = airtic.duration;
		end
		
	end
	return aname, aicon, atimestart, aduration;
end;

function Logistics.getTotemWater()
	local aname, aicon, atimestart, aduration = "", "", 0, 0;
	local ttime = math.modf(GetTime());
	if watertic.duration and (watertic.duration > 0) then
		if ttime > watertic.timestart + watertic.duration then
			watertic.duration = 0;
		else
			aname = watertic.name
			aicon = watertic.icon;
			atimestart = watertic.timestart;
			aduration = watertic.duration;
		end
		
	end
	return aname, aicon, atimestart, aduration;
end;

function Logistics.getTotemFire()
	local aname, aicon, atimestart, aduration = "", "", 0, 0;
	local ttime = math.modf(GetTime());
	if firetic.duration and (firetic.duration > 0) then
		if ttime > firetic.timestart + firetic.duration then
			firetic.duration = 0;
		else
			aname = firetic.name
			aicon = firetic.icon;
			atimestart = firetic.timestart;
			aduration = firetic.duration;
		end
		
	end
	return aname, aicon, atimestart, aduration;
end;

local function TotemParse(rowlog)
	local totemName = rowlog.a;
	if totemName then
		if earth[totemName] then
			earthtic.name = totemName;
			earthtic.icon = earth[totemName].icon;
			earthtic.timestart = math.modf(GetTime());
			earthtic.duration = earth[totemName].duration;
			sig_unit_totemearth_update:Raise(RDXPlayer);
		elseif air[totemName] then
			airtic.name = totemName;
			airtic.icon = air[totemName].icon;
			airtic.timestart = math.modf(GetTime());
			airtic.duration = air[totemName].duration;
			sig_unit_totemair_update:Raise(RDXPlayer);
		elseif water[totemName] then
			watertic.name = totemName;
			watertic.icon = water[totemName].icon;
			watertic.timestart = math.modf(GetTime());
			watertic.duration = water[totemName].duration;
			sig_unit_totemwater_update:Raise(RDXPlayer);
		elseif fire[totemName] then
			firetic.name = totemName;
			firetic.icon = fire[totemName].icon;
			firetic.timestart = math.modf(GetTime());
			firetic.duration = fire[totemName].duration;
			sig_unit_totemfire_update:Raise(RDXPlayer);
		elseif (totemName == i18n("Totemic Call")) then
			earthtic.duration = 0;
			airtic.duration = 0;
			watertic.duration = 0;
			firetic.duration = 0;
			sig_unit_totem_stop:Raise(RDXPlayer);
		end
	end
end;]]

----------------------------------------------------------
-- INIT
----------------------------------------------------------
--[[
RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	--WoWEvents:Bind("CHAT_MSG_SPELL_SELF_BUFF",nil,TotemParse);
	--RPC_Group:Bind("omniLog", TotemParse);
	local pp = {};
	pp.oevent = function(...)
		local rowlog = select(3, ...);
		if (rowlog.y == 20) then TotemParse(rowlog); end
	end
	OmniEvents:Bind("LOG_ROW_ADDED", pp, pp.oevent, "Omnitotem");
end);]]

-------------------------------------------------------------------
-- TOTEM UNITFRAME VARIABLES
-------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Variables: Totem Info";
	title = i18n("Vars: Totems Info");
	category =  i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_btotemearth");
		state:AddSlot("TextData_totemearth_name");
		state:AddSlot("TimerVar_totemearth");
		state:AddSlot("TexVar_totemearth_icon");
		state:AddSlot("BoolVar_btotemair");
		state:AddSlot("TextData_totemair_name");
		state:AddSlot("TimerVar_totemair");
		state:AddSlot("TexVar_totemair_icon");
		state:AddSlot("BoolVar_btotemwater");
		state:AddSlot("TextData_totemwater_name");
		state:AddSlot("TimerVar_totemwater");
		state:AddSlot("TexVar_totemwater_icon");
		state:AddSlot("BoolVar_btotemfire");
		state:AddSlot("TextData_totemfire_name");
		state:AddSlot("TimerVar_totemfire");
		state:AddSlot("TexVar_totemfire_icon");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local smask = mux:GetPaintMask("TOTEM_UPDATE");
		local umask = mux:GetPaintMask("ENTERING_WORLD");
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local btotemfire, totemfire_name, totemfire_start, totemfire_duration, totemfire_icon = GetTotemInfo(1);
local btotemearth, totemearth_name, totemearth_start, totemearth_duration, totemearth_icon = GetTotemInfo(2);
local btotemwater, totemwater_name, totemwater_start, totemwater_duration, totemwater_icon = GetTotemInfo(3);
local btotemair, totemair_name, totemair_start, totemair_duration, totemair_icon = GetTotemInfo(4);
]]);
		end);
		
		mux:Event_UnitMask("UNIT_TOTEM_UPDATE", smask);
		mux:Event_UnitMask("UNIT_ENTERING_WORLD", umask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variables: Totem Info" }; end;
});


