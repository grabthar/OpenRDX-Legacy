-- Obj_VirtualSet.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- A VirtualSet is a set provided internally by a mod, but accessible as a
-- file. 

RDXDB.RegisterObjectType({
	name = "VirtualSet";
	Instantiate = function(path, obj)
		local x = RDX.Set:new();
		RDX.RegisterSet(x); x.name = "<vset:" .. path .. ">";
		return x;
	end;
});

RDXDB.RegisterObjectType({
	name = "VirtualNominativeSet";
	Instantiate = function(path, obj)
		local x = RDX.NominativeSet:new();
		RDX.RegisterSet(x); x.name = "<vnset:" .. path .. ">";
		return x;
	end;
});

-------------------------------------------------------------------------------------------
-- An "indirect set" is a filesystem-based pointer to another of the internal set classes.
-- It is used to provide a slight performance advantage when you want unfiltered access
-- to the underlying set.
-------------------------------------------------------------------------------------------
local dlg = nil;
local function EditIndirectSetDialog(parent, path, md)
	if dlg then
		RDX.print(i18n("A set editor is already open. Please close it first.")); return;
	end
	if (not path) or (not md) or (not md.data) then return; end
	if not parent then parent = VFLHigh; end

	dlg = VFLUI.Window:new(parent);
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetTitleColor(0,0,.6);
	dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(316); dlg:SetHeight(357);
	dlg:SetText(i18n("Edit IndirectSet: ") .. path);
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	dlg:Show();

	local sf = VFLUI.VScrollFrame:new(dlg);
	sf:SetWidth(290); sf:SetHeight(300);
	sf:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	sf:Show();

	local ui = RDX.SetFinder:new(sf);
	ui:SetParent(sf); sf:SetScrollChild(ui); sf:Show();
	ui.isLayoutRoot = true;
	ui:SetDescriptor(md.data);

	ui:SetWidth(sf:GetWidth()); ui:Show(); VFLUI.UpdateDialogLayout(ui);

	------------------- DESTRUCTORS
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
		md.data = ui:GetDescriptor();
		VFL.EscapeTo(esch);
	end);

	dlg.Destroy = VFL.hook(function(s)
		sf:SetScrollChild(nil);
		ui:Destroy(); ui = nil; 
		sf:Destroy(); sf = nil;
		btnOK:Destroy(); btnOK = nil; dlg = nil;
	end, dlg.Destroy);
end

RDXDB.RegisterObjectType({
	name = "IndirectSet";
	New = function(path, md)
		md.version = 1;
	end;
	OverrideInstantiate = function(path, md)
		return RDX.FindSet(md.data);
	end;
	Edit = function(path, md, parent)
		EditIndirectSetDialog(parent or VFLHigh, path, md);
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit..."),
			OnClick = function() 
				VFL.poptree:Release(); 
				EditIndirectSetDialog(dlg, path, md); 
			end
		});
	end;
});
