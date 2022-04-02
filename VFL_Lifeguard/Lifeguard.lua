-- Rewrite Blizzard's EnumerateFrames() so it doesn't touch VFL frames.
local _EnumerateFrames = EnumerateFrames;

function EnumerateFrames(x)
	x = _EnumerateFrames(x);
	while x and x._VFL do x = _EnumerateFrames(x); end
	return x;
end

--[[
function listframes()
local frame = EnumerateFrames()
while frame do
    if frame:IsVisible() and MouseIsOver(frame) then
        DEFAULT_CHAT_FRAME:AddMessage(frame:GetName())
    end
    frame = EnumerateFrames(frame)
end

end
]]

