-- UITools.lua
-- OpenRDX
--
-- Helpful tools and objects for the Desktop

----------------------------------------------------
-- Strata control
----------------------------------------------------
local strata = {
	{ text = "BACKGROUND" },
	{ text = "LOW" },
	{ text = "MEDIUM" },
	{ text = "HIGH"} ,
	{ text = "DIALOG" } ,
	{ text = "FULLSCREEN" } ,
	{ text = "FULLSCREEN_DIALOG" } ,
	{ text = "TOOLTIP" } ,
};
function RDXUI.DesktopStrataFunction() return strata; end

----------------------------------------------------
-- anchor control
----------------------------------------------------
local anchors = {
	--{ text = "Auto" },
	{ text = "TOPLEFT" },
	{ text = "TOPRIGHT" },
	{ text = "BOTTOMLEFT" },
	{ text = "BOTTOMRIGHT" },
	{ text = "CENTER" },
};
function RDXUI.DesktopAnchorFunction() return anchors; end

----------------------------------------------------
-- list RDX window
----------------------------------------------------

local wl = {};

local function BuildWindowList(class)
	VFL.empty(wl);
	local desc = nil;
	for pkg,data in pairs(RDXData) do
		for file,md in pairs(data) do
			if (type(md) == "table") and md.data and md.ty and string.find(md.ty, class) then
				table.insert(wl, {text = RDXDB.MakePath(pkg, file)});
			end
		end
	end
	table.sort(wl, function(x1,x2) return x1.text<x2.text; end);
end

local function _fnListWindows() BuildWindowList("Window"); return wl; end
local function _fnListStatusWindows() BuildWindowList("StatusWindow"); return wl; end

----------------------------------------------------
-- list windowless
----------------------------------------------------

local w2 = {};

local function BuildWindowLessList()
	VFL.empty(w2);
	local desc = nil;
	for k,v in pairs(RDXDK._GetWindowsLess()) do
		table.insert(w2, {text = k});
	end
	table.sort(w2, function(x1,x2) return x1.text<x2.text; end);
end

local function _fnListWindowsLess() BuildWindowLessList(); return w2; end

----------------------------------------------------
-- all windows must have these properties
----------------------------------------------------

function RDXUI.defaultUIFromDescriptor(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		local ft = desc.feature;
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Main properties")));
		local er, dd_windowId;
		if ft == "desktop_window" then
			er = RDXUI.EmbedRight(ui, i18n("Window:"));
			dd_windowId = VFLUI.Dropdown:new(er, _fnListWindows, nil, nil, nil, 30);
			dd_windowId:SetWidth(250); dd_windowId:Show();
			if desc and desc.name then 
				dd_windowId:SetSelection(desc.name); 
			end
			er:EmbedChild(dd_windowId); er:Show();
			ui:InsertFrame(er);
		elseif ft == "desktop_statuswindow" then
			er = RDXUI.EmbedRight(ui, i18n("Status Window:"));
			dd_windowId = VFLUI.Dropdown:new(er, _fnListStatusWindows, nil, nil, nil, 30);
			dd_windowId:SetWidth(250); dd_windowId:Show();
			if desc and desc.name then 
				dd_windowId:SetSelection(desc.name); 
			end
			er:EmbedChild(dd_windowId); er:Show();
			ui:InsertFrame(er);
		elseif ft == "desktop_windowless" then
			er = RDXUI.EmbedRight(ui, i18n("Registered Window:"));
			dd_windowId = VFLUI.Dropdown:new(er, _fnListWindowsLess, nil, nil, nil, 30);
			dd_windowId:SetWidth(250); dd_windowId:Show();
			if desc and desc.name then 
				dd_windowId:SetSelection(desc.name); 
			end
			er:EmbedChild(dd_windowId); er:Show();
			ui:InsertFrame(er);
		end
		
		local chkopen = VFLUI.Checkbox:new(ui); chkopen:Show();
		chkopen:SetText(i18n("Open this element"));
		if desc and desc.open then chkopen:SetChecked(true); else chkopen:SetChecked(); end
		ui:InsertFrame(chkopen);
		
		--local txtopen = VFLUI.SimpleText:new(ui, 1, 200); txtopen:Show();
		--local str = "";
		--if desc and desc.open then str="Window is shown on your desktop"; else str="Window is hidden in your desktop" end
		--txtopen:SetText(str);
		--ui:InsertFrame(txtopen);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout properties")));
		
		local ed_scale = VFLUI.LabeledEdit:new(ui, 50); ed_scale:Show();
		ed_scale:SetText(i18n("Scale:"));
		if desc and desc.scale then ed_scale.editBox:SetText(desc.scale); end
		ui:InsertFrame(ed_scale);
		
		local ed_alpha = VFLUI.LabeledEdit:new(ui, 50); ed_alpha:Show();
		ed_alpha:SetText(i18n("Alpha: "));
		if desc and desc.alpha then ed_alpha.editBox:SetText(desc.alpha); end
		ui:InsertFrame(ed_alpha);
		
		local er = RDXUI.EmbedRight(ui, i18n("Stratum: "));
		local dd_strataType = VFLUI.Dropdown:new(er, RDXUI.DesktopStrataFunction);
		dd_strataType:SetWidth(150); dd_strataType:Show();
		if desc and desc.strata then 
			dd_strataType:SetSelection(desc.strata); 
		else
			dd_strataType:SetSelection("MEDIUM");
		end
		er:EmbedChild(dd_strataType); er:Show();
		ui:InsertFrame(er);
		
		local er = RDXUI.EmbedRight(ui, i18n("Anchor:"));
		local dd_anchorType = VFLUI.Dropdown:new(er, RDXUI.DesktopAnchorFunction);
		dd_anchorType:SetWidth(150); dd_anchorType:Show();
		if desc and desc.anchor then 
			dd_anchorType:SetSelection(desc.anchor); 
		else
			dd_anchorType:SetSelection("TOPLEFT");
		end
		er:EmbedChild(dd_anchorType); er:Show();
		ui:InsertFrame(er);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Dock properties")));
		
		local chkCTS = VFLUI.Checkbox:new(ui); chkCTS:Show();
		chkCTS:SetText(i18n("Clamp to screen (only if undocked)"));
		if desc and desc.cts then chkCTS:SetChecked(true); else chkCTS:SetChecked(); end
		ui:InsertFrame(chkCTS);
		
		local chkNoAttach = VFLUI.Checkbox:new(ui); chkNoAttach:Show();
		chkNoAttach:SetText(i18n("Prevent this window from attaching to others"));
		if desc and desc.noattach then chkNoAttach:SetChecked(true); else chkNoAttach:SetChecked(); end
		ui:InsertFrame(chkNoAttach);
		
		local chkNoHold = VFLUI.Checkbox:new(ui); chkNoHold:Show();
		chkNoHold:SetText(i18n("Prevent other windows from attaching to this one"));
		if desc and desc.nohold then chkNoHold:SetChecked(true); else chkNoHold:SetChecked(); end
		ui:InsertFrame(chkNoHold);
		
		local n = 2; 
		if desk and desk.dock then n = #desk.dock + 1 end
		if desk and desk.dgp then n = n + 1 end
		local txtCurDock = VFLUI.SimpleText:new(ui, n, 200); txtCurDock:Show();
		local str = i18n("Current Docks:\n");
		if desc.dock then
			for k,v in pairs(desc.dock) do
				str = str .. k .. ": " .. v.id .. "\n";
			end
		else
			str = str .. "(none)\n";
		end
		if desc.dgp then str = str .. "This element is parent dock"; end
		
		txtCurDock:SetText(str);
		ui:InsertFrame(txtCurDock);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Position properties")));
		
		local ed_leftpos = VFLUI.LabeledEdit:new(ui, 50); ed_leftpos:Show();
		ed_leftpos:SetText(i18n("Left:"));
		if desc and desc.l then ed_leftpos.editBox:SetText(desc.l); end
		ui:InsertFrame(ed_leftpos);
		
		local ed_toppos = VFLUI.LabeledEdit:new(ui, 50); ed_toppos:Show();
		ed_toppos:SetText(i18n("Top:"));
		if desc and desc.t then ed_toppos.editBox:SetText(desc.t); end
		ui:InsertFrame(ed_toppos);
		
		local ed_rightpos = VFLUI.LabeledEdit:new(ui, 50); ed_rightpos:Show();
		ed_rightpos:SetText(i18n("Right:"));
		if desc and desc.r then ed_rightpos.editBox:SetText(desc.r); end
		ui:InsertFrame(ed_rightpos);
		
		local ed_bottompos = VFLUI.LabeledEdit:new(ui, 50); ed_bottompos:Show();
		ed_bottompos:SetText(i18n("Bottom:"));
		if desc and desc.b then ed_bottompos.editBox:SetText(desc.b); end
		ui:InsertFrame(ed_bottompos);
		
		function ui:GetDescriptor()
			local nname = ft;
			if ft == "desktop_window" or ft == "desktop_statuswindow" or ft == "desktop_windowless"  then
				nname = dd_windowId:GetSelection();
			end
			local ll = ed_leftpos.editBox:GetNumber();
			if ll == 0 then ll = nil; end
			local ddock, dgp = nil, nil;
			if chkopen:GetChecked() then
				ddock = desc.dock;
				ddgp = desc.dgp;
			end
			return {
				feature = ft;
				name = nname;
				open = chkopen:GetChecked();
				scale = VFL.clamp(ed_scale.editBox:GetNumber(), 0.1, 2);
				alpha = VFL.clamp(ed_alpha.editBox:GetNumber(), 0.1, 2);
				strata = dd_strataType:GetSelection();
				anchor = dd_anchorType:GetSelection();
				cts = chkCTS:GetChecked();
				noattach = chkNoAttach:GetChecked();
				nohold = chkNoHold:GetChecked();
				dock = ddock;
				dgp = ddgp;
				r = ed_rightpos.editBox:GetNumber();
				b = ed_bottompos.editBox:GetNumber();
				t = ed_toppos.editBox:GetNumber();
				l = ll
			};
		end
		
		return ui;
end

---------------------------------
-- Check
---------------------------------

-- Check to see if an object name is a valid name and is not previously taken on a state. 
-- Designed for use in ExposeFeature methods
function __DesktopCheck_Name(desc, state, errs)
	if desc and desc.name then
		if state:Slot(desc.name) then
			VFL.AddError(errs, i18n("Duplicate object name '") .. desc.name .. "'.");
			return nil;
		end
		state:AddSlot(desc.name);
		return true;
	else
		VFL.AddError(errs, i18n("Bad or missing object name."));
		return nil;
	end
end
