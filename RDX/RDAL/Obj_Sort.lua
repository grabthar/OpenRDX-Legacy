-- Obj_Sort.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Glue code for the Sort object type.

-- The dialog for editing the contents of a Sort.
local dlg = nil;
function RDXUI.EditSortDialog(parent, path, md)
	if dlg then
		RDX.print(i18n("A sort editor is already open. Please close it first."));
		return;
	end
	if (not path) or (not md) or (not md.data) then return nil; end
	local inst = RDXDB.GetObjectInstance(path, true);

	if not parent then parent = UIParent; end
	dlg = VFLUI.Window:new(parent); 
	dlg:SetFrameStrata("FULLSCREEN");
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetTitleColor(0,0,.6);
	dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(435); dlg:SetHeight(350);
	dlg:SetText("Edit Sort: " .. path);
	-- OpenRDX 7.1 RDXPM
	if RDXPM.Ismanaged("Sort") then RDXPM.RestoreLayout(dlg, "Sort"); end
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	dlg:Show();

	-- Editor
	local ed = RDX.SortEditor:new(dlg);
	ed:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	ed:Show();
	
	if md.data then
		ed:SetDescriptors(md.data.set, md.data.sort);
	else
		ed:SetDescriptors();
	end

	-- OK/cancel
	local esch = function() 
		RDXPM.StoreLayout(dlg, "Sort");
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
		local d1, d2 = ed:GetDescriptors();
		VFL.EscapeTo(esch);
		if d1 and d2 then
			local set = RDX.FindSet(d1);
			if set then
				local sf = RDX.SortFunctor(d2, set, {});
				if sf then
					md.data = { set = d1, sort = d2 };
					if inst then inst:Setup(d2, set, inst:IsSecure()); end
				else
					RDX.print(i18n("Error: could not generate sort function"));
				end
			else
				RDX.print(i18n("Error: could not instantiate underlying set"));
			end
		else
			RDX.print(i18n("Error: missing descriptor."));
		end
	end);

	-- Destructor
	dlg.Destroy = VFL.hook(function(s)
		btnOK:Destroy(); btnOK = nil;
		ed:Destroy(); ed = nil;
		dlg = nil;
	end, dlg.Destroy);
end

-- Registration and controls for the Sort object type.
RDXDB.RegisterObjectType({
	name = "Sort",
	New = function(path, md)
		md.version = 2;
	end,
	Instantiate = function(path, obj)
		-- Sanity checks
		if not obj.data then return nil; end
		if obj.version < 2 then
			error(i18n("Lingering old Sort version!"));
		end
		local d1, d2 = obj.data.set, obj.data.sort;
		-- Try to get our set.
		local set = RDX.FindSet(d1);
		if not set then 
			VFL.TripError("RDX", i18n("Could not instantiate sort at ") .. tostring(path), i18n("Underlying set appears to be invalid."));
			return nil, i18n("Could not instantiate set."); 
		end
		-- Make the sort
		local x = RDX.Sort:new(); x.name = path;
		if not x:Setup(d2, set) then
			VFL.TripError("RDX", i18n("Could not instantiate sort at ") .. tostring(path), i18n("Sort generation error, see other error logs for more info."));
			return nil;
		end
		return x;
	end,
	Edit = function(path, md, parent)
		RDXUI.EditSortDialog(parent or VFLHigh, path, md);
	end,
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function() 
				VFL.poptree:Release(); 
				RDXUI.EditSortDialog(dlg, path, md); 
			end
		});
		--if RDXU.devflag then
			table.insert(mnu, {
				text = i18n("Transform Secure"),
				OnClick = function() 
					VFL.poptree:Release();
					local pkg, file = RDXDB.ParsePath(path);
					md.ty = "SecureSort";
					md.version = 1;
					RDXDBEvents:Dispatch("OBJECT_MOVED", pkg, file, pkg, file, md);
				end
			});
		--end
	end
});


