local color_height = {}

function color_height.color(y)
	y = y + 256 * 128
	local r, g = y % 256, math.floor(y / 256) % 256
	return r / 255, g / 255, 1, 1
end

function color_height.height(r, g, b, a)
	return (r + g * 256) * 255 - 256 * 128
end

assert(color_height.height(color_height.color(0)) == 0)
assert(color_height.height(color_height.color(127)) == 127)
assert(color_height.height(color_height.color(255)) == 255)
assert(color_height.height(color_height.color(256)) == 256)
assert(color_height.height(color_height.color(256 + 127)) == 256 + 127)
assert(color_height.height(color_height.color(511)) == 511)
assert(color_height.height(color_height.color(512)) == 512)

assert(color_height.height(color_height.color(-127)) == -127)
assert(color_height.height(color_height.color(-255)) == -255)
assert(color_height.height(color_height.color(-256)) == -256)
assert(color_height.height(color_height.color(-256 - 127)) == -256 - 127)
assert(color_height.height(color_height.color(-511)) == -511)
assert(color_height.height(color_height.color(-512)) == -512)

return color_height
