-- MainPanel.lua
-- OpenRDX
-- New Main Panel

-- mainbuttondb : first line of button
-- buttondb : second line of button
local mainbuttondb, buttondb = {}, {};
local sortedmb, sortedb = {}, {};

--------------------------------------
-- Main Menu Pane
--------------------------------------

local mainPane = nil;

local function CreateMainPane()
	-- main panel
	local s = VFLUI.AcquireFrame("Frame");
	s:SetParent(UIParent); s:Hide();
	s:SetPoint("CENTER", UIParent, "CENTER");
	s:SetMovable(true);
	s:SetHeight(70); s:SetWidth(240);
	--s:SetBackdrop(VFLUI.BorderlessDialogBackdrop);
	
	-- Divider
	local tx1 = VFLUI.CreateTexture(s);
	tx1:SetDrawLayer("ARTWORK");
	tx1:SetTexture("Interface\\TradeSkillFrame\\UI-TradeSkill-SkillBorder");
	tx1:SetTexCoord(0.1, 0.5, 0, 0.25);
	tx1:SetPoint("TOPLEFT", s, "TOPLEFT", 0, -37);
	tx1:SetHeight(9); tx1:SetWidth(240);
	tx1:Show();
	
	-- Divider
	local tx2 = VFLUI.CreateTexture(s);
	tx2:SetDrawLayer("ARTWORK");
	tx2:SetTexture("Interface\\TradeSkillFrame\\UI-TradeSkill-SkillBorder");
	tx2:SetTexCoord(0.1, 0.5, 0, 0.25);
	tx2:SetPoint("BOTTOMLEFT", s, "BOTTOMLEFT", 0, 20);
	tx2:SetHeight(8); tx2:SetWidth(240);
	tx2:Show();

	-- Top
	-- Button use to drag the main panel
	local tBtn = VFLUI.AcquireFrame("Button");
	tBtn:SetParent(s); 
	tBtn:SetPoint("TOPLEFT", s, "TOPLEFT");
	tBtn:SetHeight(20); tBtn:SetWidth(240);
	tBtn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	tBtn:Show();
	
	-- Click handlers for the button
	tBtn:SetScript("OnMouseDown", function()
		s:StartMoving();
	end);
	tBtn:SetScript("OnMouseUp", function()
		s:StopMovingOrSizing();
		
		-- Save the new position of the main panel in RDXG
		local l,t,r,b = GetUniversalBoundary(s);
		RDXG.MainPanel["l"] = l;
		RDXG.MainPanel["t"] = t;
		RDXG.MainPanel["r"] = r;
		RDXG.MainPanel["b"] = b;
	end);
	
	-- first line button
	local line1 = VFLUI.AcquireFrame("Frame");
	line1:SetParent(s);
	line1:SetPoint("TOPLEFT", s, "TOPLEFT", 0, -6);
	line1:SetHeight(33); line1:SetWidth(240);
	--line1:SetBackdrop(VFLUI.BorderlessDialogBackdrop);
	
	-- second line button
	local line2 = VFLUI.AcquireFrame("Frame");
	line2:SetParent(s);
	line2:SetPoint("TOPLEFT", s, "TOPLEFT", 0, -46);
	line2:SetHeight(33); line2:SetWidth(240);
	--line2:SetBackdrop(VFLUI.BorderlessDialogBackdrop);
	
	-- Button Toolbar
	local lastBtn, tmpbtns, mbtns, btns, sl = nil, nil, {}, {}, nil;
	
	-- function main panel layout
	function s:Layout()
		-- restore the position of the main panel from RDXG
		local l = RDXG.MainPanel["l"];
		if l then SetAnchorFramebyPosition(s, "TOPLEFT", RDXG.MainPanel["l"], RDXG.MainPanel["t"], RDXG.MainPanel["r"], RDXG.MainPanel["b"]); end
		
		-- line 1 is main line
		-- line 2 is sub line
		-- if the second line is activated, modify height of the main panel and call ShowSubButtons
		local sl = RDXG.MainPanel["sl"];
		if sl then
			s:SetHeight(107); s:SetWidth(240);
			self:ShowSubButtons();
		else
			s:SetHeight(66); s:SetWidth(240);
			self:HideSubButtons();
		end
	end
	--[[
	VFL.AdaptiveSchedule(self2, 0.021, function(_,elapsed)
			local offset = onupdate(self2, elapsed, v, t, maxw, true);
			if color1 then self2:SetVertexColor(CVFromCTLerp(color1, color2, offset)); end
		    end);
		    linearInterpolation(self._value, v, 1/t*self._totalElapsed);
	--]]
	local idState = {};
	
	-- Function to layout buttons
	function s:buttonsLayout(line, id, state)
		lastBtn = nil; 
		if line == "main" then
			tmpbtns = mbtns;
		else
			tmpbtns = btns;
		end
		for k,v in pairs(tmpbtns) do
			local grow = nil;
						
			if state == "mousein" then
				grow = true;
			end
			
			local h = v:GetHeight();
			local w = v:GetWidth();
			if h == 0 then h = 16; v:SetHeight(h); end
			if w == 0 then w = 16; v:SetWidth(w); end
			
			if id == k  and state then
				VFL.AdaptiveUnschedule(v);
				local totalElapsed = 0;
				local toSize = 16;
				VFL.AdaptiveSchedule(v, 0.021, function(_,elapsed)
					totalElapsed = totalElapsed + elapsed;
					if totalElapsed > .5 then
						VFL.AdaptiveUnschedule(v);
						totalElapsed = 0;
					else
						if grow then
							toSize = 32;
						else
							toSize = 16;
						end
						v:SetHeight(lerp1(1/.1*totalElapsed, h, toSize));
						v:SetWidth(lerp1(1/.1*totalElapsed, w, toSize));
					end
				end);
			end
			
			-- anchor
			if lastBtn then
				if line == "main" then
					v:SetPoint("BOTTOMLEFT", lastBtn, "BOTTOMRIGHT", 2, 0);
				else
					v:SetPoint("LEFT", lastBtn, "RIGHT", 2, 0);
				end
			else
				if line == "main" then
					v:SetPoint("BOTTOMLEFT", line1, "BOTTOMLEFT", 2, 0);
				else
					v:SetPoint("LEFT", line2, "LEFT", 2, -1);
				end
				
			end
			
			-- texture toggle
			if v._btype == "default" then
				if RDXG.MainPanel["sl"] == v._name then 
					v:SetNormalTexture(v._toggletexture);
				else
					v:SetNormalTexture(v._texture);
				end
			elseif v._btype == "toggle" then
				if v._ftoggle and v._ftoggle() then 
					v:SetNormalTexture(v._toggletexture);
				else
					v:SetNormalTexture(v._texture);
				end
			end
			lastBtn = v;
		end
	end
	
	function s:ButtonsLayoutAll()
		self:buttonsLayout("main");
		self:buttonsLayout("sub");
	end
	
	-- main buttons
	
	function s:HideMainButtons()
		for k,v in pairs(mbtns) do
			mbtns[k]:Destroy(); mbtns[k] = nil;
		end
	end
	
	function s:ShowMainButtons()
		self:HideMainButtons();
		local bnttmp;
		for k,v in pairs(sortedmb) do
			bnttmp = VFLUI.AcquireFrame("Button");
			bnttmp:SetParent(s);
			bnttmp:SetFrameLevel(5);
			bnttmp:SetNormalTexture(v.texture);
			bnttmp._name = v.name;
			bnttmp._btype = v.btype;
			bnttmp._texture = v.texture;
			bnttmp._toggletexture = v.toggletexture;
			bnttmp._ftoggle = v.IsToggle;
			if v.btype == "default" then
				-- default : show second line
				bnttmp:SetScript("OnClick", function()
					if (RDXG.MainPanel["sl"] == v.name) then 
						RDXG.MainPanel["sl"] = nil;
						self:Layout();
						self:buttonsLayout("main", k);
					else
						RDXG.MainPanel["sl"] = v.name;
						self:Layout();
						self:buttonsLayout("main", k);
					end
				end);
			elseif (v.btype == "toggle") then
				-- toggle : toggle button, change texture			
				bnttmp:SetScript("OnClick", function()
					v.OnClick();
					self:buttonsLayout("main", k);
				end);
			elseif (v.btype == "drag") then
				-- drag : toggle button, change texture			
				-- to do
			else
				-- custom do the v.OnClick function only
				bnttmp:SetScript("OnClick", function() v.OnClick(); end);
			end
			
			bnttmp:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self, "ANCHOR_NONE");
				GameTooltip:SetPoint("BOTTOMLEFT", mbtns[k], "TOPRIGHT");
				GameTooltip:ClearLines();
				GameTooltip:AddLine(v.title, 1, 1, 1, 1, true);
				GameTooltip:AddLine(v.desc);
				GameTooltip:Show();
				self:buttonsLayout("main", k, "mousein");
			end);
			bnttmp:SetScript("OnLeave", function()
				GameTooltip:Hide();
				self:buttonsLayout("main", k, "mouseout");
			end);
			bnttmp:Show();
			-- store the buttons
			mbtns[k] = bnttmp;
		end
		self:buttonsLayout("main");
	end
	
	----------------------- sub buttons
	
	function s:HideSubButtons()
		for k,v in pairs(btns) do
			btns[k]:Destroy(); btns[k] = nil;
		end
	end
	
	function s:ShowSubButtons()
		self:HideSubButtons();
		local bnttmp, textmp;
		for k,v in pairs(sortedb) do
			if RDXG.MainPanel["sl"] and (RDXG.MainPanel["sl"] == v.parent) then
				bnttmp = VFLUI.AcquireFrame("Button");
				bnttmp:SetParent(s);
				bnttmp:SetFrameLevel(5);
				bnttmp:SetNormalTexture(v.texture);
				bnttmp._name = v.name;
				bnttmp._btype = v.btype;
				bnttmp._texture = v.texture;
				bnttmp._toggletexture = v.toggletexture;
				bnttmp._ftoggle = v.IsToggle;
				if (v.btype == "toggle") then
					-- toggle : toggle button, change texture			
					bnttmp:SetScript("OnClick", function()
						v.OnClick();
						self:buttonsLayout("sub", k);
					end);
				elseif (v.btype == "drag") then
					-- drag : toggle button, change texture			
					-- to do
				else
					-- custom do the v.OnClick function only
					bnttmp:SetScript("OnClick", function() v.OnClick(); end);
				end
				
				bnttmp:SetScript("OnEnter", function()
					GameTooltip:SetOwner(self, "ANCHOR_NONE");
					GameTooltip:SetPoint("BOTTOMLEFT", btns[k], "TOPRIGHT");
					GameTooltip:ClearLines();
					GameTooltip:AddLine(v.title, 1, 1, 1, 1, true);
					GameTooltip:AddLine(v.desc);
					GameTooltip:Show();
					self:buttonsLayout("sub", k, "mousein");
				end);
				bnttmp:SetScript("OnLeave", function()
					GameTooltip:Hide();
					self:buttonsLayout("sub", k, "mouseout");
				end);
				bnttmp:Show();
				-- store the buttons
				btns[k] = bnttmp;
			end
		end
		self:buttonsLayout("sub");
	end
	
	------------- desktop
	local path = nil;
	
	local line3 = VFLUI.AcquireFrame("Button");
	line3:SetParent(s);
	line3:SetPoint("BOTTOMLEFT", s, "BOTTOMLEFT", 0 , 0);
	line3:SetHeight(23); line3:SetWidth(240);
	--line3:SetBackdrop(VFLUI.BorderlessDialogBackdrop);
	line3:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	line3:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	line3:SetScript("OnClick", function()
		if(arg1 == "LeftButton") then
			local md = RDXDB.GetObjectData(path);
			if md then RDXDK.EditDesktop(UIParent, path, md); end
		elseif(arg1 == "RightButton") then
			VFL.poptree:Begin(300, 14, UIParent, "TOPLEFT", GetRelativeLocalMousePosition(UIParent));
			VFL.poptree:Expand(nil, RDXDK.BuildQuickDesktopMenu());
		end
	end);
	line3:SetNormalFontObject(Fonts.DefaultShadowed);
	
	function s:SetDesktopName(desktxt, newpath)
		line3:SetText(desktxt);
		path = newpath;
	end
	
	s.Destroy = VFL.hook(function(s2)
		VFLUI.ReleaseRegion(tx1); tx1 = nil;
		VFLUI.ReleaseRegion(tx2); tx2 = nil;
		tBtn:Destroy(); tBtn = nil;
		s:HideMainButtons(); s.HideMainButtons = nil; s.ShowMainButtons = nil;
		s:HideSubButtons(); s.HideSubButtons = nil; s.ShowSubButtons = nil;
		s.Layout = nil; s.buttonsLayout = nil; tmpbtns = nil; mntns = nil; btns = nil; lastBtn = nil;
		line1:Destroy(); line1 = nil;
		line2:Destroy(); line2 = nil;
		line3:Destroy(); line3 = nil;
		VFLUI.ReleaseRegion(tTxtLeft); tTxtLeft = nil;
		VFLUI.ReleaseRegion(tTxtRight); tTxtRight = nil;
		s.SetDesktopName = nil;
	end, s.Destroy);

	return s;
end

------------------------
-- "MINIMIZED" RDX ICON
------------------------
local miniPane = nil;

local function CreateMiniPane()
	local mini = VFLUI.AcquireFrame("Button");
	mini:SetParent(UIParent); 
	mini:SetScale(Minimap:GetEffectiveScale() / UIParent:GetEffectiveScale());
	mini:SetMovable(true);
	mini:SetPoint("CENTER", UIParent, "CENTER");
	mini:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");
	mini:SetHeight(32); mini:SetWidth(32);
	mini:Hide();
	
	local tx1 = VFLUI.CreateTexture(mini);
	tx1:SetPoint("TOPLEFT", mini, "TOPLEFT"); tx1:SetWidth(56); tx1:SetHeight(56);
	tx1:SetDrawLayer("OVERLAY");
	tx1:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder"); tx1:Show();
	
	local tx2 = VFLUI.CreateTexture(mini);
	tx2:SetPoint("CENTER", mini, "CENTER"); tx2:SetHeight(24); tx2:SetWidth(24);
	tx2:SetDrawLayer("BACKGROUND");
	tx2:SetTexture("Interface\\Addons\\RDX\\Skin\\mmbtn"); tx2:Show();
	
	local mmvg = nil;
	local shiftRight = nil;
	mini:SetScript("OnMouseDown", function()
		if (arg1 == "LeftButton" and IsShiftKeyDown()) then
			mmvg = true;
			mini:StartMoving();
			return;
		elseif (arg1 == "RightButton" and IsShiftKeyDown()) then
			RDXDK.ToggleDesktopLock();
			shiftRight = true;
		end
	end);
	
	-- function main panel layout
	function mini:Layout()
		-- restore the position of the main panel from RDXG
		local l = RDXG.MainPanel["lm"];
		if l then SetAnchorFramebyPosition(mini, "TOPLEFT", RDXG.MainPanel["lm"], RDXG.MainPanel["tm"], RDXG.MainPanel["rm"], RDXG.MainPanel["bm"]); end
	end
	
	mini:SetScript("OnMouseUp", function()
		if mmvg then
			mmvg = nil;
			mini:StopMovingOrSizing();
			local l,t,r,b = GetUniversalBoundary(mini);
			RDXG.MainPanel["lm"] = l;
			RDXG.MainPanel["tm"] = t;
			RDXG.MainPanel["rm"] = r;
			RDXG.MainPanel["bm"] = b;
			return;
		end
		if(arg1 == "LeftButton") then 
			RDXPM.Maximize(); return; 
		elseif(arg1 == "RightButton") then
		if not shiftRight then
		    --RDX.ShowMainMenu(); return;
		else
		    shiftRight = nil;
		end
		end
	end);
	
	return mini;
end

function RDXPM.Minimize()
	if RDXG.MainPanel["mini"] then return; end
	RDXG.MainPanel["mini"] = true;
	mainPane:Hide(); miniPane:Show();
end
function RDXPM.Maximize()
	if not RDXG.MainPanel["mini"] then return; end
	RDXG.MainPanel["mini"] = nil;
	mainPane:Show(); miniPane:Hide();
end
local function restoreMiniState()
	if RDXG.MainPanel["mini"] then mainPane:Hide(); miniPane:Show(); else mainPane:Show(); miniPane:Hide(); end
end

-------------------------------------------------
-- Global API add buttons
-------------------------------------------------

-- Register a new main button
--[[
name must be unique and it is the relation with sub buttons
id is used to sort main buttons
btype : default, toggle, function, drag.
  default will show subline buttons, only available with main buttons
  toggle will toggle a button with two textures base on IsToggle and use Onclick function
  custom will just call OnClick function.
toggletexture is available for mbtype default and toggle
RDXPM.RegisterMainButton({
	name = "Desktop";
	id = 1;
	btype = "default";
	title = i18n("title in GameTooltip : Desktop Manager");
	desc = "Text GameTooltip : Change and modify all the desktops";
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\lock";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\unlock";
	IsToggle = VFL.Noop;
	OnClick = VFL.Noop;
})
]]

function RDXPM.RegisterMainButton(tbl)
	if (not tbl) or (type(tbl) ~= "table") then VFL.print(i18n("|cFFFF0000[RDXPM]|r Error : Invalide registration Main Button ")); return; end
	if type(tbl.id) ~= "number" then VFL.print(i18n("|cFFFF0000[RDXPM]|r Error : bad or missing id number")); return; end
	local name = tbl.name;
	if mainbuttondb[name] then VFL.print(i18n("|cFFFF0000[RDXPM]|r Error : Duplicate registration Main Button ") .. name); return; end
	mainbuttondb[name] = tbl;
	table.insert(sortedmb, tbl);
	table.sort(sortedmb, function(x1,x2) return x1.id < x2.id; end);
	-- if the panel is already created, reload buttons
	--if mainPane then
	--	mainPane:ShowMainButtons();
	--end
end

--- Register a new button
--[[
example : id must be unique and indicate the order of buttons
RDXPM.RegisterButton({
	name = "autoswitch_desktop";
	parent = "desktop";
	id = 1;
	btype = "function";
	title = i18n("title in GameTooltip");
	desc = "button do this GameTooltip";
	texture = "Interface\\Addons\\RDX\\Skin\\boomy\\lock";
	toggletexture = "Interface\\Addons\\RDX\\Skin\\boomy\\refresh";
	IsToggle = RDXDK.IsAutoSwitchEnable;
	OnClick = VFL.Noop;
	OnDrag = VFL.Noop;
})
]]

function RDXPM.RegisterButton(tbl)
	if (not tbl) or (type(tbl) ~= "table") then VFL.print(i18n("|cFFFF0000[RDXPM]|r Error : Invalide registration Button ")); return; end
	if type(tbl.id) ~= "number" then VFL.print(i18n("|cFFFF0000[RDXPM]|r Error : bad or missing id number")); return; end
	local name = tbl.name;
	if buttondb[name] then VFL.print(i18n("|cFFFF0000[RDXPM]|r Error : Duplicate registration Button ") .. name); return; end
	buttondb[name] = tbl;
	table.insert(sortedb, tbl);
	table.sort(sortedb, function(x1,x2) return x1.id < x2.id; end);
	-- if the panel is already created, reload buttons
	--if mainPane then
	--	mainPane:ShowSubButtons();
	--end
end

----------------------------------------------
-- INIT
-- Create the menu pane and show all buttons
----------------------------------------------

RDXEvents:Bind("INIT_DESKTOP", nil, function()
	-- Main Panel
	mainPane = CreateMainPane();
	mainPane:ShowMainButtons();
	mainPane:Layout();
	
	-- Mini Panel
	miniPane = CreateMiniPane();
	miniPane:Layout();
	
	restoreMiniState();
end);

function RDXPM.GetMainPane() return mainPane; end
function RDXPM.GetMiniPane() return miniPane; end

-- relayout the buttons
function RDXPM.LayoutAllButtons()
	mainPane:ButtonsLayoutAll();
end
