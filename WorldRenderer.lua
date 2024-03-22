local class = require("class")

---@class dh-render.WorldRenderer
---@operator call: dh-render.WorldRenderer
local WorldRenderer = class()

---@param worldBuilder dh-render.WorldBuilder
function WorldRenderer:new(worldBuilder)
	self.worldBuilder = worldBuilder

	local imageData = love.image.newImageData(1, 1)
	imageData:setPixel(0, 0, 1, 1, 1, 1)
	self.image = love.graphics.newImage(imageData)
	self.image:setFilter("nearest", "nearest")

	self.sunPos = {0, 0, 1}
end

function WorldRenderer:load()
	self.shader = love.graphics.newShader("pixel_shader.glsl")
end

function WorldRenderer:setSunPos(x, y)
	self.sunPos[1] = x
	self.sunPos[2] = y
end

function WorldRenderer:draw()
	local worldBuilder = self.worldBuilder
	local shader = self.shader

	love.graphics.setColor(1, 1, 1, 1)
	local w, h = worldBuilder.colorCanvas:getDimensions()
	-- local w, h = love.graphics.getDimensions()

	love.graphics.setShader(shader)
	shader:send("colormap", worldBuilder.colorCanvas)
	shader:send("heightmap", worldBuilder.heightCanvas)
	shader:send("sunPos", self.sunPos)

	local max_dim = math.max(w, h)

	love.graphics.draw(self.image, -max_dim / 2, -max_dim / 2, 0, max_dim, max_dim)

	love.graphics.setShader()
end

return WorldRenderer
