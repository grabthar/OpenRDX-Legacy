-- VFL_languagepack_frFR
-- OpenRDX

VFL_frFR = RegisterVFLModule({
	name = "VFL_frFR";
	title = "VFL Language pack frFR";
	description = "Language pack";
	parent = VFL;
});

VFL_frFR:LoadVersionFromTOC("VFL_languagepack_frFR");

if VFL.RegisterLanguagePack then VFL.RegisterLanguagePack(VFL_frFR, "frFR"); end
