-- Framing.lua
-- RDX
-- (C)2006 Bill Johnson
--
-- THIS FILE CONTAINS COPYRIGHTED MATERIAL SUBJECT TO THE TERMS OF A SEPARATE
-- LICENSE. UNLICENSED COPYING IS PROHIBITED.
-- 
-- Features to alter the framing and appearance of RDX windows.

--- Helper function to generate a title UI.
function RDXUI.GenerateFrameTitleUI(feature, desc, parent)
	local ui = VFLUI.LabeledEdit:new(parent, 100);
	ui:SetText(i18n("Window title"));
	ui:Show();
	if desc and desc.title then ui.editBox:SetText(desc.title); end
	function ui:GetDescriptor()
		return { feature = feature, title = ui.editBox:GetText() };
	end
	ui.Destroy = VFL.hook(function(s)
		s.GetDescriptor = nil;
	end, ui.Destroy);
	return ui;
end

------------------------------------
-- No frame whatsoever
------------------------------------
RDX.RegisterFeature({
	name = "Frame: None";
	category = i18n("Window Frames");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if state:Slot("Frame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		state:AddSlot("Frame");
		state:AddSlot("SetTitleText");
		return true;
	end;
	ApplyFeature = VFL.Noop;
	UIFromDescriptor = VFL.Nil,
	CreateDescriptor = function() return {feature = "Frame: None"}; end
});

------------------------------------
-- The VFL default frame
------------------------------------
RDX.RegisterFeature({
	name = "Frame: Default",
	category = i18n("Window Frames");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Create") then return nil; end
		if state:Slot("Frame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		if not desc then return nil; end
		state:AddSlot("Frame");
		state:AddSlot("SetTitleText");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local win, title = nil, (desc.title or i18n("(No Title)"));
		
		state:_Attach(state:Slot("Create"), true, function(w)
			win = w;
			w:SetFraming(VFLUI.Framing.Default, 18);
			w:SetText(title); w:SetTitleColor(0,0,0.6);
		end);

		state:_Attach(state:Slot("SetTitleText"), nil, function(txt)
			win:SetText(title .. txt);
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		return RDXUI.GenerateFrameTitleUI(i18n("Frame: Default"), desc, parent);
	end,
	CreateDescriptor = function() return {feature = "Frame: Default"}; end
});

----------------------------------
-- A "lightweight" frame
----------------------------------
RDX.RegisterFeature({
	name = "Frame: Lightweight",
	category = i18n("Window Frames");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Create") then return nil; end
		if state:Slot("Frame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		if not desc then return nil; end
		state:AddSlot("Frame");
		state:AddSlot("SetTitleText");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local win, title = nil, (desc.title or i18n("(No title)"));
		local titleColor = desc.titleColor or _black;
		local bkdColor = desc.bkdColor or _alphaBlack;
		
		state:_Attach(state:Slot("Create"), true, function(w)
			win = w;
			w:SetFraming(VFLUI.Framing.Sleek);
			win:SetText(title);
			win:SetTitleColor(explodeColor(titleColor));
			win:SetBackdropColor(explodeRGBA(bkdColor));
		end);

		state:_Attach(state:Slot("SetTitleText"), nil, function(txt)
			win:SetText(title .. txt);
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local title = VFLUI.LabeledEdit:new(ui, 100); title:Show();
		title:SetText(i18n("Window Title"));
		if desc and desc.title then title.editBox:SetText(desc.title); end
		ui:InsertFrame(title);

		local titleColor = RDXUI.GenerateColorSwatch(ui, i18n("Title color"));
		if desc and desc.titleColor then titleColor:SetColor(explodeRGBA(desc.titleColor)); end

		local bkdColor = RDXUI.GenerateColorSwatch(ui, i18n("Background color"));
		if desc and desc.bkdColor then bkdColor:SetColor(explodeRGBA(desc.bkdColor)); end

		function ui:GetDescriptor()
			return {
				feature = "Frame: Lightweight"; 
				title = title.editBox:GetText();
				titleColor = titleColor:GetColor();
				bkdColor = bkdColor:GetColor();
			};
		end

		return ui;
	end,
	CreateDescriptor = function() 
		return {
			feature = "Frame: Lightweight";
			titleColor = { r=0,g=0,b=0,a=1 };
			bkdColor = {r=0,g=0,b=0,a=0.5};
		}; 
	end
});

----------------------------------------------------------------
-- Frame:Black, for compatibility purposes.
----------------------------------------------------------------
RDX.RegisterFeature({
	name = "Frame: Black",
	category = i18n("Window Frames");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Create") then return nil; end
		if state:Slot("Frame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		if not desc then return nil; end
		state:AddSlot("Frame");
		state:AddSlot("SetTitleText");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local win, title = nil, (desc.title or i18n("(No title)"));
		
		state:_Attach(state:Slot("Create"), true, function(w)
			win = w;
			w:SetFraming(VFLUI.Framing.Sleek);
			win:SetText(title);
			win:SetTitleColor(explodeColor(_black));
			win:SetBackdropColor(explodeRGBA(_alphaBlack));
		end);

		state:_Attach(state:Slot("SetTitleText"), nil, function(txt)
			win:SetText(title .. txt);
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_title = VFLUI.LabeledEdit:new(parent, 100);
		ed_title:SetText(i18n("Window title")); ed_title:Show();
		if desc and desc.title then ed_title.editBox:SetText(desc.title); end
		ui:InsertFrame(ed_title);

		function ui:GetDescriptor()
			return {
				feature = "Frame: Black"; 
				title = ed_title.editBox:GetText();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function() 
		return {
			feature = "Frame: Black", 
			color = {r=0,g=0,b=0}
		}; 
	end
});

----------------------------------------------------------------
-- Frame: Fat
----------------------------------------------------------------
RDX.RegisterFeature({
	name = "Frame: Fat",
	category = i18n("Window Frames");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Create") then return nil; end
		if state:Slot("Frame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		if not desc then return nil; end
		state:AddSlot("Frame");
		state:AddSlot("SetTitleText");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local win, title = nil, (desc.title or i18n("(No title)"));
		
		state:_Attach(state:Slot("Create"), true, function(w)
			win = w;
			w:SetFraming(VFLUI.Framing.Fat);
			win:SetText(title);
		end);

		state:_Attach(state:Slot("SetTitleText"), nil, function(txt)
			win:SetText(title .. txt);
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);

		local ed_title = VFLUI.LabeledEdit:new(parent, 100);
		ed_title:SetText(i18n("Window title")); ed_title:Show();
		if desc and desc.title then ed_title.editBox:SetText(desc.title); end
		ui:InsertFrame(ed_title);

		function ui:GetDescriptor()
			return {
				feature = "Frame: Fat"; 
				title = ed_title.editBox:GetText();
			};
		end
		
		return ui;
	end;
	CreateDescriptor = function() 
		return {
			feature = "Frame: Fat",
		}; 
	end
});

----------------------------------
-- A frame Lock/Unlock
----------------------------------
RDX.RegisterFeature({
	name = "Frame: LW Lock/Unlock",
	category = i18n("Window Frames");
	deprecated = true;
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Create") then return nil; end
		if state:Slot("Frame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		if not desc then return nil; end
		state:AddSlot("Frame");
		state:AddSlot("SetTitleText");
		return true;
	end;
	ApplyFeature = function(desc, state)
		--[[if not RDXDK.IsDesktopLocked() then
			local win, title = nil, (desc.title or i18n("(No title)"));
			local titleColor = desc.titleColor or _black;
			local bkdColor = desc.bkdColor or _alphaBlack;
			state:_Attach(state:Slot("Create"), true, function(w)
				win = w;
				w:SetFraming(VFLUI.Framing.Sleek);
				win:SetText(title);
				win:SetTitleColor(explodeColor(titleColor));
				win:SetBackdropColor(explodeRGBA(bkdColor));
			end);
			state:_Attach(state:Slot("SetTitleText"), nil, function(txt)
				win:SetText(title .. txt);
			end);
		else return VFL.Noop;
		end
		return true;]]
		return VFL.Noop;
	end,
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local title = VFLUI.LabeledEdit:new(ui, 100); title:Show();
		title:SetText(i18n("Window Title"));
		if desc and desc.title then title.editBox:SetText(desc.title); end
		ui:InsertFrame(title);

		local titleColor = RDXUI.GenerateColorSwatch(ui, i18n("Title color"));
		if desc and desc.titleColor then titleColor:SetColor(explodeRGBA(desc.titleColor)); end

		local bkdColor = RDXUI.GenerateColorSwatch(ui, i18n("Background color"));
		if desc and desc.bkdColor then bkdColor:SetColor(explodeRGBA(desc.bkdColor)); end

		function ui:GetDescriptor()
			return {
				feature = "Frame: LW Lock/Unlock"; 
				title = title.editBox:GetText();
				titleColor = titleColor:GetColor();
				bkdColor = bkdColor:GetColor();
			};
		end

		return ui;
	end,
	CreateDescriptor = function() 
		return {
			feature = "Frame: LW Lock/Unlock";
			titleColor = { r=0,g=0,b=0,a=1 };
			bkdColor = {r=0,g=0,b=0,a=0.5};
		}; 
	end
});

----------------------------------
-- Box frame
----------------------------------
RDX.RegisterFeature({
	name = "Frame: Box",
	category = i18n("Window Frames");
	IsPossible = function(state)
		if not state:Slot("Window") then return nil; end
		if not state:Slot("Create") then return nil; end
		if state:Slot("Frame") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		if not desc then return nil; end
		state:AddSlot("Frame");
		state:AddSlot("SetTitleText");
		return true;
	end;
	ApplyFeature = function(desc, state)
		local win, title = nil, (desc.title or i18n("(No title)"));
		local titleColor = desc.titleColor or _black;
		local bkdColor = desc.bkdColor or _alphaBlack;
		
		state:_Attach(state:Slot("Create"), true, function(w)
			win = w;
			w:SetFraming(VFLUI.Framing.Box);
			win:SetText(title);
			win:SetTitleColor(explodeColor(titleColor));
			win:SetBackdropColor(explodeRGBA(bkdColor));
		end);

		state:_Attach(state:Slot("SetTitleText"), nil, function(txt)
			win:SetText(title .. txt);
		end);
		return true;
	end,
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		local title = VFLUI.LabeledEdit:new(ui, 100); title:Show();
		title:SetText(i18n("Window Title"));
		if desc and desc.title then title.editBox:SetText(desc.title); end
		ui:InsertFrame(title);

		local titleColor = RDXUI.GenerateColorSwatch(ui, i18n("Title color"));
		if desc and desc.titleColor then titleColor:SetColor(explodeRGBA(desc.titleColor)); end

		local bkdColor = RDXUI.GenerateColorSwatch(ui, i18n("Background color"));
		if desc and desc.bkdColor then bkdColor:SetColor(explodeRGBA(desc.bkdColor)); end

		function ui:GetDescriptor()
			return {
				feature = "Frame: Box"; 
				title = title.editBox:GetText();
				titleColor = titleColor:GetColor();
				bkdColor = bkdColor:GetColor();
			};
		end

		return ui;
	end,
	CreateDescriptor = function() 
		return {
			feature = "Frame: Box";
			titleColor = { r=0,g=0,b=0,a=1 };
			bkdColor = {r=0,g=0,b=0,a=0.5};
		}; 
	end
});
