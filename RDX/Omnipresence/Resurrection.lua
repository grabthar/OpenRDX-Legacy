-- Resurrection.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED CONTENT SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Rez monitoring.

----------------------------------
-- REZ MONITOR - CONSUMER SIDE
-- Intercept sent RPCs and maintain the rez sets.
----------------------------------

---------- The set definitions
local inc = RDX.Set:new();
inc.name = "<Rez Incoming>";
RDX.RegisterSet(inc);
local done = RDX.Set:new();
done.name = "<Rez Done>";
RDX.RegisterSet(done);

-- "Sweeper" code - constantly remove alive people from the rez sets.
local function Sweep()
	RDX.BeginEventBatch();
	for un,_,unit in inc:Iterator() do
		if not unit:IsDead() then	inc:_Set(un, false); end
	end
	for un,_,unit in done:Iterator() do
		if not unit:IsDead() then done:_Set(un, false); end
	end
	RDX.EndEventBatch();
end

local refcount = 0;
local function Activate()
	refcount = refcount + 1;
	if refcount == 1 then
		VFL.AdaptiveUnschedule("_rezmonitor");
		VFL.AdaptiveSchedule("_rezmonitor", 0.5, Sweep); 
	end
end
local function Deactivate()
	if refcount > 0 then
		refcount = refcount - 1;
		if refcount == 0 then VFL.AdaptiveUnschedule("_rezmonitor"); end
	end
end
inc._OnActivate = Activate; inc._OnDeactivate = Deactivate;
done._OnActivate = Activate; done._OnDeactivate = Deactivate;

-- Setclass registration.
-- Uses the same IDs as Arakir's version for compatibility between the two.
RDX.RegisterSetClass({
	name = "rez";
	title = i18n("Rez Status");
	GetUI = function(parent, desc)
		local ui = VFLUI.RadioGroup:new(parent);
		ui:SetLayout(2,2);
		ui.buttons[1]:SetText("Incoming"); ui.buttons[2]:SetText("Done");
		if desc and desc.n then ui:SetValue(desc.n); end

		function ui:GetDescriptor() return {class="rez", n=ui:GetValue()}; end

		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil end, ui.Destroy);
		return ui;
	end;
	FindSet = function(desc)
		if not desc then return nil; end
		if desc.n == 1 then
			return inc;
		elseif desc.n == 2 then
			return done;
		else
			return nil;
		end
	end
});

----------- RPC bindings
RPC_Group:Bind("rez_start", function(ci, targ)
	local u = RPC.GetSenderUnit(ci); if not u then return; end
	targ = RDX.GetUnitByNameIfInGroup(targ); if not targ then return; end
	-- If the rez target is dead, or he already has a pending rez, abort.
	if (not targ:IsDead()) or (done:IsMember(targ)) then return; end
	local n = inc:IsMember(targ);
	if n then
		-- There were already incoming rezzes on this guy, increment count.
		inc:_Poke(targ.nid, n+1);
	else
		-- Start us off at 1 incoming rez.
		inc:_Set(targ.nid, 1);
	end
end);

RPC_Group:Bind("rez_done", function(ci, targ)
	local u = RPC.GetSenderUnit(ci); if not u then return; end
	targ = RDX.GetUnitByNameIfInGroup(targ); if not targ then return; end
	-- If the target isn't done or already has an inc rez, abort.
	if (not targ:IsDead()) then return; end
	-- Update the sets.
	done:_Set(targ.nid, true); inc:_Set(targ.nid, false);
end);

RPC_Group:Bind("rez_fail", function(ci, targ)
	local u = RPC.GetSenderUnit(ci); if not u then return; end
	targ = RDX.GetUnitByNameIfInGroup(targ); if not targ then return; end
	-- If the target isn't done or already has an inc rez, abort.
	if (not targ:IsDead()) or (done:IsMember(targ)) then return; end
	local n = inc:IsMember(targ);
	if n and n > 0 then
		-- Decrement the number of incoming rezzes.
		n = n - 1;
		-- If the last of the incoming rezzes failed, remove from the incoming set.
		-- Otherwise update the count.
		if n == 0 then 
			inc:_Set(targ.nid, false); 
		else
			inc:_Poke(targ.nid, n);
		end
	end
end);

RPC_Group:Bind("rez_ss", function(ci)
	local u = RPC.GetSenderUnit(ci); if not u then return; end
	-- We have a soulstone ready for use.
	-- Remove us from inc rezzes, just in case we were there
	inc:_Set(u.nid, false);
	-- Add us to completed rezzes
	done:_Set(u.nid, true);
end);

----------------------------------
-- REZ MONITOR - CASTER SIDE
-- Watch spellcasts and RPC when rezzes happen.
----------------------------------
local pclass = RDXPlayer:GetClassMnemonic();
local rezSpell = nil;
if pclass == "PRIEST" then
	rezSpell = i18n("Resurrection");
elseif pclass == "PALADIN" then
	rezSpell = i18n("Redemption");
elseif pclass == "SHAMAN" then
	rezSpell = i18n("Ancestral Spirit");
elseif pclass == "DRUID" then
	rezSpell = i18n("Rebirth");
end

if rezSpell then
	local rezTarget = nil;
	-- Detect when a rez is first cast.
	WoWEvents:Bind("UNIT_SPELLCAST_SENT", nil, function()
		if (arg1 ~= "player") or (arg2 ~= rezSpell) then return; end
		local target = RDX.GetUnitByNameIfInGroup(string.lower(arg4));
		if target then
			rezTarget = target;
			RPC_Group:Invoke("rez_start", target.name);
		end
	end);

	-- Detect when a rez is finished.
	WoWEvents:Bind("UNIT_SPELLCAST_SUCCEEDED", nil, function()
		if not rezTarget then return; end
		RPC_Group:Invoke("rez_done", rezTarget.name);
		rezTarget = nil;
	end);

	-- Detect rez failure
	local function fail()
		if not rezTarget then return; end
		RPC_Group:Invoke("rez_fail", rezTarget.name);
		rezTarget = nil;
	end
	WoWEvents:Bind("UNIT_SPELLCAST_FAILED", nil, fail);
	WoWEvents:Bind("UNIT_SPELLCAST_INTERRUPTED", nil, fail);
end

-- Watch for my death. If I have a soulstone up, then broadcast me as "recoverable."
WoWEvents:Bind("PLAYER_DEAD", nil, function()
	if HasSoulstone() then
		-- Wait 1 sec for lag, if the other end doesn't think we're dead this won't work.
		VFL.schedule(1.5, RPC_Group.Invoke, RPC_Group, "rez_ss");
	end
end);

----------------------------
-- REZ MONITOR WINDOW DEFINITION
----------------------------
local rezm_version = 2007051003;

-- At loadtime, let's create the default rezmonitor if it doesn't exist
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local builtin = RDXDB.GetOrCreatePackage("Builtin");
	local vdata = builtin["rezm_version"]; 
	if (not vdata) or (type(vdata.version) ~= "number") or (vdata.version < rezm_version) then
	else
		return;
	end
	builtin["rezm_version"] = { ty = "Typeless", version = rezm_version, data = {} };

	builtin["rezm_sort"] = {
			["ty"] = "Sort",
			["version"] = 2,
			["data"] = {
				["sort"] = {
					{
						["op"] = "class",
					}, -- [1]
					{
						["op"] = "alpha",
					}, -- [2]
				},
				["set"] = {
					["class"] = "file",
					["file"] = "Builtin:rezm_set",
				},
			},
	};

	builtin["win_rezm_default"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Description",
					["description"] = "A window for monitoring targets of resurrection spells currently being cast.",
				}, -- [1]
				{
					["feature"] = "Frame: Default",
					["title"] = "Rez Monitor",
				}, -- [2]
				{
					["feature"] = "UnitFrame",
					["design"] = "Builtin:rezm_uf",
				}, -- [3]
				{
					["feature"] = "Data Source: Sort",
					["sortPath"] = "Builtin:rezm_sort",
				}, -- [4]
				{
					["feature"] = "Grid Layout",
					["dxn"] = 2,
					["cols"] = 3,
					["axis"] = 1,
					["autoShowHide"] = 1,
				}, -- [5]
			},
		};

		builtin["rezm_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "rez",
						["n"] = 1,
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["class"] = "rez",
						["n"] = 2,
					}, -- [2]
				}, -- [3]
			},
		};

		builtin["rezm_uf"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "ColorVariable: Static Color",
					["name"] = "yellow",
					["color"] = {
						["a"] = 0.4638837575912476,
						["b"] = 0,
						["g"] = 0.7176470588235294,
						["r"] = 0.788235294117647,
					},
				}, -- [1]
				{
					["feature"] = "ColorVariable: Static Color",
					["name"] = "green",
					["color"] = {
						["a"] = 0.5088750422000885,
						["b"] = 0.0392156862745098,
						["g"] = 0.407843137254902,
						["r"] = 0,
					},
				}, -- [2]
				{
					["feature"] = "Variable: Unit In Set",
					["name"] = "rezinc",
					["set"] = {
						["n"] = 1,
						["class"] = "rez",
					},
				}, -- [3]
				{
					["feature"] = "Variable: Unit In Set",
					["name"] = "rezdone",
					["set"] = {
						["n"] = 2,
						["class"] = "rez",
					},
				}, -- [4]
				{
					["feature"] = "base_default",
					["h"] = 12,
					["version"] = 1,
					["w"] = 50,
					["alpha"] = 1,
				}, -- [5]
				{
					["feature"] = "txt_np",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
					["version"] = 1,
					["h"] = 12,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["owner"] = "Base",
					["w"] = 50,
					["name"] = "np",
				}, -- [6]
				{
					["cleanupPolicy"] = 2,
					["owner"] = "Base",
					["w"] = 50,
					["feature"] = "texture",
					["h"] = 12,
					["name"] = "hlt",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
					["version"] = 1,
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["color"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["blendMode"] = "BLEND",
					},
				}, -- [7]
				{
					["feature"] = "Highlight: Texture Map",
					["color"] = "yellow",
					["flag"] = "rezinc_flag",
					["texture"] = "hlt",
				}, -- [8]
				{
					["feature"] = "Highlight: Texture Map",
					["color"] = "green",
					["flag"] = "rezdone_flag",
					["texture"] = "hlt",
				}, -- [9]
			},
		};

end);

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	if not RDXDB.CheckObject("Builtin:win_rezm", "Window") then
		local mbo = RDXDB.TouchObject("Builtin:win_rezm");
		mbo.ty = "SymLink"; mbo.version = 1; mbo.data = "Builtin:win_rezm_default";
	end
end);

----------------------------
-- PUBLIC API
----------------------------
--- Determine if the current player can rez.
function Logistics.PlayerCanRez()
	return rezSpell;
end
