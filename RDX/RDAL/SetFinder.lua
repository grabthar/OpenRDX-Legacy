-- SetFinder.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- Interfaces and helper methods for locating sets inside RDX's memory space.

local setClasses = {};

--- Register a set class. A set class must have several fields:
-- GetUI(parent, descr) - construct a UI for choosing a set of this class. The UI must have a
--   GetDescriptor() method that returns the selected descriptor.
--
-- FindSet(descr) - Find a set of this class, given the descriptor. Can return NIL if no such
-- set exists.
function RDX.RegisterSetClass(tbl)
	if not tbl then error(i18n("expected table, got nil")); end
	local n = tbl.name;
	if not n then error(i18n("attempt to register anonymous set class")); end
	if setClasses[n] then error(i18n("attempt to register duplicate set class")); end
	setClasses[n] = tbl;
	return true;
end

local function GetSetClassByName(n)
	if not n then return nil; end
	return setClasses[n];
end

--- Find a set given the descriptor returned by the set finder.
function RDX.FindSet(descr)
	if not descr then return nil; end
	local cls = GetSetClassByName(descr.class); if not cls then return nil; end
	return cls.FindSet(descr);
end

--- Validate a set
function RDX.ValidateSet(descr)
	if not descr then return nil; end
	local cls = GetSetClassByName(descr.class); if not cls then return nil; end
	if cls.ValidateSet then return cls.ValidateSet(descr); else return true; end
end

--- Create a new set finder
local noneDesc = {class = "none"};
RDX.SetFinder = {};
function RDX.SetFinder:new(parent)
	local self = RDXUI.SelectEmbed:new(parent, 150, function()
		local qq = {};
		for k,v in pairs(setClasses) do table.insert(qq, {text = v.title, value = v}); end
		return qq;
	end, function(ctl, desc)
		local cls = GetSetClassByName(desc.class);
		if cls then
			return cls.GetUI(ctl, desc), cls.title, cls;
		end
	end);
	self:SetText(i18n("Set class:"));
	self:SetDescriptor(noneDesc);
	return self;
end

-- Create a trivial GetUI() function for the set finder.
function RDX.TrivialSetFinderUI(class)
	return function(parent, desc)
		local ui = VFLUI.AcquireFrame("Frame");
		ui.GetDescriptor = function() return {class = class}; end
		ui.DialogOnLayout = VFL.Noop;
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil; end, ui.Destroy);
		return ui;
	end;
end

------------- Basic set classes.
RDX.RegisterSetClass({
	name = "none";
	title = i18n("None");
	GetUI = RDX.TrivialSetFinderUI("none");
	FindSet = function() return nil; end
});

RDX.RegisterSetClass({
	name = "group";
	title = i18n("Group");
	GetUI = RDX.TrivialSetFinderUI("group");
	FindSet = function() return RDX.groupSet; end
});

RDX.RegisterSetClass({
	name = "empty";
	title = i18n("Empty Set");
	GetUI = RDX.TrivialSetFinderUI("empty");
	FindSet = function() return RDX.emptySet; end
});

RDX.RegisterSetClass({
	name = "file",
	title = i18n("File"),
	GetUI = function(parent, desc)
		local ui = RDXDB.ObjectFinder:new(parent, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "Set$")); end);
		ui:SetLabel(i18n("File")); ui:Show();
		if desc and desc.file then ui:SetPath(desc.file); end
		ui.GetDescriptor = function()
			return {class = "file", file = ui:GetPath()};
		end
		ui.Destroy = VFL.hook(function(s) s.GetDescriptor = nil; end, ui.Destroy);

		return ui;
	end,
	FindSet = function(desc)
		if not desc.file then return nil; end
		return RDXDB.GetObjectInstance(desc.file);
	end,
});


