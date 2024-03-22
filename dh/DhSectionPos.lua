local class = require("class")

---@class dh.DhSectionPos
---@operator call: dh.DhSectionPos
local DhSectionPos = class()

function DhSectionPos:decode(s)
	local detailLevel, x, z = s:match("%[(.+),(.+),(.+)%]")
	return tonumber(detailLevel), tonumber(x), tonumber(z)
end

function DhSectionPos:encode(detailLevel, x, z)
	return ("[%s,%s,%s]"):format(detailLevel, x, z)
end

return DhSectionPos
