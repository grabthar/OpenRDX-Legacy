-- SharedMedia_Integration.lua
-- VFL
-- (C)2007 Bill Johnson and the VFL Project.
--
-- Share information between the Ace SharedMediaLib and the VFL asset
-- management system.

-- Wait until variables are loaded, then download all media from the media lib.
-- XXX: This is not optimal; really we should bind to the media registration event
-- and continue watching that, but in almost all cases this will work fine.
-- TODO: Write reciprocating texture functions.
--[[
WoWEvents:Bind("VARIABLES_LOADED", nil, function()
	---------------------
	-- SharedMedia 1.0 --
	---------------------
	-- prevents SharedMedia-1.0 integration from loading if 2.0 is present (as it loads 1.0 into 2.0 if present)
	if LibStub then
		local sml = LibStub:GetLibrary("LibSharedMedia-2.0", 1);
		if sml then return; end
	end

	if not AceLibrary then return; end
	local flag, sml = pcall(AceLibrary, "SharedMedia-1.0"); 
	if (not flag) or (not sml) then return; end

	RDX.print("SharedMedia-1.0 integration enabled.")

	-- Fonts
	local fonts = sml:HashTable(sml.MediaType.FONT);
	for name,ttf in pairs(fonts) do
		VFLUI.RegisterFontFace(ttf, name .. " [SML]");
	end
	-- Reciprocate and register our fonts back with shared media lib.
	for _,face in pairs(VFLUI._GetFontFaces()) do
		sml:Register(sml.MediaType.FONT, face.name, face.path);
	end

	-- Status Bars
	local sbars = sml:HashTable(sml.MediaType.STATUSBAR);
	for name,tex in pairs(sbars) do
		VFLUI.RegisterTexture({
			name="sml_sbar_" .. name;
			category = i18n("Status Bars [SML]");
			title = name;
			path = tex;
			dx = 256; dy = 32;
		});
	end

	-- Sounds
	local sounds = sml:HashTable(sml.MediaType.SOUND);
	for name,soundFile in pairs(sounds) do
		VFLUI.RegisterSound(soundFile, name .. " [SML]");
	end
	-- Reciprocate our sounds back to SML
	for _,sound in pairs(VFLUI.GetSoundList()) do
		sml:Register(sml.MediaType.SOUND, sound.title, sound.name);
	end
end);

WoWEvents:Bind("VARIABLES_LOADED", nil, function()
	---------------------
	-- SharedMedia 2.0 --
	---------------------
	if not LibStub then return; end

	local sml = LibStub:GetLibrary("LibSharedMedia-2.0", 1);
	if (not sml) then return; end
	
	RDX.print("SharedMedia-2.0 integration enabled.")

	-- Fonts
	local fonts = sml:HashTable(sml.MediaType.FONT);
	for name,_ in pairs(fonts) do
		VFLUI.RegisterFontFace(sml:Fetch(sml.MediaType.FONT, name), name .. " [SML]");
	end
	-- Reciprocate and register our fonts back with shared media lib.
	for _,face in pairs(VFLUI._GetFontFaces()) do
		sml:Register(sml.MediaType.FONT, face.name, face.path);
	end

	-- Status Bars
	local sbars = sml:HashTable(sml.MediaType.STATUSBAR);
	for name,_ in pairs(sbars) do
		VFLUI.RegisterTexture({
			name="sml_sbar_" .. name;
			category = i18n("Status Bars [SML]");
			title = name;
			path = sml:Fetch(sml.MediaType.STATUSBAR, name);
			dx = 256; dy = 32;
		});
	end

	-- Sounds
	local sounds = sml:HashTable(sml.MediaType.SOUND);
	for name,_ in pairs(sounds) do
		VFLUI.RegisterSound(sml:Fetch(sml.MediaType.SOUND, name), name .. " [SML]");
	end
	-- Reciprocate our sounds back to SML
	for _,sound in pairs(VFLUI.GetSoundList()) do
		sml:Register(sml.MediaType.SOUND, sound.title, sound.name);
	end
end);]]

--[[

WoWEvents:Bind("VARIABLES_LOADED", nil, function()
	---------------------
	-- SharedMedia 3.0 --
	---------------------
	if not LibStub then return; end

	local sml = LibStub:GetLibrary("LibSharedMedia-3.0", 1);
	if (not sml) then return; end
	
	RDX.print("SharedMedia-3.0 integration enabled.")

	-- Fonts
	local fonts = sml:HashTable(sml.MediaType.FONT);
	for name,_ in pairs(fonts) do
		VFLUI.RegisterFontFace(sml:Fetch(sml.MediaType.FONT, name), name .. " [SML]");
	end
	-- Reciprocate and register our fonts back with shared media lib.
	for _,face in pairs(VFLUI._GetFontFaces()) do
		sml:Register(sml.MediaType.FONT, face.name, face.path);
	end

	-- Status Bars
	local sbars = sml:HashTable(sml.MediaType.STATUSBAR);
	for name,_ in pairs(sbars) do
		VFLUI.RegisterTexture({
			name = "sml_sbar_" .. name;
			category = i18n("Status Bars [SML]");
			title = name;
			path = sml:Fetch(sml.MediaType.STATUSBAR, name);
			dx = 256; dy = 32;
		});
	end

	-- Sounds
	local sounds = sml:HashTable(sml.MediaType.SOUND);
	for name,_ in pairs(sounds) do
		VFLUI.RegisterSound(sml:Fetch(sml.MediaType.SOUND, name), name .. " [SML]");
	end
	-- Reciprocate our sounds back to SML
	for _,sound in pairs(VFLUI.GetSoundList()) do
		sml:Register(sml.MediaType.SOUND, sound.title, sound.name);
	end
	
	-- Backgrounds
	local backgrounds = sml:HashTable(sml.MediaType.BACKGROUND);
	for name,_ in pairs(backgrounds) do
		VFLUI.RegisterBackdrop({
			name = "sml_bd_" .. name;
			title = "[SML] " .. name;
			bgFile = sml:Fetch(sml.MediaType.BACKGROUND, name);
			tile = true; tileSize = 10;
		});
	end
	
	-- Border
	local borders = sml:HashTable(sml.MediaType.BORDER);
	for name,_ in pairs(borders) do
		VFLUI.RegisterBackdropBorder({
			name = "sml_bdb_" .. name;
			title = "[SML] " .. name;
			edgeFile = sml:Fetch(sml.MediaType.BORDER, name);
			edgeSize = 8;
			insets = { left = 2, right = 2, top = 2, bottom = 2};
		});
	end
end);

]]
