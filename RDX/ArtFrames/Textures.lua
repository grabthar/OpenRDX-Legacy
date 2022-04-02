-- Textures.lua
-- OpenRDX
-- Sigg Rashgarroth EU

RDX.RegisterFeature({
	name = "arttexture"; version = 1; title = i18n("Texture"); category = i18n("Basics");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Texture_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Texture_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Texture_" .. desc.name;

		------------------ On frame creation
		local createCode = [[
local _t = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
frame.]] .. objname .. [[ = _t;
_t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_t:SetWidth(]] .. desc.w .. [[); _t:SetHeight(]] .. desc.h .. [[);
_t:Show();
]];
		createCode = createCode .. VFLUI.GenerateSetTextureCode("_t", desc.texture);
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

		-- Drawlayer
		local er = RDXUI.EmbedRight(ui, i18n("Draw layer:"));
		local drawLayer = VFLUI.Dropdown:new(er, RDXUI.DrawLayerDropdownFunction);
		drawLayer:SetWidth(100); drawLayer:Show();
		if desc and desc.drawLayer then drawLayer:SetSelection(desc.drawLayer); else drawLayer:SetSelection("ARTWORK"); end
		er:EmbedChild(drawLayer); er:Show();
		ui:InsertFrame(er);

		-- Texture
		local er = RDXUI.EmbedRight(ui, i18n("Texture"));
		local tsel = VFLUI.MakeTextureSelectButton(er, desc.texture); tsel:Show();
		er:EmbedChild(tsel); er:Show();
		ui:InsertFrame(er);
		
		function ui:GetDescriptor()
			return { 
				feature = "arttexture"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				drawLayer = drawLayer:GetSelection();
				texture = tsel:GetSelectedTexture();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "arttexture"; version = 1; 
			name = "tex1", owner = "Base", drawLayer = "ARTWORK";
			texture = VFL.copy(VFLUI.defaultTexture);
			w = 90; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
		};
	end;
});

