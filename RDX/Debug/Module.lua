-- Module.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- The RDXM_Debug base module
RDXM_Debug = RegisterVFLModule({
	name = "Debug";
	title = "Debug";
	description = "Debugging functionality for RDX.";
	parent = RDX;
	version = {1,0,0};
});

--local function TheDebugMenu(menu, cell)
	--local mnu = {};
	--table.insert(mnu, {text = "Set debugger", OnClick = function() RDXM_Debug.SetDebugger(); menu:Release(); end});
	--table.insert(mnu, {text = "Disrupt", OnClick = function() RDX._Disrupt(); menu:Release(); end});
	--if RDXU.cdebug then
	--	table.insert(mnu, {text = ("Store Unitframe Compiler |cFF00FF00[ON]|r"), OnClick = function() RDXU.cdebug = nil; VFL.poptree:Release(); ReloadUI(); end});
	--else
	--	table.insert(mnu, {text = ("Store Unitframe Compiler |cFFFF0000[OFF]|r"), OnClick = function() RDXU.cdebug = true; VFL.poptree:Release(); end});
	--end
	--menu:Expand(cell, mnu);
--end

local function Breakdown(str, n)
	local ret, i = {}, 1;
	while str and string.len(str) > 0 do
		ret[i] = string.sub(str, 1, n);
		str = string.sub(str, n+1, -1);
		i=i+1;
	end
	return ret;
end

-- Serialized form viewer for objects
RDXDB.RegisterObjectMenuHandler(function(mnu, opath, dialog)
	--if RDXU.devflag then
		table.insert(mnu, {
			text = "Serialized form"; 
			OnClick = function()
				VFL.poptree:Release();
				VFL.print("-------------------------------");
				local tbl = Breakdown(Serialize(RDXDB.GetObjectData(opath)), 50);
				for _,v in ipairs(tbl) do VFL.print(v); end
				VFL.print("-------------------------------");
			end;
		});
	--end
end);

