-- Layout_HeaderGrid.lua
-- RDX - Raid Data Exchange
-- (C)2006-2007 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
--

local GetRDXUnit = RDX._ReallyFastProject;
local UIDToNumber = RDX.UIDToNumber;
local bor,band = bit.bor, bit.band;

-------------------------------------------------------------------
-- HEADER WINDOW DRIVER
--
-- This is the main feature for windows driven by headers.
-- It provides all the facilities of a DataSource and a Layout.
--
-- QUIRKS:
-- How do we account for window resizing? ANSWER: Don't. When in combat, the
-- window can only size downward, so just don't resize the containing frame
-- while in combat.
-------------------------------------------------------------------
local bucketFuncs = {
	RDXUI.TypewriterBucketing,
	RDXUI.GroupBucketing,
	RDXUI.ClassBucketing,
	RDXUI.ClassOrderBucketing,
};
RDX.RegisterFeature({
	name = "Header Grid";
	category = i18n("Layout");
	IsPossible = function(state)
		if not state:Slot("Frame") then return nil; end
		if not state:Slot("SetupSubFrame") then return nil; end
		if not state:Slot("SubFrameDimensions") then return nil; end
		if not state:Slot("SecureDataSource") then return nil; end
		if state:Slot("Layout") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if not desc then return nil; end
		state:AddSlot("HeaderDriver");
		state:AddSlot("Layout");
		state:AddSlot("RepaintAll"); state:AddSlot("RepaintSort"); state:AddSlot("RepaintData");
		--state:AddSlot("SecureDataSource"); -- Data sources are automatically Secured by HeaderGrids.
		state:AddSlot("SecureSubframes"); -- Data sources are automatically Secured by HeaderGrids.
		state:AddSlot("CellPrePaintAdvice", true); state:AddSlot("CellPostPaintAdvice", true);
		state:AddSlot("TotalPrePaintAdvice", true); state:AddSlot("TotalPostPaintAdvice", true);
		state:AddSlot("AcclimatizeAdvice", true); state:AddSlot("DeacclimatizeAdvice", true);
		return true;
	end;
	ApplyFeature = function(desc, state)

		---------------- Post-assemble functions
		local tprepa, prePaintAdvice, postPaintAdvice, tpostpa = VFL.Noop, VFL.Noop, VFL.Noop, VFL.Noop;
		local acca, deacca = VFL.Noop, VFL.Noop;
		local setTitle = VFL.Noop;
		state:_Attach(state:Slot("Assemble"), true, function(state, win)
			setTitle = state:GetSlotFunction("SetTitleText");
			tprepa = state:GetSlotFunction("TotalPrePaintAdvice");
			prePaintAdvice = state:GetSlotFunction("CellPrePaintAdvice");
			postPaintAdvice = state:GetSlotFunction("CellPostPaintAdvice");
			tpostpa = state:GetSlotFunction("TotalPostPaintAdvice");
			acca = state:GetSlotFunction("AcclimatizeAdvice");
			deacca = state:GetSlotFunction("DeacclimatizeAdvice");
		end);

		---------------- Locals
		local axis, dxn, cols, limit, hlt = desc.axis or 1, desc.dxn or 1, desc.cols or 1, desc.limit or 1000, desc.hlt;
		local bkt = desc.bkt or 1;
		local iFunc = state:GetSlotFunction("DataSourceIterator");
		local sizeFunc = state:GetSlotFunction("DataSourceSize");
		local grid, win, faux = nil, nil, nil;
		local defaultPaintMask = 0;
		local paintAll, paintSecure, paintData, secureUpdateTrigger;

		------------------ Unit lookup
		local umap = {};
		local function lookupUnit(rdxu,_,nid)
			if rdxu then
				return umap[rdxu.nid];
			elseif nid then
				return umap[nid];
			end
		end

		-- SECURE UPDATE TRIGGER
		-- Every RaidRosterUpdate triggers a whole bunch of updates to the unit frames. Instead
		-- of repainting the whole grid every time, let's bulk them up and repaint when we've
		-- already received all of the events.
		local noise = math.random(10000000);
		function secureUpdateTrigger()
			VFL.NextFrame(noise, paintSecure);
		end

		---------------- UnitFrame allocator
		local genUF = state:GetSlotFunction("SetupSubFrame");
		local dx, dy = (state:GetSlotFunction("SubFrameDimensions"))();
		dx = dx or 50; dy = dy or 12; -- BUGFIX: incase something goes wrong, don't crash/do unreasonable things

		-- "Acclimatize" a frame to this window.
		local function Acclimatize(hgrid, hdr, frame)
			genUF(frame); frame:Cleanup();
			acca(hgrid, hdr, frame);
			frame._paintmask = defaultPaintMask;
		end

		-- PAINT-ALL FUNCTION
		-- The paint all function updates the name lists of all the subordinate grids.
		function paintAll()
			if (not grid) or InCombatLockdown() then return; end
			local sz = grid:Stuff(iFunc, function(_,uid) return (UnitInRaid(uid) or UnitInParty(uid)) end, function(_,uid,unit)
			return unit.rosterName or "";
		end, bucketFuncs[bkt](cols), limit);
			-- If we didn't do any painting, invoke the secure update trigger anyway to ensure empty-window tasks
			-- are taken care of.
			--if(sz == 0) then secureUpdateTrigger(); end
			-- Sigg : many test need to be done
			-- When disconnecting while in combat and then relogging in the game, the following function make raidframes not appears
			-- so called PaintSecure immediately
			paintSecure();
		end

		-- PAINT-SECURE FUNCTION
		-- Called on secure updates.
		-- Resize the window to properly accomodate the new content; repaint mouse binding
		-- attributes; etc.
		function paintSecure()
			if (not grid) then return; end -- BUGFIX: in case we're deferred....
			-- Update the Unit ID mapping.
			for k in pairs(umap) do umap[k] = nil; end
			local n, maxx, maxy = 0, 0, 0;
			for idx, x, y, cell, uid in grid:IterateAll() do
				if cell:IsShown() and uid then
					-- Rectify dimensions
					if(x > maxx) then maxx = x; end 
					if(y > maxy) then maxy = y; end
					n=n+1;
					-- Associate the unit index to the cell in the UID mapping.
					umap[UIDToNumber(uid)] = cell;
					-- Notify the paint core that a full repaint will be necessary for this cell on the next cycle
					cell._paintmask = 1;
				end
			end
			if not desc.countTitle then setTitle(" (" .. n .. ")"); end
			-- If not ICLD, resize the window
			if (not InCombatLockdown()) then
				if n > 0 then
					-- Populous window
					local szx, szy = grid:RectifyDimensions(n, maxx, maxy);
					faux:SetWidth(szx + .1);
					faux:SetHeight(szy + .1);
				else
					-- Empty window handling..
					faux:SetWidth(dx); faux:SetHeight(.1);
					if desc.countTitle then setTitle(" (0)"); end
				end
			end
			-- Paint the data as well
			paintData();
		end

		-- PAINT-DATA FUNCTION
		-- Iterate over the grid itself and apply to each cell's _subframe the appropriate unit
		-- data.
		function paintData(maskmod)
			if not grid then return; end
			maskmod = maskmod or 0;
			tprepa(win); -- Total prepaint advice
			local csf, rdxUnit, index = nil, nil, 0;
			for idx, x, y, cell, uid in grid:Iterator() do
				index = index + 1;
				rdxUnit = GetRDXUnit(uid);
				if rdxUnit then
					cell._paintmask = bor(cell._paintmask or 0, maskmod);
					prePaintAdvice(win, cell, index, idx, uid, rdxUnit);
					cell:SetData(idx, uid, rdxUnit);
					postPaintAdvice(win, cell, index, idx, uid, rdxUnit);
				else
					cell:Cleanup();
				end
				cell._paintmask = defaultPaintMask;
			end
			tpostpa(win); -- Total postpaint advice
		end

		-- CREATION FUNCTION
		-- Acquire our window upon creation
		local htype = nil; if desc.pet then htype = "SecureGroupPetHeader"; end
		local function create(w)
			win = w;
			-- "Faux frame" that will stand in as a client in the inverted control window.
			faux = VFLUI.AcquireFrame("Frame");
			faux:SetScale(1); faux:SetMovable(true); faux:Show();
			w:SetClient(faux);

			-- Header grid
			grid = RDX.HeaderGrid:new(faux, htype);
			local intDir, extDir = "TOP", "LEFT";
			if(axis == 2) then extDir = "TOP"; end
			if(dxn == 2) then intDir = "LEFT"; end
			grid:SetLayoutParameters(extDir, 0, 0, intDir, 0, 0, dx, dy);
			grid:SetPoint("TOPLEFT", faux, "TOPLEFT"); grid:Show();

			grid.OnAcclimatize = Acclimatize;
			grid.OnDeacclimatize = deacca;
			grid.OnSecureUpdate = secureUpdateTrigger;

			-- Profiling hooks
			if w._path then
				VFLP.RegisterCategory("Win: " .. w._path);
				VFLP.RegisterFunc("Win: " .. w._path, "RepaintLayout", paintAll, true);
				VFLP.RegisterFunc("Win: " .. w._path, "RepaintSecure", paintSecure, true);
				VFLP.RegisterFunc("Win: " .. w._path, "RepaintData", paintData, true);
				VFLP.RegisterFunc("Win: " .. w._path, "LookupUnit", lookupUnit, true);
			end
		end

		-- DESTROY FUNCTION
		-- Tear down all this
		local function destroy(w)
			win:SetClient(nil); -- BUGFIX: remember to remove client refs before destroying client..
			if grid then grid:Destroy(); grid = nil; end
			if faux then faux:Destroy(); faux = nil; end
			if win._path then VFLP.UnregisterCategory("Win: " .. win._path); end
			VFL.empty(umap);
			win.LookupUnit = nil;
			win = nil;
		end

		-- At assembly time, download the default paintmask from the multiplexer...
		state:Attach("Assemble", true, function(state, win)
			defaultPaintMask = tonumber(state:GetSlotValue("DefaultPaintMask")) or 0;
			win.LookupUnit = lookupUnit;
		end);

		state:Attach("Create", true, create);
		state:Attach("Destroy", true, destroy);
		state:Attach("RepaintAll", nil, function()
			local succ,err = pcall(paintAll);
			if not succ then RDXDK.PrintError(win, "RepaintAll", err); end
		end);
		state:Attach("RepaintLayout", nil, function()
			local succ,err = pcall(paintAll);
			if not succ then RDXDK.PrintError(win, "RepaintAll", err); end
		end);
		state:Attach("RepaintSort", nil, function()
			local succ,err = pcall(paintAll);
			if not succ then RDXDK.PrintError(win, "RepaintAll", err); end
		end);
		state:Attach("RepaintData", nil, function(z)
			local succ,err = pcall(paintData, z);
			if not succ then RDXDK.PrintError(win, "RepaintData", err); end
		end);
	end,
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local axis = VFLUI.RadioGroup:new(ui);
		axis:SetLayout(2,2);
		axis.buttons[1]:SetText("Grid expands horizontally");
		axis.buttons[2]:SetText("Grid expands vertically");
		if desc and desc.axis then
			axis:SetValue(desc.axis);
		else
			axis:SetValue(1);
		end
		ui:InsertFrame(axis);

		local rg_dxn = VFLUI.RadioGroup:new(ui);
		rg_dxn:SetLayout(2,2);
		rg_dxn.buttons[1]:SetText("Subheaders expand vertically");
		rg_dxn.buttons[2]:SetText("Subheaders expand horizontally");
		if desc and desc.dxn then
			rg_dxn:SetValue(desc.dxn);
		else
			rg_dxn:SetValue(1);
		end
		ui:InsertFrame(rg_dxn);

		local bkt = VFLUI.DisjointRadioGroup:new();

		local btn_fixed = bkt:CreateRadioButton(ui);
		btn_fixed:SetText("Buckets: Fixed-sized columns or rows:");
		local ed_width = VFLUI.Edit:new(btn_fixed); ed_width:Show(); 
		ed_width:SetPoint("RIGHT", btn_fixed, "RIGHT", 0, 0);
		ed_width:SetHeight(25); ed_width:SetWidth(50);
		if desc and desc.cols then ed_width:SetText(desc.cols); end
		btn_fixed.Destroy = VFL.hook(function() ed_width:Destroy(); end, btn_fixed.Destroy);
		ui:InsertFrame(btn_fixed);

		local btn_grp = bkt:CreateRadioButton(ui);
		btn_grp:SetText(i18n("Buckets: By group"));
		ui:InsertFrame(btn_grp);

		local btn_class = bkt:CreateRadioButton(ui);
		btn_class:SetText(i18n("Buckets: By class"));
		ui:InsertFrame(btn_class);

		local btn_classSort = bkt:CreateRadioButton(ui);
		btn_classSort:SetText(i18n("Buckets: By class, in sort order"));
		ui:InsertFrame(btn_classSort);

		bkt:SetValue(desc.bkt or 1);

		local chk_limit = VFLUI.Checkbox:new(ui); chk_limit:Show();
		local ed_limit = VFLUI.Edit:new(chk_limit); ed_limit:Show();
		ed_limit:SetHeight(25); ed_limit:SetWidth(50); ed_limit:SetPoint("RIGHT", chk_limit, "RIGHT");
		chk_limit.Destroy = VFL.hook(function() ed_limit:Destroy(); end, chk_limit.Destroy);
		chk_limit:SetText(i18n("Limit number of displayed frames to"));
		if desc and desc.limit then 
			chk_limit:SetChecked(true); 
			ed_limit:SetText(desc.limit);
		else 
			chk_limit:SetChecked();
			ed_limit:SetText("1");
		end
		ui:InsertFrame(chk_limit);
        
        local chk_title = VFLUI.Checkbox:new(ui); chk_title:Show();
		chk_title:SetText(i18n("Do not show UnitFrame count in title"));
		if desc then chk_title:SetChecked(desc.countTitle); end
		ui:InsertFrame(chk_title);
        
		local chk_pet = VFLUI.Checkbox:new(ui); chk_pet:Show();
		chk_pet:SetText(i18n("Show only pets"));
		if desc and desc.pet then	chk_pet:SetChecked(true);	else chk_pet:SetChecked(nil); end
		ui:InsertFrame(chk_pet);
        
		function ui:GetDescriptor()
			local cols = VFL.clamp(ed_width:GetNumber(), 1, 100);
			local limit = nil; 
			if chk_limit:GetChecked() then limit = VFL.clamp(ed_limit:GetNumber(), 1, 100);	end
			return { 
				feature = "Header Grid"; 
				axis = axis:GetValue(); dxn = rg_dxn:GetValue();
				cols = cols; limit = limit; bkt = (bkt:GetValue() or 1);
				pet = chk_pet:GetChecked();
                countTitle = chk_title:GetChecked();
			};
		end

		return ui;
	end;
	CreateDescriptor = function() 
		return {
			feature = "Header Grid";
			axis = 1; dxn = 1; bkt = 1;	cols = 100;
		};
	end;
});
