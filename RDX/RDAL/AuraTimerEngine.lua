-- Sigg Rashgarroth EU
-- from an idea by Xenios

-- Aura Buff/Debuff Timer Engine
-- store data about specific buff and debuff

RDXATE = RegisterVFLModule({
	name = "RDXATE";
	title = i18n("RDX Aura Timer Engine");
	description = "RDX Aura Timer Engine";
	version = {1,0,0};
	parent = RDX;
});

local listBuffs = {};
RDXATE.AddBuff = function(buffname, time)
	local lbuffname = strlower(buffname);
	if listBuffs[lbuffname] then return;end
	listBuffs[lbuffname] = time;
end
RDXATE.RemoveBuff = function(buffname)
	local lbuffname = strlower(buffname);
	if not listBuffs[lbuffname] then return;end
	listBuffs[lbuffname] = nil;
end
RDXATE.listBuffs = listBuffs;

RDXATE.GetBuffTimerbyTimeleft = function(timeleft, name)
	if (not name) or (not listBuffs[name]) or (not timeleft) then return; end
	local duration = listBuffs[name];
	return (GetTime() + timeleft - duration), duration, timeleft;
end

RDXATE.GetBuffTimerbyStartime = function(startime, name)
	if (not name) or (not listBuffs[name]) or (not startime) then return; end
	local duration, timeleft = listBuffs[name], nil;
	if ((startime + duration) > GetTime()) then
	 	timeleft = duration - (GetTime() - startime);
	else
		startime = nil;
		timeleft = nil;
		duration = nil;
	end
	return startime, duration, timeleft;
end

local listDebuffs = {};
RDXATE.AddDebuff = function(debuffname, time)
	local ldebuffname = strlower(debuffname);
	if listDebuffs[ldebuffname] then return;end
	listDebuffs[ldebuffname] = time;
end
RDXATE.RemoveDebuff = function(debuffname)
	local ldebuffname = strlower(debuffname);
	if not listDebuffs[ldebuffname] then return;end
	listDebuffs[ldebuffname] = nil;
end
RDXATE.listDebuffs = listDebuffs;

RDXATE.GetDebuffTimerbyTimeleft = function(timeleft, name)
	if (not name) or (not listDebuffs[name]) or (not timeleft) then return; end
	local duration = listDebuffs[name];
	return (GetTime() + timeleft - duration), duration, timeleft;
end

RDXATE.GetDebuffTimerbyStartime = function(startime, name)
	if (not name) or (not listDebuffs[name]) or (not startime) then return; end
	local duration, timeleft = listDebuffs[name], nil;
	if ((startime + duration) > GetTime()) then
	 	timeleft = duration - (GetTime() - startime);
	else
		startime = nil;
		timeleft = nil;
		duration = nil;
	end
	return startime, duration, timeleft;
end

RDXATE.sync = false;

RDXATE.dbfdebug = function()
	for k,v in pairs(listDebuffs) do
		VFL.print("key " .. k .. " value " .. v);
	end
end

RDXATE.bfdebug = function()
	for k,v in pairs(listBuffs) do
		VFL.print("key " .. k .. " value " .. v);
	end
end

