-- Runes.lua
-- OpenRDX

local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;

local iconTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death",
}
function VFLGetRuneIconTexturesNormal(id)
	return iconTextures[id];
end

local iconTexturesOn = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood-On",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death-On",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost-On",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-On",
}
function VFLGetRuneIconTexturesOn(id)
	return iconTexturesOn[id];
end

local runeTexturesOff = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Blood-Off",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Death-Off",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Frost-Off",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-Off",
}
function VFLGetRuneIconTexturesOff(id)
	return runeTexturesOff[id];
end

local runeColors = {
	[RUNETYPE_BLOOD] = {1, 0, 0},
	[RUNETYPE_UNHOLY] = {0, 0.5, 0},
	[RUNETYPE_FROST] = {0, 1, 1},
	[RUNETYPE_DEATH] = {0.8, 0.1, 1},
}
function VFLGetRuneColors(id)
	return runeColors[id];
end   

local runeMapping = {
	[1] = i18n("BLOOD"),
	[2] = i18n("UNHOLY"),
	[3] = i18n("FROST"),
	[4] = i18n("DEATH"),
}

function VFLGetRuneMapping(id)
	return runeMapping[id];
end

local runeTexturesList = {
	{ text = "Normal" },
	{ text = "On" },
	{ text = "Off" },
};
function RDXUI.RuneTextureTypeDropdownFunction() return runeTexturesList; end

function __SetRunes(btn, dur, tl, hide)
	if hide then
		btn:Hide();
	else
		btn:Show();
	end
	if tl and tl > 0 then
		btn.cd:SetCooldown(GetTime() + tl - dur , dur);
	else
		btn.cd:SetCooldown(0, 0);
	end

	return true;
end

function __RuneOnEnter()
	if this.tooltipText then 
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
		GameTooltip:SetText(this.tooltipText);
		GameTooltip:Show(); 
	end
end
function __RuneOnLeave()
	GameTooltip:Hide();
end

--------------- Code emitter helpers
local function _EmitCreateCode(objname, desc)
	if not desc.nIcons then desc.nIcons = 6; end
	local createCode = [[
frame.]] .. objname .. [[ = {};
local btn, btnOwner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
for i=1,6 do
	btn = VFLUI.AcquireFrame("Button");
	btn:SetParent(btnOwner);
	btn:SetFrameLevel(btnOwner:GetFrameLevel());
	btn:SetWidth(]] .. desc.size .. [[); btn:SetHeight(]] .. desc.size .. [[);
	btn:SetID(i);
	btn:SetScript("OnEnter", __RuneOnEnter);
	btn:SetScript("OnLeave", __RuneOnLeave);
	
	btn.texrune = VFLUI.CreateTexture(btn);
	btn.texrune:SetPoint("TOPLEFT", btn, "TOPLEFT");
	btn.texrune:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT");
	btn.texrune:SetTexCoord(0.08, 1-0.08, 0.08, 1-0.08);
	btn.texrune:SetTexture("Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood");
	local runeType = GetRuneType(i);
	if (runeType) then
		btn.texrune:SetTexture(VFLGetRuneIconTexturesNormal(runeType));
		btn.texrune:Show();
		btn.tooltipText = _G["COMBAT_TEXT_RUNE_"..VFLGetRuneMapping(runeType)];
	else
		btn.texrune:Hide();
		btn.tooltipText = nil;
	end
	
	btn.cd = RDXUI.CooldownCounter:new(btn, false, true, true, 0.3, "MinSec", false);
	btn.cd:SetPoint("TOPLEFT", btn.texrune, "TOPLEFT", 2, -2);
	btn.cd:SetPoint("BOTTOMRIGHT", btn.texrune, "BOTTOMRIGHT", -2, 2);
	btn.cd:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetFontCode("btn.cd.fs", desc.font, nil, true);
	createCode = createCode .. [[
	btn.fraborder = VFLUI.AcquireFrame("Frame");
	btn.fraborder:SetParent(btn);
	btn.fraborder:SetFrameLevel(btn:GetFrameLevel() + 2);
	btn.fraborder:Show();
	btn.texborder = VFLUI.CreateTexture(btn.fraborder);
	btn.texborder:SetPoint("TOPLEFT", btn, "TOPLEFT");
	btn.texborder:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT");
	btn.texborder:SetTexCoord(0.08, 1-0.08, 0.08, 1-0.08);
	btn.texborder:SetTexture("Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Ring");
	btn.texborder:Show();

	frame.]] .. objname .. [[[i] = btn;
end
]];
	createCode = createCode .. RDXUI.LayoutCodeMultiRows(objname, desc);
	return createCode;
end

-----------------------------
-- RUNES
-----------------------------
RDX.RegisterFeature({
	name = "runes_bar"; version = 1; title = i18n("Runes Bar"); 
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
		
		-- Event hinting.
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local smask = mux:GetPaintMask("RUNE_POWER_UPDATE");
		local umask = mux:GetPaintMask("RUNE_TYPE_UPDATE");
		
		------------ Closure
		local closureCode = [[
local mddata_]] .. objname .. [[ = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);

		----------------- Creation
		local createCode = _EmitCreateCode(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);

		------------------- Destruction
		local destroyCode = [[
local btn = nil;
for i=1,6 do
	btn = frame.]] .. objname .. [[[i]
	VFLUI.ReleaseRegion(btn.texrune); btn.texrune = nil;
	btn.cd:Destroy(); btn.cd = nil;
	VFLUI.ReleaseRegion(btn.texborder); btn.texborder = nil;
	btn.fraborder:Destroy(); btn.fraborder = nil;
	btn.tooltipText = nil;
	btn:Destroy();
end
frame.]] .. objname .. [[ = nil;
]];
		state:Attach("EmitDestroy", true, function(code) code:AppendCode(destroyCode); end);

		------------------- Paint
		local paintCode = [[
local hide = nil;
local classMnemonic = RDXPlayer:GetClassMnemonic();
if ( classMnemonic ~= "DEATHKNIGHT" ) then
	hide = true;
end
local _runes = frame.]] .. objname .. [[;
local start, duration, runeReady, timeleft, runeType;

for i=1,6 do
	start, duration, runeReady = GetRuneCooldown(i);
	timeleft = duration - (GetTime() - start);
	runeType = GetRuneType(i);
	if (runeType) then
		_runes[i].texrune:SetTexture(VFLGetRuneIconTexturesNormal(runeType));
		_runes[i].tooltipText = _G["COMBAT_TEXT_RUNE_"..VFLGetRuneMapping(runeType)];
	end
	__SetRunes(_runes[i], duration, timeleft, hide);
end
]];
		state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCode); end);
		------------------- Cleanup
		local cleanupCode = [[
local btn = nil;
for i=1,6 do
	btn = frame.]] .. objname .. [[[i];
	btn:Hide(); btn.meta = nil;
end
]];
		--state:Attach("EmitCleanup", true, function(code) code:AppendCode(cleanupCode); end);
		
		mux:Event_UnitMask("UNIT_RUNE_POWER_UPDATE", smask);
		mux:Event_UnitMask("UNIT_RUNE_TYPE_UPDATE", umask);
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		------------- Core
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Core Parameters")));

		local ed_name = VFLUI.LabeledEdit:new(ui, 100); ed_name:Show();
		ed_name:SetText(i18n("Name"));
		ed_name.editBox:SetText(desc.name);
		ui:InsertFrame(ed_name);

		------------- Layout
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout")));

		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);

		local ed_rows = VFLUI.LabeledEdit:new(ui, 50); ed_rows:Show();
		ed_rows:SetText(i18n("Row size"));
		if desc and desc.rows then ed_rows.editBox:SetText(desc.rows); end
		ui:InsertFrame(ed_rows);

		local er = RDXUI.EmbedRight(ui, i18n("Orientation:"));
		local dd_orientation = VFLUI.Dropdown:new(er, RDXUI.OrientationDropdownFunction);
		dd_orientation:SetWidth(75); dd_orientation:Show();
		if desc and desc.orientation then 
			dd_orientation:SetSelection(desc.orientation); 
		else
			dd_orientation:SetSelection("RIGHT");
		end
		er:EmbedChild(dd_orientation); er:Show();
		ui:InsertFrame(er);
		
		local ed_iconspx = VFLUI.LabeledEdit:new(ui, 50); ed_iconspx:Show();
		ed_iconspx:SetText(i18n("Icons spacing width"));
		if desc and desc.iconspx then ed_iconspx.editBox:SetText(desc.iconspx); else ed_iconspx.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspx);
		
		local ed_iconspy = VFLUI.LabeledEdit:new(ui, 50); ed_iconspy:Show();
		ed_iconspy:SetText(i18n("Icons spacing height"));
		if desc and desc.iconspy then ed_iconspy.editBox:SetText(desc.iconspy); else ed_iconspy.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspy);
		
		local ed_size = VFLUI.LabeledEdit:new(ui, 50); ed_size:Show();
		ed_size:SetText(i18n("Icon Size"));
		if desc and desc.size then ed_size.editBox:SetText(desc.size); end
		ui:InsertFrame(ed_size);
		
		function ui:GetDescriptor()
			return { 
				feature = "runes_bar"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				rows = VFL.clamp(ed_rows.editBox:GetNumber(), 1, 5);
				orientation = dd_orientation:GetSelection();
				iconspx = VFL.clamp(ed_iconspx.editBox:GetNumber(), 0, 200);
				iconspy = VFL.clamp(ed_iconspy.editBox:GetNumber(), 0, 200);
				size = VFL.clamp(ed_size.editBox:GetNumber(), 1, 50);
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		local font = VFL.copy(Fonts.Default); font.size = 8; font.justifyV = "CENTER"; font.justifyH = "CENTER";
		return { 
			feature = "runes_bar"; 
			version = 1;
			name = "rune_bar";
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			size = 20; rows = 1; orientation = "RIGHT"; iconspx = 5; iconspy = 0;
			font = font;
			timerType = "COOLDOWN"; cdoffx = 0; cdoffy = 0;
		};
	end;
});

-------------------------------------
-- Vars: Rune Info - Deathknight rune variables
-- 
-- UnitFrameFeature to create custom Deathknight RuneElements
-- Karma - Blackrock EU
-------------------------------------

RDX.RegisterFeature({
	name = "Vars: Rune Info";
	title = i18n("Vars: Rune Info");
	category =  i18n("Variables: Unit Status");
	version = 1;
	multiple = false;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("EmitPaintPreamble") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)      
		if not desc then VFL.AddError(errs, i18n( "No descriptor.")); return nil; end
		for i=1, 6 do
			state:AddSlot("TimerVar_rune" .. i);
			state:AddSlot("BoolVar_rune" .. i .. "_ready");
			state:AddSlot("TextData_rune" .. i .. "_name");
			state:AddSlot("TexVar_rune" .. i .. "_icon");
			state:AddSlot("ColorVar_rune" .. i .. "_color");
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		if not desc.TextureType then desc.TextureType = "Normal"; end
		-- Event hinting.
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local smask = mux:GetPaintMask("RUNE_POWER_UPDATE");
		local umask = mux:GetPaintMask("RUNE_TYPE_UPDATE");
		
		local closureCode = [[ 
local runeColors = {};
]];
		for i=1, 4 do
			closureCode = closureCode .. [[
runeColors[]] .. i .. [[] = ]] .. Serialize(desc.colors[i]) .. [[;
]];
		end
		state:Attach(state:Slot("EmitClosure"), true, function(code)
			code:AppendCode(closureCode);
		end);
		
		local paintCode = "";
		for i=1, 6 do 
			paintCode = paintCode .. [[
local rune]] .. i .. [[_name, rune]] .. i .. [[_icon, rune]] .. i .. [[_color = "", nil, nil;
local rune]] .. i .. [[_start, rune]] .. i .. [[_duration, rune]] .. i .. [[_ready = 0, 0, false;
]];
		end

		paintCode = paintCode .. [[
local classMnemonic = RDXPlayer:GetClassMnemonic();

if ( classMnemonic == "DEATHKNIGHT" ) then
	local runetype;
]];
	for i=1,6 do
		paintCode = paintCode .. [[
		runeType = GetRuneType(]] .. i .. [[);
		if (runeType) then
			rune]] .. i .. [[_name = VFLGetRuneMapping(runeType);
			rune]] .. i .. [[_icon = VFLGetRuneIconTextures]] .. desc.TextureType .. [[(runeType);
			rune]] .. i .. [[_color = runeColors[runeType];
			rune]] .. i .. [[_start, rune]] .. i .. [[_duration, rune]] .. i .. [[_ready = GetRuneCooldown(]] .. i .. [[);
		end
]];
	end
	paintCode = paintCode .. [[
end
]];
		state:Attach(state:Slot("EmitPaintPreamble"), true, function(code)
			code:AppendCode(paintCode);
		end);
		
		mux:Event_UnitMask("UNIT_RUNE_POWER_UPDATE", smask);
		mux:Event_UnitMask("UNIT_RUNE_TYPE_UPDATE", umask);
		return true;
	end;

	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local er_TextureType = RDXUI.EmbedRight(ui, i18n("Texture Type:"));
		local dd_TextureType = VFLUI.Dropdown:new(er_TextureType, RDXUI.RuneTextureTypeDropdownFunction);
		dd_TextureType:SetWidth(150); dd_TextureType:Show();
		if desc and desc.TextureType then 
			dd_TextureType:SetSelection(desc.TextureType); 
		else
			dd_TextureType:SetSelection("Normal");
		end
		er_TextureType:EmbedChild(dd_TextureType); er_TextureType:Show();
		ui:InsertFrame(er_TextureType);
		
		local sw_blood = RDXUI.GenerateColorSwatch(ui, i18n("Blood rune color"));
		if desc and desc.colors and desc.colors[RUNETYPE_BLOOD] then sw_blood:SetColor(explodeRGBA(desc.colors[RUNETYPE_BLOOD])); end
		local sw_unholy = RDXUI.GenerateColorSwatch(ui, i18n("Unholy rune color"));
		if desc and desc.colors and desc.colors[RUNETYPE_UNHOLY] then sw_unholy:SetColor(explodeRGBA(desc.colors[RUNETYPE_UNHOLY])); end
		local sw_frost = RDXUI.GenerateColorSwatch(ui, i18n("Frost rune color"));
		if desc and desc.colors and desc.colors[RUNETYPE_FROST] then sw_frost:SetColor(explodeRGBA(desc.colors[RUNETYPE_FROST])); end
		local sw_death = RDXUI.GenerateColorSwatch(ui, i18n("Death rune color"));
		if desc and desc.colors and desc.colors[RUNETYPE_DEATH] then sw_death:SetColor(explodeRGBA(desc.colors[RUNETYPE_DEATH])); end
		
		function ui:GetDescriptor()
			return {
				feature = "Vars: Rune Info";
				TextureType = dd_TextureType:GetSelection();
				colors = {
					[RUNETYPE_BLOOD] = sw_blood:GetColor(),
					[RUNETYPE_UNHOLY] = sw_unholy:GetColor(),
					[RUNETYPE_FROST] = sw_frost:GetColor(),
					[RUNETYPE_DEATH] = sw_death:GetColor(),
				};
			};
		end
		return ui;
	end;   

	CreateDescriptor = function()
		return {
			feature = "Vars: Rune Info";
			colors = {
				[RUNETYPE_BLOOD] =  { r=1,   g=0,   b=0.2, a=1 },
				[RUNETYPE_UNHOLY] = { r=0,   g=1,   b=0,   a=1 },
				[RUNETYPE_FROST] =  { r=0,   g=0.6, b=1,   a=1 },
				[RUNETYPE_DEATH] =  { r=0.6, g=0.3, b=0.6, a=1 },
			};
		};
	end;
});

-------------------------------------
-- Runes Bar Skin
-- 
-- UnitFrameFeature to create custom Deathknight RuneElements
-- Cripsii Kirin Tor EU
-------------------------------------

--------------- Code emitter helpers
local function _EmitCreateCode2(objname, desc)
	if not desc.nIcons then desc.nIcons = 6; end
	local ebsos = desc.ButtonSkinOffset;
	
	local cdTimerType = "COOLDOWN"; if desc.cdTimerType then cdTimerType = desc.cdTimerType; end
	local cdtext, cdgfx, cdGfxReverse, cdTxtType, cdHideTxt = "false", "false", "true", "MinSec", "0"; 
	if desc.cdTimerType == "COOLDOWN" then cdtext = "false"; cdgfx = "true"; 
	elseif desc.cdTimerType == "TEXT" then cdtext = "true"; cdgfx = "false";
	elseif desc.cdTimerType == "COOLDOWN&TEXT" then cdtext = "true"; cdgfx = "true";
	end
	if desc.cdGfxReverse then cdGfxReverse = "false"; end
	if desc.cdTxtType then cdTxtType = desc.cdTxtType; end
	if desc.cdHideTxt then cdHideTxt = desc.cdHideTxt; end
      
	local createCode = [[
	frame.]] .. objname .. [[ = {};
	local btn, btnOwner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
	for i=1,6 do
		btn = VFLUI.AcquireFrame("Button");
		btn:SetParent(btnOwner);
		btn:SetFrameLevel(btnOwner:GetFrameLevel());
		btn:SetWidth(]] .. desc.sizew .. [[); btn:SetHeight(]] .. desc.sizeh .. [[);
		
		RDXUI.ApplyButtonSkin(btn, mddata_]] .. objname .. [[, true, false, false, true, true, true, false, true, false, true);
		btn:SetScript("OnEnter", __RuneOnEnter);
		btn:SetScript("OnLeave", __RuneOnLeave);

		btn.tex = VFLUI.CreateTexture(btn);
		btn.tex:SetPoint("TOPLEFT", btn, "TOPLEFT", ]] .. ebsos .. [[, -]] .. ebsos .. [[);
		btn.tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -]] .. ebsos .. [[, ]] .. ebsos .. [[);
		btn.tex:SetTexCoord(0.08, 1-0.08, 0.08, 1-0.08);
		btn.tex:SetTexture("Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood");
		local runeType = GetRuneType(i);
		if runeType then
			]];
			if desc.customtexture then
				createCode = createCode .. VFLUI.GenerateSetTextureCode("btn.tex", desc.runetexture);
				createCode = createCode .. [[
				btn.tex:SetVertexColor(explodeRGBA(runecolo_cl[runeType]));
				]];
			else
				createCode = createCode .. [[
				btn.tex:SetTexture(VFLGetRuneIconTexturesOn(runeType));]]; 
			end
			
			createCode = createCode ..[[   
			btn.tex:Show();
			btn.tooltipText = _G["COMBAT_TEXT_RUNE_"..VFLGetRuneMapping(runeType)];
		end
		
		btn.cd = RDXUI.CooldownCounter:new(btn, ]] .. cdtext .. ", " .. cdgfx .. [[, true, 0.3, "]] .. cdTxtType .. [[", ]] .. cdGfxReverse .. [[, ]] .. desc.cdoffx .. [[, ]] .. desc.cdoffy .. [[, ]] .. cdHideTxt .. [[);
		btn.cd:SetAllPoints(btn.tex);
		btn.cd:Show();
		
		]];
		createCode = createCode .. VFLUI.GenerateSetFontCode("btn.cd.fs", desc.cdFont, nil, true);
		
		createCode = createCode .. [[
		frame.]] .. objname .. [[[i] = btn;
	end
]];
	createCode = createCode .. RDXUI.LayoutCodeMultiRows(objname, desc);
	return createCode;
end

RDX.RegisterFeature({
	name = "runes_bar_vars";
	title = i18n("Runes Bar Skin");
	version = 1;
	multiple = false;
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
		if not desc.externalButtonSkin then VFL.AddError(errs, i18n("Select button skin")); flg = nil; end
		if not RDXDB.AccessPath(RDXDB.ParsePath(desc.externalButtonSkin)) then VFL.AddError(errs, i18n("Invalid button skin")); flg = nil; end
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		-- Event hinting.
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("RUNE_POWER_UPDATE");
		local mask = mux:GetPaintMask("RUNE_TYPE_UPDATE");
		
		------------ Closure
		local closureCode = [[
local mddata_]] .. objname .. [[ = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
local runecolo_cl = {};
runecolo_cl[1] = ]] .. Serialize(desc.bloodColor) .. [[;
runecolo_cl[2] = ]] .. Serialize(desc.unholyColor) .. [[;
runecolo_cl[3] = ]] .. Serialize(desc.frostColor) .. [[;
runecolo_cl[4] = ]] .. Serialize(desc.deathColor) .. [[;
]];
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);
		
		----------------- Creation
		local createCode = _EmitCreateCode2(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);
	
		------------------- Destruction
      		local destroyCode = [[
local btn = nil;
for i=1,6 do
	btn = frame.]] .. objname .. [[[i]
	VFLUI.ReleaseRegion(btn.tex); btn.tex = nil;
	btn.cd:Destroy(); btn.cd = nil;
	RDXUI.DestroyButtonSkin(btn)
	btn.tooltipText = nil;
	btn:Destroy();
end
frame.]] .. objname .. [[ = nil;
		]];
		state:Attach("EmitDestroy", true, function(code) code:AppendCode(destroyCode); end);

		------------------- Paint
		
		local paintCode = [[
local hide = false;
local classMnemonic = RDXPlayer:GetClassMnemonic();
if ( classMnemonic ~= "DEATHKNIGHT" ) then
	hide = true;
end
local _runes = frame.]] .. objname .. [[;
local start, duration, timeleft, runeType;
for i=1,6 do
	start, duration = GetRuneCooldown(i);
	timeleft = duration - (GetTime() - start);
	runeType = GetRuneType(i);
	if (runeType) then 
	]];
		if desc.customtexture then
			paintCode = paintCode .. VFLUI.GenerateSetTextureCode("_runes[i].tex", desc.runetexture);
			paintCode = paintCode .. [[
			_runes[i].tex:SetVertexColor(explodeRGBA(runecolo_cl[runeType]));
			]];
		else
			paintCode = paintCode .. [[
			_runes[i].tex:SetTexture(VFLGetRuneIconTexturesOn(runeType));
			]];
		end
	
		paintCode = paintCode .. [[
		_runes[i].tooltipText = _G["COMBAT_TEXT_RUNE_"..VFLGetRuneMapping(runeType)];
	end
	__SetRunes(_runes[i], duration, timeleft, hide);
end
]];
		state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCode); end);
		
		mux:Event_UnitMask("UNIT_RUNE_POWER_UPDATE", mask);
		mux:Event_UnitMask("UNIT_RUNE_TYPE_UPDATE", mask);
		return true;
	end;
	
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		------------- Core
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Core Parameters")));
		
		local ed_name = VFLUI.LabeledEdit:new(ui, 100); ed_name:Show();
		ed_name:SetText(i18n("Name"));
		ed_name.editBox:SetText(desc.name);
		ui:InsertFrame(ed_name);
		
		------------- Layout
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Layout")));
		
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end
		
		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);
		
		local ed_rows = VFLUI.LabeledEdit:new(ui, 50); ed_rows:Show();
		ed_rows:SetText(i18n("Row size"));
		if desc and desc.rows then ed_rows.editBox:SetText(desc.rows); end
		ui:InsertFrame(ed_rows);
		
		local er = RDXUI.EmbedRight(ui, i18n("Orientation:"));
		local dd_orientation = VFLUI.Dropdown:new(er, RDXUI.OrientationDropdownFunction);
		dd_orientation:SetWidth(75); dd_orientation:Show();
		if desc and desc.orientation then
			dd_orientation:SetSelection(desc.orientation);
		else
			dd_orientation:SetSelection("RIGHT");
		end
		er:EmbedChild(dd_orientation); er:Show();
		ui:InsertFrame(er);
	
		local ed_iconspx = VFLUI.LabeledEdit:new(ui, 50); ed_iconspx:Show();
		ed_iconspx:SetText(i18n("Icons spacing width"));
		if desc and desc.iconspx then ed_iconspx.editBox:SetText(desc.iconspx); else ed_iconspx.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspx);
		
		local ed_iconspy = VFLUI.LabeledEdit:new(ui, 50); ed_iconspy:Show();
		ed_iconspy:SetText(i18n("Icons spacing height"));
		if desc and desc.iconspy then ed_iconspy.editBox:SetText(desc.iconspy); else ed_iconspy.editBox:SetText("0"); end
		ui:InsertFrame(ed_iconspy);
		
		local ed_sizew = VFLUI.LabeledEdit:new(ui, 50); ed_sizew:Show();
		ed_sizew:SetText(i18n("Icon Size width"));
		if desc and desc.sizew then ed_sizew.editBox:SetText(desc.sizew); end
		ui:InsertFrame(ed_sizew);
		
		local ed_sizeh = VFLUI.LabeledEdit:new(ui, 50); ed_sizeh:Show();
		ed_sizeh:SetText(i18n("Icon Size height"));
		if desc and desc.sizeh then ed_sizeh.editBox:SetText(desc.sizeh); end
		ui:InsertFrame(ed_sizeh);
	
		-------------- ButtonSkin or Frame
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Skin type")));
		
		local erbs = RDXUI.EmbedRight(ui, i18n("Button Skin :"));
		local file_extBS = RDXDB.ObjectFinder:new(erbs, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "ButtonSkin$")); end);
		file_extBS:SetWidth(200); file_extBS:Show();
		erbs:EmbedChild(file_extBS); erbs:Show();
		ui:InsertFrame(erbs);
		if desc.externalButtonSkin then file_extBS:SetPath(desc.externalButtonSkin); end
	
		local ed_bs = VFLUI.LabeledEdit:new(ui, 50); ed_bs:Show();
		ed_bs:SetText(i18n("Button Skin Size Offset :"));
		if desc and desc.ButtonSkinOffset then ed_bs.editBox:SetText(desc.ButtonSkinOffset); end
		ui:InsertFrame(ed_bs);
		
		local chk_texture = VFLUI.Checkbox:new(ui); chk_texture:Show();
		chk_texture:SetText(i18n("Use Custom Texture"));
		if desc and desc.customtexture then chk_texture:SetChecked(true); else chk_texture:SetChecked(); end
		ui:InsertFrame(chk_texture);
	
		local er_btx = RDXUI.EmbedRight(ui, i18n("Rune Texture"));
		local runetexsel = VFLUI.MakeTextureSelectButton(er_btx, desc.runetexture); runetexsel:Show();
		er_btx:EmbedChild(runetexsel); er_btx:Show();
		ui:InsertFrame(er_btx);
		
		local sw_blood = RDXUI.GenerateColorSwatch(ui, i18n("Blood rune color"));
		if desc and desc.bloodColor then sw_blood:SetColor(explodeRGBA(desc.bloodColor)); end
		local sw_unholy = RDXUI.GenerateColorSwatch(ui, i18n("Unholy rune color"));
		if desc and desc.unholyColor then sw_unholy:SetColor(explodeRGBA(desc.unholyColor)); end
		local sw_frost = RDXUI.GenerateColorSwatch(ui, i18n("Frost rune color"));
		if desc and desc.frostColor then sw_frost:SetColor(explodeRGBA(desc.frostColor)); end
		local sw_death = RDXUI.GenerateColorSwatch(ui, i18n("Death rune color"));
		if desc and desc.deathColor then sw_death:SetColor(explodeRGBA(desc.deathColor)); end
		
		------------------ display
		local er_cdTimerType, dd_cdTimerType, chk_cdGfxReverse, ed_cdHideTxt, er_cdFont, dd_cdFont, er_cdTxtType, dd_cdTxtType, ed_cdoffx, ed_cdoffy = RDXUI.GenCooldownPortion(ui, desc);
      
		function ui:GetDescriptor()
			
			return {
				feature = "runes_bar_vars"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				rows = VFL.clamp(ed_rows.editBox:GetNumber(), 1, 5);
				orientation = dd_orientation:GetSelection();
				iconspx = VFL.clamp(ed_iconspx.editBox:GetNumber(), 0, 200);
				iconspy = VFL.clamp(ed_iconspy.editBox:GetNumber(), 0, 200);
				sizew = VFL.clamp(ed_sizew.editBox:GetNumber(), 1, 50);
				sizeh = VFL.clamp(ed_sizeh.editBox:GetNumber(), 1, 50);
				
				customtexture = chk_texture:GetChecked();
				runetexture = runetexsel:GetSelectedTexture();
				externalButtonSkin = file_extBS:GetPath();
				ButtonSkinOffset = VFL.clamp(ed_bs.editBox:GetNumber(), 0, 50);
				bloodColor = sw_blood:GetColor();
				unholyColor = sw_unholy:GetColor();
				frostColor = sw_frost:GetColor();
				deathColor = sw_death:GetColor();
				
				cdTimerType = dd_cdTimerType:GetSelection();
				cdGfxReverse = chk_cdGfxReverse:GetChecked();
				cdHideTxt = ed_cdHideTxt.editBox:GetText();
				cdFont = dd_cdFont:GetSelectedFont();
				cdTxtType = dd_cdTxtType:GetSelection();
				cdoffx = VFL.clamp(ed_cdoffx.editBox:GetNumber(), -50, 50);
				cdoffy = VFL.clamp(ed_cdoffy.editBox:GetNumber(), -50, 50);
			};
		end
		return ui;
	end;
	CreateDescriptor = function()
		local font = VFL.copy(Fonts.Default); font.size = 8; font.justifyV = "CENTER"; font.justifyH = "CENTER";
		return {
			feature = "runes_bar_vars"; 
			version = 1;
			name = "rune_bar_skin";
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			sizew = 20; sizeh = 20; rows = 1; orientation = "RIGHT"; iconspx = 5; iconspy = 0;
			cdFont = font; cdTimerType = "COOLDOWN"; cdoffx = 0; cdoffy = 0;
			externalButtonSkin = "Builtin:bs_default";
			ButtonSkinOffset = 0;
			bloodColor =  {r=1,g=0,b=0.2,a=1};
			unholyColor = {r=0,g=1,b=0,a=1};
			frostColor =  {r=0,g=0.6,b=1,a=1};
			deathColor =  {r=0.6,g=0.3,b=0.6,a=1};
		};
	end;
});
