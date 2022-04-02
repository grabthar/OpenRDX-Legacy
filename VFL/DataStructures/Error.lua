-- Error.lua
-- VFL
-- (C)2006 Bill Johnson and The VFL Project
--
-- A hierarchical error handling scheme.

VFL.Error = {};
VFL.Error.__index = VFL.Error;

function VFL.Error:new()
	local x = {};
	x.errors = {};
	x.count = 0;
	x.context = nil;
	setmetatable(x, VFL.Error);
	return x;
end

function VFL.Error:AddError(msg)
	if not msg then return; end
	self.count = self.count + 1;
	if self.context then
		table.insert(self.errors, self.context .. ":" .. msg);
	else
		table.insert(self.errors, msg);
	end
end

function VFL.Error:SetContext(ctx)
	self.context = ctx;
end

function VFL.Error:Count() return self.count; end

function VFL.Error:HasErrors() return (self.count > 0); end
VFL.Error.HasError = VFL.Error.HasErrors;

function VFL.Error:Clear()
	VFL.empty(self.errors); self.count = 0; self.context = nil;
end

function VFL.AddError(errs, msg)
	if errs then errs:AddError(msg); end
end
function VFL.HasError(errs)
	if errs then return errs:HasErrors(); else return nil; end
end

function VFL.Error:FormatErrors_SingleLine()
	local str = "";
	for _,err in pairs(self.errors) do
		str = str .. err .. "; ";
	end
	return str;
end

function VFL.Error:DumpToChat(msg)
	msg = msg or "Errors:";
	VFL.print(msg);
	VFL.print("------------");
	for _,err in ipairs(self.errors) do
		VFL.print(err);
	end
end

function VFL.Error:ToErrorHandler(context, msg)
	local s = "";
	for _,err in ipairs(self.errors) do s = s .. err .. "\n"; end
	VFL.TripError(context, msg, s);
end

function VFL.Error:ErrorTable()
	return self.errors;
end

--- A global error object to save memory.
-- USE WITH CAUTION! WHEN IN DOUBT, JUST MAKE A NEW ONE.
vflErrors = VFL.Error:new();
