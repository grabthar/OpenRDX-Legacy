-- ObjectDB.lua
-- RDX - Raid Data Exchange
-- (C)2006 Bill Johnson
--
-- The Object Database is the main method of persistent global storage for RDX.
-- The object database is divided into Packages, each of which is a container
-- that can hold any number of Objects.
--
-- Objects are referred to by a path of the form "package:object"
RDXDB = {};
RDXDBEvents = DispatchTable:new();

-----------------------------------------------------------
-- CORE ROUTINES
-----------------------------------------------------------
-- Parse a path (a:b --> a, b)
local function ParsePath(path)
	if not path then return nil; end
	local _, _, a, b = string.find(path, "^(.*):(.*)$");
	return a,b;
end
RDXDB.ParsePath = ParsePath;

-- Generate a path from components (a, b --> a:b)
local function MakePath(pkg, obj)
	return pkg .. ":" .. obj;
end
RDXDB.MakePath = MakePath;

-- Access the data stored at a given path, possibly resolving symlinks
-- RDX 7.1 table are objects, string are metadata package
local function AccessPathRaw(pkg, obj)
	if not pkg then return nil; end
	local qq = RDXData[pkg];
	if not qq or (type(qq[obj]) ~= "table") then return nil; end
	return qq[obj];
end
local function AccessPath(pkg, obj)
	local d1 = AccessPathRaw(pkg, obj);
	if not d1 then return nil; end
	if d1.ty ~= "SymLink" then return d1; end
	-- Resolve symlinks
	return AccessPathRaw(ParsePath(d1.data));
end
RDXDB._AccessPathRaw = AccessPathRaw;
RDXDB.AccessPath = AccessPath;

-- Resolve a path. If the path points to a symlink, returns the symlink
-- destination, otherwise returns the original path.
local function ResolvePath(path)
	if not path then return nil; end
	local d1 = AccessPathRaw(ParsePath(path));
	if (not d1) or (d1.ty ~= "SymLink") then return path; end
	return d1.data;
end
RDXDB.ResolvePath = ResolvePath;

--- Returns TRUE iff the name passed is valid for storage in the RDX object database,
-- NIL otherwise.
-- A valid file name is pure alphanumeric with no whitespace.
function RDXDB.IsValidFileName(x)
	if (type(x) ~= "string") or (x == "") or (x == "ty") then return nil; end
	if string.find(x, "^[%w_]+$") then return true; else return nil; end
end

-- Some words objects are now forbidden to be used (metadata package)
local reservedWords = {};
reservedWords["infoVersion"] = true;
reservedWords["infoAuthor"] = true;
reservedWords["infoAuthorRealm"] = true;
reservedWords["infoAuthorEmail"] = true;
reservedWords["infoAuthorWebSite"] = true;
reservedWords["infoComment"] = true;
reservedWords["infoIsShare"] =  true;
reservedWords["infoIsImmutable"] = true;
reservedWords["infoIsIndelible"] = true;
reservedWords["infoRunAutoexec"] = true;

function RDXDB.IsReserveWord(name)
	return reservedWords[name];
end

-- Some packages are protected
local protectedPkg = {};
protectedPkg["Builtin"] = true;
protectedPkg["Scripts"] = true;
protectedPkg["default"] = true;
protectedPkg["desktops"] = true;
protectedPkg["mediapack"] = true;

function RDXDB.IsProtectedPkg(name)
	return protectedPkg[name];
end

local function nu_iter(pkg, file, data, matchPath)
	if (data.ty == "SymLink") and (data.data == matchPath) then
		RDXDBEvents:Dispatch("OBJECT_UPDATED", pkg, file);
	end
end
--- Notify downstream processes that a file has been updated.
function RDXDB.NotifyUpdate(path)
	local pkg,obj = ParsePath(path); if (not pkg) or (not obj) then return; end
	RDXDBEvents:Dispatch("OBJECT_UPDATED", pkg, obj);
	-- All symlinks into this file are considered to be updated as well.
	RDXDB.Foreach(nu_iter, path);
end

--- Completely clear the RDX database and restart RDX. WARNING: data loss.
function RDXDB.ClearRDXDatabase()
	RDXData = {};
	ReloadUI();
end

----------------------------------------------------------------------
-- OBJECT TYPES
----------------------------------------------------------------------
-- The object-type database.
local tydb = {};

--- Register a persistent object type that can be stored in the ObjectDB.
-- Object types must provide the following methods:
-- .New(path, metadata) - Populate the metadata and data tables as appropriate for an
--    object of this type.
-- .GenerateBrowserMenu(array, path, metadata) - Generate a menu to be displayed when
--    the item is right clicked in the browser. The array is passed to the standard VFL
--    popup menu.
function RDXDB.RegisterObjectType(tbl)
	local name = tbl.name;
	if not name then VFL.print(i18n("|cFFFF0000[RDX]|r Info : Attempt to register an anonymous object type.")); return; end
	if tydb[name] then VFL.print(i18n("|cFFFF0000[RDX]|r Info : Attempt to register duplicate object type ") .. name .. "."); return; end
	tydb[name] = tbl;
end

--- Return an object type previously registered by RegisterObjectType.
function RDXDB.GetObjectType(ty)
	if not ty then return nil; end
	return tydb[ty];
end

function RDXDB._GetObjectTypes()
	return tydb;
end

-- The "Typeless" default type
RDXDB.RegisterObjectType({
	name = "Typeless";
	New = VFL.Noop;
	GenerateBrowserMenu = VFL.Noop;
});

----------------------------------------------------
-- SYMLINKS
----------------------------------------------------
-- The "SymLink" object type
local dlg = nil;
local function EditSymlink(parent, path, md)
	if dlg then
		RDX.print(i18n("A symlink editor is already open. Please close it first.")); return;
	end
	if (not path) or (not md) then return; end
	if not parent then parent = UIParent; end
	-- Create the dialog
	dlg = VFLUI.Window:new(parent);
	VFLUI.Window.SetDefaultFraming(dlg, 22);
	dlg:SetTitleColor(0,0,.6);
	dlg:SetBackdrop(VFLUI.BlackDialogBackdrop);
	dlg:SetPoint("CENTER", UIParent, "CENTER");
	dlg:SetWidth(335); dlg:SetHeight(85);
	dlg:SetText(i18n("Edit Symlink: ") .. path);
	VFLUI.Window.StdMove(dlg, dlg:GetTitleBar());
	if RDXPM.Ismanaged("symlink_editor") then RDXPM.RestoreLayout(dlg, "symlink_editor"); end

	-- Create the file picker
	local ff = RDXDB.ObjectFinder:new(dlg, function(p,f,md) return (md and type(md) == "table"); end);
	ff:SetPoint("TOPLEFT", dlg:GetClientArea(), "TOPLEFT");
	ff:SetWidth(325);
	ff:SetLabel(i18n("Link target"));
	ff:SetPath(md.data or "");
	ff:Show();
	
	-- Show the editor	
	dlg:Show(.2, true);

	---------- Destruction
	local esch = function() 
		dlg:Hide(.2, true);
		VFL.ZMSchedule(.25, function()
			RDXPM.StoreLayout(dlg, "symlink_editor");
			dlg:Destroy(); dlg = nil;
		end);
	end
	VFL.AddEscapeHandler(esch);
	local btnClose = VFLUI.CloseButton:new(dlg);
	dlg:AddButton(btnClose);
	btnClose:SetScript("OnClick", function() VFL.EscapeTo(esch); end);

	local btnOK = VFLUI.OKButton:new(dlg);
	btnOK:SetText(i18n("OK")); btnOK:SetHeight(25); btnOK:SetWidth(75);
	btnOK:SetPoint("BOTTOMRIGHT", dlg:GetClientArea(), "BOTTOMRIGHT");
	btnOK:Show();
	btnOK:SetScript("OnClick", function()
		md.data = ff:GetPath();
		VFL.EscapeTo(esch);
		RDXDB.NotifyUpdate(path);
	end);

	dlg.Destroy = VFL.hook(function(s)
		btnOK:Destroy(); btnOK = nil;
		ff:Destroy(); ff = nil;
		dlg = nil;
	end, dlg.Destroy);
end

--- Open an editor for the given symlink
function RDXDB.EditSymLink(path, parent)
	local data = AccessPathRaw(ParsePath(path));
	if not data then return; end
	parent = parent or UIParent;
	EditSymlink(parent, path, data);
end

--- Repoint the given symlink at another destination.
function RDXDB.SetSymLinkTarget(linkPath, targetPath)
	-- Sanity check
	local data = AccessPathRaw(ParsePath(linkPath));
	if (not data) or (data.ty ~= "SymLink") then return; end
	-- Update the link
	data.data = targetPath;
	-- Notify of update
	RDXDB.NotifyUpdate(linkPath);
end

RDXDB.RegisterObjectType({
	name = "SymLink";
	New = function(path, md) md.data = ""; end;
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		table.insert(mnu, {
			text = i18n("Edit...");
			OnClick = function()
				VFL.poptree:Release();
				EditSymlink(dlg, path, md);
			end;
		});
	end;
});

------------------------------------------------
-- SINGLETON INSTANCE SYSTEM
------------------------------------------------
-- The object-instance database.
local instdb, rinstdb = {}, {};

--- Determine if the given path has an instance.
function RDXDB.PathHasInstance(path)
	path = ResolvePath(path);
	if not path then return nil; end
	return instdb[path];
end

--- "Reverse-lookup" an instance of an object, returning the path it was instantiated
-- from, if possible.
function RDXDB.InstanceReverseLookup(instance)
	if not instance then return nil; end
	return rinstdb[instance];
end

-- Remove all traces of the given path from the instance db, forward and reverse.
function RDXDB._RemoveInstance(path)
	path = ResolvePath(path);
	if not path then return; end
	local i = instdb[path]; if not i then return; end
	-- If there's an instance available, and we're about to destroy it, call the type's
	-- Deinstantiate() callback.
	local md = AccessPath(ParsePath(path));
	if md then
		local ty = RDXDB.GetObjectType(md.ty);
		if ty and ty.Deinstantiate then
			ty.Deinstantiate(i, path, md);
		end
	end
	rinstdb[i] = nil; instdb[path] = nil;
end

-- Create an instance, given predefined path and type info. This should only be called after
-- it has been confirmed that an instance doesn't already exist.
local function _CreateInstance(opath, obj)
	-- Query the object's type. Check for instantiability.
	local ot = RDXDB.GetObjectType(obj.ty); if (not ot) then return nil; end
	-- Allow the overriding of default instantiation behavior.
	local oi = ot.OverrideInstantiate;
	if oi then return oi(opath, obj);	end
	-- Check for default instantiaton behavior
	oi = ot.Instantiate;
	if (not oi) then return nil; end
	-- Try to instantiate.
	local inst = oi(opath, obj); if not inst then return nil; end
	-- If successful, store in all relevant databases.
	instdb[opath] = inst;
	if not rinstdb[inst] then rinstdb[inst] = opath; end
	local tpkg, tobj = ParsePath(opath)
	RDXDBEvents:Dispatch("OBJECT_INSTANCIATED", tpkg, tobj);
	return inst;
end


--------------------------------------------------
-- PACKAGE METADATA
--------------------------------------------------
--local pkgmd = {};

--- Set a piece of metadata on a package.
--function RDXDB.SetPackageMetadata(pkg, field, val)
--	if not RDXDB.GetPackage(pkg) then return nil; end
--	if not pkgmd[pkg] then pkgmd[pkg] = {}; end
--	pkgmd[pkg][field] = val;
--	return true;
--end

-- RDX 7.1
-- Set metadata package
function RDXDB.SetPackageMetadata(pkg, field, val)
	if not RDXDB.GetPackage(pkg) then return nil; end
	if (type(val) == "table") or (type(val) == "function") then return nil; end
	if not RDXData[pkg] then RDXData[pkg] = {}; end
	RDXData[pkg][field] = val;
	RDXDBEvents:Dispatch("PACKAGE_METADATA_UPDATE", pkg);
	return true;
end

--- Get a piece of metadata about a package.
--function RDXDB.GetPackageMetadata(pkg, field)
--	if not pkgmd[pkg] then return nil; end
--	return pkgmd[pkg][field];
--end

-- RDX 7.1
-- Get metadata package
function RDXDB.GetPackageMetadata(pkg, field)
	if not pkg then return nil; end
	local qq = RDXData[pkg];
	if not qq or (type(qq[field]) == "table") then return nil; end
	return qq[field];
end

--------------------------------------------------
-- LOADING AND INITIALIZATION
--------------------------------------------------
local function InitObjectDB()
	RDX:Debug(1, "InitObjectDB()");
	-- Initialize the RDX data saved variable.
	if not RDXData then RDXData = {}; end

	--- Get a package's contents if it exists; return NIL if it doesn't
	function RDXDB.GetPackage(pkg)
		if not pkg then return nil; end
		return RDXData[pkg];
	end

	--- Get the root directory.
	function RDXDB.GetPackages()
		return RDXData;
	end

	--- Iterate a function over all files
	function RDXDB.Foreach(f, ...)
		for pkg,pd in pairs(RDXData) do
			for file,fd in pairs(pd) do
				if type(fd) == "table" then
					f(pkg, file, fd, ...);
				end
			end
		end
	end

	--- Get a package's contents, creating it if it doesn't exist.
	function RDXDB.GetOrCreatePackage(pkg, infoversion, infoname, inforealm, infoemail, infowebsite, infocomment)
		local d = RDXData[pkg];
		if not d then
			if RDXDB.CreatePackage(pkg, infoversion, infoname, inforealm, infoemail, infowebsite, infocomment) then
				return RDXData[pkg];
			else
				return nil;
			end
		end
		return d;
	end

	--- Create a package. Returns (NIL, error code) on failure.
	function RDXDB.CreatePackage(pkg, infoversion, infoname, inforealm, infoemail, infowebsite, infocomment)
		if not RDXDB.IsValidFileName(pkg) then return nil, i18n("Invalid filename. Filenames must be alphanumeric."); end
		if RDXData[pkg] then return nil, i18n("Package already exists."); end
		local d = {};
		RDXData[pkg] = d;
		if not infoversion then infoversion = "1.0.0"; end
		if not infoname then infoname = UnitName("player"); end
		if not inforealm then inforealm = GetRealmName(); end
		if not infocomment then infocomment = ""; end
		RDXDB.SetPackageMetadata(pkg, "infoVersion", infoversion);
		RDXDB.SetPackageMetadata(pkg, "infoAuthor", infoname);
		RDXDB.SetPackageMetadata(pkg, "infoAuthorRealm", inforealm);
		RDXDB.SetPackageMetadata(pkg, "infoAuthorWebSite", infowebsite);
		RDXDB.SetPackageMetadata(pkg, "infoComment", infocomment);
		RDXDBEvents:Dispatch("PACKAGE_CREATED", pkg, d);
		return true;
	end

	--- Delete a package. Fails, returning NIL, if the package is not empty.
	function RDXDB.DeletePackage(pkg, force)
		local d = RDXData[pkg];
		if not d then return true; end
		if RDXDB.GetPackageMetadata(pkg, "infoIsImmutable") or RDXDB.GetPackageMetadata(pkg, "infoIsIndelible") then
			return nil, i18n("Cannot delete indelible package.");
		end
		if (not force) and (VFL.tsize(d) > 0) then return nil, i18n("Cannot delete non-empty package."); end
		RDXData[pkg] = nil;
		RDXDBEvents:Dispatch("PACKAGE_DELETED", pkg);
		return true;
	end

	--- Empty a package.
	function RDXDB._EmptyPackage(pkg)
		local d = RDXData[pkg];
		if type(d) ~= "table" then return; end
		VFL.empty(d);
		RDXDBEvents:Dispatch("PACKAGE_MASS_CHANGE", pkg);
	end
	
	-- Return number of objects in this package
	function RDXDB.GetNumberObjects(pkg)
		local d, cp = RDXData[pkg], 0;
		if type(d) ~= "table" then return 0; end
		for file,fd in pairs(d) do
			if type(fd) == "table" then
				cp = cp + 1;
			end
		end
		return cp;
	end

	--- Check the object at the given path; verify that it exists and matches the given type
	function RDXDB.CheckObject(path, ty)
		local obj = AccessPath(ParsePath(path)); if not obj then return nil; end
		return (obj.ty == ty), obj;
	end

	--- Get the object metadata at the given path, or NIL if it doesn't exist
	function RDXDB.GetObjectData(path)
		local pkg,file = ParsePath(path);
		local fd = AccessPath(pkg, file); if not fd then return nil; end
		return fd, pkg, file, fd.ty, RDXDB.GetObjectType(fd.ty); 
	end

	--- Find an available temporary file name in the given package.
	function RDXDB.tmpnam(pkg)
		local p = RDXDB.GetPackage(pkg); if not p then return nil; end
		local i, str = 0, "unnamed";
		while p[str] do
			i=i+1; str = "unnamed" .. i;
		end
		return str;
	end

	--- Create a new object at a node where no object is.
	function RDXDB.CreateObject(pkg, file, ty)
		if (not pkg) or (not file) then return nil, i18n("Invalid path."); end
		local t = RDXDB.GetObjectType(ty);
		if (not t) or (not t.New) then return nil, i18n("Invalid object type."); end
		if (not RDXDB.IsValidFileName(file)) then return nil, i18n("Invalid filename. Filenames must be alphanumeric."); end
		if (RDXDB.IsReserveWord(file)) then return nil, i18n("Invalid filename. Filename protected."); end
		local p = RDXDB.GetPackage(pkg);
		if not p then return nil, i18n("Package does not exist."); end
		if RDXDB.GetPackageMetadata(pkg, "infoIsImmutable") then
			return nil, i18n("Cannot create object in immutable package.");
		end
		if p[file] then return nil, i18n("File already exists in package."); end
		-- Create the object
		local fmd = { ty = ty, version = 0, data = {} };
		p[file] = fmd;
		t.New(RDXDB.MakePath(pkg, file), fmd);
		RDXDBEvents:Dispatch("OBJECT_CREATED", pkg, file);
		return true;
	end

	--- Create an object, overriding most restrictions and bypassing initialization schemes.
	function RDXDB._DirectCreateObject(pkg, file)
		if (not pkg) or (not file) then return nil; end
		local p = RDXDB.GetPackage(pkg);
		if not p then return nil; end
		local fmd = { ty = "Typeless", version = 0, data = {} };
		p[file] = fmd;
		RDXDBEvents:Dispatch("OBJECT_CREATED", pkg, file);
		return fmd;
	end

	--- Delete an object.
	function RDXDB.DeleteObject(path)
		local pkg, file = ParsePath(path);
		if (not pkg) or (not file) then return nil, i18n("Invalid path."); end
		local p = RDXDB.GetPackage(pkg);
		if not p then return nil, i18n("Package does not exist."); end
		if RDXDB.GetPackageMetadata(pkg, "infoIsImmutable") then
			return nil, i18n("Cannot delete object in immutable package."); 
		end
		local qq = p[file];
		if not qq then return nil, i18n("File does not exist."); end
		if qq.virtual then return nil, i18n("Virtual files cannot be deleted."); end
		-- Perform the deletion
		RDXDB._RemoveInstance(path, qq); -- Remove any instances that are out there...
		p[file] = nil;
		RDXDBEvents:Dispatch("OBJECT_DELETED", pkg, file, qq);
		return true;
	end

	--- Rename an object.
	function RDXDB.RenameObject(path, newFileName)
		local pkg, file = ParsePath(path);
		if (not pkg) or (not file) then return nil, i18n("Invalid path."); end
		if not RDXDB.IsValidFileName(newFileName) then return nil, i18n("New filename is invalid."); end
		if RDXDB.IsReserveWord(newFileName) then return nil, i18n("New filename is invalid. (protected)"); end
		local p = RDXDB.GetPackage(pkg);
		if not p then return nil, i18n("Package does not exist."); end
		if RDXDB.GetPackageMetadata(pkg, "infoIsImmutable") then
			return nil, i18n("Cannot rename object in immutable package."); 
		end
		if p[newFileName] then
			return nil, i18n("That file already exists.");
		end
		local qq = p[file];
		if not qq then return nil, i18n("File does not exist."); end
		if qq.virtual then return nil, i18n("Virtual files cannot be renamed."); end
		-- Do the rename
		RDXDB._RemoveInstance(path);
		p[file] = nil; p[newFileName] = qq;
		RDXDBEvents:Dispatch("OBJECT_MOVED", pkg, file, pkg, newFileName, qq);
		return true;
	end

	--- Move an object.
	function RDXDB.MoveObject(path, newPkg)
		local pkg, file = ParsePath(path);
		if (not pkg) or (not file) then return nil, i18n("Invalid path."); end
		local pSrc = RDXDB.GetPackage(pkg); if not pSrc then return nil, i18n("Source package does not exist."); end
		local pDst = RDXDB.GetPackage(newPkg); if not pDst then return nil, i18n("Destination package does not exist."); end
		if RDXDB.GetPackageMetadata(pkg, "infoIsImmutable") or RDXDB.GetPackageMetadata(pDst, "infoIsImmutable") then
			return nil, i18n("Cannot modify an immutable package.");
		end
		if pDst[file] then return nil, i18n("Destination file already exists."); end
		local qq = pSrc[file]; if not qq then return nil, i18n("Source file does not exist."); end
		if qq.virtual then return nil, i18n("Virtual files cannot be moved."); end
		-- Do the move
		RDXDB._RemoveInstance(path);
		pSrc[file] = nil; pDst[file] = qq;
		RDXDBEvents:Dispatch("OBJECT_MOVED", pkg, file, newPkg, file, qq);
		return true;
	end

	--- Copy an object.
	function RDXDB.CopyObject(path, newPkg)
		local pkg,file = ParsePath(path);
		if not pkg or not file then return nil, i18n("Invalid path"); end
		return RDXDB.Copy(path, MakePath(newPkg, file), "RENAME");
	end

	--- Copies a preexisting object.
	function RDXDB.Copy(srcPath, dstPath, eh)
		if not eh then eh = "OVERWRITE"; end
		---- Source validation
		local spkg, sfile = ParsePath(srcPath);
		if(not spkg) or (not sfile) then return nil, i18n("Invalid source path."); end
		local spd = RDXDB.GetPackage(spkg); if not spd then return nil, i18n("Source package does not exist."); end
		local sfd = spd[sfile]; if not sfd then return nil, i18n("Source file does not exist."); end
		---- Destination validation
		local dpkg, dfile = ParsePath(dstPath);
		if(not dpkg) or (not dfile) then return nil, i18n("Invalid destination path."); end
		if RDXDB.GetPackageMetadata(dpkg, "infoIsImmutable") then return nil, i18n("Destination package is immutable."); end
		local dpd = RDXDB.GetOrCreatePackage(dpkg); if not dpd then return nil, i18n("Could not get destination package."); end
		local dfd = dpd[dfile];
		-- If the destination exists, typecheck vs the source
		if dfd then
			if eh == "FAIL" then 
				return nil, i18n("Destination already exists."); 
			elseif eh == "RENAME" then
				local n, ofile = 1, dfile;
				while dpd[dfile] do dfile = ofile .. "_copy" .. n; n = n + 1; end
			elseif eh == "OVERWRITE" then
				if (dfd.ty ~= sfd.ty) or (dfd.version ~= sfd.version) then return nil, i18n("Type mismatch."); end
			end
		end
		dpd[dfile] = VFL.copy(sfd);
		RDXDBEvents:Dispatch("OBJECT_CREATED", dpkg, dfile);
		return true;
	end

	--- "Touch" an object, returning a direct reference to its contents if we have the ability to
	-- update it. Automatically creates it as a typeless object if it doesn't exist.
	function RDXDB.TouchObject(path)
		local pkg, file = ParsePath(path);
		if(not pkg) or (not file) then return nil, i18n("Invalid path."); end
		local pkgData = RDXDB.GetOrCreatePackage(pkg); if not pkgData then return nil, i18n("Invalid package."); end
		-- If the file already exists, we're golden.
		local od = pkgData[file];
		if od then
			return od;
		else
			if RDXDB.GetPackageMetadata(pkg, "infoIsImmutable") then
				return nil, i18n("Cannot create object in immutable package.");
			end
			-- Create the object
			local fmd = { ty = "Typeless", version = 0 };
			pkgData[file] = fmd;
			RDXDBEvents:Dispatch("OBJECT_CREATED", pkg, file);
			return fmd;
		end
	end

	--- Get an instace of the object at the given path. If the second argument is
	-- non-NIL, the object will NOT be created if it doesn't already exist.
	function RDXDB.GetObjectInstance(path, noCreate)
		-- Symlinks to instances should resolve first.
		path = ResolvePath(path);
		-- If there's already an instance of this object, return it
		if instdb[path] then return instdb[path]; end
		-- If we're not creating, just abort
		if noCreate then return nil; end
		-- Let's find the object...
		local obj = AccessPathRaw(ParsePath(path)); 
		if (not obj) or (not obj.ty) then return nil; end
		-- OK, create an instance
		return _CreateInstance(path, obj);		
	end

	--- Run an object's Open method, if possible. If "op" is specified, runs
	-- that operation instead of the open method, with the given arguments.
	function RDXDB.OpenObject(path, op, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
		local data,_,_,_,ty = RDXDB.GetObjectData(path);
		if (not data) or (not ty) then return nil, i18n("Invalid or missing object."); end
		if not op then op = "Open"; end
		if not ty[op] then return nil, i18n("Type does not have the ") .. op .. i18n(" method"); end
		ty[op](path, data, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);
		return true;
	end

	-- Make sure the default packages exist
	RDXDB.GetOrCreatePackage("default", "1.0.0", "OpenRDX", "", "openrdx@wowinterface.com", "http://www.openrdx.com", "OpenRDX package");
	RDXDB.SetPackageMetadata("default", "infoIsIndelible", true);
	RDXDB.GetOrCreatePackage("Builtin", "1.0.0", "OpenRDX", "", "openrdx@wowinterface.com", "http://www.openrdx.com", "OpenRDX package");
	RDXDB.SetPackageMetadata("Builtin", "infoIsIndelible", true);
	RDXDB.GetOrCreatePackage("Scripts", "1.0.0", "OpenRDX", "", "openrdx@wowinterface.com", "http://www.openrdx.com", "OpenRDX package");
	RDXDB.SetPackageMetadata("Scripts", "infoIsIndelible", true);
	RDXDB.GetOrCreatePackage("desktops", "1.0.0", "OpenRDX", "", "openrdx@wowinterface.com", "http://www.openrdx.com", "OpenRDX package");
	RDXDB.SetPackageMetadata("desktops", "infoIsIndelible", true);
	-- Two-phase init
	RDX:Debug(1, "**************** INIT_DATABASE_LOADED ****************");
	RDXEvents:Dispatch("INIT_DATABASE_LOADED");
	RDXEvents:DeleteKey("INIT_DATABASE_LOADED");
	RDX:Debug(1, "**************** INIT_POST_DATABASE_LOADED ****************");
	RDXEvents:Dispatch("INIT_POST_DATABASE_LOADED");
	RDXEvents:DeleteKey("INIT_POST_DATABASE_LOADED");
end

RDXEvents:Bind("INIT_VARIABLES_LOADED", nil, InitObjectDB);

------------------------------------------------------------------
-- OBJECT VERSION MANAGEMENT
-- When WoW starts, check all objects with out-of-date descriptors, 
-- and run their VersionMismatch()
-- methods to correct the issue.
------------------------------------------------------------------
local function CheckVers(pkg, file, ty, md)
	if (ty.version ~= md.version) and ty.VersionMismatch then
		if ty.VersionMismatch(md) then 
			RDX.print(i18n("|cFF00FFFFObject Updater|r: Updating object ") .. RDXDB.MakePath(pkg,file));
			return true;
		end
	end
end

RDXEvents:Bind("INIT_DATABASE_LOADED", nil, function()
	-- Iterate over the entire FS...
	RDXDB.Foreach(function(pkg, file, md)
		local ty = RDXDB.GetObjectType(md.ty);
		if not ty then return; end
		if CheckVers(pkg, file, ty, md) then RDXDB.objupdate = true; end
	end);
end);

----------------------------------------------------------------------
-- Reload after update
----------------------------------------------------------------------

RDXDB.objupdate = nil;

RDXEvents:Bind("INIT_POST_DATABASE_LOADED", nil, function()
	if RDXDB.objupdate then
		RDX.print(i18n("Object updated, checking for UI reload."));
		VFL.ZMSchedule(2, function()
			VFLUI.MessageBox(i18n("RDX: Reload UI"), i18n("Some old RDX objects were updated. In order for these updates to take effect, your UI must be reloaded. Click Yes to reload, No to abort."), nil, i18n("No"), VFL.Noop, i18n("Yes"), ReloadUI);
		end);
		RDXDB.objupdate = nil;
	end
end);
