-- Layout_SingleArtFrame.lua
-- OpenRDX
-- Sigg Rashgarroth EU
--

RDX.RegisterFeature({
	name = "layout_single_artframe"; version = 1;
	title = i18n("Single Art Frame"); category = i18n("Layout");
	IsPossible = function(state)
		if not state:HasSlots("ArtFrame", "SetupSubFrame") then return nil; end
		-- Exclusive with other layouts
		if state:Slot("Layout") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then return nil; end
		state:AddSlot("Layout");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local frame, win = nil, nil;
		---------------- UnitFrame allocator
		local genUF = state:GetSlotFunction("SetupSubFrame");
		-- CREATION FUNCTION
		-- Acquire our window upon creation
		local frameType = "Frame";
		
		local function create(w)
			win = w;
			frame = VFLUI.AcquireFrame(frameType);
			frame:SetScale(1); frame:SetMovable(true); frame:Show();
			w:SetClient(frame);
			-- Set us up as a unitframe.
			genUF(frame); 
		end
		
		local function destroy(w)
			win:SetClient(nil);
			if frame then
				frame:Destroy(); frame = nil; 
			end
			win = nil;
		end
		
		state:_Attach(state:Slot("Create"), true, create);
		state:_Attach(state:Slot("Destroy"), true, destroy);
	end,
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);
		function ui:GetDescriptor()
			return { 
				feature = "layout_single_artframe"; version = 1;
			};
		end

		return ui;
	end;
	CreateDescriptor = function() 
		return {
			feature = "layout_single_artframe"; version = 1;
		};
	end;
});

