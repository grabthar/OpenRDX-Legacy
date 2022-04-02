-- UITools.lua
-- OpenRDX 

local loops = {
    { text = "NONE" },
    { text = "REPEAT" },
    { text = "BOUNCE" }
};
local function lmOnBuild() return loops; end
RDXUI.LoopSelectionFunc = lmOnBuild;

local smoothing = {
    { text = "IN" },
    { text = "OUT" },
    { text = "IN_OUT" },
    { text = "None" }
};
local function smOnBuild() return smoothing; end
RDXUI.SmoothSelectionFunc = smOnBuild;


