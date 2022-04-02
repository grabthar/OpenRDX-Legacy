-- Builtin.lua
-- OpenRDX
--

local strlower = string.lower;

local addonversion = RDXMP.version[1] .. "." .. RDXMP.version[2] .. "." .. RDXMP.version[3];

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	-- Make some stuff that should exist.
	local mediapack = RDXDB.GetOrCreatePackage("mediapack", "1.0.0", "OpenRDX", "", "openrdx@wowinterface.com", "http://www.openrdx.com", "OpenRDX package");
	local version = RDXDB.GetPackageMetadata("mediapack", "infoVersion");
	
	-- Check mediapack version; update if needed.
	if (version ~= addonversion) then
		RDX.print(i18n("Mediapack out of date, updating."));
		RDXDB.SetPackageMetadata("mediapack", "infoVersion", addonversion);
	else
		return;
	end

	mediapack["bs_litestep"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Border",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Normal",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Gloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
			},
		};
	mediapack["bs_gears_spark"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Border",
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
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Spark",
				},
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\overlayred",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Overlay",
				},
			},
		};
	mediapack["bs_gears"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Normal",
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
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Normal",
				},
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\overlayred",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Overlay",
				},
			},
		};
	mediapack["bs_simplesquare"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareHighlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareBase",
				},
				["dd_gloss"] = "OVERLAY",
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["dd_checked"] = "ARTWORK",
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquarePushed",
				},
				["dd_flash"] = "OVERLAY",
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareGloss",
				},
				["circle"] = 1,
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareBackdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareActive",
				},
				["dd_backdrop"] = "BACKGROUND",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareBase",
				},
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareFlash",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\simpleSquare\\simpleSquareActive",
				},
			},
		};
	mediapack["bs_serenity"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\SerenityActive",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\overlayred",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["circle"] = 1,
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\SerenityActive",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\SerenityGloss",
				},
				["dd_gloss"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\SerenityHighlight",
				},
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\SerenityBase",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["color"] = {
						["a"] = 1,
						["r"] = 1,
						["g"] = 1,
						["b"] = 1,
					},
					["blendMode"] = "BLEND",
				},
				["dd_flash"] = "OVERLAY",
			},
		};
	mediapack["bs_gears_black"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Border",
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
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Black",
				},
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\overlayred",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Gears\\Overlay",
				},
			},
		};
	mediapack["bs_onix"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Border",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Classic",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Gloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Arrow",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
			},
		};
	mediapack["bs_litestep_lite"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Border",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Lite",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Gloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
			},
		};
	mediapack["bs_serenity_square"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\SquareHighlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["dd_gloss"] = "OVERLAY",
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\Square",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Serenity\\SquareGloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\LiteStep\\Overlay",
				},
			},
		};
	mediapack["bs_kitty"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\HKittyHighlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\HKittyBase",
				},
				["dd_gloss"] = "OVERLAY",
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["dd_checked"] = "ARTWORK",
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\HKittyActive",
				},
				["dd_flash"] = "OVERLAY",
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["circle"] = 1,
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\HKittyActive",
				},
				["dd_backdrop"] = "BACKGROUND",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\HKittyBase",
				},
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\overlayred",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\HKitty\\overlayred",
				},
			},
		};
	mediapack["bs_blizzard"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\Buttons\\ButtonHilight-Square",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\Buttons\\UI-QuickslotRed",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\Buttons\\UI-Quickslot-Depress",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\Tooltips\\UI-Tooltip-Background",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\Buttons\\CheckButtonHilight",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
			},
		};
	mediapack["bs_apathy"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Border",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Overlay",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Normal",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Gloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Apathy\\Overlay",
				},
			},
		};
	mediapack["bs_caith"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Border",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Overlay",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Normal",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Gloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Caith\\Overlay",
				},
			},
		};
	mediapack["bs_entropy"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Border",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Overlay",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Normal",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Gloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Entropy\\Overlay",
				},
			},
		};
	mediapack["bs_onix_redux"] = {
			["ty"] = "ButtonSkin",
			["version"] = 1,
			["data"] = {
				["dd_disabled"] = "OVERLAY",
				["highlight"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Highlight",
				},
				["border"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Border",
				},
				["flash"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
				["dd_border"] = "OVERLAY",
				["dd_autocastable"] = "OVERLAY",
				["normal"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Redux",
				},
				["pushed"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
				["gloss"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Gloss",
				},
				["dd_flash"] = "OVERLAY",
				["backdrop"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Backdrop",
				},
				["dd_normal"] = "BORDER",
				["dd_highlight"] = "HIGHLIGHT",
				["dd_pushed"] = "ARTWORK",
				["dd_gloss"] = "OVERLAY",
				["checked"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
				["dd_backdrop"] = "BACKGROUND",
				["dd_checked"] = "ARTWORK",
				["disabled"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Arrow",
				},
				["autocastable"] = {
					["blendMode"] = "BLEND",
					["path"] = "Interface\\AddOns\\RDX_mediapack\\buttons\\Onyx\\Overlay",
				},
			},
		};
		
	-- artframe
		
	mediapack["StormUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 342,
					["feature"] = "arttexture",
					["h"] = 170,
					["version"] = 1,
					["anchor"] = {
						["dx"] = -342,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex1",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\26-stormfrontleft.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 341,
					["feature"] = "arttexture",
					["h"] = 170,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex2",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\26-stormfrontmid.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 342,
					["drawLayer"] = "ARTWORK",
					["h"] = 170,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 341,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\26-stormfrontright.tga",
					},
				}, -- [5]
			},
		};
	mediapack["BG2UI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:BG2UI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["DarkUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\07-DarkUI-1.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\07-DarkUI-2.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\07-DarkUI-3.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\07-DarkUI-4.tga",
					},
				}, -- [6]
			},
		};
	mediapack["HolyUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:HolyUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["HolyUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["feature"] = "arttexture",
					["h"] = 512,
					["version"] = 1,
					["anchor"] = {
						["dx"] = -469,
						["dy"] = 256,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex1",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\11-holy_left.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["feature"] = "arttexture",
					["h"] = 512,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 256,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex2",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\11-holy_mid.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["feature"] = "arttexture",
					["h"] = 512,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 469,
						["dy"] = 256,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex3",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\11-holy_right.tga",
					},
				}, -- [5]
			},
		};
	mediapack["ZulDrakUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\28-ZulDrakUI-1.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\28-ZulDrakUI-2.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\28-ZulDrakUI-3.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\28-ZulDrakUI-4.tga",
					},
				}, -- [6]
			},
		};
	mediapack["JuggerUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 171,
					["drawLayer"] = "ARTWORK",
					["h"] = 171,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -513,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\30-jug301.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 171,
					["drawLayer"] = "ARTWORK",
					["h"] = 171,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -342,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\30-jug302.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 171,
					["drawLayer"] = "ARTWORK",
					["h"] = 171,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = -171,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\30-jug303.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 171,
					["drawLayer"] = "ARTWORK",
					["h"] = 171,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\30-jug304.tga",
					},
				}, -- [6]
				{
					["owner"] = "pdt",
					["w"] = 171,
					["drawLayer"] = "ARTWORK",
					["h"] = 171,
					["name"] = "tex5",
					["anchor"] = {
						["dx"] = 171,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\30-jug305.tga",
					},
				}, -- [7]
				{
					["owner"] = "pdt",
					["w"] = 171,
					["drawLayer"] = "ARTWORK",
					["h"] = 171,
					["name"] = "tex6",
					["anchor"] = {
						["dx"] = 342,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\30-jug306.tga",
					},
				}, -- [8]
			},
		};
	mediapack["AngelUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 342,
					["feature"] = "arttexture",
					["h"] = 170,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex1",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\02-Angel-left.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 341,
					["feature"] = "arttexture",
					["h"] = 170,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 342,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex2",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\02_Tribal-middle.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 342,
					["feature"] = "arttexture",
					["h"] = 170,
					["version"] = 1,
					["anchor"] = {
						["dx"] = 683,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex3",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\02-Angel-right.tga",
					},
				}, -- [5]
			},
		};
	mediapack["BG1UI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:BG1UI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["BG1UI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 128,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -640,
						["dy"] = -128,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-bg2left.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-bgleft.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-bgright.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 128,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 512,
						["dy"] = -128,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-bg2right.tga",
					},
				}, -- [6]
			},
		};
	mediapack["GearUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\08-gearbar1.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\08-gearbar2.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\08-gearbar3.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\08-gearbar4.tga",
					},
				}, -- [6]
			},
		};
	mediapack["StormUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:StormUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["ZulDrakUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:ZulDrakUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["NexusUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\14-NexusUI-1.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\14-NexusUI-2.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\14-NexusUI-3.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\14-NexusUI-4.tga",
					},
				}, -- [6]
			},
		};
	mediapack["NexusUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:NexusUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["BG2UI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 64,
					["drawLayer"] = "ARTWORK",
					["h"] = 64,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -576,
						["dy"] = -192,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-controleexgauche.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-controlebggauche.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-controlebgdroite.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 64,
					["drawLayer"] = "ARTWORK",
					["h"] = 64,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 512,
						["dy"] = -192,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\03-controleexdroite.tga",
					},
				}, -- [6]
			},
		};
	mediapack["SF_IceUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:SF_IceUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["GearUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:GearUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["SFKeepUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:SFKeepUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["SFKeepUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex1",
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\15-SFKeepUI-1.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex2",
					["anchor"] = {
						["dx"] = -256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\15-SFKeepUI-2.tga",
					},
				}, -- [4]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\15-SFKeepUI-3.tga",
					},
				}, -- [5]
				{
					["owner"] = "pdt",
					["w"] = 256,
					["drawLayer"] = "ARTWORK",
					["h"] = 128,
					["name"] = "tex4",
					["anchor"] = {
						["dx"] = 256,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\15-SFKeepUI-4.tga",
					},
				}, -- [6]
			},
		};
	mediapack["SF_IceUI_art"] = {
			["ty"] = "ArtFrameType",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "artbase_default",
					["h"] = 14,
					["version"] = 1,
					["w"] = 90,
					["alpha"] = 1,
				}, -- [1]
				{
					["feature"] = "artSubframe",
					["h"] = 14,
					["name"] = "pdt",
					["flOffset"] = 1,
					["owner"] = "Base",
					["w"] = 90,
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "Base",
					},
				}, -- [2]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["feature"] = "arttexture",
					["h"] = 256,
					["version"] = 1,
					["anchor"] = {
						["dx"] = -512,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["name"] = "tex2",
					["drawLayer"] = "ARTWORK",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\22-spleft_ice.tga",
					},
				}, -- [3]
				{
					["owner"] = "pdt",
					["w"] = 512,
					["drawLayer"] = "ARTWORK",
					["h"] = 256,
					["name"] = "tex3",
					["anchor"] = {
						["dx"] = 0,
						["dy"] = 0,
						["lp"] = "TOPLEFT",
						["rp"] = "TOPLEFT",
						["af"] = "pdt",
					},
					["version"] = 1,
					["feature"] = "arttexture",
					["texture"] = {
						["blendMode"] = "BLEND",
						["path"] = "Interface\\Addons\\RDX_mediapack\\Sets\\22-spright_ice.tga",
					},
				}, -- [4]
			},
		};
	mediapack["JuggerUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:JuggerUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["DarkUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:DarkUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	mediapack["AngelUI_win"] = {
			["ty"] = "Window",
			["version"] = 1,
			["data"] = {
				{
					["feature"] = "Frame: None",
				}, -- [1]
				{
					["feature"] = "ArtFrame",
					["design"] = "mediapack:AngelUI_art",
				}, -- [2]
				{
					["feature"] = "layout_single_artframe",
					["version"] = 1,
				}, -- [3]
			},
		};
	
end);
