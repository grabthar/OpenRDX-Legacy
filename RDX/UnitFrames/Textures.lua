-- Textures.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Textures for application on unitframes.

----------------------------------------------------------
-- A sub-frame for layering and aligning texture objects.
----------------------------------------------------------
RDX.RegisterFeature({
	name = "Subframe";
	category = i18n("Basics");
	multiple = true;
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
				feature = "Subframe";
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
		return { feature = "Subframe"; name = "subframe"; owner = "Base"; w = 90; h = 14; anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0}, flOffset = 0};
	end;
});

--------------------------------------------------------------
-- A Texture is an independent texture object on a unitframe.
--------------------------------------------------------------
RDX.RegisterFeature({
	name = "texture"; version = 1; title = i18n("Texture"); category = i18n("Textures");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFFrameCheck_Proto("Texture_", desc, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Texture_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = RDXUI.ResolveTextureReference(desc.name);

		------------------ On frame creation
		local createCode = [[
local _t = VFLUI.CreateTexture(]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
_t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
_t:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
_t:SetWidth(]] .. desc.w .. [[); _t:SetHeight(]] .. desc.h .. [[);
_t:Show();
]] .. objname .. [[ = _t;
]];
		createCode = createCode .. VFLUI.GenerateSetTextureCode("_t", desc.texture);
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

		------------------ On frame destruction.
		local destroyCode = [[
]] .. objname .. [[:Destroy();
]] .. objname .. [[ = nil;
]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		if (desc.cleanupPolicy == 2) then
			state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
]] .. objname .. [[:Hide();
]]); end);
		elseif (desc.cleanupPolicy == 3) then
			state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
]] .. objname .. [[:Show();
]]); end);
		end

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

		-- Cleanup policy
		local cleanupPolicy = VFLUI.RadioGroup:new(ui);
		cleanupPolicy:SetLayout(3,3);
		cleanupPolicy.buttons[1]:SetText(i18n("No cleanup"));
		cleanupPolicy.buttons[2]:SetText(i18n("Hide on clean"));
		cleanupPolicy.buttons[3]:SetText(i18n("Show on clean"));
		if desc and desc.cleanupPolicy then
			cleanupPolicy:SetValue(desc.cleanupPolicy);
		else
			cleanupPolicy:SetValue(2);
		end
		ui:InsertFrame(cleanupPolicy);

		-- Texture
		local er = RDXUI.EmbedRight(ui, i18n("Texture"));
		local tsel = VFLUI.MakeTextureSelectButton(er, desc.texture); tsel:Show();
		er:EmbedChild(tsel); er:Show();
		ui:InsertFrame(er);
		
		function ui:GetDescriptor()
			return { 
				feature = "texture"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				drawLayer = drawLayer:GetSelection();
				texture = tsel:GetSelectedTexture();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				cleanupPolicy = cleanupPolicy:GetValue();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "texture"; version = 1; 
			name = "tex1", owner = "Base", drawLayer = "ARTWORK";
			texture = VFL.copy(VFLUI.defaultTexture);
		  w = 90; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			cleanupPolicy = 2;
		};
	end;
});

-- Update old textures
RDX.RegisterFeature({
	name = "Texture"; version = 31337; invisible = true;
	IsPossible = VFL.Nil;
	VersionMismatch = function(desc)
		desc.feature = "texture"; desc.version = 1;
		if desc.texture then
			local f = string.gsub(desc.texture, "\\\\", "\\"); -- replace double backslashes
			desc.texture = { path = f; blendMode = "BLEND"; };
		else
			desc.texture = { color = desc.texColor; blendMode = "BLEND"; };
		end
		desc.texColor = nil;
		return true;
	end;
});

