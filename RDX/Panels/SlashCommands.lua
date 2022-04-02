-- SlashCommands.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Infrastructure for basic slash-command handling.
local rdxslash = {};

function RDX.RegisterSlashCommand(name, fn)
	if (not name) then error(i18n("name is required")); end
	if rdxslash[name] then error(i18n("duplicate slash command registration ") .. name); end
	rdxslash[name] = fn;
end

SLASH_RDX1 = "/rdx";
SlashCmdList["RDX"] = function(arg)
	local cmd,arg = VFL.word(arg);
	if type(cmd) ~= "string" then return; end
	cmd = string.lower(cmd);
	if rdxslash[cmd] then
		rdxslash[cmd](arg);
	else
		RDX.print(i18n("USAGE: /rdx [command] [arguments]"));
		RDX.print(i18n("Valid commands are:"));
		for k,_ in pairs(rdxslash) do
			RDX.print("- /rdx " .. k);
		end
	end
end
