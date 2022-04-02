-- ColorVariables.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Variables that can be used to define colors.

RDX.RegisterFeature({
	name = "ColorVariable: Static Color";
	title = i18n("Color: Static Color");
	category = i18n("Variables: Color");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitClosure") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not desc.color then VFL.AddError(errs, i18n("Missing color parameter.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("ColorVar_" .. desc.name);
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[ = ]] .. Serialize(desc.color) .. [[;
]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local color = RDXUI.GenerateColorSwatch(ui, i18n("Color"));
		if desc and desc.color then color:SetColor(explodeRGBA(desc.color)); end

		function ui:GetDescriptor()
			return {
				feature = "ColorVariable: Static Color"; name = name.editBox:GetText();
				color = color:GetColor();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "ColorVariable: Static Color"; name = "staticColor"; color = {r=1,g=1,b=1,a=1}; };
	end;
});

RDX.RegisterFeature({
	name = "ColorVariable: Unit Class Color";
	title = i18n("Color: Unit Class Color");
	category = i18n("Variables: Color");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if state:Slot("ColorVar_classColor") then
			VFL.AddError(errs, i18n("Duplicate variable name.")); return nil;
		end
		state:AddSlot("Var_classColor");
		state:AddSlot("ColorVar_classColor");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode("local classColor = unit:GetClassColor();");
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function()
		return { feature = "ColorVariable: Unit Class Color"; };
	end;
});

RDX.RegisterFeature({
	name = "ColorVariable: Unit PowerType Color";
	title = i18n("Color: Unit PowerType Color");
	category = i18n("Variables: Color");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if state:Slot("ColorVar_powerColor") then
			VFL.AddError(errs, i18n("Duplicate variable name.")); return nil;
		end
		-- add tmp
		if not desc.runeColor then desc.runeColor = {r=0, g=0.75, b=1,a=1} end
		state:AddSlot("Var_powerColor");
		state:AddSlot("ColorVar_powerColor");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode([[
local powerColor_cf = {};
powerColor_cf[0] = ]] .. Serialize(desc.manaColor) .. [[;
powerColor_cf[1] = ]] .. Serialize(desc.rageColor) .. [[;
powerColor_cf[2] = powerColor_cf[0];
powerColor_cf[3] = ]] .. Serialize(desc.energyColor) .. [[;
powerColor_cf[4] = powerColor_cf[0];
powerColor_cf[5] = powerColor_cf[0];
powerColor_cf[6] = ]] .. Serialize(desc.runeColor) .. [[;
]]);
		end);
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode("local powerColor = powerColor_cf[unit:PowerType()] or powerColor_cf[0];");
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local er = RDXUI.EmbedRight(ui, i18n("Mana Color:"));
		local swatch_manac = VFLUI.ColorSwatch:new(er);
		swatch_manac:Show();
		if desc and desc.manaColor then swatch_manac:SetColor(explodeRGBA(desc.manaColor)); end
		er:EmbedChild(swatch_manac); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Energy Color:"));
		local swatch_energyc = VFLUI.ColorSwatch:new(er);
		swatch_energyc:Show();
		if desc and desc.energyColor then swatch_energyc:SetColor(explodeRGBA(desc.energyColor)); end
		er:EmbedChild(swatch_energyc); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Rage Color:"));
		local swatch_ragec = VFLUI.ColorSwatch:new(er);
		swatch_ragec:Show();
		if desc and desc.rageColor then swatch_ragec:SetColor(explodeRGBA(desc.rageColor)); end
		er:EmbedChild(swatch_ragec); er:Show();
		ui:InsertFrame(er);
		
		local er = RDXUI.EmbedRight(ui, i18n("Rune Color:"));
		local swatch_runec = VFLUI.ColorSwatch:new(er);
		swatch_runec:Show();
		if desc and desc.runeColor then swatch_runec:SetColor(explodeRGBA(desc.runeColor)); end
		er:EmbedChild(swatch_runec); er:Show();
		ui:InsertFrame(er);
		
		function ui:GetDescriptor()
			return { 
				feature = "ColorVariable: Unit PowerType Color";
				manaColor = swatch_manac:GetColor(); 
				energyColor = swatch_energyc:GetColor();
				rageColor = swatch_ragec:GetColor(); 
				runeColor = swatch_runec:GetColor();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "ColorVariable: Unit PowerType Color";
			manaColor = {r=0, g=0, b=0.75,a=1}, rageColor = {r=1,g=0,b=0,a=1}, energyColor = {r=0.75,g=0.75,b=0,a=1}, runeColor = {r=0, g=0.75, b=1,a=1};
		};
	end;
});

RDX.RegisterFeature({
	name = "ColorVariable: Two-Color Blend";
	title = i18n("Color: Two-Color Blend");
	category = i18n("Variables: Color");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if (not desc.bfVar) or (strtrim(desc.bfVar) == "") then VFL.AddError(errs, i18n("missing blend fraction.")); return nil; end
		if not tonumber(desc.bfVar) then
			if (not state:Slot("FracVar_" .. desc.bfVar)) then 
				VFL.AddError(errs, i18n("Invalid blend fraction.")); return nil;
			end
		end
		if (not desc.colorVar1) or (not desc.colorVar2) then
			VFL.AddError(errs, i18n("Missing blend colors.")); return nil;
		end
		if (not state:Slot("ColorVar_" .. desc.colorVar1)) or (not state:Slot("ColorVar_" .. desc.colorVar2)) then
			VFL.AddError(errs, i18n("Invalid blend colors.")); return nil;
		end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("ColorVar_" .. desc.name);
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode("local " .. desc.name .. " = VFL.Color:new();");
		end);
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
]] .. desc.name .. [[:blend(]] .. desc.colorVar1 .. "," .. desc.colorVar2 .. "," .. desc.bfVar .. [[);
]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local bfVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Blend fraction"), state, "FracVar_");
		if desc and desc.bfVar then bfVar:SetSelection(desc.bfVar); end

		local colorVar1 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("From color"), state, "ColorVar_");
		if desc and desc.colorVar1 then colorVar1:SetSelection(desc.colorVar1); end
		local colorVar2 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("To color"), state, "ColorVar_");
		if desc and desc.colorVar2 then colorVar2:SetSelection(desc.colorVar2); end
		
		function ui:GetDescriptor()
			return {
				feature = "ColorVariable: Two-Color Blend"; name = name.editBox:GetText();
				bfVar = bfVar:GetSelection(); colorVar1 = colorVar1:GetSelection(); colorVar2 = colorVar2:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "ColorVariable: Two-Color Blend"; name = "twoColor"; };
	end;
});

RDX.RegisterFeature({
	name = "ColorVariable: Conditional Color";
	title = i18n("Color: Conditional Color");
	category = i18n("Variables: Color");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if (not desc.condVar) then
			VFL.AddError(errs, i18n("Invalid condition variable.")); return nil;
		end
		if (not desc.colorVar1) or (not desc.colorVar2) then
			VFL.AddError(errs, i18n("Missing true/false colors.")); return nil;
		end
		if (not state:Slot("ColorVar_" .. desc.colorVar1)) or (not state:Slot("ColorVar_" .. desc.colorVar2)) then
			VFL.AddError(errs, i18n("Invalid true/false colors.")); return nil;
		end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("ColorVar_" .. desc.name);
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[ = nil;
if ]] .. desc.condVar .. [[ then 
	]] .. desc.name .. [[ = ]] .. desc.colorVar1 .. [[;
else
	]] .. desc.name .. [[ = ]] .. desc.colorVar2 .. [[;
end
]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local condVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Condition"), state, "BoolVar_");
		if desc and desc.condVar then condVar:SetSelection(desc.condVar); end

		local colorVar1 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("True color"), state, "ColorVar_");
		if desc and desc.colorVar1 then colorVar1:SetSelection(desc.colorVar1); end
		local colorVar2 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("False color"), state, "ColorVar_");
		if desc and desc.colorVar2 then colorVar2:SetSelection(desc.colorVar2); end
		
		function ui:GetDescriptor()
			return {
				feature = "ColorVariable: Conditional Color"; name = name.editBox:GetText();
				condVar = condVar:GetSelection(); colorVar1 = colorVar1:GetSelection(); colorVar2 = colorVar2:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "ColorVariable: Conditional Color"; name = "condColor"; };
	end;
});

RDX.RegisterFeature({
	name = "colorvar_hostility"; 
	title = i18n("Color: Hostility");
	category = i18n("Variables: Color");
	IsPossible = function(state)
		if not state:HasSlots("EmitClosure", "EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if state:Slot("ColorVar_hostileColor") then
			VFL.AddError(errs, i18n("Duplicate variable name.")); return nil;
		end
		state:AddSlot("Var_hostileColor");
		state:AddSlot("ColorVar_hostileColor");
		return true;
	end;
	ApplyFeature = function(desc, state)
		if desc and not(desc.XPColor) then desc.XPColor = {r=0.5,g=0.5,b=0.5,a=1}; end
		if desc and not(desc.selfColor) then desc.selfColor = {r=0,g=0,b=1,a=1}; end
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode([[
local hostileColor_cf = {};
hostileColor_cf[1] = ]] .. Serialize(desc.friendlyColor) .. [[;
hostileColor_cf[2] = ]] .. Serialize(desc.neutralColor) .. [[;
hostileColor_cf[3] = ]] .. Serialize(desc.hostileColor) .. [[;
hostileColor_cf[4] = ]] .. Serialize(desc.XPColor) .. [[;
hostileColor_cf[5] = ]] .. Serialize(desc.selfColor) .. [[;
]]);
		end);
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local hostileColor = hostileColor_cf[1];
if not UnitIsFriend(uid, "player") then
	if UnitIsEnemy(uid, "player") then
		hostileColor = hostileColor_cf[3];
	else
		hostileColor = hostileColor_cf[2];
	end
end
if UnitIsTapped(uid) and not UnitIsTappedByPlayer(uid) then
	hostileColor = hostileColor_cf[4];
end
if UnitIsUnit(uid, "player") or RDX.UnitInGroup(uid) then
	hostileColor = hostileColor_cf[5];
end
if not UnitExists(uid) then
	hostileColor = Serialize({r=0,g=0,b=0,a=0});
end
]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local er = RDXUI.EmbedRight(ui, i18n("Friendly color"));
		local swatch_friendlyColor = VFLUI.ColorSwatch:new(er);
		swatch_friendlyColor:Show();
		if desc and desc.friendlyColor then swatch_friendlyColor:SetColor(explodeRGBA(desc.friendlyColor)); end
		er:EmbedChild(swatch_friendlyColor); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Neutral color"));
		local swatch_neutralColor = VFLUI.ColorSwatch:new(er);
		swatch_neutralColor:Show();
		if desc and desc.neutralColor then swatch_neutralColor:SetColor(explodeRGBA(desc.neutralColor)); end
		er:EmbedChild(swatch_neutralColor); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Hostile color"));
		local swatch_hostileColor = VFLUI.ColorSwatch:new(er);
		swatch_hostileColor:Show();
		if desc and desc.hostileColor then swatch_hostileColor:SetColor(explodeRGBA(desc.hostileColor)); end
		er:EmbedChild(swatch_hostileColor); er:Show();
		ui:InsertFrame(er);
		
		local er = RDXUI.EmbedRight(ui, i18n("Not tap color"));
		local swatch_XPColor = VFLUI.ColorSwatch:new(er);
		swatch_XPColor:Show();
		if desc and desc.XPColor then swatch_XPColor:SetColor(explodeRGBA(desc.XPColor)); end
		er:EmbedChild(swatch_XPColor); er:Show();
		ui:InsertFrame(er);
		
		local er = RDXUI.EmbedRight(ui, i18n("Your color"));
		local swatch_selfColor = VFLUI.ColorSwatch:new(er);
		swatch_selfColor:Show();
		if desc and desc.selfColor then swatch_selfColor:SetColor(explodeRGBA(desc.selfColor)); end
		er:EmbedChild(swatch_selfColor); er:Show();
		ui:InsertFrame(er);
		
		function ui:GetDescriptor()
			return { 
				feature = "colorvar_hostility";
				friendlyColor = swatch_friendlyColor:GetColor(); 
				neutralColor = swatch_neutralColor:GetColor();
				hostileColor = swatch_hostileColor:GetColor();
				XPColor = swatch_XPColor:GetColor();
				selfColor = swatch_selfColor:GetColor();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "colorvar_hostility";
			friendlyColor = {r=0, g=0.75, b=0,a=1};
			neutralColor = {r=0.75,g=0.75,b=0,a=1};
			hostileColor = {r=0.75,g=0.15,b=0,a=1};
			XPColor = {r=0.5,g=0.5,b=0.5,a=1};
			selfColor = {r=0,g=0,b=1,a=1};
		};
	end;
});

-- Aichi Priest
-- Black Fraternity 

RDX.RegisterFeature({
    name = "colorvar_hostility_class";
    title = i18n("Color: Hostility & Class");
    category = i18n("Variables: Color");
    multiple = true;
    IsPossible = function(state)
       if not state:Slot("UnitFrame") then return nil; end
      if not state:Slot("EmitClosure") then return nil; end
        return true;
    end;
    ExposeFeature = function(desc, state, errs)
      if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
      if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
      state:AddSlot("Var_" .. desc.name);
      state:AddSlot("ColorVar_" .. desc.name);
      return true;
    end;
    ApplyFeature = function(desc, state)
    	if not desc.friendlyDeathKnightColor then desc.friendlyDeathKnightColor = {r=0.77, g=0.12, b=0.23,a=1}; end
        state:Attach(state:Slot("EmitClosure"), true, function(code)
            code:AppendCode([[
local hostileColor_class_cf = {};
hostileColor_class_cf[1] = ]] .. Serialize(desc.friendlyColor) .. [[;
hostileColor_class_cf[2] = ]] .. Serialize(desc.neutralColor) .. [[;
hostileColor_class_cf[3] = ]] .. Serialize(desc.hostileColor) .. [[;
hostileColor_class_cf[4] = ]] .. Serialize(desc.friendlyPriestColor) .. [[;
hostileColor_class_cf[5] = ]] .. Serialize(desc.friendlyWarlockColor) .. [[;
hostileColor_class_cf[6] = ]] .. Serialize(desc.friendlyHunterColor) .. [[;
hostileColor_class_cf[7] = ]] .. Serialize(desc.friendlyWarriorColor) .. [[;
hostileColor_class_cf[8] = ]] .. Serialize(desc.friendlyPaladinColor) .. [[;
hostileColor_class_cf[9] = ]] .. Serialize(desc.friendlyMageColor) .. [[;
hostileColor_class_cf[10] = ]] .. Serialize(desc.friendlyDruidColor) .. [[;
hostileColor_class_cf[11] = ]] .. Serialize(desc.friendlyShamanColor) .. [[;
hostileColor_class_cf[12] = ]] .. Serialize(desc.friendlyRogueColor) .. [[;
hostileColor_class_cf[13] = ]] .. Serialize(desc.friendlyDeathKnightColor) .. [[;
]]);
        end);
        state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
            code:AppendCode([[
local ]]  .. desc.name .. [[ = hostileColor_class_cf[1];
local classMnemonic = unit:GetClassMnemonic();
if UnitIsFriend(uid, "player") and UnitIsPlayer(uid) then
    if classMnemonic == "PRIEST" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[4];
    elseif classMnemonic == "WARLOCK" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[5];
    elseif classMnemonic == "HUNTER" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[6];
    elseif classMnemonic == "WARRIOR" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[7];
    elseif classMnemonic == "PALADIN" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[8];
    elseif classMnemonic == "MAGE" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[9];
    elseif classMnemonic == "DRUID" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[10];
    elseif classMnemonic == "SHAMAN" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[11];
    elseif classMnemonic == "ROGUE" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[12];
    elseif classMnemonic == "DEATHKNIGHT" then
        ]] .. desc.name .. [[  = hostileColor_class_cf[13];
    else
        ]] .. desc.name .. [[  = hostileColor_class_cf[1];
    end
elseif UnitIsEnemy(uid, "player") then
        ]] .. desc.name .. [[  = hostileColor_class_cf[3];
else
        ]] .. desc.name .. [[  = hostileColor_class_cf[2];
end
]]);
        end);
    end;
    UIFromDescriptor = function(desc, parent, state)
        local ui = VFLUI.CompoundFrame:new(parent);
       
      local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
      name:SetText(i18n("Variable Name"));
      if desc and desc.name then name.editBox:SetText(desc.name); end
      ui:InsertFrame(name);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly color"));
        local swatch_friendlyColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyColor:Show();
        if desc and desc.friendlyColor then swatch_friendlyColor:SetColor(explodeRGBA(desc.friendlyColor)); end
        er:EmbedChild(swatch_friendlyColor); er:Show();
        ui:InsertFrame(er);

        local er = RDXUI.EmbedRight(ui, i18n("Friendly Priest color"));
        local swatch_friendlyPriestColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyPriestColor:Show();
        if desc and desc.friendlyPriestColor then swatch_friendlyPriestColor:SetColor(explodeRGBA(desc.friendlyPriestColor)); end
        er:EmbedChild(swatch_friendlyPriestColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Warlock color"));
        local swatch_friendlyWarlockColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyWarlockColor:Show();
        if desc and desc.friendlyWarlockColor then swatch_friendlyWarlockColor:SetColor(explodeRGBA(desc.friendlyWarlockColor)); end
        er:EmbedChild(swatch_friendlyWarlockColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Hunter color"));
        local swatch_friendlyHunterColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyHunterColor:Show();
        if desc and desc.friendlyHunterColor then swatch_friendlyHunterColor:SetColor(explodeRGBA(desc.friendlyHunterColor)); end
        er:EmbedChild(swatch_friendlyHunterColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Warrior color"));
        local swatch_friendlyWarriorColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyWarriorColor:Show();
        if desc and desc.friendlyWarriorColor then swatch_friendlyWarriorColor:SetColor(explodeRGBA(desc.friendlyWarriorColor)); end
        er:EmbedChild(swatch_friendlyWarriorColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Paladin color"));
        local swatch_friendlyPaladinColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyPaladinColor:Show();
        if desc and desc.friendlyPaladinColor then swatch_friendlyPaladinColor:SetColor(explodeRGBA(desc.friendlyPaladinColor)); end
        er:EmbedChild(swatch_friendlyPaladinColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Mage color"));
        local swatch_friendlyMageColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyMageColor:Show();
        if desc and desc.friendlyMageColor then swatch_friendlyMageColor:SetColor(explodeRGBA(desc.friendlyMageColor)); end
        er:EmbedChild(swatch_friendlyMageColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Druid color"));
        local swatch_friendlyDruidColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyDruidColor:Show();
        if desc and desc.friendlyDruidColor then swatch_friendlyDruidColor:SetColor(explodeRGBA(desc.friendlyDruidColor)); end
        er:EmbedChild(swatch_friendlyDruidColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Shaman color"));
        local swatch_friendlyShamanColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyShamanColor:Show();
        if desc and desc.friendlyShamanColor then swatch_friendlyShamanColor:SetColor(explodeRGBA(desc.friendlyShamanColor)); end
        er:EmbedChild(swatch_friendlyShamanColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Friendly Rogue color"));
        local swatch_friendlyRogueColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyRogueColor:Show();
        if desc and desc.friendlyRogueColor then swatch_friendlyRogueColor:SetColor(explodeRGBA(desc.friendlyRogueColor)); end
        er:EmbedChild(swatch_friendlyRogueColor); er:Show();
        ui:InsertFrame(er);
	
	local er = RDXUI.EmbedRight(ui, i18n("Friendly Deathknight color"));
        local swatch_friendlyDeathKnightColor = VFLUI.ColorSwatch:new(er);
        swatch_friendlyDeathKnightColor:Show();
        if desc and desc.friendlyDeathKnightColor then swatch_friendlyDeathKnightColor:SetColor(explodeRGBA(desc.friendlyDeathKnightColor)); end
        er:EmbedChild(swatch_friendlyDeathKnightColor); er:Show();
        ui:InsertFrame(er);
       
        local er = RDXUI.EmbedRight(ui, i18n("Neutral color"));
        local swatch_neutralColor = VFLUI.ColorSwatch:new(er);
        swatch_neutralColor:Show();
        if desc and desc.neutralColor then swatch_neutralColor:SetColor(explodeRGBA(desc.neutralColor)); end
        er:EmbedChild(swatch_neutralColor); er:Show();
        ui:InsertFrame(er);

        local er = RDXUI.EmbedRight(ui, i18n("Hostile color"));
        local swatch_hostileColor = VFLUI.ColorSwatch:new(er);
        swatch_hostileColor:Show();
        if desc and desc.hostileColor then swatch_hostileColor:SetColor(explodeRGBA(desc.hostileColor)); end
        er:EmbedChild(swatch_hostileColor); er:Show();
        ui:InsertFrame(er);
       
        function ui:GetDescriptor()
            return {
                feature = "colorvar_hostility_class";
                name = name.editBox:GetText();
                friendlyColor = swatch_friendlyColor:GetColor();
                friendlyPriestColor = swatch_friendlyPriestColor:GetColor(); 
                friendlyWarlockColor = swatch_friendlyWarlockColor:GetColor();
                friendlyHunterColor = swatch_friendlyHunterColor:GetColor();
                friendlyWarriorColor = swatch_friendlyWarriorColor:GetColor();
                friendlyPaladinColor = swatch_friendlyPaladinColor:GetColor();   
                friendlyMageColor = swatch_friendlyMageColor:GetColor();
                friendlyDruidColor = swatch_friendlyDruidColor:GetColor();
                friendlyShamanColor = swatch_friendlyShamanColor:GetColor();   
                friendlyRogueColor = swatch_friendlyRogueColor:GetColor();   
		friendlyDeathKnightColor = swatch_friendlyDeathKnightColor:GetColor();
                neutralColor = swatch_neutralColor:GetColor();
                hostileColor = swatch_hostileColor:GetColor();
            };
        end
       
        return ui;
    end;
    CreateDescriptor = function()
        return {
            feature = "colorvar_hostility_class";
            name = "hostilityclassColor";
            friendlyColor = {r=0, g=0.75, b=0,a=1};
            friendlyPriestColor = {r=1.0, g=1.0, b=1.0,a=1}; 
             friendlyWarlockColor = {r=0.58, g=0.51, b=0.79,a=1};
             friendlyHunterColor = {r=0.67, g=0.83, b=0.45,a=1};
             friendlyWarriorColor = {r=0.78, g=0.61, b=0.43,a=1};
             friendlyPaladinColor = {r=0.96, g=0.55, b=0.73,a=1};   
             friendlyMageColor = {r=0.41, g=0.8, b=0.94,a=1};
             friendlyDruidColor = {r=1.0, g=0.49, b=0.04,a=1};
             friendlyShamanColor = {r=0.14, g=0.34, b=1.0,a=1};   
             friendlyRogueColor = {r=1.0, g=0.96, b=0.41,a=1};
	     friendlyDeathKnightColor = {r=0.77, g=0.12, b=0.23,a=1};
            neutralColor = {r=0.75,g=0.75,b=0,a=1};
            hostileColor = {r=0.75,g=0.15,b=0,a=1};
        };
    end;
}); 

RDX.RegisterFeature({
	name = "color_difficulty";
	title = i18n("Color: Difficulty"); 
	category = i18n("Variables: Color");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if state:Slot("ColorVar_difficultyColor") then
			VFL.AddError(errs, i18n("Duplicate variable name.")); return nil;
		end
		state:AddSlot("Var_difficultyColor");
		state:AddSlot("ColorVar_difficultyColor");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode("local difficultyColor = GetQuestDifficultyColor(UnitLevel(uid));");
		end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function()
		return { feature = "color_difficulty"; };
	end;
});

------------ HLS color value transform
local function valOrNil(x)
	if type(x) ~= "string" then return "nil"; end
	x = strtrim(x);
	if x == "" then return "nil"; else return x; end
end

RDX.RegisterFeature({
	name = "color_hlsxform";
	title = i18n("Color: HLS Transform"); 
	category = i18n("Variables: Color");
	multiple = true;
	IsPossible = function(state)
		if not state:HasSlots("UnitFrame", "EmitClosure", "EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if (type(desc.colorVar) ~= "string") or (strtrim(desc.colorVar) == "") then 
			VFL.AddError(errs, i18n("Missing base color.")); return nil;
		end
		if (not state:Slot("ColorVar_" .. desc.colorVar)) then VFL.AddError(errs, i18n("Invalid base color."));	end
		if (type(desc.hx) ~= "string") then	VFL.AddError(errs, i18n("Invalid hue.")); end
		if (type(desc.lx) ~= "string") then	VFL.AddError(errs, i18n("Invalid luminosity.")); end
		if (type(desc.sx) ~= "string") then	VFL.AddError(errs, i18n("Invalid saturation.")); end
		if VFL.HasError(errs) then return nil; end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("ColorVar_" .. desc.name);
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode("local " .. desc.name .. " = VFL.Color:new();");
		end);
		local condition = desc.condVar or "true";
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
if ]] .. condition .. [[ then
	]] .. desc.name .. [[:HLSTransform(]] .. desc.colorVar .. "," .. valOrNil(desc.hx) .. "," .. valOrNil(desc.lx) .. "," .. valOrNil(desc.sx) .. [[);
else
	]] .. desc.name .. [[:set(]] .. desc.colorVar .. [[);
end
]]);
		end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local colorVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("From color"), state, "ColorVar_");
		if desc and desc.colorVar then colorVar:SetSelection(desc.colorVar); end

		local condVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Apply shader only if condition is true:"), state, "BoolVar_", nil,"true", "false");
		if desc and desc.condVar then condVar:SetSelection(desc.condVar); end

		local hx = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Hue modifier (blank for none)"), state, "FracVar_");
		if desc and desc.hx then hx:SetSelection(desc.hx); end

		local lx = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Luminosity modifier (blank for none)"), state, "FracVar_");
		if desc and desc.lx then lx:SetSelection(desc.lx); end

		local sx = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Saturation modifier (blank for none)"), state, "FracVar_");
		if desc and desc.sx then sx:SetSelection(desc.sx); end

		function ui:GetDescriptor()
			return {
				feature = "color_hlsxform"; 
				name = name.editBox:GetText();
				colorVar = colorVar:GetSelection();
				condVar = condVar:GetSelection();
				hx = hx:GetSelection(); lx = lx:GetSelection(); sx = sx:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "color_hlsxform"; name = "hlsColor"; condVar = "true"; };
	end;
});

-- Cripsii

RDX.RegisterFeature({
	name = "ColorVariable: Threat Color";
	title = i18n("Color: Threat Color");
	category = i18n("Variables: Color");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if (not desc.colorVar0) or (not desc.colorVar1) or (not desc.colorVar2) or (not desc.colorVar3) then
			VFL.AddError(errs, i18n("Missing colors.")); return nil;
		end
		if (not state:Slot("ColorVar_" .. desc.colorVar0)) or (not state:Slot("ColorVar_" .. desc.colorVar1)) or (not state:Slot("ColorVar_" .. desc.colorVar2)) or (not state:Slot("ColorVar_" .. desc.colorVar3)) then
			VFL.AddError(errs, i18n("Invalid colors.")); return nil;
		end
		state:AddSlot("Var_" .. desc.name);
		state:AddSlot("ColorVar_" .. desc.name);
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode([[
local ]] .. desc.name .. [[ = nil;
local threatSituation = UnitThreatSituation(uid, "target");
if threatSituation == 0 then
	]] .. desc.name .. [[ = ]] .. desc.colorVar0 .. [[;
elseif threatSituation == 1 then
	]] .. desc.name .. [[ = ]] .. desc.colorVar1 .. [[;
elseif threatSituation == 2 then
	]] .. desc.name .. [[ = ]] .. desc.colorVar2 .. [[;
elseif threatSituation == 3 then
	]] .. desc.name .. [[ = ]] .. desc.colorVar3 .. [[;
end
			]]);
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("THREAT_SITUATION");
		mux:Event_UnitMask("UNIT_THREAT_SITUATION_UPDATE", mask);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);
		local colorVar0 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("No Threat color"), state, "ColorVar_");
		if desc and desc.colorVar0 then colorVar0:SetSelection(desc.colorVar0); end
		local colorVar1 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Gain aggro color"), state, "ColorVar_");
		if desc and desc.colorVar1 then colorVar1:SetSelection(desc.colorVar1); end
		local colorVar2 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Loss Aggro color"), state, "ColorVar_");
		if desc and desc.colorVar2 then colorVar2:SetSelection(desc.colorVar2); end
		local colorVar3 = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Tanking color"), state, "ColorVar_");
		if desc and desc.colorVar3 then colorVar3:SetSelection(desc.colorVar3); end
		
		function ui:GetDescriptor()
			return {
				feature = "ColorVariable: Threat Color"; name = name.editBox:GetText();
				colorVar0 = colorVar0:GetSelection(); colorVar1 = colorVar1:GetSelection(); colorVar2 = colorVar2:GetSelection(); colorVar3 = colorVar3:GetSelection();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "ColorVariable: Threat Color"; name = "ThreatColor"; };
	end;
});
