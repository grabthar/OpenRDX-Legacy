-- Color.lua
-- VFL
-- (C)2007 Bill Johnson and The VFL Project
--
-- Data structures for dealing with color tables and color vectors.

local format = string.format;

-----------------------
-- UTILITY FUNCTIONS
-----------------------
--- Given three numbers x, y, z, put them in order from least to greatest.
-- Returns a vector (min, mid, max).
local function ordinate(x,y,z)
	if x<=y then
		if y<=z then return x,y,z; elseif z<=x then	return z,x,y;	else return x,z,y; end
	else -- y<=x
		if x<=z then return y,x,z; elseif z<=y then return z,y,x;	else return y,z,x; end
	end
end

--- Convert an RGB(0,1) color to an HLS(0,1) color.
local function RGBtoHLS(r,g,b)
	-- Ordinate the RGB values. The luminosity is the max.
	local cmin, cmid, l = ordinate(r,g,b);
	-- Early out for black or grey
	if(l == 0) then return 0,0,0; end -- black
	if(l == cmin) then return 0,l,0; end

	-- Compute saturation (max-min)/max
	local s = (l - cmin) / l;

	-- Compute hue.
	local ofs = (cmid - cmin) / (l - cmin) / 6.0;

	if l == r then -- primary hue is red
		if cmid == g then -- intermediary hue is green
			return ofs, l, s;
		else -- intermediary hue is blue
			return 1-ofs, l, s;
		end
	elseif l == g then -- primary hue is green
		if cmid == b then -- intermediary hue is blue
			return .333333 + ofs, l, s;
		else -- intermediary hue is red
			return .333333 - ofs, l, s;
		end
	else -- primary hue is blue
		if cmid == r then -- intermediary is red
			return .666666 + ofs, l, s;
		else -- intermediary is green
			return .666666 - ofs, l, s;
		end
	end
end

-- Convert an HLS(0,1) color to an RGB(0,1) color.
local function HLStoRGB(h,l,s)
	-- Grey case
	if(l == 0) then return 0,0,0; elseif(s == 0) then return l,l,l; end
	-- Magic numbers
	local x1 = l * (1 - s);	local x2 = l - x1;
	-- Color wheel cases
	if(h < .166667) then -- red->green
		return l, x1 + (x2 * h * 6), x1;
	elseif(h < .333333) then -- yellow->red
		return l - (x2 * (h - .166667) * 6), l, x1;
	elseif(h < .5) then -- green->blue
		return x1, l, x1 + (x2 * (h - .333333) * 6);
	elseif(h < .666667) then -- cyan->green
		return x1, l - (x2 * (h - .5) * 6), l;
	elseif(h < .833333) then -- blue->red
		return x1 + (x2 * (h - .666667) * 6), x1, l;
	else -- magenta->blue
		return l, x1, l - (x2 * (h - .833333) * 6);
	end
end

---------------------------------
-- GLOBAL COLOR METHODS
-- Some global methods to manipulate colors quickly.
---------------------------------

-- Linearly interpolate two color values, returning a vector.
function CVFromCTLerp(c1, c2, t)
	local d = 1-t;
	local r,g,b = (d*c1.r + t*c2.r), (d*c1.g + t*c2.g), (d*c1.b + t*c2.b);
	local a1,a2 = c1.a or 1, c2.a or 1;
	return r,g,b,(d*a1 + t*a2);
end

-- Retrieve a string formatting code from a color vector
function strcolor(r,g,b,a)
	return format("|c%02X%02X%02X%02X", floor((a or 1)*255), floor(r*255), floor(g*255), floor(b*255));
end
-- Retrieve a string formatting code from a color table
function strtcolor(t)
	local a = t.a or 1;
	local r,g,b = floor(t.r*255), floor(t.g*255), floor(t.b*255);	a = floor(a*255);
	return format("|c%02X%02X%02X%02X", a, r, g, b);
end
-- Use a color table to color a string
function tcolorize(str, t)
	local r,g,b,a = floor(t.r*255), floor(t.g*255), floor(t.b*255), floor((t.a or 1) * 255);
	return format("|c%02X%02X%02X%02X%s|r", a, r, g, b, str);
end
-- Use a color vector to color a string
function colorize(str, r, g, b, a)
	r = floor(r*255); g = floor(g*255); b = floor(b*255);	a = floor((a or 1) * 255);
	return format("|c%02X%02X%02X%02X%s|r", a, r, g, b, str);
end

-- Convert a color table to a color 3-vector
function explodeColor(rgb)
	return rgb.r, rgb.g, rgb.b;
end
-- Convert a color table to a color 4-vector
function explodeRGBA(rgb)
	return rgb.r, rgb.g, rgb.b, rgb.a or 1;
end

---------------------------------
-- COLOR OBJECT
-- Object oriented color manipulations.
---------------------------------
VFL.Color = {};
VFL.Color.__index = VFL.Color;

--------------- CONSTRUCTION/ACCESS
--- Create a new color on the given object.
function VFL.Color:new(o)
	x = o or {}; setmetatable(x, VFL.Color);
	return x;
end

-- Clone this color, creating an identical new color object.
function VFL.Color:clone()
	local x = {r=self.r, g=self.g, b=self.b, a=self.a};
	setmetatable(x, VFL.Color);
	return x;
end

-- Copy from the target color into this color
function VFL.Color:set(target)
	self.r = target.r; self.g = target.g; self.b = target.b; self.a = target.a;
end

-- Set color directly
function VFL.Color:RGBA(r,g,b,a)
	self.r = r; self.g = g; self.b = b; self.a = a;
end

-------------- BLEND OPERATORS

-- Blend this color via RGB linear interpolation between two colors.
function VFL.Color:blend(c1, c2, t)
	local d = 1-t;
	self.r = d*c1.r + t*c2.r;
	self.g = d*c1.g + t*c2.g;
	self.b = d*c1.b + t*c2.b;
	local a1,a2 = c1.a or 1, c2.a or 1;
	self.a = d*a1 + t*a2;
end

-- Modify the HLS of the passed color c2, storing the result in this color.
-- Any arguments not provided will be assumed to go unmodified in the transformation.
function VFL.Color:HLSTransform(c2, h, l, s)
	local x, y, z = RGBtoHLS(c2.r, c2.g, c2.b);
	h = h or x; l = l or y; s = s or z;
	x, y, z = HLStoRGB(h, l, s);
	self.r = x; self.g = y; self.b = z; self.a = c2.a or 1;
end

-------------------- OUTPUT OPERATORS
-- Get the WOW text formatting string corresponding to this color
function VFL.Color:GetFormatString()
	return format("|c%02X%02X%02X%02X", floor((self.a or 1)*255), floor(self.r*255), floor(self.g*255), floor(self.b*255));
end

-- Colorize the given string with this color
function VFL.Color:colorize(str)
	return format("|c%02X%02X%02X%02X%s|r", floor((self.a or 1)*255), floor(self.r*255), floor(self.g*255), floor(self.b*255), str);
end

-- Get a vector from this color
function VFL.Color:RGBAVector()
	return self.r, self.g, self.b, self.a;
end
function VFL.Color:RGBVector()
	return self.r, self.g, self.b;
end

----------------------- TEMPORARY COLORS
-- Use temporary colors to perform blend operations without consuming memory.
-- Global temporary color, used to reduce memory allocations during
-- blend ops
tempcolor = VFL.Color:new();

--- A self-walking temp. color array for more complicated blending scenarios.
local tc_array = {};
for i=1,20 do tc_array[i] = VFL.Color:new({r=1,g=1,b=1,a=1}); end

local tc_i = 0;
function VFL_TempColor()
	tc_i = tc_i + 1; if(tc_i > 20) then tc_i = 1; end
	return tc_array[tc_i];
end
