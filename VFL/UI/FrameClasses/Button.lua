-- Button.lua
-- VFL
-- (C)2006 Bill Johnson
--
-- Button templates for the dynamic frame engine.

--- Create a standard VFL-themed button.
VFLUI.Button = {};
function VFLUI.Button:new(parent)
	local btn = VFLUI.AcquireFrame("Button");

	if parent then
		btn:SetParent(parent);
		btn:SetFrameStrata(parent:GetFrameStrata());
		btn:SetFrameLevel(parent:GetFrameLevel() + 1);
	end
	
	-- Background
	btn:SetBackdrop(VFLUI.DefaultDialogBorder);

	-- Textures
	local tex = VFLUI.CreateTexture(btn);
	tex:SetDrawLayer("BACKGROUND");
	tex:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4);
	tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4);
	tex:SetTexture(1, 1, 1, 0.1);
	tex:Show();
	btn.texBkg = tex;

	-- Normal Texture is owned by the button
	tex = btn:CreateTexture();
	tex:SetTexture(1, 1, 1, 0);
	tex:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4);
	tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4);
	tex:Show();
	btn:SetNormalTexture(tex);

	-- Disabled Texture is owned by the button
	tex = btn:CreateTexture();
	tex:SetTexture(0.5, 0.5, 0.5, 1);	
	tex:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4);
	tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4);
	tex:Show();
	btn:SetDisabledTexture(tex);

	-- Highlight Texture IS NOT OWNED by the button
	tex = VFLUI.CreateTexture(btn);
	tex:SetTexture(1, 1, 1, 0.2);
	tex:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4);
	tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4);
	tex:Show();
	btn:SetHighlightTexture(tex);
	btn.texHlt = tex;

	-- Pushed Texture is owned by the button
	tex = btn:CreateTexture();
	tex:SetTexture(1, 1, 1, 0.4);
	tex:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4);
	tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4);
	tex:Show();
	btn:SetPushedTexture(tex);

	-- Fonts
	btn:SetNormalFontObject(Fonts.Default);
	btn:SetDisabledFontObject(Fonts.Default); 
	btn:SetHighlightFontObject(Fonts.Default);
	--btn:SetTextColor(1,1,1);

	btn.Destroy = VFL.hook(function(s)
		VFLUI.ReleaseRegion(s.texBkg); s.texBkg = nil;
		VFLUI.ReleaseRegion(s.texHlt); s.texHlt = nil;
	end, btn.Destroy);

	return btn;
end

--- "Cancel" button with red text
VFLUI.CancelButton = {};
function VFLUI.CancelButton:new(parent)
	local btn = VFLUI.Button:new(parent);
	--btn:SetHighlightTextColor(1,0,0);
	return btn;
end

--- "OK" button
VFLUI.OKButton = {};
function VFLUI.OKButton:new(parent)
	local btn = VFLUI.Button:new(parent);
	--btn:SetHighlightTextColor(0,1,0);
	return btn;
end

--- Single-texture square-shaped highlightable button.
VFLUI.TexturedButton = {};
function VFLUI.TexturedButton:new(parent, dim, texture)
	local self = VFLUI.AcquireFrame("Button");
	-- Inheritance
	if parent then
		self:SetParent(parent);
		self:SetFrameStrata(parent:GetFrameStrata());
		self:SetFrameLevel(parent:GetFrameLevel() + 1);
	end
	if not dim then dim=16; end
	self:SetWidth(dim); self:SetHeight(dim);
	-- Textures
	self:SetNormalTexture(texture);
	local hltTex = VFLUI.CreateTexture(self);
	hltTex:SetAllPoints(self); hltTex:Show();
	self:SetHighlightTexture(hltTex);
	hltTex:SetBlendMode("DISABLE");
	hltTex:SetTexture(texture);

	function self:SetHighlightColor(r,g,b,a)
		hltTex:SetVertexColor(r,g,b,a);
	end
	
	self.Destroy = VFL.hook(function(s)
		VFLUI.ReleaseRegion(hltTex); hltTex = nil;
		s.SetHighlightColor = nil;
	end, self.Destroy);
	return self;
end

--- "X"-shaped Close button
VFLUI.CloseButton = {};
function VFLUI.CloseButton:new(parent, dim)
	local ret = VFLUI.TexturedButton:new(parent, dim, "Interface\\Addons\\VFL\\Skin\\x");
	ret:SetHighlightColor(1,0,0,1);
	return ret;
end

--- VFL-themed checkbox with paired text control
VFLUI.Checkbox = {};
function VFLUI.Checkbox:new(parent)
	local self = VFLUI.AcquireFrame("Frame");

	if parent then
		self:SetParent(parent);
		self:SetFrameStrata(parent:GetFrameStrata());
		self:SetFrameLevel(parent:GetFrameLevel() + 1);
	end
	
	local chk = VFLUI.AcquireFrame("CheckButton");
	chk:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up");
	chk:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
	chk:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight");
	chk:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
--	chk:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
--	chk:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");

	chk:SetParent(self); chk:SetFrameStrata(self:GetFrameStrata()); chk:SetFrameLevel(self:GetFrameLevel() + 1);
	chk:SetPoint("LEFT", self, "LEFT", 2, -1);
	chk:SetHeight(19); chk:SetWidth(19); chk:Show();

	self.check = chk; 
	
	self:SetHeight(16); self:SetWidth(0);

	local txt = VFLUI.CreateFontString(self);
	txt:SetPoint("LEFT", chk, "RIGHT"); txt:SetHeight(16);
	txt:SetJustifyH("LEFT");
	VFLUI.SetFont(txt, Fonts.Default, 10);
	self.text = txt;

	self.SetText = function(self, t) self.text:SetText(t); end;
	self.GetChecked = function(self) return self.check:GetChecked(); end;
	self.SetChecked = function(self, x) self.check:SetChecked(x); end;

	local function layout()
		local w = self:GetWidth();
		if(w < 25) then self.text:SetWidth(0); self.text:Hide(); else self.text:SetWidth(w - 19); self.text:Show(); end
	end
	self:SetScript("OnShow", layout);
	self:SetScript("OnSizeChanged", layout);
	self.DialogOnLayout = layout;

	self.Destroy = VFL.hook(function(s)
		s.check:Destroy(); s.check = nil;
		VFLUI.ReleaseRegion(s.text); s.text = nil; 
		s.SetText = nil; s.GetChecked = nil; s.SetChecked = nil;
	end, self.Destroy);

	return self;
end

-- VFL-themed Radio Button with text control
VFLUI.RadioButton = {};
function VFLUI.RadioButton:new(parent)
	-- Containing frame
	local self = VFLUI.AcquireFrame("Frame");
	if parent then
		self:SetParent(parent);
		self:SetFrameStrata(parent:GetFrameStrata());
		self:SetFrameLevel(parent:GetFrameLevel() + 1);
	end
	self:SetHeight(16); self:SetWidth(16);
	
	-- The radio button
	local chk = VFLUI.AcquireFrame("CheckButton");
	
	local tex = chk:CreateTexture();
	if not tex:SetTexture("Interface\\Buttons\\UI-RadioButton") then error("texture"); end
	tex:SetAllPoints();
	tex:SetTexCoord(0, 0.25, 0, 1); tex:Show();
	chk:SetNormalTexture(tex);
	
	local htex = chk:CreateTexture();
	if not htex:SetTexture("Interface\\Buttons\\UI-RadioButton") then error("texture"); end
	htex:SetAllPoints();
	htex:SetTexCoord(0.5, 0.75, 0, 1);
	htex:SetBlendMode("ADD"); htex:Show();
	chk:SetHighlightTexture(htex);

	tex = chk:CreateTexture();
	if not tex:SetTexture("Interface\\Buttons\\UI-RadioButton") then error("texture"); end
	tex:SetAllPoints();
	tex:SetTexCoord(0.25, 0.49, 0, 1); tex:Show();
	chk:SetCheckedTexture(tex);

	chk:SetParent(self); chk:SetFrameStrata(self:GetFrameStrata()); chk:SetFrameLevel(self:GetFrameLevel() + 1);
	chk:SetPoint("LEFT", self, "LEFT", 3, 0);
	chk:SetHeight(16); chk:SetWidth(16); chk:Show();

	self.button = chk;

	-- The text box
	local txt = VFLUI.CreateFontString(self);
	txt:SetPoint("LEFT", chk, "RIGHT"); txt:SetHeight(16);
	txt:SetJustifyH("LEFT"); txt:Show();
	txt:SetFontObject(VFLUI.GetFont(Fonts.Default, 10));

	self.SetText = function(s, t) txt:SetText(t); end;
	self.GetChecked = function(s) return chk:GetChecked(); end;
	self.SetChecked = function(s, ch) 
--		VFLUI:Debug(7, "RadioButton(" .. tostring(s) .."):SetChecked(" .. tostring(ch) .. ")");
		chk:SetChecked(ch); 
	end

	self:SetScript("OnSizeChanged", function()
		local w = this:GetWidth();
--		VFLUI:Debug(7, "RadioButton:OnSizeChanged " .. w);
		if(w < 25) then txt:SetWidth(0); txt:Hide(); else txt:SetWidth(w - 19); txt:Show(); end
	end);

	self.Destroy = VFL.hook(function(s)
		chk:Destroy(); chk = nil; self.button = nil;
		VFLUI.ReleaseRegion(txt); txt = nil;
		htex = nil;
		s.SetText = nil; s.GetChecked = nil; s.SetChecked = nil;
	end, self.Destroy);

	return self;
end

--- @class VFLUI.CheckGroup
-- A check group is a numerically indexed array of checkboxes arranged in a grid.
VFLUI.CheckGroup = {};
function VFLUI.CheckGroup:new(parent)
	local self = VFLUI.Grid:new(parent);
	self:Show();

	self.checkBox = {};
	self.SetLayout = function(s, nChecks, nCols)
		-- Size the thing
		local nRows = math.ceil(nChecks / nCols);
		s:Size(nCols, nRows, function(grid)
			local cb = VFLUI.Checkbox:new(grid);
			cb.OnDeparent = cb.Destroy;
			return cb;
		end);
		-- Populate the checkboxes array
		s.checkBox = {};
		local n = 0;
		for cell in s:Iterator() do
			n = n + 1;
			if(n > nChecks) then cell:Hide() else
				cell:Show(); s.checkBox[n] = cell;
			end
		end
		-- Trip upward layout since we changed heights.
		VFLUI.UpdateDialogLayout(s);
	end

	self.DialogOnLayout = VFL.Noop;

	self.Destroy = VFL.hook(function(s)
		VFLUI:Debug(5, "CheckGroup(" .. tostring(s) .. "):Destroy()");
		s.checkBox = nil; s.SetLayout = nil;
		s.DialogOnLayout = nil;
	end, self.Destroy);

	return self;
end

--- @class VFLUI.RadioGroup
-- A radio group is a grid of mutually exclusive radio buttons.
VFLUI.RadioGroup = {};
function VFLUI.RadioGroup:new(parent)
	local self = VFLUI.Grid:new(parent);
	self:Show();

	self.buttons = {};
	self.value = nil;
	self.SetLayout = function(s, nChecks, nCols)
		-- Size the thing
		local nRows = math.ceil(nChecks / nCols);
		s:Size(nCols, nRows, function(grid)
			local cb = VFLUI.RadioButton:new(grid);
			cb.OnDeparent = cb.Destroy;
			return cb;
		end);
		-- Populate the checkboxes array
		s.buttons = {};
		local n = 0;
		for cell in s:Iterator() do
			n = n + 1;
			if(n > nChecks) then cell:Hide() else
				cell:Show(); s.buttons[n] = cell;
				local qq = n;
				cell.button:SetScript("OnClick", function() s:SetValue(qq); end);
			end
		end
		-- Relayout the dialog.
		VFLUI.UpdateDialogLayout(s);
	end

	self.SetValue = function(s, v)
		s.value = v;
		local n = 0;
		for cell in s:Iterator() do
			n=n+1;
			if(n == v) then cell:SetChecked(true); else cell:SetChecked(nil); end
		end
	end
	self.GetValue = function(s) return s.value; end

	self.DialogOnLayout = VFL.Noop;

	self.Destroy = VFL.hook(function(s)
		VFLUI:Debug(5, "RadioGroup(" .. tostring(s) .. "):Destroy()");
		s.buttons = nil; s.SetLayout = nil;
		s.SetValue = nil; s.GetValue = nil; s.value = nil;
		s.DialogOnLayout = nil;
	end, self.Destroy);

	return self;
end
