-- Bossmod_Basics.lua
-- RDX - Raid Data Exchange
-- (C)2007 Raid Informatics
--
-- Basic features for Bossmod objects.

------------------------------------------------------------------------
-- GUI Bossmods module for RDX
--   By: Trevor Madsen (Gibypri, Kilrogg realm)
--
-- Note:
--  Licensed exclusively to Raid Informatics
------------------------------------------------------------------------

DT_Bossmods = {};
function GetBossmodDT(encid)
	DT_Bossmods[encid] = DT_Bossmods[encid] or DispatchTable:new();
	return DT_Bossmods[encid]
end

RDX.RegisterFeature({
	name = "Register Encounter",
	category = i18n("Registration");
	IsPossible = function(state)
		if not state:Slot("Bossmod") then return nil; end
		if state:Slot("Registered") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state, errs)
		if not desc then return nil; end
		if not desc.bossname or not desc.title then 
			VFL.AddError(errs, i18n("Missing field"));
			return false;
		end
		
		state:AddSlot("Registered");
		return true;
	end;
	ApplyFeature = function(desc, state, pkgName, objName)
		local category = desc.category;	if not category then category = ""; end
		category = strtrim(category);
		if category == "" then category = pkgName; end

		state.Code:Clear();
		state.Code:AppendCode([[
		local encid = "bm_]]..pkgName..objName..[[";
		-- a LOCAL handle for a GLOBAL but LOCALLY UNIQUE dispatchtable
		local BossmodEvents = GetBossmodDT(encid); 
		local track = nil;

		-- Register the encounter, replacing in situ automatically
		RDX.RegisterEncounter({
			name = encid; category = ]].. string.format("%q", category) ..[[;
			title = ]] .. string.format("%q", desc.title) .. [[;
			ActivateEncounter = function() BossmodEvents:Dispatch("ACTIVATE") end;
			DeactivateEncounter = function() BossmodEvents:Dispatch("DEACTIVATE") end;
			StartEncounter = function() BossmodEvents:Dispatch("START") end;
			StopEncounter = function() BossmodEvents:Dispatch("STOP") end;
		});
		
		-- Clear any old binds
		WoWEvents:Unbind(encid);
		RDXEvents:Unbind(encid);
		RPC.UnbindPattern("^"..encid);
		BossmodEvents:Unbind(encid);
		OmniEvents:Unbind(encid);

		RDX.RegisterMouseoverEncounterTrigger(]] .. string.format("%q", desc.bossname) .. [[, encid);
		
		BossmodEvents:Bind("ACTIVATE", nil, function()
			if not track then
				track = HOT.TrackTarget(]].. string.format("%q", desc.bossname) .. [[);
				track:Open();
				RDX.AutoStartStopEncounter(track);
				RDX.AutoUpdateEncounterPane(track);
			end
			
			RPC.Bind(encid, function(sender, event) 
				BossmodEvents:LatchedDispatch(2, event);
				-- definately don't want to dispatch everytime we get an RPC
			end);
		end, encid);
		
		BossmodEvents:Bind("DEACTIVATE", nil, function()
			if track then
				track:Close(); track = nil;
			end
			
			WoWEvents:Unbind(encid);
			RDXEvents:Unbind(encid);
			OmniEvents:Unbind(encid);
			RPC.UnbindPattern("^"..encid);
		end, encid);
		
		BossmodEvents:Bind("STOP", encid, function()
			RDX.QuashAlertsByPattern("^bm");
		end, encid);
		]]);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);

		local title = VFLUI.LabeledEdit:new(ui, 180); title:Show();
		title:SetText(i18n("Encounter Title"));
		if desc and desc.title then title.editBox:SetText(desc.title); end
		ui:InsertFrame(title);

		local category = VFLUI.LabeledEdit:new(ui, 180); category:Show();
		category:SetText(i18n("Category (if blank, uses package name)"));
		if desc and desc.category then category.editBox:SetText(desc.category); end
		ui:InsertFrame(category);

		local bossname = VFLUI.LabeledEdit:new(ui, 180); bossname:Show();
		bossname:SetText(i18n("Complete Boss Name for Tracker"));
		if desc and desc.bossname then bossname.editBox:SetText(desc.bossname); end
		ui:InsertFrame(bossname);

		local btnFromTarget = VFLUI.Button:new(ui);
		btnFromTarget:SetText(i18n("From Target")); btnFromTarget:SetHeight(24);
		btnFromTarget:Show();
		btnFromTarget:SetScript("OnClick", function()
			if UnitExists("target") then
				title.editBox:SetText(UnitName("target"));
				bossname.editBox:SetText(UnitName("target"));
			end
   	end);
		ui:InsertFrame(btnFromTarget);

		function ui:GetDescriptor()
			return {
				feature = "Register Encounter"; 
				title = title.editBox:GetText();
				bossname = bossname.editBox:GetText();
				category = category.editBox:GetText();
			};
		end

		return ui;
	end,
	CreateDescriptor = function() return {feature = "Register Encounter"}; end
});

RDX.RegisterFeature({
	name = "Basic Events (OMNI|MSG)",
	title = "Basic Events (OMNI|MSG)",
	category = i18n("Registration");
	IsPossible = function(state)
		if not state:Slot("Bossmod") then return nil; end
		if not state:Slot("Registered") then return nil; end
		if state:Slot("BasicEvents") then return nil; end
		return true;
	end,
	ExposeFeature = function(desc, state)
		if not desc then return nil; end
		state:AddSlot("BasicEvents");
		return true;
	end;
	ApplyFeature = function(desc, state)
		state.Code:AppendCode([[
		BossmodEvents:Bind("ACTIVATE", nil, function()
			RDXBM.BindAbilityEvents2(encid, BossmodEvents);
			RDXBM.BindMsgEvents(encid, BossmodEvents);
		end, encid);
		]]);
		return true;
	end,
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);
		
		local txt = VFLUI.CreateFontString(ui);
		txt:SetPoint("TOPLEFT", parent, "TOPLEFT");
		txt:SetHeight(200); txt:SetWidth(450); txt:Show();
		txt:SetFontObject(VFLUI.GetFont(Fonts.Default, 16));
		txt:SetJustifyH("LEFT"); txt:SetJustifyV("TOP");
		txt:SetText(""); txt:Show();
		
		local explanation = strcolor(1,.1,.1)..[[OMNI ]]..strcolor(1,1,1)..[[fires when a mob uses a spell, ability, gain buff or someone is afflicted with a debuff
]]..strcolor(.1,1,.1)..[[MSG ]]..strcolor(1,1,1)..[[fires when the boss makes some kind of message, say/yell/emote/etc]];
		
		txt:SetText(explanation);
	
		function ui:GetDescriptor()
			return {
				feature = "Basic Events (OMNI|MSG)"; 
			};
		end
		
		ui.Destroy = VFL.hook(function(s)
			txt:Hide(); txt:SetParent(VFLOrphan); txt:ClearAllPoints(); txt:SetAlpha(1);
			txt:SetHeight(0); txt:SetWidth(0);
			txt:SetFontObject(GameFontNormal);
			txt:SetTextColor(1,1,1,1);
			txt:SetAlphaGradient(0,0);
			txt:SetJustifyH("CENTER"); txt:SetJustifyV("CENTER");
			txt:SetText("");
		end, ui.Destroy);
		
		return ui;
	end,
	CreateDescriptor = function() return {feature = "Basic Events (OMNI|MSG)"}; end
});
