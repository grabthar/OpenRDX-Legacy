-- Internationalize.lua
-- OpenRDX

--------------------------------------------------
-- INTERNATIONALIZATION
--------------------------------------------------
local packs_table = {};

function VFL.RegisterLanguagePack(tbl, locale)
	if (not tbl) or (not locale) then VFL.print("|cFFFF0000[VFL]|r Info : attempt to register anonymous Language Pack"); return; end
	if packs_table[locale] then VFL.print("|cFFFF0000[RDX]|r Info : Duplicate registration locale " .. locale); return; end
	packs_table[locale] = tbl;
end

function VFL.GetLanguagePackVersion()
	local locale = GetLocale();
	if packs_table[locale] then
		return packs_table[locale].version, locale;
	end
	return nil, locale;
end

local i18n_table = {};

function i18n(str)
	if not str then return nil; end
	return i18n_table[str] or str;
end

function VFL.Internationalize(locale, data)
	if GetLocale() == locale then
		-- Load the translations into the translation table
		for k,v in pairs(data) do i18n_table[k] = v; end
		data = nil;
	end
end
