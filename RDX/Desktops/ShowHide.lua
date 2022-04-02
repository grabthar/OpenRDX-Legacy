-- ShowHide.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- OpenRDX
-- Sigg Rashgarroth EU
-- Desktop Main function
-- Show / Hide

-------------------------------------------------------
-- Show/hide entire desktop
-------------------------------------------------------
function RDXDK.IsRDXHidden()
	if RDXU then return RDXU.hidden; else return nil; end
end

function RDXDK.ShowRDX()
	if InCombatLockdown() then 
		RDX.print(i18n("Cannot change show/hide state while in combat."));
		return; 
	end
	if (not RDXDK.IsRDXHidden()) then return; end
	RDXU.hidden = nil;
	RDXParent:Show();
end

function RDXDK.HideRDX()
	if InCombatLockdown() then 
		RDX.print(i18n("Cannot change show/hide state while in combat."));
		return; 
	end
	if RDXDK.IsRDXHidden() then return; end
	RDXU.hidden = true;
	RDXParent:Hide();
end

function RDXDK.ToggleRDX()
	if RDXDK.IsRDXHidden() then
		RDXDK.ShowRDX();
	else
		RDXDK.HideRDX();
	end
end

-- /rdx show and /rdx hide
RDX.RegisterSlashCommand("show", RDXDK.ShowRDX);
RDX.RegisterSlashCommand("hide", RDXDK.HideRDX);

RDXPM.RegisterMainButton({
	name = "hidedesktop";
	id = 130;
	btype = "toggle";
	title = i18n("Show/hide RDX");
	desc = i18n("Toggle button");
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\windowb";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\window";
	IsToggle = RDXDK.IsRDXHidden;
	OnClick = RDXDK.ToggleRDX;
});


