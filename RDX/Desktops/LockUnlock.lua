-- OpenRDX
-- Sigg Rashgarroth EU /
-- Cidan
--
-- Lock / Unlock Desktop

function RDXDK.ImbueOverlay(frame)
	if not frame or frame.tf then return; end
	local tf, w, h = VFLUI.AcquireFrame("Button"), 3, 3;
	-- Ensure a minimum width and height
	if frame:WMGetPositionalFrame():GetHeight() < 1 then h = 20; end
	if frame:WMGetPositionalFrame():GetWidth() < 1 then w = 20; end
	
	tf:SetPoint("TOPLEFT", frame:WMGetPositionalFrame(), "TOPLEFT", -w, h);
	tf:SetPoint("BOTTOMRIGHT", frame:WMGetPositionalFrame(), "BOTTOMRIGHT", w, -h);
	tf:SetFrameStrata("HIGH");
	tf:SetFrameLevel(frame:GetFrameLevel()+5);
	--tf:GetScale(frame:GetEffectiveScale());
	tf:SetBackdrop(VFLUI.BlueDialogBackdrop);
	tf:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	tf:SetAlpha(1);
	RDXDK.StdMove(frame, tf, nil)
	tf:Show();
	
	-- Now for the font
	local tfIdent = VFLUI.CreateFontString(tf);
	tfIdent:SetPoint("CENTER", tf, "CENTER");
	tfIdent:SetWidth(tf:GetWidth()+200); 
	tfIdent:SetHeight(tf:GetHeight()-5);
	tfIdent:SetJustifyV("CENTER");
	tfIdent:SetJustifyH("CENTER");
	tfIdent:SetFontObject(Fonts.Default10);
	tfIdent:SetText(frame._dk_name);
	tfIdent:SetAlpha(1);
	tfIdent:Show();
	
	tf:Show(.2, true);
	
	frame.tf = tf;
	frame.tfIdent = tfIdent;
	frame.tfmanuel = true;
end

function RDXDK.UnimbueOverlay(frame)
	if frame.tf then
		-- problems sometime disable
		frame.tf:Hide(.2, true);
		VFL.ZMSchedule(.25, function()
			frame.tfmanuel = nil;
			VFLUI.ReleaseRegion(frame.tfIdent);
			frame.tfIdent = nil;
			frame.tf:Destroy();
			frame.tf = nil;
		end);
	end
end

function RDXDK.IsDesktopLocked()
	if RDXU then return RDXU.locked; else return nil; end
end

function RDXDK.UnlockDesktop()
	if not InCombatLockdown() then 
		RDXU.locked = nil;
		local currentDesktop = RDXDK.GetCurrentDesktop()
		if currentDesktop then currentDesktop:UnlockDesktop(); end
	else
		RDX.print(i18n("Cannot change unlock state while in combat."));
	end
end

function RDXDK.LockDesktop()
	RDXU.locked = true;
	local currentDesktop = RDXDK.GetCurrentDesktop();
	if currentDesktop then currentDesktop:LockDesktop(true); end
end

function RDXDK.ToggleDesktopLock()
	if RDXDK.IsDesktopLocked() then
		RDXDK.UnlockDesktop();
		RDX.print(i18n("Unlocking desktop."));
	else 
		RDXDK.LockDesktop();
		RDX.print(i18n("Locking desktop."));
	end
end

-- lock desktop if in combat
VFLEvents:Bind("PLAYER_COMBAT", nil, function()
	if InCombatLockdown() and not RDXDK.IsDesktopLocked() then
		RDXDK.LockDesktop();
	end
end);

RDXEvents:Bind("INIT_POST_DESKTOP", nil, function()	
	if RDXDK.IsDesktopLocked() then
		RDXDK.LockDesktop();
	else
		RDXDK.UnlockDesktop();
	end
end);

