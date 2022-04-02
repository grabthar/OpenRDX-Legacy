-- DispatchTable.lua
-- VFL
-- (C)2006 Bill Johnson and The VFL Project
--
VFL:Debug(1, "Loading DispatchTable.lua");

local tinsert, tremove = table.insert, table.remove;

------------------------------------------------------------------------
-- @class Signal
--
-- A Signal is a device for calling methods in sequence. Usually called
-- to handle an outside stimulus and allow multiple procedures to gain
-- input from the stimulus.
--
-- Each Signal can have optional event handling methods attached to it
-- which will be called when certain things happen. The available methods are
--
-- @field OnEmpty signal:OnEmpty() is called when the signal becomes empty.
-- @field OnNonEmpty signal:OnNonEmpty() is called when the signal becomes nonempty.
------------------------------------------------------------------------
Signal = {};
Signal.__index = Signal;
VFLKernelRegisterCategory("Signal");

--- Create a new, empty signal.
function Signal:new()
	-- Initialize the signal to empty.
	local self = {};
	self.name = "(anonymous)";
	self.metadata = {};
	setmetatable(self, Signal);

	return self;
end

--- Test the signal for emptiness.
-- @return TRUE iff the signal is empty.
function Signal:IsEmpty()
	if #self > 0 then return nil; else return true; end
end

--- Actuate the signal, calling all bound methods.
-- All the arguments are passed directly onto the called methods.
function Signal:Raise(...)
	for _,hsig in ipairs(self) do	hsig(...); end
end

--- Connect a method to this signal.
-- @param obj The object to bind, or nil for a standalone method.
-- @param method The method to bind. This can either be a function (in which case the function will be invoked directly) or a string (in which case the function will be looked up)
-- @param id Optional - An ID that can be later used to unbind this object.
-- @return a handle to the connection that can be later used to manipulate it.
function Signal:Connect(obj, method, id)
	-- Verify method
	if (type(obj) == "table") and (type(method) == "string") then method = obj[method]; end
	if (type(method) ~= "function") then return nil; end
	-- Add to chain
	tinsert(self, VFL.WrapInvocation(obj, method));
	local hsig = {id = id, obj = obj, method = method};
	tinsert(self.metadata, hsig);
	-- Fire Nonempty handler if applicable
	if self.OnNonEmpty and (#self == 1) then self:OnNonEmpty(); end
	return hsig;
end

--- Determine if an ID is connected to this signal.
function Signal:IsIDConnected(id)
	if not id then return; end
	local md = self.metadata;
	for i=1,#self do if md[i].id == id then return true; end end
end

--- Disconnect an object or method from this signal using the handle returned by Connect()
-- @param handle A handle returned by a previous call to Signal:Connect().
function Signal:DisconnectByHandle(handle)
	if not handle then return; end
	local md = self.metadata;
	local n,i = #self, 1; if(n == 0) then return; end
	while (i<=n) do
		if (md[i] == handle) then tremove(self, i); tremove(md, i);	n=n-1; else i=i+1; end
	end
	-- Fire Empty handler if applicable
	if self.OnEmpty and (n == 0) then self:OnEmpty(); end
end

--- Disconnect an object or method from this signal matching the given ID.
-- @param id An ID used in Signal:Connect() to connect a method to this signal.
function Signal:DisconnectByID(id)
	if not id then return; end
	local md = self.metadata;
	local n,i = #self, 1; if (n == 0) then return; end
	while (i<=n) do
		if (md[i].id == id) then tremove(self, i);	tremove(md, i);	n=n-1; else i=i+1; end
	end
	-- Fire Empty handler if applicable
	if self.OnEmpty and (n == 0) then self:OnEmpty(); end
end

--- Disconnect an object or method from this signal by object or method
-- pointer.
-- @param targ The object or method to be disconnected. If targ is a function, all bindings with matching
-- functions will be removed. If targ is a nonfunction, all bindings with matching objects will be removed.
function Signal:Disconnect(targ)
	local n,i = #self, 1; if (n == 0) or (not targ) then return; end
	local field = "obj"; if type(targ) == "function" then field = "method"; end
	local md = self.metadata;
	while(i <= n) do
		if (md[i][field] == targ) then tremove(self, i); tremove(md, i); n=n-1; else i=i+1; end
	end
	-- Fire Empty handler if applicable
	if self.OnEmpty and (n == 0) then self:OnEmpty(); end
end

--- Remove all objects from this signal.
function Signal:DisconnectAll()
	if(#self == 0) then return; end
	-- Quash all connected objects.
	for k,_ in ipairs(self) do self[k] = nil; end
	local md = self.metadata;
	for k,_ in ipairs(md) do md[k] = nil; end
	-- Fire Empty handler if applicable
	if self.OnEmpty then self:OnEmpty(); end
end

----------------------------------------------------------------------------
-- @class DispatchTable
--
-- A dispatch table is a keyed table of signals that can be Connected and Raised
-- by key.
--
-- The DispatchTable can have optional event handling methods that are triggered
-- when certain things happen.
--
-- @field OnCreateKey dt:OnCreateKey(key, signal) is called whenever a new key is created.
--  Should return TRUE if the key creation should be allowed to proceed, NIL if not.
-- @field OnDeleteKey dt:OnDeleteKey(key, signal) is called whenever a key is deleted.
----------------------------------------------------------------------------
DispatchTable = {};

-- The metatable for dispatch tables
local DispatchPrototype = {};

local DispatchMeta = {};
DispatchMeta.__index = DispatchPrototype;

-- Automatic key deleter submethod.
local function _DeleteAssociatedKey(sig)
	sig._dt_parent:DeleteKey(sig._dt_key);
end

--- Get the signal associated to the given key, creating it if it does not exist.
-- @param key The key to acquire.
-- @return The signal at the key, or NIL if the action is impossible.
function DispatchPrototype:GetSignal(key)
	-- Sanity check
	if not key then return nil; end
	-- If the key already exists, just return the signal
	local sig = self.dtbl[key];
	if sig then return sig; end
	-- If not, create a new key
	sig = Signal:new();
	-- Name the signal
	sig.name = tostring(key); sig._dt_key = key; sig._dt_parent = self;
	-- Honor the OnCreateKey contract
	if self.OnCreateKey then
		if not self:OnCreateKey(key, sig) then return nil; end
	end
	-- Bind the signal's OnEmpty handler to a function that will auto-destroy the signal
	sig.OnEmpty = _DeleteAssociatedKey;
	-- Store the new signal and return it
	self.dtbl[key] = sig;
	return sig;
end

--- "Lock" the signal associated with this key, preventing it from being auto deleted
-- when it becomes empty. This can be used to make commonly-dispatched events more
-- efficient.
function DispatchPrototype:LockSignal(key)
	local sig = self:GetSignal(key);
	sig.OnEmpty = nil;
	return sig;
end

--- Delete the signal at the given key. Don't call this unless you're sure you know what
-- you're doing. The normal method for removing dispatch entries is via proper use of :Bind(id)
-- and :Unbind(id).
-- @param key The key to destroy.
function DispatchPrototype:DeleteKey(key)
	local sig = self.dtbl[key];
	if not sig then return; end
	if self.OnDeleteKey then
		self:OnDeleteKey(key, sig);
	end
	self.dtbl[key] = nil;
end

--- Create a new binding on this dispatch table.
-- @see Signal:Connect
-- @param key The key to which the new binding should be associated.
-- @param object The object on which the binding will be invoked.
-- @param method The method that will be invoked when the binding is activated.
-- @param id Optional - An ID that can be used later to unbind this object.
-- @return If successful, a handle which can be later used with UnbindByHandle. If failed, NIL.
function DispatchPrototype:Bind(key, object, method, id)
	-- Get the signal associated with the key, creating if necessary
	local sig = self:GetSignal(key);
	if not sig then return nil; end
	-- Bind
	return sig:Connect(object, method, id);
end

--- Remove bindings from this dispatch table by ID.
-- @param id The ID used with DispatchTable:Bind(), all instances of which will be unbound.
-- @param event Optional - If provided, unbind the specific event only. ID must also match.
function DispatchPrototype:Unbind(id, event)
	if not event then
		for _,sig in pairs(self.dtbl) do
			sig:DisconnectByID(id);
		end
	else
		local sig = self.dtbl[event];
		if sig then sig:DisconnectByID(id); end
	end
end

--- Remove bindings from this dispatch table by handle.
-- @param handle The handle returned by DispatchTable:Bind(), which will be unbound.
function DispatchPrototype:UnbindByHandle(handle)
	for _,sig in pairs(self.dtbl) do
		sig:DisconnectByHandle(handle);
	end
end

--- Determine whether something with the given id is bound to the given key.
function DispatchPrototype:IsBound(key, id)
	local sig = self:GetSignal(key);
	if not sig then return; end
	return sig:IsIDConnected(id);
end

--- Make a dispatch.
-- @param key The key to dispatch on. The remaining arguments are passed along as arguments to
-- the dispatch.
function DispatchPrototype:Dispatch(key, ...)
	local sig = self.dtbl[key]; if not sig then return; end
	for _,hsig in ipairs(sig) do hsig(...);	end
end
local _Dispatch = DispatchPrototype.Dispatch;

--- Make a dispatch if enough time has passed.
-- @param dt A time in seconds that must have passed since the last latched dispatch
-- or this dispatch is ignored
-- @param key The key to dispatch on. The remaining arguments are passed along as arguments to
-- the dispatch.
-- @return TRUE iff the dispatch was performed.
function DispatchPrototype:LatchedDispatch(dt, key, ...)
	local elapsed;
	local x,t = self.lasttime, GetTime();
	if not x then x = {}; self.lasttime = x; end
	if not ( (t - (x[key] or 0)) >= dt ) then return; end
	x[key] = t;
	local sig = self.dtbl[key];	if not sig then return; end
	for _,hsig in ipairs(sig) do hsig(...); end
	return true;
end

--- Force all dispatches to pass through the given debug provider.
-- Passing nil as provider removes any debugging.
-- @param prov The debug provider through which dispatches should flow.
-- @param level The debug level to use.
function DispatchPrototype:DebugDispatches(prov, level)
	if not prov then self.Dispatch = nil; end
	self.Dispatch = function(self, key, ...)
		prov:Debug(level, self.name, "> ", tostring(key), "(", tostring(select(1,...)), ",", tostring(select(2,...)), ",", tostring(select(3,...)), ", ...)")
		_Dispatch(self, key, ...);
	end
end

--- @return A new, empty dispatch table.
function DispatchTable:new()
	local self = {};
	self.dtbl = {}; self.name = "(anonymous)";
	setmetatable(self, DispatchMeta);

	return self;
end

local function RegisterAdapter(frame, key) frame:RegisterEvent(key); return true; end
local function UnregisterAdapter(frame, key) frame:UnregisterEvent(key); return true; end
--- Convert a frame into a dispatch table. Slightly faster than maintaining a separate dispatch table;
-- also has the advantage of supporting native event args.
-- This operation CANNOT be reversed; once a frame is subsumed it is permanently so.
function DispatchTable:SubsumeFrame(frame)
	frame.dtbl = {}; frame.name = "(anonymous)";
	VFL.mixin(frame, DispatchPrototype);
	frame.OnCreateKey = RegisterAdapter;
	frame.OnDeleteKey = UnregisterAdapter;
	frame:SetScript("OnEvent", frame.Dispatch);
end
