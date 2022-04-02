-- Primitives.lua
-- VFL
-- (C) 2005-2006 Bill Johnson and The VFL Project
--
-- Contains various useful primitive operations on functions, strings, and tables.
--
-- Notational conventions are:
-- STRUCTURAL PARAMETERS
--    T is a table. k,v indicate keys and values of T respectively
--    A is an array (table with positive integer keys)
--		L is a list (table with keys ignored) L' < L indicates the sublist relation.
-- FUNCTION PARAMETERS:
--    b is a boolean predicate on an applicable domain (must return true/false)
--    f is a function to be specified.
-- OTHER PARAMETERS:
--    x is an arbitrary parameter.

-- Imports
local floor, min, max, abs = math.floor, math.min, math.max, math.abs;

-- DEBUG VERBOSITY
VFL._dv = 0;

-- Burning Crusade: Quick hack to figure out if we're on WoW 2.0 or 1.0
WoW20 = true;

------------------------------------
-- PRIMITIVE FUNCTIONS
------------------------------------
-- Constant functions
function VFL.Noop() end
function VFL.True() return true; end
function VFL.False() return false; end
function VFL.Zero() return 0; end
function VFL.One() return 1; end
function VFL.Nil() return nil; end
function VFL.Identity(x) return x; end

-- Constant empty table.
VFL.emptyTable = {};

------------------------------------
-- MATH
------------------------------------
-- math.mod is broken on negative dividends
-- Here is a fixed version
function VFL.mod(k, n)
	return k - math.floor(k/n)*n;
end

-- Burning Crusade: fix for missing math.mod (which is used everywhere...)
VFL.mmod = math.fmod;
-- Fractional part extraction
VFL.modf = math.modf;

-- Quick and dirty rounding
function VFL.round(x)
	local i,f = math.modf(x);
	if i>=0 then
		if(f > 0.5) then return i+1; else return i; end
	else
		if(f < -0.5) then return i-1; else return i; end
	end
end

-- Are two numbers "close?" (within an epsilon distance)
function VFL.close(x, y)
	return (math.abs(x-y) < 0.000001);
end

-- Constrain a number to lie between certain boundaries.
function VFL.clamp(n, min, max)
	if (type(n) ~= "number") then return min; end
	if(n < min) then return min; elseif(n > max) then return max; else return n; end
end

-------- Linear interpolation
local function clamp01(x)
	if(x<0) then return 0; elseif(x>1) then return 1; else return x; end
end
function lerp1(t, x0, x1)
	if(t<0) then t=0; elseif(t>1) then t=1; end
	local d = 1-t;
	return d*x0 + t*x1;
end

function lerp2(t, x0, x1, y0, y1)
	if(t<0) then t=0; elseif(t>1) then t=1; end
	local d = 1-t;
	return d*x0 + t*x1, d*y0 + t*y1;
end

function lerp1x2(t0, t1, x0, x1)
	if(t0 < 0) then t0 = 0; elseif(t0 > 1) then t0 = 1; end
	if(t1 < 0) then t1 = 0; elseif(t1 > 1) then t1 = 1; end
	local d0, d1 = 1-t0, 1-t1;
	return d0*x0 + t0*x1, d1*x0 + t1*x1;
end

function lerp4(t, x0, x1, y0, y1, z0, z1, u0, u1)
	if(t<0) then t=0; elseif(t>1) then t=1; end
	local d = 1-t;
	return d*x0 + t*x1, d*y0 + t*y1, d*z0 + t*z1, d*u0 + t*u1;
end

function lerp5(t, x0, x1, y0, y1, z0, z1, u0, u1, v0, v1)
	if(t<0) then t=0; elseif(t>1) then t=1; end
	local d = 1-t;
	return d*x0 + t*x1, d*y0 + t*y1, d*z0 + t*z1, d*u0 + t*u1, d*v0 + t*v1;
end

function lerp6(t, x0, x1, y0, y1, z0, z1, u0, u1, v0, v1, w0, w1)
	if(t<0) then t=0; elseif(t>1) then t=1; end
	local d = 1-t;
	return d*x0 + t*x1, d*y0 + t*y1, d*z0 + t*z1, d*u0 + t*u1, d*v0 + t*v1, d*w0 + t*w1;
end

function cosineInterpolation(start, finish, mu)
    local mu2 = (1-math.cos(mu*math.pi))/2;
    return (start*(1-mu2)+finish*mu2);
--~     return start+(finish-start)*(1- math.cos(math.pi*mu))/2;
end

function linearInterpolation(start, finish, mu)
    return lerp1(mu, start, finish);
end

------------------------------------
-- OPERATIONS ON TABLES
------------------------------------
-- isempty
-- Returns true iff the table T has no entries whatsoever.
function VFL.isempty(T)
	for k,v in pairs(T) do return false; end
	return true;
end

-- empty
-- Nils out all entries of T
function VFL.empty(T)
	for k,v in pairs(T) do T[k] = nil; end
end

-- tsize
-- Return the actual size of the table T.
function VFL.tsize(T)
	local i = 0;
	for _,_ in pairs(T) do i = i + 1; end
	return i;
end

-- getkeys
-- Returns an array containing the unique keys of the table T
function VFL.getkeys(T)
	if(T == nil) then return nil; end
	local ret = {};
	for k,v in pairs(T) do table.insert(ret, k); end
	return ret;
end

-- filteredIterator
-- Returns a pairs()-type iterator function over the given table that only returns
-- entries that match the given filter f(k,v).
function VFL.filteredIterator(T, f)
	local k = nil;
	return function()
		local v;
		k,v = next(T,k);
		while k and (not f(k,v)) do k,v = next(T,k); end
		return k,v;
	end;
end

-- An unordered iterator over the values of T
function VFL.vals(T)
	local k = nil;
	return function()
		local v;
		k,v = next(T,k);
		return v;
	end
end

-- Like ipairs(), only just returns values.
function VFL.ivals(T)
	local i = 0;
	return function()
		i = i + 1;
		return T[i];
	end
end

-- copy
-- Creates an identical, deep copy of T
function VFL.copy(T)
	if(T == nil) then return nil; end
	local out = {};
	local k,v;
	for k,v in pairs(T) do
		if type(v) == "table" then
			out[k] = VFL.copy(v); -- deepcopy subtable
		else
			out[k] = v; -- softcopy primitives
		end
	end
	return out;
end

-- copyInto
-- Copies T[k] into D[k] for all k in keys(T)
-- T is unchanged, and all other entries of D are unchanged.
function VFL.copyInto(D, T)
	for k,v in pairs(T) do
		if type(v) == "table" then D[k] = VFL.copy(v); else D[k] = v; end
	end
	return true;
end

-- collapse
-- Sets to nil all entries of D that do not have a corresponding
-- entry in T, i.e. if T[k] == nil then D[k] will be made nil.
-- T is unchanged.
function VFL.collapse(D, T)
	if(D == nil) or (T == nil) then return false; end
	for k,_ in pairs(D) do
		if T[k] == nil then D[k] = nil; end
	end
	return true;
end

-- copyOver
-- Makes the table referenced by D identical to the table referenced by T.
-- T is unchanged.
function VFL.copyOver(D, T)
	return (VFL.copyInto(D,T) and VFL.collapse(D,T));
end;

-- mixin
-- Add all of the function entries of T to D if they don't already exist.
-- If "force" is true, mixes in even if the entries already exist
function VFL.mixin(D, T, force)
	for k,v in pairs(T) do
		if (type(v) == "function") and (force or (D[k] == nil)) then
			D[k] = v;
		end
	end
end

-- unmix
-- Nil all the function entries in D that have corresponding entries in T.
-- "Reverses" the operation of mixin.
function VFL.unmix(D, T)
	for k,v in pairs(T) do
		if (type(v) == "function") and (D[k] == v) then
			D[k] = nil;
		end
	end
end

-- vfind
-- Returns k such that T[k] == v, or nil if no such k exists.
function VFL.vfind(T, v)
	if not T then return nil; end
	for k,val in pairs(T) do
		if val == v then return k; end
	end
	return nil;
end

-- vmatch
-- Returns k,T[k] such that b(T[k]), or nil if no such k exists.
function VFL.vmatch(T, b)
	if not T then return nil; end
	for k,val in pairs(T) do
		if b(val) then return k,val; end
	end
	return nil;
end

-- vremove
-- Locates the first i such that L[i] = v, then removes it, returning v.
function VFL.vremove(L, v)
	local n = table.getn(L);
	for i=1,n do if L[i] == v then return table.remove(L,i); end end
	return nil;
end

-- filter
-- Returns new L' < L with b(x) true for all x in L'
function VFL.filter(L, b)
	if not L then return nil; end
	local tmp = {};
	for _,v in pairs(L) do
		if b(v) then table.insert(tmp, v); end
	end
	return tmp;
end

-- filterInPlace
-- Modifies L, removing all elements for which b(x) is false.
function VFL.filterInPlace(L, b)
	if (not L) or (not b) then return nil; end
	local n,i = #L, 1;
	while (i <= n) do
		if b(L[i]) then i=i+1; else table.remove(L,i); n=n-1; end
	end
end

-- removeFieldMatches
-- From L (which is assumed to be a list of tables) remove all entries
-- whose field "field" has value "val". Returns the number of entries removed
function VFL.removeFieldMatches(L, field, val)
	if (type(L) ~= "table") or (field == nil) then return 0; end
	local n,i,r = #L, 1, 0;
	while (i <= n) do
		if (L[i][field] ~= val) then i=i+1; else table.remove(L, i); n=n-1; r=r+1; end
	end
	return r;
end

-- invert
-- Returns a table T' whose keys are the values of T and whose values are corresponding keys.
-- This function is invalid for inputs T with duplicated values.
function VFL.invert(T)
	if(T == nil) then return nil; end
	local ret = {};
	for k,v in pairs(T) do ret[v] = k; end
	return ret;
end

-- transform
-- Return a table T' whose pairs are related to pairs of T by (k',v')=f(k,v).
-- f is a two-argument function valid on the pairs of T
function VFL.transform(T, f)
	if(T == nil) then return nil; end
	local ret = {};
	local kp, vp;
	for k,v in pairs(T) do
		kp,vp = f(k,v);
		ret[kp] = vp;
	end
	return ret;
end

-- transformInPlace
-- Modifies the values of the table T based on a function f(k,v) of the pair.
function VFL.transformInPlace(T, f)
	if type(T) ~= "table" then return nil; end
	for k,v in pairs(T) do T[k] = f(k,v); end
	return T;
end

-- asize
-- Forces the indices of the array A to be valid for the range [1..n]. Any indices outside of this range
-- are quashed, and any indices inside this range that are missing are added, with the given default value.
function VFL.asize(A, n, default)
	for k,_ in ipairs(A) do
		if(k>n) then A[k] = nil; end
	end
	for i=1,n do
		if not A[i] then A[i] = default; end
	end
end

-- asizeup
-- Like asize, only will not quash entries beyond the end.
function VFL.asizeup(A, n, default)
	for i=1,n do
		if not A[i] then A[i] = default; end
	end
end



----------------------------------
-- OPERATIONS ON FUNCTIONS
----------------------------------
--- If f is a function, return f evaluated at the arguments, otherwise return f
function VFL.call(f, ...)
	if type(f) == "function" then return f(...); else return f; end
end

--- Wrap a "method invocation" on an object into a portable closure.
function VFL.WrapInvocation(obj, meth)
	if obj then
		return function(...) 
			return meth(obj, ...); 
		end
	else
		return meth;
	end
end

--- Create a simple hook.
-- @param fnBefore The function to call first in the hook chain.
-- @param fnAfter The function to call second in the hook chain.
-- @return The new hook chain.
function VFL.hook(fnBefore, fnAfter)
	-- If one of the hooks is invalid, just return the other.
	if (not fnBefore) or (fnBefore == VFL.Noop) then
		return fnAfter;
	elseif (not fnAfter) or (fnAfter == VFL.Noop) then
		return fnBefore;
	end
	-- Otherwise generate the hook.
	return function(...)
		fnBefore(...); fnAfter(...);
	end
end

-----------------------------------
-- OPERATIONS ON STRINGS
-----------------------------------
-- Convert nil to the empty string
function VFL.nonnil(str)
	return (str or "");
end

-- A "flag string" is a string where the presence of a character indicates the
-- truth of a property
-- Check if a flag string contains a given flag.
function VFL.checkFlag(str, flag)
	if(str == nil) then return false; end
	return string.find(str, flag, 1, true);
end

-- Set a flag in the given flag string.
function VFL.setFlag(str, flag)
	if(str == nil) then return flag; end
	if VFL.checkFlag(str,flag) then return str; else return str .. flag; end
end

-- Get the first space-delimited word from the given string
-- (word, rest) = VFL.word(str)
function VFL.word(str)
	if(str == nil) or (str == "") then return nil; end
	local i = string.find(str, " ", 1, true);
	if(i == nil) then return str, ""; end
	return string.sub(str, 1,  i-1), string.sub(str, i+1, -1);
end

-- Get the first \n-delimited line from the given string
-- (word, rest) = VFL.line(str)
function VFL.line(str)
	if(str == nil) or (str == "") then return nil; end
	local i = string.find(str, "\n", 1, true);
	if(i == nil) then return str, ""; end
	return string.sub(str, 1,  i-1), string.sub(str, i+1, -1);
end

-- Capitalize the first letter of a string
function VFL.capitalize(str)
	return string.gsub(str, "^%l", string.upper);
end

-- Trim all leading and trailing whitespace from a string
function VFL.trim(str)
	if not str then return nil; end
	_,_,str = string.find(str,"^%s*(.*)");
	if not str then return ""; end
	_,_,str = string.find(str,"(.-)%s*$");
	if not str then return ""; end
	return str;
end

-- Determines if the string is a valid identity, that is, pure alphanumerics, dashes, and underlines
function VFL.isValidIdentity(str)
	if not str then return false; end
	if string.find(str,"^[%w_-]*$") then return true; else return false; end
end

-- Determines if the string is a valid name (alphanumeric followed by alpha/space followed by alpha)
function VFL.isValidName(str)
	if not str then return false; end
	if string.find(str,"^%w[%w%s]*%w$") then return true; else return false; end
end

--------------------------------------------------
-- INTERNATIONALIZATION (has been move)
--------------------------------------------------
--local i18n_table = {};

--function i18n(str)
--	if not str then return nil; end
--	return i18n_table[str] or str;
--end

--function VFL.internationalize(locale, data)
--	if GetLocale() == locale then
		-- Load the translations into the translation table
--		for k,v in pairs(data) do i18n_table[k] = v; end
--		data = nil;
--	end
--end

----------------------------------------------
-- BASIC IO
----------------------------------------------
-- Print a single line to the chat window.
function VFL.print(str)
	if(str == nil) then return; end
	ChatFrame1:AddMessage(str, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
end

-- Print a single line in the center of the screen.
function VFL.cprint(str)
	if(str == nil) then return; end
	UIErrorsFrame:AddMessage(str, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1.0, UIERRORS_HOLD_TIME);
end

-- Print a string for debugging at the given verbosity level.
function VFL.debug(str, level)
	if(not level) or (VFL._dv > level) then
		VFL.print("[Debug] " .. str);
	end
end

-----------------------------------------
-- Serialization subroutines
-----------------------------------------
function VFL.isArray(tbl)
	local z,i = 0,0;
	for _,_ in pairs(tbl) do z = z + 1; end
	if tbl.n then z=z-1; end
	for _,_ in ipairs(tbl) do i=i+1; end
	if i == z then return true; else return nil; end
end

local function GetEntryCount(tbl)
	local i = 0;
	for _,_ in pairs(tbl) do i = i + 1; end
	return i;
end

function Serialize(obj)
	if(obj == nil) then
		return "";
	elseif (type(obj) == "string") then
		return string.format("%q", obj);
	elseif (type(obj) == "table") then
		local str = "{ ";
		if obj[1] and ( table.getn(obj) == GetEntryCount(obj) ) then
			-- Array case
			for i=1,table.getn(obj) do str = str .. Serialize(obj[i]) .. ","; end
		else
			-- Nonarray case
			for k,v in pairs(obj) do
				if (type(k) == "number") then
					str = str .. "[" .. k .. "]=";
				elseif (type(k) == "string") then
					str = str .. '["' .. k .. '"]=';
				else
					error("bad table key type");
				end
				str = str .. Serialize(v) .. ",";
			end
		end
		-- Strip trailing comma, tack on syntax
		return string.sub(str, 0, string.len(str) - 1) .. "}";
	elseif (type(obj) == "number") then
		return tostring(obj);
	elseif (type(obj) == "boolean") then
		return obj and "true" or "false";
	else
		error("could not serialize object of type " .. type(obj));
	end
end

function Deserialize(data)
	if not data then return nil; end
	local dsFunc = loadstring("return " .. data);
	if dsFunc then 
		-- Prevent the deserialization function from making external calls
		setfenv(dsFunc, VFL.emptyTable);
		-- Call the deserialization function
		return dsFunc();
	else 
		return nil; 
	end
end


------------------------------------------------
-- WoW UI related
------------------------------------------------


local ietbl = {};
ietbl["ADDON_LOADED"] = true;
ietbl["VARIABLES_LOADED"] = true;
ietbl["SPELLS_CHANGED"] = true;
ietbl["PLAYER_LOGIN"] = true;
ietbl["PLAYER_ENTERING_WORLD"] = true;
ietbl["PLAYER_LEAVING_WORLD"] = true;

--- Determine if an event is a WoW game initialization event.
-- @param ev The event to check.
-- @return TRUE iff the event is a WoW init event.
function VFL.IsGameInitEvent(ev)
	return ietbl[ev];
end
