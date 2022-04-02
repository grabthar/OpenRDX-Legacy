-- Obj_FilterSet.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Glue code for the FilterSet object type.

-- Edit a preexisting FilterSet.
local dlg = nil;
local function EditFilterSetDialog(parent, path, md)
	if dlg then
		RDX.print(i18n("A set editor is already open. Please close it first."));
		return;
	end

	-- Sanity checks
	if (not path) or (not md) or (not md.data) then return nil; end
	-- See if this set was already instantiated...
	local inst = RDXDB.GetObjectInstance(path, true);

	if not parent then parent = UIParent; end
	dlg = VFLUI.Window:new(parent);
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetTitleColor(0,0,.6);
	dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(510); dlg:SetHeight(370);
	dlg:SetText(i18n("Edit FilterSet: ") .. path);
	-- OpenRDX 7.1 RDXPM
	if RDXPM.Ismanaged("FilterSet") then RDXPM.RestoreLayout(dlg, "FilterSet"); end
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	dlg:Show();

	local fe = RDX.FilterEditor:new(dlg);
	fe:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	fe:Show();
	fe:LoadDescriptor(md.data);

	local esch = function()
		RDXPM.StoreLayout(dlg, "FilterSet");
		dlg:Destroy(); 
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
		local desc = fe:GetDescriptor();
		VFL.EscapeTo(esch);
		if desc then
			md.data = desc;
			if inst then inst:SetFilter(desc); end
		end
	end);

	dlg.Destroy = VFL.hook(function(s)
		btnOK:Destroy(); btnOK = nil;
		fe:Destroy(); fe = nil;
		dlg = nil;
	end, dlg.Destroy);
end


-- Registration and controls for the FilterSet object type.
RDXDB.RegisterObjectType({
	name = "FilterSet";
	New = function(path, md)
		md.version = 1;
	end;
	Instantiate = function(path, obj)
		-- Verify the filter
		if not RDX.ValidateFilter(obj.data) then
			VFL.TripError("RDX", i18n("Could not validate filter for FilterSet<") .. tostring(path) .. ">", "");
			return nil; 
		end
		-- Make the set
		local x = RDX.FilterSet:new(); RDX.RegisterSet(x);
		x.path = path;
		x.name = "FilterSet<" .. path .. ">"; x:SetFilter(obj.data);
		return x;
	end;
	Edit = function(path, md, parent)
		EditFilterSetDialog(parent or VFLHigh, path, md);
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function() 
				VFL.poptree:Release(); 
				EditFilterSetDialog(dlg, path, md); 
			end
		});
	end
});

