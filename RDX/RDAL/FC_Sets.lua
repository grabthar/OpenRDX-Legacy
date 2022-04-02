-- FC_Sets.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- Filter components that query other Sets.
RDX.RegisterFilterComponentCategory(i18n("Sets"));

RDX.RegisterFilterComponent({
	name = "set", title = i18n("Set"), category = i18n("Sets"),
	UIFromDescriptor = function(desc, parent)
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Set...")); ui:Show();

		local sf = RDX.SetFinder:new(ui);
		ui:SetChild(sf); sf:Show();
		if desc[2] then sf:SetDescriptor(desc[2]); end

		ui.GetDescriptor = function(x)
			return {"set", sf:GetDescriptor()};
		end

		return ui;
	end,
	GetBlankDescriptor = function() return {"set"}; end,
	ValidateDescriptor = function(desc)
		if desc and desc[2] then
			return RDX.ValidateSet(desc[2]);
		end
		--return true;
	end,
	FilterFromDescriptor = function(desc, metadata)
		if not desc[2] then return "(true)"; end
		local theSet = RDX.FindSet(desc[2]); if not theSet then return "(true)"; end
		local v = RDX.GenerateFilterUpvalue();
		table.insert(metadata, {
			class = "CLOSURE", name = v,
			script = v .. "=RDX.FindSet(" .. Serialize(desc[2]) .. ");"
		});
		return "(" .. v .. ":IsMember(unit))";
	end,
	EventsFromDescriptor = VFL.Noop,
	SetsFromDescriptor = function(desc, metadata)
		local theSet = RDX.FindSet(desc[2]);
		if theSet then metadata[theSet.sid] = true; end
	end
});

