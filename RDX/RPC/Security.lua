-- Security.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Base code for the RDX security and permissions system.

--- "Sanitize" a string, removing all quotations and anything else that could be used to inject
-- Lua code into a string.
function RDX.SanitizeCodeString(str)
	str = string.gsub(str, '"', '\\"');
	str = string.gsub(str, "'", "\\'");
	return str;
end

-----------------------------------------------------------------------------------
-- DANGEROUS OBJECT DETECTION
--
-- Detect objects that might contain Lua code or other exploitable mechanisms.
-- Warn the user before he installs any such object.
-----------------------------------------------------------------------------------

local dofs = {};

--- Register a dangerous object filter. The registration table has two fields:
-- matchType - The type of objects to match. "*" matches any type.
-- Filter - a function of the form F(metadata) called for each object to filter against.
--   Should return TRUE iff the object is dangerous.
function RDX.RegisterDangerousObjectFilter(tbl)
	if (not tbl) then error(i18n("expected table, got nil")); end
	if (not tbl.matchType) then error(i18n("missing table.matchType")); end
	if not tbl.Filter then error(i18n("missing table.Filter")); end

	-- Create the type table
	local x = dofs[tbl.matchType]; 
	if not x then
		x = {}; dofs[tbl.matchType] = x;
	end
	-- Add our filter to the table
	table.insert(x, tbl.Filter);
end

--- Using dangerous object filters, determine whether the given object is dangerous.
function RDX.IsDangerousObject(md)
	-- Any bad or untyped object is presumed dangerous.
	if (not md) or (not md.ty) then return true; end
	local filts = dofs[md.ty];
	if filts then
		for _,filt in pairs(filts) do if filt(md) then return true; end end
	end
	filts = dofs["*"];
	if filts then
		for _,filt in pairs(filts) do if filt(md) then return true; end end
	end
	return nil;
end

--- Determine whether any feature on the given feature list is dangerous.
function RDX.ContainsDangerousFeature(featList)
	for _,feature in pairs(featList) do
		if RDX.IsDangerousFeature(feature) then return true; end
	end
	return nil;
end

--- Determine whether the given feature is dangerous.
function RDX.IsDangerousFeature(feat)
	return nil;
end
