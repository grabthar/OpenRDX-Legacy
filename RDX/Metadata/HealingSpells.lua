RDXEvents:Bind("INIT_PRELOAD", nil, function()

------------ HOT SPELLS
HealSync.AddHoT("renew", i18n("Renew"), 15);
HealSync.AddHoT("regr", i18n("Regrowth"), 21);
HealSync.AddHoT("rejuv", i18n("Rejuvenation"), 12);
HealSync.AddHoT("lb", i18n("Lifebloom"), 7);
HealSync.AddHoT("el", i18n("Earthliving"), 12);
HealSync.AddHoT("wg", i18n("Wild Growth"), 7);

----------- DIRECT HEALS
-- Priest
HealSync.RegisterDirectHealSpell(i18n("Flash Heal"));
HealSync.RegisterDirectHealSpell(i18n("Binding Heal"));
HealSync.RegisterDirectHealSpell(i18n("Greater Heal"));
HealSync.RegisterDirectHealSpell(i18n("Lesser Heal"));
HealSync.RegisterDirectHealSpell(i18n("Heal"));
HealSync.RegisterDirectHealSpell(i18n("Prayer of Healing"));
HealSync.RegisterIgnoreDHSbyBuff(i18n("Flash Heal"), 33151);

-- Druid
HealSync.RegisterDirectHealSpell(i18n("Healing Touch"));
HealSync.RegisterDirectHealSpell(i18n("Regrowth"));
HealSync.RegisterDirectHealSpell(i18n("Nourish"));

-- Paladin
HealSync.RegisterDirectHealSpell(i18n("Flash of Light"));
HealSync.RegisterDirectHealSpell(i18n("Holy Light"));
HealSync.RegisterIgnoreDHSbyBuff(i18n("Flash of Light"), 59578);

-- Shaman
HealSync.RegisterDirectHealSpell(i18n("Healing Wave"));
HealSync.RegisterDirectHealSpell(i18n("Lesser Healing Wave"));
HealSync.RegisterDirectHealSpell(i18n("Chain Heal"));

end);
