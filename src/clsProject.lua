local clsProject = class("clsProject", {})


function clsProject:init()
	self.world = clsWorld()
end

function clsProject:update(dt)
	self.world:update(dt)
end

function clsProject:draw()
	self.world:draw()
	self.world.vox.voxel:drawPalette()
end


return clsProject