-- OpenRDX
-- by Doccz / ar4's

art_fe_win = nil;

local function loadfonts(path)
    if (not RDXDB.CheckObject(path, "UnitFrameType")) then
        RDX.print("Invalid object/type at path: \""..path.."\"");
        art_fe_win = nil;
        return;
    end
    -- cover the basics of the window again
    local dlg = VFLUI.Window:new(UIParent);
    dlg:SetFrameStrata("FULLSCREEN");
    VFLUI.Window.SetDefaultFraming(dlg, 22);
    dlg:SetWidth(420); dlg:SetHeight(260);
    dlg:SetTitleColor(0, 0, .6);
    dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
    dlg:SetPoint("center", UIParent, "center");
    dlg:SetText("Font Editor: "..path);
    dlg:Show();
    VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
    
    local eh = function() dlg:Destroy(); end;
    VFL.AddEscapeHandler(eh);
    
    local bc = VFLUI.CloseButton:new(dlg);
    dlg:AddButton(bc);
    bc:SetScript("OnClick", function() VFL.EscapeTo(eh); end); -- when clicked, refer to escape handler (to destroy window)
    
    local ui, sf = VFLUI.CreateScrollingCompoundFrame(dlg);
    sf:SetWidth(dlg:GetWidth()-30); sf:SetHeight(dlg:GetHeight()-50); -- height should cancel out the offset below and the width of the confirm button
    sf:SetPoint("TOPLEFT", dlg, "TOPLEFT", 7, -23);
    sf:Show();
    
    local fs, handle = {}, RDXDB.AccessPath(RDXDB.ParsePath(path)); -- initialize variables
    -- init; going to assume handle is valid as we checked the object instants before in findfont
    for o,x in pairs(handle.data) do
        if (x.font and type(x.font) == "table") then
            local bs, er = {};
            bs = RDX.GetFeatureByDescriptor(x);
            er = RDXUI.EmbedRight(ui, bs.title..": "..x.name);
            fs[o] = VFLUI.MakeFontSelectButton(er, x.font); fs[o]:Show();
            er:EmbedChild(fs[o]); er:Show();
            ui:InsertFrame(er);
        end
    end
    
    ui.isLayoutRoot = true;
    ui:SetWidth(sf:GetWidth());
    if (ui.DialogOnLayout) then ui:DialogOnLayout(); end
    ui:Show();
    
    local ok = VFLUI.OKButton:new(dlg);
    ok:SetText("Go"); ok:SetWidth(75); ok:SetHeight(25);
    ok:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
    ok:Show();
    ok:SetScript("OnClick", function()
        -- edit the fonts
        for o,x in pairs(fs) do
            handle.data[o].font = x:GetSelectedFont();
        end
        RDXDB.NotifyUpdate(path);
        RDX.print("Fonts edited for: "..path.."!");
        VFL.RemoveEscapeHandler(eh); -- just for consistence
        dlg:Destroy();
    end);
    
    dlg.Destroy = VFL.hook(function(a)
        ok:Destroy(); ok = nil;
        sf:Destroy(); sf = nil;
        ui:Destroy(); ui = nil;
        VFL.empty(fs); fs = nil;
        handle = nil;
        art_fe_win = nil; -- final step in the window process, nil the global
    end, dlg.Destroy);
    
    return dlg;
end

-- High API
RDX.loadfonts = loadfonts;

local function findfont()
    local dlg = VFLUI.Window:new(UIParent);
    dlg:SetFrameStrata("FULLSCREEN");
    VFLUI.Window.SetDefaultFraming(dlg, 22);
    dlg:SetWidth(350); dlg:SetHeight(80);
    dlg:SetTitleColor(0, 0, .6);
    dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
    dlg:SetPoint("center", UIParent, "center");
    dlg:SetText("Font Editor");
    dlg:Show();
    VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
    
    local eh = function() dlg:Destroy(); end;
    VFL.AddEscapeHandler(eh); -- when the user presses escape, destroy window
    
    local bc = VFLUI.CloseButton:new(dlg); -- The "X" button on the top right
    dlg:AddButton(bc);
    bc:SetScript("OnClick", function() VFL.EscapeTo(eh); end); -- when clicked, refer to escape handler (to destroy window)
    
    local ui = VFLUI.CompoundFrame:new(dlg);
    
    local of = RDXDB.ObjectFinder:new(ui, function(p,f,md) return (md and type(md) == "table" and md.ty and string.find(md.ty, "UnitFrameType")); end);
    of:SetLabel("Unitframe Object"); of:Show();
    
    ui:InsertFrame(of);
    ui.isLayoutRoot = true; -- copied from FeatureEditor.lua
    ui:SetParent(dlg);
    ui:SetWidth(dlg:GetWidth()-10);
    ui:SetPoint("TOPLEFT", dlg, "TOPLEFT", 7, -23);
    if (ui.DialogOnLayout) then ui:DialogOnLayout(); end
    ui:Show();
    
    local ok = VFLUI.OKButton:new(dlg);
    ok:SetText("Go"); ok:SetWidth(75); ok:SetHeight(25);
    ok:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
    ok:Show();
    ok:SetScript("OnClick", function()
        --run next window
        art_fe_win = loadfonts(of:GetPath());
        VFL.RemoveEscapeHandler(eh); -- manually remove escape handler from table
        dlg:Destroy(); -- close; don't invoke VFL.EscapeTo(eh) since it will close the window above it also
    end);
    
    dlg.Destroy = VFL.hook(function(a) -- do these additional commands when destroying
        ok:Destroy(); ok = nil;
        ui:Destroy(); ui = nil;
        of = nil; -- destroyed when ui is destroyed, simply nil here
        eh = nil;
        -- don't destroy/nil bc, it's taken care of after this function when parented to dlg
        if (art_fe_win == dlg) then -- should not be equal if proceeding to step 2 of the editing prcess
            art_fe_win = nil; -- if simply escaping/closing the window, reset global
        end
    end, dlg.Destroy);
    
    return dlg; -- return window
end

-- High API
RDX.findfont = findfont;

-- INIT

RDXEvents:Bind("INIT_DEFERRED", nil, function()
	if (not art_fe_win) then
		--art_fe_win = findfont(); -- global variable to determine if a window is open
	end
	
	local etc = RDXDB.GetObjectType("UnitFrameType");
	if (not etc) then return; end
	--art_fe_oldgbm = etc.GenerateBrowserMenu;
	etc.GenerateBrowserMenu = VFL.hook(function(mnu, path)
	table.insert(mnu, {
	    text = i18n("Font Editor..."),
	    OnClick = function()
		VFL.poptree:Release();
		RDX.loadfonts(path);
	    end
	});
	end, etc.GenerateBrowserMenu);
end);