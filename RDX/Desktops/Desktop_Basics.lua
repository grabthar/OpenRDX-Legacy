-- Desktop_Basics.lua
-- OpenRDX
--
-- Main feature for Desktop objects.
--

RDX.RegisterFeature({
	name = "Desktop main",
	title = i18n("Desktop");
	category = i18n("Basics");
	IsPossible = function(state)
		if not state:Slot("Desktop") then return nil; end
		if state:Slot("Desktop main") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if not desc then return nil; end
		if not desc.title then
			VFL.AddError(errs, i18n("Missing field"));
			return nil;
		end
		state:AddSlot("Desktop main");
		return true;
	end;
	ApplyFeature = function(desc, state)
		--local category = desc.category;	if not category then category = ""; end
		--category = strtrim(category);
		--if category == "" then category = pkgName; end
		local nobuf, nobaf, nobcb, nomap, nobmf, hcf = "false", "false", "false", "false", "false", "false";
		if desc.nobuf then nobuf = "true" end;
		if desc.nobaf then nobaf = "true" end;
		if desc.nobcb then nobcb = "true" end;
		if desc.nomap then nomap = "true" end;
		if desc.nobmf then nobmf = "true" end;
		if desc.hcf then hcf = "true" end;
		state.Code:Clear();
		state.Code:AppendCode([[
local encid = "dk_openrdx7";

-- Clear any old binds
WoWEvents:Unbind(encid);
RDXEvents:Unbind(encid);
DesktopEvents:Unbind(encid);

--DesktopEvents:Bind("DESKTOP_ACTIVATE", nil, function()
--	WoWEvents:Unbind(encid);
--	RDXEvents:Unbind(encid);
--	DesktopEvents:Unbind(encid);
--end, encid);

DesktopEvents:Bind("DESKTOP_DEACTIVATE", nil, function()
	WoWEvents:Unbind(encid);
	RDXEvents:Unbind(encid);
	DesktopEvents:Unbind(encid);
end, encid);

DesktopEvents:Bind("DESKTOP_OPEN", nil, function(_, _, id)
	if not id then
		if not RDX.IsFullDisableBlizzard() then
			if ]] .. nobuf .. [[ then RDXDK.HideBlizzardUnitframes(); end
			if ]] .. nobaf .. [[ then RDXDK.HideBlizzardAuraFrame(); end
			if ]] .. nobcb .. [[ then RDXDK.HideBlizzardCastBar(); end
			if ]] .. nomap .. [[ then RDXDK.HideBlizzardMinimap(); end
			if ]] .. nobmf .. [[ then RDXDK.HideBlizzardMainFrame(); end
		end
		if ]] .. hcf .. [[ then RDXDK.SetHighStrataChatFrame(); end
	end
end, encid);

DesktopEvents:Bind("DESKTOP_CLOSE", nil, function(_, _, id)
	if not id then
		if not RDX.IsFullDisableBlizzard() then
			if ]] .. nobuf .. [[ then RDXDK.ShowBlizzardUnitframes(); end
			if ]] .. nobaf .. [[ then RDXDK.ShowBlizzardAuraFrame(); end
			if ]] .. nobcb .. [[ then RDXDK.ShowBlizzardCastBar(); end
			if ]] .. nobaf .. [[ then RDXDK.ShowBlizzardMinimap(); end
			if ]] .. nobmf .. [[ then RDXDK.ShowBlizzardMainFrame(); end
		end
		if ]] .. hcf .. [[ then RDXDK.SetBCKStrataChatFrame(); end
	end
end, encid);

local function CreateElement(framep, name, create, id)
	if (name == id) then 
		framep.open = true;
		RDXDK._SaveFrameProps(false, framep)
	end
	if framep.open then
		local frame = create(name);
		if frame then
			RDXDK.ImbueManagedFrame(frame, name);
			return frame;
		else
			RDX.printE(i18n("Could not open window ") .. name);
		end
	end
	return nil;
end

local function DeleteElement(frame, framep, name, delete, id)
	if (name == id) then 
		framep.open = nil;
		RDXDK.ResetDockGroupLayout(frame);
		RDXDK.CompletelyUndock(framep);
		RDXDK.LayoutAll();
		RDXDK._SaveFrameProps(false, framep);
	end
	if ((not framep.open) or (id == nil)) and frame then
		--RDXDK.CompletelyUndock(framep);
		if frame.tfmanuel then RDXDK.UnimbueOverlay(frame); end
		RDXDK.UnimbueManagedFrame(frame);
		delete(name, frame);
		return true;
	end
	return nil;
end

		]]);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);

		local title = VFLUI.LabeledEdit:new(ui, 200); title:Show();
		title:SetText(i18n("Desktop Title"));
		if desc and desc.title then title.editBox:SetText(desc.title); end
		ui:InsertFrame(title);
		
		local er = RDXUI.EmbedRight(ui, i18n("Resolution:"));
		local dd_resolution = VFLUI.Dropdown:new(er, VFLUI.ResolutionsDropdownFunction);
		dd_resolution:SetWidth(200); dd_resolution:Show();
		if desc and desc.resolution then 
			dd_resolution:SetSelection(desc.resolution); 
		else
			dd_resolution:SetSelection("1024x768");
		end
		er:EmbedChild(dd_resolution); er:Show();
		ui:InsertFrame(er);
		
		local uiscale = VFLUI.LabeledEdit:new(ui, 200); uiscale:Show();
		uiscale:SetText(i18n("UI Scale"));
		if desc and desc.uiscale then uiscale.editBox:SetText(desc.uiscale); end
		ui:InsertFrame(uiscale);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Blizzard UI")));
		
		local chkunitframe = VFLUI.Checkbox:new(ui); chkunitframe:Show();
		chkunitframe:SetText(i18n("Hide UnitFrames Blizzard"));
		if desc and desc.nobuf then chkunitframe:SetChecked(true); else chkunitframe:SetChecked(); end
		ui:InsertFrame(chkunitframe);
		
		local chkauraframe = VFLUI.Checkbox:new(ui); chkauraframe:Show();
		chkauraframe:SetText(i18n("Hide AuraFrames Blizzard"));
		if desc and desc.nobaf then chkauraframe:SetChecked(true); else chkauraframe:SetChecked(); end
		ui:InsertFrame(chkauraframe);
		
		local chkcastbar = VFLUI.Checkbox:new(ui); chkcastbar:Show();
		chkcastbar:SetText(i18n("Hide CastBars Blizzard"));
		if desc and desc.nobcb then chkcastbar:SetChecked(true); else chkcastbar:SetChecked(); end
		ui:InsertFrame(chkcastbar);
		
		local chkminimap = VFLUI.Checkbox:new(ui); chkminimap:Show();
		chkminimap:SetText(i18n("Hide Minimap Blizzard"));
		if desc and desc.nomap then chkminimap:SetChecked(true); else chkminimap:SetChecked(); end
		ui:InsertFrame(chkminimap);
		
		local chkmainframe = VFLUI.Checkbox:new(ui); chkmainframe:Show();
		chkmainframe:SetText(i18n("Hide Main Frame Blizzard"));
		if desc and desc.nobmf then chkmainframe:SetChecked(true); else chkmainframe:SetChecked(); end
		ui:InsertFrame(chkmainframe);
		
		local chkchatframe = VFLUI.Checkbox:new(ui); chkchatframe:Show();
		chkchatframe:SetText(i18n("Level up strata of Chat Frame"));
		if desc and desc.hcf then chkchatframe:SetChecked(true); else chkchatframe:SetChecked(); end
		ui:InsertFrame(chkchatframe);

		function ui:GetDescriptor()
			return {
				feature = "Desktop main"; 
				title = title.editBox:GetText();
				resolution = VFLUI.GetCurrentResolution();
				uiscale = VFLUI.GetCurrentEffectiveScale();
				nobuf = chkunitframe:GetChecked();
				nobaf = chkauraframe:GetChecked();
				nobcb = chkcastbar:GetChecked();
				nomap = chkminimap:GetChecked();
				nobmf = chkmainframe:GetChecked();
				hcf = chkchatframe:GetChecked();
			};
		end

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Desktop main", resolution = VFLUI.GetCurrentResolution(), uiscale = VFLUI.GetCurrentEffectiveScale()}; end
});

