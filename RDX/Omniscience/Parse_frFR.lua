-- Sigg Rashgaroth
-- Tiras Porah

-- ouvrir avec un editeur UTF8 uniquement

-- The locale for this parser.
local PARSER_LOCALE = "frFR";

-- Preload; make sure we don't load the parser twice
if Omni.parserLoaded then return; end

-- Imported functions and variables
local parseFunc = Omni.ParseFuncs;
local AddLogRow = Omni.AddLogRow;
local match, gmatch, lower = string.find, string.gmatch, string.lower;
local trackedBuffs = Omni.trackedBuffs;
local Afflicted, Buffed, Unafflicted = Omni._Afflicted, Omni._Buffed, Omni._Unafflicted;
local GetUnitByName = RDX.GetUnitByNameIfInGroup;

----------------------------------------------------------
-- IMPORTANT: For non-US locales, uncomment the next line.
-- US is the default locale so we comment it out here.
----------------------------------------------------------
if GetLocale() == PARSER_LOCALE then

RDX.print("Omniscience: Loading " .. PARSER_LOCALE .. " parser.");
Omni.parserLoaded = true;

--- Damage types (as they appear in the WoW combat log)
-- DO NOT change the numbers, only the text.
local dmgToType = Omni.dmgToType;
dmgToType["Melee"] = 1;
dmgToType["Arcane"] = 2;
dmgToType["Feu"] = 3;
dmgToType["Nature"] = 4;
dmgToType["Givre"] = 5;
dmgToType["Ombre"] = 6;
dmgToType["Physique"] = 7;
dmgToType["Sacre"] = 8;

-- Reverse lookup for damage types (do not change)
local typeToDmg = Omni.typeToDmg;
for k,v in pairs(dmgToType) do typeToDmg[v] = k; end

--- Special modifier types (as they appear in the WoW combat log)
-- DO NOT change the numbers, only the text.
local xiTypes = Omni.xiTypes;
xiTypes[1] = "rater";
xiTypes[2] = "esquive";
xiTypes[3] = "parer";
xiTypes[4] = "bloque";
xiTypes[5] = "résiste";
xiTypes[6] = "critique";
xiTypes[7] = "absorber";
xiTypes[8] = "crush";
xiTypes[9] = "érafle";
xiTypes[10] = "insensible";
xiTypes[11] = "reflect"; --todo
xiTypes[12] = "evade"; --todo

-- Reverse lookups for modifier types (do not change)
local i_xiTypes = Omni.i_xiTypes;
for k,v in pairs(xiTypes) do i_xiTypes[v] = k; end

--- Mitigation parsing (Crushing/glancing/partial resist etc.)
local mtbl = {};
local function ComputeMitigationTable(str)
	if not str then return;end
	VFL.empty(mtbl); 
	local i, eo, amt, ty = 0, nil, nil, nil;
	--VFL.print(str);
	for modifier in gmatch(str, "%((.-)%)") do
		--VFL.print(modifier);
		if(modifier == "crushing") then
			eo = 8;
		elseif(modifier == "érafle") then
			eo = 9;
		else
			amt, ty = modifier:match("^(%d+) (.*)$");
			if ty == "bloqué" then ty = "blocked"; end
			if ty == "absorbé" then ty = "absorbed"; end
			if ty == "résiste" then ty = "resisted"; end
			--VFL.print(ty);
			if amt then
				i=i+1; mtbl[i] = ty; i=i+1; mtbl[i] = amt;
				if i == 6 then break; end
			end
		end
	end
	return eo, mtbl[1], mtbl[2], mtbl[3], mtbl[4], mtbl[5], mtbl[6];
end

--- Parsing for each combat log string type.
parseFunc["CombatIncomingHits"] = function()
	local actor, abil, amt, dtype, rest, what, flag;

	-- Tir automatique DE Chloee vous inflige 817 points de dégâts.
	-- Chloee lance Tire automatique et vous inflige un coup critique (1685 points de dégâts).
	flag = 0;
	_, _, abil, actor, amt, rest = match(arg1, "^(.*) DE (.*) vous inflige (%d+) points de dégâts%.(.*)$");
	if actor then AddLogRow(1, actor, abil, amt, 1, nil, ComputeMitigationTable(rest)); flag=1; return; end
	_, _, actor, abil, what, amt, rest = match(arg1, "^(.*) lance (.*) et vous inflige un coup critique %((%d+) points de dégâts%)%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, 1, what, ComputeMitigationTable(rest)); return;
	end
	
	if (flag == 0) then
	-- Melee hit/crit
	-- Matriarche vous inflige 11 points de dégâts. (1 bloqué)
	-- Matriarche vous inflige un coup critique pour 19 points de dégâts.
	_, _, actor, amt, rest = match(arg1, "^(.-) vous inflige un coup critique pour (%d+) points de dégâts%.(.*)$");
	if actor then AddLogRow(1, actor, nil, amt, 1, 6, ComputeMitigationTable(rest)); return; end
	
	_, _, actor, amt, rest = match(arg1, "^(.-) vous inflige (%d+) points de dégâts%.(.*)$");
	if actor then AddLogRow(1, actor, nil, amt, 1, nil, ComputeMitigationTable(rest)); return; end
	
	end

	-- Magic dps
	-- Podfaiss lance Tir et vous inflige 240 points de dégâts DE Arcane.
	-- Tir des Arcanes DE Snow vous inflige un coup critique pour 1463 points de dégâts DE Arcane.
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^(.*) DE (.*) vous inflige un coup critique pour (%d+) points de dégâts DE (.*)%.(.*)$");
	if actor then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], 6, ComputeMitigationTable(rest)); return;
	end
	_, _, actor, abil, amt, dtype, rest = match(arg1, "^(.*) lance (.*) et vous inflige (%d+) points de dégâts DE (.*)%.(.*)$");
	if actor then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	
	-- Magic hit/crit
	-- Ame en peine de mana vous touche et vous inflige 181 points de dégâts DE Arcane.
	-- Ame en peine de mana vous inflige un coup critique pour 329 points de dégâts DE Arcane.
	_, _, actor, amt, dtype, rest = match(arg1, "^(.*) vous touche et vous inflige (%d+) points de dégâts DE (.*)%.(.*)$");
	if actor then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, "Magic", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	_, _, actor, amt, dtype, rest = match(arg1, "^(.*) vous inflige un coup critique pour (%d+) points de dégâts DE (.*)%.(.*)$");
	if actor then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, "Magic", amt, dmgToType[dtype], 6, ComputeMitigationTable(rest)); return; 
	end

end

parseFunc["CombatIncomingMisses"] = function()
	local actor, amt, rest;
	-- Melee block/dodge
	_, _, actor, what = match(arg1, "^(.*) attaque et vous (%w+)%.");
	if actor then 
		if(what == "esquivez") then what = 2; else what = i_xiTypes[what]; end
		AddLogRow(1, actor, nil, 0, 1, what, nil); return; 
	end
	-- Melee parry
	_, _, actor = match(arg1, "^(.*) attaque, mais vous parez le coup%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 3, nil); return;end
	-- Melee miss
	_, _, actor = match(arg1, "^(.*) vous rate%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 1, nil); return; end
	-- Melee absorb
	_, _, actor = match(arg1, "^(.*) attaque%. Vous absorbez tous les dégâts%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 7, nil); return; end
	-- Melee immune
	_, _, actor = match(arg1, "^(.*) attaque, mais vous êtes insensible%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 10); return; end
end

parseFunc["CombatOutgoingHits"] = function()
	local actor, abil, crit, amt, rest, dtype = nil,nil,nil,nil,nil,nil;
	-- Special move (eg Auto Shot) (Votre tir automatique touche Talk et inflige 450 points de dégâts.)
	_, _, abil, actor, amt, rest = match(arg1, "^Votre (.*) touche (.*) et inflige (%d+) points de dégâts%.(.*)$");
	if actor then AddLogRow(2, actor, abil, amt, 1, nil, ComputeMitigationTable(rest)); return; end
	-- Special move (eg Auto Shot) (Votre tir automatique inflige un coup critique à Talk (450 points de dégâts).)
	_, _, abil, actor, amt, rest = match(arg1, "^Votre (.*) inflige un coup critique à (.*) %((%d+) points de dégâts%)%.(.*)$");
	if actor then AddLogRow(2, actor, abil, amt, 1, 6, ComputeMitigationTable(rest)); return; end
	
	-- Vous touchez xxxx et infligez yyy points de dégâts.
	_, _, actor, amt, rest = match(arg1, "^Vous touchez (.*) et infligez (%d+) points de dégâts%.(.*)$");
	if actor then AddLogRow(2, actor, nil, amt, 1, nil, ComputeMitigationTable(rest)); return; end
	-- Vous infligez un coup critique à xxxx (524 points de dégâts).
	_, _, actor, amt, rest = match(arg1, "^Vous infligez un coup critique à (.*) %((%d+) points de dégâts%)%.(.*)$");
	if actor then AddLogRow(2, actor, nil, amt, 1, 6, ComputeMitigationTable(rest)); return; end

	---------------------------------------------------------------------- to do
	-- Magic swing hit/crit
	-- Vous renvoyez 5 points de dégâts DE Sacré à Druide
	--_, _, crit, actor, amt, dtype, rest = match(arg1, "^You h?(c?r?)it (.*) for (%d+) (%w+) damage%.(.*)$");
	--_, _, amt, dtype, actor, rest = match(arg1, "^Vous renvoyez (%d+) points de dégâts DE (.*) à (.*)%.(.*)$");
	--if amt then 
	--	if(dtype == "Sacré") then dtype = "Sacre"; end
	--	AddLogRow(2, actor, "Magic", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return; 
	--end
	---------------------------------------------------------------------- to do

	-- Magic abil hit/crit (baguette)
	-- Votre tir touche sanglier et lui inflige 300 points de dégâts DE Ombre.
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^Votre (.-) touche (.*) et lui inflige (%d+) points de dégâts DE (.*)%.(.*)$");
	if abil then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(2, actor, abil, amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return; 
	end
	-- Votre tir inflige un coup critique à sanglier (528 points de dégâts DE Ombre).
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^Votre (.-) inflige un coup critique à (.*) %((%d+) points de dégâts DE (.*)%)%.(.*)$");
	if abil then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(2, actor, abil, amt, dmgToType[dtype], 6, ComputeMitigationTable(rest)); return; 
	end
end

parseFunc["CombatOutgoingMisses"] = function()
	local actor, what;
	-- Vous ratez Martriache.
	_, _, actor = match(arg1, "^Vous ratez (.*)%.");
	if actor then AddLogRow(2, actor, nil, 0, 1, 1); return; end

	-- Enemy parries/blocks/evades.
	-- Vous attaquez, mais Vieux trotteur pare l'attaque.
	_, _, actor, what = match(arg1, "^Vous attaquez, mais (.*) (%w+) l'attaque%.");
	if actor then 
		if(what == "pare") then what = 3; else what = i_xiTypes[what]; end
			AddLogRow(2, actor, nil, 0, 1, what); 
		return; 
	end
	-- Enemy dodges
	-- Vous attaquez, mais Vieux trotteur esquive.
	_, _, actor, what = match(arg1, "^Vous attaquez, mais (.*) (%w+)%.");
	if actor then 
		what = i_xiTypes[what];
		AddLogRow(2, actor, nil, 0, 1, what); 
		return; 
	end
	
	-- Enemy absorb.
	-- Vous attaquez. PodFaiss absorbe tous les dégâts.
	_, _, actor = match(arg1, "^Vous attaquez%. (.*) absorbe tous les dégâts%.");
	if actor then	AddLogRow(2, actor, nil, 0, 1, 7); return; end
	
	----------------------------------------------------------------------------- to do
	-- Enemy immune
	_, _, actor = match(arg1, "^You attack but (.*) is immune%.");
	if actor then	AddLogRow(2, actor, nil, 0, 1, 10); return; end
	----------------------------------------------------------------------------- to do
end

parseFunc["CombatDeath"] = function()
	if match(arg1, "^Vous êtes mort") then AddLogRow(17); return; end
	local actor;
	_, _, actor = match(arg1, "^Vous avez tué (.*)!$");
	if actor then AddLogRow(16, actor); return; end
end

parseFunc["SpellDirectBuffIn"] = function()
	local actor, amt, abil;
	-- Incoming heal crit
	-- Zelkan vous soigne avec Prière de soins et vous rend 2678 points de vie.
	_, _, actor, abil, amt = match(arg1, "^(.*) vous soigne avec (.*) et vous rend (%d+) points de vie%.");
	if actor then AddLogRow(3, actor, abil, amt, nil, 6); return; end
	-- Incoming heal hit
	-- Soins supérieurs DE Zelkan vous soigne pour 4376 points de vie.
	_, _, abil, actor, amt = match(arg1, "^(.*) DE (.*) vous soigne pour (%d+) points de vie%.");
	if actor then AddLogRow(3, actor, abil, amt); return; end
end

parseFunc["SpellDirectBuffOut"] = function()
	local actor, amt, abil;
	-- Votre Soins rapides soigne Lameuh avec un effet critique et lui rend 3450 points de vie.
	-- Votre Soins rapides a un effet critique et vous rend 3347 points de vie.
	_, _, abil, actor, amt = match(arg1, "^Votre (.*) soigne (.*) avec un effet critique et lui rend (%d+) points de vie%.");
	if abil then AddLogRow(4, actor, abil, amt, nil, 6); return; end
	_, _, abil, amt = match(arg1, "^Votre (.*) a un effet critique et vous rend (%d+) points de vie%.");
	if abil then AddLogRow(7, UnitName("player"), abil, amt, nil, 6); return; end

	-- Votre Soins rapides vous soigne pour 2200 points de vie.
	-- Votre Soins rapides soigne ToTo pour 2230 points de vie.
	_, _, abil, actor, amt = match(arg1, "^Votre (.*) soigne (.*) pour (%d+) points de vie%.");
	if abil then AddLogRow(4, actor, abil, amt); return; end
	_, _, abil, amt = match(arg1, "^Votre (.*) vous soigne pour (%d+) points de vie%.");
	if abil then AddLogRow(7, UnitName("player"), abil, amt); return; end

	-----------------------------------------------------------------------------
	-- Ability performance.
	-- "You perform Vanish." voir avec feign death
	_, _, abil = match(arg1, "^You perform (.*)%.");
	if abil then AddLogRow(18, nil, abil); return; end
	-----------------------------------------------------------------------------
	
	_, _, abil = match(arg1, "^Vous lancez (.*)%.");
	if abil then
		AddLogRow(19, nil, abil); return;
	end
end

parseFunc["SpellDirectDamageIn"] = function()
	local actor, abil, amt, dtype, rest, what;

	-- Melee special hit on you
	-- "Inhume's Sinister Strike hits/crits you for 302. (3 absorbed) (5 blocked)"
	-- Encorner DE Talbuk vous inflige 240 points de dégâts.
	_, _, abil, actor, amt, rest = match(arg1, "^(.*) DE (.*) vous inflige (%d+) points de dégâts%.(.*)$");
	if actor then AddLogRow(1, actor, abil, amt, 7, nil, ComputeMitigationTable(rest)); return; end
	
	----------------------------------------------------------------------------- to do critique
	-- Melee special crit on you
	-- Encorner DE Talbuk vous inflige 240 points de dégâts.
	--_, _, actor, abil, what, amt, rest = match(arg1, "^(.-)'s (.*) h?(c?r?)its you for (%d+)%.(.*)$");
	--if actor then
	--	if what == "" then what = nil; else what = 6; end
	--	AddLogRow(1, actor, abil, amt, 7, what, ComputeMitigationTable(rest)); return;
	--end
	_, _, actor, abil, what, amt, rest = match(arg1, "^(.*) lance (.*) et vous inflige un coup critique %((%d+) points de dégâts%)%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, 7, what, ComputeMitigationTable(rest)); return;
	end
	-----------------------------------------------------------------------------

	-- Magic inc dps
	-- Matriarche lance Eclair et vous inflige 30 points de dégâts DE Nature
	_, _, actor, abil, amt, dtype, rest = match(arg1, "^(.-) lance (.*) et vous inflige (%d+) points de dégâts DE (.*)%.(.*)$");
	if actor then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	-- Brûlure de Ralgare vous inflige un coup critique pour 459 points de dégâts DE Feu.
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^(.*) DE (.*) vous inflige un coup critique pour (%d+) points de dégâts DE (.*)%.(.*)$");
	if abil then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], 6, ComputeMitigationTable(rest)); return;
	end
	
	-- Gerbe de flammes vous touche et vous inflige 3042 points de dégâts DE feu.
	_, _, actor, amt, dtype, rest = match(arg1, "^(.-) vous touche et vous inflige (%d+) points de dégâts DE (.*)%.(.*)$");
	if actor then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, actor, amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	
	-- Talbuk utilise Encorner, mais son adversaire esquive.
	_, _, actor, abil, what = match(arg1, "^(.*) utilise (.*), mais son adversaire (.*)%.");
	if actor then 
		if(what == "pare") then what = 3; else what = i_xiTypes[what]; end -- à vérifier pour le pare
		AddLogRow(1, actor, abil, 0, nil, what); return; 
	end

	-- Coup de Talbuk DE Talbuk vous rate.
	_, _, abil, actor = match(arg1, "^(.*) DE (.*) vous rate.");
	if actor then AddLogRow(1, actor, abil, 0, nil, 1); return; end
	
	-- kuku utilise Attaque mentale, mais cela n'a aucun effet.
	_, _, actor, abil = match(arg1, "^(.*) utilise (.*), mais cela n'a aucun effet%.");
	if actor then AddLogRow(1, actor, abil, 0, nil, 5); return; end

	-- kuku utilise Attaque mentale, mais vous absorbez l'effet.
	_, _, actor, abil = match(arg1, "^(.*) utilise (.*), mais vous absorbez l'effet%.");
	if actor then AddLogRow(1, actor, abil, 0, nil, 7); return; end
	
	-- "Inhume's Feint failed. You are immune."
	-- to do
end

parseFunc["SpellDirectDamageOut"] = function()
	local abil, what, actor, amt, dtype, rest;

	-- Votre Flamme sacrées touche sanglier et lui inflige 528 points de dégâts DE Sacré.
	-- Votre Flamme sacrées inflige un coup critique à sanglier (528 points de dégâts DE Sacré).
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^Votre (.-) touche (.*) et lui inflige (%d+) points de dégâts DE (.*)%.(.*)$");
	if abil then
		if(actor == "you") then actor = UnitName("player"); end
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(2, actor, abil, amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^Votre (.-) inflige un coup critique à (.*) %((%d+) points de dégâts DE (.*)%)%.(.*)$");
	if abil then
		if(actor == "you") then actor = UnitName("player"); end
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(2, actor, abil, amt, dmgToType[dtype], 6, ComputeMitigationTable(rest)); return;
	end

	-- Melee special hit
	-- Votre Visée touche Talbuk et inflige 1050 points de dégâts.
	_, _, abil, actor, amt, rest = match(arg1, "^Votre (.*) touche (.*) et inflige (%d+) points de dégâts%.(.*)$");
	if abil then
		if(actor == "you") then actor = UnitName("player"); end
		AddLogRow(2, actor, abil, amt, 7, nil, ComputeMitigationTable(rest)); return;
	end
	-- Votre Visée inflige un coup critique à Talbuk (2050 points de dégâts).
	_, _, abil, actor, amt, rest = match(arg1, "^Votre (.-) inflige un coup critique à (.*) %((%d+) points de dégâts%)%.(.*)$");
	if abil then
		if(actor == "you") then actor = UnitName("player"); end
		AddLogRow(2, actor, abil, amt, 7, 6, ComputeMitigationTable(rest)); return;
	end

	-- Magic special paladin à vérifier
	-- Vous renvoyez 5 points de dégâts DE Sacré à Druide
	_, _, amt, dtype, actor, rest = match(arg1, "^Vous renvoyez (%d+) points de dégâts DE (.*) à (.*)%.(.*)$");
	if dtype then 
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(2, actor, "Magic", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return; 
	end

	----------------------------------------------------------------------------- to do
	-- Spell resisted/blocked/dodged/parried/evaded
	-- "Your Curse of Agony was resisted by Lugnut."
	--_, _, abil, what, actor = match(arg1, "^Your (.-) i?w?a?s (%w+)ed by (.*)%.$");
	--if abil then 
	--	if(what == "parri") then what = 3; elseif (what == "evad") then what = 12; else what = i_xiTypes[what]; end
	--	AddLogRow(2, actor, abil, 0, nil, what); return;
	--end
	-- Spell missed
	--_,_,abil,actor = match(arg1, "^Your (.-) missed (.*)%.$");
	--if abil then AddLogRow(2, actor, abil, 0, nil, 1); return; end	

	-- Spell absorbed
	-- L'effet de votre Attaque mentale est absorbé par Podfaiss.
	_,_,abil,actor = match(arg1, "^L'effet de votre (.*) est aborbé par (.*)%.$");
	if abil then AddLogRow(2, actor, abil, 0, nil, 7); return; end
	
	-- Spell resisted
	_,_,abil,actor = match(arg1, "^Vous utilisez (.*), mais (.*) résiste%.$");
	if abil then AddLogRow(2, actor, abil, 0, nil, 5); return; end
	
	-----------------------------------------------------------------------------
end

parseFunc["SpellDebuffOut"] = function()
	-- DoTs from self
	local amt, actor, abil, rest, dtype;

	-- Votre Blessure profonde inflige 35 points de dégâts DE Physique à Sanglier infernale.
	_, _, abil, amt, dtype, actor, rest = match(arg1, "^Votre (.*) inflige (%d+) points de dégâts DE (.*) à (.*)%.(.*)$");
	if abil then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(2, actor, abil .. " (DoT)", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return; 
	end

	-------------------------------------------------------
	-- DoT tick absorb
	_,_,abil,actor = match(arg1, "^Your (.-) is absorbed by (.*)%.$");
	if abil then AddLogRow(2, actor, abil .. " (DoT)", 0, nil, 7); return; end
	-------------------------------------------------------
end

parseFunc["SpellDebuffIn"] = function()
	-- DoTs from others
	local amt, actor, abil, rest, dtype;

	-- "Malédiction DE toto vous inflige 240 points de dégâts DE Ombre."
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^(.*) DE (.*) vous inflige (%d+) points de dégâts DE (.*)%.(.*)$");
	if abil then
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(1, actor, abil .. " (DoT)", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end

	-- Debuffs
	-- "Vous subissez les effets de Vunérabilité au Feu (5)."
	_, _, abil, rest = match(arg1, "^Vous subissez les effets de (.*) %((%d+)%)%.");
	if abil then Afflicted(abil, tonumber(rest)); return; end
	
	-- Vous subissez les effets de Mot de l'ombre.
	_, _, abil = match(arg1, "^Vous subissez les effets de (.*)%.");
	if abil then Afflicted(abil, 1); return; end
end

parseFunc["SpellBuffOut"] = function()
	local amt, actor, abil;
	-----------------------------------------------------------------------------
	-- HoTs from you on others
	--_, _, actor, amt, abil = match(arg1, "^(.*) gains (%d+) health from your (.*)%.");
	--if actor then
	--	AddLogRow(4, actor, abil, amt); return;
	--end
	-----------------------------------------------------------------------------
end

parseFunc["SpellBuffIn"] = function()
	local actor, abil, amt, rest;
	
	-- HoTs from others
	-- Le Rénovation DE Scarlak vous fait gagner 725 points de vie
	_, _, abil, actor, amt = match(arg1, "^Le (.*) DE (.*) vous fait gagner (%d+) points de vie%.");
	if amt then AddLogRow(3, actor, abil, amt); return; end
	-- HoTs from self
	-- Rénovation vous rend 634 points de vie.
	_, _, abil, amt = match(arg1, "^(.*) vous rend (%d+) points de vie%.");
	if amt then AddLogRow(7, UnitName("player"), abil, amt); return; end

	-- Ignore "You gain 1 Rage from Bloodrage"
	-- rage sanguinaire vous fait gagner 1 rage.
	--_, _, amt, stuff, abil = match(arg1, "^You gain (%d+) (%w+) from (.*)%.");
	--if amt then
	--	return;
	--end

	-- "You gain Prayer of Mending (5)."
	_, _, abil, rest = match(arg1, "^Vous gagnez (.*) %((%d+)%)%.");
	if abil then Buffed(abil, tonumber(rest)); return; end
	
	-- "You gain Shield Block."
	-- Vous gagnez Mot de pouvoir : Bouclier
	_, _, abil = match(arg1, "^Vous gagnez (.*)%.");
	if abil then Buffed(abil, 1); return; end
end

parseFunc["SpellAuraFaded"] = function()
	local abil;
	-- Rénovation vient de se dissiper
	_, _, abil = match(arg1, "^(.*) vient de se dissiper%.");
	if abil then Unafflicted(abil); return; end	
end

parseFunc["SpellDamageShields"] = function()
	local what, actor, amt, dtype, rest;

	-- Vous renvoyez 5 points de dégâts DE Sacré à Druide
	_, _, amt, dtype, actor, rest = match(arg1, "^Vous renvoyez (%d+) points de dégâts DE (.*) à (.*)%.(.*)$");
	if amt then 
		if(dtype == "Sacré") then dtype = "Sacre"; end
		AddLogRow(2, actor, "Reflect", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return; 
	end
end

----------------------------------------------------------
-- IMPORTANT: For non-US locales, uncomment the next line.
-- US is the default locale so we comment it out here.
----------------------------------------------------------
end
