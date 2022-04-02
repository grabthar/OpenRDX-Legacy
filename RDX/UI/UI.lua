-- UI.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL. UNLICENSED COPYING IS PROHIBITED.
--
-- Primitives associated with the RDX UI.
RDXUI = {};

--- Helper function: embed a fixed-width control on the right side of a variable-width
-- frame with a label.
function RDXUI.EmbedRight(parent, label)
	local frame = VFLUI.AcquireFrame("Frame");
	if parent then
		frame:SetParent(parent); frame:SetFrameStrata(parent:GetFrameStrata());
		frame:SetFrameLevel(parent:GetFrameLevel());
	end
	local lbl = VFLUI.MakeLabel(nil, frame, label);
	lbl:SetPoint("LEFT", frame, "LEFT");
	local child = nil
	function frame:EmbedChild(chd)
		if child then return; end
		child = chd;
		child:ClearAllPoints(); child:SetPoint("RIGHT", frame, "RIGHT");
		frame:SetHeight(VFL.clamp(child:GetHeight(), 12, 1000));
	end
	frame.DialogOnLayout = VFL.Noop;
	frame.Destroy = VFL.hook(function(s)
		s.EmbedChild = nil;
		if child then child:Destroy(); child = nil; end
	end, frame.Destroy);
	return frame;
end

function RDXUI.CheckEmbedRight(parent, label)
	local frame = VFLUI.Checkbox:new(parent);
	frame:SetText(label);

	local child = nil;
	function frame:EmbedChild(chd)
		if child then return; end
		child = chd;
		child:ClearAllPoints(); child:SetPoint("RIGHT", frame, "RIGHT");
		frame:SetHeight(VFL.clamp(child:GetHeight(), 16, 1000));
	end
	frame.DialogOnLayout = VFL.Noop;

	frame.Destroy = VFL.hook(function(s)
		s.EmbedChild = nil;
		if child then child:Destroy(); child = nil; end
	end, frame.Destroy);
	return frame;
end

------------------------------------------
-- TIMER WIDGET
-- A timer widget is an MM:SS.hh time display.
------------------------------------------
RDXUI.TimerWidget = {};
function RDXUI.TimerWidget:new(parent)
	local self = VFLUI.AcquireFrame("Frame");
	if parent then
		self:SetParent(parent); self:SetFrameStrata(parent:GetFrameStrata());
		self:SetFrameLevel(parent:GetFrameLevel() + 1);
	end

	local txt1 = VFLUI.CreateFontString(self);
	VFLUI.SetFont(txt1, Fonts.BastardusSans, 12);
	txt1:SetDrawLayer("OVERLAY"); txt1:SetJustifyH("RIGHT");
	txt1:SetJustifyV("BOTTOM");
	txt1:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT");
	txt1:Show();

	local txt2 = VFLUI.CreateFontString(self);
	VFLUI.SetFont(txt2, Fonts.BastardusSans, 12);
	txt2:SetDrawLayer("OVERLAY"); txt2:SetJustifyH("LEFT"); 
	txt2:SetJustifyV("BOTTOM");
	txt2:SetPoint("LEFT", txt1, "RIGHT", 0, 0);
	txt2:Show();
	
	local function Layout()
		local w = math.max(self:GetWidth(), 0);
		local h = math.max(self:GetHeight(), 0);
		VFLUI.SetFont(txt2, Fonts.BastardusSans, h*0.6);
		txt2:SetHeight(h*.6); txt2:SetWidth(h*1.2);
		txt2:SetPoint("LEFT", txt1, "RIGHT", 0, -(h*.15));

		VFLUI.SetFont(txt1, Fonts.BastardusSans, h);
		txt1:SetHeight(h); 
		txt1:SetWidth(math.max(w-(h*1.2), 0));
	end
	self:SetScript("OnShow", Layout);
	self:SetScript("OnSizeChanged", Layout);

	local t = 0;
	function self:SetTime(sec)
		t = sec;
		if(sec < 0) then sec = 0; end
		local s = math.floor(sec); local frac = (sec - s)*100;
		local m = math.floor(sec/60); sec = VFL.mmod(sec, 60);
		txt1:SetText(string.format("%d:%02d", m, sec));
		txt2:SetText(string.format("%02d", frac));
	end

	function self:GetTime() return t; end

	self.Destroy = VFL.hook(function(s)
		s.SetTime = nil; s.GetTime = nil;
		VFLUI.ReleaseRegion(txt1); txt1 = nil;
		VFLUI.ReleaseRegion(txt2); txt2 = nil;
	end, self.Destroy);
	
	return self;
end

-------------------------------------------------------
-- Cooldown count widget
-- This is just a cooldown with a fontstring optionally bolted onto it.
-------------------------------------------------------
RDXUI.CooldownCounter = {};
function RDXUI.CooldownCounter:new(parent, showText, showGraphic, dontSetFont, updateSpeed, TextType, reverse, fsoffsetx, fsoffsety, hideTextSec)
	if type(updateSpeed) ~= "number" then updateSpeed = 0.5; end
	if not hideTextSec then hideTextSec = 0; end
	local s = VFLUI.AcquireFrame("Frame");
	s:SetParent(parent); s:SetFrameLevel(parent:GetFrameLevel() + 2);

	-- If desired, create the cooldown graphic.
	if showGraphic then
		s.cd = VFLUI.AcquireFrame("Cooldown");
		s.cd:SetParent(parent); s.cd:SetFrameLevel(parent:GetFrameLevel() + 1);
		s.cd:SetReverse(reverse);
		s.cd:SetAllPoints(s); s.cd:Hide();
	end
	
	-- Create a FontString subcontrol for number display.
	s.fs = VFLUI.CreateFontString(s);
	s.fs:SetPoint("CENTER", s, "CENTER", fsoffsetx, fsoffsety);
	s.fs:SetWidth(parent:GetWidth() + 50); s.fs:SetHeight(parent:GetHeight() + 50);
	s.fs:Show();
	if not dontSetFont then
		VFLUI.SetFont(s.fs, Fonts.Default, 8);
	end

	function s:SetCooldown(start, duration)
		if start == 0 then
			self.expiration = 0;
			if self.cd then self.cd:Hide(); end
			return;
		end
		self.expiration = start + duration;
		if self.cd then self.cd:Show(); self.cd:SetCooldown(start, duration); end
	end

	if showText then
		if (not TextType) then 
			s.transform = VFL.Time.FormatMinSec;
		else 
			s.transform = RDXUI.GetTextTimerTypesFunction(TextType);
		end
		
		s.expiration = 0;
		local lastUpdate = 0;
		local t, u;
		s:SetScript("OnUpdate", function(self)
			-- Throttle
			t = GetTime();	if (t - lastUpdate) < updateSpeed then return; end
			lastUpdate = t;
			-- Update
			u = self.expiration - t;
			if u > 0 and u > hideTextSec then
				self.fs:SetText(self.transform(u));
			else
				self.fs:SetText("");
			end
		end);
	end

	s.Destroy = VFL.hook(function(self)
		if self.cd then self.cd:Destroy(); self.cd = nil; end
		self.SetCooldown = nil;
		self.transform = nil; self.expiration = nil;
		self.fs:Destroy(); self.fs = nil;
	end, s.Destroy);

	return s;
end

-----------------------------------------------------------
-- cache element
-----------------------------------------------------------

local function ElementCachePopup(db, callback, frame, point, dx, dy)
	local qq = {};
	for _,v in pairs(db) do
		local dbEntry = v;
		table.insert(qq, {
			text = v;
			OnClick = function()
				VFL.poptree:Release();
				callback(dbEntry);
			end
		});
	end
	table.sort(qq, function(x1,x2) return tostring(x1.text) < tostring(x2.text); end);
	table.insert(qq, { text = i18n("Element not listed...") });
	VFL.poptree:Begin(200, 12, frame, point, dx, dy);
	VFL.poptree:Expand(nil, qq, 20);
end

function RDXUI.CreateElementEdit(parent, text, db)
	local ui = VFLUI.LabeledEdit:new(parent, 200);
	ui:SetText(text); ui:Show();
	
	local btn = VFLUI.Button:new(ui);
	btn:SetHeight(25); btn:SetWidth(25); btn:SetText("...");
	btn:SetPoint("RIGHT", ui.editBox, "LEFT"); btn:Show();
	btn:SetScript("OnClick", function()
		ElementCachePopup(db, function(x) 
			if x then ui.editBox:SetText(x); end
		end, btn, "CENTER");
	end);
	
	ui.Destroy = VFL.hook(function(s)
			btn:Destroy(); btn = nil;
	end, ui.Destroy);
	
	return ui;
end
