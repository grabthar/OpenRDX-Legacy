-- UnitFramePreviewWindow.lua
-- OpenRDX

------------------------------------------------------------------------
-- GUI Preview unitframe
--   By: Daniel LY (Sigg, Rashgarroth realm)
------------------------------------------------------------------------

local preview_window, ca;

local function OpenPreviewWindow(parent)
	if preview_window then return preview_window, ca; end
	if not parent then parent = RDX.IsUnitframeEditorOpen(); end
	if not parent then parent = UIParent; end
	preview_window = VFLUI.Window:new(parent); 
	preview_window:SetFrameStrata("FULLSCREEN");
	VFLUI.Window.SetDefaultFraming(preview_window, 24);
	preview_window:SetBackdrop(VFLUI.DefaultDialogBackdrop);
	--preview_window:SetBackdrop(VFLUI.DefaultDialogBorder);
	preview_window:SetTitleColor(0,.6,0);
	preview_window:SetText("Preview Unitframe");
	preview_window:SetWidth(350); 
	preview_window:SetHeight(500);
	preview_window:SetPoint("TOPLEFT", parent, "TOPRIGHT");
	preview_window:Show();
	--VFLUI.Window.StdMove(preview_window, preview_window:GetTitleBar());
	ca = preview_window:GetClientArea();
	
	local curUF = nil;
	local function UpdateUnitFrameDesign(state)
		-- Destroy the old frame
		if curUF then curUF:Destroy(); curUF = nil; end
		-- Load the ufstate.
		local ufstate = RDX.UnitFrameState:new();
		local func = ufstate.ApplyAll;
		local winstate = RDX._exportedWindowState;
		ufstate:SetContainingWindowState(winstate);
		ufstate:LoadDescriptor(state:GetDescriptor());
		local _errs = VFL.Error:new();
		if not func(ufstate, _errs) then
			_errs:ToErrorHandler("RDX", i18n("Could not load UnitFrameType at <preview>"));
			return;
		end
		--if not ufstate then return; end
		local createFrame = RDX.UnitFrameGeneratingFunctor(ufstate);
		if not createFrame then return; end
		-- Success, update the uf.
		curUF = VFLUI.AcquireFrame("Frame"); 
		VFLUI.StdSetParent(curUF, ca);
		createFrame(curUF);
		curUF:SetPoint("CENTER", ca, "CENTER", 0, 0); 
		curUF:Show();
	end
	
	local unit;
	local function PaintUnitFrame()
		if curUF then 
			unit = RDX.ProjectUnitID("player");
			if unit then
				curUF._paintmask = 1;
				curUF:SetData(1, unit.uid, unit);
			end
		end
	end
	VFL.AdaptiveSchedule("__uf_preview", 1, PaintUnitFrame);
	
	preview_window.UpdateFrame = UpdateUnitFrameDesign;
	
	preview_window.Destroy = VFL.hook(function(s)
		if curUF then curUF:Destroy(); end
		VFL.AdaptiveUnschedule("__uf_preview");
	end, preview_window.Destroy);
	
	return preview_window, ca;
end

local function ClosePreviewWindow()
	if preview_window then preview_window:Destroy(); preview_window = nil; end
	return true;
end

local function TogglePreviewWindow()
	if preview_window then
		return ClosePreviewWindow();
	else
		return OpenPreviewWindow();
	end
end

local function PaintPreviewWindow(state)
	if preview_window then preview_window.UpdateFrame(state); end
	return true;
end

RDXDB.PaintPreviewWindow = PaintPreviewWindow;
RDXDB.TogglePreviewWindow = TogglePreviewWindow;
RDXDB.ClosePreviewWindow = ClosePreviewWindow;
RDXDB.OpenPreviewWindow= OpenPreviewWindow;
