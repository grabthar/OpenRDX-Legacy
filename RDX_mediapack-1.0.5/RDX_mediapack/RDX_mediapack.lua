-- RDX_mediapack
-- OpenRDX

RDXMP = RegisterVFLModule({
	name = "RDXMP";
	title = "RDX Media Pack";
	description = "Media pack";
	parent = RDX;
});

RDXMP:LoadVersionFromTOC("RDX_mediapack");

-- updater code
local function CheckTexture(feat)
	if not feat.texture.path then return nil; end
	local find = 0;
	feat.texture.path, find = feat.texture.path:gsub("\\RDX\\Skin\\Halcyon\\", "\\RDX_mediapack\\Halcyon\\");
	if find > 0 then return true; end
	feat.texture.path, find = feat.texture.path:gsub("\\RDX\\Skin\\blizzard\\", "\\RDX_mediapack\\blizzard\\");
	if find > 0 then return true; end
	feat.texture.path, find = feat.texture.path:gsub("\\RDX\\Skin\\buttons\\", "\\RDX_mediapack\\buttons\\");
	if find > 0 then return true; end
	feat.texture.path, find = feat.texture.path:gsub("\\RDX\\Skin\\minimap\\", "\\RDX_mediapack\\minimap\\");
	if find > 0 then return true; end
	feat.texture.path, find = feat.texture.path:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.texture.path, find = feat.texture.path:gsub("\\SharedMedia-2.0\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.texture.path, find = feat.texture.path:gsub("\\RDX\\Skin\\Turbo\\", "\\RDX_mediapack\\Turbo\\");
	if find > 0 then return true; end
	return nil;
end

local function CheckTexture2(feat)
	if not feat.sbtexture.path then return nil; end
	local find = 0;
	feat.sbtexture.path, find = feat.sbtexture.path:gsub("\\RDX\\Skin\\Halcyon\\", "\\RDX_mediapack\\Halcyon\\");
	if find > 0 then return true; end
	feat.sbtexture.path, find = feat.sbtexture.path:gsub("\\RDX\\Skin\\blizzard\\", "\\RDX_mediapack\\blizzard\\");
	if find > 0 then return true; end
	feat.sbtexture.path, find = feat.sbtexture.path:gsub("\\RDX\\Skin\\buttons\\", "\\RDX_mediapack\\buttons\\");
	if find > 0 then return true; end
	feat.sbtexture.path, find = feat.sbtexture.path:gsub("\\RDX\\Skin\\minimap\\", "\\RDX_mediapack\\minimap\\");
	if find > 0 then return true; end
	feat.sbtexture.path, find = feat.sbtexture.path:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.sbtexture.path, find = feat.sbtexture.path:gsub("\\SharedMedia-2.0\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.sbtexture.path, find = feat.sbtexture.path:gsub("\\RDX\\Skin\\Turbo\\", "\\RDX_mediapack\\Turbo\\");
	if find > 0 then return true; end
	return nil;
end

local ignorepath = {
	["Interface\\Addons\\VFL\\Fonts\\framd.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\framdit.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\bs.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\lucon.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\myriad.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\LiberationSans-Regular.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\LiberationSans-Bold.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\LiberationSans-Italic.ttf"] = true;
	["Interface\\Addons\\VFL\\Fonts\\LiberationSans-BoldItalic.ttf"] = true;
};

local function CheckFont(feat)
	if not feat.font.face or ignorepath[feat.font.face] then return nil; end
	local find = 0;
	feat.font.face, find = feat.font.face:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.font.face, find = feat.font.face:gsub("\\VFL\\Fonts\\", "\\RDX_mediapack\\Fonts\\");
	if find > 0 then return true; end
	return nil;
end

local function CheckFontST(feat)
	if not feat.fontst.face or ignorepath[feat.fontst.face] then return nil; end
	local find = 0;
	feat.fontst.face, find = feat.fontst.face:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.fontst.face, find = feat.fontst.face:gsub("\\VFL\\Fonts\\", "\\RDX_mediapack\\Fonts\\");
	if find > 0 then return true; end
	return nil;
end

local function CheckiconFont(feat)
	if not feat.iconfont.face or ignorepath[feat.iconfont.face] then return nil; end
	local find = 0;
	feat.iconfont.face, find = feat.iconfont.face:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.iconfont.face, find = feat.iconfont.face:gsub("\\VFL\\Fonts\\", "\\RDX_mediapack\\Fonts\\");
	if find > 0 then return true; end
	return nil;
end

local function ChecksbFont(feat)
	if not feat.sbfont.face or ignorepath[feat.sbfont.face] then return nil; end
	local find = 0;
	feat.sbfont.face, find = feat.sbfont.face:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.sbfont.face, find = feat.sbfont.face:gsub("\\VFL\\Fonts\\", "\\RDX_mediapack\\Fonts\\");
	if find > 0 then return true; end
	return nil;
end

local function ChecksbTimerFont(feat)
	if not feat.sbtimerfont.face or ignorepath[feat.sbtimerfont.face] then return nil; end
	local find = 0;
	feat.sbtimerfont.face, find = feat.sbtimerfont.face:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
	if find > 0 then return true; end
	feat.sbtimerfont.face, find = feat.sbtimerfont.face:gsub("\\VFL\\Fonts\\", "\\RDX_mediapack\\Fonts\\");
	if find > 0 then return true; end
	return nil;
end

local function CheckBkd(feat)
	local find, flag = 0, nil;
	if feat.bkd.edgeFile then
		feat.bkd.edgeFile, find = feat.bkd.edgeFile:gsub("\\RDX\\Skin\\Halcyon\\", "\\RDX_mediapack\\Halcyon\\");
		if find > 0 then flag = true; end
		feat.bkd.edgeFile = feat.bkd.edgeFile:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
		if find > 0 then flag = true; end
	end
	if feat.bkd.bgFile then
		feat.bkd.bgFile, find = feat.bkd.bgFile:gsub("\\RDX\\Skin\\Halcyon\\", "\\RDX_mediapack\\Halcyon\\");
		if find > 0 then flag = true; end
		feat.bkd.bgFile = feat.bkd.bgFile:gsub("\\RDX\\Skin\\sharedmedia\\", "\\RDX_mediapack\\sharedmedia\\");
		if find > 0 then flag = true; end
	end
	return flag;
end

local function CheckButtonSkin(feat)
	local find = 0;
	if feat.externalButtonSkin ~= "Builtin:bs_default" then
		feat.externalButtonSkin, find = feat.externalButtonSkin:gsub("Builtin", "mediapack");
	end
	if find > 0 then return true; end
	return nil;
end

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()

	-- Iterate over the entire FS...
	RDXDB.Foreach(function(pkg, file, md)
		local ty = RDXDB.GetObjectType(md.ty);
		if not ty then return; end
		-- Iterate over features on feature driven objects
		if (type(md.data) == "table") then
			for _,featDesc in ipairs(md.data) do
				if (type(featDesc) == "table") then
					if featDesc.texture then
						if CheckTexture(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating texture on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.sbtexture then
						if CheckTexture2(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating texture on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.font then
						if CheckFont(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating font on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.fontst then
						if CheckFontST(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating font on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.iconfont then
						if CheckiconFont(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating font on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.sbfont then
						if ChecksbFont(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating font on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.sbtimerfont then
						if ChecksbTimerFont(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating font on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.bkd then
						if CheckBkd(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating Backdrop on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
					if featDesc.externalButtonSkin then
						if CheckButtonSkin(featDesc) then 
							RDXDB.objupdate = true;
							RDX.print(i18n("|cFF00FFFFMedia Updater|r: Updating Button skin on object ") .. RDXDB.MakePath(pkg,file));
						end
					end
				end
			end
		end
	end);
end);
