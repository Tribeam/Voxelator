
function love.load(arg)

    -- Zerobrane debugging
    if arg[#arg] == "-debug" then
        require("mobdebug").start()
    end

	love.graphics.setDefaultFilter("nearest", "nearest", 0)
	love.graphics.setLineStyle("rough")

	class		= require("mod30log")
	clsVoxel	= require("clsVoxel")
	fileVox		= require("fileVox")

	local apppath = love.filesystem.getSourceBaseDirectory()
	vox = fileVox(apppath .. "/voxels/1975_tank_shoot1.vox")
	vox:save(apppath .. "/voxels/derp.vox")

end

function love.update(dt)

end

function love.draw()
	vox.voxel:drawPreviews()
end