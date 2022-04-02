-- NotSoPrimitives.lua
-- VFL
-- (C) 2005-2006 Bill Johnson and The VFL Project
--
-- Contains more advanced, less frequently used operations on tables and functions.

-----------------------------------------------------------------------------
-- GENERALIZED SUM
-- Collapses a table along its rows, by identifying certain rows
-- as being in certain equivalence classes, then accumulating over those
-- classes. (Similar to an aggregate SQL query.)
--
-- General algorithm:
--  Foreach row R in iterator:
--   Identify similarity class of row R sc(R) [via fnClassify(R)]
--   Get the representative row rep(sc(R)), creating if nonexistent [via fnGenRep(R)]
--   rep(sc(R)) <-- rep(sc(R)) + R [via fnAddInPlace(rep, R)]
--
-- Details of arguments:
--  * ri must be a Lua iterator that returns tables to be regarded as rows.
--  * fnClassify(R) must take a row and return a classification of that row, or nil if the row is to
--  be ignored. The classification function may split the row into up to 5 separate categories, each of which
--  must be returned.
--  * fnGenRep(R, class) must take a row and its class and generate a representative row suitable for fnAddInPlace.
--  * fnAddInPlace(Rrep, R) must set Rrep=Rrep+R.
--
-- Returns:
--  The cumulated representatives of each row class.
-- 
-- Usage:
--  Given a time series of events (hits with damage, for example) one might want to classify each type of hit
--  (Eviscerate, Sinister Strike, etc) and arrive at a final table describing each TYPE of hit and the TOTAL
--  or AVERAGE damage over that type. If fnClassify were a projection onto the hit-type axis, and
--  fnAddInPlace was a sum or average cumulator, this function would perform this task.
-----------------------------------------------------------------------------
function VFL.gsum(ri, fnClassify, fnGenRep, fnAddInPlace)
	-- Begin afresh
	local reps, classify = {}, {};
	-- Foreach row
	for R in ri do
		-- Attempt to classify row
		local c1, c2, c3, c4, c5 = fnClassify(R);
		-- If class is nil, ignore, otherwise proceed.
		if c1 then
			classify[1] = c1; classify[2] = c2; classify[3] = c3; classify[4] = c4; classify[5] = c5;
			-- For each classification...
			for _,rclass in pairs(classify) do
				-- Obtain representative row, creating one if none exists
				local rrep = reps[rclass];
				if not rrep then reps[rclass] = fnGenRep(R, rclass); rrep = reps[rclass]; end
				-- Add this row to the representative row, in place (i.e. rrep <-- rrep + R)
				if rrep then fnAddInPlace(rrep, R, rclass); end
			end -- for _,rclass in classify
		end -- if c1
	end -- for R in ri
	-- Return the representative rows.
	return reps;
end

-----------------------------------------------------------------
-- DESTRUCTURE
--
-- Applies a "destructuring operator" to a table, which extracts or transforms substructures 
-- of tables in an extremely general way. Similar to (but more general than) the 
-- pattern matching construct in languages like ML.
--
-- How it works: You provide a function f(context, key, value) that is evaluated at each pair 
-- of the table. This function is given a "context" object, which is the heart of the 
-- destructuring algorithm.
--
-- The context object provides lots of useful information, including the current recursion level
-- within the table, and the "path" of keys starting from the top that was used to reach the
-- current node.
-- While processing a node that's a table, you can decide whether to recurse or not. If you call
-- context:Recurse(key, value), the destructure will continue down that node. Otherwise it will not.
-- This gives you enhanced control over performance and can also make algorithms easy to write (only
-- recurse when needed.)
--
-- As the context is a lua table, you can also initialize it however you want, as well as storing
-- arbitrary information on it. However, you may not touch the following reserved fields:
-- context.depth - INTEGER - the current destructure depth
-- context.path - TABLE - the current path in the destructuring
-- context._func - FUNCTION - the destructure operator.
-- context.Recurse - FUNCTION - the recurse trigger.
--
-- At the end of the destructure, the context object is returned.
-------------------------------------------------------------------
local function dest_recurse(context, key, value)
	context.depth = context.depth + 1;
	context.path[context.depth] = key;
	for k,v in pairs(value) do
		context._func(context, k, v);
	end
	context.path[context.depth] = nil;
	context.depth = context.depth - 1;
end

function VFL.destructure(T, f, context)
	if (type(T) ~= "table") or (type(f) ~= "function") then 
		error("VFL.destructure: unexpected argument type"); 
	end
	-- Setup the context
	if type(context) ~= "table" then context = {}; end
	context.depth = 0; context.path = {}; context.Recurse = dest_recurse; context._func = f;
	-- Depth 0 scan
	for k,v in pairs(T) do
		f(context, k, v);
	end
	-- Done
	return context;
end

