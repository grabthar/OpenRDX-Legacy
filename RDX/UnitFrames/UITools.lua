-- UITools.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Helpful tools and objects for the UnitFrames UIs.

---------------------------------------------------
-- Generate a right-embedded color swatch inside a container.
---------------------------------------------------
function RDXUI.GenerateColorSwatch(ctr, text)
	local er = RDXUI.EmbedRight(ctr, text);
	local swatch = VFLUI.ColorSwatch:new(er);
	swatch:Show();
	er:EmbedChild(swatch); er:Show();
	ctr:InsertFrame(er);
	return swatch;
end

----------------------------------------------------
-- Given a unitframe state, compose a list of available objects on that state.
----------------------------------------------------
function RDXUI.ComposeObjectList(state, prefix, includeBase)
	local tbl = {};
	if (not state) or (not state:Slot("Base")) then return tbl; end
	if includeBase then table.insert(tbl, {text = "Base"}); end
	if type(prefix) == "table" then
		for i,p in pairs(prefix) do
			for x in state:SlotsMatching("^" .. p) do
				local _,_,trim = string.find(x, "^" .. p .. "(.*)$");
				if trim then
					table.insert(tbl, {text = p .. trim});
				end
			end
		end
	else
		for x in state:SlotsMatching("^" .. prefix) do
			local _,_,trim = string.find(x, "^" .. prefix .. "(.*)$");
			if trim then
				table.insert(tbl, {text = trim});
			end
		end
	end
	return tbl;
end

function RDXUI.ComposeFrameList(state)
	return RDXUI.ComposeObjectList(state, "Frame_", true);
end

function RDXUI.ComposeAnchorList(state)
	return RDXUI.ComposeObjectList(state, {"Frame_", "Text_", "Texture_", }, true);
end

----------------------------------------------------
-- Generate a dropdown that selects slots with a given prefix from a state.
----------------------------------------------------
function RDXUI.MakeSlotSelectorDropdown(ctr, title, state, prefix, includeBase, x1, x2)
	local er = RDXUI.EmbedRight(ctr, title);
	local dd_array = RDXUI.ComposeObjectList(state, prefix, includeBase);
	if x1 then table.insert(dd_array, {text = x1}); end
	if x2 then table.insert(dd_array, {text = x2}); end
	local dd = VFLUI.ComboBox:new(er, function() return dd_array; end);
	dd:SetWidth(250); dd:Show();
	er:EmbedChild(dd); er:Show();
	ctr:InsertFrame(er);

	return dd;
end

-- Validity check for boolean variables (allow true/false constants)
function RDXUI.IsValidBoolVar(vn, state)
	if (not vn) then return nil; end
	if (vn == "true") or (vn == "false") or (state:Slot("BoolVar_" .. vn)) then return true; else return nil; end
end

----------------------------------------------------
-- Anchor selection control for unit frames
----------------------------------------------------
local anchorpoints = {
	{ text = "TOPLEFT" },
	{ text = "TOP" },
	{ text = "TOPRIGHT" },
	{ text = "RIGHT" },
	{ text = "BOTTOMRIGHT" },
	{ text = "BOTTOM" },
	{ text = "BOTTOMLEFT" },
	{ text = "LEFT" },
	{ text = "CENTER" }
};
local function amOnBuild() return anchorpoints; end
RDXUI.AnchorPointSelectionFunc = amOnBuild;

RDXUI.UnitFrameAnchorSelector = {};
function RDXUI.UnitFrameAnchorSelector:new(parent)
	local self = VFLUI.GroupBox:new(parent);
	VFLUI.GroupBox.MakeTextCaption(self, i18n("Anchor"));
	self:SetLayoutConstraint("WIDTH_DOWNWARD_HEIGHT_UPWARD");
	local ctr = VFLUI.CompoundFrame:new(self); ctr:Show();
	self:SetClient(ctr);

	-- Local anchor point
	local er = RDXUI.EmbedRight(ctr, i18n("Anchor local point:"));
	local dd_lp = VFLUI.Dropdown:new(er, amOnBuild);
	dd_lp:SetWidth(100); dd_lp:Show(); dd_lp:SetSelection("TOPLEFT");
	er:EmbedChild(dd_lp); er:Show();
	ctr:InsertFrame(er);

	-- Remote anchor frame
	local afArray = {};
	local afOnBuild = function() return afArray; end
	function self:SetAFArray(x) afArray = x; end

	er = RDXUI.EmbedRight(ctr, i18n("To object:"));
	local dd_af = VFLUI.ComboBox:new(er, afOnBuild);
	dd_af:SetWidth(150); dd_af:Show();
	er:EmbedChild(dd_af); er:Show();
	ctr:InsertFrame(er);
	
	-- Remote anchor point
	local er = RDXUI.EmbedRight(ctr, i18n("and remote point:"));
	local dd_rp = VFLUI.Dropdown:new(er, amOnBuild);
	dd_rp:SetWidth(100); dd_rp:Show(); dd_rp:SetSelection("TOPLEFT");
	er:EmbedChild(dd_rp); er:Show();
	ctr:InsertFrame(er);

	-- OffsetY
	local edy = VFLUI.LabeledEdit:new(ctr, 75); edy:SetText(i18n("Offset X/Y:")); edy:Show();
	local edx = VFLUI.Edit:new(edy); edx:Show();
	edx:SetHeight(24); edx:SetWidth(75); edx:SetPoint("RIGHT", edy.editBox, "LEFT");
	edy.Destroy = VFL.hook(function() edx:Destroy(); end, edy.Destroy);
	ctr:InsertFrame(edy);

	------------------------ SETUP
	function self:SetAnchorInfo(ai)
		dd_lp:SetSelection(ai.lp); dd_rp:SetSelection(ai.rp); dd_af:SetText(ai.af);
		edx:SetText(ai.dx); edy.editBox:SetText(ai.dy);
	end
	function self:GetAnchorInfo()
		local dx = VFL.clamp(edx:GetNumber(), -1024, 1024);
		local dy = VFL.clamp(edy.editBox:GetNumber(), -1024, 1024);
		return {
			lp = dd_lp:GetSelection(), rp = dd_rp:GetSelection(), af = dd_af:GetSelection(),
			dx = dx, dy = dy
		};
	end

	----------------------- Destructor
	self.Destroy = VFL.hook(function(s)
		s.SetAFArray = nil; 
		afArray = nil; afOnBuild = nil;
		s.SetAnchorInfo = nil; s.GetAnchorInfo = nil;
	end, self.Destroy);

	return self;
end

--- A helper function to resolve a frame reference to a variable on the object.
function RDXUI.ResolveFrameReference(ref)
	if (not ref) or (ref == "") or (ref == "Base") then return "frame"; end
	if string.find(ref, "^Frame_") then
		VFL.TripError("RDX", i18n("Warning: deprecated frame reference"), i18n("Deprecated frame reference <") .. ref .. ">");
		return "frame." .. ref;
	else
		return "frame.Frame_" .. ref;
	end
end

function RDXUI.ResolveTextureReference(ref)
	if (not ref) or (ref == "") or (ref == "Base") then return "tex1"; end
	return "frame.Texture_" .. ref;
end

function RDXUI.ResolveTextReference(ref)
	if (not ref) or (ref == "") or (ref == "Base") then return "customText"; end
	return "frame.Text_" .. ref;
end

--- A helper function to generate the appropriate arguments to SetPoint() given an
-- anchor descriptor
function RDXUI.ResolveAnchorReference(ref)
	if (not ref) or (ref == "") or (ref == "Base") then return "frame"; end
	if string.find(ref, "^Frame_") or string.find(ref, "^Texture_") or string.find(ref, "^Text_") then
		return "frame." .. ref;
	else
		return "frame.Frame_" .. ref;
	end
end

function RDXUI.AnchorCodeFromDescriptor(anchor)
	return "'" .. anchor.lp .. "'," .. RDXUI.ResolveAnchorReference(anchor.af) .. ",'" .. anchor.rp .. "'," .. anchor.dx .. "," .. anchor.dy;
end

------------------------------------------
-- Layout helpers
------------------------------------------

function RDXUI.LayoutCodeMultiRows(objname, desc)
	local createCode = [[
frame.]] .. objname .. [[[1]:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
for i=2, ]] .. desc.nIcons .. [[ do ]];
	local opri1, opri2, osec1, osec2, csx, csy, csxm, csym = '"RIGHT"', '"LEFT"', '"TOP"', '"BOTTOM"', -tonumber(desc.iconspx), 0, 0, -tonumber(desc.iconspy);
	if desc.orientation == "RIGHT" then
		opri1 = '"LEFT"'; opri2 = '"RIGHT"'; csx = tonumber(desc.iconspx); csy = 0;
	elseif desc.orientation == "DOWN" then
		opri1 = '"TOP"'; opri2 = '"BOTTOM"'; osec1 = '"LEFT"'; osec2 = '"RIGHT"'; csx = 0; csy = -tonumber(desc.iconspy); csxm = tonumber(desc.iconspx); csym = 0;
	elseif desc.orientation == "UP" then
		opri1 = '"BOTTOM"'; opri2 = '"TOP"'; osec1 = '"LEFT"'; osec2 = '"RIGHT"'; csx = 0; csy = tonumber(desc.iconspy); csxm = tonumber(desc.iconspx); csym = 0;
	end
	if desc.rows == 1 then 
		-- Single-row code
		createCode = createCode .. [[frame.]] .. objname .. [[[i]:SetPoint(]] .. opri1 .. [[, frame.]] .. objname .. [[[i-1], ]] .. opri2 .. [[, ]] .. csx .. [[, ]] .. csy .. [[);]];
	else 
		-- Multi-row code
		createCode = createCode .. [[
	if( VFL.mmod ( i + ]] .. desc.rows .. [[-1,]] .. desc.rows .. [[)  == 0 ) then 
	    frame.]] .. objname .. [[[i]:SetPoint(]] .. osec1 .. [[, frame.]] .. objname .. "[i-" .. desc.rows .. [[], ]] .. osec2 .. [[, ]] .. csxm .. [[, ]] .. csym .. [[);
	else 
	    frame.]] .. objname .. [[[i]:SetPoint(]] .. opri1 .. [[, frame.]] .. objname .. "[i-1], " .. opri2 .. [[, ]] .. csx .. [[, ]] .. csy .. [[);
	end
]];
	end
		createCode = createCode .. [[
end
]];
	return createCode;
end

------------------------------------------
-- Dropdown helpers
------------------------------------------
local fontdd = {};
for k,_ in pairs(Fonts) do
	table.insert(fontdd, { text = k } );
end

function RDXUI.FontDropdownFunction() return fontdd; end

local hadd = {
	{ text = "LEFT" },
	{ text = "CENTER" },
	{ text = "RIGHT" }
};
function RDXUI.HAlignDropdownFunction() return hadd; end

local vadd = {
	{ text = "TOP" },
	{ text = "CENTER" },
	{ text = "BOTTOM" }
};
function RDXUI.VAlignDropdownFunction() return vadd; end

local oradd = {
	{ text = "LEFT"},
	{ text = "RIGHT"},
	{ text = "DOWN"},
	{ text = "UP"},
};
function RDXUI.OrientationDropdownFunction() return oradd; end

local dladd = {
	{ text = "BACKGROUND" },
	{ text = "BORDER" },
	{ text = "ARTWORK" },
	{ text = "OVERLAY" },
	{ text = "HIGHLIGHT" }
};
function RDXUI.DrawLayerDropdownFunction() return dladd; end

local titadd = {
	{ text = "COOLDOWN&TEXT" },
	{ text = "COOLDOWN" },
	{ text = "TEXT" },
	{ text = "NONE" },
};
function RDXUI.TimerTypesDropdownFunction() return titadd; end

local cotadd = {
	{ text = "CountUP" },
	{ text = "CountDOWN" },
};
function RDXUI.CountTypesDropdownFunction() return cotadd; end

local _aurasadd = {
	{ text = "BUFFS" },
	{ text = "DEBUFFS" },
};
function RDXUI.AurasTypesDropdownFunction() return _aurasadd; end

--------------------------------------------
-- text timer type
--------------------------------------------
local tetadd = {
	{ text = "Largest" },
	{ text = "MinSec" },
	{ text = "Seconds" },
	{ text = "Tenths" },
	{ text = "Hundredths" },
};
function RDXUI.TextTypesDropdownFunction() return tetadd; end

local mapNTT = {
	["Largest"] = Emm,
	["MinSec"] = VFL.Time.FormatMinSec,
	["Seconds"] = VFL.NumberFloor,
	["Tenths"] = VFL.Tenths,
	["Hundredths"] = Hundredths,
}
function RDXUI.GetTextTimerTypesFunction(name) return mapNTT[name] or VFL.Time.FormatMinSec; end

local mapNTS = {
	["Largest"] = "Emm",
	["MinSec"] = "VFL.Time.FormatMinSec",
	["Seconds"] = "VFL.NumberFloor",
	["Tenths"] = "VFL.Tenths",
	["Hundredths"] = "Hundredths",
}
function RDXUI.GetTextTimerTypesString(name) return mapNTS[name] or "VFL.Time.FormatMinSec"; end

---------------------------------------------
-- Factored-out oft-repeated fragments
---------------------------------------------

function RDXUI.GenWidthHeightPortion(ui, desc, state)
	local ed_width = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Width"), state, "StaticVar_");
	if desc and desc.w then ed_width:SetSelection(desc.w); end
	
	local ed_height = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Height"), state, "StaticVar_");
	if desc and desc.h then ed_height:SetSelection(desc.h); end
	
	return ed_width, ed_height;
end

function RDXUI.GenNameWidthHeightPortion(ui, desc, state)
	local ed_name = VFLUI.LabeledEdit:new(ui, 100); ed_name:Show();
	ed_name:SetText(i18n("Name"));
	ed_name.editBox:SetText(desc.name);
	ui:InsertFrame(ed_name);
	
	local ed_width = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Width"), state, "StaticVar_");
	if desc and desc.w then ed_width:SetSelection(desc.w); end
	
	local ed_height = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Height"), state, "StaticVar_");
	if desc and desc.h then ed_height:SetSelection(desc.h); end

	--local ed_width = VFLUI.LabeledEdit:new(ui, 50); ed_width:Show();
	--ed_width:SetText(i18n("Width"));
	--if desc and desc.w then ed_width.editBox:SetText(desc.w); end
	--ui:InsertFrame(ed_width);

	--local ed_height = VFLUI.LabeledEdit:new(ui, 50); ed_height:Show();
	--ed_height:SetText(i18n("Height"));
	--if desc and desc.h then ed_height.editBox:SetText(desc.h); end
	--ui:InsertFrame(ed_height);

	return ed_name, ed_width, ed_height;
end

function RDXUI.GenCooldownPortion(ui, desc)
	ui:InsertFrame(VFLUI.Separator:new(ui, i18n("Cooldown Display")));
	
	local er_cdTimerType = RDXUI.EmbedRight(ui, i18n("Timer Type:"));
	local dd_cdTimerType = VFLUI.Dropdown:new(er_cdTimerType, RDXUI.TimerTypesDropdownFunction);
	dd_cdTimerType:SetWidth(150); dd_cdTimerType:Show();
	if desc and desc.cdTimerType then 
		dd_cdTimerType:SetSelection(desc.cdTimerType); 
	else
		dd_cdTimerType:SetSelection("NONE");
	end
	er_cdTimerType:EmbedChild(dd_cdTimerType); er_cdTimerType:Show();
	ui:InsertFrame(er_cdTimerType);
	
	local chk_cdGfxReverse = VFLUI.Checkbox:new(ui); chk_cdGfxReverse:Show();
	chk_cdGfxReverse:SetText(i18n("Cooldown graphics reverse"));
	if desc and desc.cdGfxReverse then chk_cdGfxReverse:SetChecked(true); else chk_cdGfxReverse:SetChecked(); end
	ui:InsertFrame(chk_cdGfxReverse);
	
	local ed_cdHideTxt = VFLUI.LabeledEdit:new(ui, 50); ed_cdHideTxt:Show();
	ed_cdHideTxt:SetText(i18n("Hide Text Cooldown (seconds left)"));
	if desc and desc.cdHideTxt then ed_cdHideTxt.editBox:SetText(desc.cdHideTxt); else ed_cdHideTxt.editBox:SetText("0"); end
	ui:InsertFrame(ed_cdHideTxt);
	
	local er_cdFont = RDXUI.EmbedRight(ui, i18n("Timer Text Font"));
	local dd_cdFont = VFLUI.MakeFontSelectButton(er_cdFont, desc.cdFont); 
	dd_cdFont:Show();
	er_cdFont:EmbedChild(dd_cdFont); er_cdFont:Show();
	ui:InsertFrame(er_cdFont);
	
	local er_cdTxtType = RDXUI.EmbedRight(ui, i18n("Timer Text Type:"));
	local dd_cdTxtType = VFLUI.Dropdown:new(er_cdTxtType, RDXUI.TextTypesDropdownFunction);
	dd_cdTxtType:SetWidth(150); dd_cdTxtType:Show();
	if desc and desc.cdTxtType then 
		dd_cdTxtType:SetSelection(desc.cdTxtType); 
	else
		dd_cdTxtType:SetSelection("MinSec");
	end
	er_cdTxtType:EmbedChild(dd_cdTxtType); er_cdTxtType:Show();
	ui:InsertFrame(er_cdTxtType);
	
	local ed_cdoffx = VFLUI.LabeledEdit:new(ui, 50); ed_cdoffx:Show();
	ed_cdoffx:SetText(i18n("Timer Text Offset X"));
	if desc and desc.cdoffx then ed_cdoffx.editBox:SetText(desc.cdoffx); else ed_cdoffx.editBox:SetText("0"); end
	ui:InsertFrame(ed_cdoffx);
	
	local ed_cdoffy = VFLUI.LabeledEdit:new(ui, 50); ed_cdoffy:Show();
	ed_cdoffy:SetText(i18n("Timer Text Offset Y"));
	if desc and desc.cdoffy then ed_cdoffy.editBox:SetText(desc.cdoffy); else ed_cdoffy.editBox:SetText("0"); end
	ui:InsertFrame(ed_cdoffy);
	
	return er_cdTimerType, dd_cdTimerType, chk_cdGfxReverse, ed_cdHideTxt, er_cdFont, dd_cdFont, er_cdTxtType, dd_cdTxtType, ed_cdoffx, ed_cdoffy;
end

--- Check to see if an object name is a valid name (alphanumeric/underscores only, 15 chars or less)
-- and is not previously taken on a state. Designed for use in ExposeFeature methods
function __UFFrameCheck_Proto(prefix, desc, state, errs)
	if desc and desc.name then
		if(desc.name == "Base") then
			VFL.AddError(errs, i18n("No object can be named 'Base.'"));
			return nil;
		end
		if not RDXDB.IsValidFileName(desc.name) then
			VFL.AddError(errs, i18n("Object names must be alphanumeric."));
			return nil;
		end
		if state:Slot(prefix .. desc.name) then
			VFL.AddError(errs, i18n("Duplicate object name '") .. desc.name .. "'.");
			return nil;
		end
		state:AddSlot(prefix .. desc.name);
		return true;
	else
		VFL.AddError(errs, i18n("Bad or missing object name."));
		return nil;
	end
end

function __UFFrameCheck(prefix)
	return function(desc, state, errs)
		return __UFFrameCheck_Proto(prefix, desc, state, errs);
	end;
end

__UFObjCheck = __UFFrameCheck("Obj_");

--- Check an anchor descriptor against a state to make sure we're anchoring to something that exists.
function __UFAnchorCheck(anchor, state, errs)
	if not anchor then
		VFL.AddError(errs, i18n("Invalid anchor definition."));
		return nil;
	end
	if (not anchor.lp) or (not anchor.rp) or (not anchor.dx) or (not anchor.dy) then
		VFL.AddError(errs, i18n("Missing anchor layout parameters."));
		return nil;
	end
	if (not anchor.af) then
		VFL.AddError(errs, i18n("Missing anchor target frame.")); return nil;
	end
	if (anchor.af == "Base") or (state:Slot("Frame_" .. anchor.af)) or (state:Slot("Text_" .. anchor.af)) or (state:Slot("Texture_" .. anchor.af)) then return true; end
	--if (anchor.af == "Base") or (state:Slot("Frame_" .. anchor.af)) then return true; end
	if state:Slot(anchor.af) then
		--VFL.AddError(errs, i18n("Warning: Deprecated Frame_ reference."));
		return true;
	end
	VFL.AddError(errs, i18n("Anchor target frame does not exist.")); return nil;
end

--- Check a frame owner exist.
function __UFOwnerCheck(owner, state, errs)
	if not owner then
		VFL.AddError(errs, i18n("Invalid owner definition."));
		return nil;
	end
	if (owner == "Base") or (state:Slot("Frame_" .. owner)) or (state:Slot("Subframe_" .. owner)) then return true; end
	VFL.AddError(errs, i18n("Owner frame does not exist.")); return nil;
end
