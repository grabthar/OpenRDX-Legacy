-- LibHealcomm_Integration.lua

--------------------------------------------------------------------
-- LibHealComm-3.0 Intergration
-- OpenRDX - Xenios
--------------------------------------------------------------------

local HealComm;

local function InitAceHealComm()
	RDX.print("LibHealComm-3.0 integration enabled.");
	local RDXHealComm = {};
	function RDXHealComm:HealComm_DirectHealStart(event, healerName, healSize, endTime, ...)
		
		local origin = RDX.GetUnitByName(string.lower(healerName));
		if (not origin) or (not origin:IsValid()) then return; end
		if origin.GetMainTalent() ~= 0 then return end;

		for i=1,select('#', ...) do
			local targetName = select(i, ...);
			local targetUnit = RDX.GetUnitByName(string.lower(targetName));
			healSize = healSize * HealComm:UnitHealModifierGet(origin.uid);
			targetUnit:_AddIncHeal(origin, healSize, endTime, nil);
		end
	end

	function RDXHealComm:HealComm_DirectHealStop(event, healerName, healSize, succeeded, ...)
		
		local origin = RDX.GetUnitByName(string.lower(healerName));
		if (not origin) or (not origin:IsValid()) then return; end
		if origin.GetMainTalent() ~= 0 then return end;

		for i=1,select('#', ...) do
			local targetName = select(i, ...);
			local targetUnit = RDX.GetUnitByName(string.lower(targetName));
			targetUnit:_StopIncHeal(origin);
		end
	end

	function RDXHealComm:HealComm_DirectHealDelayed(event, healerName, healSize, endTime, ...)
		
		local origin = RDX.GetUnitByName(string.lower(healerName));
		if (not origin) or (not origin:IsValid()) then return; end
		if origin.GetMainTalent() ~= 0 then return end;

		for i=1,select('#', ...) do
			local targetName = select(i, ...);
			local targetUnit = RDX.GetUnitByName(string.lower(targetName));
			targetUnit:_StopIncHeal(origin);
			local healSize = healSize * HealComm:UnitHealModifierGet(origin.uid);
			targetUnit:_AddIncHeal(origin, healSize, endTime, nil);
		end
	end

	HealComm.RegisterCallback(RDXHealComm, "HealComm_DirectHealStart");
	HealComm.RegisterCallback(RDXHealComm, "HealComm_DirectHealStop");
	HealComm.RegisterCallback(RDXHealComm, "HealComm_DirectHealDelayed");
end

-----------------------------------------------------------
-- INIT
-----------------------------------------------------------
RDXEvents:Bind("INIT_POST_VARIABLES_LOADED", nil, function()
	if not LibStub then return; end
	HealComm = LibStub:GetLibrary("LibHealComm-3.0", true);
	if (not HealComm) then return; end
	RDX.print(i18n("LibHealComm-3.0 integration activated"));
	InitAceHealComm();
end);

