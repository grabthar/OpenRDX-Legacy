-- List.lua
-- VFL
-- (C)2006 Bill Johnson
-- 
-- A List is a frame that contains a number of subframes and (possibly) a scrollbar.
VFLUI.List = {};

--- Create a new List.
-- @param cellHeight The height of each cell in the list.
-- @param fnAlloc The function called to allocate a new frame in the list.
function VFLUI.List:new(parent, cellHeight, fnAlloc)
	local self = VFLUI.AcquireFrame("Frame");
	if parent then
		self:SetParent(parent); self:SetFrameStrata(parent:GetFrameStrata()); self:SetFrameLevel(parent:GetFrameLevel());
	end

	---------
	-- PARAMETERS
	---------
	-- Dimensions
	local nCells, dy = 0, 0;
	-- Scrollbar
	local scrollbar = VFLUI.VScrollBar:new(self);
	local scrollEnabled = true;
	-- Apply data function
	local fnSize, fnData = VFL.EmptyLiterator();
	local fnApplyData = VFL.Noop;
	
	-- Get the cell height provided at list creation.
	function self:GetCellHeight() return cellHeight; end
	
	-- Set this list to empty.
	function self:SetEmpty() 
		self:SetDataSource(VFL.EmptyLiterator(), VFL.Noop); 
	end
	
	-- Set the underlying data source for this list. The data source must be a _linear iterator_
	-- which consists of a pair of functions; one to retrieve the size of the underlying list and
	-- one which takes a numerical parameter and returns the data at that index, or NIL for none.
	function self:SetDataSource(fnad, liSz, liData)
		fnSize = liSz; fnData = liData; fnApplyData = fnad;
		self:Update();
	end

	----------
	-- RENDERER
	-- We use a VFL grid renderer
	----------
	local grid = VFLUI.Grid:new(self);
	grid:SetPoint("TOPLEFT", self, "TOPLEFT"); grid:Show();
	-- Anchor the scrollbar to the grid
	scrollbar:ClearAllPoints();
	scrollbar:SetPoint("TOPLEFT", grid, "TOPRIGHT", 0, -16);
	scrollbar:SetPoint("BOTTOMRIGHT", grid, "BOTTOMRIGHT", 16, 16);
	
	-- Get the underlying grid.
	function self:_GetGrid() return grid; end
	
	-----------
	-- SCROLLING
	-- We use a VFL virtual grid view into the underlying data source
	-----------
	local virt = VFLUI.VirtualGrid:new(grid);
	virt.GetVirtualSize = function()
		local q = fnSize() - nCells + 1;
		if(q < 1) then q = 1; end
		return 1,q;
	end
	virt.OnRenderCell = function(v, c, x, y, vx, vy)
		local pos = y + vy - 1;
		local qq = fnData(pos);
		if not qq then 
			c:Hide() 
		else
			c:Show(); fnApplyData(c, qq, pos, y);
		end
	end
	self.SetVerticalScroll = function(g, val)
		local oldv, newv = virt.vy, math.floor(val);
		if(oldv ~= newv) then virt:SetVirtualPosition(1, newv); end
	end
	
	-- Change the scroll value of the list. If the second parameter is given, the scrollbar
	-- will be pinned to the maximum value.
	function self:SetScroll(n, max)
		-- Update the virtual position of the list
		if max then
			virt:SetVirtualPosition(virt:GetVirtualSize());
		else
			virt:SetVirtualPosition(1, n);
		end
		-- Paint the scrollbar
		if scrollbar:IsShown() then
			scrollbar:SetValue(virt.vy); VFLUI.ScrollBarRangeCheck(scrollbar);
		end
	end
	
	-- Enable mousewheel scrolling
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", function(thisframe, delta)
		local newpos, _, maxpos = virt.vy - delta, virt:GetVirtualSize();
		if(newpos < 1) then newpos = 1; elseif (newpos > maxpos) then newpos = maxpos; end
		self:SetScroll(newpos);
	end)

	----------
	-- SCROLL BARS
	-- Handle the scroll bars.
	-- They can appear and disappear based on the size of the list.
	----------
	local function GetModifiedWidth()
		local w = self:GetWidth();
		if scrollbar:IsShown() then return w-16; else return w; end
	end
	
	local function CreateScrollBar()
		-- Don't create if we already have one
		if scrollbar:IsShown() then return; end
		-- Resize the grid to accomodate the new scrollbar
		grid:SetCellDimensions(self:GetWidth() - 16, cellHeight);
		scrollbar:Show();
	end
	
	local function DestroyScrollBar()
		if not scrollbar:IsShown() then return; end
		grid:SetCellDimensions(self:GetWidth(), cellHeight);
		scrollbar:Hide();
	end

	--- Enable/disable the scroll bar for this grid
	function self:SetScrollBarEnabled(val)
		if val then scrollEnabled = true; else scrollEnabled = nil; end
	end
	
	----------
	-- PAINTING FUNCTIONS
	-- Repaint the list.
	----------
	-- Rebuild the list control. This should be used when the size of the container frame changes.
	function self:Rebuild()
		local oldnCells = nCells;
		nCells = math.floor(self:GetHeight() / cellHeight);
		if(nCells < 0) then nCells = 0; end
		if(oldnCells ~= nCells) then
			grid:Clear();
			grid:Size(1, nCells, fnAlloc);
			grid:SetCellDimensions(GetModifiedWidth(), cellHeight);
			scrollbar:SetPageSize(nCells);
			self:Update();
		else
			grid:SetCellDimensions(GetModifiedWidth(), cellHeight);
		end
	end

	-- Update the list in response to an update of the data table.
	function self:Update()
		_,dy = virt:GetVirtualSize();
		-- Get the pagesize for the scroll bar
		if(dy > 1) and nCells > 0 and scrollEnabled then
			CreateScrollBar();
			scrollbar:SetMinMaxValues(1, dy);
		else
			DestroyScrollBar();
		end
		virt:SetVirtualPosition(1, virt.vy);
		if scrollbar:IsShown() then
			scrollbar:SetValue(virt.vy); VFLUI.ScrollBarRangeCheck(scrollbar);
		end
	end

	-- Auto-rebuild on size changed if necessary
	self:SetScript("OnSizeChanged", self.Rebuild);

	-- Destroy handler.
	self.Destroy = VFL.hook(function(s)
		s.SetVerticalScroll = nil;
		scrollbar:Destroy(); scrollbar = nil;
		virt:Destroy();
		self.Rebuild = nil;
		self.GetCellHeight = nil;
		self.SetDataSource = nil;
		self.SetEmpty = nil;
		self.Update = nil;
		self.SetScroll = nil; self.SetScrollBarEnabled = nil;
		self._GetGrid = nil;
		self:EnableMouseWheel(false); self:SetScript("OnMouseWheel", nil);
	end, self.Destroy);

	return self;
end
