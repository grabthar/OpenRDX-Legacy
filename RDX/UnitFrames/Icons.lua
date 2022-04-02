-- OpenRDX

----------------------------------------------------------------------
-- An iconic representation of the underlying unit's raid target icon.
----------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Raid Target Icon";
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local ebs = "false"; if desc.externalButtonSkin then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end
		
		------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddatarti = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddatarti, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
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
if GetRaidTargetIndex(uid) then
	frame.]] .. objname .. [[:Show();
	SetRaidTargetIconTexture(frame.]] .. objname .. [[._t, GetRaidTargetIndex(uid));
else
	frame.]] .. objname .. [[:Hide();
end
]]); end);

		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("RAID_TARGET_UPDATE", 2);

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
				feature = "Raid Target Icon", name = name, owner = owner:GetSelection();
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
			feature = "Raid Target Icon", name = "rti", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 5;
		};
	end;
});

----------------------------------------------------------------------
-- An iconic representation of Unit status icon for player frame. (made by superraider)
----------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Player Status Icon";
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local ebs = "false"; if (desc.externalButtonSkin) then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end
		
	------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddatapsi = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddatapsi, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\CharacterFrame\\UI-StateIcon");
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
]]); 
		end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.]] .. objname .. [[:Hide();
]]);
		end);

      ------------------ On paint.
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[
local name = UnitName(uid);
if UnitAffectingCombat(uid) then
	frame.]] .. objname .. [[:Show();
	frame.]] .. objname .. [[._t:SetTexCoord(0.5, 1, 0, 0.5);
elseif (RDXPlayer.rosterName == name) and IsResting() then
	frame.]] .. objname .. [[:Show();
	frame.]] .. objname .. [[._t:SetTexCoord(0, 0.5, 0, 0.421875)
else
	frame.]] .. objname .. [[:Hide();
end
]]);
		end);

		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("PLAYER_UPDATE_RESTING", 2);
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);
		
		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end
		
		-- Drawlayer
		local er = RDXUI.EmbedRight(ui, "Draw layer:");
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
				feature = "Player Status Icon", name = name, owner = owner:GetSelection();
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
			feature = "Player Status Icon", name = "sti", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 5;
		};
	end;
}); 

----------------------------------------------------------------------
-- An iconic representation if unit is master looter (made by superraider)
----------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Master Looter Icon";
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local ebs = "false"; if (desc.externalButtonSkin) then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end

      ------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddatamli = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddatamli, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter");
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

		------------------ On paint. --fridg
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[
local name, pname = nil, nil;
local _, partyMaster, raidMaster = GetLootMethod();
if raidMaster then
	if unit.rosterName then
		name = unit.rosterName;
	else
		name = UnitName(uid);
	end
	if (name == RDX.GetUnitByNumber(raidMaster).rosterName) then
		frame.]] .. objname .. [[:Show();
	else
		frame.]] .. objname .. [[:Hide();
	end
elseif partyMaster then
	name = UnitName(uid);
	pname = UnitName("party"..partyMaster);
	if (partyMaster == 0) and (RDXPlayer.rosterName == name) then
		frame.]] .. objname .. [[:Show();
	elseif (name == pname) then
		frame.]] .. objname .. [[:Show();
	else
		frame.]] .. objname .. [[:Hide();
	end
else
	frame.]] .. objname .. [[:Hide();
end
]]);
		end);
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
			feature = "Master Looter Icon", name = name, owner = owner:GetSelection();
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
			feature = "Master Looter Icon", name = "mli", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 5;
		};
	end;
}); 

----------------------------------------------------------------------
-- An iconic representation if unit is leader (made by superraider)
----------------------------------------------------------------------
RDX.RegisterFeature({
	name = "Raid Leader Icon";
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local ebs = "false"; if (desc.externalButtonSkin) then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end
      
      ------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddatarli = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddatarli, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
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
]]); 
		end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.]] .. objname .. [[:Hide();
]]);
		end);
      ------------------ On paint.
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[
if UnitIsPartyLeader(uid) then
	frame.]] .. objname .. [[:Show();
else
	frame.]] .. objname .. [[:Hide();
end
]]); 
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("PARTY_LOOT_METHOD_CHANGED", 2);
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
				feature = "Raid Leader Icon", name = name, owner = owner:GetSelection();
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
			feature = "Raid Leader Icon", name = "rli", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 10;
		};
	end;
});

local pvpIcons = {
	["Horde"] = {0.08, 0.58, 0.045, 0.545},
	["Alliance"] = {0.07, 0.58, 0.06, 0.57},
	["FFA"] = {0.05, 0.605, 0.015, 0.57},
}

function VFLGetPVPIcon(cl)
	return pvpIcons[cl];
end

RDX.RegisterFeature({
	name = "tex_pvp";
	title = i18n("Faction Icon");
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local ebs = "false"; if desc.externalButtonSkin then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end

		------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddatafi = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddatafi, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
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
local pvptype, faction, pvpc = nil, nil, nil;
if UnitIsPVPFreeForAll(uid) then 
	pvptype = "FFA";
else
	faction = UnitFactionGroup(uid);
	if faction then pvptype = faction; end
end
if pvptype then
	pvpc = VFLGetPVPIcon(pvptype);
	frame.]] .. objname .. [[._t:SetTexture("Interface\\TargetingFrame\\UI-PVP-" .. pvptype);
	frame.]] .. objname .. [[._t:SetTexCoord(pvpc[1], pvpc[2], pvpc[3], pvpc[4]);
	frame.]] .. objname .. [[:Show();
end
]]); 
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("UNIT_FACTION", 2);
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
				feature = "tex_pvp", name = name, owner = owner:GetSelection();
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
			feature = "tex_pvp", name = "faction", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 10;
		};
	end;
});

RDX.RegisterFeature({
	name = "tex_pvp2";
	title = i18n("PVP Icon");
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local ebs = "false"; if desc.externalButtonSkin then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end

		------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddatapi = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddatapi, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
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
if UnitIsPVP(uid) then
	local pvptype, pvpc = UnitFactionGroup(uid), nil;
	if UnitIsPVPFreeForAll(uid) then pvptype = "FFA"; end
	if pvptype then 
		pvpc = VFLGetPVPIcon(pvptype);
		frame.]] .. objname .. [[._t:SetTexture("Interface\\TargetingFrame\\UI-PVP-" .. pvptype);
		frame.]] .. objname .. [[._t:SetTexCoord(pvpc[1], pvpc[2], pvpc[3], pvpc[4]);
		frame.]] .. objname .. [[:Show();
	else
		frame.]] .. objname .. [[:Hide();
	end
else
	frame.]] .. objname .. [[:Hide();
end;
]]); 
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("UNIT_FACTION", 2);
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
				feature = "tex_pvp2", name = name, owner = owner:GetSelection();
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
			feature = "tex_pvp2", name = "pvp", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 10;
		};
	end;
});


-- by Aichi

RDX.RegisterFeature({
	name = "Ready Check Icon";
	category = i18n("Textures");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local ebs = "false"; if desc.externalButtonSkin then ebs = "true"; end
		local ebsos = 0; if desc.externalButtonSkin and desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end

		------------------ Closure corde (before frame creation, load button skin)
		local closureCode = "";
		if desc.externalButtonSkin then closureCode = closureCode .. [[
local mddatarci = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
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
	RDXUI.ApplyButtonSkin(btn, mddatarci, true, false, false, true, false, false, false, false, false, true);
end
btn._t = VFLUI.CreateTexture(btn);
btn._t:SetDrawLayer("]] .. (desc.drawLayer or "ARTWORK") .. [[");
btn._t:SetPoint("CENTER", btn, "CENTER");
btn._t:SetWidth(]] .. desc.w .. [[ - ]] .. ebsos .. [[); btn._t:SetHeight(]] .. desc.h .. [[ - ]] .. ebsos .. [[);
btn._t:SetVertexColor(1,1,1,1);
btn._t:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting");
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
]]); 
		end);
		state:Attach(state:Slot("EmitCleanup"), true, function(code) code:AppendCode([[
frame.]] .. objname .. [[:Hide();
]]); 
		end);

		------------------ On paint.
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode([[
local readyCheckStatus = nil;
if IsRaidLeader() or IsRaidOfficer() or IsPartyLeader() then
    readyCheckStatus = GetReadyCheckStatus(uid);
end
if readyCheckStatus then
  if ( readyCheckStatus == "ready" ) then
     frame.]] .. objname .. [[:Show();
     frame.]] .. objname .. [[._t:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready");
  elseif ( readyCheckStatus == "notready" ) then
     frame.]] .. objname .. [[:Show();
     frame.]] .. objname .. [[._t:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady");
  elseif ( readyCheckStatus == "waiting" ) then
     frame.]] .. objname .. [[:Show();
     frame.]] .. objname .. [[._t:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting");
  end
else
    frame.]] .. objname .. [[:Hide();
end
]]); 
		end);
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		mux:Event_MaskAll("READY_CHECK", 2);
		mux:Event_MaskAll("READY_CHECK_CONFIRM", 2);
		mux:Event_MaskAll("READY_CHECK_FINISHED", 2);
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);
		
		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end
		
		-- Drawlayer
		local er = RDXUI.EmbedRight(ui, "Draw layer:");
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
				feature = "Ready Check Icon", name = name, owner = owner:GetSelection();
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
			feature = "Ready Check Icon", name = "rci", owner = "Base", drawLayer = "ARTWORK";
			w = 14; h = 14;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			ButtonSkinOffset = 10;
		};
	end;
}); 
