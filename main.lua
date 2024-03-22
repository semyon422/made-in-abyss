local libs_prefix = "/home/semyon422/code/soundsphere/"
package.path = package.path .. ";" .. libs_prefix .. "?.lua"

local pkg = require("aqua.package")
pkg.addc(libs_prefix .. "3rd-deps/lib")
pkg.addc(libs_prefix .. "bin/lib")
pkg.add(libs_prefix .. "3rd-deps/lua")
pkg.add(libs_prefix .. "aqua")

package.loaded.xsys = {string = require("aqua.string")}
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")

local abyss = require("abyss")
local SectionBuilder = require("SectionBuilder")
local WorldBuilder = require("WorldBuilder")
local WorldRenderer = require("WorldRenderer")
local render_presets = require("render_presets")

local path = "/home/semyon422/.minecraft/modpacks/1.20.4-vanilla/Distant_Horizons_server_data/build%2Emineinabyss%2Ecom/overworld/DistantHorizons.sqlite"

local db = LjsqliteDatabase()
db:open(path)

local _models = {DhRenderData = {table_name = "DhRenderData"}}

local orm = TableOrm(db)
local models = Models(_models, orm)

local preset = render_presets[1]

local sectionBuilder = SectionBuilder(models.DhRenderData, preset.clip_plane)

local worldBuilder = WorldBuilder(2048, 2048, sectionBuilder)

local a, b = unpack(preset.range)

-- worldBuilder:build(0, 0)
-- worldBuilder:build(a, b)
-- worldBuilder:saveToFiles("colormap.png", "heightmap.png")

worldBuilder:loadFromFiles("colormap.png", "heightmap.png")

local worldRenderer = WorldRenderer(worldBuilder)
worldRenderer:load()

function love.draw()
	local w, h = love.graphics.getDimensions()
	local mx, my = love.mouse.getPosition()

	love.graphics.translate(w / 2, h / 2)

	if love.keyboard.isScancodeDown("space") then
		love.graphics.scale(0.5, 0.5)
	end

	worldRenderer:setSunPos(mx / w, my / h)
	worldRenderer:draw()

	local ay = worldBuilder:getHeightAt(mx, my)
	local wx, wy = unpack(abyss.world_coords(mx - w / 2, -ay)[1])
	love.graphics.print(("a.y = %s\nw.xyz = %s %s %s\nclip plane = %s"):format(ay, wx, wy, my - h / 2, preset.clip_plane))
end

