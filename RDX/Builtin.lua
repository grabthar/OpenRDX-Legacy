-- Builtin.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- A few useful built-in structures.

local strlower = string.lower;

local addonversion = RDX.version[1] .. "." .. RDX.version[2] .. "." .. RDX.version[3];

local function spellNamebyId(spellId)
	local name = GetSpellInfo(spellId)
	return name
end

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local default = RDXDB.GetOrCreatePackage("default");
	local builtin = RDXDB.GetOrCreatePackage("Builtin");
	if not default["assists"] then
		default["assists"] = {
			["ty"] = "NominativeSet",
			["version"] = 1,
			["data"] = {}
		};
	end

	-- Check builtin version; update if needed.
	local version = RDXDB.GetPackageMetadata("Builtin", "infoVersion");
	if (version ~= addonversion) then
		RDX.print(i18n("Builtin out of date, updating."));
		RDXDB.SetPackageMetadata("Builtin", "infoVersion", addonversion);
	else
		return;
	end
	
	builtin["version"] = nil;

	builtin["uf_multitrack_default"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "base_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 100,
					["alpha"] = 1,
				}, -- [1]
				{
					["fadeColor"] = {
						["a"] = 1,
						["b"] = 0,
						["g"] = 0,
						["r"] = 1,
					},
					["color"] = {
						["a"] = 1,
						["b"] = 0,
						["g"] = 0.5,
						["r"] = 0,
					},
					["w"] = 100,
					["feature"] = "Bar: RDX Unit HP Bar",
					["h"] = 14,
					["name"] = "hpbar",
					["hostileColor"] = {
						["a"] = 1,
						["b"] = 0,
						["g"] = 0.36,
						["r"] = 0.86,
					},
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["flo"] = -1,
					["texture"] = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1",
				}, -- [2]
				{
					["feature"] = "txt_np",
					["h"] = 14,
					["version"] = 1,
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["anchor"] = {
						["dx"] = 10,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["owner"] = "Base",
					["w"] = 65,
					["name"] = "np",
					["classColor"] = 1,
				}, -- [3]
				{
					["owner"] = "Base",
					["w"] = 25,
					["feature"] = "txt_status",
					["h"] = 14,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["ty"] = "hpp",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["name"] = "status_text",
				}, -- [4]
				{
					["feature"] = "Raid Target Icon",
					["h"] = 10,
					["name"] = "rti",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["owner"] = "Base",
					["w"] = 10,
					["drawLayer"] = "ARTWORK",
				}, -- [5]
			},
	}; -- uf_multitrack_default

	builtin["uf_hp_default"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "base_default",
					["version"] = 1,
					["h"] = 14,
					["a"] = 1,
					["w"] = 90,
					["alpha"] = 1,
					["ph"] = true,
				}, -- [1]
				{
					["feature"] = "Variables: Status Flags (dead, ld, feigned)",
				}, -- [2]
				{
					["feature"] = "Variable: Fractional health (fh)",
				}, -- [3]
				{
					["w"] = 50,
					["feature"] = "txt_np",
					["h"] = 14,
					["name"] = "np",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
					["owner"] = "Base",
					["classColor"] = 1,
					["version"] = 1,
				}, -- [4]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "status_text",
					["ty"] = "fdld",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [5]
				{
					["feature"] = "Bar: RDX Unit HP Bar",
					["fadeColor"] = {
						["r"] = 1,
						["g"] = 0,
						["b"] = 0,
					},
					["name"] = "hpbar",
					["h"] = 14,
					["color"] = {
						["r"] = 0,
						["g"] = 0.5,
						["b"] = 0,
					},
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["w"] = 90,
					["texture"] = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1",
				}, -- [6]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "text_hp_percent",
					["ty"] = "hpp",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [7]
			},
	}; -- builtin["uf_hp"]

	builtin	["uf_hpmana_default"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["a"] = 1,
					["h"] = 14,
					["alpha"] = 1,
					["w"] = 90,
					["ph"] = true,
					["feature"] = "base_default",
					["version"] = 1,
				}, -- [1]
				{
					["feature"] = "Variables: Status Flags (dead, ld, feigned)",
				}, -- [2]
				{
					["feature"] = "Variable: Fractional health (fh)",
				}, -- [3]
				{
					["feature"] = "Variable: Fractional mana (fm)",
				}, -- [4]
				{
					["feature"] = "Bar: RDX Unit HP Bar",
					["fadeColor"] = {
						["b"] = 0,
						["g"] = 0,
						["r"] = 1,
					},
					["name"] = "hpbar",
					["h"] = 7,
					["color"] = {
						["b"] = 0,
						["g"] = 0.5,
						["r"] = 0,
					},
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
					["w"] = 90,
					["texture"] = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1",
				}, -- [5]
				{
					["energyColor"] = {
						["b"] = 0,
						["g"] = 0.75,
						["r"] = 0.75,
					},
					["fadeColor"] = {
						["b"] = 0,
						["g"] = 0,
						["r"] = 1,
					},
					["w"] = 90,
					["rageColor"] = {
						["b"] = 0,
						["g"] = 0,
						["r"] = 1,
					},
					["feature"] = "Bar: RDX Unit Mana Bar",
					["h"] = 7,
					["name"] = "mpbar",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "BOTTOMLEFT",
						["rp"] = "BOTTOMLEFT",
						["af"] = "Base",
					},
					["texture"] = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1",
					["manaColor"] = {
						["b"] = 0.75,
						["g"] = 0,
						["r"] = 0,
					},
				}, -- [6]
				{
					["w"] = 50,
					["feature"] = "txt_np",
					["h"] = 14,
					["name"] = "np",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
					["classColor"] = 1,
					["owner"] = "Base",
					["version"] = 1,
				}, -- [7]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "text_hp_percent",
					["ty"] = "hpp",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [8]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "status_text",
					["ty"] = "fdld",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [9]
			},
	};

	builtin["uf_hpmissing_default"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Variables: Status Flags (dead, ld, feigned)",
				}, -- [1]
				{
					["feature"] = "Variable: Fractional health (fh)",
				}, -- [2]
				{
					["a"] = 1,
					["h"] = 14,
					["w"] = 90,
					["alpha"] = 1,
					["feature"] = "base_default",
					["version"] = 1,
					["ph"] = true,
				}, -- [3]
				{
					["w"] = 50,
					["feature"] = "txt_np",
					["h"] = 14,
					["name"] = "np",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
					["classColor"] = 1,
					["owner"] = "Base",
					["version"] = 1,
				}, -- [4]
				{
					["feature"] = "Bar: RDX Unit HP Bar",
					["fadeColor"] = {
						["r"] = 1,
						["g"] = 0,
						["b"] = 0,
					},
					["name"] = "hpbar",
					["h"] = 14,
					["color"] = {
						["r"] = 0,
						["g"] = 0.5,
						["b"] = 0,
					},
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["w"] = 90,
					["texture"] = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1",
				}, -- [5]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "text_hp_missing",
					["ty"] = "hpm",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [6]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "status_text",
					["ty"] = "fdld",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [7]
			},
	};

	builtin["uf_mana_default"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Variables: Status Flags (dead, ld, feigned)",
				}, -- [1]
				{
					["feature"] = "Variable: Fractional mana (fm)",
				}, -- [2]
				{
					["a"] = 1,
					["h"] = 14,
					["w"] = 90,
					["alpha"] = 1,
					["feature"] = "base_default",
					["ph"] = true,
					["version"] = 1,
				}, -- [3]
				{
					["w"] = 50,
					["feature"] = "txt_np",
					["h"] = 14,
					["name"] = "np",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
					["classColor"] = 1,
					["owner"] = "Base",
					["version"] = 1,
				}, -- [4]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "status_text",
					["ty"] = "fdld",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [5]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "text_mp_percent",
					["ty"] = "mpp",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [6]
				{
					["energyColor"] = {
						["r"] = 0.75,
						["g"] = 0.75,
						["b"] = 0,
					},
					["fadeColor"] = {
						["r"] = 1,
						["g"] = 0,
						["b"] = 0,
					},
					["w"] = 90,
					["rageColor"] = {
						["r"] = 1,
						["g"] = 0,
						["b"] = 0,
					},
					["feature"] = "Bar: RDX Unit Mana Bar",
					["h"] = 14,
					["name"] = "mpbar",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["manaColor"] = {
						["r"] = 0,
						["g"] = 0,
						["b"] = 0.75,
					},
					["texture"] = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1",
				}, -- [7]
			},
	};

	builtin["uf_name_default"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "base_default",
					["ph"] = true,
					["version"] = 1,
					["h"] = 14,
					["a"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["w"] = 90,
					["feature"] = "txt_np",
					["h"] = 14,
					["name"] = "np",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
					["classColor"] = 1,
					["owner"] = "Base",
					["version"] = 1,
				}, -- [2]
			},
	}; -- builtin["uf_name"]


	builtin["uf_assist_default"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "base_default",
					["ph"] = true,
					["version"] = 1,
					["h"] = 24,
					["alpha"] = 1,
					["w"] = 110,
				}, -- [1]
				{
					["feature"] = "Variables: Status Flags (dead, ld, feigned)",
				}, -- [2]
				{
					["feature"] = "Variable: Fractional health (fh)",
				}, -- [3]
				{
					["fadeColor"] = {
						["a"] = 1,
						["b"] = 0,
						["g"] = 0,
						["r"] = 1,
					},
					["color"] = {
						["a"] = 1,
						["b"] = 0,
						["g"] = 0.5,
						["r"] = 0,
					},
					["w"] = 108,
					["feature"] = "Bar: RDX Unit HP Bar",
					["h"] = 14,
					["name"] = "hpbar",
					["hostileColor"] = {
						["a"] = 1,
						["b"] = 0,
						["g"] = 0.4627450980392157,
						["r"] = 0.8509803921568627,
					},
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
					["texture"] = "Interface\\\\Addons\\\\RDX\\\\Skin\\\\bar1",
				}, -- [4]
				{
					["w"] = 70,
					["feature"] = "txt_np",
					["h"] = 14,
					["name"] = "np",
					["anchor"] = {
						["dx"] = 12,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "hpbar",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["version"] = 1,
					["owner"] = "Base",
					["classColor"] = 1,
				}, -- [5]
				{
					["feature"] = "Raid Target Icon",
					["h"] = 12,
					["name"] = "rti",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "hpbar",
					},
					["owner"] = "Base",
					["w"] = 12,
					["drawLayer"] = "ARTWORK",
				}, -- [6]
				{
					["w"] = 40,
					["feature"] = "txt_status",
					["h"] = 14,
					["name"] = "text_hp_percent",
					["ty"] = "hpp",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "RIGHT",
						["rp"] = "RIGHT",
						["af"] = "hpbar",
					},
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["owner"] = "Base",
					["version"] = 1,
				}, -- [7]
				{
					["rows"] = 1,
					["feature"] = "aura_icons",
					["ephemeral"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "BOTTOMLEFT",
						["af"] = "hpbar",
					},
					["auratimer"] = 1,
					["nIcons"] = 10,
					["auraType"] = "DEBUFFS",
					["owner"] = "Base",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["name"] = "ai1",
					["size"] = 10,
					["orientation"] = "RIGHT",
					["text"] = "STACK",
					["version"] = 2,
					["iconspx"] = 0;
					["iconspy"] = 0;
					["cdoffx"] = 0; 
					["cdoffy"] = 0;
					["timerType"] = "COOLDOWN";
					["externalButtonSkin"] = "Builtin:bs_default";
					["ButtonSkinOffset"] = 0;
				}, -- [8]
			},
	};

	builtin["sort_assist"] = {
			["ty"] = "SecureSort",
			["version"] = 2,
			["data"] = {
				["sort"] = {
					[1] = {
						["op"] = "intrinsic",
					},
				},
				["set"] = {
					["class"] = "file",
					["file"] = "default:assists",
				},
			},
	};

	builtin["win_assist_default"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				[1] = {
					["feature"] = "Frame: Lightweight",
					["title"] = "Assists",
					["bkdColor"] = {
						["a"] = 0.2557997107505798,
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
					["titleColor"] = {
						["a"] = 1,
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
				},
				[2] = {
					["feature"] = "UnitFrame",
					["design"] = "Builtin:uf_assist",
				},
				[3] = {
					["feature"] = "Data Source: Secure",
					["sortPath"] = "Builtin:sort_assist",
				},
				[4] = {
					["feature"] = "Secure Assists",
					["showAssist"] = 1,
					["hlt"] = true,
				},
				[5] = {
					["feature"] = "mousebindings",
					["version"] = 1,
					["hotspot"] = "",
					["mbFriendly"] = "default:bindings",
				},
				[6] = {
					["feature"] = "NominativeSet Editor",
				},
			},
	};

	builtin["clickTarget"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "target",
				},
			},
	};
end);

--------------------------------------
-- Builtin symlinks
--------------------------------------
local function CheckAndCreateIfNot(path, type, linkPath)
	-- Check to see if it's a symlink; if not, overwrite it with one
	local data = RDXDB._AccessPathRaw(RDXDB.ParsePath(path));
	if (not data) or (data.ty ~= "SymLink") then
		RDX.print(i18n("Creating link: ") .. path);
		local mbo = RDXDB.TouchObject(path);
		mbo.ty = "SymLink"; mbo.version = 1; mbo.data = linkPath;
	end
	-- Check to see if it points to an object of the proper type; if not, point it to the default
	if not RDXDB.CheckObject(path, type) then
		RDX.print(i18n("Updating link: ") .. path);
		local mbo = RDXDB.TouchObject(path);
		mbo.ty = "SymLink"; mbo.version = 1; mbo.data = linkPath;
	end
end
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	CheckAndCreateIfNot("Builtin:uf_hp", "UnitFrameType", "Builtin:uf_hp_default");
	CheckAndCreateIfNot("Builtin:uf_mana", "UnitFrameType", "Builtin:uf_mana_default");
	CheckAndCreateIfNot("Builtin:uf_hpmissing", "UnitFrameType", "Builtin:uf_hpmissing_default");
	CheckAndCreateIfNot("Builtin:uf_hpmana", "UnitFrameType", "Builtin:uf_hpmana_default");
	CheckAndCreateIfNot("Builtin:uf_name", "UnitFrameType", "Builtin:uf_name_default");
	CheckAndCreateIfNot("Builtin:uf_assist", "UnitFrameType", "Builtin:uf_assist_default");
	CheckAndCreateIfNot("Builtin:win_assist", "Window", "Builtin:win_assist_default");

	-- MultiTrack used to point at the assist frame, make sure that isn't happening anymore.
	local data = RDXDB._AccessPathRaw("Builtin", "uf_multitrack");
	if data and data.ty == "SymLink" and data.data == "Builtin:uf_assist_default" then
		data.data = "Builtin:uf_multitrack_default";
	else
		CheckAndCreateIfNot("Builtin:uf_multitrack", "UnitFrameType", "Builtin:uf_multitrack_default");
	end
end);

--------------------------------------
-- Builtin default mouse bindings
--------------------------------------
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	-- Create player-specific bindings if they don't exist
	local mbo = RDXDB.TouchObject("default:bindings_" .. RDX.pspace);
	if not mbo.data then
		mbo.data = {}; mbo.ty = "MouseBindings"; mbo.version = 1;
	end
	-- Create symlink if it doesn't exist
	local mbsl = RDXDB.TouchObject("default:bindings");
	if not mbsl.data then
		mbsl.ty = "SymLink"; mbsl.version = 1; mbsl.data = "";
	end
	-- Repoint symlink
	RDXDB.SetSymLinkTarget("default:bindings", "default:bindings_" .. RDX.pspace);
	
	
-- Create player-specific bindings status for windows if they don't exist
mbo = RDXDB.TouchObject("default:bindings_status_" .. RDX.pspace);
if not mbo.data then
     mbo.data = {
                ["1"] = {
                    ["action"] = "target",
                },
                ["2"] = {
                    ["action"] = "menu",
                },
     }; 
     mbo.ty = "MouseBindings"; 
     mbo.version = 1;
end
-- Create symlink if it doesn't exist
mbsl = RDXDB.TouchObject("default:bindings_status");
if not mbsl.data then
      mbsl.ty = "SymLink"; mbsl.version = 1; mbsl.data = "";
end
-- Repoint symlink
RDXDB.SetSymLinkTarget("default:bindings_status", "default:bindings_status_" .. RDX.pspace);


-- Create player-specific bindings decurse for windows if they don't exist
local mbo = RDXDB.TouchObject("default:bindings_decurse_" .. RDX.pspace);
if not mbo.data then
local _,class = UnitClass("player");
if class == "PRIEST" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Dispel Magic") .. i18n("(Rank 2)"),
    },
    ["2"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Abolish Disease") .. "()",
    },
};
elseif class == "DRUID" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Abolish Poison") .. "()",
    },
    ["2"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Remove Curse") .. "()",
    },
};
elseif class == "PALADIN" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Cleanse") .. "()",
    },
};
elseif class == "SHAMAN" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Cure Disease") .. "()",
    },
    ["2"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Cure Poison") .. "()",
    },
};
elseif class == "MAGE" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Remove Lesser Curse") .. "()",
    },
};
else
mbo.data = {};
end

     mbo.ty = "MouseBindings"; 
     mbo.version = 1;
end
-- Create symlink if it doesn't exist
local mbsl = RDXDB.TouchObject("default:bindings_decurse");
if not mbsl.data then
      mbsl.ty = "SymLink"; mbsl.version = 1; mbsl.data = "";
end
-- Repoint symlink
RDXDB.SetSymLinkTarget("default:bindings_decurse", "default:bindings_decurse_" .. RDX.pspace);



-- Create player-specific bindings healings for windows if they don't exist
local mbo = RDXDB.TouchObject("default:bindings_healing_" .. RDX.pspace);
if not mbo.data then
local _,class = UnitClass("player");
if class == "PRIEST" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Flash Heal"),
    },
};
elseif class == "DRUID" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Healing Touch"),
    },
};
elseif class == "PALADIN" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Flash of Light"),
    },
};
elseif class == "SHAMAN" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Healing Wave"),
    },
};
elseif class == "WARRIOR" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Intervene"),
    },
};
elseif class == "HUNTER" then
mbo.data = {
    ["1"] = {
        ["action"] = "cast",
        ["spell"] = i18n("Misdirection"),
    },
};
else
mbo.data = {};
end

     mbo.ty = "MouseBindings"; 
     mbo.version = 1;
end
-- Create symlink if it doesn't exist
local mbsl = RDXDB.TouchObject("default:bindings_healing");
if not mbsl.data then
      mbsl.ty = "SymLink"; mbsl.version = 1; mbsl.data = "";
end
-- Repoint symlink
RDXDB.SetSymLinkTarget("default:bindings_healing", "default:bindings_healing_" .. RDX.pspace);

end);

--------------------------------------
-- Builtin heal-range and dispel-range detection
--------------------------------------
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	-- Create the Builtin:heal_range set if it doesn't exist
	local rs = RDXDB.TouchObject("Builtin:heal_range");
	if not rs.data then
	rs.data = { "set", { class = "unitinrange" }, }; rs.ty = "FilterSet"; rs.version = 1;
	end
	local rs2 = RDXDB.TouchObject("Builtin:dispel_range");
	if not rs2.data then
		rs2.data = {}; rs2.ty = "IndirectSet"; rs2.version = 1;
	end
	local ds0 = RDXDB.TouchObject("Builtin:curable"); ds0.version = 1;
	local ds1 = RDXDB.TouchObject("Builtin:curable_primary"); ds1.version = 1;
	local ds2 = RDXDB.TouchObject("Builtin:curable_secondary"); ds2.version = 1;

	-- Now update the contents of that set based on what class we are
	local _,class = UnitClass("player");
	if(class == "PRIEST") then
		--rs.data = {class="spellrange", spell=i18n("Lesser Heal") .. i18n("(Rank 1)")};
		rs2.data = {class="spellrange", spell=i18n("Cure Disease") .. i18n("()")};
		ds0.ty = "FilterSet"; ds0.data = {
			"or",
			{ "set", {class = "debuff", buff = "@magic"} },
			{ "set", {class = "debuff", buff = "@disease"} },
		};
		ds1.ty = "IndirectSet"; ds1.data = {class="debuff", buff = "@magic"};
		ds2.ty = "IndirectSet"; ds2.data = {class="debuff", buff = "@disease"};
	elseif(class == "PALADIN") then
		--rs.data = {class="spellrange", spell=i18n("Holy Light") .. i18n("(Rank 1)")};
		rs2.data = {class="spellrange", spell=i18n("Cleanse") .. i18n("()")};
		ds0.ty = "FilterSet"; ds0.data = {
			"or",
			{ "set", {class = "debuff", buff = "@magic"} },
			{ "set", {class = "debuff", buff = "@poison"} },
			{ "set", {class = "debuff", buff = "@disease"} },
		};
		ds1.ty = "FilterSet"; ds1.data = {
			"or",
			{ "set", {class = "debuff", buff = "@magic"} },
			{ "set", {class = "debuff", buff = "@poison"} },
			{ "set", {class = "debuff", buff = "@disease"} },
		};
		ds2.ty = "IndirectSet"; ds2.data = {class = "empty"};
	elseif(class == "DRUID") then
		--rs.data = {class="spellrange", spell=i18n("Healing Touch") .. i18n("(Rank 1)")};
		rs2.data = {class="spellrange", spell=i18n("Cure Poison") .. i18n("()")};
		ds0.ty = "FilterSet"; ds0.data = {
			"or",
			{ "set", {class = "debuff", buff = "@curse"} },
			{ "set", {class = "debuff", buff = "@poison"} },
		};
		ds1.ty = "IndirectSet"; ds1.data = {class="debuff", buff = "@curse"};
		ds2.ty = "IndirectSet"; ds2.data = {class="debuff", buff = "@poison"};
	elseif(class == "SHAMAN") then
		--rs.data = {class="spellrange", spell=i18n("Healing Wave") .. i18n("(Rank 1)")};
		rs2.data = {class="spellrange", spell=i18n("Cure Poison") .. i18n("()")};
		ds0.ty = "FilterSet"; ds0.data = {
			"or",
			{ "set", {class = "debuff", buff = "@poison"} },
			{ "set", {class = "debuff", buff = "@disease"} },
		};
		ds1.ty = "IndirectSet"; ds1.data = {class="debuff", buff = "@disease"};
		ds2.ty = "IndirectSet"; ds2.data = {class="debuff", buff = "@poison"};
	elseif(class == "MAGE") then
		--rs.data = {class="frs", n=4};
		rs2.data = {class="spellrange", spell=i18n("Remove Lesser Curse") .. i18n("()")};
		ds0.ty = "IndirectSet"; ds0.data = {class="debuff", buff = "@curse"};
		ds1.ty = "IndirectSet"; ds1.data = {class="debuff", buff = "@curse"};
		ds2.ty = "IndirectSet"; ds2.data = {class="empty"};
	elseif(class == "WARLOCK") then
		--rs.data = {class="frs", n=4};
		rs2.data = {class="frs", n=3};
		ds0.ty = "IndirectSet"; ds0.data = {class="debuff", buff = "@magic"};
		ds1.ty = "IndirectSet"; ds1.data = {class="debuff", buff = "@magic"};
		ds2.ty = "IndirectSet"; ds2.data = {class="empty"};
	else
		--rs.data = {class="frs", n=4};
		rs2.data = {class="frs", n=3};
		ds0.ty = "IndirectSet"; ds0.data = {class="empty"};
		ds1.ty = "IndirectSet"; ds1.data = {class="empty"};
		ds2.ty = "IndirectSet"; ds2.data = {class="empty"};
	end
end);

--------------------------------------
-- Bossmod builtin
--------------------------------------
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local builtin = RDXDB.GetOrCreatePackage("Builtin");
	builtin["bm_hot_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"hot_target", -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
		};
	builtin["bm_interrupt_uf"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "base_default",
					["h"] = 10,
					["version"] = 1,
					["w"] = 100,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "ColorVariable: Unit Class Color",
				}, -- [2]
				{
					["owner"] = "Base",
					["w"] = 98,
					["classColor"] = 1,
					["h"] = 10,
					["version"] = 1,
					["feature"] = "txt_np",
					["anchor"] = {
						["dx"] = 2,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["trunc"] = 8,
					["name"] = "np",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
				}, -- [3]
			},
		};
	builtin["bm_range_10Yard"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: Black",
					["title"] = "Rng 0-10",
				}, -- [1]
				{
					["feature"] = "UnitFrame",
					["design"] = "Builtin:bm_range_uf",
				}, -- [2]
				{
					["feature"] = "Description",
					["description"] = "Range Window 0-10yd",
				}, -- [3]
				{
					["feature"] = "Data Source: Set",
					["set"] = {
						["file"] = "Builtin:bm_range_10Yard_set",
						["class"] = "file",
					},
				}, -- [4]
				{
					["feature"] = "Grid Layout",
					["limit"] = 5,
					["dxn"] = 1,
					["axis"] = 1,
					["cols"] = 1,
				}, -- [5]
			},
		};
	builtin["bm_range_15Yard"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: Black",
					["title"] = "Rng 10-15",
				}, -- [1]
				{
					["feature"] = "UnitFrame",
					["design"] = "Builtin:bm_range_uf",
				}, -- [2]
				{
					["feature"] = "Description",
					["description"] = "Range Window 10-15yd (Requires Heavy Frostweave Bandage)",
				}, -- [3]
				{
					["feature"] = "Data Source: Set",
					["set"] = {
						["class"] = "file",
						["file"] = "Builtin:bm_range_15Yard_set",
					},
				}, -- [4]
				{
					["feature"] = "Grid Layout",
					["limit"] = 5,
					["dxn"] = 1,
					["cols"] = 1,
					["axis"] = 1,
				}, -- [5]
			},
		};
	builtin["bm_interrupt"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: Lightweight",
					["title"] = "Interrupts",
					["titleColor"] = {
						["a"] = 1,
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
					["bkdColor"] = {
						["a"] = 0.5,
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
				}, -- [1]
				{
					["feature"] = "UnitFrame",
					["design"] = "Builtin:bm_interrupt_uf",
				}, -- [2]
				{
					["feature"] = "Data Source: Sort",
					["sortPath"] = "Builtin:bm_interrupt_sort",
				}, -- [3]
				{
					["feature"] = "Grid Layout",
					["dxn"] = 1,
					["cols"] = 1,
					["axis"] = 1,
				}, -- [4]
				{
					["feature"] = "No Hinting",
				}, -- [5]
				{
					["feature"] = "Description",
					["description"] = "Interrupters Window",
				}, -- [6]
			},
		};
	builtin["bm_range_15Yard_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["item"] = i18n("heavy frostweave bandage"),
						["class"] = "itemrange",
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["n"] = 2,
							["class"] = "frs",
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"nidmask", -- [1]
					true, -- [2]
				}, -- [4]
			},
		};
	builtin["bm_hot"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Description",
					["description"] = "High Order Target Window",
				}, -- [1]
				{
					["bkdColor"] = {
						["a"] = 0,
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
					["titleColor"] = {
						["a"] = 1,
						["r"] = 0,
						["g"] = 0,
						["b"] = 0,
					},
					["title"] = "Multi Targets",
					["feature"] = "Frame: Lightweight",
				}, -- [2]
				{
					["feature"] = "Assist Frames",
					["design"] = "Builtin:bm_hot_uf",
				}, -- [3]
				{
					["feature"] = "Data Source: Set",
					["set"] = {
						["class"] = "file",
						["file"] = "Builtin:bm_hot_set",
					},
				}, -- [4]
				{
					["feature"] = "Grid Layout",
					["dxn"] = 1,
					["cols"] = 1,
					["axis"] = 1,
				}, -- [5]
				{
					["feature"] = "Event: Periodic Repaint",
					["interval"] = 0.1000000014901161,
					["slot"] = "RepaintAll",
				}, -- [6]
			},
		};
	builtin["bm_interrupt_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["cd"] = "cs",
						["class"] = "cd_avail",
					}, -- [2]
				}, -- [2]
				{
					"and", -- [1]
					{
						"set", -- [1]
						{
							["cd"] = "pummel",
							["class"] = "cd_avail",
						}, -- [2]
					}, -- [2]
					{
						"set", -- [1]
						{
							["cd"] = "shbash",
							["class"] = "cd_avail",
						}, -- [2]
					}, -- [3]
				}, -- [3]
				{
					"set", -- [1]
					{
						["cd"] = "eshock",
						["class"] = "cd_avail",
					}, -- [2]
				}, -- [4]
				{
					"set", -- [1]
					{
						["cd"] = "kick",
						["class"] = "cd_avail",
					}, -- [2]
				}, -- [5]
			},
		};
	builtin["bm_hot_uf"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Variables: Status Flags (dead, ld, feigned)",
				}, -- [1]
				{
					["feature"] = "Variable: Fractional health (fh)",
				}, -- [2]
				{
					["feature"] = "var_spellinfo",
				}, -- [3]
				{
					["feature"] = "ColorVariable: Unit Class Color",
				}, -- [4]
				{
					["feature"] = "ColorVariable: Static Color",
					["name"] = "green",
					["color"] = {
						["a"] = 1,
						["b"] = 0,
						["g"] = 0.8156862745098039,
						["r"] = 0.03137254901960784,
					},
				}, -- [5]
				{
					["feature"] = "base_default",
					["h"] = 15,
					["version"] = 1,
					["w"] = 260,
					["alpha"] = 1,
				}, -- [6]
				{
					["feature"] = "Subframe",
					["h"] = 15,
					["name"] = "subframe",
					["flOffset"] = 0,
					["owner"] = "Base",
					["w"] = 120,
					["anchor"] = {
						["dx"] = 140,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [7]
				{
					["feature"] = "Subframe",
					["h"] = 14,
					["name"] = "top",
					["flOffset"] = 2,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [8]
				{
					["feature"] = "backdrop",
					["owner"] = "subframe",
					["version"] = 1,
					["bkd"] = {
						["_border"] = "straight",
						["edgeSize"] = 8,
						["_backdrop"] = "none",
						["edgeFile"] = "Interface\\Addons\\VFL\\Skin\\straight-border",
						["insets"] = {
							["top"] = 1,
							["right"] = 1,
							["left"] = 1,
							["bottom"] = 1,
						},
					},
				}, -- [9]
				{
					["cleanupPolicy"] = 3,
					["owner"] = "Base",
					["w"] = 140,
					["feature"] = "texture",
					["h"] = 14,
					["name"] = "tex1",
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
						["blendMode"] = "BLEND",
						["path"] = "Interface\\TargetingFrame\\UI-StatusBar",
					},
				}, -- [10]
				{
					["w1"] = 0.1000000014901161,
					["t1"] = 1,
					["color"] = "classColor",
					["feature"] = "StatusBar Texture Map",
					["b1"] = 0,
					["b2"] = 0,
					["texture"] = "tex1",
					["frac"] = "fh",
					["h2"] = 14,
					["h1"] = 14,
					["l2"] = 0,
					["flag"] = "true",
					["l1"] = 0,
					["t2"] = 1,
					["r1"] = 0,
					["r2"] = 1,
					["w2"] = 140,
				}, -- [11]
				{
					["owner"] = "Base",
					["w"] = 110,
					["staticColor"] = {
						["a"] = 1,
						["r"] = 1,
						["g"] = 1,
						["b"] = 1,
					},
					["feature"] = "txt_np",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["version"] = 1,
					["anchor"] = {
						["dx"] = 12,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
					["name"] = "np",
					["h"] = 14,
				}, -- [12]
				{
					["feature"] = "Raid Target Icon",
					["h"] = 12,
					["name"] = "rti",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "top",
					},
					["owner"] = "top",
					["w"] = 12,
					["drawLayer"] = "ARTWORK",
				}, -- [13]
				{
					["owner"] = "Base",
					["w"] = 35,
					["feature"] = "txt_status",
					["ty"] = "hpp",
					["name"] = "text_hp_percent",
					["anchor"] = {
						["dx"] = 102,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
					["version"] = 1,
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["h"] = 14,
				}, -- [14]
				{
					["size"] = 14,
					["myaurasfilter"] = 1,
					["rows"] = 1,
					["auraType"] = "DEBUFFS",
					["orientation"] = "LEFT",
					["owner"] = "Base",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
					["version"] = 1,
					["feature"] = "aura_icons",
					["ephemeral"] = 1,
					["iconspx"] = 0,
					["name"] = "debuffs",
					["cooldownGfx"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPRIGHT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
					["text"] = "STACK",
					["iconspy"] = 0,
					["nIcons"] = 10,
					["iconspx"] = 0;
					["iconspy"] = 0;
					["cdoffx"] = 0; 
					["cdoffy"] = 0;
					["timerType"] = "COOLDOWN";
					["externalButtonSkin"] = "Builtin:bs_default";
					["ButtonSkinOffset"] = 0;
				}, -- [15]
				{
					["frac"] = "",
					["owner"] = "subframe",
					["w"] = 108,
					["feature"] = "statusbar_horiz",
					["h"] = 11,
					["version"] = 1,
					["colorVar"] = "green",
					["anchor"] = {
						["dx"] = 12,
						["dy"] = -2,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "subframe",
					},
					["name"] = "statusBar",
					["orientation"] = "HORIZONTAL",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX\\Skin\\bar_halfoutline",
					},
				}, -- [16]
				{
					["script"] = "",
					["owner"] = "subframe",
					["w"] = 40,
					["feature"] = "txt_custom",
					["h"] = 14,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = -1,
						["lp"] = "TOPRIGHT",
						["rp"] = "TOPRIGHT",
						["af"] = "subframe",
					},
					["name"] = "spellText",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "RIGHT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 8,
					},
				}, -- [17]
				{
					["statusBar"] = "statusBar",
					["version"] = 1,
					["text"] = "spellText",
					["textType"] = "Hundredths",
					["countType"] = "CountUP",
					["timerVar"] = "spell",
					["feature"] = "free_timer",
				}, -- [18]
				{
					["txt"] = "spell_name_rank",
					["owner"] = "subframe",
					["w"] = 93,
					["feature"] = "txt_dyn",
					["h"] = 14,
					["name"] = "infoText",
					["anchor"] = {
						["dx"] = 13,
						["dy"] = -1,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "subframe",
					},
					["version"] = 1,
					["font"] = {
						["sr"] = 0,
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["sb"] = 0,
						["sa"] = 1,
						["sg"] = 0,
						["justifyH"] = "LEFT",
						["sx"] = 1,
						["sy"] = -1,
						["title"] = "Default",
						["name"] = "Default",
						["size"] = 8,
					},
				}, -- [19]
				{
					["cleanupPolicy"] = 3,
					["owner"] = "subframe",
					["w"] = 11,
					["feature"] = "texture",
					["h"] = 11,
					["name"] = "icontex",
					["anchor"] = {
						["dx"] = 1,
						["dy"] = -2,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "subframe",
					},
					["version"] = 1,
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["color"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["blendMode"] = "BLEND",
					},
				}, -- [20]
				{
					["feature"] = "shader_applytex",
					["owner"] = "icontex",
					["version"] = 1,
					["var"] = "spell_icon",
				}, -- [21]
			},
		};
	builtin["bm_range_uf"] = {
			["ty"] = "UnitFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "base_default",
					["h"] = 10,
					["version"] = 1,
					["w"] = 75,
					["alpha"] = 1,
				}, -- [1]
				{
					["owner"] = "Base",
					["w"] = 40,
					["feature"] = "txt_status",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 9,
					},
					["name"] = "group",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["ty"] = "gn",
					["h"] = 10,
					["version"] = 1,
				}, -- [2]
				{
					["feature"] = "ColorVariable: Unit Class Color",
				}, -- [3]
				{
					["feature"] = "Variable: Unit In Set",
					["name"] = "nada",
					["set"] = {
						["class"] = "empty",
					},
				}, -- [4]
				{
					["condVar"] = "nada_flag",
					["name"] = "namecolor",
					["colorVar1"] = "classColor",
					["feature"] = "ColorVariable: Conditional Color",
					["colorVar2"] = "classColor",
				}, -- [5]
				{
					["cleanupPolicy"] = 2,
					["owner"] = "Base",
					["w"] = 75,
					["feature"] = "texture",
					["h"] = 10,
					["name"] = "overlay",
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
				}, -- [6]
				{
					["feature"] = "ColorVariable: Static Color",
					["name"] = "red",
					["color"] = {
						["a"] = 0.5051560997962952,
						["r"] = 1,
						["g"] = 0.01568627450980392,
						["b"] = 0,
					},
				}, -- [7]
				{
					["owner"] = "Base",
					["w"] = 50,
					["classColor"] = 1,
					["h"] = 10,
					["version"] = 1,
					["feature"] = "txt_np",
					["anchor"] = {
						["dx"] = 8,
						["dy"] = 0,
						["lp"] = "LEFT",
						["rp"] = "LEFT",
						["af"] = "Base",
					},
					["trunc"] = 8,
					["name"] = "np",
					["font"] = {
						["name"] = "Default",
						["title"] = "Default",
						["justifyH"] = "LEFT",
						["face"] = "Interface\\Addons\\VFL\\Fonts\\framd.ttf",
						["justifyV"] = "CENTER",
						["size"] = 10,
					},
				}, -- [8]
			},
		};
	builtin["bm_interrupt_sort"] = {
			["ty"] = "Sort",
			["version"] = 2,
			["data"] = {
				["sort"] = {
					{
						8, -- [1]
						5, -- [2]
						7, -- [3]
						4, -- [4]
						6, -- [5]
						9, -- [6]
						1, -- [7]
						2, -- [8]
						3, -- [9]
						["vname"] = "cls5554064",
						["op"] = "class2",
					}, -- [1]
					{
						["op"] = "alpha",
					}, -- [2]
				},
				["set"] = {
					["file"] = "Builtin:bm_interrupt_set",
					["class"] = "file",
				},
			},
		};
	builtin["bm_range_10Yard_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["n"] = 2,
						["class"] = "frs",
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"me", -- [1]
					}, -- [2]
				}, -- [3]
				{
					"ol", -- [1]
				}, -- [4]
				{
					"not", -- [1]
					{
						"dead", -- [1]
					}, -- [2]
				}, -- [5]
				{
					"nidmask", -- [1]
					true, -- [2]
				}, -- [6]
			},
		};
end);


----------------------------------------------
-- buff debuff builtin
----------------------------------------------

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local builtin = RDXDB.GetOrCreatePackage("Builtin");
	builtin["buffpal_might_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				19740, -- [1]
				25782, -- [2]
			},
		};
	builtin["buffpal_might_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 19740,
						["class"] = "buff",
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["buff"] = 25782,
						["class"] = "buff",
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffpal_kings_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				20217, -- [1]
				25898, -- [2]
			},
		};
	builtin["buffpal_kings_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 20217,
						["class"] = "buff",
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["buff"] = 25898,
						["class"] = "buff",
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffpal_sanctuary_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Blessing of Sanctuary"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Greater Blessing of Sanctuary"),
				},
			},
		};
	builtin["buffdru_thorns_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Thorns"),
				},
			},
		};
	builtin["buffpal_might_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Blessing of Might"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Greater Blessing of Might"),
				},
			},
		};
	builtin["debuff_magic_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "debuff",
						["buff"] = "@magic",
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "debuff",
							["buff"] = "thunderfury",
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "debuff",
							["buff"] = i18n("unstable affliction"),
						}, -- [2]
					}, -- [2]
				}, -- [4]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "debuff",
							["buff"] = i18n("dreamless sleep"),
						}, -- [2]
					}, -- [2]
				}, -- [5]
			},
		};
	builtin["debuff_poison_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "debuff",
						["buff"] = "@poison",
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "debuff",
							["buff"] = strlower(i18n("Abolish Poison")),
						}, -- [2]
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["debuff_disease_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "debuff",
						["buff"] = "@disease",
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "debuff",
							["buff"] = strlower(i18n("Abolish Disease")),
						}, -- [2]
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["debuff_curse_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "debuff",
						["buff"] = "@curse",
					}, -- [2]
				}, -- [2]
			},
		};
	builtin["buffpri_spirit_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				48073, -- [1]
				48074, -- [2]
			},
		};
	builtin["buffpri_spirit_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 48073,
						["class"] = "buff",
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["buff"] = 48074,
						["class"] = "buff",
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffpri_fortitude_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Power Word: Fortitude"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Prayer of Fortitude"),
				},
			},
		};
	builtin["buffmag_arcane_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				1459, -- [1]
				23028, -- [2]
				61024, -- [3]
				61316, -- [4]
			},
		};
	builtin["buffmag_arcane_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 1459,
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 23028,
					}, -- [2]
				}, -- [3]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 61024,
					}, -- [2]
				}, -- [4]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 61316,
					}, -- [2]
				}, -- [5]
			},
		};
	builtin["buffpri_shadow_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Shadow Protection"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Prayer of Shadow Protection"),
				},
			},
		};
	builtin["buffpal_wisdom_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Blessing of Wisdom"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Greater Blessing of Wisdom"),
				},
			},
		};
	builtin["buffdru_thorns_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				9756, -- [1]
			},
		};
	builtin["buffdru_thorns_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 9756,
						["class"] = "buff",
					}, -- [2]
				}, -- [2]
			},
		};
	builtin["buffpri_spirit_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Divine Spirit"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Prayer of Spirit"),
				},
			},
		};
	builtin["buffpri_fortitude_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				48161, -- [1]
				48162, -- [2]
			},
		};
	builtin["buffpri_fortitude_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 48161,
						["class"] = "buff",
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["buff"] = 48162,
						["class"] = "buff",
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffpri_shadow_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				48169, -- [1]
				48170, -- [2]
			},
		};
	builtin["buffpri_shadow_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 48169,
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 48170,
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffpal_wisdom_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				19742, -- [1]
				25894, -- [2]
			},
		};
	builtin["buffpal_wisdom_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 19742,
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["class"] = "buff",
						["buff"] = 25894,
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffdru_wild_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Mark of the Wild"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Gift of the Wild"),
				},
			},
		};
	builtin["buffpal_sanctuary_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 20911,
						["class"] = "buff",
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["buff"] = 25899,
						["class"] = "buff",
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffpal_sanctuary_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				20911, -- [1]
				25899, -- [2]
			},
		};
	builtin["buffpal_kings_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Blessing of Kings"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Greater Blessing of Kings"),
				},
			},
		};
	builtin["buffdru_wild_afilter"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				1126, -- [1]
				21849, -- [2]
			},
		};
	builtin["buffdru_wild_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"set", -- [1]
					{
						["buff"] = 1126,
						["class"] = "buff",
					}, -- [2]
				}, -- [2]
				{
					"set", -- [1]
					{
						["buff"] = 21849,
						["class"] = "buff",
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["buffmag_arcane_mb"] = {
			["ty"] = "MouseBindings",
			["version"] = 1,
			["data"] = {
				["1"] = {
					["action"] = "cast",
					["spell"] = i18n("Arcane Intellect"),
				},
				["2"] = {
					["action"] = "cast",
					["spell"] = i18n("Arcane Brilliance"),
				},
			},
		};
	builtin["hots_list"] = {
			["ty"] = "AuraFilter",
			["version"] = 1,
			["data"] = {
				strlower(i18n("Renew")), -- [1]
				strlower(i18n("Rejuvenation")), -- [2]
				strlower(i18n("Regrowth")), -- [3]
				strlower(i18n("Lifebloom")), -- [4]
				strlower(i18n("Prayer of Mending")), -- [5]
				strlower(i18n("Innervate")), -- [6]
				strlower(i18n("Fear Ward")), -- [7]
				strlower(i18n("Misdirection")), -- [8]
				strlower(i18n("Power Infusion")), -- [9]
				strlower(i18n("esprit de redemption")), -- [10]
				strlower(i18n("Power Word: Shield")), -- [11]
			},
		};
	builtin["party_set"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"mygroup", -- [1]
				}, -- [2]
				{
					"not", -- [1]
					{
						"me", -- [1]
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["not_flask_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 17626,
						}, -- [2]
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 17627,
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 17628,
						}, -- [2]
					}, -- [2]
				}, -- [4]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 17629,
						}, -- [2]
					}, -- [2]
				}, -- [5]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28518,
						}, -- [2]
					}, -- [2]
				}, -- [6]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28519,
						}, -- [2]
					}, -- [2]
				}, -- [7]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28520,
						}, -- [2]
					}, -- [2]
				}, -- [8]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28521,
						}, -- [2]
					}, -- [2]
				}, -- [9]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28540,
						}, -- [2]
					}, -- [2]
				}, -- [10]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 33053,
						}, -- [2]
					}, -- [2]
				}, -- [11]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 42735,
						}, -- [2]
					}, -- [2]
				}, -- [12]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 40567,
						}, -- [2]
					}, -- [2]
				}, -- [13]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 40568,
						}, -- [2]
					}, -- [2]
				}, -- [14]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 40572,
						}, -- [2]
					}, -- [2]
				}, -- [15]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 40573,
						}, -- [2]
					}, -- [2]
				}, -- [16]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 40575,
						}, -- [2]
					}, -- [2]
				}, -- [17]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 40576,
						}, -- [2]
					}, -- [2]
				}, -- [18]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 41608,
						}, -- [2]
					}, -- [2]
				}, -- [19]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 41609,
						}, -- [2]
					}, -- [2]
				}, -- [20]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 41610,
						}, -- [2]
					}, -- [2]
				}, -- [21]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 41611,
						}, -- [2]
					}, -- [2]
				}, -- [22]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 46837,
						}, -- [2]
					}, -- [2]
				}, -- [23]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 46839,
						}, -- [2]
					}, -- [2]
				}, -- [24]
			},
		};
	builtin["not_elixirs_guardian_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 11348,
						}, -- [2]
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 11396,
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 24363,
						}, -- [2]
					}, -- [2]
				}, -- [4]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28502,
						}, -- [2]
					}, -- [2]
				}, -- [5]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28509,
						}, -- [2]
					}, -- [2]
				}, -- [6]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28514,
						}, -- [2]
					}, -- [2]
				}, -- [7]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 39625,
						}, -- [2]
					}, -- [2]
				}, -- [8]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 39626,
						}, -- [2]
					}, -- [2]
				}, -- [9]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 39627,
						}, -- [2]
					}, -- [2]
				}, -- [10]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 39628,
						}, -- [2]
					}, -- [2]
				}, -- [11]
			},
		};
	builtin["not_elixirs_battle_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 11390,
						}, -- [2]
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 11406,
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 17538,
						}, -- [2]
					}, -- [2]
				}, -- [4]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 17539,
						}, -- [2]
					}, -- [2]
				}, -- [5]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28490,
						}, -- [2]
					}, -- [2]
				}, -- [6]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28491,
						}, -- [2]
					}, -- [2]
				}, -- [7]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28493,
						}, -- [2]
					}, -- [2]
				}, -- [8]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28497,
						}, -- [2]
					}, -- [2]
				}, -- [9]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28501,
						}, -- [2]
					}, -- [2]
				}, -- [10]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 28503,
						}, -- [2]
					}, -- [2]
				}, -- [11]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 33720,
						}, -- [2]
					}, -- [2]
				}, -- [12]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 33721,
						}, -- [2]
					}, -- [2]
				}, -- [13]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 33726,
						}, -- [2]
					}, -- [2]
				}, -- [14]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 38954,
						}, -- [2]
					}, -- [2]
				}, -- [15]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 45373,
						}, -- [2]
					}, -- [2]
				}, -- [16]
			},
		};
	builtin["not_food_fset"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"or", -- [1]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 35272,
						}, -- [2]
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 43722,
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 43730,
						}, -- [2]
					}, -- [2]
				}, -- [4]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 43763,
						}, -- [2]
					}, -- [2]
				}, -- [5]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "buff",
							["buff"] = 44106,
						}, -- [2]
					}, -- [2]
				}, -- [6]
			},
		};
end);

----------------------------------------------
-- buff debuff builtin
----------------------------------------------

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local builtin = RDXDB.GetOrCreatePackage("Builtin");
	builtin["range_0_70"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["n"] = 4,
						["class"] = "frs",
					}, -- [2]
				}, -- [2]
				{
					"ol", -- [1]
				}, -- [3]
			},
		};
	builtin["range_0_15"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["item"] = i18n("heavy frostweave bandage"),
						["class"] = "itemrange",
					}, -- [2]
				}, -- [2]
				{
					"ol", -- [1]
				}, -- [3]
			},
		};
	builtin["range_10_15"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["item"] = i18n("heavy frostweave bandage"),
						["class"] = "itemrange",
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "file",
							["file"] = "Builtin:range_0_10",
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"ol", -- [1]
				}, -- [4]
			},
		};
	builtin["range_0_10"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "frs",
						["n"] = 2,
					}, -- [2]
				}, -- [2]
				{
					"ol", -- [1]
				}, -- [3]
			},
		};
	builtin["range_40plus"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "file",
							["file"] = "Builtin:range_0_15",
						}, -- [2]
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "file",
							["file"] = "Builtin:range_15_30",
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "file",
							["file"] = "Builtin:range_30_40",
						}, -- [2]
					}, -- [2]
				}, -- [4]
				{
					"ol", -- [1]
				}, -- [5]
			},
		};
	builtin["range_0_40"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "unitinrange",
					}, -- [2]
				}, -- [2]
				{
					"ol", -- [1]
				}, -- [3]
			},
		};
	builtin["range_0_30"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["n"] = 3,
						["class"] = "frs",
					}, -- [2]
				}, -- [2]
				{
					"ol", -- [1]
				}, -- [3]
			},
		};
	builtin["range_30_40"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "unitinrange",
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["file"] = "Builtin:range_0_15",
							["class"] = "file",
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["file"] = "Builtin:range_15_30",
							["class"] = "file",
						}, -- [2]
					}, -- [2]
				}, -- [4]
				{
					"ol", -- [1]
				}, -- [5]
			},
		};
	builtin["range_15_30"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "frs",
						["n"] = 3,
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "file",
							["file"] = "Builtin:range_0_15",
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"ol", -- [1]
				}, -- [4]
			},
		};
	builtin["range_70plus"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["n"] = 4,
							["class"] = "frs",
						}, -- [2]
					}, -- [2]
				}, -- [2]
				{
					"ol", -- [1]
				}, -- [3]
			},
		};
	builtin["range_30plus"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"ol", -- [1]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["n"] = 3,
							["class"] = "frs",
						}, -- [2]
					}, -- [2]
				}, -- [3]
			},
		};
	builtin["range_40_70"] = {
			["ty"] = "FilterSet",
			["version"] = 1,
			["data"] = {
				"and", -- [1]
				{
					"set", -- [1]
					{
						["class"] = "frs",
						["n"] = 4,
					}, -- [2]
				}, -- [2]
				{
					"not", -- [1]
					{
						"set", -- [1]
						{
							["class"] = "file",
							["file"] = "Builtin:range_0_40",
						}, -- [2]
					}, -- [2]
				}, -- [3]
				{
					"ol", -- [1]
				}, -- [4]
			},
		};
end);

----------------------------------------------
-- Button skin builtin
----------------------------------------------

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	local builtin = RDXDB.GetOrCreatePackage("Builtin");
	builtin["bs_default"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["dd_gloss"] = "OVERLAY",
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["dd_checked"] = "ARTWORK",
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["dd_flash"] = "OVERLAY",
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["circle"] = 1,
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["dd_backdrop"] = "BACKGROUND",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
			},
		};
end);

