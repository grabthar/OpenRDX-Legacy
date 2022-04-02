-- OpenRDX
-- Sigg / Rashgarroth EU
--

-----------------------------------
-- The ButtonSkin object type.
-----------------------------------
local dlg = nil;

local function updateInst(inst, desc)
	VFL.empty(inst);
	for k,v in pairs(desc) do
		inst[k] = v; 
	end
end

RDXDB.RegisterObjectType({
	name = "ButtonSkin";
	New = function(path, md)
		md.version = 1;
	end;
	Edit = function(path, md, parent)
		if dlg then return; end
		if (not path) or (not md) or (not md.data) then return nil; end
		local inst = RDXDB.GetObjectInstance(path, true);
		local desc = VFL.copy(md.data);

		dlg = VFLUI.Window:new(parent or VFLHigh);
		VFLUI.Window.SetDefaultFraming(dlg, 22);
		dlg:SetTitleColor(0,0,.6);
		dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
		dlg:SetPoint("CENTER", UIParent, "CENTER");
		dlg:SetWidth(550); dlg:SetHeight(350);
		dlg:SetText(i18n("Edit ButtonSkin: ") .. path);
		VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
		dlg:Show();
		
		local txtbkd = VFLUI.CreateFontString(dlg);
		txtbkd:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
		txtbkd:SetWidth(80); txtbkd:SetHeight(24);
		txtbkd:SetJustifyH("LEFT"); txtbkd:SetJustifyV("CENTER");
		txtbkd:SetFontObject(Fonts.Default10);
		txtbkd:Show(); txtbkd:SetText("Backdrop Texture");
	
		local backdrop = VFLUI.MakeTextureSelectButton(dlg, desc.backdrop); 
		backdrop:SetPoint("TOPLEFT", txtbkd, "TOPRIGHT");
		backdrop:Show();
		
		local dd_backdrop = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_backdrop:SetPoint("TOPRIGHT", backdrop, "BOTTOMRIGHT");
		dd_backdrop:SetWidth(130); dd_backdrop:Show();
		if desc.dd_backdrop then 
			dd_backdrop:SetSelection(desc.dd_backdrop); 
		else
			dd_backdrop:SetSelection("BACKGROUND");
		end
		
		local txtbor = VFLUI.CreateFontString(dlg);
		txtbor:SetPoint("TOPLEFT", txtbkd, "BOTTOMLEFT", 0, -30);
		txtbor:SetWidth(80); txtbor:SetHeight(24);
		txtbor:SetJustifyH("LEFT"); txtbor:SetJustifyV("CENTER");
		txtbor:SetFontObject(Fonts.Default10);
		txtbor:Show(); txtbor:SetText("Border texture");
		
		local border = VFLUI.MakeTextureSelectButton(dlg, desc.border); 
		border:SetPoint("TOPLEFT", txtbor, "TOPRIGHT");
		border:Show();
		
		local dd_border = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_border:SetPoint("TOPRIGHT", border, "BOTTOMRIGHT");
		dd_border:SetWidth(130); dd_border:Show();
		if desc.dd_border then 
			dd_border:SetSelection(desc.dd_border); 
		else
			dd_border:SetSelection("OVERLAY");
		end
		
		local txtflash = VFLUI.CreateFontString(dlg);
		txtflash:SetPoint("TOPLEFT", txtbor, "BOTTOMLEFT", 0, -30);
		txtflash:SetWidth(80); txtflash:SetHeight(24);
		txtflash:SetJustifyH("LEFT"); txtflash:SetJustifyV("CENTER");
		txtflash:SetFontObject(Fonts.Default10);
		txtflash:Show(); txtflash:SetText("Flash Texture");
		
		local flash = VFLUI.MakeTextureSelectButton(dlg, desc.flash); 
		flash:SetPoint("TOPLEFT", txtflash, "TOPRIGHT");
		flash:Show();
		
		local dd_flash = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_flash:SetPoint("TOPRIGHT", flash, "BOTTOMRIGHT");
		dd_flash:SetWidth(130); dd_flash:Show();
		if desc.dd_flash then 
			dd_flash:SetSelection(desc.dd_flash); 
		else
			dd_flash:SetSelection("OVERLAY");
		end
		
		local txtnormal = VFLUI.CreateFontString(dlg);
		txtnormal:SetPoint("TOPLEFT", txtflash, "BOTTOMLEFT", 0, -30);
		txtnormal:SetWidth(80); txtnormal:SetHeight(24);
		txtnormal:SetJustifyH("LEFT"); txtnormal:SetJustifyV("CENTER");
		txtnormal:SetFontObject(Fonts.Default10);
		txtnormal:Show(); txtnormal:SetText("Normal Texture");
		
		local normal = VFLUI.MakeTextureSelectButton(dlg, desc.normal); 
		normal:SetPoint("TOPLEFT", txtnormal, "TOPRIGHT");
		normal:Show();
		
		local dd_normal = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_normal:SetPoint("TOPRIGHT", normal, "BOTTOMRIGHT");
		dd_normal:SetWidth(130); dd_normal:Show();
		if desc.dd_normal then 
			dd_normal:SetSelection(desc.dd_normal); 
		else
			dd_normal:SetSelection("BORDER");
		end
		
		local txtpushed = VFLUI.CreateFontString(dlg);
		txtpushed:SetPoint("TOPLEFT", txtnormal, "BOTTOMLEFT", 0, -30);
		txtpushed:SetWidth(80); txtpushed:SetHeight(24);
		txtpushed:SetJustifyH("LEFT"); txtpushed:SetJustifyV("CENTER");
		txtpushed:SetFontObject(Fonts.Default10);
		txtpushed:Show(); txtpushed:SetText("Pushed Texture");
		
		local pushed = VFLUI.MakeTextureSelectButton(dlg, desc.pushed); 
		pushed:SetPoint("TOPLEFT", txtpushed, "TOPRIGHT");
		pushed:Show();
		
		local dd_pushed = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_pushed:SetPoint("TOPRIGHT", pushed, "BOTTOMRIGHT");
		dd_pushed:SetWidth(130); dd_pushed:Show();
		if desc.dd_pushed then 
			dd_pushed:SetSelection(desc.dd_pushed); 
		else
			dd_pushed:SetSelection("ARTWORK");
		end
		
		local txtdisabled = VFLUI.CreateFontString(dlg);
		txtdisabled:SetPoint("TOPLEFT", txtpushed, "BOTTOMLEFT", 0, -30);
		txtdisabled:SetWidth(80); txtdisabled:SetHeight(24);
		txtdisabled:SetJustifyH("LEFT"); txtdisabled:SetJustifyV("CENTER");
		txtdisabled:SetFontObject(Fonts.Default10);
		txtdisabled:Show(); txtdisabled:SetText("Disabled Texture");
		
		local disabled = VFLUI.MakeTextureSelectButton(dlg, desc.disabled); 
		disabled:SetPoint("TOPLEFT", txtdisabled, "TOPRIGHT");
		disabled:Show();
		
		local dd_disabled = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_disabled:SetPoint("TOPRIGHT", disabled, "BOTTOMRIGHT");
		dd_disabled:SetWidth(130); dd_disabled:Show();
		if desc.dd_disabled then 
			dd_disabled:SetSelection(desc.dd_disabled); 
		else
			dd_disabled:SetSelection("OVERLAY");
		end
		
		local txtchecked = VFLUI.CreateFontString(dlg);
		txtchecked:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT", 280, 0);
		txtchecked:SetWidth(80); txtchecked:SetHeight(24);
		txtchecked:SetJustifyH("LEFT"); txtchecked:SetJustifyV("CENTER");
		txtchecked:SetFontObject(Fonts.Default10);
		txtchecked:Show(); txtchecked:SetText("Checked Texture");
		
		local checked = VFLUI.MakeTextureSelectButton(dlg, desc.checked); 
		checked:SetPoint("TOPLEFT", txtchecked, "TOPRIGHT");
		checked:Show();
		
		local dd_checked = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_checked:SetPoint("TOPRIGHT", checked, "BOTTOMRIGHT");
		dd_checked:SetWidth(130); dd_checked:Show();
		if desc.dd_checked then 
			dd_checked:SetSelection(desc.dd_checked); 
		else
			dd_checked:SetSelection("ARTWORK");
		end
		
		local txtautocastable = VFLUI.CreateFontString(dlg);
		txtautocastable:SetPoint("TOPLEFT", txtchecked, "BOTTOMLEFT", 0, -30);
		txtautocastable:SetWidth(80); txtautocastable:SetHeight(24);
		txtautocastable:SetJustifyH("LEFT"); txtautocastable:SetJustifyV("CENTER");
		txtautocastable:SetFontObject(Fonts.Default10);
		txtautocastable:Show(); txtautocastable:SetText("Autocastable Texture");
		
		local autocastable = VFLUI.MakeTextureSelectButton(dlg, desc.autocastable); 
		autocastable:SetPoint("TOPLEFT", txtautocastable, "TOPRIGHT");
		autocastable:Show();
		
		local dd_autocastable = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_autocastable:SetPoint("TOPRIGHT", autocastable, "BOTTOMRIGHT");
		dd_autocastable:SetWidth(130); dd_autocastable:Show();
		if desc.dd_autocastable then 
			dd_autocastable:SetSelection(desc.dd_autocastable); 
		else
			dd_autocastable:SetSelection("OVERLAY");
		end
		
		local txthighlight = VFLUI.CreateFontString(dlg);
		txthighlight:SetPoint("TOPLEFT", txtautocastable, "BOTTOMLEFT", 0, -30);
		txthighlight:SetWidth(80); txthighlight:SetHeight(24);
		txthighlight:SetJustifyH("LEFT"); txthighlight:SetJustifyV("CENTER");
		txthighlight:SetFontObject(Fonts.Default10);
		txthighlight:Show(); txthighlight:SetText("Highlight Texture");
		
		local highlight = VFLUI.MakeTextureSelectButton(dlg, desc.highlight); 
		highlight:SetPoint("TOPLEFT", txthighlight, "TOPRIGHT");
		highlight:Show();
		
		local dd_highlight = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_highlight:SetPoint("TOPRIGHT", highlight, "BOTTOMRIGHT");
		dd_highlight:SetWidth(130); dd_highlight:Show();
		if desc.dd_highlight then 
			dd_highlight:SetSelection(desc.dd_highlight); 
		else
			dd_highlight:SetSelection("HIGHLIGHT");
		end
		
		local txtgloss = VFLUI.CreateFontString(dlg);
		txtgloss:SetPoint("TOPLEFT", txthighlight, "BOTTOMLEFT", 0, -30);
		txtgloss:SetWidth(80); txtgloss:SetHeight(24);
		txtgloss:SetJustifyH("LEFT"); txtgloss:SetJustifyV("CENTER");
		txtgloss:SetFontObject(Fonts.Default10);
		txtgloss:Show(); txtgloss:SetText("Gloss Texture");
		
		local gloss = VFLUI.MakeTextureSelectButton(dlg, desc.gloss); 
		gloss:SetPoint("TOPLEFT", txtgloss, "TOPRIGHT");
		gloss:Show();
		
		local dd_gloss = VFLUI.Dropdown:new(dlg, RDXUI.DrawLayerDropdownFunction);
		dd_gloss:SetPoint("TOPRIGHT", gloss, "BOTTOMRIGHT");
		dd_gloss:SetWidth(130); dd_gloss:Show();
		if desc.dd_gloss then 
			dd_gloss:SetSelection(desc.dd_gloss); 
		else
			dd_gloss:SetSelection("OVERLAY");
		end
		
		--[[local txtcircle = VFLUI.CreateFontString(dlg);
		txtcircle:SetPoint("TOPLEFT", txtgloss, "BOTTOMLEFT", 0, -30);
		txtcircle:SetWidth(80); txtcircle:SetHeight(24);
		txtcircle:SetJustifyH("LEFT"); txtcircle:SetJustifyV("CENTER");
		txtcircle:SetFontObject(Fonts.Default10);
		txtcircle:Show(); txtcircle:SetText("Circle skin");
		
		local chk_circle = VFLUI.Checkbox:new(dlg);
		chk_circle:SetPoint("LEFT", txtcircle, "RIGHT");
		chk_circle:SetHeight(16); chk_circle:SetWidth(16);
		if desc and desc.circle then chk_circle:SetChecked(true); else chk_circle:SetChecked(); end
		chk_circle:Show();]]

		local esch = function() dlg:Destroy(); end
		VFL.AddEscapeHandler(esch);
		
		local btnClose = VFLUI.CloseButton:new(dlg);
		dlg:AddButton(btnClose);
		btnClose:SetScript("OnClick", function() VFL.EscapeTo(esch); end);

		local btnOK = VFLUI.OKButton:new(dlg);
		btnOK:SetText(i18n("OK")); btnOK:SetHeight(25); btnOK:SetWidth(75);
		btnOK:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
		btnOK:Show();
		btnOK:SetScript("OnClick", function()
			local desc = {};
			desc.backdrop = backdrop:GetSelectedTexture();
			desc.dd_backdrop = dd_backdrop:GetSelection();
			desc.border = border:GetSelectedTexture();
			desc.dd_border = dd_border:GetSelection();
			desc.flash = flash:GetSelectedTexture();
			desc.dd_flash = dd_flash:GetSelection();
			desc.normal = normal:GetSelectedTexture();
			desc.dd_normal = dd_normal:GetSelection();
			desc.pushed = pushed:GetSelectedTexture();
			desc.dd_pushed = dd_pushed:GetSelection();
			desc.disabled = disabled:GetSelectedTexture();
			desc.dd_disabled = dd_disabled:GetSelection();
			desc.checked = checked:GetSelectedTexture();
			desc.dd_checked = dd_checked:GetSelection();
			desc.autocastable = autocastable:GetSelectedTexture();
			desc.dd_autocastable = dd_autocastable:GetSelection();
			desc.highlight = highlight:GetSelectedTexture();
			desc.dd_highlight = dd_highlight:GetSelection();
			desc.gloss = gloss:GetSelectedTexture();
			desc.dd_gloss = dd_gloss:GetSelection();
			--desc.circle = chk_circle:GetChecked();
			md.data = desc;
			if inst then updateInst(inst, desc); end
			VFL.EscapeTo(esch);
		end);

		dlg.Destroy = VFL.hook(function(s)
			btnOK:Destroy(); btnOK = nil;
			VFLUI.ReleaseRegion(txtbkd); txtbkd = nil;
			backdrop:Destroy(); backdrop = nil;
			dd_backdrop:Destroy(); dd_backdrop = nil;
			VFLUI.ReleaseRegion(txtbor); txtbor = nil;
			border:Destroy(); border = nil;
			dd_border:Destroy(); dd_border = nil;
			VFLUI.ReleaseRegion(txtflash); txtflash = nil;
			flash:Destroy(); flash = nil;
			dd_flash:Destroy(); dd_flash = nil;
			VFLUI.ReleaseRegion(txtnormal); txtnormal = nil;
			normal:Destroy(); normal = nil;
			dd_normal:Destroy(); dd_normal = nil;
			VFLUI.ReleaseRegion(txtpushed); txtpushed = nil;
			pushed:Destroy(); pushed = nil;
			dd_pushed:Destroy(); dd_pushed = nil;
			VFLUI.ReleaseRegion(txtdisabled); txtdisabled = nil;
			disabled:Destroy(); disabled = nil;
			dd_disabled:Destroy(); dd_disabled = nil;
			VFLUI.ReleaseRegion(txtchecked); txtchecked = nil;
			checked:Destroy(); checked = nil;
			dd_checked:Destroy(); dd_checked = nil;
			VFLUI.ReleaseRegion(txtautocastable); txtautocastable = nil;
			autocastable:Destroy(); autocastable = nil;
			dd_autocastable:Destroy(); dd_autocastable = nil;
			VFLUI.ReleaseRegion(txthighlight); txthighlight = nil;
			highlight:Destroy(); highlight = nil;
			dd_highlight:Destroy(); dd_highlight = nil;
			VFLUI.ReleaseRegion(txtgloss); txtgloss = nil;
			gloss:Destroy(); gloss = nil;
			dd_gloss:Destroy(); dd_gloss = nil;
			--VFLUI.ReleaseRegion(txtcircle); txtcircle = nil;
			--chk_circle:Destroy(); chk_circle = nil;
			dlg = nil;
		end, dlg.Destroy);
	end;
	Instantiate = function(path, md)
		if type(md.data) ~= "table" then return nil; end
		local inst = {};
		updateInst(inst, md.data);
		return inst;
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function()
				VFL.poptree:Release();
				RDXDB.OpenObject(path, "Edit", dlg);
			end
		});
	end;
});

--
-- Create a button skin like
--

RDXUI.ButtonSkin = {};
function RDXUI.ButtonSkin:new(parent, ftype, mddata, backdrop, border, flash, normal, pushed, disabled, checked, autocastable, highlight, gloss)
	if ftype ~= "CheckButton" and btn:GetFrameType() ~= "Button" and btn:GetFrameType() ~= "SecureActionButton" then return; end
	local btn = VFLUI.AcquireFrame(ftype);
	
	if backdrop then
		if not btn._texBackdrop then
			local _fbck = VFLUI.AcquireFrame("Frame");
			_fbck:SetParent(btn);
			_fbck:SetFrameLevel(btn:GetFrameLevel() - 2);
			_fbck:SetAllPoints(btn);
			_fbck:Show();
			btn._fbck = _fbck;
			
			local _texBackdrop = VFLUI.CreateTexture(btn._fbck);
			VFLUI.SetTexture(_texBackdrop, mddata.backdrop);
			_texBackdrop:SetDrawLayer(mddata.dd_backdrop);
			_texBackdrop:SetAllPoints(btn._fbck);
			_texBackdrop:Show();
			btn._texBackdrop = _texBackdrop;
		else
			VFLUI.SetTexture(btn._texBackdrop, mddata.backdrop);
			btn._texBackdrop:SetDrawLayer(mddata.dd_backdrop);
		end
	end
	if border then
		if not btn._texBorder then
			local _fbdr = VFLUI.AcquireFrame("Frame");
			_fbdr:SetParent(btn);
			_fbdr:SetFrameLevel(btn:GetFrameLevel() + 1);
			_fbdr:SetAllPoints(btn);
			_fbdr:Show();
			btn._fbdr = _fbdr;
			
			local _texBorder = VFLUI.CreateTexture(btn._fbdr);
			VFLUI.SetTexture(_texBorder, mddata.border);
			_texBorder:SetDrawLayer(mddata.dd_border);
			_texBorder:SetAllPoints(btn._fbdr);
			_texBorder:Show();
			btn._texBorder = _texBorder;
		else
			VFLUI.SetTexture(btn._texBorder, mddata.border);
			btn._texBorder:SetDrawLayer(mddata.dd_border);
		end
	end
	if flash then
		if not btn._texFlash then
			local _ffl = VFLUI.AcquireFrame("Frame");
			_ffl:SetParent(btn);
			_ffl:SetFrameLevel(btn:GetFrameLevel() + 2);
			_ffl:SetAllPoints(btn);
			--_ffl:Show();
			btn._ffl = _ffl;
			
			local _texFlash = VFLUI.CreateTexture(btn._ffl);
			VFLUI.SetTexture(_texFlash, mddata.flash);
			_texFlash:SetDrawLayer(mddata.dd_flash);
			_texFlash:SetAllPoints(btn._ffl);
			_texFlash:Show();
			btn._texFlash = _texFlash;
		else
			VFLUI.SetTexture(btn._texFlash, mddata.flash);
			btn._texFlash:SetDrawLayer(mddata.dd_flash);
		end
	end
	if normal then
		btn:SetNormalTexture("");
		VFLUI.SetTexture(btn:GetNormalTexture(), mddata.normal);
		btn:GetNormalTexture():SetDrawLayer(mddata.dd_normal);
	end
	if pushed then
		btn:SetPushedTexture("");
		VFLUI.SetTexture(btn:GetPushedTexture(), mddata.pushed);
		btn:GetPushedTexture():SetDrawLayer(mddata.dd_pushed);
	end
	if disabled then
		btn:SetDisabledTexture("");
		VFLUI.SetTexture(btn:GetDisabledTexture(), mddata.disabled);
		btn:GetDisabledTexture():SetDrawLayer(mddata.dd_disabled);
	end
	if checked and btn:GetFrameType() == "CheckButton" then
		btn:SetCheckedTexture("");
		VFLUI.SetTexture(btn:GetCheckedTexture(), mddata.checked);
		btn:GetCheckedTexture():SetDrawLayer(mddata.dd_checked);
	end
	if highlight then
		btn:SetHighlightTexture("");
		VFLUI.SetTexture(btn:GetHighlightTexture(), mddata.highlight);
		btn:GetHighlightTexture():SetDrawLayer(mddata.dd_highlight);
	end
	--[[if autocastable then
		btn._a = VFLUI.CreateTexture(parent);
		VFLUI.SetTexture(btn._a, mddata.autocastable);
		btn._a:SetDrawLayer(mddata.dd_autocastable);
		btn._a:SetAllPoints(parent);
		btn._a:Hide();
	end]]
	if gloss then
		if not btn._texGloss then
			local _fgl = VFLUI.AcquireFrame("Frame");
			_fgl:SetParent(btn);
			_fgl:SetFrameLevel(btn:GetFrameLevel() + 2);
			_fgl:SetAllPoints(btn);
			_fgl:Show();
			btn._fgl = _fgl;
			
			local _texGloss = VFLUI.CreateTexture(btn._fgl);
			VFLUI.SetTexture(_texGloss, mddata.gloss);
			_texGloss:SetDrawLayer(mddata.dd_gloss);
			_texGloss:SetAllPoints(btn._fgl);
			_texGloss:Show();
			btn._texGloss = _texGloss;
		else
			VFLUI.SetTexture(btn._texGloss, mddata.gloss);
			btn._texGloss:SetDrawLayer(mddata.dd_gloss);
		end
	end

	btn.Destroy = VFL.hook(function(self)
		if self._texBackdrop then VFLUI.ReleaseRegion(self._texBackdrop); self._texBackdrop = nil; end
		if self._fbck then self._fbck:Destroy(); self._fbck = nil; end
		if self._texBorder then VFLUI.ReleaseRegion(self._texBorder); self._texBorder = nil; end
		if self._fbdr then self._fbdr:Destroy(); self._fbdr = nil; end
		if self._texFlash then VFLUI.ReleaseRegion(self._texFlash); self._texFlash = nil; end
		if self._ffl then self._ffl:Destroy(); self._ffl = nil; end
		--if self._a then VFLUI.ReleaseRegion(self._a); self._a = nil; end
		if self._texGloss then VFLUI.ReleaseRegion(self._texGloss); self._texGloss = nil; end
		if self._fgl then self._fgl:Destroy(); self._fgl = nil; end
	end, btn.Destroy);

	return btn;
end

--
-- Use to apply skin to an existing button
--

function RDXUI.ApplyButtonSkin(btn, mddata, backdrop, border, flash, normal, pushed, disabled, checked, highlight, autocastable, gloss)
	if btn:GetFrameType() ~= "CheckButton" and btn:GetFrameType() ~= "Button" then return; end
	if backdrop then
		if not btn._texBackdrop then
			local _fbck = VFLUI.AcquireFrame("Frame");
			_fbck:SetParent(btn);
			_fbck:SetFrameLevel(btn:GetFrameLevel() - 1);
			_fbck:SetAllPoints(btn);
			_fbck:Show();
			btn._fbck = _fbck;
			
			local _texBackdrop = VFLUI.CreateTexture(btn._fbck);
			VFLUI.SetTexture(_texBackdrop, mddata.backdrop);
			_texBackdrop:SetDrawLayer(mddata.dd_backdrop);
			_texBackdrop:SetAllPoints(btn._fbck);
			_texBackdrop:Show();
			btn._texBackdrop = _texBackdrop;
		else
			VFLUI.SetTexture(btn._texBackdrop, mddata.backdrop);
			btn._texBackdrop:SetDrawLayer(mddata.dd_backdrop);
		end
	end
	if border then
		if not btn._texBorder then
			local _fbdr = VFLUI.AcquireFrame("Frame");
			_fbdr:SetParent(btn);
			_fbdr:SetFrameLevel(btn:GetFrameLevel() + 1);
			_fbdr:SetAllPoints(btn);
			_fbdr:Show();
			btn._fbdr = _fbdr;
			
			local _texBorder = VFLUI.CreateTexture(btn._fbdr);
			VFLUI.SetTexture(_texBorder, mddata.border);
			_texBorder:SetDrawLayer(mddata.dd_border);
			_texBorder:SetAllPoints(btn._fbdr);
			_texBorder:Show();
			btn._texBorder = _texBorder;
		else
			VFLUI.SetTexture(btn._texBorder, mddata.border);
			btn._texBorder:SetDrawLayer(mddata.dd_border);
		end
	end
	if flash then
		if not btn._texFlash then
			local _ffl = VFLUI.AcquireFrame("Frame");
			_ffl:SetParent(btn);
			_ffl:SetFrameLevel(btn:GetFrameLevel() + 1);
			_ffl:SetAllPoints(btn);
			_ffl:Show();
			btn._ffl = _ffl;
			
			local _texFlash = VFLUI.CreateTexture(btn._ffl);
			VFLUI.SetTexture(_texFlash, mddata.flash);
			_texFlash:SetDrawLayer(mddata.dd_flash);
			_texFlash:SetAllPoints(btn._ffl);
			_texFlash:Show();
			btn._texFlash = _texFlash;
		else
			VFLUI.SetTexture(btn._texFlash, mddata.flash);
			btn._texFlash:SetDrawLayer(mddata.dd_flash);
		end
	end
	if normal then
		btn:SetNormalTexture("");
		VFLUI.SetTexture(btn:GetNormalTexture(), mddata.normal);
		btn:GetNormalTexture():SetDrawLayer(mddata.dd_normal);
	end
	if pushed then
		btn:SetPushedTexture("");
		VFLUI.SetTexture(btn:GetPushedTexture(), mddata.pushed);
		btn:GetPushedTexture():SetDrawLayer(mddata.dd_pushed);
	end
	if disabled then
		btn:SetDisabledTexture("");
		VFLUI.SetTexture(btn:GetDisabledTexture(), mddata.disabled);
		btn:GetDisabledTexture():SetDrawLayer(mddata.dd_disabled);
	end
	if checked and btn:GetFrameType() == "CheckButton" then
		btn:SetCheckedTexture("");
		VFLUI.SetTexture(btn:GetCheckedTexture(), mddata.checked);
		btn:GetCheckedTexture():SetDrawLayer(mddata.dd_checked);
	end
	if highlight then
		btn:SetHighlightTexture("");
		VFLUI.SetTexture(btn:GetHighlightTexture(), mddata.highlight);
		btn:GetHighlightTexture():SetDrawLayer(mddata.dd_highlight);
	end
	--[[if autocastable then
		s._a = VFLUI.CreateTexture(parent);
		VFLUI.SetTexture(s._a, mddata.autocastable);
		s._a:SetDrawLayer(mddata.dd_autocastable);
		s._a:SetAllPoints(parent);
		s._a:Hide();
	end]]
	
	if gloss then
		if not btn._texGloss then
			local _fgl = VFLUI.AcquireFrame("Frame");
			_fgl:SetParent(btn);
			_fgl:SetFrameLevel(btn:GetFrameLevel() + 1);
			_fgl:SetAllPoints(btn);
			_fgl:Show();
			btn._fgl = _fgl;
			
			local _texGloss = VFLUI.CreateTexture(btn._fgl);
			VFLUI.SetTexture(_texGloss, mddata.gloss);
			_texGloss:SetDrawLayer(mddata.dd_gloss);
			_texGloss:SetAllPoints(btn._fgl);
			_texGloss:Show();
			btn._texGloss = _texGloss;
		else
			VFLUI.SetTexture(btn._texGloss, mddata.gloss);
			btn._texGloss:SetDrawLayer(mddata.dd_gloss);
		end
	end
end

function RDXUI.DestroyButtonSkin(btn)
	if btn._fbck then 
		VFLUI.ReleaseRegion(btn._texBackdrop); btn._texBackdrop = nil;
		btn._fbck:Destroy(); btn._fbck = nil;
	end
	if btn._fbdr then 
		VFLUI.ReleaseRegion(btn._texBorder); btn._texBorder = nil;
		btn._fbdr:Destroy(); btn._fbdr = nil;
	end
	if btn._ffl then 
		VFLUI.ReleaseRegion(btn._texFlash); btn._texFlash = nil;
		btn._ffl:Destroy(); btn._ffl = nil;
	end
	if btn._fgl then 
		VFLUI.ReleaseRegion(btn._texGloss); btn._texGloss = nil;
		btn._fgl:Destroy(); btn._fgl = nil;
	end
	--btn:SetNormalTexture("");
	--btn:SetPushedTexture("");
	--btn:SetDisabledTexture("");
	--btn:SetCheckedTexture("");
	--btn:SetHighlightTexture("");
end





