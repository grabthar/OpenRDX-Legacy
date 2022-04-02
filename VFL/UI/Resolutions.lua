-- Resolutions.lua
-- OpenRDX
-- Sigg / Rashgarroth EU

-- This file contains functions to manage Resolution

local resolutions = {};

--800x600
--1024x768
--1280x768
--1280x1024


local function ParseResolution(res)
	if not res then return nil; end
	local _, _, x, y = string.find(res, "^(.*)x(.*)$");
	return x,y;
end

local function CalculateRatio(res)
	if not res then return nil; end
	local x, y = ParseResolution(res);
	return x / y, x, y;
end

-- scale are always base on y resolution
local function CalculateScale(resSource, resTarget)
	if (not resSource) or (not resTarget) then return nil; end
	local _, ys = ParseResolution(resSource);
	local _, yt = ParseResolution(resTarget);
	return yt / ys;
end

local function CalculatePosition(resSource, resTarget, pos)
	if (not resSource) or (not resTarget) then return nil; end
	local xs, ys = ParseResolution(resSource);
	local xt, yt = ParseResolution(resTarget);
	return newpos;
end

function VFLUI.GetCurrentResolution()
	return ({GetScreenResolutions()})[GetCurrentResolution()];

end

function VFLUI.GetCurrentEffectiveScale()
	return UIParent:GetEffectiveScale();
end

local resolutiondd = {};
for k,v in pairs({GetScreenResolutions()}) do
	table.insert(resolutiondd, { text = v } );
end

function VFLUI.ResolutionsDropdownFunction() return resolutiondd; end

-- /script VFL.print(VFLUI.GetCurrentResolution());


--WoWEvents:Bind("VARIABLES_LOADED", nil, function()
--local resolutions = {GetScreenResolutions()}
--for i,entry in pairs(resolutions) do
--  DEFAULT_CHAT_FRAME:AddMessage(format('Resolution %u: %s', i, entry))
--end

--end);