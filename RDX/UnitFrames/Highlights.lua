-- Highlights.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics LLC
--
-- THIS FILE CONTAINS CONTENT PROTECTED BY COPYRIGHT LAW AND INTERNATIONAL TREATY PROVISIONS.
-- DISTRIBUTION AND USE ARE BY THE TERMS OF A SEPARATE LICENSE.
--
-- Code for highlights on unitframes.

------------------------------ The highlight feature.
RDX.RegisterFeature({
	name = "Highlight";
	category = i18n("Oldschool Unitframes");
	deprecated = true;
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		local flg = __UFObjCheck(desc, state, errs);
		if desc and desc.set then
			local si = RDX.FindSet(desc.set);
			if not si then
				VFL.AddError(errs, i18n("Invalid set pointer."));
				flg = nil;
			end
		else
			VFL.AddError(errs, i18n("Missing set definition."));
			flg = nil;
		end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Obj_" .. desc.name;
		local createCode, destroyCode, cleanupCode, paintCode = "", "", "", "";

		-- Attach the parent window's Hide/Show to the set's Open/Close refcount incrementers.
		local si = RDX.FindSet(desc.set);
		if not si then return; end
		-- Event hint: on set delta, repaint all delta'd frames.
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_SetDeltaMask(si, 2); -- 2 = non-specific repaint mask
		
		-------------- Hlt texture
		-- Only create the texture if we aren't using alpha highlighting
		if not desc.ah then
			-- Only create the texture once.
			if not state:Slot("HighlightTexture") then
				state:AddSlot("HighlightTexture");
				createCode = createCode .. [[
local _tex = VFLUI.CreateTexture(frame);
_tex:SetDrawLayer("OVERLAY");
_tex:SetAllPoints(frame); _tex:Hide();
_tex:SetTexture(1,1,1,0.3);
frame._highlight = _tex;
]];
				destroyCode = destroyCode .. [[
VFLUI.ReleaseRegion(frame._highlight); frame._highlight = nil;
]];
				cleanupCode = cleanupCode .. [[
frame._highlight:Hide();
]];
			end

			paintCode = [[
if ]] .. objname .. [[_set:IsMember(unit) then 
	frame._highlight:Show(); 
	frame._highlight:SetVertexColor(]] .. desc.hltColor.r .. [[,]] .. desc.hltColor.g .. [[,]] .. desc.hltColor.b .. [[);
end
]];
		else -- Alpha highlight
			paintCode = [[
if ]] .. objname .. [[_set:IsMember(unit) then 
	frame:SetAlpha(]] .. desc.ah .. [[);
end
]];	
		end
	
		------------- Set closure
		local closureCode = [[
local ]] .. objname .. [[_set = RDX.FindSet(]] .. Serialize(desc.set) .. [[);
]];
		
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode(cleanupCode); end);
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		state:Attach(state:Slot("EmitClosure"), true, function(code) code:AppendCode(closureCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_name = VFLUI.LabeledEdit:new(ui, 100); ed_name:Show();
		ed_name:SetText(i18n("Name"));
		ed_name.editBox:SetText(desc.name);
		ui:InsertFrame(ed_name);

		local sf = RDX.SetFinder:new(ui); sf:Show();
		if desc and desc.set then sf:SetDescriptor(desc.set); end
		ui:InsertFrame(sf);

		local er = RDXUI.EmbedRight(ui, i18n("Highlight Color:"));
		local swatch_hltc = VFLUI.ColorSwatch:new(er);
		swatch_hltc:Show();
		if desc and desc.hltColor then swatch_hltc:SetColor(explodeColor(desc.hltColor)); end
		er:EmbedChild(swatch_hltc); er:Show();
		ui:InsertFrame(er);

		local chk_ah = VFLUI.Checkbox:new(ui); chk_ah:Show();
		chk_ah:SetText(i18n("Use alpha-value highlighting"));
		local ed_alpha = VFLUI.Edit:new(chk_ah); ed_alpha:SetWidth(50); ed_alpha:SetHeight(25);
		ed_alpha:SetPoint("RIGHT", chk_ah, "RIGHT"); ed_alpha:Show();
		if desc and desc.ah then 
			chk_ah:SetChecked(true);
			ed_alpha:SetText(desc.ah);
		else 
			chk_ah:SetChecked(); 
			ed_alpha:SetText("0.5");
		end
		ui:InsertFrame(chk_ah);
		
		function ui:GetDescriptor()
			local alpha = VFL.clamp(ed_alpha:GetNumber(), 0, 1);
			if not chk_ah:GetChecked() then alpha = nil; end
			return { feature = "Highlight", name = ed_name.editBox:GetText(),
				set = sf:GetDescriptor(), hltColor = swatch_hltc:GetColor(), ah = alpha };
		end

		ui.Destroy = VFL.hook(function() ed_alpha:Destroy(); end, ui.Destroy);
		
		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "Highlight", name = "hlt", hltColor = {r=1, g=1, b=0} };
	end;
});

---------------------------------------------------------------------------------
-- Graded highlight.
--
-- Show the given texture and grade its vertex color based on the underlying
-- unit's position in the given Sort.
---------------------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Highlight: Texture Map";
	category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDXUI.IsValidBoolVar(desc.flag, state) then
			VFL.AddError(errs, i18n("Invalid flag variable.")); return nil;
		end
		-- Verify our texture
		if (not desc.texture) or (not state:Slot("Texture_" .. desc.texture)) then
			VFL.AddError(errs, i18n("Invalid texture object pointer.")); return nil;
		end
		if (not desc.color) or (not state:Slot("ColorVar_" .. desc.color)) then
			VFL.AddError(errs, i18n("Invalid color variable.")); return nil;
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		local tname = RDXUI.ResolveTextureReference(desc.texture);
		local paintCode = [[
if ]] .. desc.flag .. [[ then
	]] .. tname .. [[:Show();
	]] .. tname .. [[:SetVertexColor(explodeRGBA(]] .. desc.color .. [[));
end
]];
		-- If there's not already a highlight preamble for this texture, add it.
		if not state:Slot("__Hlt_Preamble_" .. desc.texture) then
			state:AddSlot("__Hlt_Preamble_" .. desc.texture);
			state:Attach("EmitPaintPreamble", true, function(code) code:AppendCode([[
]] .. tname .. [[:Hide();
]]);
			end);
		end
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local flag = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Show condition variable"), state, "BoolVar_", nil, "true", "false");
		if desc and desc.flag then flag:SetSelection(desc.flag); end

		local texture = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Texture"), state, "Texture_");
		if desc and desc.texture then texture:SetSelection(desc.texture); end
		
		local color = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Color variable"), state, "ColorVar_");
		if desc and desc.color then color:SetSelection(desc.color); end
		
		function ui:GetDescriptor()
			return {
				feature = "Highlight: Texture Map";
				flag = flag:GetSelection();
				texture = texture:GetSelection(); 
				color = color:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "Highlight: Texture Map";
			flag = "true";
		};
	end;
});

-----------------------------------------------------------
-- Alpha shaders
-----------------------------------------------------------
RDX.RegisterFeature({
	name = "shader_ca"; version = 1;
	title = i18n("Conditional Alpha Shader"); category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDXUI.IsValidBoolVar(desc.flag, state) then
			VFL.AddError(errs, i18n("Invalid flag variable.")); return nil;
		end
		if (not tonumber(desc.falseAlpha)) or (not tonumber(desc.trueAlpha)) then
			VFL.AddError(errs, i18n("Invalid alpha values.")); return nil;
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		local fname = RDXUI.ResolveFrameReference(desc.owner);
		local paintCode = [[
if ]] .. desc.flag .. [[ then
	]] .. fname .. [[:SetAlpha(]] .. desc.trueAlpha .. [[);
else
	]] .. fname .. [[:SetAlpha(]] .. desc.falseAlpha .. [[);
end
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Target subframe"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local flag = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Condition variable"), state, "BoolVar_", nil, "true", "false");
		if desc and desc.flag then flag:SetSelection(desc.flag); end

		local falseAlpha = VFLUI.LabeledEdit:new(ui, 50); falseAlpha:Show();
		falseAlpha:SetText(i18n("Alpha when false"));
		if desc and desc.falseAlpha then falseAlpha.editBox:SetText(desc.falseAlpha); end
		ui:InsertFrame(falseAlpha);

		local trueAlpha = VFLUI.LabeledEdit:new(ui, 50); trueAlpha:Show();
		trueAlpha:SetText(i18n("Alpha when true"));
		if desc and desc.trueAlpha then trueAlpha.editBox:SetText(desc.trueAlpha); end
		ui:InsertFrame(trueAlpha);
		
		function ui:GetDescriptor()
			local fa, ta = VFL.clamp(falseAlpha.editBox:GetNumber(), 0, 1), VFL.clamp(trueAlpha.editBox:GetNumber(), 0, 1);
			return {
				feature = "shader_ca"; version = 1;
				owner = owner:GetSelection();
				flag = flag:GetSelection();
				falseAlpha = fa; trueAlpha = ta;
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "shader_ca"; version = 1;
			owner = "Base";
			flag = "true"; falseAlpha = 1; trueAlpha = 1;
		};
	end;
});

-- Update old CAS
RDX.RegisterFeature({
	name = "Conditional Alpha Shader"; version = 31337; invisible = true;
	IsPossible = VFL.Nil;
	VersionMismatch = function(desc)
		desc.feature = "shader_ca"; desc.version = 1; desc.owner = "Base";
	end;
});
