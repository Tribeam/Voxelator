local clsProject = class("clsProject", {})


function clsProject:init()

	self.voxel = fileVox(love.filesystem.getSourceBaseDirectory() .. "/voxels/WALL57_2.vox").voxel
	self.world = clsWorld(self.voxel)

	self.palsize = 8

end

function clsProject:update(dt)
	self.world:update(dt)
end


function clsProject:draw()
	self.world:draw()
	self:drawPalette()
	self:drawInfo()
end

function clsProject:resize()
	self.world:resize()
end

function clsProject:input(text)
	self.world:input(text)
end

function clsProject:drawPalette()
	for i = 0, 255 do
		local x = (i % 32)*self.palsize
		local y = math.floor(i / 32)*self.palsize

		x = x + love.graphics.getWidth()-(32*self.palsize)-self.palsize
		y = y + love.graphics.getHeight()-(8*self.palsize)-self.palsize

		if(self.voxel.palette ~= nil) then
			love.graphics.setColor(self.voxel.palette[i+1][1], self.voxel.palette[i+1][2], self.voxel.palette[i+1][3])
		end

		love.graphics.rectangle("fill", x, y, self.palsize, self.palsize)
	end
end


-- draw the palette to screen
function clsProject:drawInfo()
	love.graphics.setColor(1.0, 1.0, 1.0)
	love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
	love.graphics.print(string.format("Pivot: %d, %d, %d", self.voxel.pivot.x, self.voxel.pivot.y, self.voxel.pivot.z), 10, 25)
	love.graphics.print(string.format("Size:  %d, %d, %d", self.voxel.size.x, self.voxel.size.y, self.voxel.size.z), 10, 40)
	love.graphics.print(string.format("Voxels:  %d", self.voxel.count), 10, 55)
	love.graphics.print(string.format("Fly Mode:  %s", self.world.fly), 10, 70)
	love.graphics.print(string.format("Light: M:%s, R:%.3f, D:%.3f, H:%.3f, B:%.3f", self.world.shade, math.deg(self.world.sunrotation), self.world.sundist, self.world.sunheight, self.world.sunbright), 10, 85)
	love.graphics.print(string.format("Cursor Mode: %s", self.world.cursormode), 10, 100)


end


return clsProject