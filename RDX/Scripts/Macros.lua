-- Macros.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Tools to assist in macro, slash command, and boss mod development.


--- Gets an iterator over the iterable object (Set or Sort) at the given path.
function RDX.GetObjectIterator(path)
	local si = nil;
	local data, _, _, ty = RDXDB.GetObjectData(path);
	if not data then return nil; end
	-- Only works on sorts or sets...
	if(not string.find(ty, "Sort$")) and (not string.find(ty, "Set$")) then return nil; end
	si = RDXDB.GetObjectInstance(path); if not si then return nil; end
	si:Open();
	return si:Iterator();
end

--- Gets an up-to-date Sort from the given path.
function RDX.GetSort(path)
	local _,_,_,ty = RDXDB.GetObjectData(path);
	if(string.find(ty, "Sort$")) then
		local si = RDXDB.GetObjectInstance(path); if not si then return nil; end
		si:Open();
		return si;
	end
end

--- Gets the n'th member of the given sort.
function RDX.NthInSort(path, n, constrain)
	local sort = RDX.GetSort(path); if not sort then return nil; end
	if constrain then n = math.min(n, sort:GetSize()); end
	return sort:GetByIndex(n);
end

--- Gets the n'th member of the given sort modulo the size of the sort
function RDX.ModnInSort(path, n)
	n = tonumber(n);
	if (not n) or (n < 1) then return nil; end
	local sort = RDX.GetSort(path); if not sort then return nil; end
	local sz = sort:GetSize(); if sz == 0 then return nil; end
	return sort:GetByIndex(VFL.mmod(n-1, sz) + 1);
end

--- Executes the given Lua function on each unit from the given set. If the function returns
-- NIL at any time, the loop is aborted. Returns the unit for which func returned nil, if any.
function RDX.ForeachInObject(path, func)
	if not func then func = VFL.Noop; end
	local inst = RDXDB.GetObjectInstance(path); 
	if (not inst) or (not inst.Iterator) then return nil; end
	for _,_,unit in inst:Iterator() do
		if unit:IsCacheValid() then
		--if unit:IsValid() then
			if not func(unit) then break; end
		end
	end
	return u;
end

--- Return the RDX Unit object of the first member of the sort at the given
-- path. Will also accept sets, but if a set is provided, ordering is obviously
-- not guaranteed.
function RDX.GetFirstUnitInObject(path)
	local u = nil;
	for _,unit in RDX.GetObjectIterator(path) do
		u = unit; break;
	end
	return u;
end

-------------------------------------
-- SCRIPT EXECUTION
-------------------------------------
function RDX.RunScript(path)
	if RDXDB.CheckObject(path, "Script") then RDXDB.OpenObject(path); end
end

RDX.RegisterSlashCommand("script", function(rest)
	local script = VFL.word(rest);
	RDX.RunScript(script);
end);
