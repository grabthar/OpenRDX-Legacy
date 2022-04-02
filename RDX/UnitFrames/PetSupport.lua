-- PetSupport.lua
-- OpenRDX - Raid Data Exchange
--
-- Some basic code and features to support pet-driven frames.

local pethapIcons = {
	[1] = {0.375, 0.5625, 0, 0.359375},
	[2] = {0.1875, 0.375, 0, 0.359375},
	[3] = {0, 0.1875, 0, 0.359375},
}

function VFLGetPethapIcon(cl)
	return pethapIcons[cl];
end

------------------------------------------------
-- UNITFRAME
------------------------------------------------
--- Unit frame pet hapiness icon by sigg
RDX.RegisterFeature({
	name = "tex_pethap";
	title = i18n("Pet Hapiness Icon");
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Icon_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Icon_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Icon_" .. desc.name;
		local ebs = "false"; if desc.externalButtonSkin then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end
		
		------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddataphi = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddataphi, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness");
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
if unit:IsPet() then
	local happiness = GetPetHappiness();
	if happiness then
		local petc = VFLGetPethapIcon(happiness);
		frame.]] .. objname .. [[._t:SetTexCoord(petc[1], petc[2], petc[3], petc[4]);
		frame.]] .. objname .. [[:Show();
	else
		frame.]] .. objname .. [[:Hide();
	end
end
]]); end);
	local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
	mux:Event_MaskAll("UNIT_HAPPINESS", 2);
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
				feature = "tex_pethap", name = name, owner = owner:GetSelection();
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
			feature = "tex_pethap", name = "pethap", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 10;
		};
	end;
});

-------------------------------------------------------
-- Debuff flags for second class units.
-------------------------------------------------------
RDX.RegisterFeature({
	name = "Variable: 2C Debuff Flags";
	category = i18n("Variables: Second-Class Units");
	deprecated = true;
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		if state:Slot("Var_sc_curse") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		state:AddSlot("Var_sc_curse"); state:AddSlot("BoolVar_sc_curse");
		state:AddSlot("Var_sc_magic"); state:AddSlot("BoolVar_sc_magic");
		state:AddSlot("Var_sc_poison"); state:AddSlot("BoolVar_sc_poison");
		state:AddSlot("Var_sc_disease"); state:AddSlot("BoolVar_sc_disease");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local sc_curse, sc_magic, sc_poison, sc_disease = nil, nil, nil, nil;
local _bn, _type, _i = nil, nil, 1;
while true do
	_bn, _, _, _, _type = UnitDebuff(uid, _i);
	if not _bn then break; end
	if(_type == "MAGIC") then sc_magic = true;
	elseif(_type == "CURSE") then sc_curse = true;
	elseif(_type == "POISON") then sc_poison = true;
	elseif(_type == "DISEASE") then sc_disease = true; end
	_i = _i + 1;
end
]]); end);
	end;
	UIFromDescriptor = VFL.Nil;
	CreateDescriptor = function() return { feature = "Variable: 2C Debuff Flags" }; end
});

--------------------------------------------------------
-- Spellrange flag for second class units.
--------------------------------------------------------
RDX.RegisterFeature({
	name = "Variable: 2C Spell Range Flag";
	multiple = true;
	category = i18n("Variables: Second-Class Units");
	deprecated = true;
	IsPossible = function(state)
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not RDX._CheckVariableNameValidity(desc.name, state, errs) then return nil; end
		if not desc.spell then VFL.AddError(errs, i18n("No spell name.")); return nil; end
		state:AddSlot("Var_" .. desc.name); state:AddSlot("BoolVar_" .. desc.name);
		return true;
	end;
	ApplyFeature = function(desc, state)
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code) code:AppendCode([[
local ]] .. desc.name .. [[ = nil;
if IsSpellInRange("]] ..desc.spell .. [[", uid) then ]] .. desc.name .. [[=true; end
]]); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local name = VFLUI.LabeledEdit:new(ui, 100); name:Show();
		name:SetText(i18n("Variable Name"));
		if desc and desc.name then name.editBox:SetText(desc.name); end
		ui:InsertFrame(name);

		local spellEdit = RDXUI.SpellSelector:new(ui); spellEdit:Show();
		if desc and desc.spell then spellEdit:SetSpell(desc.spell); else spellEdit:SetSpell("(none)"); end
		ui:InsertFrame(spellEdit);

		function ui:GetDescriptor()
			return {
				feature = "Variable: 2C Spell Range Flag";
				name = name.editBox:GetText();
				spell = spellEdit:GetSpell();
			};
		end

		return ui;
	end;
	CreateDescriptor = function() return { feature = "Variable: 2C Spell Range Flag", name = "psrf" }; end
});

---------------------------------------------
-- "Has Pet" set class
---------------------------------------------
local hasPetSet = RDX.Set:new();
hasPetSet.name = "Has Pet";
RDX.RegisterSet(hasPetSet);

local function UpdateHasPet()
	local unit,uid;
	RDX.BeginEventBatch();
	for i=41,80 do
		unit = RDX.GetUnitByNumber(i);
		if unit:IsValid() then
			hasPetSet:_Set(i-40, true);
		else
			hasPetSet:_Set(i-40, false);
		end
	end
	RDX.EndEventBatch();
end
RDXEvents:Bind("ROSTER_PETS_CHANGED", nil, UpdateHasPet);

RDX.RegisterSetClass({
	name = "haspet";
	title = i18n("Has Pet");
	GetUI = RDX.TrivialSetFinderUI("haspet");
	FindSet = function() return hasPetSet; end;
});

-- The whole raid, and pets set
local gps = RDX.Set:new();
gps.name = "Group and Pets";
RDX.RegisterSet(gps);

local function UpdateGroupPet()
	local unit,uid;
	RDX.BeginEventBatch();
	for i=1,80 do
		unit = RDX.GetUnitByNumber(i);
		if unit:IsValid() then
			gps:_Set(i, true);
		else
			gps:_Set(i, false);
		end
	end
	RDX.EndEventBatch();
end

RDXEvents:Bind("ROSTER_UPDATE", nil, UpdateGroupPet);

RDX.RegisterSetClass({
	name = "grouppets";
	title = i18n("Group and Pets");
	GetUI = RDX.TrivialSetFinderUI("grouppets");
	FindSet = function() return gps; end;
});
