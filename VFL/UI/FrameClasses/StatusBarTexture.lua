-- StatusBarTexture.lua
-- VFL
-- (C)2006 The VFL Project
--
-- A status bar system that provides some essential features missing from Blizzard's internal
-- StatusBar object.

local function statusBar_SetValueAndColorTable(self, v, c, t)
	self:SetValue(v, t); 
	self:SetVertexColor(c.r, c.g, c.b, c.a or 1);
end
local function statusBar_SetColorTable(self, c)
	self:SetVertexColor(c.r, c.g, c.b, c.a or 1);
end

local function onupdate(self, elapsed, v, t, maxx, horiz)
	self._totalElapsed = self._totalElapsed + elapsed
	if self._totalElapsed >= t then
		self._totalElapsed = 0;
		VFL.AdaptiveUnschedule(self);
		if horiz then
			self._bSetWidth(self, v*maxx + (1-v)*0.001);
			self:SetTexCoord(0, v, 0, 1);
		else
			if self._vertFix then
			self:SetTexCoord(0, 1, 1-v, 1);
			else
			self._bSetHeight(self, v*maxx + (1-v)*0.001);
			self:SetTexCoord(0, 1, 0, v);
			end
		end
		self._value = v;
		return v;
	end
	offset = linearInterpolation(self._value, v, 1/t*self._totalElapsed);
	if horiz then
		self._bSetWidth(self, offset*maxx + (1-offset)*0.001);
		self:SetTexCoord(0, offset, 0, 1);
	else
		if self._vertFix then
			self:SetTexCoord(0, 1, 1-offset, 1);
		else
			self._bSetHeight(self, offset*maxx + (1-offset)*0.001);
			self:SetTexCoord(0, 1, 0, offset);
		end
	end
	self._value = offset;
	return offset;
end


VFLUI.StatusBarTexture = {};
function VFLUI.StatusBarTexture:new(parent, vertFix)
	local s = VFLUI.CreateTexture(parent);
	s:SetDrawLayer("ARTWORK");
	s:SetWidth(0.001); s:SetHeight(0.001);

	-- Internal state variables
	local color1, color2 = nil, nil;
	local maxw, maxh = 0.001, 0.001;
	local offset;
	s._value = -1;
	s._vertFix = vertFix;
    
	s._bSetWidth, s._bSetHeight = s.SetWidth, s.SetHeight;
	local bSetWidth, bSetHeight = s._bSetWidth, s._bSetHeight;
	function s:SetWidth(w) maxw = w; bSetWidth(self, w); end
	function s:SetHeight(h) maxh = h; bSetHeight(self, h); end
	function s:SetColors(c1, c2) color1 = c1; color2 = c2; end

	function s:SetOrientation(o)
		bSetWidth(self, maxw); bSetHeight(self, maxh);
		if(o == "HORIZONTAL") then
			self:SetTexCoordModifiesRect(false);
			function self.SetValue(self2, v, t)
				if self2._value == v then return; end
				if t then
					VFL.AdaptiveUnschedule(self2);
					self._totalElapsed = 0;
					VFL.AdaptiveSchedule(self2, 0.021, function(_,elapsed)
						offset = onupdate(self2, elapsed, v, t, maxw, true);
						if color1 then self2:SetVertexColor(CVFromCTLerp(color1, color2, offset)); end
					end);
				else
					bSetWidth(self2, v*maxw + (1-v)*0.001);
					self2:SetTexCoord(0, v, 0, 1);
					if color1 then self2:SetVertexColor(CVFromCTLerp(color1, color2, v)); end
					self2._value = v;
				end
			end
		elseif(o == "VERTICAL") then
			if self._vertFix then
				self:SetTexCoordModifiesRect(true);
			end
			function self.SetValue(self2, v, t)
				if self2._value == v then return; end
				if t then
					self._totalElapsed = 0;
					VFL.AdaptiveSchedule(self2, 0.021, function(_,elapsed)
						offset = onupdate(self2, elapsed, v, t, maxh);
						if color1 then self2:SetVertexColor(CVFromCTLerp(color1, color2, offset)); end
					end);
				else
					if self2._vertFix then
						self2:SetTexCoord(0, 1, 1-v, 1);
					else
						bSetHeight(self2, v*maxh + (1-v)*0.001);
						self2:SetTexCoord(0, 1, 0, v);
					end
					if color1 then self2:SetVertexColor(CVFromCTLerp(color1, color2, v)); end
				end
			end
		end
	end

	s.SetValueAndColorTable = statusBar_SetValueAndColorTable;
	s.SetColorTable = statusBar_SetColorTable;

	s.Destroy = VFL.hook(function(s2)
		VFL.AdaptiveUnschedule(s2);
		s2.SetValueAndColorTable = nil; s2.SetColorTable = nil;
		color1 = nil; color2 = nil;
		s2.SetOrientation = nil; s2.SetWidth = nil; s2.SetHeight = nil; s2.SetColors = nil;
		s2._totalElapsed = nil; s._value = nil;
		s2:SetTexCoordModifiesRect(false);
		s2._vertFix = nil;
	end, s.Destroy);
	
	return s;
end
