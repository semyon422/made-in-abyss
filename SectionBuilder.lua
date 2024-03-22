local class = require("class")
local abyss = require("abyss")
local color_height = require("color_height")
local rdpu = require("dh.RenderDataPointUtil")
local ColumnRenderSource = require("dh.ColumnRenderSource")
local DhSectionPos = require("dh.DhSectionPos")

---@class dh-render.SectionBuilder
---@operator call: dh-render.SectionBuilder
local SectionBuilder = class()

local secsize = ColumnRenderSource.SECTION_SIZE

---@param DhRenderData table
---@param clip_plane number?
function SectionBuilder:new(DhRenderData, clip_plane)
	self.DhRenderData = DhRenderData
	self.clip_plane = clip_plane or math.huge

	self.imageData = love.image.newImageData(secsize, secsize)
	self.image = love.graphics.newImage(self.imageData)
	self.image:setFilter("nearest", "nearest")
end

function SectionBuilder:getDP(crs, section_offset, x, y)
	local dp, prev_dp
	local dp_y
	for i = 0, crs:getVerticalSize() - 1 do
		prev_dp = dp
		dp = crs:getDataPoint(x, y, i)
		dp_y = rdpu:getYMax(dp) - 256
		local h = abyss.section_depth(section_offset, dp_y)
		if h < self.clip_plane then
			if i == 0 then
				return dp
			elseif rdpu:getYMin(prev_dp) > rdpu:getYMax(dp) then
				return dp
			end
		end
	end
end

function SectionBuilder:getColor(x, y, crs, section_offset)
	local dp = self:getDP(crs, section_offset, x, y)
	if not dp then
		return 0, 0, 0, 0
	end

	local r = rdpu:getRed(dp) / 255
	local g = rdpu:getGreen(dp) / 255
	local b = rdpu:getBlue(dp) / 255
	local a = rdpu:getAlpha(dp) / 255
	-- a = a * (rdpu:getLightBlock(dp) / 15 * 0.3 + 0.7)
	if a > 0.1 then
		a = 1
	end

	return r, g, b, a
end

function SectionBuilder:getHeight(x, y, crs, section_offset)
	local dp = self:getDP(crs, section_offset, x, y)
	if not dp then
		return 0, 0, 0, 0
	end

	local _h = rdpu:getYMax(dp) - 256
	local h = abyss.section_depth(section_offset, _h)
	local r, g, b = color_height.color(h)
	local a = 1
	if _h == -256 then
		a = 0
	end
	return r, g, b, a
end

function SectionBuilder:fillImage(dsp, _type)
	local det, sx, sz = DhSectionPos:decode(dsp)

	local row = self.DhRenderData:find({DhSectionPos = dsp})
	if not row then
		return
	end

	local crs = ColumnRenderSource()
	crs:readDataV1(row)

	local section_offset = abyss.section_offset(sx * 64)

	local method_name = _type == "color" and "getColor" or "getHeight"
	local method = self[method_name]

	self.imageData:mapPixel(function(x, y)
		return method(self, x, y, crs, section_offset)
	end)
	self.image:replacePixels(self.imageData)

	return self.image
end

return SectionBuilder
