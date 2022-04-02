-- MenuBar.lua
-- OpenRDX
-- Sigg Rashgarroth EU

local function _EmitCreateCode(objname, desc)
	local createCode = [[
local btnOwner = ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
local micromenu = RDXUI.AcquireMicroMenu();
if micromenu then
	for i=1, #micromenu do
		VFLUI.StdSetParent(micromenu[i], btnOwner);
		micromenu[i]:SetFrameLevel(btnOwner:GetFrameLevel());
		micromenu[i]:Show();
	end
	micromenu[1]:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
	for i=2, #micromenu do ]];
		local opri1, opri2, osec1, osec2, csx, csy, csxm, csym = '"RIGHT"', '"LEFT"', '"TOP"', '"BOTTOM"', -tonumber(desc.iconspx), 0, 0, -tonumber(desc.iconspy);
		if desc.orientation == "RIGHT" then
			opri1 = '"LEFT"'; opri2 = '"RIGHT"'; csx = tonumber(desc.iconspx); csy = 0;
		elseif desc.orientation == "DOWN" then
			opri1 = '"TOP"'; opri2 = '"BOTTOM"'; osec1 = '"LEFT"'; osec2 = '"RIGHT"'; csx = 0; csy = -tonumber(desc.iconspy); csxm = tonumber(desc.iconspx); csym = 0;
		elseif desc.orientation == "UP" then
			opri1 = '"BOTTOM"'; opri2 = '"TOP"'; osec1 = '"LEFT"'; osec2 = '"RIGHT"'; csx = 0; csy = tonumber(desc.iconspy); csxm = tonumber(desc.iconspx); csym = 0;
		end
		createCode = createCode .. [[micromenu[i]:SetPoint(]] .. opri1 .. [[, micromenu[i-1], ]] .. opri2 .. [[, ]] .. csx .. [[, ]] .. csy .. [[);]];
		createCode = createCode .. [[
	end
	frame.micromenu = micromenu;
end
]];
	return createCode;
end

local _orientations = {
	{ text = "LEFT"},
	{ text = "RIGHT"},
	{ text = "DOWN"},
	{ text = "UP"},
};
local function _dd_orientations() return _orientations; end

RDX.RegisterFeature({
	name = "menubar"; version = 1; title = i18n("Menu Bar"); category = i18n("Bars");
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)

		------------------ On frame creation

		local createCode = _EmitCreateCode(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);
		
		------------------ On frame destruction.
		local destroyCode = [[
local micromenu = frame.micromenu;
if micromenu then
	RDXUI.ReleaseMicroMenu(micromenu);
end
frame.micromenu = nil;
]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		------------- Layout
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout")));
		
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local er = RDXUI.EmbedRight(ui, i18n("Orientation:"));
		local dd_orientation = VFLUI.Dropdown:new(er, _dd_orientations);
		dd_orientation:SetWidth(75); dd_orientation:Show();
		if desc and desc.orientation then 
			dd_orientation:SetSelection(desc.orientation); 
		else
			dd_orientation:SetSelection("RIGHT");
		end
		er:EmbedChild(dd_orientation); er:Show();
		ui:InsertFrame(er);
		
		local ed_iconspx = VFLUI.LabeledEdit:new(ui, 50); ed_iconspx:Show();
		ed_iconspx:SetText(i18n("Action Bar Buttons spacing width"));
		if desc and desc.iconspx then ed_iconspx.editBox:SetText(desc.iconspx); else ed_iconspx.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspx);
		
		local ed_iconspy = VFLUI.LabeledEdit:new(ui, 50); ed_iconspy:Show();
		ed_iconspy:SetText(i18n("Action Bar Buttons spacing height"));
		if desc and desc.iconspy then ed_iconspy.editBox:SetText(desc.iconspy); else ed_iconspy.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspy);
		
		function ui:GetDescriptor()
			return { 
				feature = "menubar"; version = 1;
				name = "mbar";
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				orientation = dd_orientation:GetSelection();
				iconspx = VFL.clamp(ed_iconspx.editBox:GetNumber(), -10, 200);
				iconspy = VFL.clamp(ed_iconspy.editBox:GetNumber(), -25, 200);
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "menubar"; version = 1; 
			name = "mbar"; owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			orientation = "RIGHT"; iconspx = -2; iconspy = 0;
		};
	end;
});

