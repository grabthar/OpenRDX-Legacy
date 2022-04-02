-- OpenRDX
-- sigg / rashgarroth EU

-- The Omni.GUID object

Omni.GUID = {};
Omni.GUID.__index = Omni.GUID;

function Omni.GUID:new(GUID, name)
	local self = {};
	-- id
	self.GUID = GUID;
	if name then name = string.lower(name); end
	self.name = name;
	self.last = GetTime();
	
	-- Omni meters info (damage, heal, overhealing)
	self.info = {};
	
	-- Omni cooldowns
	self.cd = {}; -- possible
	
	setmetatable(self, Omni.GUID);
	--VFL.print("ok");
	return self;
end

-- return the guid of this object
function Omni.GUID:getObjectGUID()
	return self.GUID;
end

-- return the name
function Omni.GUID:getObjectName()
	return self.name or "";
end

-- return the last change time of this guid
function Omni.GUID:getObjectTime()
	return self.last;
end

---------------------------------------------
-- Omnimeters
---------------------------------------------

-- update data stype = damagedone, damagetaken, healdone etc...
function Omni.GUID:addGUIDData(stype, v)
	if (not stype) or (not v) then return nil; end
	local obj = self.info[stype];
	if (not obj) then
		--VFL.print("addguid not found" .. v);
		obj = {nb = 1, data = v};
		self.info[stype] = obj;
	else
		--VFL.print("addguid found" .. v);
		obj.data = obj.data + v;
		obj.nb = obj.nb + 1;
		self.info[stype] = obj;
	end
	--VFL.print("data " .. self.sinfo[stype].data);
	self.last = GetTime();
end

-- get data stype = damagedone, damagetaken, healdone etc...
function Omni.GUID:getGUIDData(stype)
	if (not stype) then return nil; end
	local obj = self.info[stype];
	if (not obj) then
		obj = {nb = 1, data = 0};
		self.info[stype] = obj;
	end
	self.last = GetTime();
	return obj.data;
end

-- update data stype = damagedone, damagetaken, healdone etc...
function Omni.GUID:setGUIDData(stype, v)
	if (not stype) or (not v) then return nil; end
	local obj = self.info[stype];
	if (not obj) then
		obj = {nb = 1, data = v};
		self.info[stype] = obj;
	else
		obj.data = v;
	end
	--self.last = GetTime();
end

-- Empty Info.
function Omni.GUID:emptyINFO()
	VFL.empty(self.info);
end

------------------------------
-- COOLDOWN ENGINE
------------------------------

function Omni.GUID:GetCooldown(i)
	return self.cd[i];
end

local foundcd;
function Omni.GUID:SetCooldown(spellname, spellid, expirationTime)
	foundcd = nil;
	for _,v in ipairs(self.cd) do
		if v.spellname == spellname then
			v.expirationTime = expirationTime;
			v.spellid = spellid;
			foundcd = true;
		end
	end
	if not foundcd then 
		local cd = {spellname = spellname, spellid = spellid, expirationTime = expirationTime};
		table.insert(self.cd, cd);
	end
	self.last = GetTime();
	return true;
end

function Omni.GUID:emptyCD()
	VFL.empty(self.cd);
end
