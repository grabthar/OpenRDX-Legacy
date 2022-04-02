-- WindowOpenDelay.lua
-- OpenRDX

RDX.RegisterFeature({
	name = "WindowOpenDelay";
	title = i18n("Window Open Delay");
	IsPossible = function(state)
		if not state:Slot("Layout") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then return nil; end
		state:AddSlot("WindowOpenDelay");
		return true;
	end;
	ApplyFeature = function(desc, state)
		return true;
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return {feature = "WindowOpenDelay"}; end;
});