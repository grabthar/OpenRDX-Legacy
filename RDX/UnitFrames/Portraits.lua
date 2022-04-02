-- Portraits.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Support for portraits on unit frames.

-- Modify by Joeba18

-- Global function to set a model to camera zero
function SetCameraZero(self) self:SetCamera(0); end
function SetCameraOne(self) self:SetCamera(1); end

local _types = {
	{ text = "SetCameraZero" },
	{ text = "SetCameraOne" },
};
local function _dd_cameratypes() return _types; end

----------- 2D Portrait
RDX.RegisterFeature({
	name = "portrait_2d"; version = 1; multiple = true;
	title = i18n("2D Portrait Shader"); category = i18n("Portraits");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		-- Verify our texture
		if (not desc.texture) or (not state:Slot("Tex_" .. desc.texture)) then
			VFL.AddError(errs, i18n("Invalid texture object pointer.")); return nil;
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Tex_" .. desc.texture;

		-- Event hinting.
		local mux, mask = state:GetContainingWindowState():GetSlotValue("Multiplexer"), 0;
		mask = mux:GetPaintMask("PORTRAIT");
		mux:Event_UnitMask("UNIT_PORTRAIT_UPDATE", mask);
		mask = bit.bor(mask, 1);

		-- Painting
		local paintCode = [[
if band(paintmask, ]] .. mask .. [[) ~= 0 then
	SetPortraitTexture(frame.]] .. objname .. [[, uid);
end
]];
		state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local texture = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Apply portrait to texture"), state, "Texture_");
		if desc and desc.texture then texture:SetSelection(desc.texture); end

		function ui:GetDescriptor()
			return { 
				feature = "portrait_2d"; version = 1;
				texture = texture:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "portrait_2d"; version = 1; 
		};
	end;
});

----------- 3D Portrait object
RDX.RegisterFeature({
	name = "portrait_3d"; version = 1; multiple = true;
	title = i18n("3D Portrait"); category = i18n("Portraits");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then 
			state:AddSlot("Frame_" .. desc.name);
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local camera = "SetCameraZero";
		if desc and desc.cameraType then camera = desc.cameraType; end

		-- Creation/destruction
		local createCode = [[
local _f = VFLUI.AcquireFrame("PlayerModel");
VFLUI.StdSetParent(_f, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[, ]] .. desc.flOffset .. [[);
_f:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_f:SetWidth(]] .. desc.w .. [[); _f:SetHeight(]] .. desc.h .. [[);
_f:Show();
_f:SetScript("OnShow", ]].. camera ..[[);
frame.]] .. objname .. [[ = _f;
]];
		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[=nil;
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		-- Event hinting.
		local mux, mask = state:GetContainingWindowState():GetSlotValue("Multiplexer"), 0;
		mask = mux:GetPaintMask("PORTRAIT");
		mux:Event_UnitMask("UNIT_PORTRAIT_UPDATE", mask);
		mask = bit.bor(mask, 1);

		-- Painting
		local paintCode = [[
if band(paintmask, ]] .. mask .. [[) ~= 0 then
	frame.]] .. objname .. [[:SetUnit(uid);
	]].. camera ..[[(frame.]] .. objname .. [[);
end
if UnitIsVisible(uid) then 
	frame.]] .. objname .. [[:Show();
else
	frame.]] .. objname .. [[:Hide();
end
]];
		state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_flOffset = VFLUI.LabeledEdit:new(ui, 50); ed_flOffset:Show();
		ed_flOffset:SetText(i18n("FrameLevel offset"));
		if desc and desc.flOffset then ed_flOffset.editBox:SetText(desc.flOffset); end
		ui:InsertFrame(ed_flOffset);
		
		local er = RDXUI.EmbedRight(ui, i18n("Camera Type:"));
		local dd_cameraType = VFLUI.Dropdown:new(er, _dd_cameratypes);
		dd_cameraType:SetWidth(200); dd_cameraType:Show();
		if desc and desc.cameraType then 
			dd_cameraType:SetSelection(desc.cameraType); 
		else
			dd_cameraType:SetSelection("SetCameraZero");
		end
		er:EmbedChild(dd_cameraType); er:Show();
		ui:InsertFrame(er);

		function ui:GetDescriptor()
			local a = ed_flOffset.editBox:GetNumber(); if not a then a=0; end a = VFL.clamp(a, -2, 5);
			return { 
				feature = "portrait_3d"; version = 1;
				name = ed_name.editBox:GetText();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				flOffset = a;
				cameraType = dd_cameraType:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "portrait_3d"; version = 1; 
			name = "portrait3d";
			w = 30; h = 30; 
			anchor = {lp = "RIGHT", af = "Base", rp = "LEFT", dx = 0, dy = 0}; 
			flOffset = 0;
		};
	end;
});
