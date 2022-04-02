-- BasicAFFeatures.lua
-- OpenRDX
-- Sigg Rashgarroth EU

------------------ BASEFRAME
RDX.RegisterFeature({
	name = "artbase_default"; version = 1; title = i18n("Base Frame"); category = i18n("Basics");
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("EmitCreate") then return nil; end
		if not state:Slot("EmitDestroy") then return nil; end
		if state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if (not desc) or (not desc.w) or (not desc.h) then
			VFL.AddError(errs, i18n("Bad or missing width/height parameters."));
			return nil;
		end
		if (not desc.alpha) or (desc.alpha < 0.05) then
			desc.alpha = 1;
		end
		state:AddSlot("Base");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local alpha = desc.alpha or 1;
		local dx,dy = desc.w, desc.h;
		local createCode = [[
frame:SetWidth(]] .. dx .. [[); frame:SetHeight(]] .. dy .. [[);
frame:SetAlpha(]] .. alpha .. [[);
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:AddSlot("FrameDimensions");
		state:Attach(state:Slot("FrameDimensions"), nil, function() return dx,dy; end);
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		local ed_width, ed_height = RDXUI.GenWidthHeightPortion(ui, desc, state);

		local ed_alpha = VFLUI.LabeledEdit:new(ui, 50); ed_alpha:Show();
		ed_alpha:SetText(i18n("Base alpha"));
		if desc and desc.alpha then ed_alpha.editBox:SetText(desc.alpha); end
		ui:InsertFrame(ed_alpha);

		function ui:GetDescriptor()
			local a = ed_alpha.editBox:GetNumber(); if not a then a = 1; end
			a = VFL.clamp(a, 0, 1);
			return { 
				feature = "artbase_default"; 
				version = 1; 
				alpha = a;
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "artbase_default"; version = 1;
			w = 90, h = 14, alpha = 1;
		};
	end;
});

----------------------------------------------------------
-- A sub-frame for layering and aligning texture objects.
----------------------------------------------------------
RDX.RegisterFeature({
	name = "artSubframe";
	title = i18n("Subframe");
	category = i18n("Basics");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then 
			state:AddSlot("Subframe_" .. desc.name);
			state:AddSlot("Frame_" .. desc.name);
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local createCode = [[
local _f = VFLUI.AcquireFrame("Frame");
_f:SetParent(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
_f:SetFrameLevel(frame:GetFrameLevel() + (]] .. desc.flOffset .. [[));
_f:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_f:SetWidth(]] .. desc.w .. [[); _f:SetHeight(]] .. desc.h .. [[);
_f:Show();
frame.]] .. objname .. [[ = _f;
]];
		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[=nil;
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

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
				feature = "artSubframe";
				owner = owner:GetSelection();
				name = ed_name.editBox:GetText();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				flOffset = a; 
				anchor = anchor:GetAnchorInfo();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "artSubframe"; name = "subframe"; owner = "Base"; w = 90; h = 14; anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0}, flOffset = 0};
	end;
});

