-- OpenRDX
-- Sigg Rashgaroth
-- Tiras Porah

-- Imported functions and variables
local parseFunc = Omni.ParseFuncs;
local AddLogRow = Omni.AddLogRow;
--local AddLogRow2 = Omni.AddLogRow2;
local match, gmatch, lower = string.find, string.gmatch, string.lower;
local trackedBuffs = Omni.trackedBuffs;
local Afflicted, Buffed, Unafflicted = Omni._Afflicted, Omni._Buffed, Omni._Unafflicted;
local GetUnitByName = RDX.GetUnitByNameIfInGroup;

Omni.parserLoaded = true;

--- Damage types (as they appear in the WoW combat log)
-- DO NOT change the numbers, only the text.
local dmgToType = Omni.dmgToType;
dmgToType["Physical"] = 1;
dmgToType["Holy"] = 2;
dmgToType["Fire"] = 3;
dmgToType["Nature"] = 4;
dmgToType["Frost"] = 5;
dmgToType["Shadow"] = 6;
dmgToType["Arcane"] = 7;

-- Reverse lookup for damage types (do not change)
local typeToDmg = Omni.typeToDmg;
for k,v in pairs(dmgToType) do typeToDmg[v] = k; end

local tmpdmg = {};
tmpdmg[1] = "Physical";
tmpdmg[2] = "Holy";
tmpdmg[4] = "Fire";
tmpdmg[8] = "Nature";
tmpdmg[16] = "Frost";
tmpdmg[32] = "Shadow";
tmpdmg[64] = "Arcane";



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
xiTypes[8] = "crushing";
xiTypes[9] = "glancing";
xiTypes[10] = "immune";
xiTypes[11] = "reflect";
xiTypes[12] = "evade";
xiTypes[13] = "deflect";
xiTypes[14] = "dot";
xiTypes[15] = "hot";
xiTypes[16] = "range";
xiTypes[17] = "xtrahit";

-- Reverse lookups for modifier types (do not change)
local i_xiTypes = Omni.i_xiTypes;
for k,v in pairs(xiTypes) do i_xiTypes[v] = k; end

--- Mitigation parsing (Crushing/glancing/partial resist etc.)
local mtbl = {};
local i, e = 0, nil;

local function ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing)
	i, e = 0, nil;
	VFL.empty(mtbl);
	if critical then e = 6;
	elseif crushing then e = 8;
	elseif glancing then e = 9;
	end
	if resisted then i=i+1; mtbl[i] = xiTypes[5]; i=i+1; mtbl[i] = resisted; end
	if blocked then i=i+1; mtbl[i] = xiTypes[4]; i=i+1; mtbl[i] = blocked; end
	if absorbed then i=i+1; mtbl[i] = xiTypes[7]; i=i+1; mtbl[i] = absorbed; end
	return e, mtbl[1], mtbl[2], mtbl[3], mtbl[4], mtbl[5], mtbl[6];
end

local MyGUID, uselogall = nil, false;

-- Spell standard order
local spellId, spellName, spellSchool;
local extraSpellId, extraSpellName, extraSpellSchool;

-- For Melee/Ranged swings and enchants
local nameIsNotSpell, extraNameIsNotSpell; 

-- Damage standard order
local amount, overkill, overhealing, school, resisted, blocked, absorbed, critical, glancing, crushing;
-- Miss argument order
local missType;
-- Aura arguments
local auraType; -- BUFF or DEBUFF

-- Enchant arguments
local itemId, itemName;

-- Special Spell values
local valueType = 1;  -- 1 = School, 2 = Power Type
local extraAmount; -- Used for Drains and Leeches
local powerType; -- Used for energizes, drains and leeches
local environmentalType; -- Used for environmental damage
local message; -- Used for server spell messages

local originalEvent; -- Used for spell links
local subVal;

function Omni.StandardParser(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	
	originalEvent = event; -- Used for spell links
	subVal = strsub(event, 1, 5);
	
	if (subVal == "SWING") then
		if (event == "SWING_DAMAGE") then
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(1, ...);
			--amount = amount - overkill;
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, nil, nil, amount, overkill, 1, nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, nil, nil, amount, overkill, 1, nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
			end
		elseif (event == "SWING_MISSED") then
			missType = select(1, ...);
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, nil, nil, 0, 0, _, nil, nil, nil, i_xiTypes[lower(missType)]);
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, nil, nil, 0, 0, _, nil, nil, nil, i_xiTypes[lower(missType)]);
			end
		end
	elseif (subVal == "SPELL") then 
		if (event == "SPELL_DAMAGE") then
			spellId, spellName, spellSchool = select(1, ...);
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);
			--amount = amount - overkill;
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
			end
		elseif (event == "SPELL_HEAL") then
			spellId, spellName, spellSchool = select(1, ...);
			amount, overhealing, critical = select(4, ...);
			--amount = amount - overhealing;
			if ((sourceGUID == MyGUID) and (destGUID == MyGUID)) then
				AddLogRow(7, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
			end
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(4, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
			end
			if (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(3, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
			end
		elseif (strsub(event, 1, 14) == "SPELL_PERIODIC") then
			if (event == "SPELL_PERIODIC_DAMAGE") then
				spellId, spellName, spellSchool = select(1, ...);
				amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);
				--amount = amount - overkill;
				if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
					AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[spellSchool]], 14, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
				elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[spellSchool]], 14, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
				end
			elseif (event == "SPELL_PERIODIC_HEAL") then
				spellId, spellName, spellSchool = select(1, ...);
				amount, overhealing, critical = select(4, ...);
				--amount = amount - overhealing;
				if ((sourceGUID == MyGUID) and (destGUID == MyGUID)) then
					AddLogRow(7, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
				end
				if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
					AddLogRow(4, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
				end
				if (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					AddLogRow(3, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
				end
			elseif (event == "SPELL_PERIODIC_MISSED") then 
				spellId, spellName, spellSchool = select(1, ...);
				missType = select(4, ...);
				if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
					AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[spellSchool]], 14, nil, nil, i_xiTypes[lower(missType)]);
				elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[spellSchool]], 14, nil, nil, i_xiTypes[lower(missType)]);
				end
			elseif (event == "SPELL_PERIODIC_DRAIN") then
				spellId, spellName, spellSchool = select(1, ...);
				amount, powerType, extraAmount = select(4, ...);
				if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
					AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]], 14);
				elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]], 14);
				end
			elseif (event == "SPELL_PERIODIC_LEECH") then
				spellId, spellName, spellSchool = select(1, ...);
				amount, powerType, extraAmount = select(4, ...);
				if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
					AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]], 14);
				elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]], 14);
				end
			end
		-------- by markushe       
		elseif (event == "SPELL_INTERRUPT") then
			spellId, spellName, spellSchool = select(1, ...);
			
			-- I don't know how to pass them to AddLogRow. So disabled for now
			-- extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);
			
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(28, sourceName, destName, sourceGUID, destGUID, spellName, spellId);
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(29, sourceName, destName, sourceGUID, destGUID, spellName, spellId);
			end
		---------------------
		elseif (strsub(event, 1, 10) == "SPELL_AURA") then
			if (event == "SPELL_AURA_APPLIED") then --or event == "SPELL_AURA_REFRESH") then
				spellId, spellName, spellSchool = select(1, ...);
				auraType = select(4, ...);
				if (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					if (auraType == "BUFF") then AddLogRow(9, nil, destName, nil, destGUID, spellName, spellId);
					else AddLogRow(5, nil, destName, nil, destGUID, spellName, spellId);
					end
				-- markushe: was missing for mobs. Needed for 
				-- +BuffMob/+DebuffMob in Bossmods 
				elseif (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) == COMBATLOG_OBJECT_TYPE_NPC) then 
					if (auraType == "BUFF") then 
						AddLogRow(23, nil, destName, nil, destGUID, spellName, spellId);
					else 
						AddLogRow(25, nil, destName, nil, destGUID, spellName, spellId);
					end
				end
			elseif (event == "SPELL_AURA_REMOVED") then
				spellId, spellName, spellSchool = select(1, ...);
				auraType = select(4, ...);
				if (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					if (auraType == "BUFF") then AddLogRow(10, nil, destName, nil, destGUID, spellName, spellId);
					else AddLogRow(6, nil, destName, nil, destGUID, spellName, spellId);
					end
				-- markushe: was missing for mobs. Needed for 
				-- -BuffMob/-DebuffMob in Bossmods 
				elseif (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) == COMBATLOG_OBJECT_TYPE_NPC) then 
					if (auraType == "BUFF") then 
						AddLogRow(24, nil, destName, nil, destGUID, spellName, spellId);
					else 
						AddLogRow(26, nil, destName, nil, destGUID, spellName, spellId);
					end
				end
			elseif (event == "SPELL_AURA_APPLIED_DOSE") then
				spellId, spellName, spellSchool = select(1, ...);
				auraType, amount = select(4, ...);
				if (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					if (auraType == "BUFF") then AddLogRow(9, nil, destName, nil, destGUID, spellName, spellId);
					else AddLogRow(5, nil, destName, nil, destGUID, spellName, spellId);
					end
				-- markushe: was missing for mobs. Needed for 
				-- +BuffMob/+DebuffMob in Bossmods 
				elseif (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) == COMBATLOG_OBJECT_TYPE_NPC) then 
					if (auraType == "BUFF") then 
						AddLogRow(23, nil, destName, nil, destGUID, spellName, spellId);
					else 
						AddLogRow(25, nil, destName, nil, destGUID, spellName, spellId);
					end
				end
			elseif (event == "SPELL_AURA_REMOVED_DOSE") then
				spellId, spellName, spellSchool = select(1, ...);
				auraType, amount = select(4, ...);
				if (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
					if (auraType == "BUFF") then AddLogRow(10, nil, destName, nil, destGUID, spellName, spellId);
					else AddLogRow(6, nil, destName, nil, destGUID, spellName, spellId);
					end
				-- markushe: was missing for mobs. Needed for 
				-- -BuffMob/-DebuffMob in Bossmods 
				elseif (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) == COMBATLOG_OBJECT_TYPE_NPC) then 
					if (auraType == "BUFF") then 
						AddLogRow(24, nil, destName, nil, destGUID, spellName, spellId);
					else 
						AddLogRow(26, nil, destName, nil, destGUID, spellName, spellId);
					end
				end
			end
		elseif  (event == "SPELL_CAST_START") then
			spellId, spellName, spellSchool = select(1, ...);
			AddLogRow(21, sourceName, destName, sourceGUID, destGUID, spellName, spellId);
		elseif (event == "SPELL_CAST_SUCCESS") then
			spellId, spellName = select(1, ...);
			-- markushe: I am only adding this for NPCs (needed for bossmods)
			-- because I don't know why SPELL_CAST_SUCCESS was commented out
			-- (see below)
			if (bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_NPC) == COMBATLOG_OBJECT_TYPE_NPC) then
				AddLogRow(22, sourceName, destName, sourceGUID, destGUID, spellName, spellId);
			end
			if RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(27, sourceName, destName, sourceGUID, destGUID, spellName, spellId);
			end
		elseif (event == "SPELL_MISSED") then 
			spellId, spellName, spellSchool = select(1, ...);
			missType = select(4, ...);
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, i_xiTypes[lower(missType)]);
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, i_xiTypes[lower(missType)]);
			end
		elseif (event == "SPELL_DRAIN") then
			spellId, spellName, spellSchool = select(1, ...);
			amount, powerType, extraAmount = select(4, ...);
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]]);
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]]);
			end
		elseif (event == "SPELL_LEECH") then
			spellId, spellName, spellSchool = select(1, ...);
			amount, powerType, extraAmount = select(4, ...);
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]]);
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, 0, dmgToType[tmpdmg[spellSchool]]);
			end
		--[[
		elseif (event == "SPELL_EXTRA_ATTACKS") then
			amount = select(1, ...);
			if (sourceGUID == MyGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, nil, nil, 0, 0, 1, nil, nil, nil, 17);
			elseif (destGUID == MyGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, nil, nil, 0, 0, 1, nil, nil, nil, 17);
			end
		]]
		elseif (event == "SPELL_SUMMON") then
			spellId, spellName, spellSchool = select(1, ...);
			AddLogRow(30, sourceName, destName, sourceGUID, destGUID, spellName, spellId);
		end
	elseif (subVal == "RANGE") then
		if (event == "RANGE_DAMAGE") then
			spellId, spellName, spellSchool = select(1, ...);
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);
			--amount = amount - overkill;
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[school]], nil, nil, 16, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[school]], nil, nil, 16, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
			end
		elseif (event == "RANGE_MISSED") then 
			spellId, spellName, spellSchool = select(1, ...);
			missType = select(4, ...);
			if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
				AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[school]], nil, nil, 16, i_xiTypes[lower(missType)]);
			elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
				AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[school]], nil, nil, 16, i_xiTypes[lower(missType)]);
			end
		end
	elseif (event == "DAMAGE_SHIELD") then
		spellId, spellName, spellSchool = select(1, ...);
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);
		--amount = amount - overkill;
		if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
			AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
		elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
			AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
		end
	elseif (event == "DAMAGE_SHIELD_MISSED") then 
		spellId, spellName, spellSchool = select(1, ...);
		missType = select(4, ...);
		if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
			AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, i_xiTypes[lower(missType)]);
		elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
			AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, 0, 0, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, i_xiTypes[lower(missType)]);
		end
	elseif (event == "DAMAGE_SPLIT") then
		spellId, spellName, spellSchool = select(1, ...);
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);
		--amount = amount - overkill;
		if (sourceGUID == MyGUID) or RDX.GetUnitByGuid(sourceGUID) then
			AddLogRow(2, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[school]], nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
		elseif (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
			AddLogRow(1, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overkill, dmgToType[tmpdmg[school]], nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
		end
	elseif (event == "ENVIRONMENTAL_DAMAGE") then
		environmentalType = select(1,...)
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(2, ...);
		--amount = amount - overkill;
		if (destGUID == MyGUID) or RDX.GetUnitByGuid(destGUID) then
			AddLogRow(1, environmentalType, destName, nil, destGUID, nil, nil, amount, overkill, dmgToType[tmpdmg[school]], nil, nil, nil, ComputeMitigationTable(resisted, blocked, absorbed, critical, glancing, crushing));
		end
	elseif (event == "PARTY_KILL") then
		AddLogRow(17, sourceName, destName, sourceGUID, destGUID);
	elseif (event == "UNIT_DIED" or event == "UNIT_DESTROYED") then
		AddLogRow(18, sourceName, destName, sourceGUID, destGUID);
	end
end

function Omni.MiniParser(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	
	-- Spell standard order
	local spellId, spellName, spellSchool;
	local extraSpellId, extraSpellName, extraSpellSchool;

	-- For Melee/Ranged swings and enchants
	local nameIsNotSpell, extraNameIsNotSpell; 

	-- Damage standard order
	local amount, overkill, overhealing, school, resisted, blocked, absorbed, critical, glancing, crushing;
	-- Miss argument order
	local missType;
	-- Aura arguments
	local auraType; -- BUFF or DEBUFF

	-- Enchant arguments
	local itemId, itemName;

	-- Special Spell values
	local valueType = 1;  -- 1 = School, 2 = Power Type
	local extraAmount; -- Used for Drains and Leeches
	local powerType; -- Used for energizes, drains and leeches
	local environmentalType; -- Used for environmental damage
	local message; -- Used for server spell messages
	local originalEvent = event; -- Used for spell links
	local subVal = strsub(event, 1, 5);
	
	if (event == "SPELL_HEAL") then
		spellId, spellName, spellSchool = select(1, ...);
		amount, overhealing, critical = select(4, ...);
		--amount = amount - overhealing;
		if (sourceGUID == MyGUID) and (destGUID == MyGUID) then
			AddLogRow(7, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
		elseif (sourceGUID == MyGUID) then
			AddLogRow(4, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
		elseif (destGUID == MyGUID) then
			AddLogRow(3, sourceName, destName, sourceGUID, destGUID, spellName, spellId, amount, overhealing, dmgToType[tmpdmg[spellSchool]], nil, nil, nil, ComputeMitigationTable(nil, nil, nil, critical, nil, nil));
		end
	end
end

VFLP.RegisterFunc("RDX Omniscience", "Standard Parser", Omni.StandardParser, true);
--VFLP.RegisterFunc("RDX Omniscience", "Minimal Parser", Omni.MiniParser, true);

RDXEvents:Bind("INIT_DEFERRED", nil, function()
	
	MyGUID = UnitGUID("player");
	
end);
