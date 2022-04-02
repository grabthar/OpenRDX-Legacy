-- UnitFrameType.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Setup and generative code for feature-based UnitFrames.

-----------------------------------------------------
-- UnitFrame rendering helpers.
-----------------------------------------------------
-- Set the value and colors of a status bar appropriately.
function RDX.SetStatusBar(bar, val, color, fadeColor)
	if fadeColor then
		tempcolor:blend(fadeColor, color, val);
		bar:SetStatusBarColor(tempcolor.r, tempcolor.g, tempcolor.b);
	else
		bar:SetStatusBarColor(color.r, color.g, color.b);
	end
	bar:SetValue(val);
end

-----------------------------------
-- The ObjectState for a UnitFrame.
-----------------------------------
RDX.UnitFrameState = {};
function RDX.UnitFrameState:new()
	local st = RDX.ObjectState:new();

	st.SetContainingWindowState = function(state, cws)
		state._ownerWindowState = cws;
	end;

	st.GetContainingWindowState = function(state) return state._ownerWindowState; end

	st.OnResetSlots = function(state)
		-- Mark this state as a UnitFrame
		state:AddSlot("UnitFrame", nil);
		-- The owner window also gets a slot
		state:AddSlot("GetContainingWindowState", nil);
		local qq = state._ownerWindowState;
		state:_SetSlotFunction("GetContainingWindowState", function() return qq; end);
		-- Add the code-emitter slots
		state:AddSlot("EmitClosure", true);
		state:AddSlot("EmitCreatePreamble", true);
		state:AddSlot("EmitCreate", true);
		state:AddSlot("EmitReparent", true);
		state:AddSlot("EmitPaintPreamble", true);
		state:AddSlot("EmitPaint", true);
		state:AddSlot("EmitCleanupPreamble", true);
		state:AddSlot("EmitCleanup", true);
		state:AddSlot("EmitDestroy", true);
		state:AddSlot("PaintHint", true);
		-- Add the decor-frame slot
		state:AddSlot("Subframe_decor");
	end

	st:Clear();
	return st;
end

local ufState = RDX.UnitFrameState:new();

-------------------------------------------
-- UNITFRAME EDITOR
-- just a modified feature editor for unitframe
-------------------------------------------
RDX.IsUnitframeEditorOpen = RDX.IsFeatureEditorOpen;

function RDX.UnitframeEditor(state, callback, augText)
	local dlg = RDX.FeatureEditor(state, callback, augText);
	if not dlg then return nil; end
	
	RDXDB.TogglePreviewWindow();
	RDXDB.PaintPreviewWindow(state);
	
	------ Close procedure
	dlg.Destroy = VFL.hook(function(s)
		RDXDB.ClosePreviewWindow();
	end, dlg.Destroy);
end

----------------------------------------------------------------------
-- The UnitFrameType filetype
----------------------------------------------------------------------
local function EditUnitFrameType(parent, path, md)
	if RDX.IsUnitframeEditorOpen() then return; end
	ufState:LoadDescriptor(md.data);
	RDX.UnitframeEditor(ufState, function(x)
		md.data = x:GetDescriptor();
		RDXDB.NotifyUpdate(path);
	end, path);
end

RDXDB.RegisterObjectType({
	name = "UnitFrameType";
	isFeatureDriven = true;
	New = function(path, md)
		md.version = 1;
	end;
	Edit = function(path, md, parent)
		EditUnitFrameType(parent or UIParent, path, md);
	end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		--if RDXU.devflag then
			table.insert(mnu, {
				text = i18n("Edit..."),
				OnClick = function()
					VFL.poptree:Release();
					EditUnitFrameType(dlg, path, md);
				end
			});
		--end
	end;
});
