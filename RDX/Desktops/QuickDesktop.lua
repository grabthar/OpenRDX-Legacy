-- QuickDesktop.lua
-- OpenRDX

local qd = nil;

-- On init, create the quick desktop list
RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	if not RDXG.qd then RDXG.qd = {}; end
	qd = RDXG.qd;
	-- Verify that all the quick desktops exist; remove those that do not.
	VFL.filterInPlace(qd, function(x)
		local _,_,_,ty = RDXDB.GetObjectData(x);
		if(ty == "Desktop") then return true; else return nil; end
	end);
end);

--- Determine if a desktop is on the Quick Desktops list.
function RDXDK.IsQuickDesktop(path)
	return VFL.vfind(qd, path);
end

-- Remove a desktop from the Quick Desktops list.
function RDXDK.RemoveQuickDesktop(path)
	VFL.filterInPlace(qd, function(x) return (x ~= path); end);
end

-- Add a desktop to the Quick Desktops list if it's not already there.
function RDXDK.AddQuickDesktop(path)
	-- Make sure it's not already there
	if RDXDK.IsQuickDesktop(path) then return nil; end
	-- Make sure it's a desktop
	local _,_,_,ty = RDXDB.GetObjectData(path); if(ty ~= "Desktop") then return nil; end
	-- Add it
	table.insert(qd, path);
end

-- OLD function
function RDX.AddQuickDesktop(path)
	RDXDK.AddQuickDesktop(path);
end

local mnu = {};
function RDXDK.BuildQuickDesktopMenu()
	VFL.empty(mnu);
	local newqd = VFL.copy(qd);
	if GetActiveTalentGroup() == 1 then
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_inn");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_solo");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_group");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_raid");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_pvp");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_arena");
	elseif GetActiveTalentGroup() == 2 then
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_inn2");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_solo2");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_group2");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_raid2");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_pvp2");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_arena2");
	else
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_inn");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_solo");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_group");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_raid");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_pvp");
		table.insert(newqd, "desktops:" .. RDX.pspace .. "_arena");
	end
	for _,name in ipairs(newqd) do
		local path = name;
		table.insert(mnu, {
			text = path;
			OnClick = function()
				VFL.poptree:Release();
				if(arg1 == "LeftButton") then
					--RDXDK.SecuredChangeDesktop(path);
					RDXDK.SetSwichDesktop(path);
				elseif(arg1 == "RightButton") then
					RDXDK.RemoveQuickDesktop(path);
				end
			end;
		});
	end
	return mnu;
end