-- Minimap.lua
-- OpenRDX
-- Sigg Rashgarroth EU

RDX.RegisterFeature({
	name = "button_a"; version = 1; title = i18n("Button Function"); category = i18n("Basics");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		-- Verify our owner frame exists
		if (not desc.owner) or ((desc.owner ~= "Base") and (not state:Slot("Subframe_" .. desc.owner))) then
			VFL.AddError(errs, i18n("Owner frame does not exist.")); return nil;
		end
		local flg = true;
		--flg = flg and __UFFrameCheck_Proto("Tex_", desc, state, errs);
		--flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		--flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		--if flg then state:AddSlot("Tex_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Button_" .. desc.name;

		------------------ On frame creation
		local createCode = [[
local btn_a = VFLUI.AcquireFrame("Button");
VFLUI.StdSetParent(btn_a, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[, ]] .. desc.flOffset .. [[);
frame.]] .. objname .. [[ = btn_a;
btn_a:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
btn_a:SetWidth(]] .. desc.w .. [[); btn_a:SetHeight(]] .. desc.h .. [[);
btn_a:SetNormalTexture("Interface\\WorldMap\\UI-World-Icon");
btn_a:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");
btn_a:SetScript("OnClick", function() ToggleWorldMap(); end);
btn_a:Show();
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

		------------------ On frame destruction.
		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Anchor
		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_flOffset = VFLUI.LabeledEdit:new(ui, 50); ed_flOffset:Show();
		ed_flOffset:SetText(i18n("FrameLevel offset"));
		if desc and desc.flOffset then ed_flOffset.editBox:SetText(desc.flOffset); end
		ui:InsertFrame(ed_flOffset);
		
		function ui:GetDescriptor()
			local a = ed_flOffset.editBox:GetNumber(); if not a then a=0; end a = VFL.clamp(a, -2, 5);
			return { 
				feature = "button_a"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				flOffset = a;
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "button_a"; version = 1; 
			name = "but1", owner = "Base";
			w = 20; h = 20;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			flOffset = 0;
		};
	end;
});

