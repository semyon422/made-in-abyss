local class = require("class")
local color_height = require("color_height")
local ColumnRenderSource = require("dh.ColumnRenderSource")
local DhSectionPos = require("dh.DhSectionPos")

---@class dh-render.WorldBuilder
---@operator call: dh-render.WorldBuilder
local WorldBuilder = class()

local detail_level = 6
local secsize = ColumnRenderSource.SECTION_SIZE

---@param w number
---@param h number
---@param sectionBuilder dh-render.SectionBuilder
function WorldBuilder:new(w, h, sectionBuilder)
	self.width = w
	self.height = h
	self.sectionBuilder = sectionBuilder
end

local scale = 1
local dist = 32

function WorldBuilder:getHeightAt(x, z)
	local w, h = self.heightImageData:getDimensions()
	local r, g, b, a = self.heightImageData:getPixel(x % w, z % h)
	return color_height.height(r, g, b, a)
end

function WorldBuilder:drawSections(sox, soy, key)
	for sx = -dist + sox, dist - 1 + sox do
		for sy = -dist + soy, dist - 1 + soy do
			local image = self.sectionBuilder:fillImage(DhSectionPos:encode(detail_level, sx, sy), key)
			if image then
				love.graphics.draw(
					image,
					((sx - sox) * secsize) * scale,
					((sy - soy) * secsize) * scale,
					0, scale, scale
				)
			end
		end
	end
end

function WorldBuilder:drawSectionsStacked(a, b, key)
	for i = b, a, -1 do
		self:drawSections(i * 2 ^ (14 - detail_level), 0, key)
	end
end

function WorldBuilder:build(a, b)
	local w, h = self.width, self.height

	self.colorCanvas = love.graphics.newCanvas(w, h)
	self.heightCanvas = love.graphics.newCanvas(w, h)
	self.colorCanvas:setFilter("nearest", "nearest")
	self.heightCanvas:setFilter("nearest", "nearest")

	love.graphics.translate(w / 2, h / 2)

	love.graphics.setCanvas(self.colorCanvas)
	self:drawSectionsStacked(a, b, "color")
	love.graphics.setCanvas(self.heightCanvas)
	self:drawSectionsStacked(a, b, "height")
	love.graphics.setCanvas()

	self.heightImageData = self.heightCanvas:newImageData()
	self.colorImageData = self.colorCanvas:newImageData()
end

function WorldBuilder:saveToFiles(color_file_name, height_color_name)
	local f = assert(io.open(height_color_name, "wb"))
	f:write(self.heightImageData:encode("png"):getString())
	f:close()

	f = assert(io.open(color_file_name, "wb"))
	f:write(self.colorImageData:encode("png"):getString())
	f:close()
end

function WorldBuilder:loadFromFiles(color_file_name, height_color_name)
	self.colorImageData = love.image.newImageData(color_file_name)
	self.heightImageData = love.image.newImageData(height_color_name)
	self.colorCanvas = love.graphics.newImage(self.colorImageData)
	self.heightCanvas = love.graphics.newImage(self.heightImageData)
	self.colorCanvas:setFilter("nearest", "nearest")
	self.heightCanvas:setFilter("nearest", "nearest")
end

return WorldBuilder
