-- Desktop_OmniLive.lua
-- OpenRDX

----------------------------------
-- OmniLive combat log
----------------------------------

RDXDK.RegisterWindowLess({
	name = "desktop_omnilive",
	Open = function(id)
		local a = Omni.OpenLiveWindow();
		if a then a:Show(); end
		return a;
	end,
	Close = function(id, frame)
		Omni.CloseLiveWindow();
		--frame:Destroy(); frame = nil;	
		--RDXU.omniLW = nil;
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
