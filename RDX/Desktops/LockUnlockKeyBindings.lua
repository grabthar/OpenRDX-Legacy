-- OpenRDX
-- Sigg Rashgarroth EU
--
-- Lock / Unlock KeyBindings

function RDXDK.IsKeyBindingsLocked()
	if RDXU then return RDXU.keylocked; else return nil; end
end

function RDXDK.UnlockKeyBindings()
	if not InCombatLockdown() then 
		RDXU.keylocked = nil;
		DesktopEvents:Dispatch("DESKTOP_UNLOCK_BINDINGS");
	else
		RDX.print(i18n("Cannot change unlock state while in combat."));
	end
end

function RDXDK.LockKeyBindings()
	RDXU.keylocked = true;
	DesktopEvents:Dispatch("DESKTOP_LOCK_BINDINGS");
	--SaveBindings(GetCurrentBindingSet());
end

function RDXDK.ToggleKeyBindingsLock()
	if RDXDK.IsKeyBindingsLocked() then
		RDXDK.UnlockKeyBindings();
		RDX.print(i18n("Unlocking Key Bindings."));
	else 
		RDXDK.LockKeyBindings();
		RDX.print(i18n("Locking Key Bindings."));
	end
end

-- lock desktop if in combat
VFLEvents:Bind("PLAYER_COMBAT", nil, function()
	if InCombatLockdown() and not RDXDK.IsKeyBindingsLocked() then
		RDXDK.LockKeyBindings();
	end
end);

RDXEvents:Bind("INIT_POST_DESKTOP", nil, function()	
	if RDXDK.IsKeyBindingsLocked() then
		RDXDK.LockKeyBindings();
	else
		RDXDK.UnlockKeyBindings();
	end
end);

