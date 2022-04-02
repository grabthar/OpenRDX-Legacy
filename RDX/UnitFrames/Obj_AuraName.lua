-----------------------------------
-- The AuraName object type.
-- Use with the feature buff/debuff info
-----------------------------------
local dlg = nil;

local function WriteName(dest, src)
	VFL.empty(dest);
	if type(src) == "string" then
		dest[string.lower(src)] = true; 
	end
end

RDXDB.RegisterObjectType({
	name = "AuraName";
	New = function(path, md)
		md.version = 1;
	end;
	Edit = function(path, md, parent)
		if dlg then return; end
		if (not path) or (not md) or (not md.data) then return nil; end
		local inst = RDXDB.GetObjectInstance(path, true);

		dlg = VFLUI.Window:new(UIParent);
		dlg:SetFrameStrata("FULLSCREEN");
		VFLUI.Window.SetDefaultFraming(dlg, 22);
		dlg:SetTitleColor(0,0,.6);
		dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
		dlg:SetPoint("CENTER", UIParent, "CENTER");
		dlg:SetWidth(320); dlg:SetHeight(85);
		dlg:SetText(i18n("Edit AuraName: ") .. path);
		
		VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
		if RDXPM.Ismanaged("Auraname") then RDXPM.RestoreLayout(dlg, "Auraname"); end
		
		local ed_name = VFLUI.LabeledEdit:new(dlg, 220);
		ed_name:SetText(i18n("Aura Name"));
		ed_name.editBox:SetText(md.data["auraname"] or "");
		ed_name:SetHeight(25); ed_name:SetWidth(310);
		ed_name:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
		ed_name:Show();
		
		local tmpcache = {};
		
		local btn_name = VFLUI.Button:new(ed_name);
		btn_name:SetHeight(25); btn_name:SetWidth(25); btn_name:SetText("...");
		btn_name:SetPoint("RIGHT", ed_name.editBox, "LEFT"); 
		btn_name:Show();
		btn_name:SetScript("OnClick", function()
			VFL.empty(tmpcache);
			VFL.copyInto(tmpcache, RDX._GetBuffCache());
			VFL.copyInto(tmpcache, RDX._GetDebuffCache());
			RDXUI.AuraCachePopup(tmpcache, function(x) 
				if x then ed_name.editBox:SetText(x.name); end
			end, btn_name, "CENTER");
		end);
		
		dlg:Show(.2, true);

		local esch = function()
			dlg:Hide(.2, true);
			VFL.ZMSchedule(.25, function()
				RDXPM.StoreLayout(dlg, "Auraname");
				dlg:Destroy(); dlg = nil;
			end);
		end
		VFL.AddEscapeHandler(esch);
		
		local btnClose = VFLUI.CloseButton:new(dlg);
		dlg:AddButton(btnClose);
		btnClose:SetScript("OnClick", function() VFL.EscapeTo(esch); end);

		local btnOK = VFLUI.OKButton:new(dlg);
		btnOK:SetText(i18n("OK")); btnOK:SetHeight(25); btnOK:SetWidth(75);
		btnOK:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
		btnOK:Show();
		btnOK:SetScript("OnClick", function()
			local desc = ed_name.editBox:GetText();
			if desc then
				md.data["auraname"] = desc;
				if inst then WriteFilter(inst, desc); end
			end
			VFL.EscapeTo(esch);
		end);

		dlg.Destroy = VFL.hook(function(s)
			btnOK:Destroy(); btnOK = nil;
			ed_name:Destroy(); ed_name = nil;
			btn_name:Destroy(); btn_name = nil;
			dlg = nil;
		end, dlg.Destroy);
	end;
	Instantiate = function(path, md)
		if type(md.data) ~= "string" then return nil; end
		local inst = {};
		WriteName(inst, md.data["auraname"]);
		return inst;
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function()
				VFL.poptree:Release();
				RDXDB.OpenObject(path, "Edit", md, dlg);
			end
		});
	end;
});
