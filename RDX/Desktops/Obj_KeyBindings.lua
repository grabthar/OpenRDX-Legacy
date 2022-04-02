-- Obj_ActionBindings.lua
-- OpenRDX
--
-- Code from SpellBinder by Nymbia

RDXKB = RegisterVFLModule({
	name = "RDXKB";
	title = i18n("RDX Key Bindings Object");
	description = i18n("RDX Desktop GUI Editor");
	version = {1,0,0};
	parent = RDX;
});

---------------------------------------------------------
-- Helpers
---------------------------------------------------------

local currentKeyBindings = nil;
local currentpath = nil;

local keys = {
	'ESCAPE', "`", 'TAB', '²', 'SPACE', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'A', 'S',
	'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '-', '=', '[', ']', ')',
	'\\', ';', "'", '.', '/', ',', 'ENTER', 'MOUSEWHEELUP', 'MOUSEWHEELDOWN', 'BACKSPACE', 'DELETE',
	'INSERT', 'HOME', 'END', 'PAGEUP', 'PAGEDOWN', 'NUMLOCK', 'NUMPADSLASH', 'NUMPADMULTIPLY', 'NUMPADMINUS',
	'NUMPADPLUS', 'NUMPADENTER', 'NUMPADPERIOD',
}
for i = 0, 9 do
	keys[#keys+1] = tostring(i);
	keys[#keys+1] = 'NUMPAD' .. i;
end
for i = 1, 12 do
	keys[#keys+1] = 'F' .. i;
end
for i = 1, 5 do
	keys[#keys+1] = 'BUTTON' .. i;
end

local modifiers = {
	'', 'ALT-', 'CTRL-', 'SHIFT-', 'ALT-CTRL-', 'ALT-SHIFT-', 'CTRL-SHIFT-', 'ALT-CTRL-SHIFT-',
}

local function SaveKeyBindings(keylist)
	for _, modifier in ipairs(modifiers) do
		for _, key in ipairs(keys) do
			local action = GetBindingAction(modifier..key);
			if action and action ~= "" then
				keylist[modifier..key] = action;
			end
		end
	end
end

local function LoadKeyBindings(keylist)
	for k, v in pairs(keylist) do
		local key1, key2 = GetBindingKey(v);
		if key1 then SetBinding(key1); end
		if key2 then SetBinding(key2); end
		SetBinding(k, v);
	end
	if GetCurrentBindingSet() then
		SaveBindings(GetCurrentBindingSet());
	end
end

--------------------------------------------------------
-- KeyBindings object
--------------------------------------------------------

RDXKB.KeyBindings = {};
function RDXKB.KeyBindings:new(parent)
	local self = VFLUI.AcquireFrame("Frame");
	if not parent then parent = UIParent; end
	self:SetParent(parent);
	
	function self:LoadKB(keylist)
		LoadKeyBindings(keylist);
	end
	
	function self:SaveKB(keylist)
		SaveKeyBindings(keylist);
	end
	
	self.Destroy = VFL.hook(function(s)
		s.LoadKB = nil; s.SaveKB = nil
	end, self.Destroy);
	
	return self;
end

local function EditKeyBindings(path, md, parent)
	--TODO
end

-- The Window object type.
RDXDB.RegisterObjectType({
	name = "KeyBindings",
	version = 1,
	New = function(path, md)
		md.version = 1;
		md.data = {};
		SaveKeyBindings(md.data);
	end,
	Edit = function(path, md, parent)
		if currentpath == path then
			EditKeyBindings(path, md, parent);
		else
			RDX.printW("Edit only active KB");
		end
	end,
	Instantiate = function(path, obj)
		if currentKeyBindings then RDX.print("a key bindings is already instantiated"); return nil; end
		local kb = RDXKB.KeyBindings:new(parent);
		-- Set the path
		kb._path = path;
		currentpath = path;
		-- Setup desktop
		kb:LoadKB(obj.data);
		return kb;
	end,
	Deinstantiate = function(instance, path, obj, nosave)
		if not nosave then instance:SaveKB(obj.data); end
		instance:Destroy();
		instance._path = nil;
		instance = nil;
	end,
	GenerateBrowserMenu = function(mnu, path, md, dlg)
		--table.insert(mnu, {
		--	text = i18n("Edit..."),
		--	OnClick = function()
		--		VFL.poptree:Release();
		--		RDXDB.OpenObject(path, "Edit", md);
		--	end
		--});
	end,
});

