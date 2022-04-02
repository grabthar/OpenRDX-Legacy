-- Class.lua
-- RDX - Raid Data Exchange
-- (C)2007 Sigg / Rashgarroth eu

-- Unit Icon

------------------------------------------------
-- UNITFRAME
------------------------------------------------
--- Unit frame class icon
RDX.RegisterFeature({
	name = "tex_class";
	title = i18n("Class Icon");
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		-- Verify our owner frame exists
		if (not desc.owner) or ((desc.owner ~= "Base") and (not state:Slot("Subframe_" .. desc.owner))) then
			VFL.AddError(errs, i18n("Owner frame does not exist.")); return nil;
		end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Icon_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		if flg then state:AddSlot("Icon_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
	local objname = "Icon_" .. desc.name;
	local ebs = "false"; if desc.externalButtonSkin then ebs = "true"; end
	local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end

	------------------ Closure corde (before frame creation, load button skin)
	local closureCode = "";
	if desc.externalButtonSkin then
		closureCode = closureCode .. [[ local mddataclai = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);
	end

		------------------ On frame creation
		local createCode = [[
local btn, owner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
btn = VFLUI.AcquireFrame("Button");
btn:SetParent(owner);
btn:SetFrameLevel(owner:GetFrameLevel());
btn:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
btn:SetWidth(]] .. desc.w .. [[); btn:SetHeight(]] .. desc.h .. [[);
if ]] .. ebs .. [[ then 
	RDXUI.ApplyButtonSkin(btn, mddataclai, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes");
btn._t:Show();
btn:Hide();
frame.]] .. objname .. [[ = btn;

]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

		------------------ On frame destruction.
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode([[
VFLUI.ReleaseRegion(frame.]] .. objname .. [[._t); frame.]] .. objname .. [[._t = nil;
if ]] .. ebs .. [[ then
	RDXUI.DestroyButtonSkin(frame.]] .. objname .. [[);
end
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]]); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.]] .. objname .. [[:Hide();
]]); end);

		------------------ On paint.
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[
if UnitIsPlayer(uid) then
	local classii = RDXCT.GetClassIcon(unit:GetClassMnemonic());
	frame.]] .. objname .. [[._t:SetTexCoord(classii[1], classii[2], classii[3], classii[4]);
	frame.]] .. objname .. [[:Show();
else
	frame.]] .. objname .. [[:Hide();
end
]]); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Drawlayer
		local er = RDXUI.EmbedRight(ui, i18n("Draw layer:"));
		local drawLayer = VFLUI.Dropdown:new(er, RDXUI.DrawLayerDropdownFunction);
		drawLayer:SetWidth(100); drawLayer:Show();
		if desc and desc.drawLayer then drawLayer:SetSelection(desc.drawLayer); else drawLayer:SetSelection("ARTWORK"); end
		er:EmbedChild(drawLayer); er:Show();
		ui:InsertFrame(er);

		-- Anchor
		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);
		
		local chk_bs = RDXUI.CheckEmbedRight(ui, i18n("Use Button Skin"));
		local file_extBS = RDXDB.ObjectFinder:new(chk_bs, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "ButtonSkin$")); end);
		file_extBS:SetWidth(200); file_extBS:Show();
		chk_bs:EmbedChild(file_extBS); chk_bs:Show();
		ui:InsertFrame(chk_bs);
		if desc.externalButtonSkin then
			chk_bs:SetChecked(true); file_extBS:SetPath(desc.externalButtonSkin);
		else
			chk_bs:SetChecked();
		end
		
		local ed_bs = VFLUI.LabeledEdit:new(ui, 50); ed_bs:Show();
		ed_bs:SetText(i18n("Button Skin, Icon size"));
		if desc and desc.ButtonSkinOffset then ed_bs.editBox:SetText(desc.ButtonSkinOffset); end
		ui:InsertFrame(ed_bs);
		
		function ui:GetDescriptor()
			local name = ed_name.editBox:GetText();
			local ebs = nil;
			if chk_bs:GetChecked() then ebs = file_extBS:GetPath(); end
			return { 
				feature = "tex_class", name = name, owner = owner:GetSelection();
				drawLayer = drawLayer:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				externalButtonSkin = ebs;
				ButtonSkinOffset = VFL.clamp(ed_bs.editBox:GetNumber(), 0, 50);
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "tex_class", name = "rci", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 15;
		};
	end;
});


-----------------------------------
-- Subclass talent
-----------------------------------

local sig_unit_subclass = RDXEvents:LockSignal("UNIT_SUBCLASS");

-----------------------------------------------
-- Talent ndata def
-----------------------------------------------

-- MainTalent is a number
RDX.Unit.GetMainTalent = function()
	return 0;
end;
RDX.Unit.SetMainTalent = VFL.Zero;
RDX.Unit.GetMainTalent = VFL.Zero;


RDXEvents:Bind("NDATA_CREATED", nil, function(ndata, name)
	local t = {};
	t.mainTalent = 0;
	ndata.GetMainTalent = function()
		return t.mainTalent;
	end;
	ndata.SetMainTalent = function(tname)
		t.mainTalent = tname;
	end;
	ndata:SetNField("subclass", t);
end);

--------------------------------------------------
-- bind
--------------------------------------------------

local function RPCSendSubClass()
	local t = {};
	local tabPSTmp = 0;
	local tabNameTmp = "";
	for i=1,GetNumTalentTabs() do
		local tabName, _, tabPS = GetTalentTabInfo(i);
		if tabPS > tabPSTmp then 
			tabPSTmp = tabPS;
			tabNameTmp = tabName;
		end;
	end;
	--local _, a = UnitClass("player");
	local a = RDXPlayer:GetClassMnemonic();
	t.mainTalent = RDXCT.GetIdSubClassByLocal(a .. "_" .. tabNameTmp);
	RPC_Group:Flash("sync_SubClass", t);
end;

local function RPCSyncSubClass(ci, tabInfo)
	local unit = RPC.GetSenderUnit(ci);
	if (not unit) or (not unit:IsValid()) then return; end	
	unit.SetMainTalent(tabInfo.mainTalent);
	sig_unit_subclass:Raise(unit, unit.nid, unit.uid);
end

RPC_Group:Bind("sync_SubClass", RPCSyncSubClass);

------------------------------------------------
-- INIT
------------------------------------------------
RDXEvents:Bind("INIT_DESKTOP", nil, function()
		RPCSendSubClass();
		-- Start periodic broadcasts
		VFL.AdaptiveSchedule(nil, 120, RPCSendSubClass);
end);
------------------------------------------------
-- UNITFRAME
------------------------------------------------
--- Unit frame sub class icon
RDX.RegisterFeature({
	name = "ico_subclass";
	title = i18n("Talent Icon");
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		-- Verify our owner frame exists
		if (not desc.owner) or ((desc.owner ~= "Base") and (not state:Slot("Subframe_" .. desc.owner))) then
			VFL.AddError(errs, i18n("Owner frame does not exist.")); return nil;
		end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Icon_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		if flg then state:AddSlot("Icon_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Icon_" .. desc.name;
		local flag = "false"; if desc and desc.ukfilter then flag = "true"; end
		local ebs = "false"; if desc.externalButtonSkin then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end

		------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then
			closureCode = closureCode .. [[ local mddatasubi = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
			state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);
		end
		

		------------------ On frame creation
		local createCode = [[
local btn, owner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
btn = VFLUI.AcquireFrame("Button");
btn:SetParent(owner);
btn:SetFrameLevel(owner:GetFrameLevel());
btn:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
btn:SetWidth(]] .. desc.w .. [[); btn:SetHeight(]] .. desc.h .. [[);
if ]] .. ebs .. [[ then 
	RDXUI.ApplyButtonSkin(btn, mddatasubi, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\InventoryItems\\WoWUnknownItem01.blp");
btn._t:Show();
btn:Hide();
frame.]] .. objname .. [[ = btn;

]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

		------------------ On frame destruction.
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode([[
VFLUI.ReleaseRegion(frame.]] .. objname .. [[._t); frame.]] .. objname .. [[._t = nil;
if ]] .. ebs .. [[ then
	RDXUI.DestroyButtonSkin(frame.]] .. objname .. [[);
end
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]]); end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.]] .. objname .. [[:Hide();
]]); end);

		------------------ On paint.
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[

frame.]] .. objname .. [[._t:SetTexture(RDXCT.GetTextureSubClassById(unit.GetMainTalent()));
if ]] .. flag .. [[ and unit.GetMainTalent() == 0 then
	frame.]] .. objname .. [[:Hide();
else
	frame.]] .. objname .. [[:Show();
end;
]]); end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("UNIT_SUBCLASS", mux:GetPaintMask("SUBCLASS"));
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Drawlayer
		local er = RDXUI.EmbedRight(ui, i18n("Draw layer:"));
		local drawLayer = VFLUI.Dropdown:new(er, RDXUI.DrawLayerDropdownFunction);
		drawLayer:SetWidth(100); drawLayer:Show();
		if desc and desc.drawLayer then drawLayer:SetSelection(desc.drawLayer); else drawLayer:SetSelection("ARTWORK"); end
		er:EmbedChild(drawLayer); er:Show();
		ui:InsertFrame(er);

		-- Anchor
		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);
		
		local chk_ukfilter = VFLUI.Checkbox:new(ui); chk_ukfilter:Show();
		chk_ukfilter:SetText(i18n("Hide unknown icon"));
		if desc and desc.ukfilter then chk_ukfilter:SetChecked(true); else chk_ukfilter:SetChecked(false); end
		ui:InsertFrame(chk_ukfilter);
		
		local chk_bs = RDXUI.CheckEmbedRight(ui, i18n("Use Button Skin"));
		local file_extBS = RDXDB.ObjectFinder:new(chk_bs, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "ButtonSkin$")); end);
		file_extBS:SetWidth(200); file_extBS:Show();
		chk_bs:EmbedChild(file_extBS); chk_bs:Show();
		ui:InsertFrame(chk_bs);
		if desc.externalButtonSkin then
			chk_bs:SetChecked(true); file_extBS:SetPath(desc.externalButtonSkin);
		else
			chk_bs:SetChecked();
		end
		
		local ed_bs = VFLUI.LabeledEdit:new(ui, 50); ed_bs:Show();
		ed_bs:SetText(i18n("Button Skin, Icon size"));
		if desc and desc.ButtonSkinOffset then ed_bs.editBox:SetText(desc.ButtonSkinOffset); end
		ui:InsertFrame(ed_bs);
		
		function ui:GetDescriptor()
			local name = ed_name.editBox:GetText();
			local ebs = nil;
			if chk_bs:GetChecked() then ebs = file_extBS:GetPath(); end
			return { 
				feature = "ico_subclass", name = name, owner = owner:GetSelection();
				drawLayer = drawLayer:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				ukfilter = chk_ukfilter:GetChecked();
				externalButtonSkin = ebs;
				ButtonSkinOffset = VFL.clamp(ed_bs.editBox:GetNumber(), 0, 50);
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "ico_subclass", name = "rtai", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 15;
		};
	end;
});

---------------------------------------------------------------
-- Match subclasses
---------------------------------------------------------------
RDX.RegisterFilterComponent({
	name = "subclasses", title = i18n("Talents..."), category = i18n("Group Composition"),
	UIFromDescriptor = function(desc, parent)
		-- Setup the base frame and the checkboxes for subclasses
		local ui = RDXUI.FilterDialogFrame:new(parent);
		ui:SetText(i18n("Subclasses..."));
		local checks = VFLUI.CheckGroup:new(ui);
		ui:SetChild(checks);
		checks:SetLayout(31, 2);
		-- Populate checkboxes
		for i=1,30 do 
			checks.checkBox[i]:SetText(strtcolor(RDXCT.GetColorSubClassById(i)) .. RDXCT.GetLocalSubclassById(i) .. "|r"); 
			if desc[i + 1] then checks.checkBox[i]:SetChecked(true); end
		end
		checks.checkBox[31]:SetText(strcolor(.5,.5,.5) .. i18n("Unknown|r"));
		if desc[32] then checks.checkBox[31]:SetChecked(true); end

		ui.GetDescriptor = function(x)
			local ret = {"subclasses"};
			for i=1,31 do
				if checks.checkBox[i]:GetChecked() then ret[i+1] = true; else ret[i+1] = nil; end
			end
			return ret;
		end
		return ui;
	end,
	GetBlankDescriptor = function() return {"subclasses"}; end,
	FilterFromDescriptor = function(desc, metadata)
		-- Build the filtration array
		local v = RDX.GenerateFilterUpvalue();
		local script = v .. "={};";
		for i=2,31 do
			if desc[i] then script = script .. v .. "[" .. i-1 .. "]=true;"; end
		end
		if desc[32] then script = script .. v .. "[0]=true;"; end
		table.insert(metadata, { class = "CLOSURE", name = v, script = script });
		-- Now, our filter expression is just a check on the closure array against the unit's subclass number.
		return "(" .. v .. "[unit.GetMainTalent()])";
	end,
	ValidateDescriptor = VFL.True,
	EventsFromDescriptor = function(desc, metadata)
		RDX.FilterEvents_FullUpdate(metadata, "ROSTER_UPDATE");
		RDX.FilterEvents_FullUpdate(metadata, "UNIT_SUBCLASS");
	end,
	SetsFromDescriptor = VFL.Noop,
});
