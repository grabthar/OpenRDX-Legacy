-- Pool.lua
-- VFL - Venificus' Function Library
-- (C)2006 Bill Johnson (Venificus of Eredar server)
-- 
-- Generalized pool class, and frame pool libraries taking advantage of it.
--

------------------------------------------------------
-- @class VFL.Pool
-- 
-- A generalized pool of objects, with primitives for acquiring items from the pool
-- and releasing items into the pool.
--
-- Each Pool can additionally have event handlers bound onto it in the forms of
-- functions assigned to slots on the pool object. The following are available:
--
-- Modified by Sigg for indexed pool
-- The key bindings system required to use a indexed pool.
--
-- pool:OnAcquire(obj) - Called on obj when obj is acquired from the pool by a client.
-- pool:OnRelease(obj) - Called on obj when obj is released into the pool by a client.
-- pool:OnFallback() - Called when :Acquire fails to acquire an object from the actual pool. Should return a new object which will be subsequently added to the pool.
------------------------------------------------------
VFL.Pool = {};
VFL.Pool.__index = VFL.Pool;

--- Construct a new, empty pool
function VFL.Pool:new(pooltype)
	local self = {};
	setmetatable(self, VFL.Pool);
	self.pool = {};
	self.jail = {};
	self.keys = {};
	self.name = "(anonymous)"; self.fallbacks = 0; self.pooltype = pooltype;
	self.Releaser = function(obj) self:Release(obj); end
	self.Acquirer = function(arg) return self:Acquire(arg); end
	return self;
end

-- VFL kernel hooks
function VFL.Pool:KGetObjectName()
	return self.name;
end
function VFL.Pool:KGetObjectInfo()
	local sz = self:GetSize();
	return "Sz " .. sz .. " Fallbacks " .. self.fallbacks .. " Delta " .. (self.fallbacks - sz);
end

-- Get the current size of the pool
function VFL.Pool:GetSize()
	return table.getn(self.pool);
end

-- Get the current size of the jail pool
function VFL.Pool:GetJailSize()
	return table.getn(self.jail);
end

-- Get the number of object created
function VFL.Pool:GetFallbacks()
	return self.fallbacks;
end

-- Acquire an object, removing it from this pool.
function VFL.Pool:Acquire(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
	-- Attempt to get a pooled object
	local obj = nil;
	if self.pooltype == "key" then
		obj = self.pool[a1];
		self.pool[a1] = nil;
		--if obj then VFL.print("acquire object " .. obj.keypool); end
	else
		obj = table.remove(self.pool);
	end
	
	-- check object already aquired from indexed pool
	if self.pooltype == "key" and (not obj) and self.keys[a1] then
		return nil;
	end
	
	-- If we couldn't get the object...
	if not obj then
		-- If we have a fallback...
		if(self.OnFallback) then
			-- Try for a fallback...
			obj = self:OnFallback(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);
			if obj then
				-- Fallback successful.
				self.fallbacks = self.fallbacks + 1;
				if self.pooltype == "key" then
					obj.keypool = a1;
					self.keys[a1] = true;
				end
			else
				return nil;
			end
		else
			return nil;
		end -- if(self.onFallback)
	end -- if not obj
	
	-- We successfully acquired an object; return it.
	if(self.OnAcquire) then self:OnAcquire(obj); end
	return obj;
end

-- Release an object into this pool.
function VFL.Pool:Release(o)
	if self.OnRelease then self:OnRelease(o); end
	if(o.OnRelease) then o.OnRelease(o, self); o.OnRelease = nil; end
	if o.keypool then
		self.pool[o.keypool] = o;
	else
		table.insert(self.pool, o);
	end
end
function VFL.Pool:_Release(o)
	if o.jail then
		table.insert(self.jail, o); -- infected frame
	elseif o.keypool then
		self.pool[o.keypool] = o;
	else
		table.insert(self.pool, o);
	end
end

-- Get the n'th object from this pool, resizing if necessary until there are n objects.
function VFL.Pool:Get(i)
	return self.pool[i];
end

-- Empty out the pool, calling the optional destructor function for each object in the pool.
function VFL.Pool:Empty(destr)
	if not destr then destr = VFL.Noop; end
	for _,obj in pairs(self.pool) do destr(obj); end
	self.pool = {}; self.fallbacks = 0;
end

-- Shunt the pool. Destroys the pool's current contents, prevents future acquisitions,
-- and runs all future releases through the provided destructor.
function VFL.Pool:Shunt(destr)
	if not destr then destr = VFL.Noop; end
	for _,obj in pairs(self.pool) do destr(obj); end
	self.pool = nil; self.fallbacks = 0;
	self.OnAcquire = nil; self.Acquire = VFL.Nil; self.Get = VFL.Nil;
	self.GetSize = VFL.Zero; self.Empty = VFL.Noop; self.Fill = VFL.Noop;
	self.OnRelease = nil; self.Release = function(s,o) destr(o); end
end

-- Fill a pool with global objects having a given prefix.
function VFL.Pool:Fill(pfx)
	local i = 1;
	while(true) do
		local pe = getglobal(pfx .. i);
		if not pe then break; end
		self:Release(pe);
		i = i + 1;
	end
end

