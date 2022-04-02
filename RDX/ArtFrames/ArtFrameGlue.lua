-- ArtFrameGlue.lua
-- OpenRDX
-- Sigg Rashgarroth EU
-- Glue the custom ArtFrame system to the Windowing system.

function RDX.ArtFrameGeneratingFunctor(state, path)
	if not state then return nil; end

	--- Build the code from the features
	local code = VFL.Snippet:new();
	code:AppendCode([[-- ArtFrame: ]] .. tostring(path) .. [[

local band,min,max,clamp = bit.band,math.min,math.max,VFL.clamp;

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
		VFL.TripError("RDX", i18n("Could not compile art frame."), i18n("Error: ") .. err .. i18n("\n\nCode:\n------------\n") .. code);
		return nil;
	end
	return f();
end

local afstate = RDX.ArtFrameState:new();

-- Artframe state object used throughout
function RDX.LoadArtFrameDesign(path, func, windowState)
	if not func then func = afstate.ApplyAll; end
	local md,_,_,ty = RDXDB.GetObjectData(path);
	if (not md) or (not md.data) or (md.ty ~= "ArtFrameType") then return nil; end
	afstate:SetContainingWindowState(windowState);
	afstate:LoadDescriptor(md.data);
	local _errs = VFL.Error:new();
	if not func(afstate, _errs, path) then
		_errs:ToErrorHandler("RDX", i18n("Could not load ArtFrameType at <") .. tostring(path) .. ">");
		return nil;
	end
	return afstate;
end

-----------------------------------------------------------------
-- The UnitFrame feature.
-----------------------------------------------------------------
RDX.RegisterFeature({
	name = "ArtFrame",
	title = "Art Frame",
	category = "Subframes";
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Frame") then return nil; end
		if state:Slot("StatusWindow") then return nil; end
		if state:Slot("UnitFrame") then return nil; end
		if state:Slot("ArtFrame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if (not desc) or (not desc.design) then
			VFL.AddError(errs, i18n("Bad or missing art frame design."));
			return nil;
		else
			if not RDX.LoadArtFrameDesign(desc.design, RDX.ObjectState.Verify, state) then
				VFL.AddError(errs, i18n("Could not load ArtFrameDesign at <") .. tostring(desc.design) .. ">.");
				return nil;
			end
		end
		state:AddSlot("ArtFrame");
		state:AddSlot("SetupSubFrame");
		--state:AddSlot("SubFrameDimensions");
		
		return true;
	end;
	ApplyFeature = function(desc, state)
		-- This variable will hold the frame pool for all unit frames associated to
		-- this window.
		local fp = nil;

		-- Load the functions from the design object provided by the user.
		local path = desc.design;
		local desPkg, desFile = RDXDB.ParsePath(desc.design);
		if not RDX.LoadArtFrameDesign(desc.design, nil, state) then return nil; end
		local createFrame  = RDX.ArtFrameGeneratingFunctor(afstate, desc.design);	
		if not createFrame then return nil; end

		-- Attach a function allowing other processes to get the ambient dimensions of the unit frame
		--local dx,dy = afstate:RunSlot("FrameDimensions");
		--state:_Attach(state:Slot("SubFrameDimensions"), nil, function() return dx,dy; end);
	
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
			--if RDXU.devflag then
				table.insert(mnu, {
					text = i18n("Edit ArtFrame");
					OnClick = function()
						VFL.poptree:Release();
						RDXDB.OpenObject(path, "Edit");
					end;
				});
			--end
		end);

		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local ofDesign = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty=="ArtFrameType"); end);
		ofDesign:SetLabel(i18n("Frame type:"));
		if desc and desc.design then ofDesign:SetPath(desc.design); end
		ui:InsertFrame(ofDesign);

		function ui:GetDescriptor()
			return { feature = "ArtFrame", design = ofDesign:GetPath() };
		end
		
		return ui;
	end,
	CreateDescriptor = function() return { feature = "ArtFrame" }; end,
});
