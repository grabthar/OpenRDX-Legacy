-- OpenRDX
-- Sigg Rashgarroth EU
-- Desktop Main function
-- Development Mode

-- This file has been removed from toc file

-------------------------------------------------------
-- Developpment flag
-------------------------------------------------------
--[[
local function ActivateDev()
	RDXU.devflag = true;
	RDX.print(i18n("Development Mode ON"));
end

function RDXDK.ActivateDev()
	VFLUI.MessageBox("Activation development", "Do you want to activate Unitframes, Artframes and Windows Editors? Please visit our website http://www.openrdx.com to learn how to use editors.", nil, "No", nil, "Yes", ActivateDev);
end

RDX.systemMenu:RegisterMenuFunction(function(ent)
	if not RDXU.devflag then
		ent.text = i18n("Development Mode |cFFFF0000[OFF]|r");
		ent.OnClick = function() VFL.poptree:Release(); RDXDK.ActivateDev(); end;
	else
		ent.text = i18n("Development Mode |cFF00FF00[ON]|r");
		ent.OnClick = function() VFL.poptree:Release(); RDXU.devflag = false; RDX.print(i18n("Development Mode OFF"));  end;
	end
end);

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	if RDXU.devflag then
		RDX.print(i18n("Development Mode ON"));
	else
		RDX.print(i18n("Development Mode OFF"));
	end
end);
]]