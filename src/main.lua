
function love.load()

	class				= require("mod30log")
	clsVoxel			= require("clsVoxel")
	clsProject			= require("clsProject")
	clsOptions			= require("clsOptions")()
	fileVox				= require("fileVox")
	project = clsProject()
end

function love.update(dt)

end

function love.draw()
	project:draw()
end












