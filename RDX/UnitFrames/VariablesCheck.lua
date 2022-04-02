-- VariablesCheck.lua
-- Boolean variables

--------------------------
-- Single-unit status variables
--------------------------
RDX.RegisterFeature({
	name = "var_isnpc"; title = i18n("Var: NPC?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isnpc");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local isnpc = (not UnitIsPlayer(uid));
]]);
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isnpc" }; end
});

RDX.RegisterFeature({
	name = "var_incombat"; title = i18n("Var: Combat?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_incombat");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local incombat = UnitAffectingCombat(uid);
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_incombat" }; end
});

RDX.RegisterFeature({
	name = "var_ininn"; title = i18n("Var: Inn?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_ininn");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local ininn = IsResting();
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_ininn" }; end
});

RDX.RegisterFeature({
	name = "var_isDeath"; title = i18n("Var: Death?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isDeath");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local isDeath = UnitIsDead(uid);
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isDeath" }; end
});

RDX.RegisterFeature({
	name = "var_isGhost"; title = i18n("Var: Ghost?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isGhost");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local isGhost = UnitIsGhost(uid);
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isGhost" }; end
});

RDX.RegisterFeature({
	name = "var_inInstance"; title = i18n("Var: Instance?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_inInstance");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local inInstance = true;
local posX = GetPlayerMapPosition(uid);
if posX and (posX > 0) then inInstance = false; end
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_inInstance" }; end
});

RDX.RegisterFeature({
	name = "var_tapped"; title = i18n("Var: Tapped?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_tapped");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local tapped = UnitIsTapped(uid) and (not UnitIsTappedByPlayer(uid));
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_tapped" }; end
});

RDX.RegisterFeature({
	name = "var_existed"; title = i18n("Var: Existed?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_existed");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local existed = UnitExists(uid);
if existed then existed = true; else existed = false; end
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_existed" }; end
});

RDX.RegisterFeature({
	name = "var_targetexisted"; title = i18n("Var: Target Existed?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_targetexisted");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local targetexisted = UnitExists("target");
if targetexisted then targetexisted = true; else targetexisted = false; end
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("TARGET");
		mux:Event_UnitMask("UNIT_TARGET", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_targetexisted" }; end
});

RDX.RegisterFeature({
	name = "var_inrange"; title = i18n("Var: InRange?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_inRange");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local inRange = UnitInRange(uid);
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("RANGED");
		mux:Event_UnitMask("UNIT_RANGED", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_inrange" }; end
});

RDX.RegisterFeature({
	name = "var_isExhaustion"; title = i18n("Var: IsExhaustion?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isExhaustion");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local nbexh, isExhaustion = GetXPExhaustion(), false;
if nbexh then isExhaustion = true; end
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("XP");
		mux:Event_UnitMask("UNIT_XP_UPDATE", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isExhaustion" }; end
});

RDX.RegisterFeature({
	name = "var_isElite"; title = i18n("Var: IsElite?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isElite");
		state:AddSlot("BoolVar_isNotElite");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local isElite, isNotElite = false, true;
local strclasstype = UnitClassification(uid);
if (strclasstype ~= "normal") then isElite = true; isNotElite = false; end
]]);
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isElite" }; end
});

-- Xenios

RDX.RegisterFeature({
	name = "var_isEnemy"; title = i18n("Var: Enemy?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isEnemy");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local isEnemy = UnitIsEnemy(uid,"player");
]]);
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isEnemy" }; end
});

-- Xenios

RDX.RegisterFeature({
	name = "var_isEven"; title = i18n("Var: Even Group?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isEven");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local isEven = (unit:GetGroup() % 2 == 0);
]]);
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isEven" }; end
});

RDX.RegisterFeature({
	name = "var_isMaxHealth"; title = i18n("Var: IsMaxHealth?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_ismaxhealth");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local ismaxhealth = false;
if unit:Health() == unit:MaxHealth() then ismaxhealth = true end;
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("HEALTH");
		mux:Event_UnitMask("UNIT_HEALTH", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isMaxHealth" }; end
});

RDX.RegisterFeature({
	name = "var_isMaxPower"; title = i18n("Var: IsMaxPower?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_ismaxpower");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local ismaxpower = false;
if unit:Power() == unit:MaxPower() then ismaxpower = true end;
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("POWER");
		mux:Event_UnitMask("UNIT_POWER", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isMaxPower" }; end
});

-- Cidan

RDX.RegisterFeature({
	name = "var_israidpartyleader"; title = i18n("Var: Raid/Party Leader?"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_israidpartyleader");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local israidpartyleader = nil;
if GetNumRaidMembers() > 0 then
	_,israidpartyleader = GetRaidRosterInfo(RDX.UIDToNumber(uid));
	if israidpartyleader < 2 then israidpartyleader = nil; end
else
	israidpartyleader = UnitIsPartyLeader(uid);
end
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("FLAGS");
		mux:Event_UnitMask("UNIT_FLAGS", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_israidpartyleader" }; end
});

-- Hardware event variables
RDX.RegisterFeature({
	name = "var_isMouseOver"; title = i18n("Var: Is Mouse Over?"); category = i18n("Variables: Hardware Events");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isMouseOver");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local isMouseOver = MouseIsOver(frame);
]]);
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isMouseOver" }; end
});

RDX.RegisterFeature({
	name = "var_isShiftDown"; title = i18n("Var: Is Shift Held Down?"); category = i18n("Variables: Hardware Events");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isShiftDown");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local isShiftDown = IsShiftKeyDown();
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("HARDWARE");
		mux:Event_UnitMask("MODIFIER_STATE_CHANGED", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isShiftDown" }; end
});

RDX.RegisterFeature({
	name = "var_isControlDown"; title = i18n("Var: Is Control Held Down?"); category = i18n("Variables: Hardware Events");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isControlDown");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local isControlDown = IsControlKeyDown();
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("HARDWARE");
		mux:Event_UnitMask("MODIFIER_STATE_CHANGED", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isControlDown" }; end
});

RDX.RegisterFeature({
	name = "var_isAltDown"; title = i18n("Var: Is Alt Held Down?"); category = i18n("Variables: Hardware Events");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("BoolVar_isAltDown");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local isAltDown = IsAltKeyDown();
]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("HARDWARE");
		mux:Event_UnitMask("MODIFIER_STATE_CHANGED", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_isAltDown" }; end
});