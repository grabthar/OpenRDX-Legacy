-- The locale for this parser.
local PARSER_LOCALE = "deDE";

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

RDX.print("Omniscience: L\195\164dt... " .. PARSER_LOCALE .. " parser.");
Omni.parserLoaded = true;

--- Damage types (as they appear in the WoW combat log)
-- DO NOT change the numbers, only the text.
local dmgToType = Omni.dmgToType;
dmgToType["K\195\188rperlich"] = 1;
dmgToType["Arkan"] = 2;
dmgToType["Feuer"] = 3;
dmgToType["Natur"] = 4;
dmgToType["Frost"] = 5;
dmgToType["Schatten"] = 6;
dmgToType["Physisch"] = 7;
dmgToType["Heilig"] = 8;

-- Reverse lookup for damage types (do not change)
local typeToDmg = Omni.typeToDmg;
for k,v in pairs(dmgToType) do typeToDmg[v] = k; end

--- Special modifier types (as they appear in the WoW combat log)
-- DO NOT change the numbers, only the text.
local xiTypes = Omni.xiTypes;
xiTypes[1] = "verfehlt";
xiTypes[2] = "weicht aus";
xiTypes[3] = "pariert";
xiTypes[4] = "blockt";
xiTypes[5] = "wiederstanden";
xiTypes[6] = "kritisch";
xiTypes[7] = "absorbiert";
xiTypes[8] = "schmetternd";
xiTypes[9] = "gestreift";
xiTypes[10] = "immun";
xiTypes[11] = "reflektiert";
xiTypes[12] = "entgehen"; -- not sure here

-- Reverse lookups for modifier types (do not change)
local i_xiTypes = Omni.i_xiTypes;
for k,v in pairs(xiTypes) do i_xiTypes[v] = k; end

--- Mitigation parsing (Crushing/glancing/partial resist etc.)
local mtbl = {};
local function ComputeMitigationTable(str)
	VFL.empty(mtbl); 
	local i, eo, amt, ty = 0, nil, nil, nil;
	for modifier in gmatch(str, "%((.-)%)") do
		if(modifier == "schmetternd") then
			eo = 8;
		elseif(modifier == "gestreift") then
			eo = 9;
		else
			amt, ty = modifier:match("^(%d+) (%w+)$");
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
	local actor, abil, amt, dtype, rest, what;
	-- Special move (eg Auto Shot) (Fafhrd's Auto Shot hits you for 350.)
	_, _, actor, abil, what, amt, rest = match(arg1, "^(.-) trifft Euch mit '(.*)' ?([kritisch]? f\195\188r (%d+) Schaden%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, 1, what, ComputeMitigationTable(rest)); return;
	end
	-- Melee hit/crit	- Sch�delhauer der Felsenkiefer trifft Euch f�r 10 Schaden.
	_, _, actor, what, amt, rest = match(arg1, "^(.-) trifft Euch ?([kritisch]?) f\195\188r (%d+) Schaden%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, nil, amt, 1, what, ComputeMitigationTable(rest)); return;
	end
	-- Magic dps (eg wanding) (Venificus's Shoot hits you for 120 Shadow damage.)
	_, _, actor, abil, what, amt, dtype, rest = match(arg1, "^(.-) trifft Euch mit '(.*)' ?([kritisch]?) f\195\188r (%d+) (%w+)schaden%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], what, ComputeMitigationTable(rest)); return;
	end
	-- Magic hit/crit
	_, _, actor, what, amt, dtype, rest = match(arg1, "^(.-) trifft Euch ?([kritisch]?) f\195\188r (%d+) (%w+)schaden%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, "Magic", amt, dmgToType[dtype], what, ComputeMitigationTable(rest)); return;
	end
end

parseFunc["CombatIncomingMisses"] = function()
	local actor, amt, rest;
	-- Melee block/dodge/parry
	_, _, actor, what = match(arg1, "^(.*) greift an%. Ihr (%w+)%.");
	if actor then 
		what = i_xiTypes[what];
		AddLogRow(1, actor, nil, 0, 1, what, nil); return; 
	end
	-- Melee miss
	_, _, actor = match(arg1, "^(.*) verfehlt euch%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 1, nil); return; end
	-- Melee absorb
	_, _, actor = match(arg1, "^(.*) greift an%. Ihr absorbiert allen Schaden%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 7, nil); return; end
	-- Melee immune
	_, _, actor = match(arg1, "^(.*) greift an, aber ihr seid immun%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 10); return; end
end

parseFunc["CombatOutgoingHits"] = function()
	local actor, abil, crit, amt, rest, school = nil,nil,nil,nil,nil,nil;
	-- Melee swing hit/crit
	_, _, actor, amt, rest = match(arg1, "^Ihr trefft (.*)%. Schaden: (%d+)%.(.*)$");
	if actor then 
		AddLogRow(2, actor, nil, amt, 1, crit, ComputeMitigationTable(rest)); return; 
	end
	_, _, actor, amt, rest = match(arg1, "^Ihr trefft (.*) kritisch: (%d+)%.(.*)$");
	if actor then 
		AddLogRow(2, actor, nil, amt, 1, 6, ComputeMitigationTable(rest)); return; 
	end
	-- Magic swing hit/crit
	-- can't test the next line
	_, _, crit, actor, amt, school, rest = match(arg1, "Ihr trefft (.*) f\195\188r (%w)schaden%.(.*)$"); 
	if actor then 
		AddLogRow(2, actor, "Magic", amt, dmgToType[school], crit, ComputeMitigationTable(rest)); return; 
	end
	-- Magic abil hit/crit
	_, _, abil, actor, amt, school, rest = match(arg1, "(.-) trifft (.*)%. Schaden: (%d+) (%w+)%.(.*)$");
	if abil then 
		AddLogRow(2, actor, abil, amt, dmgToType[school], crit, ComputeMitigationTable(rest)); return; 
	end
	_, _, abil, actor, amt, school, rest = match(arg1, "(.-) trifft (.*) kritisch: (%d+) (%w+)schaden%.(.*)$");
	if abil then 
		AddLogRow(2, actor, abil, amt, dmgToType[school], 6, ComputeMitigationTable(rest)); return; 
	end
end

parseFunc["CombatOutgoingMisses"] = function()
	local actor, what;
	-- You miss enemy.
	_, _, actor = match(arg1, "^Ihr verfehlt (.*)%.");
	if actor then AddLogRow(2, actor, nil, 0, 1, 1); return; end
	-- Enemy parries/dodges/blocks/evades.
	_, _, actor, what = match(arg1, "^Ihr greift an%. (.*) (%w+)%.");
	if actor then 
		if(what == "pariert") then what = 3; else what = i_xiTypes[what]; end
		AddLogRow(2, actor, nil, 0, 1, what); 
		return; 
	end
	-- Enemy absorb.
	_, _, actor = match(arg1, "^Ihr greift an%. (.*) absorbiert%.");
	if actor then	AddLogRow(2, actor, nil, 0, 1, 7); return; end
	-- Enemy immune
	_, _, actor = match(arg1, "^Ihr greift an aber (.*) ist immun%.");
	if actor then	AddLogRow(2, actor, nil, 0, 1, 10); return; end
end

parseFunc["CombatDeath"] = function()
	if match(arg1, "^Ihr sterbt") then AddLogRow(17); return; end
	local actor;
	_, _, actor = match(arg1, "^Ihr habt (.*) get\195\188tet!$");
	if actor then AddLogRow(16, actor); return; end
end

parseFunc["SpellDirectBuffIn"] = function()
	local actor, amt, abil, crit = nil,nil,nil,nil;
	-- Incoming heal crit
	if(match(string.lower(arg1), "kritisch")) then crit = 6; end;
	-- Incoming heal hit
	_, _, actor, abil, amt = match(arg1, "(.-)'s (.*) heilt Euch um (%d+) Punkte%.$");
	if actor then
		AddLogRow(3, actor, abil, amt, crit); return;
	end
	_, _, abil, amt = match(arg1, "^(.*) heilt Euch um (%d+) Punkte%.$");
	if abil then
		AddLogRow(3, UnitName("player"), abil, amt, crit); return;
	end
end

parseFunc["SpellDirectBuffOut"] = function()
	local actor, amt, abil;
	-- Outgoing heal crit
	-- "Your Flash Heal critically heals you for 362."
	_, _, abil, actor, amt = match(arg1, "^Kritische Heilung: (.*) heilt (.*) um (%d+) Punkte%.");
	if abil then
		if (actor == "Euch") then
			-- Self heal
			AddLogRow(7, UnitName("player"), abil, amt, nil, 6); 
--			AddLogRow(4, UnitName("player"), abil, amt, nil, 6);
			return;
		else
			AddLogRow(4, actor, abil, amt, nil, 6); return;
		end
	end
	-- Outgoing heal
	-- "Your Flash Heal heals you for 552."
	-- "Your Flash Heal heals Astranaar Sentinel for 241."
	_, _, abil, actor, amt = match(arg1, "(.*) heilt (.*) um (%d+) Punkte%.");
	if abil then
		if (actor == "Euch") then
			AddLogRow(7, UnitName("player"), abil, amt);
--			AddLogRow(4, UnitName("player"), abil, amt);
			return;
		else
			AddLogRow(4, actor, abil, amt); return;
		end
	end
	-- Ability performance.
	-- "You perform Vanish."
	_, _, abil = match(arg1, "^Ihr f\195\188hrt (.*) aus%.");
	if abil then
		AddLogRow(18, nil, abil); return;
	end
	
	-- Sigg add for totem
	_, _, abil = match(arg1, "^Ihr wirkt (.+)%.");
	if abil then
		AddLogRow(19, nil, abil); return;
	end
end

parseFunc["SpellDirectDamageIn"] = function()
	local actor, abil, amt, dtype, rest, what;
	-- Melee special hit/crit on you
	-- "Inhume's Sinister Strike hits/crits you for 302. (3 absorbed) (5 blocked)"
	_, _, actor, abil, what, amt, rest = match(arg1, "^(.-) trifft Euch mit '(.*)' ?([kritisch]? f\195\188r (%d+) Schaden%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, 7, what, ComputeMitigationTable(rest)); return;
	end
	-- Magic inc dps
	-- "Isotriv's Lightning Bolt hits/crits you for 228 Nature damage."
	_, _, actor, abil, what, amt, dtype, rest = match(arg1, "^(.-) trifft Euch mit '(.*)' ?([kritisch]?) f\195\188r (%d+) (%w+)schaden%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], what, ComputeMitigationTable(rest)); return;
	end
	-- Blah's Blah was resisted/dodged/parried
	_, _, actor, abil, what = match(arg1, "^(.-)'s (.*) wurde (%w+).");
	if actor then 
		if(what == "pariert") then what = 3; else what = i_xiTypes[what]; end
		AddLogRow(1, actor, abil, 0, nil, what); return; 
	end
	-- Fafhrd's Multi-Shot misses you.
	_, _, actor, abil = match(arg1, "^(.-)'s (.*) verfehlt Euch.");
	if actor then
		AddLogRow(1, actor, abil, 0, nil, 1); return;
	end
	-- You absorb Blah's Blah
	_, _, actor, abil = match(arg1, "^Ihr absorbiert (.-)'s (.*).");
	if actor then AddLogRow(1, actor, abil, 0, nil, 7); return; end
	-- "Inhume's Feint failed. You are immune."
end

parseFunc["SpellDirectDamageOut"] = function()
	local abil, what, actor, amt, dtype, rest;
	-- Spell hit
	_, _, abil, actor, amt, dtype, rest = match(arg1, "^(.-) trifft (.*)%. Schaden: (%d+) (%w+)%.(.*)$");
	if abil then
		if(actor == "you") then actor = UnitName("player"); end
		AddLogRow(2, actor, abil, amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	_, _, abil, actor, amt, dtype, rest = match(arg1, "(.-) trifft (.*) kritisch: (%d+) (%w+)schaden%.(.*)$");
	if abil then
		if(actor == "you") then actor = UnitName("player"); end
		AddLogRow(2, actor, abil, amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	
	-- Melee special hit
	_, _, actor, amt, rest = match(arg1, "^Ihr trefft (.*)%. Schaden: (%d+)%.(.*)$");
	if actor then 
		AddLogRow(2, actor, nil, amt, 1, crit, ComputeMitigationTable(rest)); return; 
	end
	_, _, actor, amt, rest = match(arg1, "^Ihr trefft (.*) kritisch: (%d+)%.(.*)$");
	if actor then 
		AddLogRow(2, actor, nil, amt, 1, 6, ComputeMitigationTable(rest)); return; 
	end
	-- Spell resisted/blocked/dodged/parried/evaded/absorbed
	-- "Your Curse of Agony was resisted by Lugnut."
	_, _, abil, actor, what = match(arg1, "^Euer (.-) wurde von (%w+) (.*)%.$");
	if abil then 
		if(what == "pariert") then what = 3; elseif (what == "entgangen") then what = 12; else what = i_xiTypes[what]; end
		AddLogRow(2, actor, abil, 0, nil, what); return;
	end
	-- Spell missed
	_,_,abil,actor = match(arg1, "^Your (.-) missed (.*)%.$");
	if abil then AddLogRow(2, actor, abil, 0, nil, 1); return; end
end

parseFunc["SpellDebuffOut"] = function()
	-- DoTs from self
	local amt, actor, abil, rest, dtype;
	_, _, actor, amt, dtype, abil, rest = match(arg1, "^(.*) erleidet (%d+) (%w+)schaden %(durch (.*)%)%.(.*)$");
	if actor then
		AddLogRow(2, actor, abil .. " (DoT)", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	-- DoT tick absorb
	_,_,abil,actor = match(arg1, "^Euer (.-) wurde von (.*) absorbiert%.$");
	if abil then AddLogRow(2, actor, abil .. " (DoT)", 0, nil, 7); return; end
end

parseFunc["SpellDebuffIn"] = function()
	-- DoTs from others
	-- "You suffer 73 Physical damage from Inhume's Garrotte"
	local amt, actor, abil, rest, dtype;
	_, _, amt, dtype, actor, abil, rest = match(arg1, "^Ihr erleidet (%d+) (%w+)schaden %(durch (.*)%)'s (.*)%.(.*)$");
	if amt then
		AddLogRow(1, actor, abil .. " (DoT)", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	-- Debuffs
	-- "You are afflicted by Sunder Armor (5)."
	_, _, abil, rest = match(arg1, "^Ihr seid betroffen von (.*) %((%d+)%)%.");
	if abil then Afflicted(abil, tonumber(rest)); return; end
	-- "You are afflicted by Unbalancing Strike."
	_, _, abil = match(arg1, "^Ihr seid betroffen von (.*)%.");
	if abil then Afflicted(abil, 1); return; end
end

parseFunc["SpellBuffOut"] = function()
	local amt, actor, abil;
	-- HoTs from you on others
	_, _, actor, amt, abil = match(arg1, "^(.*) erh\195\164lt (%d+) Gesundheit durch (.*)%.");
	if actor then
		AddLogRow(4, actor, abil, amt); return;
	end
end

parseFunc["SpellBuffIn"] = function()
	local actor, abil, amt, rest;
	-- HoTs from others
	_, _, amt, actor, abil = match(arg1, "^Ihr erhaltet (%d+) Leben von (.*)'s (.*)%.");
	if amt then AddLogRow(3, actor, abil, amt); return; end
	-- HoTs from self
	_, _, amt, abil = match(arg1, "^Ihr erhaltet (%d+) Gesundheit durch (.*)%.");
	if amt then
		AddLogRow(7, UnitName("player"), abil, amt); 
--		AddLogRow(4, UnitName("player"), abil, amt);
		return;
	end
	-- Ignore "You gain 1 Rage from Bloodrage"
	_, _, amt, stuff, abil = match(arg1, "^Ihr erhaltet (%d+) (%w+) von (.*)%.");
	if amt then
		return;
	end
	-- "You gain Prayer of Mending (5)."
	_, _, abil, rest = match(arg1, "^Ihr bekommt (.*) %((%d+)%)%.");
	if abil then Buffed(abil, tonumber(rest)); return; end
	-- "You gain Shield Block."
	_, _, abil = match(arg1, "^Ihr bekommt (.*)%.");
	if abil then Buffed(abil, 1); return; end
end

parseFunc["SpellAuraFaded"] = function()
	local abil;
	-- "Unbalancing Strike fades from you."
	_, _, abil = match(arg1, "^(.*) schwindet von Euch.");
	if abil then Unafflicted(abil); return; end	
end

----------------------------------------------------------
-- IMPORTANT: For non-US locales, uncomment the next line.
-- US is the default locale so we comment it out here.
----------------------------------------------------------
end
