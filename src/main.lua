
function love.load()

	love.window.maximize()
	MR = require 'renderer'
	Cpml = require 'Cpml'


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

function love.resize(x, y)
	project:resize()
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

function love.textinput(text)
	project:input()
end

function love.draw()
	project:draw()
end












