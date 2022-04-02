-- The locale for this parser.
local PARSER_LOCALE = "enUS";

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
-- if GetLocale() == PARSER_LOCALE then

RDX.print("Omniscience: Loading " .. PARSER_LOCALE .. " parser.");
Omni.parserLoaded = true;

--- Damage types (as they appear in the WoW combat log)
-- DO NOT change the numbers, only the text.
local dmgToType = Omni.dmgToType;
dmgToType["Melee"] = 1;
dmgToType["Arcane"] = 2;
dmgToType["Fire"] = 3;
dmgToType["Nature"] = 4;
dmgToType["Frost"] = 5;
dmgToType["Shadow"] = 6;
dmgToType["Physical"] = 7;
dmgToType["Holy"] = 8;

-- Reverse lookup for damage types (do not change)
local typeToDmg = Omni.typeToDmg;
for k,v in pairs(dmgToType) do typeToDmg[v] = k; end

--- Special modifier types (as they appear in the WoW combat log)
-- DO NOT change the numbers, only the text.
local xiTypes = Omni.xiTypes;
xiTypes[1] = "miss";
xiTypes[2] = "dodge";
xiTypes[3] = "parry";
xiTypes[4] = "block";
xiTypes[5] = "resist";
xiTypes[6] = "crit";
xiTypes[7] = "absorb";
xiTypes[8] = "crush";
xiTypes[9] = "glance";
xiTypes[10] = "immune";
xiTypes[11] = "reflect";
xiTypes[12] = "evade";

-- Reverse lookups for modifier types (do not change)
local i_xiTypes = Omni.i_xiTypes;
for k,v in pairs(xiTypes) do i_xiTypes[v] = k; end

--- Mitigation parsing (Crushing/glancing/partial resist etc.)
local mtbl = {};
local function ComputeMitigationTable(str)
	VFL.empty(mtbl); 
	local i, eo, amt, ty = 0, nil, nil, nil;
	for modifier in gmatch(str, "%((.-)%)") do
		if(modifier == "crushing") then
			eo = 8;
		elseif(modifier == "glancing") then
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
	_, _, actor, abil, what, amt, rest = match(arg1, "^(.-)'s (.*) h?(c?r?)its you for (%d+)%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, 1, what, ComputeMitigationTable(rest)); return;
	end
	-- Melee hit/crit
	_, _, actor, what, amt, rest = match(arg1, "^(.-) h?(c?r?)its you for (%d+)%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, nil, amt, 1, what, ComputeMitigationTable(rest)); return;
	end
	-- Magic dps (eg wanding) (Venificus's Shoot hits you for 120 Shadow damage.)
	_, _, actor, abil, what, amt, dtype, rest = match(arg1, "^(.-)'s (.*) h?(c?r?)its you for (%d+) (%w+) damage%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], what, ComputeMitigationTable(rest)); return;
	end
	-- Magic hit/crit
	_, _, actor, what, amt, dtype, rest = match(arg1, "^(.-) h?(c?r?)its you for (%d+) (%w+) damage%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, "Magic", amt, dmgToType[dtype], what, ComputeMitigationTable(rest)); return;
	end
end

parseFunc["CombatIncomingMisses"] = function()
	local actor, amt, rest;
	-- Melee block/dodge/parry
	_, _, actor, what = match(arg1, "^(.*) attacks%. You (%w+)%.");
	if actor then 
		what = i_xiTypes[what];
		AddLogRow(1, actor, nil, 0, 1, what, nil); return; 
	end
	-- Melee miss
	_, _, actor = match(arg1, "^(.*) misses you%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 1, nil); return; end
	-- Melee absorb
	_, _, actor = match(arg1, "^(.*) attacks%. You absorb all the damage%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 7, nil); return; end
	-- Melee immune
	_, _, actor = match(arg1, "^(.*) attacks but you are immune%.");
	if actor then AddLogRow(1, actor, nil, 0, 1, 10); return; end
end

parseFunc["CombatOutgoingHits"] = function()
	local actor, abil, crit, amt, rest, school = nil,nil,nil,nil,nil,nil;
	-- Melee swing hit/crit
	_, _, crit, actor, amt, rest = match(arg1, "^You h?(c?r?)it (.*) for (%d+)%.(.*)$");
	if crit then 
		if crit == "" then crit = nil; else crit = 6; end
		AddLogRow(2, actor, nil, amt, 1, crit, ComputeMitigationTable(rest)); return; 
	end
	-- Magic swing hit/crit
	_, _, crit, actor, amt, school, rest = match(arg1, "^You h?(c?r?)it (.*) for (%d+) (%w+) damage%.(.*)$");
	if crit then 
		if crit == "" then crit = nil; else crit = 6; end
		AddLogRow(2, actor, "Magic", amt, dmgToType[school], crit, ComputeMitigationTable(rest)); return; 
	end
	-- Magic abil hit/crit
	_, _, abil, crit, actor, amt, school, rest = match(arg1, "^Your (.-) h?(c?r?)its (.*) for (%d+) (%w+) damage%.(.*)$");
	if abil then 
		if crit == "" then crit = nil; else crit = 6; end
		AddLogRow(2, actor, abil, amt, dmgToType[school], crit, ComputeMitigationTable(rest)); return; 
	end
end

parseFunc["CombatOutgoingMisses"] = function()
	local actor, what;
	-- You miss enemy.
	_, _, actor = match(arg1, "^You miss (.*)%.");
	if actor then AddLogRow(2, actor, nil, 0, 1, 1); return; end
	-- Enemy parries/dodges/blocks/evades.
	_, _, actor, what = match(arg1, "^You attack%. (.*) (%w+)s%.");
	if actor then 
		if(what == "parrie") then what = 3; else what = i_xiTypes[what]; end
		AddLogRow(2, actor, nil, 0, 1, what); 
		return; 
	end
	-- Enemy absorb.
	_, _, actor = match(arg1, "^You attack%. (.*) absorbs all the damage%.");
	if actor then	AddLogRow(2, actor, nil, 0, 1, 7); return; end
	-- Enemy immune
	_, _, actor = match(arg1, "^You attack but (.*) is immune%.");
	if actor then	AddLogRow(2, actor, nil, 0, 1, 10); return; end
end

parseFunc["CombatDeath"] = function()
	if match(arg1, "^You die") then AddLogRow(17); return; end
	local actor;
	_, _, actor = match(arg1, "^You have slain (.*)!$");
	if actor then AddLogRow(16, actor); return; end
end

parseFunc["SpellDirectBuffIn"] = function()
	local actor, amt, abil;
	-- Incoming heal crit
	_, _, actor, abil, amt = match(arg1, "^(.-)'s (.*) critically heals you for (%d+)");
	if actor then
		AddLogRow(3, actor, abil, amt, nil, 6); return;
	end
	-- Incoming heal hit
	_, _, actor, abil, amt = match(arg1, "^(.-)'s (.*) heals you for (%d+)");
	if actor then
		AddLogRow(3, actor, abil, amt); return;
	end
end

parseFunc["SpellDirectBuffOut"] = function()
	local actor, amt, abil;
	-- Outgoing heal crit
	-- "Your Flash Heal critically heals you for 362."
	_, _, abil, actor, amt = match(arg1, "^Your (.*) critically heals (.*) for (%d+)%.");
	if abil then
		if (actor == "you") then
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
	_, _, abil, actor, amt = match(arg1, "^Your (.*) heals (.*) for (%d+)%.");
	if abil then
		if (actor == "you") then
			AddLogRow(7, UnitName("player"), abil, amt);
--			AddLogRow(4, UnitName("player"), abil, amt);
			return;
		else
			AddLogRow(4, actor, abil, amt); return;
		end
	end
	-- Ability performance.
	-- "You perform Vanish."
	_, _, abil = match(arg1, "^You perform (.*)%.");
	if abil then
		AddLogRow(18, nil, abil); return;
	end
	-- Sigg add for totem
	_, _, abil = match(arg1, "^You cast (.*)%.");
	if abil then
		AddLogRow(19, nil, abil); return;
	end
	
end

parseFunc["SpellDirectDamageIn"] = function()
	local actor, abil, amt, dtype, rest, what;
	-- Melee special hit/crit on you
	-- "Inhume's Sinister Strike hits/crits you for 302. (3 absorbed) (5 blocked)"
	_, _, actor, abil, what, amt, rest = match(arg1, "^(.-)'s (.*) h?(c?r?)its you for (%d+)%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, 7, what, ComputeMitigationTable(rest)); return;
	end
	-- Magic inc dps
	-- "Isotriv's Lightning Bolt hits/crits you for 228 Nature damage."
	_, _, actor, abil, what, amt, dtype, rest = match(arg1, "^(.-)'s (.*) h?(c?r?)its you for (%d+) (%w+) damage%.(.*)$");
	if actor then
		if what == "" then what = nil; else what = 6; end
		AddLogRow(1, actor, abil, amt, dmgToType[dtype], what, ComputeMitigationTable(rest)); return;
	end
	-- Blah's Blah was resisted/dodged/parried
	_, _, actor, abil, what = match(arg1, "^(.-)'s (.*) was (%w+)ed.");
	if actor then 
		if(what == "parri") then what = 3; else what = i_xiTypes[what]; end
		AddLogRow(1, actor, abil, 0, nil, what); return; 
	end
	-- Fafhrd's Multi-Shot misses you.
	_, _, actor, abil = match(arg1, "^(.-)'s (.*) misses you.");
	if actor then
		AddLogRow(1, actor, abil, 0, nil, 1); return;
	end
	-- You absorb Blah's Blah
	_, _, actor, abil = match(arg1, "^You absorb (.-)'s (.*).");
	if actor then AddLogRow(1, actor, abil, 0, nil, 7); return; end
	-- "Inhume's Feint failed. You are immune."
end

parseFunc["SpellDirectDamageOut"] = function()
	local abil, what, actor, amt, dtype, rest;
	-- Spell hit
	_, _, abil, what, actor, amt, dtype, rest = match(arg1, "^Your (.*) h?(c?r?)its (.*) for (%d+) (%w+) damage%.(.*)$");
	if abil then
		if what == "" then what = nil; else what = 6; end
		if(actor == "you") then actor = UnitName("player"); end
		AddLogRow(2, actor, abil, amt, dmgToType[dtype], what, ComputeMitigationTable(rest)); return;
	end
	-- Melee special hit
	_, _, abil, what, actor, amt, rest = match(arg1, "^Your (.*) h?(c?r?)its (.*) for (%d+)%.(.*)$");
	if abil then
		if what == "" then what = nil; else what = 6; end
		if(actor == "you") then actor = UnitName("player"); end
		AddLogRow(2, actor, abil, amt, 7, what, ComputeMitigationTable(rest)); return;
	end
	-- Spell resisted/blocked/dodged/parried/evaded/absorbed
	-- "Your Curse of Agony was resisted by Lugnut."
	_, _, abil, what, actor = match(arg1, "^Your (.-) i?w?a?s (%w+)ed by (.*)%.$");
	if abil then 
		if(what == "parri") then what = 3; elseif (what == "evad") then what = 12; else what = i_xiTypes[what]; end
		AddLogRow(2, actor, abil, 0, nil, what); return;
	end
	-- Spell missed
	_,_,abil,actor = match(arg1, "^Your (.-) missed (.*)%.$");
	if abil then AddLogRow(2, actor, abil, 0, nil, 1); return; end
end

parseFunc["SpellDebuffOut"] = function()
	-- DoTs from self
	local amt, actor, abil, rest, dtype;
	_, _, actor, amt, dtype, abil, rest = match(arg1, "^(.*) suffers (%d+) (%w+) damage from your (.*)%.(.*)$");
	if actor then
		AddLogRow(2, actor, abil .. " (DoT)", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	-- DoT tick absorb
	_,_,abil,actor = match(arg1, "^Your (.-) is absorbed by (.*)%.$");
	if abil then AddLogRow(2, actor, abil .. " (DoT)", 0, nil, 7); return; end
end

parseFunc["SpellDebuffIn"] = function()
	-- DoTs from others
	-- "You suffer 73 Physical damage from Inhume's Garrotte"
	local amt, actor, abil, rest, dtype;
	_, _, amt, dtype, actor, abil, rest = match(arg1, "^You suffer (%d+) (%w+) damage from (.*)'s (.*)%.(.*)$");
	if amt then
		AddLogRow(1, actor, abil .. " (DoT)", amt, dmgToType[dtype], nil, ComputeMitigationTable(rest)); return;
	end
	-- Debuffs
	-- "You are afflicted by Sunder Armor (5)."
	_, _, abil, rest = match(arg1, "^You are afflicted by (.*) %((%d+)%)%.");
	if abil then Afflicted(abil, tonumber(rest)); return; end
	-- "You are afflicted by Unbalancing Strike."
	_, _, abil = match(arg1, "^You are afflicted by (.*)%.");
	if abil then Afflicted(abil, 1); return; end
end

parseFunc["SpellBuffOut"] = function()
	local amt, actor, abil;
	-- HoTs from you on others
	_, _, actor, amt, abil = match(arg1, "^(.*) gains (%d+) health from your (.*)%.");
	if actor then
		AddLogRow(4, actor, abil, amt); return;
	end
end

parseFunc["SpellBuffIn"] = function()
	local actor, abil, amt, rest;
	-- HoTs from others
	_, _, amt, actor, abil = match(arg1, "^You gain (%d+) health from (.*)'s (.*)%.");
	if amt then AddLogRow(3, actor, abil, amt); return; end
	-- HoTs from self
	_, _, amt, abil = match(arg1, "^You gain (%d+) health from (.*)%.");
	if amt then
		AddLogRow(7, UnitName("player"), abil, amt); 
--		AddLogRow(4, UnitName("player"), abil, amt);
		return;
	end
	-- Ignore "You gain 1 Rage from Bloodrage"
	_, _, amt, stuff, abil = match(arg1, "^You gain (%d+) (%w+) from (.*)%.");
	if amt then
		return;
	end
	-- "You gain Prayer of Mending (5)."
	_, _, abil, rest = match(arg1, "^You gain (.*) %((%d+)%)%.");
	if abil then Buffed(abil, tonumber(rest)); return; end
	-- "You gain Shield Block."
	_, _, abil = match(arg1, "^You gain (.*)%.");
	if abil then Buffed(abil, 1); return; end
end

parseFunc["SpellAuraFaded"] = function()
	local abil;
	-- "Unbalancing Strike fades from you."
	_, _, abil = match(arg1, "^(.*) fades from you.");
	if abil then Unafflicted(abil); return; end	
end

----------------------------------------------------------
-- IMPORTANT: For non-US locales, uncomment the next line.
-- US is the default locale so we comment it out here.
----------------------------------------------------------
-- end
