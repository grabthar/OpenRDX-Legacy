-- FC_GroupComposition.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- Filter components relating to raid-group composition.
RDX.RegisterFilterComponentCategory(i18n("Group Composition"));

--------------------------------
-- Match anyone in the raid
--------------------------------
RDX.RegisterFilterComponent({
	name = "ne1", title = i18n("Everyone"), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Everyone")); ui:Show();
		ui.GetDescriptor = function() return {"ne1"}; end;
		return ui;
	end,
	GetBlankDescriptor = function() return {"ne1"}; end,
	FilterFromDescriptor = function(desc, metadata)
		return "(true)";
	end,
	EventsFromDescriptor = VFL.Noop,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

--------------------------------
-- Match the player
--------------------------------
RDX.RegisterFilterComponent({
	name = "me", title = i18n("Me"), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Me")); ui:Show();
		ui.GetDescriptor = function() return {"me"}; end;
		return ui;
	end,
	GetBlankDescriptor = function() return {"me"}; end,
	FilterFromDescriptor = function(desc, metadata)
		return "(UnitIsUnit(unit.uid, RDXPlayer.uid))";
	end,
	EventsFromDescriptor = VFL.Noop,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

--------------------------------
-- Individual groups
--------------------------------
RDX.RegisterFilterComponent({
	name = "groups", title = i18n("Groups..."), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		-- Setup the base frame and the checkboxes for groups
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Groups..."));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(8, 2);
		for i=1,8 do 
			checks.checkBox[i]:SetText(i18n("Group ") .. i);
			if desc[i + 1] then checks.checkBox[i]:SetChecked(true); end
		end

		ui.GetDescriptor = function(x)
			local ret = {"groups"};
			for i=1,8 do
				if checks.checkBox[i]:GetChecked() then ret[i+1] = true; else ret[i+1] = nil; end
			end
			return ret;
		end

		return ui;
	end,
	GetBlankDescriptor = function() return {"groups"}; end,
	FilterFromDescriptor = function(desc, metadata)
		-- Build the filtration array.
		local v = RDX.GenerateFilterUpvalue();
		local script = v .. "={};";
		for i=2,9 do
			if desc[i] then script = script .. v .. "[" .. i-1 .. "]=true;"; end
		end
		table.insert(metadata, { class = "CLOSURE", name = v, script = script });
		-- Now, our filter expression is just a check on the closure array against the unit's group number.
		return "(" .. v .. "[unit:GetGroup()])";
	end,
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_FullUpdate(metadata, "ROSTER_UPDATE");
	end,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

RDX.RegisterFilterComponent({
	name = "mygroup", title = i18n("My Group"), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("My Group")); ui:Show();
		ui.GetDescriptor = function() return {"mygroup"}; end
		return ui;
	end,
	GetBlankDescriptor = function() return {"mygroup"}; end,
	FilterFromDescriptor = function(desc, metadata)
		return "(unit:GetGroup() == RDXPlayer:GetGroup())";
	end,
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_FullUpdate(metadata, "ROSTER_UPDATE");
	end,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

RDX.RegisterFilterComponent({
	name = "mygroupid", title = i18n("My Group ID"), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		-- Setup the base frame and the checkboxes for groups
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("My Group ID"));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(4, 2);
		for i=1,4 do 
			checks.checkBox[i]:SetText(i18n("Member ") .. i);
			if desc[i + 1] then checks.checkBox[i]:SetChecked(true); end
		end

		ui.GetDescriptor = function(x)
			local ret = {"mygroupid"};
			for i=1,4 do
				if checks.checkBox[i]:GetChecked() then ret[i+1] = true; else ret[i+1] = nil; end
			end
			return ret;
		end

		return ui;
	end,
	GetBlankDescriptor = function() return {"mygroupid"}; end,
	FilterFromDescriptor = function(desc, metadata)
		-- Build the filtration array.
		local v = RDX.GenerateFilterUpvalue();
		local script = v .. "={};";
		for i=2,5 do
			if desc[i] then script = script .. v .. "[" .. i-1 .. "]=true;"; end
		end
		table.insert(metadata, { class = "CLOSURE", name = v, script = script });
		return "(" .. v .. "[unit:GetMemberGroupId()])";
	end,
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_FullUpdate(metadata, "ROSTER_UPDATE");
	end,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

---------------------------------------------------------------
-- Match classes
---------------------------------------------------------------
RDX.RegisterFilterComponent({
	name = "classes", title = i18n("Classes..."), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		-- Setup the base frame and the checkboxes for groups
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Classes..."));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(11, 2);
		-- Populate checkboxes
		for i=1,10 do 
			checks.checkBox[i]:SetText(strtcolor(RDXCT.GetClassColor(i)) .. RDXCT.GetClassMnemonic(i) .. "|r"); 
			if desc[i + 1] then checks.checkBox[i]:SetChecked(true); end
		end
		checks.checkBox[11]:SetText(strcolor(.5,.5,.5) .. i18n("UNKNOWN") .. "|r");
		if desc[12] then checks.checkBox[11]:SetChecked(true); end

		ui.GetDescriptor = function(x)
			local ret = {"classes"};
			for i=1,11 do
				if checks.checkBox[i]:GetChecked() then ret[i+1] = true; else ret[i+1] = nil; end
			end
			return ret;
		end

		return ui;
	end,
	GetBlankDescriptor = function() return {"classes"}; end,
	FilterFromDescriptor = function(desc, metadata)
		-- Build the filtration array
		local v = RDX.GenerateFilterUpvalue();
		local script = v .. "={};";
		for i=2,11 do
			if desc[i] then script = script .. v .. "[" .. i-1 .. "]=true;"; end
		end
		if desc[11] then script = script .. v .. "[0]=true;"; end
		table.insert(metadata, { class = "CLOSURE", name = v, script = script });
		-- Now, our filter expression is just a check on the closure array against the unit's class
		return "(" .. v .. "[unit:GetClassID()])";
	end,
	ValidateDescriptor = VFL.True,
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_FullUpdate(metadata, "ROSTER_UPDATE");
	end,
	SetsFromDescriptor = VFL.Noop,
});

RDX.RegisterFilterComponent({
	name = "rl", title = i18n("Leaders..."), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Leaders..."));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(2,2);
		checks.checkBox[1]:SetText(i18n("(L) Leader")); if desc[2] then checks.checkBox[1]:SetChecked(true); end
		checks.checkBox[2]:SetText(i18n("(A) Assistant")); if desc[3] then checks.checkBox[2]:Setchecked(true); end
		
		ui.GetDescriptor = function(x)
			local ret = {"rl"};
			for i=1,2 do if checks.checkBox[i]:GetChecked() then ret[i+1] = true; end end
			return ret;
		end
		
		return ui;
	end,
	GetBlankDescriptor = function() return {"rl"}; end,
	FilterFromDescriptor = function() return "(true)"; end,
	ValidateDescriptor = VFL.True,
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_FullUpdate(metadata, "ROSTER_UPDATE");
	end,
	SetsFromDescriptor = VFL.Noop,
});

----------------------------------------------
-- Player vs. pet unit mask component
----------------------------------------------
RDX.RegisterFilterComponent({
	name = "nidmask"; title = i18n("Player and Pet"); category = i18n("Group Composition");
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Unit NID mask"));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(2,2);
		checks.checkBox[1]:SetText(i18n("Match players")); checks.checkBox[2]:SetText(i18n("Match pets"));
		for i=1,2 do
			if desc[i+1] then checks.checkBox[i]:SetChecked(true); end
		end

		function ui:GetDescriptor()
			local ret = {"nidmask"};
			for i=1,2 do
				if checks.checkBox[i]:GetChecked() then ret[i+1] = true; end
			end
			return ret;
		end

		return ui;
	end;
	GetBlankDescriptor = function() return {"nidmask"}; end;
	FilterFromDescriptor = function(desc, metadata)
		local lowv, highv = 1, 40;
		if desc[2] or desc[3] then
			if not desc[2] then lowv = 41; highv = 80; -- just pets
			elseif desc[3] then lowv = 1; highv = 80; -- players and pets
			end
			-- just players
		end
		table.insert(metadata, {class = "LOCAL", name = "nid", value = "unit.nid"})
		return "(nid and (nid >= " .. lowv ..") and (nid <= " .. highv .. "))";
	end;
	EventsFromDescriptor = VFL.Noop;
	SetsFromDescriptor = VFL.Noop;
	ValidateDescriptor = VFL.True;
});

----------------------------------------------
-- Arena component
----------------------------------------------
RDX.RegisterFilterComponent({
	name = "arena"; title = i18n("Arena and Pet"); category = i18n("Group Composition");
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Arena"));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(2,2);
		checks.checkBox[1]:SetText(i18n("Match players")); checks.checkBox[2]:SetText(i18n("Match pets"));
		for i=1,2 do
			if desc[i+1] then checks.checkBox[i]:SetChecked(true); end
		end

		function ui:GetDescriptor()
			local ret = {"arena"};
			for i=1,2 do
				if checks.checkBox[i]:GetChecked() then ret[i+1] = true; end
			end
			return ret;
		end

		return ui;
	end;
	GetBlankDescriptor = function() return {"arena"}; end;
	FilterFromDescriptor = function(desc, metadata)
		local lowv, highv = 81, 85;
		if desc[2] or desc[3] then
			if not desc[2] then lowv = 86; highv = 90; -- just pets
			elseif desc[3] then lowv = 81; highv = 90; -- players and pets
			end
		end
		table.insert(metadata, {class = "LOCAL", name = "nid", value = "unit.nid"})
		return "(nid and (nid >= " .. lowv ..") and (nid <= " .. highv .. "))";
	end;
	EventsFromDescriptor = VFL.Noop;
	SetsFromDescriptor = VFL.Noop;
	ValidateDescriptor = VFL.True;
});

----------------------------------------------
-- Power type filter component
----------------------------------------------
RDX.RegisterFilterComponent({
	name = "ptype", title = i18n("Power Type"), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		-- Create checkboxes for each power type
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Power Types..."));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(4, 4);
		checks.checkBox[1]:SetText(i18n("Mana"));
		checks.checkBox[2]:SetText(i18n("Rage"));
		checks.checkBox[3]:SetText(i18n("Energy"));
		checks.checkBox[4]:SetText(i18n("Rune"));
		for i=1,4 do 
			if desc[i + 1] then checks.checkBox[i]:SetChecked(true); end
		end
		ui.GetDescriptor = function(x)
			local ret = {"ptype"};
			for i=1,4 do
				if checks.checkBox[i]:GetChecked() then ret[i+1] = true; end
			end
			return ret;
		end

		return ui;
	end,
	GetBlankDescriptor = function() return {"ptype"}; end,
	FilterFromDescriptor = function(desc, metadata)
		-- Build the filtration array.
		local v = RDX.GenerateFilterUpvalue();
		local script = v .. "={};";
		if desc[2] then script = script .. v .. "[0]=true;"; end  -- mana
		if desc[3] then script = script .. v .. "[1]=true;"; end  -- rage
		if desc[4] then script = script .. v .. "[3]=true;"; end  -- energy
		if desc[5] then script = script .. v .. "[6]=true;"; end  -- rune
		table.insert(metadata, { class = "CLOSURE", name = v, script = script });
		return "(" .. v .. "[unit:PowerType()])";
	end,
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_UnitUpdate(metadata, "UNIT_DISPLAYPOWER");
	end,
	SetsFromDescriptor = VFL.Noop,
	ValidateDescriptor = VFL.True,
});

