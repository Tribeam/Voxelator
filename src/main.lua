
function love.load()

	--love.mouse.setRelativeMode(true)

	MR = require 'renderer'
	Cpml = require 'Cpml'

	palshader = love.graphics.newShader(
	[[
		#pragma language glsl3

		extern vec4 pal[256];
		vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
		{
			vec4 pixel = Texel(tex, texture_coords);
			int index = int(pixel.g*255);
			return pal[index];
		}
	]])

	class			= require("mod30log")
	clsWorld		= require("clsWorld")
	clsVoxel		= require("clsVoxel")
	clsProject		= require("clsProject")
	fileVox			= require("fileVox")

	project = clsProject()


	mouse = {}
	mouse.x = 0
	mouse.y = 0
	mouse.dx = 0
	mouse.dy = 0

end

function love.mousemoved(x, y, dx, dy, istouch)
	mouse.dx = dx
	mouse.dy = dy
end

function love.update(dt)
	if love.keyboard.isDown('escape') then love.event.quit("User Requested.") end
	project:update(dt)
	mouse.dx = 0
	mouse.dy = 0
end

function love.draw()
	project:draw()
end












