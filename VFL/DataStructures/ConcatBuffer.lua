-- ConcatBuffer.lua
-- VFL
--
-- An implementation of Roberto Ierusalimschy's fast string concatenation
-- buffer scheme at
--    http://www.lua.org/notes/ltn009.html


ConcatBuffer = {};

local tinsert, tremove, strlen = table.insert, table.remove, string.len;

function ConcatBuffer.new() return {}; end

function ConcatBuffer.append(buf, str)
	tinsert(buf, str);
	for i=(#buf - 1), 1, -1 do
		if strlen(buf[i]) > strlen(buf[i+1]) then break; end
		buf[i] = buf[i] .. tremove(buf);
	end
end

function ConcatBuffer.toString(buf)
	for i=(#buf - 1), 1, -1 do
		buf[i] = buf[i] .. tremove(buf);
	end
	return buf[1];
end

