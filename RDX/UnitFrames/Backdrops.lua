-- Backdrops.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Creation and modifications of backdrops on UnitFrames and subframes.

------------------------------------------------------
-- Backdrop feature. Adds a backdrop to a subframe.
------------------------------------------------------
RDX.RegisterFeature({
	name = "backdrop"; version = 1; multiple = true;
	title = i18n("Backdrop");	category = i18n("Basics");
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		if not __UFOwnerCheck(desc.owner, state, errs) then return nil; end
		-- Verify there isn't two backdrops on the same owner frame
		if state:Slot("Bkdp_" .. desc.owner) then
			VFL.AddError(errs, i18n("Owner frame already has a backdrop.")); return nil;
		end
		-- Verify backdrop
		if type(desc.bkd) ~= "table" then VFL.AddError(errs, i18n("Invalid backdrop.")); return nil; end
		state:AddSlot("Bkdp_" .. desc.owner);
		return true;
	end;
	ApplyFeature = function(desc, state)
		local fvar = RDXUI.ResolveFrameReference(desc.owner);

		-- Closure
		local closureCode = [[
local bkdp_]] .. desc.owner .. [[ = ]] .. Serialize(desc.bkd) .. [[;
]];
		state:Attach("EmitClosure", true, function(code) code:AppendCode(closureCode); end);

		-- Create
		local createCode = [[
VFLUI.SetBackdrop(]] .. fvar .. [[, bkdp_]] .. desc.owner .. [[);
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

		-- Destroy
		local destroyCode = [[
if ]] .. fvar .. [[ then ]] .. fvar .. [[:SetBackdrop(nil); end
]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Backdrop
		local er = RDXUI.EmbedRight(ui, i18n("Backdrop style"));
		local bkd = VFLUI.MakeBackdropSelectButton(er, desc.bkd); bkd:Show();
		er:EmbedChild(bkd); er:Show();
		ui:InsertFrame(er);

		function ui:GetDescriptor()
			return { 
				feature = "backdrop"; version = 1;
				owner = owner:GetSelection();
				bkd = bkd:GetSelectedBackdrop();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "backdrop"; owner = "Base"; version = 1; bkd = VFL.copy(VFLUI.defaultBackdrop);};
	end;
});

-- Update old textures
RDX.RegisterFeature({
	name = "Backdrop"; version = 31337; invisible = true;
	IsPossible = VFL.Nil;
	VersionMismatch = function(desc)
		desc.feature = "backdrop"; desc.version = 1;
		if desc.bkd == "Straight Lines" then
			desc.bkd = {
				_border = "straight"; _backdrop = "none";
				edgeFile = "Interface\\Addons\\VFL\\Skin\\straight-border"; edgeSize = 8;
				insets = { left = 2, right = 2, top = 2, bottom = 2};
			};
		elseif desc.bkd == "Tooltip" then
			desc.bkd = {
				_border = "tooltip"; _backdrop = "none";
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border"; edgeSize = 16;
				insets = { left = 4, right = 4, top = 4, bottom = 4};
			};
		else
			desc.bkd = nil;
		end
		return true;
	end;
});

----------------------------------------------------------------------
-- Backdrop colorizers
----------------------------------------------------------------------
local function bdc_ef(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("No descriptor.")); return nil; end
		if not desc.flag then desc.flag = "true"; end
		if not RDXUI.IsValidBoolVar(desc.flag, state) then
			VFL.AddError(errs, i18n("Invalid flag variable.")); return nil;
		end
		-- Verify our frame
		if (not desc.owner) or ((desc.owner ~= "Base") and (not state:Slot("Subframe_" .. desc.owner))) then
			VFL.AddError(errs, i18n("Owner frame does not exist.")); return nil;
		end
		-- Verify color
		if (not desc.color) or (not state:Slot("ColorVar_" .. desc.color)) then
			VFL.AddError(errs, i18n("Invalid color variable.")); return nil;
		end
		return true;
end

local function bdc_uifd(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, "Owner", state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Color var
		local color = RDXUI.MakeSlotSelectorDropdown(ui, "Color variable", state, "ColorVar_");
		if desc and desc.color then color:SetSelection(desc.color); end

		function ui:GetDescriptor()
			return { 
				feature = desc.feature, owner = owner:GetSelection();
				color = color:GetSelection();
			};
		end

		return ui;
end

RDX.RegisterFeature({
	name = "Backdrop Border Colorizer";
	category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = bdc_ef;
	ApplyFeature = function(desc, state)
		local fvar = RDXUI.ResolveFrameReference(desc.owner);
		local paintCode = [[
]] .. fvar .. [[:SetBackdropBorderColor(explodeRGBA(]] .. desc.color .. [[));
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = bdc_uifd;
	CreateDescriptor = function()
		return { feature = "Backdrop Border Colorizer"; };
	end;
});

RDX.RegisterFeature({
	name = "Backdrop Colorizer";
	category = i18n("Shaders");
	multiple = true;
	IsPossible = function(state)
		if not state:Slot("UnitFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = bdc_ef;
	ApplyFeature = function(desc, state)
		local fvar = RDXUI.ResolveFrameReference(desc.owner);
		local paintCode = [[
]] .. fvar .. [[:SetBackdropColor(explodeRGBA(]] .. desc.color .. [[));
]];
		state:Attach(state:Slot("EmitPaint"), true, function(code) code:AppendCode(paintCode); end);
	end;
	UIFromDescriptor = bdc_uifd;
	CreateDescriptor = function()
		return { feature = "Backdrop Colorizer"; };
	end;
});

