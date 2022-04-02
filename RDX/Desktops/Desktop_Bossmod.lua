-- Desktop_Bossmod.lua
-- OpenRDX

----------------------------------
-- bossmod encounter pane
----------------------------------

RDXDK.RegisterWindowLess({
	name = "desktop_bossmod",
	Open = function(id)
		local a = RDX.GetEncounterPane(); 
		if a then a:Show(); end
		return a;
	end,
	Close = function(id, frame)
		frame:Hide();
		return true;
	end,
	Rebuild = function(id, frame)
		return true;
	end,
	Props = function(mnu, id, frame)
		--[[table.insert(mnu, {
			text = i18n("Edit Window"),
			OnClick = function()
				VFL.poptree:Release();
				local md = RDXDB.GetObjectData(id);
				if md then EditWindow(id, md); end
			end
		});]]
		table.insert(mnu, {
			text = i18n("Rebuild"),
			OnClick = function()
				VFL.poptree:Release();
				local cls = RDXDK.GetWindowLess(frame._dk_name);
				if cls then
					cls.Rebuild(id, frame);
				end
			end
		});
	end
});

----------------------------------
-- bossmod multi track window
----------------------------------

RDXDK.RegisterWindowLess({
	name = "desktop_multi_track",
	Open = function(id)
		local a = MultiTrack.Open(); 
		a:Show();
		return a;
	end,
	Close = function(id, frame)
		MultiTrack.Close();
		return true;
	end,
	Rebuild = function(id, frame)
		return true;
	end,
	Props = function(mnu, id, frame)
		--[[table.insert(mnu, {
			text = i18n("Edit Window"),
			OnClick = function()
				VFL.poptree:Release();
				local md = RDXDB.GetObjectData(id);
				if md then EditWindow(id, md); end
			end
		});]]
		table.insert(mnu, {
			text = i18n("Rebuild"),
			OnClick = function()
				VFL.poptree:Release();
				local cls = RDXDK.GetWindowLess(frame._dk_name);
				if cls then
					cls.Rebuild(id, frame);
				end
			end
		});
	end
});