local ffi = require("ffi")
local class = require("class")
local byte = require("byte_new")
local lz4f = require("lz4f")

---@class dh.ColumnRenderSource
---@operator call: dh.ColumnRenderSource
local ColumnRenderSource = class()

ColumnRenderSource.SECTION_MINIMUM_DETAIL_LEVEL = 6
ColumnRenderSource.SECTION_SIZE_OFFSET = ColumnRenderSource.SECTION_MINIMUM_DETAIL_LEVEL
ColumnRenderSource.SECTION_SIZE = 2 ^ ColumnRenderSource.SECTION_SIZE_OFFSET

ColumnRenderSource.DATA_GUARD_BYTE = -1
ColumnRenderSource.NO_DATA_FLAG_BYTE = 1

function ColumnRenderSource:readDataV1(dto)
	local data = lz4f.decompress(dto.Data)
	local buf = byte.buffer(#data):fill(data):seek(0)

	self.detailLevel = buf:int8()
	self.verticalDataCount = buf:int32_be()

	local maxNumberOfDataPoints = self.SECTION_SIZE ^ 2 * self.verticalDataCount

	local dataPresentFlag = buf:int8()
	if dataPresentFlag ~= self.NO_DATA_FLAG_BYTE and dataPresentFlag ~= self.DATA_GUARD_BYTE then
		error("Incorrect render file format: " .. dataPresentFlag)
	elseif dataPresentFlag == self.NO_DATA_FLAG_BYTE then
		error("no data")
	end

	self.fileYOffset = buf:int32_be()

	local dataPoints = ffi.new("int64_t[?]", maxNumberOfDataPoints)
	assert(buf.offset + maxNumberOfDataPoints * 8 < buf.size)
	ffi.copy(dataPoints, buf.pointer + buf.offset, maxNumberOfDataPoints * 8)
	buf:seek(buf.offset + maxNumberOfDataPoints * 8)

	local guardByteFlag = buf:int8()
	if guardByteFlag ~= self.DATA_GUARD_BYTE then
		error("invalid world gen step end guard")
	end

	self.worldGenStep = buf:int8()

	assert(buf.size == buf.offset)

	self.dataPoints = dataPoints
end

function ColumnRenderSource:getFirstDataPoint(posX, posZ)
	return self:getDataPoint(posX, posZ, 0)
end

function ColumnRenderSource:getDataPoint(posX, posZ, verticalIndex)
	local vdc = self.verticalDataCount
	return self.dataPoints[posX * self.SECTION_SIZE * vdc + posZ * vdc + verticalIndex]
end

function ColumnRenderSource:getVerticalDataPointArray(posX, posZ)
	local result = ffi.new("int64_t[?]", self.verticalDataCount)
	local index = posX * self.SECTION_SIZE * self.verticalDataCount + posZ * self.verticalDataCount
	ffi.copy(result, self.dataPoints + index, self.verticalDataCount * 8)
	return result
end

function ColumnRenderSource:getVerticalDataPointView(posX, posZ)
	-- return ColumnArrayView(self.dataPoints, self.verticalDataCount,
	-- 		posX * self.SECTION_SIZE * self.verticalDataCount + posZ * self.verticalDataCount,
	-- 		self.verticalDataCount)
end

function ColumnRenderSource:getFullQuadView()
	return self:getQuadViewOverRange(0, 0, self.SECTION_SIZE, self.SECTION_SIZE)
end

function ColumnRenderSource:getQuadViewOverRange(quadX, quadZ, quadXSize, quadZSize)
	return ColumnQuadView(self.dataPoints, self.SECTION_SIZE, self.verticalDataCount, quadX, quadZ, quadXSize, quadZSize)
end

function ColumnRenderSource:getVerticalSize()
	return self.verticalDataCount
end

return ColumnRenderSource
