-- WindowList.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED CONTENT SUBJECT TO THE TERMS OF A SEPARATE LICENSE.
-- UNLICENSED COPYING IS PROHIBITED.
--
-- The window list is a dialog that allows the rapid opening and closing of windows without
-- digging through the RDX Explorer.

---------------------------------------------------------------------
-- The "Description" feature that lets windows have descriptions.
---------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Description";
	title = i18n("Description");
	category = i18n("Misc");
	IsPossible = function(state)
		if state:Slot("GetContainingWindowState") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if (not desc) or (not desc.description) then
			VFL.AddError(errs, i18n("Invalid description"));
			return nil;
		end
		return true;
	end;
	ApplyFeature = VFL.Noop;
	UIFromDescriptor = function(desc, parent, state)
		local txt = VFLUI.AcquireFrame("EditBox");
		VFLUI.StdSetParent(txt, parent, 1);
		txt:SetFontObject(Fonts.Default);
		txt:SetTextInsets(0,0,0,0);
		txt:SetAutoFocus(nil); txt:ClearFocus();
		txt:SetScript("OnEscapePressed", function() this:ClearFocus(); end);
		txt:SetMultiLine(true); txt:Show();
		if desc and desc.description then txt:SetText(desc.description); end
		txt:SetFocus()

		txt.DialogOnLayout = VFL.Noop;
		function txt:GetDescriptor() return {feature = "Description", description = self:GetText(); } end

		return txt;
	end;
	CreateDescriptor = function() return {feature = "Description", description = ""}; end;
});

---------------------------------------------------------------------
-- Feature for hiding in windowlist.
---------------------------------------------------------------------
RDX.RegisterFeature({
	name = "WindowListHide";
	title = i18n("Hide From Windowlist");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		return true;
	end;
	ApplyFeature = VFL.Noop;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return {feature = "WindowListHide"}; end;
});


---------------------------------------------------------------------
-- The window list dialog.
---------------------------------------------------------------------
local dlg = nil;

local wl = {};

local function BuildWindowList()
	VFL.empty(wl);
	local desc = nil;
	for pkg,data in pairs(RDXData) do
		for file,md in pairs(data) do
			if (type(md) == "table") and md.data and md.ty and string.find(md.ty, "Window$") then
				local hide = RDX.HasFeature(md.data, "WindowListHide");
				if not hide then
					table.insert(wl, {path = RDXDB.MakePath(pkg, file), data = md.data});
				end
			end
		end
	end
	table.sort(wl, function(x1,x2) return x1.path<x2.path; end);
end

local function CreateWindowListFrame()
	local self = VFLUI.AcquireFrame("Button");
	
	-- Create the button highlight texture
	local hltTexture = VFLUI.CreateTexture(self);
	hltTexture:SetAllPoints(self);
	hltTexture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	hltTexture:Show();
	self:SetHighlightTexture(hltTexture);

	-- Create the text
	local text = VFLUI.CreateFontString(self);
	text:SetFontObject(VFLUI.GetFont(Fonts.Default, 10));	text:SetJustifyH("LEFT");
	text:SetTextColor(1,1,1,1);
	text:SetPoint("LEFT", self, "LEFT"); text:SetHeight(10); text:SetWidth(200);
	text:Show();
	self.text = text;

	text = VFLUI.CreateFontString(self);
	text:SetFontObject(VFLUI.GetFont(Fonts.Default, 10)); text:SetJustifyH("LEFT");
	text:SetTextColor(1,1,1,1);
	text:SetPoint("RIGHT", self, "RIGHT");  text:SetHeight(10); text:SetWidth(350);
	text:Show();
	self.text2 = text;

	self.Destroy = VFL.hook(function(self)
		-- Destroy allocated regions
		VFLUI.ReleaseRegion(hltTexture); hltTexture = nil;
		VFLUI.ReleaseRegion(self.text); self.text = nil;
		VFLUI.ReleaseRegion(self.text2); self.text2 = nil;
	end, self.Destroy);

	self.OnDeparent = self.Destroy;

	return self;
end

local function WindowListClick(path)
	-- "Close" case
	if InCombatLockdown() then return; end	
	local inst = RDXDB.GetObjectInstance(path, true);
	if inst then
		--RDX.print(i18n("Closing Window at <") .. path .. ">");
		RDXDB.OpenObject(path, "Close");
		return;
	end
	-- "Open" case
	--RDX.print(i18n("Opening Window at <") .. path .. ">");
	RDXDB.OpenObject(path);
end
RDXDK.OpenCloseWindow = WindowListClick;

function RDXDK.WindowList()
	if dlg then return; end

	dlg = VFLUI.Window:new(UIParent); dlg:SetFrameStrata("DIALOG");
	dlg:SetFraming(VFLUI.Framing.Sleek);
	dlg:SetBackdropColor(0,0,0,.8);
	dlg:SetTitleColor(0,.5,0);
	dlg:SetText(i18n("Window List"));
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:Accomodate(566, 348);
	
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	if RDXPM.Ismanaged("windowlist") then RDXPM.RestoreLayout(dlg, "windowlist"); end
	local ca = dlg:GetClientArea();

	local list = VFLUI.List:new(dlg, 12, CreateWindowListFrame);
	list:SetPoint("TOPLEFT", ca, "TOPLEFT");
	list:SetWidth(566); list:SetHeight(348);
	list:Rebuild(); list:Show();
	list:SetDataSource(function(cell, data, pos)
		local p = data.path;
		if RDXDB.PathHasInstance(p) then
			cell.text:SetText("|cFF00FF00" .. p .. "|r");
		else
			cell.text:SetText(p);
		end
		local str, df = nil, RDX.HasFeature(data.data, "Description");
		if df then str = df.description; end
		if str then
			cell.text2:SetText("|cFFCCCCCC" .. str .. "|r");
		else
			cell.text2:SetText(i18n("|cFF777777(No description)|r"));
		end
		cell:SetScript("OnClick", function()
			WindowListClick(p); list:Update();
		end);
	end, VFL.ArrayLiterator(wl));
	
	-- Build the base list
	BuildWindowList();
	list:Update();
	
	dlg:Show(.2, true);
	
	-- Escapement
	local esch = function() 
		dlg:Hide(.2, true);
		VFL.ZMSchedule(.25, function()
			RDXPM.StoreLayout(dlg, "windowlist");
			dlg:Destroy(); dlg = nil;
		end);
	end
	VFL.AddEscapeHandler(esch);
	
	function dlg:_esch()
		VFL.EscapeTo(esch);
	end
	
	local btnClose = VFLUI.CloseButton:new(dlg);
	dlg:AddButton(btnClose);
	btnClose:SetScript("OnClick", function() VFL.EscapeTo(esch); end);
	
	----------------- Close functionality
	dlg.Destroy = VFL.hook(function()
		list:Destroy(); list = nil;
	end, dlg.Destroy);
end

function RDXDK.ToggleWindowList()
	if dlg then
		dlg:_esch();
	else
		RDXDK.WindowList();
	end
end

