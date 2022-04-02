-- Minimap.lua
-- OpenRDX
-- Sigg Rashgarroth EU

RDX.RegisterFeature({
	name = "minimap"; version = 1; title = i18n("Minimap"); category = i18n("Basics");
	IsPossible = function(state)
		if not state:Slot("ArtFrame") then return nil; end
		if not state:Slot("Base") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if not desc then VFL.AddError(errs, i18n("Missing descriptor.")); return nil; end
		local flg = true;
		flg = flg and __UFFrameCheck_Proto("Frame_", desc, state, errs);
		flg = flg and __UFAnchorCheck(desc.anchor, state, errs);
		flg = flg and __UFOwnerCheck(desc.owner, state, errs);
		if flg then state:AddSlot("Frame_" .. desc.name); end
		return flg;
	end;
	ApplyFeature = function(desc, state)
		local objname = "Frame_" .. desc.name;

		------------------ On frame creation
		local createCode = [[
local mmap = VFLUI.AcquireFrame("Minimap");
VFLUI.StdSetParent(mmap, ]] .. RDXUI.ResolveFrameReference(desc.owner) .. [[);
mmap:SetPoint(]] .. RDXUI.AnchorCodeFromDescriptor(desc.anchor) .. [[);
mmap:SetWidth(]] .. desc.w .. [[); mmap:SetHeight(]] .. desc.h .. [[);
--mmap:SetPlayerModel("Interface\\Minimap\\MinimapArrow.mdx");
--mmap:SetArrowModel("Interface\\Minimap\\Rotating-MinimapArrow.mdl");
mmap:SetBlipTexture(VFLUI.GetBlipTexture("]] .. desc.blipType .. [["));
mmap:SetMaskTexture(VFLUI.GetMaskTexture("]] .. desc.maskType .. [["));
local angle = 0;
local nord = VFLUI.CreateFontString(mmap);
nord:SetPoint("CENTER", mmap, "CENTER", 120*math.cos(0 + math.pi/2), 120*math.sin(0 + math.pi/2));
]] .. VFLUI.GenerateSetFontCode("nord", desc.font, nil, true) .. [[
nord:SetText("N")
nord:Show();
mmap.nord = nord;

local function moveCompass()
	angle = 0;
	if GetCVar("rotateMinimap") == "1" then angle = MiniMapCompassRing:GetFacing(); end
	mmap.nord:SetPoint("CENTER", mmap, "CENTER", ]] .. desc.w / 2 .. [[*math.cos(angle + math.pi/2), ]] .. desc.w / 2 .. [[*math.sin(angle + math.pi/2));
end
moveCompass();
if GetCVar("rotateMinimap") == "1" then
	mmap:SetScript("OnUpdate", moveCompass);
end

mmap:SetZoom(1);

mmap:EnableMouseWheel(1)
mmap:SetScript('OnMouseWheel', function(_, dir)
      if(dir > 0) then
         Minimap_ZoomIn()
      else
         Minimap_ZoomOut()
      end
end)

mmap:Show();
frame.]] .. objname .. [[ = mmap;
]];
		state:Attach(state:Slot("EmitCreate"), true, function(code) code:AppendCode(createCode); end);

		------------------ On frame destruction.
		local destroyCode = [[
frame.]] .. objname .. [[.nord:Destroy(); frame.]] .. objname .. [[.nord = nil;
frame.]] .. objname .. [[:Destroy(); frame.]] .. objname .. [[ = nil;
]];
		state:Attach(state:Slot("EmitDestroy"), true, function(code) code:AppendCode(destroyCode); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent, state)
		local ui = VFLUI.CompoundFrame:new(parent);

		-- Name/width/height
		local ed_name, ed_width, ed_height = RDXUI.GenNameWidthHeightPortion(ui, desc, state);

		-- Owner
		local owner = RDXUI.MakeSlotSelectorDropdown(ui, i18n("Owner"), state, "Subframe_", true);
		if desc and desc.owner then owner:SetSelection(desc.owner); end

		-- Anchor
		local anchor = RDXUI.UnitFrameAnchorSelector:new(ui); anchor:Show();
		anchor:SetAFArray(RDXUI.ComposeAnchorList(state));
		if desc and desc.anchor then anchor:SetAnchorInfo(desc.anchor); end
		ui:InsertFrame(anchor);
		
		local er = RDXUI.EmbedRight(ui, i18n("Blip Type:"));
		local dd_blipType = VFLUI.Dropdown:new(er, VFLUI.GetListBlipTexture);
		dd_blipType:SetWidth(150); dd_blipType:Show();
		if desc and desc.blipType then 
			dd_blipType:SetSelection(desc.blipType); 
		else
			dd_blipType:SetSelection("Blizzard");
		end
		er:EmbedChild(dd_blipType); er:Show();
		ui:InsertFrame(er);
		
		local er = RDXUI.EmbedRight(ui, i18n("Mask Type:"));
		local dd_maskType = VFLUI.Dropdown:new(er, VFLUI.GetListMaskTexture);
		dd_maskType:SetWidth(150); dd_maskType:Show();
		if desc and desc.maskType then 
			dd_maskType:SetSelection(desc.maskType); 
		else
			dd_maskType:SetSelection("Blizzard");
		end
		er:EmbedChild(dd_maskType); er:Show();
		ui:InsertFrame(er);
		
		local er = RDXUI.EmbedRight(ui, i18n("Compass Font"));
		local fontsel = VFLUI.MakeFontSelectButton(er, desc.font); fontsel:Show();
		er:EmbedChild(fontsel); er:Show();
		ui:InsertFrame(er);
		
		function ui:GetDescriptor()
			return { 
				feature = "minimap"; version = 1;
				name = ed_name.editBox:GetText();
				owner = owner:GetSelection();
				w = ed_width:GetSelection();
				h = ed_height:GetSelection();
				anchor = anchor:GetAnchorInfo();
				blipType = dd_blipType:GetSelection();
				maskType = dd_maskType:GetSelection();
				font = fontsel:GetSelectedFont();
			};
		end

		return ui;
	end;
	CreateDescriptor = function()
		return { 
			feature = "minimap"; version = 1; 
			name = "minimap1", owner = "Base";
			w = 140; h = 140;
			anchor = { lp = "TOPLEFT", af = "Base", rp = "TOPLEFT", dx = 0, dy = 0};
			blipType = "Blizzard"; maskType = "Blizzard";
		};
	end;
});

