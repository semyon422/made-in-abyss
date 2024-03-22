local abyss = require("abyss")

return {
	{
		name = "all",
		range = {0, 12},
		clip_plane = math.huge,
	},
	{
		name = "L2 top",
		range = {3, 5},
		clip_plane = -1321,
	},
	{
		name = "L2 middle",
		range = {3, 5},
		clip_plane = -1321 - (119 + 101),
	},
	{
		name = "L2 inv forest top",
		range = {3, 5},
		clip_plane = select(2, abyss.abyss_coords(81000, 223)),
	},
	{
		name = "L2 inv forest bottom",
		range = {3, 5},
		clip_plane = select(2, abyss.abyss_coords(81000, 114)),
	},
	{
		name = "L4",
		range = {8, 12},
		clip_plane = select(2, abyss.abyss_coords(130000, -64)),
	},
}
