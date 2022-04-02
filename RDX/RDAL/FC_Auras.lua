-- FC_Auras.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Filter Components dealing with buffs and debuffs.
RDX.RegisterFilterComponentCategory(i18n("Auras"));


-- Debuff Type: magic
RDX.RegisterFilterComponent({
	name = "dmagic", title = i18n("Magic"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "debuff", buff = "@magic" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

-- Debuff Type: curse
RDX.RegisterFilterComponent({
	name = "dcurse", title = i18n("Curse"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "debuff", buff = "@curse" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

-- Debuff Type: disease
RDX.RegisterFilterComponent({
	name = "ddisease", title = i18n("Disease"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "debuff", buff = "@disease" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

-- Debuff Type: poison
RDX.RegisterFilterComponent({
	name = "dpoison", title = i18n("Poison"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "debuff", buff = "@poison" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

-- Debuff Type: other
RDX.RegisterFilterComponent({
	name = "dother", title = i18n("Other"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "debuff", buff = "@other" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

-- Debuff by name
RDX.RegisterFilterComponent({
	name = "debuff_n", title = i18n("Debuff (by name)"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "debuff" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

-- Buff by name
RDX.RegisterFilterComponent({
	name = "buff_n", title = i18n("Buff (by name)"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "buff" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});
-- MyBuff by name by sigg
RDX.RegisterFilterComponent({
	name = "mybuff_n", title = i18n("MyBuff (by name)"), category = i18n("Auras"),
	UIFromDescriptor = VFL.Nil,
	GetBlankDescriptor = function() return {"set", { class = "mybuff" } }; end,
	FilterFromDescriptor = VFL.Nil,
	EventsFromDescriptor = VFL.Nil,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});
