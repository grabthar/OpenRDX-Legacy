-- Cooldown registry
local cds = {};

-- Cooldown group registry
local cdg = {};

local cdmnu = {};
local cdmnu_star = { { text = "(any)", value = "*" } };
local function _AddCDToMenu(value, text)
	local t = { text = text, value = value };
	table.insert(cdmnu, t);
	table.insert(cdmnu_star, t);
end

function Omni.RegisterCooldown(tbl)
	if not tbl.spellid then VFL.print(i18n("|cFFFF0000[RDX]|r Info : Attempt to register an anonymous omni cooldown.")); return; end
	if cds[tbl.spellid] then VFL.print(i18n("|cFFFF0000[RDX]|r Info : Attempt to register duplicate object type ") .. tbl.spellid .. "."); return; end
	cds[tbl.spellid] = tbl;
	_AddCDToMenu(tbl.spellid, tbl.cdtype .. ": " .. tbl.spellname);
	if tbl.group then
		if not cdg[tbl.group] then cdg[tbl.group] = {}; end
		local found = nil;
		for k,v in pairs(cdg[tbl.group]) do
			if v.spellname == tbl.spellname then found = true; end
		end
		if not found then
			table.insert(cdg[tbl.group],{ spellname = tbl.spellname, spellid = tbl.spellid });
		end
	end
	return true;
end

local unitclass;
local function TestClass(self, uid)
	_, uniclass = UnitClass(uid);
	if uniclass == self.cdtype then
		return true;
		--spell_id = RDXSS.GetBestSpellID(spellname);
		--if spell_id then 
		--	Omni._RegisterForUSS(self, spellname);
		--	self.GetValue = function()
		--		local s,d = GetSpellCooldown(spell_id, BOOKTYPE_SPELL);
		--		if s>0 and d>1 then
		--			duration = d;
		--			return VFL.clamp(d-(GetTime()-s), 0, 1000000), d;
		--		else
		--			return 0, duration;
		--		end
		--	end
		--	return true;
		--end
	else
		return nil;
	end
end

function Omni.RegisterSpellClassCooldown(spellid, class, duration, group)
	local spell_id, spellname, icon = nil, nil, nil;
	duration = VFL.clamp(duration, 1, 1000000);
	spellname, _, icon = GetSpellInfo(spellid);
	local cd = {
		spellid = spellid;
		spellname = spellname;
		cdtype = class;
		group = group;
		duration = duration;
		icon = icon;
		IsPossible = TestClass;
		Initialize = VFL.Noop;
		Activate = VFL.Noop;
		CooldownUsed = VFL.Noop;
		GetValue = Logistics.UnknownCooldown;
	};
	Omni.RegisterCooldown(cd);
	return cd;
end

function Omni.RegisterSpellRaceCooldown(spellid, race, duration)
	local spell_id, spellname, icon = nil, nil, nil;
	duration = VFL.clamp(duration, 1, 1000000);
	spellname, _, icon = GetSpellInfo(spellid);
	local cd = {
		spellid = spellid;
		spellname = spellname;
		cdtype = race;
		duration = duration;
		icon = icon;
		IsPossible = function(self, uid)
			local unitrace;
			_, unitrace = UnitRace(uid);
			if unitrace == self.cdtype then
				return true;
			else
				return nil;
			end
		end;
		Initialize = VFL.Noop;
		Activate = VFL.Noop;
		CooldownUsed = VFL.Noop;
		GetValue = Logistics.UnknownCooldown;
	};
	Omni.RegisterCooldown(cd);
	return cd;
end

function Omni.GetCooldownInfoBySpellid(spellid)
	if not spellid then return nil; end
	return cds[spellid];
end

function Omni.GetGroupCooldowns(group)
	if not group then return nil; end
	return cdg[group];
end
