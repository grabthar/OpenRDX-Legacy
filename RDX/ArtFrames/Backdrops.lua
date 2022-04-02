-- Backdrops.lua
-- OpenRDX
-- Sigg Rashgarroth EU
--
-- Creation and modifications of backdrops

------------------------------------------------------
-- Backdrop feature. Adds a backdrop to a subframe.
------------------------------------------------------
RDX.RegisterFeature({
	name = "artbackdrop"; version = 1; multiple = true;
	title = i18n("Backdrop"); category = i18n("Basics");
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
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

		-- Create
		local createCode = [[
VFLUI.SetBackdrop(]] .. fvar .. [[, ]] .. Serialize(desc.bkd) .. [[);
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
				feature = "artbackdrop"; version = 1;
				owner = owner:GetSelection();
				bkd = bkd:GetSelectedBackdrop();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { feature = "artbackdrop"; owner = "Base"; version = 1; bkd = VFL.copy(VFLUI.defaultBackdrop);};
	end;
});

