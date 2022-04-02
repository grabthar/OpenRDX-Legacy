-- Spells.lua
-- (C)2006 Bill Johnson
--
-- Code relating to the manipulation of in-game spells and abilities.
--
-- Each spell is represented by its WoW numerical spell ID. Spells are grouped into SpellClasses;
-- all spells in a SpellClass have the same effect, but to different magnitudes.
--
-- Examples of SpellClasses: Shadow Bolt(Rank 1), Shadow Bolt(Rank 2), ...
--                           Detect Lesser Invisibility, Detect Invisibility, Detect Greater Invisibility
-- Subtleties: Power Word: Fortitude and Prayer of Fortitude are DIFFERENT spell classes because
--   they don't have the exact same effect (one buffs a single person, one buffs a group.)
--
-- Spells are also grouped into SpellCategories. A SpellCategory can be something like "DAMAGE", 
-- "HEALING", "PERIODIC", "INSTANT", etc. A spell can be in multiple SpellCategories.
--
-- Spells are also grouped into RangeClasses. Spells in the same RangeClass have the same range.
--
-- Spells can be manually grouped into generic SpellGroups which can have any content or meaning 
-- that the programmer desires.
-- 
-- Interesting spell events
-- LEARNED_SPELL_IN_TAB(tabnum)
-- SPELL_UPDATE_USABLE
--
-- OpenRDX, move into RDX

RDXSS = RegisterVFLModule({
	name = "RDXSS";
	title = "RDX Spell System";
	description = "RDX Spell System";
	version = {1,0,0};
	parent = RDX;
});

-- Burning Crusade: abstract away crazy renamed function...
if IsPassiveSpell then
	RDXSS.IsPassiveSpell = IsPassiveSpell;
else
	RDXSS.IsPassiveSpell = IsSpellPassive;
end

------------------------------------------------
-- Basic spell API
------------------------------------------------

--- Given a spell's numerical ID, return its full name.
function RDXSS.GetSpellFullName(id)
	if not id then return nil; end
	local name,q = GetSpellName(id, BOOKTYPE_SPELL);
	if not name then return nil; end
	return name .. '(' .. q .. ')', name, q;
end

--- Given a spell's numerical ID, attempt to figure out its numerical rank,
-- if any.
function RDXSS.GetSpellRank(id)
	local name,q = GetSpellName(id, BOOKTYPE_SPELL);
	if not name then return nil; end
	if q then
		local _,_,num = string.find(q, "(%d+)");
		if num then return tonumber(num), name, q; end
	end
	return 0, name, q;
end

------------------------------------------------
-- Local spell DB
------------------------------------------------

function RDXSS.GetSpellIdByLocalName(name)
	if not name then return nil; end
	return RDXLocalSpellDB[name];
end

------------------------------------------------
-- Core spell databases
------------------------------------------------
-- Spells by full name
local spFN = {};
local FullspFN = {};

--- Get a spell by FULL NAME: Spell Name(Rank X)
-- Partial names will not work.
function RDXSS.GetSpellByFullName(n, fulldb)
	if not n then return nil; end
	if fulldb then
		return FullspFN[n];
	else
		return spFN[n];
	end
end

--- Get a table (name->id) of all spells recognized by VFL.
function RDXSS.GetAllSpells(fulldb) 
	if fulldb then
		return FullspFN;
	else
		return spFN;
	end
end

--- Exclusion tables. Spells excluded by this table will not
-- appear in the VFL spell system.
local excludeNames = {
	[i18n("Attack")] = true,
	[i18n("Disenchant")] = true,
	[i18n("Gnomish Engineer")] = true,
	[i18n("Goblin Engineer")] = true,
};
local excludeQualifiers = {
	[i18n("Passive")] = true,
	[i18n("Racial Passive")] = true,
	[i18n("Apprentice")] = true,
	[i18n("Journeyman")] = true,
	[i18n("Master")] = true,
	[i18n("Expert")] = true,
	[i18n("Artisan")] = true,
};

-- Filter this spell for "worthwhile-ness"
local function SpellFilter(id,name,q)
	if RDXSS.IsPassiveSpell(id, BOOKTYPE_SPELL) then return nil; end
	if excludeNames[name] then return nil; end
	if excludeQualifiers[q] then return nil; end
	return true;
end

-- Empty the core spell database
local function ResetCoreSpellDB()
	VFL.empty(spFN);
	VFL.empty(FullspFN);
end

-- Rebuild the core spell database
local function BuildCoreSpellDB()
	local i=1;
	while true do
		local name,q = GetSpellName(i, BOOKTYPE_SPELL);
		if not name then break; end
		if SpellFilter(i,name,q) then
			spFN[name.."("..q..")"] = i;
		end
		FullspFN[name.."("..q..")"] = i;
		i=i+1;
	end
end

-----------------------------------------------
-- Companion spell 3.0.3
-----------------------------------------------
local spCritter = {};
local spMount = {};

function RDXSS.GetSpellCritterByName(n)
	if not n then return nil; end
	return spCritter[n];
end

local function ResetCoreSpellCritterDB()
	VFL.empty(spCritter);
end

local function BuildCoreSpellCritterDB()
	local i=1;
	while true do
		local creatureID, creatureName, creatureSpellID, icon, issummoned = GetCompanionInfo("CRITTER", i);
		if not creatureName then break; end
		spCritter[creatureName] = {creatureID = creatureID, creatureName = creatureName, creatureSpellID = creatureSpellID, icon = icon, issummoned = issummoned, i = i};
		i=i+1;
	end
end

function RDXSS.GetSpellMountByName(n)
	if not n then return nil; end
	return spMount[n];
end

local function ResetCoreSpellMountDB()
	VFL.empty(spMount);
end

local function BuildCoreSpellMountDB()
	local i=1;
	while true do
		local creatureID, creatureName, creatureSpellID, icon, issummoned = GetCompanionInfo("MOUNT", i);
		if not creatureName then break; end
		spMount[creatureName] = {creatureID = creatureID, creatureName = creatureName, creatureSpellID = creatureSpellID, icon = icon, issummoned = issummoned, i = i};
		i=i+1;
	end
end

function DEBUGMOUNT()
	for k,v in pairs(spMount) do
		VFL.print(k);
		VFL.print(v.creatureSpellID);
	end
end

------------------------------------------------
-- SpellGroup
-- A SpellGroup is a group of spells. Big shocker there. The spells in the
-- group can be queried by ID or name.
------------------------------------------------
RDXSS.SpellGroup = {};
function RDXSS.SpellGroup:new()
	local s = {};
	
	local spells = {};
	local spellsByID = {};
	local spellsByName = {};
	
	--- Get all spells in this group, as a sorted array.
	function s:Spells() return spells; end

	--- Empty this spell group
	function s:Empty()
		VFL.empty(spells); VFL.empty(spellsByID); VFL.empty(spellsByName);
	end

	--- Add a spell to this group.
	function s:AddSpell(id)
		if not id then error("expected id, got nil"); end
		if spellsByID[id] then return nil; end
		local sn = RDXSS.GetSpellFullName(id); if not sn then return nil; end
		table.insert(spells, id);
		spellsByID[id] = sn;
		spellsByName[sn] = id;
		return true;
	end

	--- Add a spell to this group by full name.
	function s:AddSpellByFullName(fn)
		self:AddSpell(RDXSS.GetSpellByFullName(fn));
	end

	--- Determine if the spell with the given ID is in this group
	function s:HasSpellByID(id)
		if not id then return nil; end
		return spellsByID[id];
	end

	--- Determine if the spell with the given full name is in this group.
	function s:HasSpellByFullName(fn)
		if not fn then return nil; end
		return spellsByName[fn];
	end

	--- Get the highest-sorted spell in this group.
	function s:GetBestSpellID()
		local n = table.getn(spells);
		if(n == 0) then return nil; end
		return spells[n];
	end

	--- Get the highest-sorted spell in this group by name
	function s:GetBestSpellName()
		local n = table.getn(spells);
		if(n == 0) then return nil; end
		return spellsByID[spells[n]];
	end

	-- Debug string dump
	function s:_DebugDump()
		local str = "";
		for _,sp in ipairs(spells) do
			str = str .. RDXSS.GetSpellFullName(sp) .. ",";
		end
		return str;
	end

	return s;
end

----------------------------------------------------------------
-- SpellClass
-- A SpellClass is a spell group containing spells that have identical
-- effects, but different magnitudes.
----------------------------------------------------------------

-- The class databases
local id2class = {};
local cn2class = {};

--- Get all spell classes
function RDXSS.GetSpellClasses() return cn2class; end

--- Get the class of the spell with the given id, if any.
function RDXSS.GetClassOfSpell(id)
	if not id then return nil; end
	return id2class[id];
end

--- Get the class of the given name.
function RDXSS.GetClassByName(cn)
	if not cn then return nil; end
	return cn2class[cn];
end

--- Get a class with a given name, creating it if it does not exist.
function RDXSS.GetOrCreateClassByName(cn)
	if not cn then return nil; end
	local cc = cn2class[cn];
	if not cc then
		cc = RDXSS.SpellGroup:new();
		cn2class[cn] = cc;
	end
	return cc;
end

--- Get the "best" spell of a given class.
function RDXSS.GetBestSpell(name)
	if not name then return nil; end
	local c = RDXSS.GetClassByName(name); if not c then return nil; end
	return c:GetBestSpellName();
end
function RDXSS.GetBestSpellID(name)
	if not name then return nil; end
	local c = RDXSS.GetClassByName(name); if not c then return nil; end
	return c:GetBestSpellID();
end

--- Manually classify a spell.
function RDXSS.ClassifySpell(spellFullName, className)
	if (not spellFullName) or (not className) then error("usage: RDXSS.ClassifySpell(spellFullName, className)"); end
	local cls = RDXSS.GetOrCreateClassByName(className);
	local id = RDXSS.GetSpellByFullName(spellFullName); if not id then return; end
	if id2class[id] then return; end
	id2class[id] = cls; cls:AddSpell(id);
end

-- Empty the spell-class database
local function ResetSpellClassDatabase()
	VFL.empty(id2class);
	VFL.empty(cn2class);
end

-- Sort an implicit rank-defined class by spell rank
local function SortImplicitClass(class)
	if not class then return; end
	local sp = class:GetSpells();
	table.sort(sp, function(s1, s2) return RDXSS.GetSpellRank(s1) < RDXSS.GetSpellRank(s2); end);
end

-- Implicitly classify all spells not already explicitly classified.
local function BuildImplicitSpellClasses()
	local i=1;
	while true do
		local name,q = GetSpellName(i, BOOKTYPE_SPELL);
		if not name then break; end
		if SpellFilter(i,name,q) then
			if not RDXSS.GetClassOfSpell(i) then
				local cls = RDXSS.GetOrCreateClassByName(name);
				id2class[i] = cls; cls:AddSpell(i);
			end
		end
		i=i+1;
	end
end

--------------------------------------------------------------------
-- SpellCategory
--
-- A SpellCategory is a loose string-identified grouping of spells.
-- A spell can belong to multiple categories, and there are API
-- calls to identify which categories a spell belongs to.
--------------------------------------------------------------------

local catname2category = {};
local spell2cats = {};

local function ResetSpellCategoryDatabase()
	VFL:Debug(1, "ResetSpellCategoryDatabase()");
	VFL.empty(catname2category);
	VFL.empty(spell2cats);
end

--- Get the category database
function RDXSS.GetAllCategories()
	return catname2category;
end

--- Get a category by name.
function RDXSS.GetCategoryByName(cn)
	if not cn then return nil; end
	return catname2category[cn];
end

--- Get a category by name, creating it if it does not exist.
function RDXSS.GetOrCreateCategoryByName(cn)
	if not cn then return nil; end
	local cat = catname2category[cn];
	if not cat then
		cat = RDXSS.SpellGroup:new();
		VFL:Debug(3,"Creating SpellCategory<"..cn.."> as " .. tostring(cat));
		catname2category[cn] = cat;
	end
	return cat;
end

--- Categorize a spell, assuming both the category and SID are valid.
local function CategorizeSpell(cat, cn, id)
	if cat:HasSpellByID(id) then return; end
	cat:AddSpell(id);
	local s = spell2cats[id];
	if not s then s = {}; spell2cats[id] = s; end
	s[cn] = true;
end

--- Categorize a single spell.
function RDXSS.CategorizeSpell(spellfn, cn)
	if (not spellfn) or (not cn) then return; end
	local id = RDXSS.GetSpellByFullName(spellfn); if not id then return; end
	local cat = RDXSS.GetOrCreateCategoryByName(cn);
	CategorizeSpell(cat, cn, id);
end

--- Categorize all spells in a SpellClass.
function RDXSS.CategorizeClass(class, cn)
	if(not class) or (not cn) then error("usage: RDXSS.CategorizeClass(className, categoryName)"); end
	local cls = RDXSS.GetClassByName(class); if not cls then return; end
	local cat = RDXSS.GetOrCreateCategoryByName(cn);
	for _,id in pairs(cls:Spells()) do CategorizeSpell(cat, cn, id); end
end

--- Get a table (cat->true) mapping of all categories to which the given spell belongs.
function RDXSS.GetSpellCategories(id)
	if not id then return VFL.emptyTable; end
	return spell2cats[id] or VFL.emptyTable;
end

------------------------------------------------
-- UPDATERS/EVENTS
------------------------------------------------

-- Master updater for the spell engine.
local function UpdateSpells()
	ResetCoreSpellDB();
	ResetSpellClassDatabase();
	ResetSpellCategoryDatabase();
	RDXEvents:Dispatch("SPELLS_RESET");
	BuildCoreSpellDB();
	RDXEvents:Dispatch("SPELLS_BUILD_CLASSES");
	BuildImplicitSpellClasses();
	RDXEvents:Dispatch("SPELLS_BUILD_CATEGORIES");
	RDXEvents:Dispatch("SPELLS_UPDATED");
end

WoWEvents:Bind("LEARNED_SPELL_IN_TAB", nil, UpdateSpells);
RDXEvents:Bind("INIT_SPELL", nil, UpdateSpells);

-- Master updater for the spell companion.
local function UpdateSpellsCompanion()
	ResetCoreSpellCritterDB();
	ResetCoreSpellMountDB();
	RDXEvents:Dispatch("SPELLS_COMPANION_RESET");
	BuildCoreSpellCritterDB();
	BuildCoreSpellMountDB();
	RDXEvents:Dispatch("SPELLS_COMPANION_UPDATED");
end

--WoWEvents:Bind("COMPANION_LEARNED", nil, UpdateSpellsCompanion);
--WoWEvents:Bind("COMPANION_UPDATE", nil, UpdateSpellsCompanion);
RDXEvents:Bind("INIT_SPELL", nil, UpdateSpellsCompanion);

-----------------------------------------------
-- DEBUGGERY
-----------------------------------------------
function DebugSpells()
	for k,v in pairs(RDXSS.GetAllSpells()) do
		VFL.print(v .. ": " .. k);
	end
end

function DebugSpellClasses()
	for k,v in pairs(RDXSS.GetSpellClasses()) do
		VFL.print(k .. ": " .. v:_DebugDump());
	end
end

function DebugSpellCategories()
	for k,v in pairs(RDXSS.GetAllCategories()) do
		VFL.print(k .. ": " .. v:_DebugDump());
	end
end

