local abyss = {}

abyss.wy = -256
abyss.wh = 512
abyss.dx = 16384
abyss.dy = 480
abyss.overlap = 32

-- world to abyss

function abyss.section_offset(x)
	local section = math.floor(x / abyss.dx + 0.5)
	x = abyss.dx * ((x / abyss.dx + 0.5) % 1 - 0.5)
	return section, x
end

function abyss.section_depth(section, y)
	return y - section * abyss.dy
end

function abyss.abyss_coords(x, y)
	local l, _x = abyss.section_offset(x)
	local _y = abyss.section_depth(l, y)
	return _x, _y
end

-- abyss to world

function abyss.inv_section_offset(section, x)
	return section * abyss.dx + x
end

function abyss.inv_section_depth(section, y)
	return abyss.section_depth(section, -y)
end

function abyss.belongs_to_section(section, y)
	if section == 0 and y > 0 then
		return true
	end
	local min_y = abyss.section_depth(section, abyss.wy)
	local max_y = abyss.section_depth(section, abyss.wy + abyss.wh)
	return y >= min_y and y < max_y
end

function abyss.sections(y)
	local sections = {}
	for s = 0, 14 do
		if abyss.belongs_to_section(s, y) then
			table.insert(sections, s)
		end
	end
	return sections
end

function abyss.world_coords(x, y)
	local coords = {}
	for i, section in ipairs(abyss.sections(y)) do
		coords[i] = {
			abyss.inv_section_offset(section, x),
			abyss.inv_section_depth(section, y),
		}
	end
	return coords
end

-- tests

do
	local section, x = abyss.section_offset(abyss.dx + 1)
	assert(section == 1 and x == 1)
	section, x = abyss.section_offset(abyss.dx - 1)
	assert(section == 1 and x == -1)

	assert(abyss.section_depth(1, 0) == -480)

	local x, y = abyss.abyss_coords(abyss.dx, 0)
	assert(x == 0 and y == -480)

	assert(abyss.inv_section_offset(1, 0) == abyss.dx)
	assert(abyss.inv_section_depth(1, -480) == 0)

	assert(not abyss.belongs_to_section(1, 0))
	assert(abyss.belongs_to_section(1, -480))
	assert(not abyss.belongs_to_section(1, -224))  -- y = 256
	assert(abyss.belongs_to_section(0, -224))  -- y = -256

	local sections = abyss.sections(-257)
	assert(#sections == 1 and sections[1] == 1)
	sections = abyss.sections(-256)
	assert(#sections == 2 and sections[1] == 0 and sections[2] == 1)
	sections = abyss.sections(-225)
	assert(#sections == 2 and sections[1] == 0 and sections[2] == 1)
	sections = abyss.sections(-224)
	assert(#sections == 1 and sections[1] == 0)
end

return abyss
