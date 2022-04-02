-- UnitFrameGlue.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--
-- Glue the custom UnitFrame system to the Windowing system.

----------------------------------------------------------------------
-- Code generation functor. Given a unitframe ObjectState, build the
-- create, paint, cleanup, and destroy functions.
----------------------------------------------------------------------
function RDX.UnitFrameGeneratingFunctor(state, path)
	if not state then return nil; end

	--- Build the code from the features
	local code = VFL.Snippet:new();
	code:AppendCode([[-- UnitFrame: ]] .. tostring(path) .. [[

local band,min,max,clamp = bit.band,math.min,math.max,VFL.clamp;
local strformat = string.format;
local _i, _j, _avail, _bn, _tex, _apps, _meta, _dur, _tl, _dispelt, _caster, _isStealable;
local _icons;
]]);
	state:RunSlot("EmitClosure", code);
	code:AppendCode([[
local function _paint(frame, icv, uid, unit, a1, a2, a3, a4, a5, a6, a7)
	if not unit then return; end
	if not uid then uid = unit.uid; end
	local paintmask = frame._paintmask or 0;
	if paintmask ~= 0 then
		frame.Frame_decor:Show();
]]);
	state:RunSlot("EmitPaintPreamble", code);
	state:RunSlot("EmitPaint", code);
	code:AppendCode([[
	end
end
local function _cleanup(frame)
	frame.Frame_decor:Hide();
]]);
	state:RunSlot("EmitCleanupPreamble", code);
	state:RunSlot("EmitCleanup", code);
	code:AppendCode([[
end

local hindex = {};
local hpri = nil;
local function _hotspot_set(frame, id, spot)
	if not id then
		hpri = spot;
	else
		hindex[id] = spot;
	end
end
local function _hotspot_get(frame, id)
	if id then return hindex[id]; else return hpri; end
end

local function _create(frame)
	frame.Cleanup = _cleanup;	frame.SetData = _paint;
	frame.GetHotspot = _hotspot_get; frame.SetHotspot = _hotspot_set;
	frame.Frame_decor = VFLUI.AcquireFrame("Frame");
	frame.Frame_decor:SetParent(frame);
	frame.Frame_decor:SetAllPoints(frame);
	frame.Frame_decor:Show();
]]);
	state:RunSlot("EmitCreatePreamble", code);
	state:RunSlot("EmitCreate", code);
	code:AppendCode([[
	frame.Destroy = VFL.hook(function(frame)
		frame.Cleanup = nil; frame.SetData = nil; 
]]);
	state:RunSlot("EmitDestroy", code);
		code:AppendCode([[
		frame.Frame_decor:Destroy(); frame.Frame_decor = nil;
		frame.GetHotspot = nil; frame.SetHotspot = nil;
		frame._paintmask = nil;
	end, frame.Destroy);

	return frame;
end

return _create;
]]);

	code = code:GetCode();

	-- If the debug module is enabled, store the compiled code for possible later analysis
	if path and RDXG.cdebug and RDXM_Debug.StoreCompiledObject then
		RDXM_Debug.StoreCompiledObject(path, code);
	end

	--- Execute the code
	local f, err = loadstring(code);
	if not f then
		VFL.TripError("RDX", i18n("Could not compile unit frame."), i18n("Error: ") .. err .. i18n("\n\nCode:\n------------\n") .. code);
		return nil;
	end
	return f();
end

local ufstate = RDX.UnitFrameState:new();

-- Unitframe state object used throughout
function RDX.LoadUnitFrameDesign(path, func, windowState)
	if not func then func = ufstate.ApplyAll; end
	local md,_,_,ty = RDXDB.GetObjectData(path);
	if (not md) or (not md.data) or (md.ty ~= "UnitFrameType") then return nil; end
	ufstate:SetContainingWindowState(windowState);
	ufstate:LoadDescriptor(md.data);
	local _errs = VFL.Error:new();
	if not func(ufstate, _errs, path) then
		_errs:ToErrorHandler("RDX", i18n("Could not load UnitFrameType at <") .. tostring(path) .. ">");
		return nil;
	end
	return ufstate;
end

-----------------------------------------------------------------
-- The UnitFrame feature.
-----------------------------------------------------------------
RDX.RegisterFeature({
	name = "UnitFrame",
	title = "Unit Frame",
	category = "Subframes";
	IsPossible = function(state)
		--if not state:Slot("UnitWindow") then return nil; end
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Frame") then return nil; end
		if state:Slot("StatusWindow") then return nil; end
		if state:Slot("UnitFrame") then return nil; end
		if state:Slot("ArtFrame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if (not desc) or (not desc.design) then
			VFL.AddError(errs, i18n("Bad or missing unit frame design."));
			return nil;
		else
			if not RDX.LoadUnitFrameDesign(desc.design, RDX.ObjectState.Verify, state) then
				VFL.AddError(errs, i18n("Could not load UnitFrameDesign at <") .. tostring(desc.design) .. ">.");
				return nil;
			end
		end
		state:AddSlot("UnitWindow", nil);
		state:AddSlot("UnitFrame");
		state:AddSlot("SetupSubFrame");
		state:AddSlot("SubFrameDimensions");
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- This variable will hold the frame pool for all unit frames associated to
		-- this window.
		local fp = nil;

		-- Load the functions from the design object provided by the user.
		local path = desc.design;
		local desPkg, desFile = RDXDB.ParsePath(desc.design);
		if not RDX.LoadUnitFrameDesign(desc.design, nil, state) then return nil; end
		local createFrame  = RDX.UnitFrameGeneratingFunctor(ufstate, desc.design);	
		if not createFrame then return nil; end

		-- Attach a function allowing other processes to get the ambient dimensions of the unit frame
		local dx,dy = ufstate:RunSlot("FrameDimensions");
		state:_Attach(state:Slot("SubFrameDimensions"), nil, function() return dx,dy; end);
	
		state:_Attach(state:Slot("Create"), true, function(w)
			-- When the window's underlying unitframe is updated, rebuild it.
			RDXDBEvents:Bind("OBJECT_UPDATED", nil, function(up, uf)
				if(up == desPkg) and (uf == desFile) then RDXDK.QueueLockdownAction(w._path, RDXDK._AsyncRebuildWindowRDX); end
			end, w._path .. path);
		end);
		
		-- The UnitFrame function should imbue a frame with unit-frame-hood
		state:_Attach(state:Slot("SetupSubFrame"), nil, createFrame);
		
		state:_Attach(state:Slot("Destroy"), true, function(w)
			-- Unbind us from the database update events
			RDXDBEvents:Unbind(w._path .. path);
		end);

		-- Make a menu for editing the unitframe type.
		state:Attach("Menu", true, function(win, mnu)
				table.insert(mnu, {
					text = i18n("Edit UnitFrame");
					OnClick = function()
						VFL.poptree:Release();
						RDXDB.OpenObject(path, "Edit");
					end;
				});
		end);

		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local ofDesign = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty=="UnitFrameType"); end);
		ofDesign:SetLabel(i18n("Frame type:"));
		if desc and desc.design then ofDesign:SetPath(desc.design); end
		ui:InsertFrame(ofDesign);

		function ui:GetDescriptor()
			return { feature = "UnitFrame", design = ofDesign:GetPath() };
		end
		
		return ui;
	end,
	CreateDescriptor = function() return { feature = "UnitFrame" }; end,
});
