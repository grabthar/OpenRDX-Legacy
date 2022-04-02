-- AuraBars.lua
-- OpenRDX
-- Code for aura bars attached to unitframes.
-- Sigg Rashgarroth EU
--

function __SetAuraBar(btn, meta, tex, apps, dur, tl, dispelType, i, showBorder, auratype, usedebuffcolor, auranametrunc, auranameab, auratex)
	btn:Show(); btn.meta = meta;
	btn:SetID(i);
	if auratex then 
		btn.icontex:SetTexture();
	else
		btn.icontex:SetTexture(tex)
	end
	
	if auranameab then
		local word, anstr = nil, "";
		for word in string.gmatch(meta.properName, "%a+")
			do anstr = anstr .. word:sub(1, 1);
		end
		btn.sbtxt:SetText(anstr);
	elseif auranametrunc then
		btn.sbtxt:SetText(string.sub(meta.properName, 1, auranametrunc));
	else
		btn.sbtxt:SetText(meta.properName);
	end
	if auratype == "DEBUFFS" and usedebuffcolor then
		--if showBorder then
		--	if dispelType then
				--btn:SetBackdropBorderColor(explodeColor(DebuffTypeColor[dispelType]));
		--	end
		--else
			if dispelType then
				btn.sb:SetColorTable(DebuffTypeColor[dispelType]);
			else
				btn.sb:SetColorTable(_grey);
			end
		--end
	end
	btn.ftc:SetFormula(false);
	if dur and dur > 0 then
		btn.ftc:SetTimer(GetTime() + tl - dur , dur);
	else
		btn.ftc:SetTimer(0, 0);
	end
	if apps and (apps > 1) then btn.icontxt:SetText(apps); else btn.icontxt:SetText(""); end
	return true;
end

--------------- Code emitter helpers
local function _EmitCreateCode(objname, desc)
	local ty, bs = '"Frame"', 1;
	if (not desc.ephemeral) then 
		ty = '"Button"';
	else
		if not desc.bkd then desc.bkd = {} end
		if desc.bkd.edgeSize then bs = desc.bkd.edgeSize/3; end
	end
	if not desc.w then desc.w = 90; end
	if not desc.h then desc.h = 14; end
	local createCode = [[
frame.]] .. objname .. [[ = {};
local btn, btnOwner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
for i=1,]] .. desc.nIcons .. [[ do
	btn = VFLUI.AcquireFrame(]] .. ty .. [[);
	btn:SetParent(btnOwner);
	btn:SetFrameLevel(btnOwner:GetFrameLevel());
	btn:SetWidth(]] .. desc.w .. [[); btn:SetHeight(]] .. desc.h .. [[);
]];
	if (not desc.ephemeral) then
		createCode = createCode .. [[
	btn:SetScript("OnEnter", __AuraIconOnEnter);
	btn:SetScript("OnLeave", __AuraIconOnLeave);
	btn:RegisterForClicks("RightButtonUp");
	btn:SetScript("OnClick", __AuraIconOnClick);]];
	else
		createCode = createCode .. [[
	VFLUI.SetBackdrop(btn, ]] .. Serialize(desc.bkd) .. [[);]];
	end
	
	createCode = createCode .. [[
	btn.icontex = VFLUI.CreateTexture(btn);
]];	
	if desc.iconposition and desc.iconposition == "RIGHT" then
		createCode = createCode .. [[
		btn.icontex:SetPoint("TOPLEFT", btn, "TOPRIGHT",0,0);]];
	else
		createCode = createCode .. [[
		btn.icontex:SetPoint("TOPRIGHT", btn, "TOPLEFT",0,0);]];
	end
	
	createCode = createCode .. [[
	btn.icontex:SetWidth(]] .. desc.h .. [[); btn.icontex:SetHeight(]] .. desc.h .. [[);
	btn.icontex:SetTexCoord(0.08, 1-0.08, 0.08, 1-0.08);
	btn.icontex:Show();
	btn.icontxt = VFLUI.CreateFontString(btn);
	btn.icontxt:SetAllPoints(btn.icontex); 
	btn.icontxt:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetFontCode("btn.icontxt", desc.iconfont, nil, true);
	createCode = createCode .. [[
	btn.sb = VFLUI.StatusBarTexture:new(btn);
	btn.sb:SetOrientation("]] .. desc.borientation .. [[");
	btn.sb:SetPoint("TOPLEFT", btn, "TOPLEFT");
	btn.sb:SetWidth(]] .. desc.w .. [[); btn.sb:SetHeight(]] .. desc.h .. [[);
	btn.sb:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetTextureCode("btn.sb", desc.sbtexture);
	createCode = createCode .. [[
	btn.sbtxt = VFLUI.CreateFontString(btn);
	btn.sbtxt:SetPoint("TOPLEFT", btn, "TOPLEFT");
	btn.sbtxt:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT");
	btn.sbtxt:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetFontCode("btn.sbtxt", desc.sbfont, nil, true);
	createCode = createCode .. [[
	btn.sbtimetxt = VFLUI.CreateFontString(btn);
	btn.sbtimetxt:SetPoint("TOPLEFT", btn, "TOPLEFT");
	btn.sbtimetxt:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT");
	btn.sbtimetxt:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetFontCode("btn.sbtimetxt", desc.sbtimerfont, nil, true);
	createCode = createCode .. [[
	btn.ftc = ftc_]] .. objname .. [[(frame, btn.sb, btn.sbtimetxt);
]];
	createCode = createCode .. [[
	frame.]] .. objname .. [[[i] = btn;
end
]];
	createCode = createCode .. RDXUI.LayoutCodeMultiRows(objname, desc);
	return createCode;
end

local tbl_hvert = { {text = "HORIZONTAL"}}; --, {text = "VERTICAL"} };
local function hvert_gen() return tbl_hvert; end

local tbl_lr = { {text = "LEFT"}, {text = "RIGHT"} };
local function lr_gen() return tbl_lr; end

RDX.RegisterFeature({
	name = "aura_bars2";
	version = 2;
	title = i18n("Aura Bars");
	category = i18n("Auras/Cooldowns");
	multiple = true;
	VersionMismatch = function(desc)
		desc.version = 2;
		desc.nIcons = 10;
		desc.nBars = nil;
		return true;
	end;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Bars_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if not desc.mindurationfilter then desc.mindurationfilter = 0; end
		if (not tonumber(desc.mindurationfilter)) then 
			if (desc.mindurationfilter ~= "") then VFL.AddError(errs, i18n("Min duration is not a number or empty")); flg = nil; end 
		end
		if not desc.maxdurationfilter then desc.maxdurationfilter = 3000; end
		if (not tonumber(desc.maxdurationfilter)) then 
			if (desc.maxdurationfilter ~= "") then VFL.AddError(errs, i18n("Max duration is not a number or empty")); flg = nil; end 
		end
		if desc.externalNameFilter and desc.externalNameFilter ~= "" then
			if not RDXDB.CheckObject(desc.externalNameFilter, "AuraFilter") then VFL.AddError(errs, i18n("Invalid AuraFilter")); flg = nil; end
		end
		if flg then state:AddSlot("Bars_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Bars_" .. desc.name;
		local loadCode = "RDX.LoadBuffFromUnit";
		-- Event hinting.
		local mux, mask = state:GetContainingWindowState():GetSlotValue("Multiplexer"), 0;
		if desc.auraType == "DEBUFFS" then
			mask = mux:GetPaintMask("DEBUFFS");
			mux:Event_UnitMask("UNIT_DEBUFF_*", mask);
			loadCode = "RDX.LoadDebuffFromUnit";
		else
			mask = mux:GetPaintMask("BUFFS");
			mux:Event_UnitMask("UNIT_BUFF_*", mask);
		end
		mask = bit.bor(mask, 1);

		-- If there's an external filter, add a quick menu to the window to edit it.
		if desc.externalNameFilter then
			local path = desc.externalNameFilter; local afname = desc.name;
			state:GetContainingWindowState():Attach("Menu", true, function(win, mnu)
				table.insert(mnu, {
					text = i18n("Edit AuraFilter: ") .. afname;
					OnClick = function()
						VFL.poptree:Release();
						RDXDB.OpenObject(path, "Edit");
					end;
				});
			end);
		end

		------------ Closure
		local closureCode = [[
local ftc_]] .. objname .. [[ = FreeTimer.CreateFreeTimerClass(true,true, nil, RDXUI.GetTextTimerTypesString("MinSec"), false, false, FreeTimer.SB_Hide, FreeTimer.Text_None, FreeTimer.TextInfo_None, FreeTimer.TexIcon_Hide, FreeTimer.SB_Hide, FreeTimer.Text_None, FreeTimer.TextInfo_None, FreeTimer.TexIcon_Hide);
]];
		if desc.filterName then
			closureCode = closureCode .. [[
local ]] .. objname .. [[_fnames = ]];
			if desc.externalNameFilter then
				closureCode = closureCode .. [[RDXDB.GetObjectInstance(]] .. string.format("%q", desc.externalNameFilter) .. [[);
]];
			else
				-- Internal filter
				closureCode = closureCode .. [[{};
]];
				if desc.filterNameList then
					local flag;
					for _,name in pairs(desc.filterNameList) do
						flag = nil;
						local test = string.sub(name, 1, 1);
						if test == "!" then
							flag = true;
							name = string.sub(name, 2);
						end
						local testnumber = tonumber(name);
						if testnumber then
							local auname = GetSpellInfo(name);
							if flag then
								auname = "!" .. auname;
								closureCode = closureCode .. objname .. "_fnames[" .. string.format("%q", auname) .. "] = true; ";
							else
								closureCode = closureCode .. objname .. "_fnames[" .. string.format("%q", auname) .. "] = true; ";
							end
						else
							if flag then
								name = "!" .. name;
								closureCode = closureCode .. objname .. "_fnames[" .. string.format("%q", name) .. "] = true; ";
							else
								closureCode = closureCode .. objname .. "_fnames[" .. string.format("%q", name) .. "] = true; ";
							end
						end
					end
				end
			end
		end
		
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);

		----------------- Creation
		local createCode = _EmitCreateCode(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);

		------------------- Destruction
		local destroyCode = [[
local btn = nil;
for i=1,]] .. desc.nIcons .. [[ do
	btn = frame.]] .. objname .. [[[i]
	btn.meta = nil;
	VFLUI.ReleaseRegion(btn.icontex); btn.icontex = nil;
	VFLUI.ReleaseRegion(btn.icontxt); btn.icontxt = nil;
	btn.sb:Destroy(); btn.sb = nil;
	VFLUI.ReleaseRegion(btn.sbtxt); btn.sbtxt = nil;
	VFLUI.ReleaseRegion(btn.sbtimetxt); btn.sbtimetxt = nil;
	btn.ftc:Destroy(); btn.ftc = nil;
	btn:Destroy();
end
frame.]] .. objname .. [[ = nil;
]];
		state:Attach("EmitDestroy", true, function(code) code:AppendCode(destroyCode); end);

		------------------- Paint
		local winpath = state:GetContainingWindowState():GetSlotValue("Path");
		local md = RDXDB.GetObjectData(winpath);
		local auracache = "false"; if md and RDX.HasFeature(md.data, "AuraCache") then auracache = "true"; end
		
		local raidfilter = "nil"; if desc.raidfilter then raidfilter = "true"; end
		
		local aurasfilter, afflag = " (", nil; 
		if desc.playerauras then aurasfilter = aurasfilter .. " _caster == 'player'"; afflag = true; end
		if desc.othersauras then
			if afflag then
				aurasfilter = aurasfilter .. " or _caster ~= 'player'";
			else
				aurasfilter = aurasfilter .. " _caster ~= 'player'"; afflag = true;
			end
		end
		if desc.petauras then 
			if afflag then
				aurasfilter = aurasfilter .. " or _caster == 'pet'";
			else
				aurasfilter = aurasfilter .. " _caster == 'pet'"; afflag = true;
			end
		end
		if desc.targetauras then 
			if afflag then
				aurasfilter = aurasfilter .. " or _caster == 'target'";
			else
				aurasfilter = aurasfilter .. " _caster == 'target'"; afflag = true;
			end
		end
		if desc.focusauras then 
			if afflag then
				aurasfilter = aurasfilter .. " or _caster == 'focus'";
			else
				aurasfilter = aurasfilter .. " _caster == 'focus'"; afflag = true;
			end
		end
		if not afflag then aurasfilter = aurasfilter .. " true"; end
		aurasfilter = aurasfilter .. " )";
		
		local isstealablefilter = "true"; if desc.isstealablefilter then isstealablefilter = "_isStealable"; end
		local curefilter = "true"; if desc.curefilter then curefilter = "(_dispelt and RDXSS.GetCategoryByName('CURE_'..string.upper(_dispelt)))"; end
		local timefilter = "true"; if desc.timefilter then timefilter = "(_dur > 0";
			if (desc.mindurationfilter ~= "") then timefilter = timefilter .. " and _dur >= " .. desc.mindurationfilter; end
			if (desc.maxdurationfilter ~= "") then timefilter = timefilter .. " and _dur <= " .. desc.maxdurationfilter; end
			timefilter = timefilter ..")";
		end
		local namefilter = "true"; if desc.filterName then
			namefilter = "(" .. objname .. "_fnames[_bn] or " .. objname .. "_fnames[_meta.category])";
			namefilter = namefilter .. " and (not (" .. objname .. "_fnames['!'.._bn] or " .. objname .. "_fnames['!'.._meta.category]))"
		end
		local showBorder = "false"; if desc.bkd.edgeSize then showBorder = "true"; end
		local usedebuffcolor = "true"; if (not desc.sbcolor) then usedebuffcolor = "false"; end
		local auranametrunc = "nil"; if desc.trunc then auranametrunc = desc.trunc; end
		local auranameab = "true"; if (not desc.abr) then auranameab = "false"; end
		local auratex = "true" if (not desc.hidetex) then auratex = "false"; end
		local sorticons = " "; if desc.sort then
			if desc.sortduration then sorticons = sorticons .. [[
			table.sort(sort_icons, function(x1,x2) return x1._dur < x2._dur; end); ]];
			end
			if desc.sortstack then sorticons = sorticons .. [[
			table.sort(sort_icons, function(x1,x2) return x1._apps < x2._apps; end); ]];
			end
			if desc.sorttimeleft then sorticons = sorticons .. [[
			table.sort(sort_icons, function(x1,x2) return x1._tl < x2._tl; end); ]];
			end
			if desc.sortname then sorticons = sorticons .. [[
			table.sort(sort_icons, function(x1,x2) return x1._bn < x2._bn; end); ]];
			end
			
		end

		local paintCode = [[
if band(paintmask, ]] .. mask .. [[) ~= 0 then
	_i, _j, _bn, _tex, _apps, _meta, _dur, _tl, _dispelt, _caster, _isStealable = 1,1,nil,nil,nil,nil,nil,nil,nil,nil;
	_icons = frame.]] .. objname .. [[;
	local sort_icons = {};
	
	while true do
		local tbl_icons = {};
		_, _bn, _, _, _meta, _, _tex, _apps, _dispelt, _dur, _, _tl, _caster, _isStealable = ]] .. loadCode .. [[(uid, _i, ]] .. raidfilter .. [[, ]] .. auracache .. [[);
		if not _meta then break; end
		if (not _meta.isInvisible) and ]] .. aurasfilter .. [[ and ]] .. isstealablefilter .. [[ and ]] .. curefilter .. [[ and ]] .. timefilter .. [[ and ]] .. namefilter .. [[ then
			tbl_icons._bn = _bn;
			tbl_icons._meta = _meta;
			tbl_icons._tex = _tex;
			tbl_icons._apps = _apps;
			tbl_icons._dispelt = _dispelt;
			tbl_icons._dur = _dur;
			tbl_icons._tl = _tl;
			tbl_icons._i = _i;
			table.insert(sort_icons, tbl_icons);
		end
		_i = _i + 1;
	end
	
	]];
		paintCode = paintCode .. sorticons;
		paintCode = paintCode ..[[
	local tbl_icons;
	while true do
		if (_j > ]] .. desc.nIcons .. [[) then break; end
		tbl_icons = sort_icons[_j];
		if not tbl_icons then break; end
		__SetAuraBar(_icons[_j], tbl_icons._meta, tbl_icons._tex, tbl_icons._apps, tbl_icons._dur, tbl_icons._tl, tbl_icons._dispelt, tbl_icons._i, ]] .. showBorder .. [[, "]] .. desc.auraType .. [[", ]] .. usedebuffcolor .. [[, ]] .. auranametrunc .. [[, ]] .. auranameab .. [[, ]] .. auratex .. [[);
		_j = _j + 1;
	end
	
	while _j <= ]] .. desc.nIcons .. [[ do
		_icons[_j]:Hide(); _j = _j + 1;
	end
end
]];

		local paintCodeWithoutSort = [[
if band(paintmask, ]] .. mask .. [[) ~= 0 then
	_i, _j, _bn, _tex, _apps, _meta, _dur, _tl, _dispelt, _caster, _isStealable = 1,1,nil,nil,nil,nil,nil,nil,nil,nil;
	_icons = frame.]] .. objname .. [[;
	while true do
		if (_j > ]] .. desc.nIcons .. [[) then break; end
		_, _bn, _, _, _meta, _, _tex, _apps, _dispelt, _dur, _, _tl, _caster, _isStealable = ]] .. loadCode .. [[(uid, _i, ]] .. raidfilter .. [[, ]] .. auracache .. [[);
		if not _meta then break; end
		if (not _meta.isInvisible) and ]] .. aurasfilter .. [[ and ]] .. isstealablefilter .. [[ and ]] .. curefilter .. [[ and ]] .. timefilter .. [[ and ]] .. namefilter .. [[ then
			__SetAuraBar(_icons[_j], _meta, _tex, _apps, _dur, _tl, _dispelt, _i, ]] .. showBorder .. [[, "]] .. desc.auraType .. [[", ]] .. usedebuffcolor .. [[, ]] .. auranametrunc .. [[, ]] .. auranameab .. [[, ]] .. auratex .. [[);
			_j = _j + 1;
		end
		_i = _i + 1;
	end
	while _j <= ]] .. desc.nIcons .. [[ do
		_icons[_j]:Hide(); _j = _j + 1;
	end
end
]];

		if desc.sort then
			state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCode); end);
		else
			state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCodeWithoutSort); end);
		end
		------------------- Cleanup
		local cleanupCode = [[
local btn = nil;
for i=1,]] .. desc.nIcons .. [[ do
	btn = frame.]] .. objname .. [[[i];
	btn:Hide(); btn.meta = nil;
	btn.sb:SetValue(0);
end
]];
		state:Attach("EmitCleanup", true, function(code) code:AppendCode(cleanupCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		------------- Core
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Core Parameters")));

		local ed_name = VFLUI.LabeledEdit:new(ui, 100); ed_name:Show();
		ed_name:SetText(i18n("Name"));
		ed_name.editBox:SetText(desc.name);
		ui:InsertFrame(ed_name);

		local er = RDXUI.EmbedRight(ui, i18n("Aura Type:"));
		local dd_auraType = VFLUI.Dropdown:new(er, RDXUI.AurasTypesDropdownFunction);
		dd_auraType:SetWidth(75); dd_auraType:Show();
		if desc and desc.auraType then 
			dd_auraType:SetSelection(desc.auraType); 
		else
			dd_auraType:SetSelection("BUFFS");
		end
		er:EmbedChild(dd_auraType); er:Show();
		ui:InsertFrame(er);

		------------- Layout
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout")));

		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_mb = VFLUI.LabeledEdit:new(ui, 50); ed_mb:Show();
		ed_mb:SetText(i18n("Max bars"));
		if desc and desc.nIcons then ed_mb.editBox:SetText(desc.nIcons); end
		ui:InsertFrame(ed_mb);

		local ed_rows = VFLUI.LabeledEdit:new(ui, 50); ed_rows:Show();
		ed_rows:SetText(i18n("Row size"));
		if desc and desc.rows then ed_rows.editBox:SetText(desc.rows); end
		ui:InsertFrame(ed_rows);

		local er = RDXUI.EmbedRight(ui, i18n("Orientation:"));
		local dd_orientation = VFLUI.Dropdown:new(er, RDXUI.OrientationDropdownFunction);
		dd_orientation:SetWidth(75); dd_orientation:Show();
		if desc and desc.orientation then 
			dd_orientation:SetSelection(desc.orientation); 
		else
			dd_orientation:SetSelection("RIGHT");
		end
		er:EmbedChild(dd_orientation); er:Show();
		ui:InsertFrame(er);
		
		local ed_iconspx = VFLUI.LabeledEdit:new(ui, 50); ed_iconspx:Show();
		ed_iconspx:SetText(i18n("Bars spacing width"));
		if desc and desc.iconspx then ed_iconspx.editBox:SetText(desc.iconspx); else ed_iconspx.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspx);
		
		local ed_iconspy = VFLUI.LabeledEdit:new(ui, 50); ed_iconspy:Show();
		ed_iconspy:SetText(i18n("Bars spacing height"));
		if desc and desc.iconspy then ed_iconspy.editBox:SetText(desc.iconspy); else ed_iconspy.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspy);
		
		local er_bor = RDXUI.EmbedRight(ui, i18n("Bar orientation:"));
		local dd_borientation = VFLUI.Dropdown:new(er_bor, hvert_gen);
		dd_borientation:SetWidth(100); dd_borientation:Show();
		if desc and desc.borientation then 
			dd_borientation:SetSelection(desc.borientation); 
		else
			dd_borientation:SetSelection("HORIZONTAL");
		end
		er_bor:EmbedChild(dd_borientation); er_bor:Show();
		ui:InsertFrame(er_bor);
		
		local ed_width, ed_height = RDXUI.GenWidthHeightPortion(ui, desc, state);
		
		local er_ip = RDXUI.EmbedRight(ui, i18n("Icon Position"));
		local dd_ip = VFLUI.Dropdown:new(er_ip, lr_gen);
		dd_ip:SetWidth(100); dd_ip:Show();
		if desc and desc.iconposition then 
			dd_ip:SetSelection(desc.iconposition); 
		else
			dd_ip:SetSelection("LEFT");
		end
		er_ip:EmbedChild(dd_ip); er_ip:Show();
		ui:InsertFrame(er_ip);

		-------------- Display
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Display")));
		
		local er2 = RDXUI.EmbedRight(ui, i18n("Backdrop style"));
		local bkd = VFLUI.MakeBackdropSelectButton(er2, desc.bkd); bkd:Show();
		er2:EmbedChild(bkd); er2:Show();
		ui:InsertFrame(er2);
		
		local er_if = RDXUI.EmbedRight(ui, i18n("Icon Font Stack"));
		local iconfontsel = VFLUI.MakeFontSelectButton(er_if, desc.iconfont); iconfontsel:Show();
		er_if:EmbedChild(iconfontsel); er_if:Show();
		ui:InsertFrame(er_if);
		
		local er_btx = RDXUI.EmbedRight(ui, i18n("Bar Texture"));
		local sbtexsel = VFLUI.MakeTextureSelectButton(er_btx, desc.sbtexture); sbtexsel:Show();
		er_btx:EmbedChild(sbtexsel); er_btx:Show();
		ui:InsertFrame(er_btx);
		
		local er_bf = RDXUI.EmbedRight(ui, i18n("Bar Font Aura name"));
		local barfontsel = VFLUI.MakeFontSelectButton(er_bf, desc.sbfont); barfontsel:Show();
		er_bf:EmbedChild(barfontsel); er_bf:Show();
		ui:InsertFrame(er_bf);
		
		local ed_trunc = VFLUI.LabeledEdit:new(ui, 50); ed_trunc:Show();
		ed_trunc:SetText(i18n("Max aura length (blank = no truncation)"));
		if desc and desc.trunc then ed_trunc.editBox:SetText(desc.trunc); end
		ui:InsertFrame(ed_trunc);
		
		local chk_abr = VFLUI.Checkbox:new(ui); chk_abr:Show();
		chk_abr:SetText(i18n("Use abbreviating"));
		if desc and desc.abr then chk_abr:SetChecked(true); else chk_abr:SetChecked(); end
		ui:InsertFrame(chk_abr);
		
		local er_tf = RDXUI.EmbedRight(ui, i18n("Bar Font Aura Timer"));
		local timerfontsel = VFLUI.MakeFontSelectButton(er_tf, desc.sbtimerfont); timerfontsel:Show();
		er_tf:EmbedChild(timerfontsel); er_tf:Show();
		ui:InsertFrame(er_tf);
		
		local chk_bc = VFLUI.Checkbox:new(ui); chk_bc:Show();
		chk_bc:SetText(i18n("Use Bar color debuff"));
		if desc and desc.sbcolor then chk_bc:SetChecked(true); else chk_bc:SetChecked(); end
		ui:InsertFrame(chk_bc);
		
		local chk_ephemeral = VFLUI.Checkbox:new(ui); chk_ephemeral:Show();
		chk_ephemeral:SetText(i18n("No tooltips on mouseover / No drop on click"));
		if desc and desc.ephemeral then chk_ephemeral:SetChecked(true); else chk_ephemeral:SetChecked(); end
		ui:InsertFrame(chk_ephemeral);
		
		local chk_tex = VFLUI.Checkbox:new(ui); chk_tex:Show();
		chk_tex:SetText(i18n("Hide icon texture"));
		if desc and desc.hidetex then chk_tex:SetChecked(true); else chk_tex:SetChecked(); end
		ui:InsertFrame(chk_tex);
		
		------------ Sort
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Sort")));
		
		local chk_sort = VFLUI.Checkbox:new(ui); chk_sort:Show();
		chk_sort:SetText(i18n("Activate Sort"));
		if desc and desc.sort then chk_sort:SetChecked(true); else chk_sort:SetChecked(); end
		ui:InsertFrame(chk_sort);
		
		local chk_sortstack = VFLUI.Checkbox:new(ui); chk_sortstack:Show();
		chk_sortstack:SetText(i18n("Sort by stack"));
		if desc and desc.sortstack then chk_sortstack:SetChecked(true); else chk_sortstack:SetChecked(); end
		ui:InsertFrame(chk_sortstack);
		
		local chk_sortduration = VFLUI.Checkbox:new(ui); chk_sortduration:Show();
		chk_sortduration:SetText(i18n("Sort by duration"));
		if desc and desc.sortduration then chk_sortduration:SetChecked(true); else chk_sortduration:SetChecked(); end
		ui:InsertFrame(chk_sortduration);
		
		local chk_sorttimeleft = VFLUI.Checkbox:new(ui); chk_sorttimeleft:Show();
		chk_sorttimeleft:SetText(i18n("Sort by timeleft"));
		if desc and desc.sorttimeleft then chk_sorttimeleft:SetChecked(true); else chk_sorttimeleft:SetChecked(); end
		ui:InsertFrame(chk_sorttimeleft);
		
		local chk_sortname = VFLUI.Checkbox:new(ui); chk_sortname:Show();
		chk_sortname:SetText(i18n("Sort by name"));
		if desc and desc.sortname then chk_sortname:SetChecked(true); else chk_sortname:SetChecked(); end
		ui:InsertFrame(chk_sortname);

		------------ Filter
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Filtering")));

		local chk_raidfilter = VFLUI.Checkbox:new(ui); chk_raidfilter:Show();
		chk_raidfilter:SetText(i18n("Use Blizzard raid filter"));
		if desc and desc.raidfilter then chk_raidfilter:SetChecked(true); else chk_raidfilter:SetChecked(); end
		ui:InsertFrame(chk_raidfilter);
		
		local chk_playerauras = VFLUI.Checkbox:new(ui); chk_playerauras:Show();
		chk_playerauras:SetText(i18n("Filter auras by player"));
		if desc and desc.playerauras then chk_playerauras:SetChecked(true); else chk_playerauras:SetChecked(); end
		ui:InsertFrame(chk_playerauras);
		
		local chk_othersauras = VFLUI.Checkbox:new(ui); chk_othersauras:Show();
		chk_othersauras:SetText(i18n("Filter auras by other players"));
		if desc and desc.othersauras then chk_othersauras:SetChecked(true); else chk_othersauras:SetChecked(); end
		ui:InsertFrame(chk_othersauras);

		local chk_petauras = VFLUI.Checkbox:new(ui); chk_petauras:Show();
		chk_petauras:SetText(i18n("Filter auras by pet/vehicle"));
		if desc and desc.petauras then chk_petauras:SetChecked(true); else chk_petauras:SetChecked(); end
		ui:InsertFrame(chk_petauras);
		
		local chk_targetauras = VFLUI.Checkbox:new(ui); chk_targetauras:Show();
		chk_targetauras:SetText(i18n("Filter auras by target"));
		if desc and desc.targetauras then chk_targetauras:SetChecked(true); else chk_targetauras:SetChecked(); end
		ui:InsertFrame(chk_targetauras);
		
		local chk_focusauras = VFLUI.Checkbox:new(ui); chk_focusauras:Show();
		chk_focusauras:SetText(i18n("Filter auras by focus"));
		if desc and desc.focusauras then chk_focusauras:SetChecked(true); else chk_focusauras:SetChecked(); end
		ui:InsertFrame(chk_focusauras);
		
		local chk_nameauras = VFLUI.Checkbox:new(ui); chk_nameauras:Show();
		chk_nameauras:SetText(i18n("Filter auras by name"));
		if desc and desc.nameauras then chk_nameauras:SetChecked(true); else chk_nameauras:SetChecked(); end
		ui:InsertFrame(chk_nameauras);
		
		local ed_unitfilter = VFLUI.LabeledEdit:new(ui, 200); ed_unitfilter:Show();
		ed_unitfilter:SetText(i18n("Name of the unit"));
		if desc and desc.unitfilter then ed_unitfilter.editBox:SetText(desc.unitfilter); else ed_unitfilter.editBox:SetText(""); end
		ui:InsertFrame(ed_unitfilter);
		
		local chk_isStealable = VFLUI.Checkbox:new(ui); chk_isStealable:Show();
		chk_isStealable:SetText(i18n("Show only Stealable auras"));
		if desc and desc.isstealablefilter then chk_isStealable:SetChecked(true); else chk_isStealable:SetChecked(); end
		ui:InsertFrame(chk_isStealable);
		
		local chk_curefilter = VFLUI.Checkbox:new(ui); chk_curefilter:Show();
		chk_curefilter:SetText(i18n("Show only auras that I can cure"));
		if desc and desc.curefilter then chk_curefilter:SetChecked(true); else chk_curefilter:SetChecked(); end
		ui:InsertFrame(chk_curefilter);
		
		local chk_timefilter = VFLUI.Checkbox:new(ui); chk_timefilter:Show();
		chk_timefilter:SetText(i18n("Show only auras with timer"));
		if desc and desc.timefilter then chk_timefilter:SetChecked(true); else chk_timefilter:SetChecked(); end
		ui:InsertFrame(chk_timefilter);
                
		local ed_maxduration = VFLUI.LabeledEdit:new(ui, 50); ed_maxduration:Show();
		ed_maxduration:SetText(i18n("Filter by Max duration (sec)"));
		if desc and desc.maxdurationfilter then ed_maxduration.editBox:SetText(desc.maxdurationfilter); else ed_maxduration.editBox:SetText(""); end
		ui:InsertFrame(ed_maxduration);
		
		local ed_minduration = VFLUI.LabeledEdit:new(ui, 50); ed_minduration:Show();
		ed_minduration:SetText(i18n("Filter by min duration (sec)"));
		if desc and desc.mindurationfilter then ed_minduration.editBox:SetText(desc.mindurationfilter); else ed_minduration.editBox:SetText(""); end
		ui:InsertFrame(ed_minduration);

		local chk_filterName = VFLUI.Checkbox:new(ui); chk_filterName:Show();
		chk_filterName:SetText(i18n("Filter by aura name"));
		if desc and desc.filterName then chk_filterName:SetChecked(true); else chk_filterName:SetChecked(); end
		ui:InsertFrame(chk_filterName);

		local chk_external = RDXUI.CheckEmbedRight(ui, i18n("Use external aura list"));
		local file_external = RDXDB.ObjectFinder:new(chk_external, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "AuraFilter$")); end);
		file_external:SetWidth(200); file_external:Show();
		chk_external:EmbedChild(file_external); chk_external:Show();
		ui:InsertFrame(chk_external);
		if desc.externalNameFilter then
			chk_external:SetChecked(true); file_external:SetPath(desc.externalNameFilter);
		else
			chk_external:SetChecked();
		end

		local le_names = VFLUI.ListEditor:new(ui, desc.filterNameList or {}, function(cell,data) 
			if type(data) == "number" then
				local name = GetSpellInfo(data);
				cell.text:SetText(name);
			else
				local test = string.sub(data, 1, 1);
				if test == "!" then
					local uname = string.sub(data, 2);
					local vname = GetSpellInfo(uname);
					if vname then
						cell.text:SetText("!" .. vname);
					else
						cell.text:SetText(data);
					end
				else
					cell.text:SetText(data);
				end
			end
		end);
		le_names:SetHeight(183); le_names:Show();
		ui:InsertFrame(le_names);
		
		function ui:GetDescriptor()
			local trunc = tonumber(ed_trunc.editBox:GetText());
			if trunc then trunc = VFL.clamp(trunc, 1, 50); end
			local filterName, filterNameList, filternl, ext, unitfi = nil, nil, {}, nil, "";
			if chk_nameauras:GetChecked() then
				unitfi = string.lower(ed_unitfilter.editBox:GetText());
			end
			if chk_timefilter:GetChecked() then
				maxdurfil = ed_maxduration.editBox:GetText();
				mindurfil = ed_minduration.editBox:GetText();
			end
			if chk_filterName:GetChecked() then
				filterNameList = le_names:GetList();
				local flag;
				for k,v in pairs(filterNameList) do
					flag = nil;
					local test = string.sub(v, 1, 1);
					if test == "!" then
						flag = true;
						v = string.sub(v, 2);
					end
					local testnumber = tonumber(v);
					if testnumber then
						if flag then
							filternl[k] = "!" .. testnumber;
						else
							filternl[k] = testnumber;
						end
					else
						if flag then
							local spellid = RDXSS.GetSpellIdByLocalName(v);
							if spellid then
								filternl[k] = "!" .. spellid;
							else
								filternl[k] = "!" .. v;
							end
						else
							filternl[k] = RDXSS.GetSpellIdByLocalName(v) or v;
						end
					end
				end
				if chk_external:GetChecked() then ext = file_external:GetPath(); end
			end
			if  not chk_sort:GetChecked() then
				chk_sortstack:SetChecked();
				chk_sortduration:SetChecked();
				chk_sorttimeleft:SetChecked();
				chk_sortname:SetChecked();
			end
			return { 
				feature = "aura_bars2"; 
				version = 2;
				name = ed_name.editBox:GetText();
				auraType = dd_auraType:GetSelection();
				-- layout
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				nIcons = VFL.clamp(ed_mb.editBox:GetNumber(), 1, 40);
				rows = VFL.clamp(ed_rows.editBox:GetNumber(), 1, 40);
				orientation = dd_orientation:GetSelection();
				iconspx = VFL.clamp(ed_iconspx.editBox:GetNumber(), 0, 200);
				iconspy = VFL.clamp(ed_iconspy.editBox:GetNumber(), 0, 200);
				borientation = dd_borientation:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				iconposition = dd_ip:GetSelection();
				-- display
				bkd = bkd:GetSelectedBackdrop();
				iconfont = iconfontsel:GetSelectedFont();
				sbtexture = sbtexsel:GetSelectedTexture();
				sbfont = barfontsel:GetSelectedFont();
				trunc = trunc;
				abr = chk_abr:GetChecked();
				sbtimerfont = timerfontsel:GetSelectedFont();
				sbcolor = chk_bc:GetChecked();
				ephemeral = chk_ephemeral:GetChecked();
				hidetex = chk_tex:GetChecked();
				-- filter
				raidfilter = chk_raidfilter:GetChecked();
				playerauras = chk_playerauras:GetChecked();
				othersauras = chk_othersauras:GetChecked();
				petauras = chk_petauras:GetChecked();
				targetauras = chk_targetauras:GetChecked();
				focusauras = chk_focusauras:GetChecked();
				nameauras = chk_nameauras:GetChecked();
				unitfilter = unitfi;
				isstealablefilter = chk_isStealable:GetChecked();
				curefilter = chk_curefilter:GetChecked();
				timefilter = chk_timefilter:GetChecked();
				maxdurationfilter = maxdurfil;
				mindurationfilter = mindurfil;
				filterName = chk_filterName:GetChecked();
				externalNameFilter = ext;
				filterNameList = filternl;
				-- sort
				sort = chk_sort:GetChecked();
				sortstack = chk_sortstack:GetChecked();
				sortduration = chk_sortduration:GetChecked();
				sorttimeleft = chk_sorttimeleft:GetChecked();
				sortname = chk_sortname:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		local sbtfont = VFL.copy(Fonts.Default); sbtfont["justifyH"] = "RIGHT";
		return { 
			feature = "aura_bars2";
			version = 1;
			name = "ab1";
			auraType = "BUFFS";
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			nIcons = 10; rows = 1; orientation = "DOWN"; iconspx = 0; iconspy = 1; 
			borientation = "HORIZONTAL"; w = 90; h = 14;
			bkd = VFL.copy(VFLUI.defaultBackdrop);
			iconfont = VFL.copy(Fonts.Default);
			sbtexture = { blendMode = "BLEND"; path = "Interface\\TargetingFrame\\UI-StatusBar"; };
			sbfont = VFL.copy(Fonts.Default);
			sbtimerfont = sbtfont;
		};
	end;
});

