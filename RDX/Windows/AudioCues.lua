-- AudioCues.lua
-- RDX - Raid Data Exchange
-- (C)2006 Raid Informatics
--
-- THIS FILE CONTAINS COPYRIGHTED CONTENT SUBJECT TO THE TERMS OF A SEPARATE LICENSE.
-- UNLICENSED COPYING IS PROHIBITED.
--
-- Triggers that play a sound when specific sets become empty/full.
-- Audio cues are implemented as window features; when the window in question is shown,
-- the audio cues are active.

local function GenPlaySoundFunc(sound)
	if (type(sound) == "string") and (sound ~= "") then
		return function()	PlaySoundFile(sound);	end
	else
		return VFL.Noop;
	end
end

RDX.RegisterFeature({
	name = "Audio Cue: Set Delta";
	multiple = true;
	category = i18n("Audio Cues");
	IsPossible = function(state)
		if not state:Slot("UnitWindow") then return nil; end
		return true;
	end;
	ExposeFeature = function(desc, state, errs)
		if desc and desc.set then
			local set = RDX.FindSet(desc.set);
			if not set then
				VFL.AddError(errs, i18n("Invalid set pointer."));
				return nil;
			end
			return true;
		else
			VFL.AddError(errs, i18n("Bad or missing set pointer"));
			return nil;
		end
	end;
	ApplyFeature = function(desc, state)
		local set, n = RDX.FindSet(desc.set), 0;
		if not set then return; end

		-- Populate sound playing functions.
		local fFill, fEmpty, fUp, fDown = GenPlaySoundFunc(desc.sndFill), GenPlaySoundFunc(desc.sndEmpty), GenPlaySoundFunc(desc.sndUp), GenPlaySoundFunc(desc.sndDown);

		-- Master dispatcher function
		local function cueCheck()
			local n1 = set:GetSize();

			-- Honor "No Sound" user choice
			if RDXU.nosound then n = n1; return; end

			-- Figure out what to do
			if n1 > n then
				if n == 0 then -- set became nonempty
					fFill();
				else -- set increased in size
					fUp();
				end
			elseif n1 < n then
				if n1 == 0 then -- Set became empty
					fEmpty();
				else -- Set decreased in size
					fDown();
				end
			end
			n = n1;
		end

		-- Bind events
		state:_Attach(state:Slot("Show"), true, function(w) set:ConnectDelta(w, cueCheck); end);
		state:_Attach(state:Slot("Hide"), true, function(w) set:RemoveDelta(w); end);

		return true;
	end;
	UIFromDescriptor = function(desc, parent)
		local ui = VFLUI.CompoundFrame:new(parent);

		local setsel = RDX.SetFinder:new(ui); setsel:Show();
		if desc.set then setsel:SetDescriptor(desc.set); end
		ui:InsertFrame(setsel);

		local er = RDXUI.EmbedRight(ui, i18n("Non-empty sound"));
		local sndFill = VFLUI.MakeSoundSelectButton(er, desc.sndFill); sndFill:Show();
		er:EmbedChild(sndFill); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Increase sound"));
		local sndUp = VFLUI.MakeSoundSelectButton(er, desc.sndUp); sndUp:Show();
		er:EmbedChild(sndUp); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Decrease sound"));
		local sndDown = VFLUI.MakeSoundSelectButton(er, desc.sndDown); sndDown:Show();
		er:EmbedChild(sndDown); er:Show();
		ui:InsertFrame(er);

		local er = RDXUI.EmbedRight(ui, i18n("Empty sound"));
		local sndEmpty = VFLUI.MakeSoundSelectButton(er, desc.sndEmpty); sndEmpty:Show();
		er:EmbedChild(sndEmpty); er:Show();
		ui:InsertFrame(er);

		function ui:GetDescriptor()
			return { 
				feature = "Audio Cue: Set Delta";
				set = setsel:GetDescriptor();
				sndUp = sndUp:GetSelectedSound();
				sndFill = sndFill:GetSelectedSound();
				sndDown = sndDown:GetSelectedSound();
				sndEmpty = sndEmpty:GetSelectedSound();
			};
		end

		return ui;
	end,
	CreateDescriptor = function() 
		return {
			feature = "Audio Cue: Set Delta"; 
		}; 
	end
});
