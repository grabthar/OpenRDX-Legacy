-- CooldownIcons.lua
-- OpenRDX
-- sigg / rashgarroth
--

function __SetCooldownIcon(btn, meta, tex, dur, tl, i, ebs)
	btn:Show(); btn.meta = meta;
	btn:SetID(i);
	btn.tex:SetTexture(tex);
	-- Cooldown
	if dur and dur > 0 and btn.cd then
		btn.cd:SetCooldown(GetTime() + tl - dur , dur);
	--else
		--btn.cd:SetCooldown(0, 0);
	end
	return true;
end

--function __AuraIconOnEnter()
--	if this.meta then RDX.ShowAuraTooltip(this.meta, this, "RIGHT"); end
--end
--function __AuraIconOnLeave()
--	GameTooltip:Hide();
--end
--function __AuraIconOnClick()
--	CancelUnitBuff("player", this:GetID());
--end

--------------- Code emitter helpers
local function _EmitCreateCode(objname, desc)
	local ty, ebsos = '"Frame"', 0;
	if (not desc.ephemeral) then 
		ty = '"Button"';
		if desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end
	else
		if not desc.bkd then desc.bkd = {}; end
		if desc.bkd.edgeSize then ebsos = desc.bkd.edgeSize/3; end
	end
	
	local cdTimerType = "COOLDOWN"; if desc.cdTimerType then cdTimerType = desc.cdTimerType; end
	local cdtext, cdgfx, cdGfxReverse, cdTxtType, cdHideTxt = "false", "false", "true", "MinSec", "0"; 
	if desc.cdTimerType == "COOLDOWN" then cdtext = "false"; cdgfx = "true"; 
	elseif desc.cdTimerType == "TEXT" then cdtext = "true"; cdgfx = "false";
	elseif desc.cdTimerType == "COOLDOWN&TEXT" then cdtext = "true"; cdgfx = "true";
	end
	if desc.cdGfxReverse then cdGfxReverse = "false"; end
	if desc.cdTxtType then cdTxtType = desc.cdTxtType; end
	if desc.cdHideTxt then cdHideTxt = desc.cdHideTxt; end
	
	local createCode = [[
frame.]] .. objname .. [[ = {};
local btn, btnOwner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
for i=1, ]] .. desc.nIcons .. [[ do
	btn = VFLUI.AcquireFrame(]] .. ty .. [[);
	btn:SetParent(btnOwner);
	btn:SetFrameLevel(btnOwner:GetFrameLevel());
	btn:SetWidth(]] .. desc.size .. [[); btn:SetHeight(]] .. desc.size .. [[);
]];
	if (not desc.ephemeral) then
		createCode = createCode .. [[
	RDXUI.ApplyButtonSkin(btn, mddata_]] .. objname .. [[, true, false, false, true, true, true, false, true, false, true);
	btn:SetScript("OnEnter", __AuraIconOnEnter);
	btn:SetScript("OnLeave", __AuraIconOnLeave);
	btn:RegisterForClicks("RightButtonUp");
	btn:SetScript("OnClick", __AuraIconOnClick);]];
	else
		createCode = createCode .. [[
	VFLUI.SetBackdrop(btn, ]] .. Serialize(desc.bkd) .. [[);]];
	end
	
	createCode = createCode .. [[
	btn.tex = VFLUI.CreateTexture(btn);
	btn.tex:SetPoint("TOPLEFT", btn, "TOPLEFT", ]] .. ebsos .. [[, -]] .. ebsos .. [[);
	btn.tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -]] .. ebsos .. [[, ]] .. ebsos .. [[);
	btn.tex:SetTexCoord(0.08, 1-0.08, 0.08, 1-0.08);
	btn.tex:Show();
	
	btn.cd = RDXUI.CooldownCounter:new(btn, ]] .. cdtext .. ", " .. cdgfx .. [[, true, 0.3, "]] .. cdTxtType .. [[", ]] .. cdGfxReverse .. [[, ]] .. desc.cdoffx .. [[, ]] .. desc.cdoffy .. [[, ]] .. cdHideTxt .. [[);
	btn.cd:SetAllPoints(btn.tex);
	btn.cd:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetFontCode("btn.cd.fs", desc.cdFont, nil, true);
	createCode = createCode .. [[
	btn.sttxt = VFLUI.CreateFontString(btn);
	btn.sttxt:SetAllPoints(btn);
	btn.sttxt:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetFontCode("btn.sttxt", desc.fontst, nil, true);
	createCode = createCode .. [[
	frame.]] .. objname .. [[[i] = btn;
end
]];
	createCode = createCode .. RDXUI.LayoutCodeMultiRows(objname, desc);
	return createCode;
end

-----------------------------
-- AURA ICONS
-----------------------------
RDX.RegisterFeature({
	name = "cd_icons";
	version = 1;
	title = i18n("Cooldown Icons");
	category = i18n("Auras/Cooldowns");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Icons_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if not desc.ephemeral and not desc.externalButtonSkin then VFL.AddError(errs, i18n("Select button skin")); flg = nil; end
		if desc.externalButtonSkin then
			if not RDXDB.CheckObject(desc.externalButtonSkin, "ButtonSkin") then VFL.AddError(errs, i18n("Invalid button skin")); flg = nil; end
		end
		if not desc.mindurationfilter then desc.mindurationfilter = 0; end
		if (not tonumber(desc.mindurationfilter)) then 
			if (desc.mindurationfilter ~= "") then VFL.AddError(errs, i18n("Min duration is not a number or empty")); flg = nil; end 
		end
		if not desc.maxdurationfilter then desc.maxdurationfilter = 3000; end
		if (not tonumber(desc.maxdurationfilter)) then 
			if (desc.maxdurationfilter ~= "") then VFL.AddError(errs, i18n("Max duration is not a number or empty")); flg = nil; end 
		end
		if desc.externalNameFilter and desc.externalNameFilter ~= "" then
			if not RDXDB.CheckObject(desc.externalNameFilter, "CooldownFilter") then VFL.AddError(errs, i18n("Invalid AuraFilter")); flg = nil; end
		end
		if flg then state:AddSlot("Icons_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Icons_" .. desc.name;
		local ebs = "false"; if (not desc.ephemeral) then ebs = "true"; end
		-- Event hinting.
		local mux, mask = state:GetContainingWindowState():GetSlotValue("Multiplexer"), 0;
		mask = mux:GetPaintMask("COOLDOWNS");
		mux:Event_UnitMask("UNIT_COOLDOWN", mask);
		mask = bit.bor(mask, 1);
		
		-- If there's an external filter, add a quick menu to the window to edit it.
		if desc.externalNameFilter then
			local path = desc.externalNameFilter; local afname = desc.name;
			state:GetContainingWindowState():Attach("Menu", true, function(win, mnu)
				table.insert(mnu, {
					text = i18n("Edit CooldownFilter: ") .. afname;
					OnClick = function()
						VFL.poptree:Release();
						RDXDB.OpenObject(path, "Edit");
					end;
				});
			end);
		end

		------------ Closure
		local closureCode = [[ ]];
		if desc.filterName then
			closureCode = closureCode ..[[
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
		if not desc.ephemeral then 
			closureCode = closureCode .. [[ 
local mddata_]] .. objname .. [[ = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
		end
		if desc.filterName or (not desc.ephemeral) then
			state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);
		end
		
		----------------- Creation
		local createCode = _EmitCreateCode(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);

		------------------- Destruction
		local destroyCode = [[
local btn = nil;
for i=1,]] .. desc.nIcons .. [[ do
	btn = frame.]] .. objname .. [[[i]
	btn.meta = nil; ]];
			if (not desc.ephemeral) then
				destroyCode = destroyCode .. [[ 
	RDXUI.DestroyButtonSkin(btn); ]];
			end
			destroyCode = destroyCode .. [[
	VFLUI.ReleaseRegion(btn.sttxt); btn.sttxt = nil;
	btn.cd:Destroy(); btn.cd = nil;
	VFLUI.ReleaseRegion(btn.tex); btn.tex = nil;
	btn:Destroy();
end
frame.]] .. objname .. [[ = nil;
]];
		state:Attach("EmitDestroy", true, function(code) code:AppendCode(destroyCode); end);

		------------------- Paint
		local timefilter = "true"; if desc.timefilter then timefilter = "(_dur > 0";
			if (desc.mindurationfilter ~= "") then timefilter = timefilter .. " and _dur >= " .. desc.mindurationfilter; end
			if (desc.maxdurationfilter ~= "") then timefilter = timefilter .. " and _dur <= " .. desc.maxdurationfilter; end
			timefilter = timefilter ..")";
		end
		local namefilter = "true"; if desc.filterName then
			namefilter = "(" .. objname .. "_fnames[_bn] or " .. objname .. "_fnames[_meta.category])";
			namefilter = namefilter .. " and (not (" .. objname .. "_fnames['!'.._bn] or " .. objname .. "_fnames['!'.._meta.category]))"
		end
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
	_i, _j, _avail, _bn, _meta, _tex, _dur, _tl = 1, 1, nil, nil, nil, nil, nil;
	_icons = frame.]] .. objname .. [[;
	local sort_icons = {};

	while true do
		local tbl_icons = {};
		_avail, _bn, _, _, _meta, _tex, _dur, _, _tl = RDX.UnitCooldown(uid, _i);
		if not _avail then break; end
		if ]] .. timefilter .. [[ and ]] .. namefilter .. [[ then
			tbl_icons._bn = _bn;
			tbl_icons._meta = _meta;
			tbl_icons._tex = _tex;
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
		__SetCooldownIcon(_icons[_j], tbl_icons._meta, tbl_icons._tex, tbl_icons._dur, tbl_icons._tl, tbl_icons._i, ]] .. ebs .. [[);
		_j = _j + 1;
	end
	
	while _j <= ]] .. desc.nIcons .. [[ do
		_icons[_j]:Hide(); _j = _j + 1;
	end
end
]];

		local paintCodeWithoutSort = [[
if band(paintmask, ]] .. mask .. [[) ~= 0 then
	_i, _j, _avail, _bn, _meta, _tex, _dur, _tl = 1, 1, nil, nil, nil, nil, nil;
	_icons = frame.]] .. objname .. [[;
	while true do
		if (_j > ]] .. desc.nIcons .. [[) then break; end
		_avail, _bn, _, _, _meta, _tex, _dur, _, _tl = RDX.UnitCooldown(uid, _i);
		if not _avail then break; end
		if ]] .. timefilter .. [[ and ]] .. namefilter .. [[ then
			__SetCooldownIcon(_icons[_j], _meta, _tex, _dur, _tl, _i, ]] .. ebs .. [[);
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

		------------- Layout
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout")));

		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_nicon = VFLUI.LabeledEdit:new(ui, 50); ed_nicon:Show();
		ed_nicon:SetText(i18n("Max icons"));
		if desc and desc.nIcons then ed_nicon.editBox:SetText(desc.nIcons); end
		ui:InsertFrame(ed_nicon);

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
		ed_iconspx:SetText(i18n("Icons spacing width"));
		if desc and desc.iconspx then ed_iconspx.editBox:SetText(desc.iconspx); else ed_iconspx.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspx);
		
		local ed_iconspy = VFLUI.LabeledEdit:new(ui, 50); ed_iconspy:Show();
		ed_iconspy:SetText(i18n("Icons spacing height"));
		if desc and desc.iconspy then ed_iconspy.editBox:SetText(desc.iconspy); else ed_iconspy.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspy);
		
		local ed_size = VFLUI.LabeledEdit:new(ui, 50); ed_size:Show();
		ed_size:SetText(i18n("Icon Size"));
		if desc and desc.size then ed_size.editBox:SetText(desc.size); end
		ui:InsertFrame(ed_size);

		-------------- ButtonSkin or Frame
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Frame or Button type")));
		
		local chk_ephemeral = VFLUI.Checkbox:new(ui); chk_ephemeral:Show();
		chk_ephemeral:SetText(i18n("Frame type, no Button skin, no tooltips on mouseover / no drop on click"));
		if desc and desc.ephemeral then chk_ephemeral:SetChecked(true); else chk_ephemeral:SetChecked(); end
		ui:InsertFrame(chk_ephemeral);
		
		local erbs = RDXUI.EmbedRight(ui, i18n("Button Skin :"));
		local file_extBS = RDXDB.ObjectFinder:new(erbs, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "ButtonSkin$")); end);
		file_extBS:SetWidth(200); file_extBS:Show();
		erbs:EmbedChild(file_extBS); erbs:Show();
		ui:InsertFrame(erbs);
		if desc.externalButtonSkin then file_extBS:SetPath(desc.externalButtonSkin); end
		
		local ed_bs = VFLUI.LabeledEdit:new(ui, 50); ed_bs:Show();
		ed_bs:SetText(i18n("Button Skin Size Offset :"));
		if desc and desc.ButtonSkinOffset then ed_bs.editBox:SetText(desc.ButtonSkinOffset); end
		ui:InsertFrame(ed_bs);
		
		--local er2 = RDXUI.EmbedRight(ui, i18n("Backdrop (frame only) :"));
		--local bkd = VFLUI.MakeBackdropSelectButton(er2, desc.bkd); bkd:Show();
		--er2:EmbedChild(bkd); er2:Show();
		--ui:InsertFrame(er2);
		
		-------------- Display
		local er_cdTimerType, dd_cdTimerType, chk_cdGfxReverse, ed_cdHideTxt, er_cdFont, dd_cdFont, er_cdTxtType, dd_cdTxtType, ed_cdoffx, ed_cdoffy = RDXUI.GenCooldownPortion(ui, desc);
		
		--ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Stack Display")));
		
		--local er_st = RDXUI.EmbedRight(ui, i18n("Font stack"));
		--local fontsel2 = VFLUI.MakeFontSelectButton(er_st, desc.fontst); fontsel2:Show();
		--er_st:EmbedChild(fontsel2); er_st:Show();
		--ui:InsertFrame(er_st);
		
		------------ Sort
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Sort")));
		
		local chk_sort = VFLUI.Checkbox:new(ui); chk_sort:Show();
		chk_sort:SetText(i18n("Activate Sort"));
		if desc and desc.sort then chk_sort:SetChecked(true); else chk_sort:SetChecked(); end
		ui:InsertFrame(chk_sort);
		
		--local chk_sortstack = VFLUI.Checkbox:new(ui); chk_sortstack:Show();
		--chk_sortstack:SetText(i18n("Sort by stack"));
		--if desc and desc.sortstack then chk_sortstack:SetChecked(true); else chk_sortstack:SetChecked(); end
		--ui:InsertFrame(chk_sortstack);
		
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
		local file_external = RDXDB.ObjectFinder:new(chk_external, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "CooldownFilter$")); end);
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
		local filterName, filterNameList, filternl, ext, extBS, unitfi, maxdurfil, mindurfil = nil, nil, {}, nil, nil, "", "", "";
			if not chk_ephemeral:GetChecked() then extBS = file_extBS:GetPath(); end
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
				chk_sortduration:SetChecked();
				chk_sorttimeleft:SetChecked();
				chk_sortname:SetChecked();
			end
			return { 
				feature = "cd_icons"; version = 1;
				name = ed_name.editBox:GetText();
				-- layout
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				nIcons = VFL.clamp(ed_nicon.editBox:GetNumber(), 1, 40);
				rows = VFL.clamp(ed_rows.editBox:GetNumber(), 1, 40);
				orientation = dd_orientation:GetSelection();
				iconspx = VFL.clamp(ed_iconspx.editBox:GetNumber(), -200, 200);
				iconspy = VFL.clamp(ed_iconspy.editBox:GetNumber(), -200, 200);
				size = VFL.clamp(ed_size.editBox:GetNumber(), 1, 100);
				-- display
				ephemeral = chk_ephemeral:GetChecked();
				externalButtonSkin = extBS;
				ButtonSkinOffset = VFL.clamp(ed_bs.editBox:GetNumber(), 0, 50);
				--bkd = bkd:GetSelectedBackdrop();
				-- cooldown
				cdTimerType = dd_cdTimerType:GetSelection();
				cdGfxReverse = chk_cdGfxReverse:GetChecked();
				cdHideTxt = ed_cdHideTxt.editBox:GetText();
				cdFont = dd_cdFont:GetSelectedFont();
				cdTxtType = dd_cdTxtType:GetSelection();
				cdoffx = VFL.clamp(ed_cdoffx.editBox:GetNumber(), -50, 50);
				cdoffy = VFL.clamp(ed_cdoffy.editBox:GetNumber(), -50, 50);
				-- other
				--fontst = fontsel2:GetSelectedFont();
				-- filter
				--raidfilter = chk_raidfilter:GetChecked();
				--playerauras = chk_playerauras:GetChecked();
				--othersauras = chk_othersauras:GetChecked();
				--petauras = chk_petauras:GetChecked();
				--targetauras = chk_targetauras:GetChecked();
				--focusauras = chk_focusauras:GetChecked();
				--nameauras = chk_nameauras:GetChecked();
				--unitfilter = unitfi;
				--isstealablefilter = chk_isStealable:GetChecked();
				--curefilter = chk_curefilter:GetChecked();
				timefilter = chk_timefilter:GetChecked();
				maxdurationfilter = maxdurfil;
				mindurationfilter = mindurfil;
				filterName = chk_filterName:GetChecked();
				externalNameFilter = ext;
				filterNameList = filternl;
				-- sort
				sort = chk_sort:GetChecked();
				--sortstack = chk_sortstack:GetChecked();
				sortduration = chk_sortduration:GetChecked();
				sorttimeleft = chk_sorttimeleft:GetChecked();
				sortname = chk_sortname:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		local font = VFL.copy(Fonts.Default); font.size = 8; font.justifyV = "CENTER"; font.justifyH = "CENTER";
		return { 
			feature = "cd_icons";
			version = 1;
			name = "ai1";
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			nIcons = 4; size = 20; rows = 1; orientation = "RIGHT"; iconspx = 5; iconspy = 0;
			cdFont = font; cdTimerType = "COOLDOWN"; cdoffx = 0; cdoffy = 0;
			externalButtonSkin = "Builtin:bs_default";
			ButtonSkinOffset = 0;
		};
	end;
});


