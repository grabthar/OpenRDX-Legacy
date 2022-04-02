-- Filters.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--

----------------------------------------------------------------------
-- FILTER FUNCTOR CONSTRUCTION
----------------------------------------------------------------------
-- Build a closure string from metadata
function RDX.FilterBuildClosureStringFromMetadata(md)
	local cl = "";
	for _,mde in pairs(md) do
		if mde.class == "CLOSURE" then
			cl = cl .. "local " .. mde.name .. "=";
			if mde.value then cl = cl .. mde.value ..";" else
				cl = cl .. "nil;";
				cl = cl .. mde.script;
			end
		end
	end
	return cl;
end

-- Build a locals string from metadata
function RDX.FilterBuildLocalsStringFromMetadata(md)
	local cl = "";
	for _,mde in pairs(md) do
		if mde.class == "LOCAL" then
			cl = cl .. "local " .. mde.name .. "=" .. mde.value .. ";";
		end
	end
	return cl;
end

------ Unique name generation
local clid = 0;
local function ResetFilterUpvalues()
	clid = 0;
end

--- Generate a unique variable name. Designed for use in filters that require closures.
function RDX.GenerateFilterUpvalue()
	clid = clid + 1;
	return "v" .. clid;
end

--- Generate a filter function from a descriptor.
function RDX.FilterFunctor(fd)
	-- Find root component
	local rootComp = RDX.GetFilterComponent(fd);
	if not rootComp then return nil; end
	-- Build filter expression
	local meta = {};
	ResetFilterUpvalues();
	local expr = rootComp.FilterFromDescriptor(fd, meta); if not expr then return nil; end
	-- Prepend closures and locals
	local cl, loc = RDX.FilterBuildClosureStringFromMetadata(meta), RDX.FilterBuildLocalsStringFromMetadata(meta);
	--RDX:Debug(1, "RDX.FilterFunctor(): generating filter: " .. cl .. "return function(unit) " .. loc .. " return " .. expr .. "; end;");
	-- We should now have an evaluable expression that will return our filter function...
	--local f_filtergen, f_err = loadstring(cl .. " return function(unit) " .. loc .. " return (unit:IsValid() and " .. expr .. "); end;");
	local f_filtergen, f_err = loadstring(cl .. " return function(unit) " .. loc .. " return (unit:IsCacheValid() and " .. expr .. "); end;");
	if not f_filtergen then 
		VFL.TripError("RDX", i18n("Could not build filter.", "Filter:\n------------------\n") .. Serialize(fd) .. i18n("\n\nError:\n----------------------\n") .. f_err);
		return; 
	end
	-- We have a filter, return it along with some metadata.
	return f_filtergen(), rootComp, meta;
end

--- Validate a filter descriptor.
function RDX.ValidateFilter(fd)
	local cmp = RDX.GetFilterComponent(fd); 
	-- BUGFIX: An empty filter is invalid.
	if not cmp then return nil; end
	return cmp.ValidateDescriptor(fd);
end

--------------------------------------------------
-- FILTER COMPONENT MANAGEMENT
--------------------------------------------------
-- The filter components database
local filterComponents = {};
local filterCategory = {};
local filterCategories = {};

--- Gets the filter component for the given descriptor.
-- @param desc The filter descriptor.
-- @return The filter class for the given descriptor, or NIL if it wasn't possible.
function RDX.GetFilterComponent(desc)
	if not desc then return nil; end
	-- desc[1] is the filter class
	local fcn = desc[1];
	if not fcn then return nil; end
	-- Lookup the filter class
	return filterComponents[fcn];
end

--- Gets a filter component by name
function RDX.GetFilterComponentByName(name)
	return filterComponents[name];
end

-- Register a filter category
function RDX.RegisterFilterComponentCategory(cat)
	local cdata = {};
	filterCategory[cat] = cdata;
	table.insert(filterCategories, {name = cat, entries = cdata});
end

RDX.RegisterFilterComponentCategory(i18n("Uncategorized"));


-- Register a filter component
function RDX.RegisterFilterComponent(data)
	if not data.name then error(i18n("RDX.RegisterFilterComponent: attempt to register unnamed filter component.")); end
	if filterComponents[data.name] then error(i18n("RDX.RegisterFilterComponent: double registration of filter component ") .. data.name); end
	filterComponents[data.name] = data;
	-- Make sure we have a title.
	if not data.title then data.title = data.name; end
	-- Categorize
	local cat = data.category; if not cat then cat = i18n("Uncategorized"); end
	local qq = filterCategory[cat]; if not qq then qq = filterCategory[i18n("Uncategorized")]; end
	table.insert(qq, data);
end

---------------------------------------------------
-- FILTER UI
---------------------------------------------------

------------------- Drag and Drop impl
-- The drag context for filters
RDXUI.dcFilters = VFLUI.DragContext:new();

-- Generate a frame onto which a filter can be dropped.
function RDXUI.GenerateFilterDropTarget(parent)
	local self = VFLUI.AcquireFrame("Button");
	if parent then
		self:SetParent(parent); self:SetFrameStrata(parent:GetFrameStrata()); self:SetFrameLevel(parent:GetFrameLevel() + 1);
	end

	local tex = VFLUI.CreateTexture(self);
	tex:SetDrawLayer("BACKGROUND");
	tex:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4);
	tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4);
	tex:SetTexture(1, 1, 1, 0.2);
	tex:Hide();
	
	self:SetBackdrop(VFLUI.DefaultDialogBackdrop);
	self:SetNormalFontObject(Fonts.DefaultItalic);
	self:SetText(i18n("(Drag a filter component here)"));
	--self:SetTextColor(.6, .6, .6);
	self:SetHeight(30);

	-- Empty OnLayout method
	self.DialogOnLayout = VFL.Noop;
	-- On drag start/stop, highlight
	self.OnDragStart = function() tex:SetTexture(1, 1, 1, 0.2); tex:Show(); end
	self.OnDragStop = function() tex:Hide(); end
	-- On drag enter/leave, highlight brightly
	self.OnDragEnter = function() tex:SetTexture(1, 1, 1, 0.4); end
	self.OnDragLeave = function() tex:SetTexture(1, 1, 1, 0.2); end

	self.Destroy = VFL.hook(function(s)
		s.DialogOnLayout = nil;
		s.OnDragStart = nil; s.OnDragStop = nil; s.OnDragEnter = nil; s.OnDragLeave = nil; s.OnDrop = nil;
		RDXUI.dcFilters:UnregisterDragTarget(s);
		VFLUI.ReleaseRegion(tex); tex = nil;
	end, self.Destroy);

	RDXUI.dcFilters:RegisterDragTarget(self);
	return self;
end


--------------- Dialog box helpers
-- A dialog control for filter entries.
RDXUI.FilterDialogFrame = {};
function RDXUI.FilterDialogFrame:new(parent)
	local self = VFLUI.PassthroughFrame:new(nil, parent);
	self:SetBackdrop(VFLUI.DefaultDialogBorder);
	self:SetInsets(5, 17, 5, 5);

	local btn = VFLUI.CloseButton:new(self, 12);
	btn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -5, -5);
	btn:Hide();

	local label = VFLUI.CreateFontString(self);
	label:SetHeight(12); label:SetWidth(50);
	label:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -5);
	label:SetFontObject(Fonts.Default10); label:SetJustifyH("LEFT");
	label:Show();

	local oldSetChild = self.SetChild;
	self.SetChild = function(s, child)
		oldSetChild(s, child);
		s:SetCollapsed(nil);
	end

	self.DialogOnLayout = VFL.hook(function(s)
		label:SetWidth(math.max(s:GetWidth() - 25, 0));
	end, self.DialogOnLayout);

	self.EnableCloseButton = function(s, onClose)
		btn:Show();
		btn:SetScript("OnClick", onClose);
	end;
	self.SetText = function(s, t) 
		label:SetText(t); 
	end

	self.Destroy = VFL.hook(function(s)
		s.GetDescriptor = nil; s.EnableCloseButton = nil; s.SetText = nil;
		btn:Destroy(); btn = nil;
		VFLUI.ReleaseRegion(label); label = nil;
	end, self.Destroy);

	return self;
end


-- Helper function to build a selectable menu of all filter categories.
local function CreateCategoryEntry(cat)
	return { text = cat, hlt = { r=0, g=0.5, b=0.7, a=.75 } };
end
RDXUI._CreateCategoryEntry = CreateCategoryEntry; -- Export this function for use elsewhere.
local function CreateFilterEntry(filt)
	local fn, ft = filt.name, filt.title;
	return { text = ft, OnMouseDown = function()
		RDXUI.dcFilters:Drag(this, VFLUI.CreateGenericDragProxy(this, ft, fn));
	end };
end
local function BuildFilterComponentMenu()
	local ret = {};
	for _,cdata in pairs(filterCategories) do
		table.insert(ret, CreateCategoryEntry(cdata.name));
		for _,fdata in pairs(cdata.entries) do
			table.insert(ret, CreateFilterEntry(fdata));
		end
	end
	return ret;
end

---------------------------------------------
-- Filter editor UI
---------------------------------------------
RDX.FilterEditor = {};
function RDX.FilterEditor:new(parent)
	-- The dialog itself
	local dlg = VFLUI.AcquireFrame("Frame");
	if parent then
		dlg:SetParent(parent); 
		dlg:SetFrameStrata(parent:GetFrameStrata());
		dlg:SetFrameLevel(parent:GetFrameLevel() + 1);
	end
	dlg:SetHeight(320); dlg:SetWidth(500);
	dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
	dlg:Show();

	------------ Left side: drag-and-drop component list
	local compList = VFLUI.List:new(dlg, 12, VFLUI.Selectable.AcquireCell);
	compList:SetPoint("TOPLEFT", dlg, "TOPLEFT", 5, -25);
	compList:SetWidth(150); compList:SetHeight(288); compList:Rebuild();
	compList:Show();
	compList:SetDataSource(VFLUI.Selectable.ApplyData_TextOnly, VFL.ArrayLiterator(BuildFilterComponentMenu()));
	compList:Update();

	--------------- Right side: the UI
	local sf = VFLUI.VScrollFrame:new(dlg);
	sf:SetWidth(324); sf:SetHeight(310);
	sf:SetPoint("TOPLEFT", compList, "TOPRIGHT", 0, 20);
	sf:Show();
	
	local ui = nil;
	local function ResetFilterUI()
		if ui then ui:Hide(); sf:SetScrollChild(nil); ui:Destroy(); ui = nil; end
	end
	
	local function SetFilterUI(x)
		if ui or (not x) then return nil; end
		ui = x; ui.isLayoutRoot = true;
		ui:SetParent(sf);
		sf:SetScrollChild(ui);
		if ui.EnableCloseButton then
			ui:EnableCloseButton(function() ResetFilterUI(); dlg:LoadEmpty(); end);
		end
		ui:SetWidth(sf:GetWidth());
		ui:DialogOnLayout();
		ui:Show();
	end

	--- "And Wrap" button
	local btnAndWrap = VFLUI.Button:new(dlg);
	btnAndWrap:SetPoint("TOPLEFT", dlg, "TOPLEFT", 5, -5);
	btnAndWrap:SetHeight(20); btnAndWrap:SetWidth(150);
	btnAndWrap:SetNormalFontObject(Fonts.Default10);
	btnAndWrap:SetText(i18n("And Wrap")); btnAndWrap:Show();
	btnAndWrap:SetScript("OnClick", function()
		local d = dlg:GetDescriptor(); if not d then return; end
		if (d[1] == "and") then return; end
		dlg:LoadDescriptor({"and", d});
	end);

	dlg.LoadEmpty = function(x)
		local dragTarget = RDXUI.GenerateFilterDropTarget(sf);
		dragTarget.isLayoutRoot = true;
		function dragTarget:OnDrop(dropped)
			local fc = RDX.GetFilterComponentByName(dropped.data);
			if not fc then error(i18n("CompoundFilterUI: an invalid filter component was drag-and-dropped.")); return; end
			ResetFilterUI();
			local desc = fc.GetBlankDescriptor();
			fc = RDX.GetFilterComponent(desc);
			SetFilterUI(fc.UIFromDescriptor(desc, sf));
		end
		ResetFilterUI(); SetFilterUI(dragTarget);
	end

	dlg.LoadDescriptor = function(x, descr)
		if type(descr) ~= "table" then x:LoadEmpty(); return; end
		-- Create the new UI
		local fc = RDX.GetFilterComponent(descr);
		if fc then
			local nui = fc.UIFromDescriptor(descr, sf);
			if nui then ResetFilterUI(); SetFilterUI(nui); return true; end
		end
		x:LoadEmpty(); return nil;
	end

	dlg.GetDescriptor = function(x)
		if (not ui) or (not ui.GetDescriptor) then return nil; end
		local desc = ui:GetDescriptor();
		return desc;
	end

	dlg.Destroy = VFL.hook(function(s)
		btnAndWrap:Destroy(); btnAndWrap = nil;
		ResetFilterUI();
		compList:Destroy(); sf:Destroy();
		s.LoadDescriptor = nil; s.LoadEmpty = nil; s.GetDescriptor = nil;
	end, dlg.Destroy);

	return dlg;
end

--- Generic empty filter UI generating function
function RDX.TrivialFilterUI(filtName, filtText)
	return function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(filtText); ui:Show();
		ui.GetDescriptor = function() return {filtName}; end
		return ui;
	end;
end

-----------------------------------------------------------------------
-- FILTER COMPONENTS
--
-- Filter components are the stuff from which filters are built. Each filter component
-- has its own embedded UI and must be capable of generating, from the output of that UI,
-- an object known as a Descriptor. The Descriptor is a simple array whose first entry is the
-- filter component being used and whose subsequent entries are the parameters. (The parameters
-- may themselves be other Components! see the Logic filter components)
--
-- From the Descriptor is generated the filter function, which takes a single argument (an RDX Unit
-- object) and returns true or false based on whether the object is accepted or rejected by the filter.
-- 
-- The Descriptor is also responsible for generating an events table, which is used by the FilterSet
-- object in the RDX engine to decide how to respond to game events.
--------------------------------------------------------------------------
-- *** FILTER COMPONENTS WERE MOVED OUT TO THEIR OWN FILES FC_*.lua ***



-------------------------------------------------------
-- UPDATE TRIGGERS
-------------------------------------------------------
function RDX.FilterEvents_FullUpdate(md, ev, adapter)
	if not md[ev] then
		md[ev] = { actionid = 2, adapter = adapter };
	elseif md[ev].actionid == 1 then
		md[ev].actionid = 2; md[ev].adapter = adapter;
	end
end

function RDX.FilterEvents_UnitUpdate(md, ev, adapter)
	if not md[ev] then
		md[ev] = { actionid = 1, adapter = adapter };
	end
end

