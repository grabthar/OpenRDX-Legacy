-- Variables.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Variables that can be used in unit frames.

--- Subroutine to check a variable name for validity.
local reservedWords = {};
reservedWords["frame"] = true;
reservedWords["unit"] = true;
reservedWords["uid"] = true;
reservedWords["true"] =  true;
reservedWords["false"] = true;
reservedWords["nil"] = true;

function RDX._CheckVariableNameValidity(name, state, errs)
	if not type(name) == "string" then VFL.AddError(errs, i18n("Missing variable name.")); return nil; end
	if type(name) == "number" then VFL.AddError(errs, i18n("Variable name must be alpha.")); return nil; end
	if not string.find(name, "^%w+$") then
		VFL.AddError(errs, i18n("Invalid characters in variable name")); return nil;
	end
	if string.sub(name,1,1) == "_" then VFL.AddError(errs, i18n("Name may not begin with an underscore.")); return nil; end
	if reservedWords[name] then VFL.AddError(errs, i18n("The name '") .. name .. i18n("' is a reserved word.")); return nil; end
	if state:Slot("Var_" .. name) then
		VFL.AddError(errs, i18n("The name '") .. name .. i18n("' is already in use.")); return nil; 
	end
	return true;
end

function RDX._AddReservedVariableName(name)
	reservedWords[name] = true;
end

------------------------ Baseline status flags
RDX.RegisterFeature({
	name = "Variables: Status Flags (dead, ld, feigned)";
	title = i18n("Vars: Status Flags (dead, ld, feigned)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_dead") or state:Slot("Var_ld") or state:Slot("Var_feigned") or state:Slot("Var_incap") then 
			return nil; 
		end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_dead"); state:AddSlot("BoolVar_dead");
		state:AddSlot("Var_ld"); state:AddSlot("BoolVar_ld");
		state:AddSlot("Var_feigned"); state:AddSlot("BoolVar_feigned");
		state:AddSlot("Var_incap"); state:AddSlot("BoolVar_incap");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local feigned, dead, ld, incap = nil, nil, nil, nil;
if unit then feigned = unit:IsFeigned(); end
dead = UnitIsDeadOrGhost(uid) and (not feigned);
ld = (not UnitIsConnected(uid));
incap = (feigned or dead or ld);
]]); 
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("HEALTH");
		mux:Event_UnitMask("UNIT_HEALTH", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variables: Status Flags (dead, ld, feigned)" }; end
});

--------------------------------------- fh/fm
RDX.RegisterFeature({
	name = "Variable: Fractional health (fh)";
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_fh") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_fh");
		state:AddSlot("FracVar_fh");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local fh = unit:FracHealth();
]]); 
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("HEALTH");
		mux:Event_UnitMask("UNIT_HEALTH", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variable: Fractional health (fh)" }; end
});

RDX.RegisterFeature({
	name = "Variable: Fractional mana (fm)";
	title = "Variable: Fractional power (fm)";
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_fm") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_fm");
		state:AddSlot("FracVar_fm");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local fm = unit:FracPower();
]]); 
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("POWER");
		mux:Event_UnitMask("UNIT_POWER", mask);
	end;

	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variable: Fractional mana (fm)" }; end
});

-------------------------------------------------------------------
-- Unit In Sort/Unit In Set variables
-------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Variable: Unit In Sort";
	category = i18n("Variables: Sorts and Sets");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)		
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		local _,_,_,ty = RDXDB.GetObjectData(desc.sort);
		if (not ty) or (not string.find(ty, "Sort$")) or (not RDXDB.GetObjectInstance(desc.sort)) then
			VFL.AddError(errs, i18n("Invalid sort pointer.")); return nil;
		end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("BoolVar_" .. desc.name .. "_flag");
		state:AddSlot("FracVar_" .. desc.name .. "_grade");
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- On closure, acquire the set locally
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[ = RDXDB.GetObjectInstance("]] .. desc.sort .. [[");
]]);
		end);
		-- On paint preamble, create flag and grade variables
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[_idx, ]] .. desc.name .. [[_flag, ]] .. desc.name .. [[_grade = ]] .. desc.name .. [[:IndexOfUID(uid), false, 0;
if not  ]] .. desc.name .. [[_idx then
	]] .. desc.name .. [[_idx = 0;
elseif ]] .. desc.name .. [[_idx <= ]] .. desc.order .. [[ then
	]] .. desc.name .. [[_flag = true;
]]);
			if desc.order ~= 1000 then
				-- Case 1: grade = pos / fixed number
				code:AppendCode(desc.name .. [[_grade = (]] .. desc.name .. [[_idx - 1) / (]] .. desc.order .. [[);
]]);
			else
				-- Case 2: grade = pos / sortsize
				code:AppendCode(desc.name .. [[_grade = (]] .. desc.name .. [[_idx - 1) / (]] .. desc.name .. [[:GetSize());
]]);
			end
			code:AppendCode([[end
]]);
		end);
		-- Event hint: update on sort.
		local sort = RDXDB.GetObjectInstance(desc.sort);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_SigUpdateMaskAll(sort, 2); -- mask 2 = generic repaint
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local sort = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "Sort$")); end);
		sort:SetLabel(i18n("Sort")); sort:Show();
		if desc and desc.sort then sort:SetPath(desc.sort); end
		ui:InsertFrame(sort);

		local chk_order = VFLUI.Checkbox:new(ui); chk_order:Show();
		local order = VFLUI.Edit:new(chk_order); order:Show();
		order:SetHeight(25); order:SetWidth(50); order:SetPoint("RIGHT", chk_order, "RIGHT");
		chk_order.Destroy = VFL.hook(function() order:Destroy(); end, chk_order.Destroy);
		chk_order:SetText(i18n("Limit size of sort to:"));
		if desc and desc.order and (desc.order ~= 1000) then 
			chk_order:SetChecked(true); 
			order:SetText(desc.order);
		else 
			chk_order:SetChecked();
			order:SetText("1");
		end
		ui:InsertFrame(chk_order);
	
		function ui:GetDescriptor()
			local ord = 1000;
			if chk_order:GetChecked() then ord = VFL.clamp(order:GetNumber(), 1, 40); end
			return {
				feature = "Variable: Unit In Sort";
				name = name.editBox:GetText(); sort = sort:GetPath();
				order = ord;
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Variable: Unit In Sort"; name = "unitInSort"; order = 1000; };
	end;
});

RDX.RegisterFeature({
	name = "Variable: Unit In Set";
	category = i18n("Variables: Sorts and Sets");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)		
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if not RDX.FindSet(desc.set) then
			VFL.AddError(errs, i18n("Invalid set pointer."));
			return nil;
		end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("BoolVar_" .. desc.name .. "_flag");
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- On closure, acquire the set locally
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[ = RDX.FindSet(]] .. Serialize(desc.set) .. [[);
]]);
		end);
		-- On paint preamble, create flag and grade variables
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
if not ]] .. desc.name .. [[:IsOpen() then ]] .. desc.name .. [[:Open(); end
local ]] .. desc.name .. [[_flag = ]] .. desc.name .. [[:IsMember(unit);
]]);
		end);
		-- Event hint: update on sort.
		local set = RDX.FindSet(desc.set);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_SetDeltaMask(set, 2); -- mask 2 = generic repaint
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local sf = RDX.SetFinder:new(ui); sf:Show();
		ui:InsertFrame(sf); 
		if desc and desc.set then sf:SetDescriptor(desc.set); end

		function ui:GetDescriptor()
			return {
				feature = "Variable: Unit In Set";
				name = name.editBox:GetText(); 
				set = sf:GetDescriptor();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Variable: Unit In Set"; name = "unitInSet"; };
	end;
});

--------------------------------------------------
-- Spellcast Info vars (castbar, spell name)
--------------------------------------------------
RDX.RegisterFeature({
	name = "Variables: Spellcast";
	title = "Vars: Spellcast";
	deprecated = true;
	invisible = true;
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("FracVar_spellPerc");
		state:AddSlot("TimerVar_spell");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local spellName,x,_,_,spellTime,spellPerc = UnitCastingInfo(uid);
if not spellName then
	spellName,x,_,_,spellTime,spellPerc = UnitChannelInfo(uid);
end
if spellName then
	spellPerc = spellPerc / 1000;
	x = spellPerc - (spellTime / 1000);
	spellTime = spellPerc - GetTime();
	spellPerc = 1 - VFL.clamp(spellTime / x, 0, 1);
else
	spellName = ""; spellTime = 0; spellPerc = 0;
end
]]);
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variables: Spellcast" }; end
});

RDX.RegisterFeature({
	name = "var_spellinfo";
	title = i18n("Vars: Spell Info"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("TimerVar_spell");
		state:AddSlot("BoolVar_spell_channeled");
		state:AddSlot("BoolVar_spell_casting");
		state:AddSlot("BoolVar_spell_castingOrChanneled");
		state:AddSlot("TextData_spell_name_rank");
		state:AddSlot("TextData_vertical_spell_name_rank");
		state:AddSlot("TexVar_spell_icon");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local umask = mux:GetPaintMask("CAST_TIMER_UPDATE");
		local smask = mux:GetPaintMask("CAST_TIMER_STOP");
		
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local spell_channeled, spell_casting, spell_castingOrChanneled, spell_name_rank, vertical_spell_name_rank = nil, nil, nil, "", "";
local spell_name, spell_rank, spell_fullname, spell_icon, spell_start, spell_duration = UnitCastingInfo(uid);
if not spell_name then
	spell_name, spell_rank, spell_fullname, spell_icon, spell_start, spell_duration = UnitChannelInfo(uid);
	if spell_name then
		spell_channeled = true;
		spell_castingOrChanneled = true;
	end
else
	spell_casting = true;
	spell_castingOrChanneled = true;
end
if spell_name and (spell_channeled or (band(paintmask, ]] .. smask .. [[) == 0)) then
	spell_start = spell_start / 1000;
	spell_duration = (spell_duration / 1000) - spell_start;
else
	spell_casting = nil; spell_casting = nil; spell_castingOrChanneled = nil;
	spell_name = ""; spell_start = 0; spell_duration = 0;
end
if spell_name and spell_name ~= "" then
	spell_name_rank = spell_name;
	vertical_spell_name_rank = spell_name;
	if spell_rank and spell_rank ~= "" then
		spell_name_rank = spell_name_rank .. " (" .. spell_rank .. ")";
		vertical_spell_name_rank = vertical_spell_name_rank .. spell_rank;
	end
	vertical_spell_name_rank = string.gsub(vertical_spell_name_rank, "[^A-Z:0-9.]","")
	if string.len(vertical_spell_name_rank) > 5 then
		vertical_spell_name_rank = string.sub(vertical_spell_name_rank,1,5);
	end
	local vtext = "";
	for i=1,string.len(vertical_spell_name_rank) do
		vtext = vtext..string.sub(vertical_spell_name_rank,i,i).."\n";
	end
	vertical_spell_name_rank = vtext;
end
]]);
		end);

		mux:Event_UnitMask("UNIT_CAST_TIMER_UPDATE", umask);
		mux:Event_UnitMask("UNIT_CAST_TIMER_STOP", smask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_spellinfo" }; end
});

RDX.RegisterFeature({
	name = "var_castlag";
	title = i18n("Var: Player Cast Lag"); category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:HasSlots("UnitFrame", "EmitPaintPreamble", "TimerVar_spell") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("FracVar_spell_fraclag");
		state:AddSlot("TextData_spell_lag_number");
		return true;
	end;
	ApplyFeature = function(desc, state)
		--local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		--local umask = mux:GetPaintMask("CAST_TIMER_UPDATE");
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local spell_lag = RDX._GetLastSpellLag();
local spell_fraclag = clamp(spell_lag / max(spell_duration,0.01), 0, 1);
local spell_lag_number = strformat("%dms", spell_lag*1000);
]]);
		--mux:Event_UnitMask("UNIT_CAST_TIMER_UPDATE", umask);
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "var_castlag" }; end
});

--------------------------------------------------
-- Scripted variable type
--------------------------------------------------
RDX.RegisterFeature({
	name = "Variable: Scripted";
	category = i18n("Variables: Unit Status");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local md,_,_,ty = RDXDB.GetObjectData(desc.script);
		if (not md) or (ty ~= "Script") or (not md.data) or (not md.data.script) then
			VFL.AddError(errs, i18n("Invalid script pointer.")); return nil;
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- Apply the custom code.
		local paintCode = [[

]];
		paintCode = paintCode .. (RDXDB.GetObjectData(desc.script)).data.script;
		paintCode = paintCode .. [[

]];

		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode(paintCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local scriptsel = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "Script")); end);
		scriptsel:SetLabel(i18n("Script object")); scriptsel:Show();
		if desc and desc.script then scriptsel:SetPath(desc.script); end
		ui:InsertFrame(scriptsel);

		function ui:GetDescriptor()
			return { 
				feature = "Variable: Scripted";
				script = scriptsel:GetPath();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "Variable: Scripted", 
		};
	end;
});

---------------------------------------------------
-- Fractional XP (fridgid)
---------------------------------------------------
RDX.RegisterFeature({
	name = "Variable: Frac XP (fxp)";
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_fxp") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_fxp");
		state:AddSlot("FracVar_fxp");
		state:AddSlot("TextData_fpxptxt");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local fxp = UnitXP("player")/UnitXPMax("player");
local fpxptxt = floor((UnitXP("player")/UnitXPMax("player")) * 100) .. "% | " .. UnitXP("Player") .. " / " .. UnitXPMax("player");
if GetXPExhaustion() then fpxptxt = fpxptxt .. " " .. (GetXPExhaustion()/2).. " R"; end
]]); end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("XP");
		mux:Event_UnitMask("UNIT_XP_UPDATE", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variable: Frac XP (fxp)" }; end
});

---------------------------------------------------
-- Fractional Pet XP (fridgid)
---------------------------------------------------
RDX.RegisterFeature({
	name = "Variable: Frac Pet XP (fpxp)";
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_fpxp") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_fpxp");
		state:AddSlot("FracVar_fpxp");
		state:AddSlot("TextData_fpetxptxt");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local currentXP, nextXP = GetPetExperience();
local fpxp = currentXP/nextXP;
local fpetxptxt = currentXP .. " / " .. nextXP;
]]); end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("XP");
		mux:Event_UnitMask("UNIT_XP_UPDATE", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variable: Frac Pet XP (fpxp)" }; end
});

---------------------------------------------------
-- Fractional Reputation (fridgid)
---------------------------------------------------

RDX.RegisterFeature({
	name = "Variable: Frac Reputation (frep)";
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_frep") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_frep");
		state:AddSlot("FracVar_frep");
		state:AddSlot("TextData_freptxt");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local name, _, repmin, repmax, repvalue = GetWatchedFactionInfo();
local frep = (repvalue - repmin) / (repmax - repmin);
local crep = repvalue - repmin;
local cmax = repmax - repmin;
local freptxt = "";
if GetWatchedFactionInfo()  then
	freptxt = name .. ": ".. crep .. "/".. cmax .. " ".. floor((crep/cmax) *100) .."%";
end

]]); end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("UNIT_FACTION", 2);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variable: Frac Reputation (frep)" }; end
});

-------------------------------------
-- Buff Debuff Info by Sigg Rashgarroth eu
-------------------------------------

local i, name, icon, apps, dur, timeleft, caster, fdur, ftimeleft, possible, start, bn;

function __rdxloadbuff(uid, buffname, auracache, playerauras, othersauras, petauras, targetauras, focusauras)
	i, name, icon, apps, dur, timeleft, caster, fdur, ftimeleft, possible, start, bn = 1, nil, "", nil, nil, nil, nil, 0, 0, false, 0, nil;
	if type(buffname) == "number" then
		local auname = GetSpellInfo(buffname);
		bn =  auname;
	else
		bn = buffname;
	end
	while true do
		_, name, _, _, _, _, icon, apps, _, dur, _, timeleft, caster = RDX.LoadBuffFromUnit(uid, i, nil, auracache);
		if not name then break; end
		if (name == bn) and dur and dur > 0 then
			fdur = dur;
			ftimeleft = timeleft;
			start = GetTime() - (dur - timeleft);
			possible = true;
			if (playerauras and caster ~= "player") or (othersauras and caster == "player") or (petauras and caster ~= "pet") or (targetauras and caster ~= "target") or (focusauras and caster ~= "focus") then
				fdur = 0;
				ftimeleft = 0;
				start = 0;
				possible = false;
			end
			if possible then 
				break;
			end
		end
		i = i + 1;
	end
	return possible, apps, icon, start, fdur, caster, timeleft;
end

function __rdxloaddebuff(uid, debuffname, auracache, playerauras, othersauras, petauras, targetauras, focusauras)
	i, name, icon, apps, dur, timeleft, caster, fdur, ftimeleft, possible, start, bn = 1, nil, "", nil, nil, nil, nil, 0, 0, false, 0, nil;
	if type(debuffname) == "number" then
		local auname = GetSpellInfo(debuffname);
		bn =  auname;
	else
		bn = debuffname;
	end
	while true do
		_, name, _, _, _, _, icon, apps, _, dur, _, timeleft, caster = RDX.LoadDebuffFromUnit(uid, i, nil, auracache);
		if not name then break; end
		if (name == bn) and dur and dur > 0 then
			fdur = dur;
			ftimeleft = timeleft;
			start = GetTime() - (dur - timeleft);
			possible = true;
			if (playerauras and caster ~= "player") or (othersauras and caster == "player") or (petauras and caster ~= "pet") or (targetauras and caster ~= "target") or (focusauras and caster ~= "focus") then
				fdur = 0;
				ftimeleft = 0;
				start = 0;
				possible = false;
			end
			if not _dispelt or (cureable and _dispelt and not RDXSS.GetCategoryByName('CURE_'..string.upper(_dispelt))) then possible = false; end
			if possible then 
				break;
			end
		end
		i = i + 1;
	end
	return possible, apps, icon, start, fdur, caster, timeleft;
end

local _types = {
	{ text = "BUFFS" },
	{ text = "DEBUFFS" },
};
local function _dd_types() return _types; end

RDX.RegisterFeature({
	name = "Variables: Buffs Debuffs Info";
	title = i18n("Vars: Aura Info");
	category =  i18n("Variables: Unit Status");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)		
		if not desc then VFL.AddError(errs, i18n( "No descriptor.")); return nil; end
		if not desc.cd then VFL.AddError(errs, i18n( "No aura selected.")); return nil; end
		state:AddSlot("Var_" .. desc.name .. "_stack");
		state:AddSlot("BoolVar_" .. desc.name .."_possible");
		state:AddSlot("TimerVar_" .. desc.name .."_aura");
		state:AddSlot("TextData_" .. desc.name .."_aura_name");
		state:AddSlot("TextData_" .. desc.name .."_aura_stack");
		state:AddSlot("TextData_" .. desc.name .."_aura_caster");
		state:AddSlot("TexVar_" .. desc.name .."_icon");
		state:AddSlot("Var_" .. desc.name .. "_timeleft");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local playerauras = "false"; if desc.playerauras then playerauras = "true"; end
		local othersauras = "false"; if desc.othersauras then othersauras = "true"; end
		local petauras = "false"; if desc.petauras then petauras = "true"; end
		local targetauras = "false"; if desc.targetauras then targetauras = "true"; end
		local focusauras = "false"; if desc.focusauras then focusauras = "true"; end
		local loadCode = "__rdxloadbuff";
		local reverse = "true" if desc.reverse then reverse = "false"; end
		
		-- Event hinting.
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = 0; 
		if desc.auraType == "DEBUFFS" then
			mask = mux:GetPaintMask("DEBUFFS");
			mux:Event_UnitMask("UNIT_DEBUFF_*", mask);
			loadCode = "__rdxloaddebuff";
		else
			mask = mux:GetPaintMask("BUFFS");
			mux:Event_UnitMask("UNIT_BUFF_*", mask);
		end
		
		local tcd = nil;
		if type(desc.cd) == "number" then
			tcd = desc.cd;
		else
			tcd = "'" .. desc.cd .. "'";
		end
		
		local winpath = state:GetContainingWindowState():GetSlotValue("Path");
		local md = RDXDB.GetObjectData(winpath);
		local auracache = "false"; if md and RDX.HasFeature(md.data, "AuraCache") then auracache = "true"; end
		
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[_possible, ]] .. desc.name .. [[_stack, ]] .. desc.name .. [[_icon , ]] .. desc.name .. [[_aura_start, ]] .. desc.name .. [[_aura_duration, ]] .. desc.name .. [[_caster, ]] .. desc.name .. [[_timeleft = ]] .. loadCode .. [[(uid, ]] .. tcd .. [[, ]] .. auracache .. [[, ]] .. playerauras .. [[, ]] .. othersauras .. [[, ]] .. petauras .. [[, ]] .. targetauras .. [[, ]] .. focusauras .. [[);
local ]] .. desc.name .. [[_aura_name = "";
local ]] .. desc.name .. [[_aura_stack = "";
local ]] .. desc.name .. [[_aura_caster = "";
if not ]] .. reverse .. [[ then
	]] .. desc.name .. [[_possible = not ]] .. desc.name .. [[_possible;
end
if ]] .. desc.name .. [[_possible then
	]] .. desc.name .. [[_aura_name = "]] .. desc.cd .. [[";
end
if ]] .. desc.name .. [[_stack and ]] .. desc.name .. [[_stack > 1 then
	]] .. desc.name .. [[_aura_stack = ]] .. desc.name .. [[_stack;
end
if ]] .. desc.name .. [[_caster and ]] .. desc.name .. [[_caster ~= "" then
	local unitu = RDX._ReallyFastProject(]] .. desc.name .. [[_caster);
	if unitu then
		]] .. desc.name .. [[_aura_caster = unitu:GetName();
	else
		]] .. desc.name .. [[_aura_caster = ]] .. desc.name .. [[_caster;
	end
end

]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local iname = VFLUI.LabeledEdit:new(ui, 100); 
		iname:Show();
		iname:SetText(i18n("Variable Name"));
		if desc and desc.name then iname.editBox:SetText(desc.name); end
		ui:InsertFrame(iname);
		
		local er = RDXUI.EmbedRight(ui, i18n("Aura Type:"));
		local dd_auraType = VFLUI.Dropdown:new(er, _dd_types);
		dd_auraType:SetWidth(75); dd_auraType:Show();
		if desc and desc.auraType then 
			dd_auraType:SetSelection(desc.auraType); 
		else
			dd_auraType:SetSelection("BUFFS");
		end
		er:EmbedChild(dd_auraType); er:Show();
		ui:InsertFrame(er);
		
		local cd = VFLUI.LabeledEdit:new(ui, 150);
		cd:SetText(i18n("Aura Name"));
		cd:Show();
		if desc and desc.cd then 
			if type(desc.cd) == "number" then
				local name = GetSpellInfo(desc.cd);
				cd.editBox:SetText(name);
			else
				cd.editBox:SetText(desc.cd);
			end
		end
		ui:InsertFrame(cd);
		
		local btn = VFLUI.Button:new(cd);
		btn:SetHeight(25); btn:SetWidth(25); btn:SetText("...");
		btn:SetPoint("RIGHT", cd.editBox, "LEFT"); 
		btn:Show();
		if dd_auraType:GetSelection() == "BUFFS" then 
			btn:SetScript("OnClick", function()
				RDXUI.AuraCachePopup(RDX._GetBuffCache(), function(x) 
					if x then cd.editBox:SetText(x.properName); end
				end, btn, "CENTER");
			end);
		else
			btn:SetScript("OnClick", function()
				RDXUI.AuraCachePopup(RDX._GetDebuffCache(), function(x) 
					if x then cd.editBox:SetText(x.properName); end
				end, btn, "CENTER");
			end);
		end
		
		------------ Filter
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Filtering")));
		
		local chk_playerauras = VFLUI.Checkbox:new(ui); chk_playerauras:Show();
		chk_playerauras:SetText(i18n("Filter auras by player"));
		if desc and desc.playerauras then chk_playerauras:SetChecked(true); else chk_playerauras:SetChecked(); end
		ui:InsertFrame(chk_playerauras);
		
		local chk_othersauras = VFLUI.Checkbox:new(ui); chk_othersauras:Show();
		chk_othersauras:SetText(i18n("Filter auras by other players"));
		if desc and desc.othersauras then chk_othersauras:SetChecked(true); else chk_othersauras:SetChecked(); end
		ui:InsertFrame(chk_othersauras);

		local chk_petauras = VFLUI.Checkbox:new(ui); chk_petauras:Show();
		chk_petauras:SetText(i18n("Filter auras by pet/vehicle"));
		if desc and desc.petauras then chk_petauras:SetChecked(true); else chk_petauras:SetChecked(); end
		ui:InsertFrame(chk_petauras);
		
		local chk_targetauras = VFLUI.Checkbox:new(ui); chk_targetauras:Show();
		chk_targetauras:SetText(i18n("Filter auras by target"));
		if desc and desc.targetauras then chk_targetauras:SetChecked(true); else chk_targetauras:SetChecked(); end
		ui:InsertFrame(chk_targetauras);
		
		local chk_focusauras = VFLUI.Checkbox:new(ui); chk_focusauras:Show();
		chk_focusauras:SetText(i18n("Filter auras by focus"));
		if desc and desc.focusauras then chk_focusauras:SetChecked(true); else chk_focusauras:SetChecked(); end
		ui:InsertFrame(chk_focusauras);
        
		local chk_reverse = VFLUI.Checkbox:new(ui); chk_reverse:Show();
		chk_reverse:SetText(i18n("Reverse filtering (report when NOT possible)"));
		if desc and desc.reverse then chk_reverse:SetChecked(true); else chk_reverse:SetChecked(); end
		ui:InsertFrame(chk_reverse);

		function ui:GetDescriptor()
			local t = cd.editBox:GetText();
			return {
				feature = "Variables: Buffs Debuffs Info"; 
				name = iname.editBox:GetText();
				auraType = dd_auraType:GetSelection();
				cd = RDXSS.GetSpellIdByLocalName(t) or t;
				playerauras = chk_playerauras:GetChecked();
				othersauras = chk_othersauras:GetChecked();
				petauras = chk_petauras:GetChecked();
				targetauras = chk_targetauras:GetChecked();
				focusauras = chk_focusauras:GetChecked();
				reverse = chk_reverse:GetChecked();
			};
		end
		
		ui.Destroy = VFL.hook(function(s) btn:Destroy(); s.GetDescriptor = nil; end, ui.Destroy);

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Variables: Buffs Debuffs Info"; name = "aurai"; auraType = "BUFFS"; };
	end;
});

RDX.RegisterFeature({
	name = "Variables range";
	title = i18n("Vars: Range (frac, color)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:HasSlots("UnitFrame", "EmitClosure", "EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)		
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if (not RDX.FindSet(desc.set1)) or (not RDX.FindSet(desc.set2)) or (not RDX.FindSet(desc.set3)) or (not RDX.FindSet(desc.set4)) then
			VFL.AddError(errs, i18n("Invalid set pointer."));
			return nil;
		end
		if state:Slot("Var_rangeColor") then
			VFL.AddError(errs, i18n("Duplicate variable name.")); return nil;
		end
		state:AddSlot("Var_rangeColor");
		state:AddSlot("ColorVar_rangeColor");
		state:AddSlot("FracVar_rangeFrac");
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- On closure, acquire the set locally
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode("local st1 = RDX.FindSet(" .. Serialize(desc.set1) .. ");");
			code:AppendCode("local st2 = RDX.FindSet(" .. Serialize(desc.set2) .. ");");
			code:AppendCode("local st3 = RDX.FindSet(" .. Serialize(desc.set3) .. ");");
			code:AppendCode("local st4 = RDX.FindSet(" .. Serialize(desc.set4) .. ");");
			code:AppendCode([[
local raColor_cf = {};
raColor_cf[1] = ]] .. Serialize(desc.raColor1) .. [[;
raColor_cf[2] = ]] .. Serialize(desc.raColor2) .. [[;
raColor_cf[3] = ]] .. Serialize(desc.raColor3) .. [[;
raColor_cf[4] = ]] .. Serialize(desc.raColor4) .. [[;
]]);
		end);
		-- On paint preamble, create flag and grade variables
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local rangeColor, rangeFrac = raColor_cf[1], 1;
if st1:IsMember(unit) then
	rangeColor = raColor_cf[1];
	rangeFrac = 1;
elseif st2:IsMember(unit) then
	rangeColor = raColor_cf[2];
	rangeFrac = 0.66;
elseif st3:IsMember(unit) then
	rangeColor = raColor_cf[3];
	rangeFrac = 0.33;
elseif st4:IsMember(unit) then
	rangeColor = raColor_cf[4];
	rangeFrac = 0;
end
]]);
		end);
		-- Event hint: update on sort.
		local set1 = RDX.FindSet(desc.set1);
		local set2 = RDX.FindSet(desc.set2);
		local set3 = RDX.FindSet(desc.set3);
		local set4 = RDX.FindSet(desc.set4);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_SetDeltaMask(set1, 2); -- mask 2 = generic repaint
		mux:Event_SetDeltaMask(set2, 2); -- mask 2 = generic repaint
		mux:Event_SetDeltaMask(set3, 2); -- mask 2 = generic repaint
		mux:Event_SetDeltaMask(set4, 2); -- mask 2 = generic repaint
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local sf1 = RDX.SetFinder:new(ui); sf1:Show();
		ui:InsertFrame(sf1); 
		if desc and desc.set1 then sf1:SetDescriptor(desc.set1); end
		
		local er1 = RDXUI.EmbedRight(ui, i18n("0-15 color"));
		local swatch_raColor1 = VFLUI.ColorSwatch:new(er1);
		swatch_raColor1:Show();
		if desc and desc.raColor1 then swatch_raColor1:SetColor(explodeRGBA(desc.raColor1)); end
		er1:EmbedChild(swatch_raColor1); er1:Show();
		ui:InsertFrame(er1);
		
		local sf2 = RDX.SetFinder:new(ui); sf2:Show();
		ui:InsertFrame(sf2); 
		if desc and desc.set2 then sf2:SetDescriptor(desc.set2); end
		
		local er2 = RDXUI.EmbedRight(ui, i18n("15-30 color"));
		local swatch_raColor2 = VFLUI.ColorSwatch:new(er2);
		swatch_raColor2:Show();
		if desc and desc.raColor2 then swatch_raColor2:SetColor(explodeRGBA(desc.raColor2)); end
		er2:EmbedChild(swatch_raColor2); er2:Show();
		ui:InsertFrame(er2);
		
		local sf3 = RDX.SetFinder:new(ui); sf3:Show();
		ui:InsertFrame(sf3); 
		if desc and desc.set3 then sf3:SetDescriptor(desc.set3); end
		
		local er3 = RDXUI.EmbedRight(ui, i18n("30-40 color"));
		local swatch_raColor3 = VFLUI.ColorSwatch:new(er3);
		swatch_raColor3:Show();
		if desc and desc.raColor3 then swatch_raColor3:SetColor(explodeRGBA(desc.raColor3)); end
		er3:EmbedChild(swatch_raColor3); er3:Show();
		ui:InsertFrame(er3);
		
		local sf4 = RDX.SetFinder:new(ui); sf4:Show();
		ui:InsertFrame(sf4); 
		if desc and desc.set4 then sf4:SetDescriptor(desc.set4); end
		
		local er4 = RDXUI.EmbedRight(ui, i18n("40+ color"));
		local swatch_raColor4 = VFLUI.ColorSwatch:new(er4);
		swatch_raColor4:Show();
		if desc and desc.raColor4 then swatch_raColor4:SetColor(explodeRGBA(desc.raColor4)); end
		er4:EmbedChild(swatch_raColor4); er4:Show();
		ui:InsertFrame(er4);

		function ui:GetDescriptor()
			return {
				feature = "Variables range";
				set1 = sf1:GetDescriptor();  
				set2 = sf2:GetDescriptor();
				set3 = sf3:GetDescriptor();
				set4 = sf4:GetDescriptor();
				raColor1 = swatch_raColor1:GetColor(); 
				raColor2 = swatch_raColor2:GetColor();
				raColor3 = swatch_raColor3:GetColor();
				raColor4 = swatch_raColor4:GetColor();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Variables range"; 
			set1 = { file = "Builtin:range_0_15", class = "file"};
			set2 = { file = "Builtin:range_15_30", class = "file"};
			set3 = { file = "Builtin:range_30_40", class = "file"}; 
			set4 = { file = "Builtin:range_40plus", class = "file"};
			raColor1 = _green;
			raColor2 = _yellow;
			raColor3 = _orange;
			raColor4 = _red;
		};
	end;
});


-------------------------
-- Sigg / Rashgarroth eu
-------------------------

RDX.RegisterFeature({
	name = "Variables decurse";
	title = i18n("Vars: Decurse (Texicon, color)");
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:HasSlots("UnitFrame", "EmitClosure", "EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)		
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if (not RDX.FindSet(desc.set1)) or (not RDX.FindSet(desc.set2)) or (not RDX.FindSet(desc.set3)) or (not RDX.FindSet(desc.set4)) then
			VFL.AddError(errs, i18n("Invalid set pointer."));
			return nil;
		end
		if state:Slot("ColorVar_decurseColor") then
			VFL.AddError(errs, i18n("Duplicate variable name.")); return nil;
		end
		--state:AddSlot("Var_decurseColor");
		state:AddSlot("ColorVar_decurseColor");
		state:AddSlot("TexVar_decurseIcon");
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- On closure, acquire the set locally
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode("local st1 = RDX.FindSet(" .. Serialize(desc.set1) .. ");");
			code:AppendCode("local st2 = RDX.FindSet(" .. Serialize(desc.set2) .. ");");
			code:AppendCode("local st3 = RDX.FindSet(" .. Serialize(desc.set3) .. ");");
			code:AppendCode("local st4 = RDX.FindSet(" .. Serialize(desc.set4) .. ");");
			code:AppendCode([[
local deColor_cf = {};
deColor_cf[1] = ]] .. Serialize(desc.raColor1) .. [[;
deColor_cf[2] = ]] .. Serialize(desc.raColor2) .. [[;
deColor_cf[3] = ]] .. Serialize(desc.raColor3) .. [[;
deColor_cf[4] = ]] .. Serialize(desc.raColor4) .. [[;

local deTex_cf = {};
deTex_cf[1] = ]] .. string.format("%q", desc.texture1.path) .. [[;
deTex_cf[2] = ]] .. string.format("%q", desc.texture2.path) .. [[;
deTex_cf[3] = ]] .. string.format("%q", desc.texture3.path) .. [[;
deTex_cf[4] = ]] .. string.format("%q", desc.texture4.path) .. [[;
]]);
		end);
		-- On paint preamble, create flag and grade variables
		local cmagic, cpoison, cdisease, ccurse = "and RDXSS.GetCategoryByName('CURE_MAGIC') ", "and RDXSS.GetCategoryByName('CURE_POISON') ", "and RDXSS.GetCategoryByName('CURE_DISEASE') ", "and RDXSS.GetCategoryByName('CURE_CURSE') ";
		if desc.nocurefilter then
			cmagic, cpoison, cdisease, ccurse = "", "", "", "";
		end
		
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local decurseColor, decurseIcon = _alphafull, "";
if st1:IsMember(unit) ]] .. cmagic .. [[ then
	decurseColor = deColor_cf[1];
	decurseIcon = deTex_cf[1];
elseif st2:IsMember(unit) ]] .. cpoison .. [[ then
	decurseColor = deColor_cf[2];
	decurseIcon = deTex_cf[2];
elseif st3:IsMember(unit) ]] .. cdisease .. [[ then
	decurseColor = deColor_cf[3];
	decurseIcon = deTex_cf[3];
elseif st4:IsMember(unit) ]] .. ccurse .. [[ then
	decurseColor = deColor_cf[4];
	decurseIcon = deTex_cf[4];
end
]]);
		end);
		-- Event hint: update on sort.
		local set1 = RDX.FindSet(desc.set1);
		local set2 = RDX.FindSet(desc.set2);
		local set3 = RDX.FindSet(desc.set3);
		local set4 = RDX.FindSet(desc.set4);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_SetDeltaMask(set1, 2); -- mask 2 = generic repaint
		mux:Event_SetDeltaMask(set2, 2); -- mask 2 = generic repaint
		mux:Event_SetDeltaMask(set3, 2); -- mask 2 = generic repaint
		mux:Event_SetDeltaMask(set4, 2); -- mask 2 = generic repaint
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Options")));
		
		local chk_nocurefilter = VFLUI.Checkbox:new(ui); chk_nocurefilter:Show();
		chk_nocurefilter:SetText(i18n("No filter, show all debuff"));
		if desc and desc.nocurefilter then chk_nocurefilter:SetChecked(true); else chk_nocurefilter:SetChecked(); end
		ui:InsertFrame(chk_nocurefilter);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Magic")));
		
		local sf1 = RDX.SetFinder:new(ui); sf1:Show();
		ui:InsertFrame(sf1); 
		if desc and desc.set1 then sf1:SetDescriptor(desc.set1); end
		
		local er1 = RDXUI.EmbedRight(ui, i18n("Magic"));
		local swatch_raColor1 = VFLUI.ColorSwatch:new(er1);
		swatch_raColor1:Show();
		if desc and desc.raColor1 then swatch_raColor1:SetColor(explodeRGBA(desc.raColor1)); end
		er1:EmbedChild(swatch_raColor1); er1:Show();
		ui:InsertFrame(er1);
		
		local er1 = RDXUI.EmbedRight(ui, i18n("Texture Magic"));
		local tsel1 = VFLUI.MakeTextureSelectButton(er1, desc.texture1); tsel1:Show();
		er1:EmbedChild(tsel1); er1:Show();
		ui:InsertFrame(er1);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("poison")));
		
		local sf2 = RDX.SetFinder:new(ui); sf2:Show();
		ui:InsertFrame(sf2); 
		if desc and desc.set2 then sf2:SetDescriptor(desc.set2); end
		
		local er2 = RDXUI.EmbedRight(ui, i18n("Poison"));
		local swatch_raColor2 = VFLUI.ColorSwatch:new(er2);
		swatch_raColor2:Show();
		if desc and desc.raColor2 then swatch_raColor2:SetColor(explodeRGBA(desc.raColor2)); end
		er2:EmbedChild(swatch_raColor2); er2:Show();
		ui:InsertFrame(er2);
		
		local er2 = RDXUI.EmbedRight(ui, i18n("Texture Poison"));
		local tsel2 = VFLUI.MakeTextureSelectButton(er2, desc.texture2); tsel2:Show();
		er2:EmbedChild(tsel2); er2:Show();
		ui:InsertFrame(er2);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Disease")));
		
		local sf3 = RDX.SetFinder:new(ui); sf3:Show();
		ui:InsertFrame(sf3); 
		if desc and desc.set3 then sf3:SetDescriptor(desc.set3); end
		
		local er3 = RDXUI.EmbedRight(ui, i18n("Disease"));
		local swatch_raColor3 = VFLUI.ColorSwatch:new(er3);
		swatch_raColor3:Show();
		if desc and desc.raColor3 then swatch_raColor3:SetColor(explodeRGBA(desc.raColor3)); end
		er3:EmbedChild(swatch_raColor3); er3:Show();
		ui:InsertFrame(er3);
		
		local er3 = RDXUI.EmbedRight(ui, i18n("Texture Disease"));
		local tsel3 = VFLUI.MakeTextureSelectButton(er3, desc.texture3); tsel3:Show();
		er3:EmbedChild(tsel3); er3:Show();
		ui:InsertFrame(er3);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Curse")));
		
		local sf4 = RDX.SetFinder:new(ui); sf4:Show();
		ui:InsertFrame(sf4); 
		if desc and desc.set4 then sf4:SetDescriptor(desc.set4); end
		
		local er4 = RDXUI.EmbedRight(ui, i18n("Curse"));
		local swatch_raColor4 = VFLUI.ColorSwatch:new(er4);
		swatch_raColor4:Show();
		if desc and desc.raColor4 then swatch_raColor4:SetColor(explodeRGBA(desc.raColor4)); end
		er4:EmbedChild(swatch_raColor4); er4:Show();
		ui:InsertFrame(er4);
		
		local er4 = RDXUI.EmbedRight(ui, i18n("Texture Curse"));
		local tsel4 = VFLUI.MakeTextureSelectButton(er4, desc.texture4); tsel4:Show();
		er4:EmbedChild(tsel4); er4:Show();
		ui:InsertFrame(er4);

		function ui:GetDescriptor()
			return {
				feature = "Variables decurse";
				nocurefilter = chk_nocurefilter:GetChecked();
				set1 = sf1:GetDescriptor();  
				set2 = sf2:GetDescriptor();
				set3 = sf3:GetDescriptor();
				set4 = sf4:GetDescriptor();
				texture1 = tsel1:GetSelectedTexture();
				texture2 = tsel2:GetSelectedTexture();
				texture3 = tsel3:GetSelectedTexture();
				texture4 = tsel4:GetSelectedTexture();
				raColor1 = swatch_raColor1:GetColor(); 
				raColor2 = swatch_raColor2:GetColor();
				raColor3 = swatch_raColor3:GetColor();
				raColor4 = swatch_raColor4:GetColor();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Variables decurse";
			set1 = { file = "Builtin:debuff_magic_fset", class = "file"};
			set2 = { file = "Builtin:debuff_poison_fset", class = "file"};
			set3 = { file = "Builtin:debuff_disease_fset", class = "file"}; 
			set4 = { file = "Builtin:debuff_curse_fset", class = "file"};
			texture1 = { blendMode = "BLEND", path = "Interface\\Icons\\Spell_Holy_DispelMagic"};
			texture2 = { blendMode = "BLEND", path = "Interface\\Icons\\Spell_Nature_NullifyPoison_02"};
			texture3 = { blendMode = "BLEND", path = "Interface\\Icons\\Spell_Nature_RemoveDisease"};
			texture4 = { blendMode = "BLEND", path = "Interface\\Icons\\Spell_Nature_RemoveCurse"};
			raColor1 = _blue;
			raColor2 = _green;
			raColor3 = _yellow;
			raColor4 = _red;
		};
	end;
});

---------------------------------------------
-- Multi faction variable by Taelnia
---------------------------------------------

RDX.RegisterFeature({
	name = "Variables: Detailed Faction Info";
	title = i18n("Vars: Detailed Faction Info");
	category =  i18n("Variables: Unit Status");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if (not desc.factionID) or (desc.factionID < 1) then
			VFL.AddError(errs, i18n("Missing faction identifier.")); return nil;
		end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("FracVar_" .. desc.name);
		state:AddSlot("TextData_" .. desc.name .. "txt");
		state:AddSlot("ColorVar_" .. desc.name .. "cv");
		return true;
	end;
      
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitClosure"), true, function(code) code:AppendCode([[
local reputationColor_cf = {};
reputationColor_cf[0] = ]] .. Serialize(desc.colorUnknown) .. [[;
reputationColor_cf[1] = ]] .. Serialize(desc.colorHated) .. [[;
reputationColor_cf[2] = ]] .. Serialize(desc.colorHostile) .. [[;
reputationColor_cf[3] = ]] .. Serialize(desc.colorUnfriendly) .. [[;
reputationColor_cf[4] = ]] .. Serialize(desc.colorNeutral) .. [[;
reputationColor_cf[5] = ]] .. Serialize(desc.colorFriendly) .. [[;
reputationColor_cf[6] = ]] .. Serialize(desc.colorHonored) .. [[;
reputationColor_cf[7] = ]] .. Serialize(desc.colorRevered) .. [[;
reputationColor_cf[8] = ]] .. Serialize(desc.colorExalted) .. [[;
]]);
		end);
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local ]] .. desc.name .. [[, ]] .. desc.name .. [[txt, ]] .. desc.name .. [[cv = 0, "", Serialize({r=0.5,g=0.5,b=0.5,a=1});
if(]] .. desc.factionID .. [[ > 0) then
	local name,_, repstanding, repmin, repmax, repvalue = GetFactionInfo(]] .. desc.factionID .. [[);
	local crep = repvalue - repmin;
	local cmax = repmax - repmin;
	]] .. desc.name .. [[ = crep / cmax;
	]] .. desc.name .. [[txt = name .. ": ".. crep .. "/".. cmax .. " ".. floor((crep/cmax) *100) .."%";
	]] .. desc.name .. [[cv = reputationColor_cf[repstanding];
end
]]); end);
         local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
         mux:Event_MaskAll("UNIT_FACTION", 2);
      end;
      UIFromDescriptor = function(desc, parent, state)
         local start, finish, done = 1, GetNumFactions(), false;
         local name, isHeader, isCollapsed;
         local collapsedHeaders = {};
         
         local factionList = {};
         repeat
            for i = start, finish do
               name, _, _, _, _, _, _, _, isHeader, isCollapsed, _, _, _ = GetFactionInfo(i);
               
               table.insert(factionList, { text = name, id = i });
               
               if(isHeader and isCollapsed) then
                  collapsedHeaders[i] = true;
                  ExpandFactionHeader(i);
                  start = i + 1;
                  finish = GetNumFactions();
                  break;
               end
               
               if(i == finish) then
                  done = true;
               end
            end
         until done == true
         
         local playerFactionCount = GetNumFactions();
         
         for i = playerFactionCount, 1, -1 do
            if(collapsedHeaders[i] == true) then
               CollapseFactionHeader(i);
               collapsedHeaders[i] = nil;
            end
         end
         
         start, finish, done, name, isHeader, isCollapsed, collapsedHeaders = nil, nil, nil, nil, nil, nil ,nil;
         
         local ui = VFLUI.CompoundFrame:new(parent);
         
         local iname = VFLUI.LabeledEdit:new(ui, 180);
         iname:Show();
         iname:SetText(i18n("Variable Name"));
         if desc and desc.name then iname.editBox:SetText(desc.name); end
         ui:InsertFrame(iname);
         
         local er = RDXUI.EmbedRight(ui, i18n("Faction:"));
         local dd_factionList = VFLUI.Dropdown:new(er, function() return factionList; end);
         dd_factionList:SetWidth(180); dd_factionList:Show();
         if desc and desc.factionName then
            dd_factionList:SetSelection(desc.factionName);
         else
            dd_factionList:SetSelection("Other");
         end
         er:EmbedChild(dd_factionList); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Unknown color"));
         local swatch_colorUnknown = VFLUI.ColorSwatch:new(er);
         swatch_colorUnknown:Show();
         if desc and desc.colorUnknown then swatch_colorUnknown:SetColor(explodeRGBA(desc.colorUnknown)); end
         er:EmbedChild(swatch_colorUnknown); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Hated color"));
         local swatch_colorHated = VFLUI.ColorSwatch:new(er);
         swatch_colorHated:Show();
         if desc and desc.colorHated then swatch_colorHated:SetColor(explodeRGBA(desc.colorHated)); end
         er:EmbedChild(swatch_colorHated); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Hostile color"));
         local swatch_colorHostile = VFLUI.ColorSwatch:new(er);
         swatch_colorHostile:Show();
         if desc and desc.colorHostile then swatch_colorHostile:SetColor(explodeRGBA(desc.colorHostile)); end
         er:EmbedChild(swatch_colorHostile); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Unfriendly color"));
         local swatch_colorUnfriendly = VFLUI.ColorSwatch:new(er);
         swatch_colorUnfriendly:Show();
         if desc and desc.colorUnfriendly then swatch_colorUnfriendly:SetColor(explodeRGBA(desc.colorUnfriendly)); end
         er:EmbedChild(swatch_colorUnfriendly); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Neutral color"));
         local swatch_colorNeutral = VFLUI.ColorSwatch:new(er);
         swatch_colorNeutral:Show();
         if desc and desc.colorNeutral then swatch_colorNeutral:SetColor(explodeRGBA(desc.colorNeutral)); end
         er:EmbedChild(swatch_colorNeutral); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Friendly color"));
         local swatch_colorFriendly = VFLUI.ColorSwatch:new(er);
         swatch_colorFriendly:Show();
         if desc and desc.colorFriendly then swatch_colorFriendly:SetColor(explodeRGBA(desc.colorFriendly)); end
         er:EmbedChild(swatch_colorFriendly); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Honored color"));
         local swatch_colorHonored = VFLUI.ColorSwatch:new(er);
         swatch_colorHonored:Show();
         if desc and desc.colorHonored then swatch_colorHonored:SetColor(explodeRGBA(desc.colorHonored)); end
         er:EmbedChild(swatch_colorHonored); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Revered color"));
         local swatch_colorRevered = VFLUI.ColorSwatch:new(er);
         swatch_colorRevered:Show();
         if desc and desc.colorRevered then swatch_colorRevered:SetColor(explodeRGBA(desc.colorRevered)); end
         er:EmbedChild(swatch_colorRevered); er:Show();
         ui:InsertFrame(er);
         
         er = RDXUI.EmbedRight(ui, i18n("Exalted color"));
         local swatch_colorExalted = VFLUI.ColorSwatch:new(er);
         swatch_colorExalted:Show();
         if desc and desc.colorExalted then swatch_colorExalted:SetColor(explodeRGBA(desc.colorExalted)); end
         er:EmbedChild(swatch_colorExalted); er:Show();
         ui:InsertFrame(er);
         
         function ui:GetDescriptor()
            local facName = dd_factionList:GetSelection();
            local facID = 0;
           
            for index, value in pairs(factionList) do
               if value.text == facName then
                  facID = value.id;
                  break;
               end
            end
           
            return {
               feature = i18n("Variables: Detailed Faction Info");
               name = iname.editBox:GetText();
               factionName = facName;
               factionID = facID;
               colorUnknown = swatch_colorUnknown:GetColor();
               colorHated = swatch_colorHated:GetColor();
               colorHostile = swatch_colorHostile:GetColor();
               colorUnfriendly = swatch_colorUnfriendly:GetColor();
               colorNeutral = swatch_colorNeutral:GetColor();
               colorFriendly = swatch_colorFriendly:GetColor();
               colorHonored = swatch_colorHonored:GetColor();
               colorRevered = swatch_colorRevered:GetColor();
               colorExalted = swatch_colorExalted:GetColor();
            };
         end
         
         ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil; for index, value in pairs(factionList) do value.text = nil; value.id = nil; factionList[index] = nil; end factionList = nil; end, ui.Destroy);
         
         return ui;
      end;
      CreateDescriptor = function()
         return {
            feature         = i18n("Variables: Detailed Faction Info");
            name            = "faction1";
            factionName     = "";
            factionID       = 0;
            colorUnknown    = {r = 0.5,  g = 0.5,  b = 0.5,  a = 1};
            colorHated      = {r = 0.8,  g = 0.13, b = 0.13, a = 1};
            colorHostile    = {r = 1,    g = 0,    b = 0,    a = 1};
            colorUnfriendly = {r = 0.93, g = 0.4,  b = 0.13, a = 1};
            colorNeutral    = {r = 1,    g = 1,    b = 0,    a = 1};
            colorFriendly   = {r = 0,    g = 1,    b = 0,    a = 1};
            colorHonored    = {r = 0,    g = 1,    b = 0.53, a = 1};
            colorRevered    = {r = 0,    g = 1,    b = 0.8,  a = 1};
            colorExalted    = {r = 0,    g = 1,    b = 1,    a = 1};
         };
      end;
});

-- by netquick

RDX.RegisterFeature({
	name = "Variable: Druid Mana (dmana)";
	title = "Variable: Druid Mana (dmana)";
	category = i18n("Variables: Unit Status");
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_dmana") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_dmana");
		state:AddSlot("FracVar_dmana");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
			local dmana = 0;
			if unit:GetClassMnemonic() == "DRUID" then
				dmana = format("%.2f", (UnitPower(uid,0)/UnitPowerMax(uid,0)));
			else
				dmana = format("%.2f", (UnitPower(uid)/UnitPowerMax(uid)));
			end
			]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("POWER");
		mux:Event_UnitMask("UNIT_POWER", mask);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variable: Druid Mana (dmana)" }; end
});
