-- ArtFrameType.lua
-- OpenRDX
-- Sigg Rashgarroth EU

-----------------------------------
-- The ObjectState for a UnitFrame.
-----------------------------------
RDX.ArtFrameState = {};
function RDX.ArtFrameState:new()
	local st = RDX.ObjectState:new();

	st.SetContainingWindowState = function(state, cws)
		state._ownerWindowState = cws;
	end;

	st.GetContainingWindowState = function(state) return state._ownerWindowState; end

	st.OnResetSlots = function(state)
		-- Mark this state as a UnitFrame
		state:AddSlot("ArtFrame", nil);
		-- The owner window also gets a slot
		state:AddSlot("GetContainingWindowState", nil);
		local qq = state._ownerWindowState;
		state:_SetSlotFunction("GetContainingWindowState", function() return qq; end);
		-- Add the code-emitter slots
		--state:AddSlot("EmitClosure", true);
		--state:AddSlot("EmitCreatePreamble", true);
		state:AddSlot("EmitCreate", true);
		state:AddSlot("EmitReparent", true);
		--state:AddSlot("EmitPaintPreamble", true);
		--state:AddSlot("EmitPaint", true);
		--state:AddSlot("EmitCleanupPreamble", true);
		--state:AddSlot("EmitCleanup", true);
		state:AddSlot("EmitDestroy", true);
		--state:AddSlot("PaintHint", true);
		-- Add the decor-frame slot
		state:AddSlot("Subframe_decor");
	end

	st:Clear();
	return st;
end

local afState = RDX.ArtFrameState:new();

-------------------------------------------
-- ArtFRAME EDITOR
-------------------------------------------
RDX.IsArtframeEditorOpen = RDX.IsFeatureEditorOpen;

function RDX.ArtframeEditor(state, callback, augText)
	local dlg = RDX.FeatureEditor(state, callback, augText);
	if not dlg then return nil; end
	
	--RDXDB.TogglePreviewWindow();
	--RDXDB.PaintPreviewWindow(state);
	
	------ Close procedure
	dlg.Destroy = VFL.hook(function(s)
		RDXDB.ClosePreviewWindow();
	end, dlg.Destroy);
end

----------------------------------------------------------------------
-- The UnitFrameType filetype
----------------------------------------------------------------------
local function EditArtFrameType(parent, path, md)
	if RDX.IsArtframeEditorOpen() then return; end
	afState:LoadDescriptor(md.data);
	RDX.ArtframeEditor(afState, function(x)
		md.data = x:GetDescriptor();
		RDXDB.NotifyUpdate(path);
	end, path);
end

RDXDB.RegisterObjectType({
	name = "ArtFrameType";
	isFeatureDriven = true;
	New = function(path, md)
		md.version = 1;
	end;
	Edit = function(path, md, parent)
		EditArtFrameType(parent or UIParent, path, md);
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		--if RDXU.devflag then
			table.insert(mnu, {
				text = i18n("Edit..."),
				OnClick = function()
					VFL.poptree:Release();
					EditArtFrameType(dlg, path, md);
				end
			});
		--end
	end;
});
