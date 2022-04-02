-- Errors.lua
-- VFL
-- (C)2006 Bill Johnson and The VFL Project
--
-- A frame for collecting error information with full stack traces.

-- Repaint signal for the errors window
local sigRepaint = Signal:new();

----------------------------------------------------
-- DATA COLLECTION
----------------------------------------------------
local errsByTitle = {};
local errs = {};

local function ErrorHandler(msg)
	if not msg then return; end
	local prev = errsByTitle[msg];
	if prev then
		prev.count = prev.count + 1;
	else
		local err = {};
		err.msg = string.gsub(msg, "^[Ii]nterface%\\[Aa]dd[Oo]ns%\\", "");
		err.full = msg .. "\n\nStack trace:\n-----------\n" .. debugstack(4,50,50);
		err.count = 1;
		errsByTitle[msg] = err;
		table.insert(errs, 1, err);
		VFL.print("|cFFFF0000[*] Lua error:|r |cFFFFFFFF" .. msg .. "|r - Type /err to view extended info.");
		sigRepaint:Raise();
	end
end

function _ClearErrors()
	VFL.empty(errsByTitle);
	VFL.empty(errs);
	sigRepaint:Raise();
end

seterrorhandler(ErrorHandler);

-- Trip an error.
function VFL.TripError(context, msg, extended)
	context = tostring(context); msg = tostring(msg); extended = tostring(extended);
	local err = {};
	err.msg = context .. ": " .. msg;
	err.full = err.msg .. "\n\nExtended info:\n-----------\n" .. extended;
	err.count = 1;
	errsByTitle[err.msg] = err;
	table.insert(errs, 1, err);
	VFL.print("|cFFFF0000[*] " .. context .. ":|r |cFFFFFFFF" .. msg .. "|r - Type /err to view extended info.");
end

---------------------------------------------
-- INTERFACE
---------------------------------------------

local dlg = nil;
local function OpenErrorDialog()
	if dlg then return; end
	
	dlg = VFLUI.Window:new(UIParent); dlg:SetFrameStrata("FULLSCREEN");
	VFLUI.Window.SetDefaultFraming(dlg, 24);
	dlg:SetTitleColor(.6,0,0);
	dlg:SetText("Errors");
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetHeight(400); dlg:SetWidth(400);
    VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	dlg:Show();
	local ca = dlg:GetClientArea();

	---------------- Error list
	local selection = nil;
	local errorList = VFLUI.List:new(dlg, 12, VFLUI.Selectable.AcquireCell);
	errorList:SetPoint("TOPLEFT", ca, "TOPLEFT");
	errorList:SetWidth(390); errorList:SetHeight(96);
	errorList:Rebuild(); errorList:Show();
	errorList:SetDataSource(function(cell, data, pos)
		cell.text:SetText(data.msg);
		if data == selection then
			cell.selTexture:SetVertexColor(0,0,1); cell.selTexture:Show();
		else
			cell.selTexture:Hide();
		end
		cell:SetScript("OnClick", function() selection = data; sigRepaint:Raise(); end);
	end, VFL.ArrayLiterator(errs));

	---------------------- View box
	local viewBox = VFLUI.TextEditor:new(dlg);
	viewBox:SetPoint("TOPLEFT", errorList, "BOTTOMLEFT");
	viewBox:SetWidth(390); viewBox:SetHeight(250); viewBox:Show();

	--------------------- Repaint
	local function Repaint()
		errorList:Update();
		if selection and VFL.vfind(errs, selection) then
			viewBox:SetText(selection.full or "");
		else
			selection = nil; viewBox:SetText("");
		end
	end
	sigRepaint:Connect(nil, Repaint, "repaint");

	-------------------- Interactions
	local btnCancel = VFLUI.CancelButton:new(dlg);
	btnCancel:SetHeight(25); btnCancel:SetWidth(60);
	btnCancel:SetPoint("BOTTOMRIGHT", ca, "BOTTOMRIGHT");
	btnCancel:SetText("Close"); btnCancel:Show();
	btnCancel:SetScript("OnClick", function()
		dlg:Destroy(); dlg = nil;
	end);

	local btnNone = VFLUI.Button:new(dlg);
	btnNone:SetHeight(25); btnNone:SetWidth(60);
	btnNone:SetPoint("RIGHT", btnCancel, "LEFT");
	btnNone:SetText("Clear"); btnNone:Show();
	btnNone:SetScript("OnClick", function() _ClearErrors();	end);

	dlg.Destroy = VFL.hook(function(s)
		sigRepaint:DisconnectByID("repaint"); Repaint = nil;
		btnCancel:Destroy(); btnNone:Destroy();
		btnCancel = nil; btnNone = nil;
		errorList:Destroy(); errorList = nil; selection = nil;
		viewBox:Destroy(); viewBox = nil;
		dlg = nil;
	end, dlg.Destroy);

	return;
end

SLASH_ERR1 = "/err";
SlashCmdList["ERR"] = OpenErrorDialog;
