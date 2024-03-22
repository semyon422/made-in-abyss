local class = require("class")
local bit = require("bit")

---@class dh.RenderDataPointUtil
---@operator call: dh.RenderDataPointUtil
local RenderDataPointUtil = class()

local EMPTY_DATA = 0
local MAX_WORLD_Y_SIZE = 4096

local ALPHA_DOWNSIZE_SHIFT = 4

local IRIS_BLOCK_MATERIAL_ID_SHIFT = 60

local COLOR_SHIFT = 32
local BLUE_SHIFT = COLOR_SHIFT
local GREEN_SHIFT = BLUE_SHIFT + 8
local RED_SHIFT = GREEN_SHIFT + 8
local ALPHA_SHIFT = RED_SHIFT + 8

local HEIGHT_SHIFT = 20
local DEPTH_SHIFT = 8
local BLOCK_LIGHT_SHIFT = 4
local SKY_LIGHT_SHIFT = 0

local ALPHA_MASK = 0xF
local RED_MASK = 0xFF
local GREEN_MASK = 0xFF
local BLUE_MASK = 0xFF
local COLOR_MASK = 0xFFFFFF
local HEIGHT_MASK = 0xFFF
local DEPTH_MASK = 0xFFF
local HEIGHT_DEPTH_MASK = 0xFFFFFF
local BLOCK_LIGHT_MASK = 0xF
local SKY_LIGHT_MASK = 0xF
local IRIS_BLOCK_MATERIAL_ID_MASK = 0xF
local COMPARE_SHIFT = 0b111

local HEIGHT_SHIFTED_MASK = bit.lshift(HEIGHT_MASK, HEIGHT_SHIFT)
local DEPTH_SHIFTED_MASK = bit.lshift(DEPTH_MASK, DEPTH_SHIFT)

local VOID_SETTER = bit.bor(HEIGHT_SHIFTED_MASK, DEPTH_SHIFTED_MASK)

function RenderDataPointUtil:getYMax(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, HEIGHT_SHIFT), HEIGHT_MASK))
end
function RenderDataPointUtil:getYMin(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, DEPTH_SHIFT), DEPTH_MASK))
end

function RenderDataPointUtil:getAlpha(dataPoint)
	return tonumber(bit.bor(bit.lshift(bit.band(bit.rshift(dataPoint, ALPHA_SHIFT), ALPHA_MASK), ALPHA_DOWNSIZE_SHIFT), 0b1111))
end
function RenderDataPointUtil:getRed(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, RED_SHIFT), RED_MASK))
end
function RenderDataPointUtil:getGreen(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, GREEN_SHIFT), GREEN_MASK))
end
function RenderDataPointUtil:getBlue(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, BLUE_SHIFT), BLUE_MASK))
end

function RenderDataPointUtil:getLightSky(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, SKY_LIGHT_SHIFT), SKY_LIGHT_MASK))
end
function RenderDataPointUtil:getLightBlock(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, BLOCK_LIGHT_SHIFT), BLOCK_LIGHT_MASK))
end

function RenderDataPointUtil:getBlockMaterialId(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, IRIS_BLOCK_MATERIAL_ID_SHIFT), IRIS_BLOCK_MATERIAL_ID_MASK))
end

function RenderDataPointUtil:isVoid(dataPoint)
	return tonumber(bit.band(bit.rshift(dataPoint, DEPTH_SHIFT), HEIGHT_DEPTH_MASK) == 0)
end

function RenderDataPointUtil:doesDataPointExist(dataPoint)
	return dataPoint ~= EMPTY_DATA
end

function RenderDataPointUtil:toString(dataPoint)
	if not self:doesDataPointExist(dataPoint) then
		return "null"
	elseif self:isVoid(dataPoint) then
		return "void"
	else
		return ("Y+:%s Y-:%s argb:%s %s %s %s BL:%s SL:%s BID:%s"):format(
			self:getYMax(dataPoint),
			self:getYMin(dataPoint),
			self:getAlpha(dataPoint),
			self:getRed(dataPoint),
			self:getGreen(dataPoint),
			self:getBlue(dataPoint),
			self:getLightBlock(dataPoint),
			self:getLightSky(dataPoint),
			self:getBlockMaterialId(dataPoint)
		)
	end
end


return RenderDataPointUtil
