-- Filter.lua
-- RDX6 - Project Omniscience
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Code for filtration of Omniscience logs.

-------------------------------------------------
-- The filter editor dialog
-------------------------------------------------
Omni.FilterEditor = {};
function Omni.FilterEditor:new(parent)
	local dlg = VFLUI.AcquireFrame("Frame");
	if parent then
		dlg:SetParent(parent); 
		dlg:SetFrameStrata(parent:GetFrameStrata());
		dlg:SetFrameLevel(parent:GetFrameLevel() + 3);
	end
	dlg:SetWidth(346); dlg:SetHeight(340); 
	dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
	dlg:Show();

	-- Scrollframe
	local sf = VFLUI.VScrollFrame:new(dlg);
	sf:SetWidth(320); sf:SetHeight(330);
	sf:SetPoint("TOPLEFT", dlg, "TOPLEFT", 5, -5);
	sf:Show();

	-- Root
	local ui = VFLUI.CompoundFrame:new(sf); ui.isLayoutRoot = true;

	-- Event types
	local ctr = VFLUI.CollapsibleFrame:new(ui); ctr:Show();
	ctr:SetText("Event Types");
	ui:InsertFrame(ctr);
	local ctd = VFLUI.CheckGroup:new(ctr); ctd:Show();
	ctr:SetChild(ctd); ctr:SetCollapsed(true);
	local btnMap = Omni.GetMap_IndexToRowType();
	ctd:SetLayout(18, 2);
	for i=1,18 do ctd.checkBox[i]:SetText(strtcolor(Omni.GetRowTypeColor(i)) .. (btnMap[i] or "") .. "|r"); end
	local etypes_container, etypes_checks = ctr,ctd;

	-- Damage types
	ctr = VFLUI.CollapsibleFrame:new(ui); ctr:Show();
	ctr:SetText("Damage Types");
	ui:InsertFrame(ctr);
	ctd = VFLUI.CheckGroup:new(ctr); ctd:Show();
	ctr:SetChild(ctd); ctr:SetCollapsed(true);
	ctd:SetLayout(9, 3);
	for i=1,9 do
		ctd.checkBox[i]:SetText(strtcolor(Omni.GetDamageTypeColor(i)) .. Omni.GetDamageTypeName(i) .. "|r");
	end
	local dtypes_container, dtypes_checks = ctr, ctd;

	-- Modifiers
	ctr = VFLUI.CollapsibleFrame:new(ui); ctr:Show();
	ctr:SetText("Modifiers");
	ui:InsertFrame(ctr);
	ctd = VFLUI.CheckGroup:new(ctr); ctd:Show();
	ctr:SetChild(ctd); ctr:SetCollapsed(true);
	ctd:SetLayout(9, 3);
	for i=1,9 do ctd.checkBox[i]:SetText(Omni.GetXiType(i)); end
	local mtypes_container, mtypes_checks = ctr, ctd;

	-- Source Filter
	ctr = VFLUI.CollapsibleFrame:new(ui); ctr:Show();
	ctr:SetText("Source");
	ui:InsertFrame(ctr);
	ctd = VFLUI.LabeledEdit:new(ctr, 200); ctd:Show();
	ctr:SetChild(ctd); ctr:SetCollapsed(true);
	ctd:SetText("* is a wildcard");
	local src_container, src_edit = ctr,ctd;

	-- Target Filter
	ctr = VFLUI.CollapsibleFrame:new(ui); ctr:Show();
	ctr:SetText("Target");
	ui:InsertFrame(ctr);
	ctd = VFLUI.LabeledEdit:new(ctr, 200); ctd:Show();
	ctr:SetChild(ctd); ctr:SetCollapsed(true);
	ctd:SetText("* is a wildcard");
	local targ_container, targ_edit = ctr,ctd;	

	-- Ability Filter
	ctr = VFLUI.CollapsibleFrame:new(ui); ctr:Show();
	ctr:SetText("Ability");
	ui:InsertFrame(ctr);
	ctd = VFLUI.LabeledEdit:new(ctr, 250); ctd:Show();
	ctr:SetChild(ctd); ctr:SetCollapsed(true);
	ctd:SetText("* is a wildcard");
	local abil_container, abil_edit = ctr,ctd;	

	--- Layout Engine Bootstrap
	sf:SetScrollChild(ui);
	ui:SetWidth(sf:GetWidth());
	ui:DialogOnLayout(); ui:Show();

	function dlg:GetDescriptor()
		local desc = {};
		if not etypes_container:IsCollapsed() then
			desc.etypes = {};
			for i=1,18 do 
				if etypes_checks.checkBox[i]:GetChecked() then desc.etypes[i] = true; end
			end
		end

		if not dtypes_container:IsCollapsed() then
			desc.dtypes = {};
			for i=1,9 do 
				if dtypes_checks.checkBox[i]:GetChecked() then desc.dtypes[i] = true; end
			end
		end

		if not mtypes_container:IsCollapsed() then
			desc.mtypes = {};
			for i=1,9 do 
				if mtypes_checks.checkBox[i]:GetChecked() then desc.mtypes[i] = true; end
			end
		end

		if not src_container:IsCollapsed() then desc.src = src_edit.editBox:GetText(); end
		if not targ_container:IsCollapsed() then desc.targ = targ_edit.editBox:GetText(); end
		if not abil_container:IsCollapsed() then desc.abil = abil_edit.editBox:GetText(); end

		return desc;
	end

	dlg.Destroy = VFL.hook(function(s)
		s.GetDescriptor = nil;
		sf:SetScrollChild(nil);
		ui:Destroy(); ui = nil; sf:Destroy(); sf = nil;
	end, dlg.Destroy);

	return dlg;
end

-- Given a descriptor, return a function that accepts a (table, row) pair and returns TRUE iff the row
-- matches the filter
function Omni.FilterFunctor(desc)
	if type(desc) ~= "table" then return VFL.Nil; end
	-- Load defaults
	local etypes, dtypes, mtypes = {}, {}, {};
	for i=1,18 do etypes[i] = true; end
	for i=1,9 do dtypes[i] = true; end
	for i=1,10 do mtypes[i] = true; end
	local re_src, re_targ, re_abil = nil, nil, nil;

	-- Deviate from defaults as needed
	if desc.etypes then for i=1,18 do etypes[i] = desc.etypes[i]; end end
	if desc.dtypes then for i=1,9 do dtypes[i] = desc.dtypes[i]; end end
	if desc.mtypes then 
		mtypes[10] = nil;
		for i=1,9 do mtypes[i] = desc.mtypes[i]; end 
	end
	if desc.src then re_src = VFL.WildcardToRegex(string.lower(desc.src)); end
	if desc.targ then re_targ = VFL.WildcardToRegex(string.lower(desc.targ)); end
	if desc.abil then re_abil = VFL.WildcardToRegex(string.lower(desc.abil)); end

	return function(tbl, row)
		if not etypes[row.y] then return nil; end
		if not dtypes[(row.d or 9)] then return nil; end
		-- Modifier type
		local modFlag = nil;
		if (mtypes[7] and row.absorbed) or (mtypes[4] and row.blocked) or (mtypes[5] and row.resisted) or (mtypes[row.e or 10]) then modFlag = true; end
		if not modFlag then return nil; end
		if re_src and (not string.find(string.lower(tbl:GetRowSource(row) or ""), re_src)) then return nil; end
		if re_targ and (not string.find(string.lower(tbl:GetRowTarget(row) or ""), re_targ)) then return nil; end
		if re_abil and (not string.find(string.lower(row.a or ""), re_abil)) then return nil; end
		return true;
	end
end
