-----------------------------------
-- The CooldownFilter object type.
-----------------------------------
local dlg = nil;

local function WriteFilter(dest, src)
	VFL.empty(dest);
	local auname, flag;
	for _,v in ipairs(src) do
		flag = nil;
		local test = string.sub(v, 1, 1);
		if test == "!" then
			flag = true;
			v = string.sub(v, 2);
		end
		local testnumber = tonumber(v);
		if testnumber then
			auname = GetSpellInfo(v);
			if flag then
				dest["!" .. auname] = true;
			else
				dest[auname] = true;
			end
		else
			if flag then
				dest["!" .. v] = true;
			else
				dest[v] = true;
			end
		end
	end
end

--RDXDB.WriteFilter = WriteFilter;

RDXDB.RegisterObjectType({
	name = "CooldownFilter";
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
		dlg:SetWidth(310); dlg:SetHeight(270);
		dlg:SetText(i18n("Edit CooldownFilter: ") .. path);
		
		VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
		if RDXPM.Ismanaged("CooldownFilter") then RDXPM.RestoreLayout(dlg, "CooldownFilter"); end

		local le_names = VFLUI.ListEditor:new(dlg, md.data, function(cell,data) 
			if type(data) == "number" then
				local name = GetSpellInfo(data);
				cell.text:SetText(name);
			else
				local test = string.sub(data, 1, 1);
				if test == "!" then
					local uname = string.sub(data, 2);
					local vname = GetSpellInfo(uname);
					if vname then
						cell.text:SetText("!" .. vname);
					else
						cell.text:SetText(data);
					end
				else
					cell.text:SetText(data);
				end
			end
		end);
		le_names:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
		le_names:SetWidth(300);	le_names:SetHeight(183); le_names:Show();

		dlg:Show(.2, true);

		local esch = function()
			dlg:Hide(.2, true);
			VFL.ZMSchedule(.25, function()
				RDXPM.StoreLayout(dlg, "CooldownFilter");
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
			local desc = le_names:GetList();
			if desc then
				local flag;
				local descid = {};
				for k,v in pairs(desc) do
					flag = nil;
					local test = string.sub(v, 1, 1);
					if test == "!" then
						flag = true;
						v = string.sub(v, 2);
					end
					local testnumber = tonumber(v);
					if testnumber then
						if flag then
							descid[k] = "!" .. testnumber;
						else
							descid[k] = testnumber;
						end
					else
						if flag then
							local spellid = RDXSS.GetSpellIdByLocalName(v);
							if spellid then
								descid[k] = "!" .. spellid;
							else
								descid[k] = "!" .. v;
							end
						else
							descid[k] = RDXSS.GetSpellIdByLocalName(v) or v;
						end
					end
				end
				md.data = descid;
				if inst then WriteFilter(inst, descid); end
			end
			VFL.EscapeTo(esch);
		end);

		dlg.Destroy = VFL.hook(function(s)
			btnOK:Destroy(); btnOK = nil;
			le_names:Destroy(); le_names = nil;
			dlg = nil;
		end, dlg.Destroy);
	end;
	Instantiate = function(path, md)
		if type(md.data) ~= "table" then return nil; end
		local inst = {};
		WriteFilter(inst, md.data);
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
