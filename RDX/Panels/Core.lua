-- Core.lua
-- OpenRDX
-- Sigg / Rashgarroth EU
-- Manage RDX Panels (main menu and editors)

RDXPM = RegisterVFLModule({
	name = "RDXPM";
	title = i18n("RDX Panel Management");
	description = "RDX Panel Management";
	version = {1,0,0};
	parent = RDX;
});

--- The root dispatch table.
-- Events:
-- LAYOUT(session) - fired whenever a layout button is need.

RDXPMEvents = DispatchTable:new();

-- store and restore RDX Editors positions
-- positions are stored in RDXG

function RDXPM.Ismanaged(name)
	if RDXG.EditorsPanel[name] then return true; else return false; end
end

function RDXPM.StoreLayout(frame, name)
	local lt,tt,rt,bt = GetUniversalBoundary(frame);
	local tbl = {l=lt, t=tt, r=rt, b=bt};
	RDXG.EditorsPanel[name] = tbl;
end

function RDXPM.RestoreLayout(frame, name)
	local tbl = RDXG.EditorsPanel[name];
	SetAnchorFramebyPosition(frame, "TOPLEFT", tbl.l, tbl.t, tbl.r, tbl.b);
end

-- delete all positions
function RDXPM.ResetLayouts()
	RDXG.MainPanel = nil;
	RDXG.EditorsPanel = nil;
	ReloadUI();
end

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, function()
	if not RDXG.MainPanel then RDXG.MainPanel = {}; end
	if not RDXG.EditorsPanel then RDXG.EditorsPanel = {}; end
end);

RDXEvents:Bind("USER_RESET_UI", nil, function()
	RDXPM.ResetLayouts()
end);

RDX.RegisterSlashCommand("reset", RDXPM.ResetLayouts);

