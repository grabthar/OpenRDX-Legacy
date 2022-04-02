-- Shaders.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- "Shaders" are independent pieces of code that change the way unit frames are
-- painted.

------------------------------------
-- Scripted Shader - a shader driven by a Script object.
------------------------------------
RDX.RegisterFeature({
	name = "Shader: Scripted";
	category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("EmitPaint") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local md,_,_,ty = RDXDB.GetObjectData(desc.script);
		if (not md) or (ty ~= "Script") or (not md.data) or (not md.data.script) then
			VFL.AddError(errs, i18n("Invalid script pointer.")); return nil;
		end
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- Apply the custom code.
		local paintCode = [[

]];
		paintCode = paintCode .. (RDXDB.GetObjectData(desc.script)).data.script;
		paintCode = paintCode .. [[

]];

		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
		
		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local scriptsel = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "Script")); end);
		scriptsel:SetLabel("Script object"); scriptsel:Show();
		if desc and desc.script then scriptsel:SetPath(desc.script); end
		ui:InsertFrame(scriptsel);

		function ui:GetDescriptor()
			return { 
				feature = "Shader: Scripted";
				script = scriptsel:GetPath();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "Shader: Scripted", 
		};
	end;
});

------------------------------
-- Show/Hide Element shader
------------------------------
RDX.RegisterFeature({
	name = "shader_showhide"; version = 1;
	title = i18n("Show/Hide"); category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		local flg = true;
		--if not (state:Slot("Subframe_" .. desc.owner)) then 
		--	VFL.AddError(errs, i18n("Invalid subframe")); flg = nil;
		--end
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local fname = RDXUI.ResolveFrameReference(desc.owner);
		local paintCode = [[
if ]] .. desc.flag .. [[ then ]] .. fname .. [[:Show(); else ]] .. fname .. [[:Hide(); end
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Target subframe"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local flag = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Condition variable"), state, "BoolVar_", nil, "true", "false");
		if desc and desc.flag then flag:SetSelection(desc.flag); end
		
		function ui:GetDescriptor()
			return {
				feature = "shader_showhide"; version = 1;
				owner = owner:GetSelection();
				flag = flag:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "shader_showhide"; version = 1;
			owner = "Base"; flag = "true";
		};
	end;
});

------------------------------
-- Show/Hide Texture shader
------------------------------
RDX.RegisterFeature({
	name = "shaderTex_showhide"; version = 1;
	title = i18n("Show/Hide Texture"); category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		--if (not desc.flag) or (not state:Slot("BoolVar_" .. desc.flag)) then
		--	VFL.AddError(errs, i18n("Invalid condition")); return nil;
		--end
		return true;
	end;
	ApplyFeature = function(desc, state)
		local tname = RDXUI.ResolveTextureReference(desc.owner);
		local paintCode = [[
if ]] .. desc.flag .. [[ then ]] .. tname .. [[:Show(); else ]] .. tname .. [[:Hide(); end
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Target Texture"), state, "Texture_", nil);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local flag = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Condition variable"), state, "BoolVar_", nil, "true", "false");
		if desc and desc.flag then flag:SetSelection(desc.flag); end
		
		function ui:GetDescriptor()
			return {
				feature = "shaderTex_showhide"; version = 1;
				owner = owner:GetSelection();
				flag = flag:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "shaderTex_showhide"; version = 1;
			owner = "Base"; flag = "true";
		};
	end;
});

------------------------------
-- Show/Hide Element shader
------------------------------
RDX.RegisterFeature({
	name = "shader_applytex"; version = 1;
	title = i18n("Apply Texture"); category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if (not desc.owner) or (not state:Slot("Texture_" .. desc.owner)) then
			VFL.AddError(errs, i18n("Invalid texture")); return nil;
		end
		if (not desc.var) then VFL.AddError(errs, i18n("Invalid variable")); return nil; end
		return true;
	end;
	ApplyFeature = function(desc, state)
		local tname = RDXUI.ResolveTextureReference(desc.owner);
		local paintCode = [[
]] .. tname .. [[:SetTexture(]] .. desc.var .. [[);
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Target texture"), state, "Texture_");
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local flag = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Texture variable"), state, "TexVar_");
		if desc and desc.var then flag:SetSelection(desc.var); end
		
		function ui:GetDescriptor()
			return {
				feature = "shader_applytex"; version = 1;
				owner = owner:GetSelection();
				var = flag:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "shader_applytex"; version = 1;
		};
	end;
});

------------------------------------
-- Smooth power bar shader
-- working like the freetimer
-- by Sigg
------------------------------------

local function ftStart(self, unit)
	self.start = true; self.unit = unit; self.fp = -1;
end

local function ftIsStart(self)
	return self.start;
end

local function ftDestroy(self)
	self.start = nil; self.unit = nil; self.fp = nil;
	self.bar = nil; self.text = nil; self.Start = nil; self.IsStart = nil; 
end

function RDX.CreateSPBClass(statusBar, textPower)
	-- Build the onupdate script.
	local onUpdate = [[
return function(self)
	if self.start and self.unit then
		self.fp = self.unit:FracPower();
]];
	if statusBar then onUpdate = onUpdate .. "self.bar:Show(); self.bar:SetValue(self.fp);"; end
	if textPower then onUpdate = onUpdate .. "self.text:SetText(string.format('%0.0f%%', self.fp*100));"; end
	
	-- stop when max power
	onUpdate = onUpdate .. [[
		if (self.unitGetClassMnemonic == "WARRIOR" or self.unitGetClassMnemonic == "DEATHKNIGHT") then
			if (self.fp == 0) then self.start = false; end
		else
			if (self.fp == 1) then self.start = false; end
		end
]];
	onUpdate = onUpdate .. [[
	end
end;
]];
	local updater = loadstring(onUpdate);
	if updater then updater = updater(); else updater = VFL.Noop; end

	return function(parent, sb, txt)
		local f = VFLUI.AcquireFrame("Frame");
		f:SetParent(parent);
		f:Show();
		f.bar = sb; f.text = txt; 
		f.Start = ftStart;
		f.IsStart = ftIsStart;
		f:SetScript("OnUpdate", updater);
		f.Destroy = VFL.hook(ftDestroy, f.Destroy);
		return f;
	end
end

RDX.RegisterFeature({
	name = "shader_SPB"; 
	version = 1;	
	multiple = true;
	title = i18n("Smooth Power Bar Shader"); category = i18n("Shaders");
	IsPossible = function(state)
		if not state:HasSlots("UnitFrame", "EmitClosure", "EmitCreate", "EmitPaint", "EmitDestroy") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		return true;
	end;
	ApplyFeature = function(desc, state, errs)
		local objname = "shader_SPB_" .. math.random(10000000); -- Generate a random ID.
		local sb = strtrim(desc.statusBar or "");
		local txt = strtrim(desc.text or "");
		local sbPresent, txtPresent = "true", "true";
		if sb == "" then sbPresent = "false"; sb = "nil"; else sb = RDXUI.ResolveFrameReference(desc.statusBar); end
		if txt == "" then txtPresent = "false"; txt = "nil"; else txt = RDXUI.ResolveFrameReference(desc.text); end

		--- Closure
		-- Create a SPB class for our frame (this avoids the nasty situation where we have to recompile
		-- the code every time a frame is created.)
		local closureCode = [[
local ftc_]] .. objname .. [[ = RDX.CreateSPBClass(]] .. sbPresent .. [[,]] .. txtPresent .. [[);
]];
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);

		--- Creation
		-- The shader is just a frame with an OnUpdate routine that updates the linked objects.
		local createCode = [[
frame.]] .. objname .. [[ = ftc_]] .. objname .. [[(frame, ]] .. sb .. [[, ]] .. txt .. [[);
]];
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);

		--- Paint
		local paintCode = [[
if ((uid == "player") or (uid == "pet")) then
if not frame.]] .. objname .. [[:IsStart() then
	frame.]] .. objname .. [[:Start(unit);
end
end

]];
		state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCode); end);

		--- Destruction
		local destroyCode = [[
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];
		state:Attach("EmitDestroy", true, function(code) code:AppendCode(destroyCode); end);
		
		local mux = state:GetContainingWindowState():GetSlotValue("Multiplexer");
		local mask = mux:GetPaintMask("POWER");
		mux:Event_UnitMask("UNIT_POWER", mask);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local statusBar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Status Bar"), state, "StatusBar_");
		if desc and desc.statusBar then statusBar:SetSelection(desc.statusBar); end
		
		local text = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Text"), state, "Text_");
		if desc and desc.text then text:SetSelection(desc.text); end
		
		function ui:GetDescriptor()
			return {
				feature = "shader_SPB"; version = 1;
				statusBar = statusBar:GetSelection();
				text = text:GetSelection();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return {
			feature = "shader_SPB"; version = 1;
		};
	end;
});

---------------------------------------------------------------------------------
-- Texture Cooldown
---------------------------------------------------------------------------------

--------------- Code emitter helpers
local function _EmitCreateCode(objname, desc)
	local ty, ebsos = '"Frame"', 0;
	if (not desc.ephemeral) then 
		ty = '"Button"';
		if desc.ButtonSkinOffset then ebsos = desc.ButtonSkinOffset; end
	else
		if not desc.bkd then desc.bkd = {}; end
		if desc.bkd.edgeSize then ebsos = desc.bkd.edgeSize/3; end
	end
	
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
local btn, btnOwner = nil, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[;
btn = VFLUI.AcquireFrame(]] .. ty .. [[);
btn:SetParent(btnOwner);
btn:SetFrameLevel(btnOwner:GetFrameLevel());
btn:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
btn:SetWidth(]] .. desc.w .. [[); 
btn:SetHeight(]] .. desc.h .. [[);
btn:EnableMouse(false);
]];
	if (not desc.ephemeral) then
		createCode = createCode .. [[
RDXUI.ApplyButtonSkin(btn, mddata_]] .. objname .. [[, true, false, false, true, true, true, false, true, false, true);
]];
	end	
	createCode = createCode .. [[
btn.tex = VFLUI.CreateTexture(btn);
btn.tex:SetPoint("TOPLEFT", btn, "TOPLEFT", ]] .. ebsos .. [[, -]] .. ebsos .. [[);
btn.tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -]] .. ebsos .. [[, ]] .. ebsos .. [[);
btn.tex:SetTexCoord(0.08, 1-0.08, 0.08, 1-0.08);
btn.tex:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetTextureCode("btn.tex", desc.texture);
	createCode = createCode .. [[
btn.cd = RDXUI.CooldownCounter:new(btn, ]] .. cdtext .. ", " .. cdgfx .. [[, true, 0.3, "]] .. cdTxtType .. [[", ]] .. cdGfxReverse .. [[, ]] .. desc.cdoffx .. [[, ]] .. desc.cdoffy .. [[, ]] .. cdHideTxt .. [[);
btn.cd:SetAllPoints(btn.tex);
btn.cd:Show();
]];
	createCode = createCode .. VFLUI.GenerateSetFontCode("btn.cd.fs", desc.cdFont, nil, true);
	createCode = createCode .. [[
frame.]] .. objname .. [[ = btn;

]];
	return createCode;
end

RDX.RegisterFeature({
	name = "texture_cooldown";
	version = 1;
	title = i18n("Texture Cooldown");
	category = i18n("Shaders");
	multiple = true;
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
		if not desc.timerVar or desc.timerVar == "" then VFL.AddError(errs, i18n("Missing variable timer.")); flg = nil; end
		if desc.externalButtonSkin then
			if not RDXDB.CheckObject(desc.externalButtonSkin, "ButtonSkin") then VFL.AddError(errs, i18n("Invalid button skin")); flg = nil; end
		end
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;
		local texIcondata = desc.tex or "";
		
		------------ Closure
		local closureCode = [[ ]];
		if not desc.ephemeral then 
			closureCode = closureCode .. [[
local mddata_]] .. objname .. [[ = RDXDB.GetObjectInstance(]] .. Serialize(desc.externalButtonSkin) .. [[);
]];
			state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);
		end
		
		
		----------------- Creation
		local createCode = _EmitCreateCode(objname, desc);
		state:Attach("EmitCreate", true, function(code) code:AppendCode(createCode); end);

		------------------- Destruction
		local destroyCode = [[
local btn = frame.]] .. objname .. [[;
]];
		if (not desc.ephemeral) then destroyCode = destroyCode .. [[ 
RDXUI.DestroyButtonSkin(btn);
]];
		end
		destroyCode = destroyCode .. [[
btn.cd:Destroy(); btn.cd = nil;
VFLUI.ReleaseRegion(btn.tex); btn.tex = nil;
btn:Destroy(); btn = nil;
frame.]] .. objname .. [[ = nil;
]];
		state:Attach("EmitDestroy", true, function(code) code:AppendCode(destroyCode); end);

		------------------- Paint
		local paintCode = [[
local btn = frame.]] .. objname .. [[;
]];
		if desc.dyntexture then
		paintCode = paintCode .. [[
btn.tex:SetTexture(]] .. texIcondata .. [[);
]];
		end
		paintCode = paintCode .. [[
if ]] .. desc.timerVar .. [[_start and ]] .. desc.timerVar .. [[_start > 0 then
	--btn.tex:Show();
	btn.cd:SetCooldown(]] .. desc.timerVar .. [[_start, ]] .. desc.timerVar .. [[_duration);
	btn:Show();
else
	--btn.tex:Hide();
	btn:Hide();
end
btn:Show();
]];
		state:Attach("EmitPaint", true, function(code) code:AppendCode(paintCode); end);

		------------------- Cleanup
		local cleanupCode = [[
frame.]] .. objname .. [[:Hide();
]];
		state:Attach("EmitCleanup", true, function(code) code:AppendCode(cleanupCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		------------- Core
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Core Parameters")));
		
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);
		
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);
		
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Timer")));
		
		local timerVar = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Timer variable"), state, "TimerVar_");
		if desc and desc.timerVar then timerVar:SetSelection(desc.timerVar); end
		
		------------- ButtonSkin
		ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Button Skin and Texture")));
		
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
		
		local er = RDXUI.EmbedRight(ui, i18n("Texture"));
		local tsel = VFLUI.MakeTextureSelectButton(er, desc.texture); tsel:Show();
		er:EmbedChild(tsel); er:Show();
		ui:InsertFrame(er);
		
		local chk_dyntexture = VFLUI.Checkbox:new(ui); chk_dyntexture:Show();
		chk_dyntexture:SetText(i18n("Use the Texture data"));
		if desc and desc.dyntexture then chk_dyntexture:SetChecked(true); else chk_dyntexture:SetChecked(); end
		ui:InsertFrame(chk_dyntexture);
		
		local tex = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Texture data"), state, "TexVar_");
		if desc and desc.tex then tex:SetSelection(desc.tex); end
		
		-------------- Cooldown Display
		local er_cdTimerType, dd_cdTimerType, chk_cdGfxReverse, ed_cdHideTxt, er_cdFont, dd_cdFont, er_cdTxtType, dd_cdTxtType, ed_cdoffx, ed_cdoffy = RDXUI.GenCooldownPortion(ui, desc);
		
		function ui:GetDescriptor()
			return { 
				feature = "texture_cooldown"; 
				version = 1;
				name = ed_name.editBox:GetText();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				owner = owner:GetSelection();
				anchor = anchor:GetAnchorInfo();
				timerVar = timerVar:GetSelection();
				externalButtonSkin = file_extBS:GetPath();
				ButtonSkinOffset = VFL.clamp(ed_bs.editBox:GetNumber(), 0, 50);
				texture = tsel:GetSelectedTexture();
				dyntexture = chk_dyntexture:GetChecked();
				tex = tex:GetSelection();
				
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
			feature = "texture_cooldown";
			version = 1;
			name = "texcd1";
			owner = "Base";
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			w = 36; h = 36;
			externalButtonSkin = "Builtin:bs_default";
			ButtonSkinOffset = 0;
			cdFont = font; cdTimerType = "COOLDOWN"; cdoffx = 0; cdoffy = 0;
		};
	end;
});



