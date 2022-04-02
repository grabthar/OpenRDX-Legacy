-- SortFuncs.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Various operators for sorting.

------------------------------------------------------------
-- BASIC PROPERTIES
------------------------------------------------------------
RDX.RegisterSortOperatorCategory(i18n("Basic"));
-- Unit number sort
RDX.RegisterSortOperator({
	name = "nid";
	title = i18n("Unit Number (nid)");
	category = i18n("Basic");
	EmitCode = function(desc, code, context)
		if desc.reversed then
			code:AppendCode([[return u1.nid > u2.nid;]]);
		else
			code:AppendCode([[return u1.nid < u2.nid;]]);
		end
	end;
	GetUI = RDX.TrivialSortUI("nid", i18n("Unit Numerical ID"));
	GetBlankDescriptor = function() return {op = "nid"}; end;
});

-- Alpha sort.
RDX.RegisterSortOperator({
	name = "alpha";
	title = i18n("Alphabetical");
	category = i18n("Basic");
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if u1.name == u2.name then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[
else
]]);
		if desc.reversed then
			code:AppendCode([[return u1.name > u2.name;]]);
		else
			code:AppendCode([[return u1.name < u2.name;]]);
		end
code:AppendCode([[
end
]]);	
	end;
	GetUI = RDX.TrivialSortUI("alpha", i18n("Alphabetical"));
	GetBlankDescriptor = function() return {op = "alpha"}; end;
});

-- Class sort.
RDX.RegisterSortOperator({
	name = "class";
	title = i18n("Class");
	category = i18n("Basic");
	EmitLocals = function(desc, code, vars)
		if not vars["classid"] then
			vars["classid"] = true;
			code:AppendCode([[
local classid1,classid2 = u1:GetClassID(), u2:GetClassID();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if classid1 == classid2 then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[
else
]]);
		if desc.reversed then
			code:AppendCode([[return classid1 > classid2;]]);
		else
			code:AppendCode([[return classid1 < classid2;]]);
		end
code:AppendCode([[
end
]]);	
	end;
	GetUI = RDX.TrivialSortUI("class", i18n("Class"));
	GetBlankDescriptor = function() return {op = "class"}; end;
});

-- Grp# sort.
RDX.RegisterSortOperator({
	name = "group";
	title = i18n("Group");
	category = i18n("Basic");
	EmitLocals = function(desc, code, vars)
		if not vars["group"] then
			vars["group"] = true;
			code:AppendCode([[
local group1,group2 = u1:GetGroup(), u2:GetGroup();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if group1 == group2 then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[
else
]]);
		if desc.reversed then
			code:AppendCode([[return group1 > group2;]]);
		else
			code:AppendCode([[return group1 < group2;]]);
		end
code:AppendCode([[
end
]]);	
	end;
	Events = function(desc, ev) ev["ROSTER_UPDATE"] = true; end;
	GetUI = RDX.TrivialSortUI("group", i18n("Group"));
	GetBlankDescriptor = function() return {op = "group"}; end;
});

--------------------------------------------------------------
-- UNIT STATUS
--------------------------------------------------------------
RDX.RegisterSortOperatorCategory(i18n("Status"));
-- HP% sort.
RDX.RegisterSortOperator({
	name = "hpp";
	title = i18n("HP%");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["fh"] then
			vars["fh"] = true;
			code:AppendCode([[
local fh1,fh2 = u1:FracHealth(), u2:FracHealth();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(fh1 == fh2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return fh1 > fh2;]]);
		else
			code:AppendCode([[return fh1 < fh2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("hpp", i18n("HP%"));
	GetBlankDescriptor = function() return {op = "hpp"}; end;
	Events = function(desc, ev) ev["UNIT_HEALTH"] = true; end
});

-- HP sort.
RDX.RegisterSortOperator({
	name = "hp";
	title = i18n("HP");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["h"] then
			vars["h"] = true;
			code:AppendCode([[
local h1,h2 = u1:Health(), u2:Health();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(h1 == h2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return h1 > h2;]]);
		else
			code:AppendCode([[return h1 < h2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("hp", i18n("HP"));
	GetBlankDescriptor = function() return {op = "hp"}; end;
	Events = function(desc, ev) ev["UNIT_HEALTH"] = true; end
});

-- MP% sort.
RDX.RegisterSortOperator({
	name = "mpp";
	title = i18n("Power%");
	category = i18n("Status");
	EmitLocals = function(desc, code, vars)
		if not vars["fm"] then
			vars["fm"] = true;
			code:AppendCode([[
local fm1,fm2 = u1:FracPower(), u2:FracPower();
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if(fm1 == fm2) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[else
]]);
		if desc.reversed then
			code:AppendCode([[return fm1 > fm2;]]);
		else
			code:AppendCode([[return fm1 < fm2;]]);
		end
code:AppendCode([[
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("mpp", i18n("Mana%"));
	GetBlankDescriptor = function() return {op = "mpp"}; end;
	Events = function(desc, ev) ev["UNIT_POWER"] = true; end
});

------------------------------------------------------------------
-- COLLATION
------------------------------------------------------------------
RDX.RegisterSortOperatorCategory(i18n("Collate"));
RDX.RegisterSortOperator({
	name = "cset";
	title = i18n("Collate Set");
	category = i18n("Collate");
	EmitClosure = function(desc, code, vars)
		code:AppendCode([[
local ]] .. desc.vname .. [[ = RDX.FindSet(]] .. Serialize(desc.set) .. [[);
]]);
	end;
	EmitLocals = function(desc, code, vars)
		code:AppendCode([[
local ]] .. desc.vname .. [[_1 = ]] .. desc.vname .. [[:IsMember(u1);
local ]] .. desc.vname .. [[_2 = ]] .. desc.vname .. [[:IsMember(u2);
]]);
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if (]] .. desc.vname .. [[_1 and ]] .. desc.vname .. [[_2) or ((not ]] .. desc.vname .. [[_1) and (not ]] .. desc.vname .. [[_2)) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[elseif ]] .. desc.vname .. [[_1 then
	return true;
else
	return nil
end
]]);
	end;
	Events = function(desc, ev)
		local set = RDX.FindSet(desc.set);
		ev["_SET_" .. desc.vname] = set;
	end;
	GetUI = function(parent, desc)
		local ui = RDXUI.SortDialogFrame:new(parent);
		ui:SetText(i18n("Collate by set...")); ui:Show();

		local sf = RDX.SetFinder:new(ui);
		ui:SetChild(sf); sf:Show();
		if desc.set then sf:SetDescriptor(desc.set); end

		ui.GetDescriptor = function(x)
			return {op = "cset"; vname = desc.vname or ("cs" .. math.random(1,10000000)); set = sf:GetDescriptor()};
		end

		return ui;
	end;
	GetBlankDescriptor = function() return {op = "cset"; vname = "cs" .. math.random(1, 10000000)}; end;
});

-----------------------------------------------------------------
-- Implements a defined sort order for classes
--
-- Copyright 2006 Jim Zajkowski, wenge.feathermoon@gmail.com
-----------------------------------------------------------------
local function CreateElevatorWidget(parent)
	local self = VFLUI.AcquireFrame("Frame");
	VFLUI.StdSetParent(self, parent);
	self:SetHeight(12);

	local dnbtn = VFLUI.TexturedButton:new(self, 12, "Interface\\Addons\\VFL\\Skin\\sb_down");
	dnbtn:SetPoint("LEFT", self, "LEFT");
	dnbtn:Show();
	local upbtn = VFLUI.TexturedButton:new(self, 12, "Interface\\Addons\\VFL\\Skin\\sb_up");
	upbtn:SetPoint("LEFT", dnbtn, "RIGHT");
	upbtn:Show();
	local label = VFLUI.CreateFontString(self);
	label:SetHeight(12); label:SetWidth(50);
	label:SetPoint("LEFT", upbtn, "RIGHT", 3, 0);
	label:SetFontObject(Fonts.Default10); label:SetJustifyH("LEFT");
	label:Show();

	function self:DialogOnLayout()
		label:SetWidth(math.max(self:GetWidth() - 30, 0));
	end
	self.SetupButtons = function(s, onUp, onDn)
		upbtn:SetScript("OnClick", onUp);
		dnbtn:SetScript("OnClick", onDn);
	end;
	self.SetText = function(s, t) 
		label:SetText(t); 
	end
	
	self.Destroy = VFL.hook(function(s)
		s.SetupButtons = nil; s.SetText = nil;
		upbtn:Destroy(); upbtn = nil; dnbtn:Destroy(); dnbtn = nil;
		VFLUI.ReleaseRegion(label); label = nil;
		s.classID = nil;
	end, self.Destroy);

	return self;
end

-- Specified class sort.
RDX.RegisterSortOperator({
	name = "class2";
	title = i18n("Class Order");
	category = i18n("Basic");
	EmitClosure = function(desc, code, vars)
		code:AppendCode(" local " .. desc.vname .. " = { }; " .. desc.vname .. "[0] = 0; ");
		for i = 1,10 do
            if i and desc[i] then
                code:AppendCode(desc.vname .. "[" .. desc[i] .. "] = " .. i .. "; ");
            end
		end
	end;
	
	EmitLocals = function(desc, code, vars)
		if not vars["classid"] then
			vars["class2id"] = true;
			code:AppendCode([[
local class2id1,class2id2 = ]] .. desc.vname .. [[[u1:GetClassID()], ]] .. desc.vname .. [[[u2:GetClassID()] ]]);
		end
	end;
	
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if class2id1 == class2id2 then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[
else
]]);
		if desc.reversed then
			code:AppendCode([[return class2id1 > class2id2;]]);
		else
			code:AppendCode([[return class2id1 < class2id2;]]);
		end
code:AppendCode([[
end
]]);	
	end;
	
	GetUI = function(parent, desc)
		local ui = RDXUI.SortDialogFrame:new(parent);
		ui:SetText(i18n("Specified Class Order")); ui:Show();
		
		local container = VFLUI.CompoundFrame:new(ui);
		ui:SetChild(container); container:Show();
				
		local function Move(frame, dxn)
			local x,y = container:LocateFrame(frame);
			if not x then return; end
			local np = y + dxn;
			if(np < 1) or (np > container.dy) then return; end -- can't move past end
			-- Do the switch
			local temp = container.cells[1][y];
			container.cells[1][y] = container.cells[1][np];
			container.cells[1][np] = temp;
			-- Relayout
			VFLUI.UpdateDialogLayout(container);
		end
		
		local i;
		for i = 1,10 do
			local cls = CreateElevatorWidget(container);
			cls:SetupButtons(function()	Move(cls, -1); end, function() Move(cls, 1); end);
			cls.classID = desc[i];
			cls:SetText(strtcolor(RDXCT.GetClassColor(desc[i])) .. RDXCT.GetClassName(desc[i]) .. "|r"); 
			container:InsertFrame(cls);
			cls:Show();
		end
		
		ui.GetDescriptor = function() 
			local ret = { op = "class2"; vname = desc.vname or ("cls" .. math.random(1,10000000)) };
			for i=1,10 do
				ret[i] = container.cells[1][i].classID;
			end
			return ret;
		end;
	
		return ui;
	end;
	
	GetBlankDescriptor = function()
		local ret = { op = "class2"; vname = "cls" .. math.random(1, 10000000) };
		for i=1,10 do
			ret[i] = i;
		end
		return ret;
	end;
});

---------------------------------------------------------------
-- The Intrinsic sort operator - sorts by intrinsic set value.
---------------------------------------------------------------
RDX.RegisterSortOperator({
	name = "intrinsic";
	title = i18n("Set Position");
	category = i18n("Collate");
	EmitLocals = function(desc, code, vars)
		if not vars["intr"] then
			vars["intr"] = true;
			code:AppendCode([[
local u1_intr = tonumber(set:IsMember(u1));
local u2_intr = tonumber(set:IsMember(u2));
]]);
		end
	end;
	EmitCode = function(desc, code, context)
		code:AppendCode([[
if (u1_intr == u2_intr) then
]]);
		RDX._SortContinuation(context);
		code:AppendCode([[elseif u1_intr < u2_intr then
	return true;
else
	return nil;
end
]]);
	end;
	GetUI = RDX.TrivialSortUI("intrinsic", i18n("Set Position"));
	GetBlankDescriptor = function() return {op = "intrinsic"}; end;
});

