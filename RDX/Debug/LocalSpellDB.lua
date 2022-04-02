-- OpenRDX
-- LocalSpellDB

local spellId, spellName, spellSchool;
local originalEvent; -- Used for spell links
local subVal;

local rank, norank;

function __RDXParser(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	originalEvent = event; -- Used for spell links
	subVal = strsub(event, 1, 5);
	spellId, spellName, spellSchool = nil, nil, nil;
	norank = nil;
	
	if (subVal == "SPELL") then 
		if (event == "SPELL_DAMAGE") then
			spellId, spellName, spellSchool = select(1, ...);
		elseif (event == "SPELL_HEAL") then
			spellId, spellName, spellSchool = select(1, ...);
		elseif (event == "SPELL_INTERRUPT") then
			spellId, spellName, spellSchool = select(1, ...);
		elseif (strsub(event, 1, 14) == "SPELL_PERIODIC") then
			if (event == "SPELL_PERIODIC_DAMAGE") then
				spellId, spellName, spellSchool = select(1, ...);
			elseif (event == "SPELL_PERIODIC_HEAL") then
				spellId, spellName, spellSchool = select(1, ...);
			elseif (event == "SPELL_PERIODIC_MISSED") then 
				spellId, spellName, spellSchool = select(1, ...);
			elseif (event == "SPELL_PERIODIC_DRAIN") then
				spellId, spellName, spellSchool = select(1, ...);
			elseif (event == "SPELL_PERIODIC_LEECH") then
				spellId, spellName, spellSchool = select(1, ...);
			end
		elseif (strsub(event, 1, 10) == "SPELL_AURA") then
			norank = true;
			if (event == "SPELL_AURA_APPLIED") then --or event == "SPELL_AURA_REFRESH") then
				spellId, spellName, spellSchool = select(1, ...);
			elseif (event == "SPELL_AURA_REMOVED") then
				spellId, spellName, spellSchool = select(1, ...);
			elseif (event == "SPELL_AURA_APPLIED_DOSE") then
				spellId, spellName, spellSchool = select(1, ...);
			elseif (event == "SPELL_AURA_REMOVED_DOSE") then
				spellId, spellName, spellSchool = select(1, ...);
			end
		elseif  (event == "SPELL_CAST_START") then
			spellId, spellName, spellSchool = select(1, ...);
		elseif (event == "SPELL_MISSED") then 
			spellId, spellName, spellSchool = select(1, ...);
		elseif (event == "SPELL_DRAIN") then
			spellId, spellName, spellSchool = select(1, ...);
		elseif (event == "SPELL_LEECH") then
			spellId, spellName, spellSchool = select(1, ...);
		elseif (event == "SPELL_CAST_SUCCESS") then
			spellId, spellName = select(1, ...);
		end
	elseif (subVal == "RANGE") then
		if (event == "RANGE_DAMAGE") then
			spellId, spellName, spellSchool = select(1, ...);
		elseif (event == "RANGE_MISSED") then 
			spellId, spellName, spellSchool = select(1, ...);
		end
	elseif (event == "DAMAGE_SHIELD") then
		spellId, spellName, spellSchool = select(1, ...);
	elseif (event == "DAMAGE_SHIELD_MISSED") then 
		spellId, spellName, spellSchool = select(1, ...);
	elseif (event == "DAMAGE_SPLIT") then
		spellId, spellName, spellSchool = select(1, ...);
	end
	
	if norank and spellName and spellId then
		RDXLocalSpellDB[spellName] = spellId;
	end
	
	if spellName and spellId then
		_, rank = GetSpellInfo(spellId);
		if rank then spellName = spellName .. "(" .. rank ..")"; end
		RDXLocalSpellDB[spellName] = spellId;
	end
end

local function EnableStoreLocalSpellDB()
	RDXG.localSpellDB = true;
	WoWEvents:Unbind("LocalSpellDB");
	WoWEvents:Bind("COMBAT_LOG_EVENT_UNFILTERED", nil, __RDXParser, "LocalSpellDB");
end

local function DisableStoreLocalSpellSB()
	RDXG.localSpellDB = nil;
	WoWEvents:Unbind("LocalSpellDB");
end

function RDXM_Debug.ToggleStoreLocalSpellSB()
	if RDXG.localSpellDB then
		DisableStoreLocalSpellSB();
		RDX.print(i18n("Disable Store Local Spell DB"));
	else
		EnableStoreLocalSpellDB();
		RDX.print(i18n("Enable Store Local Spell DB"));
	end
end

function RDXM_Debug.IsStoreLocalSpellDB()
	return RDXG.localSpellDB;
end

---------------------------------------------------
-- INIT
---------------------------------------------------

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	if not RDXLocalSpellDB then RDXLocalSpellDB = {}; end
	if RDXG.localSpellDB then 
		EnableStoreLocalSpellDB(); 
		RDX.printW("Store Local Spell DB Activated !!!");
	end
end);