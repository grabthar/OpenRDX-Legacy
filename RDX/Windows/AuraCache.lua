-- AuraCache.lua
-- OpenRDX

RDX.RegisterFeature({
	name = "AuraCache";
	title = i18n("AuraCache");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if state:Slot("RepaintAllArgs") then return true; end
		if state:Slot("GetContainingWindowState") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		return true;
	end;
	ApplyFeature = function(desc, state)
		return true;
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return {feature = "AuraCache"}; end;
});