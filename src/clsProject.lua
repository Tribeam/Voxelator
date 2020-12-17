local clsProject = class("clsProject", {})


function clsProject:init()


	local count = 1
	self.voxels = {}
	for k, v in pairs(options.data) do
		if(string.upper(k) ~= "DEFAULT") then
			self.voxels[count] = filePng(v).voxel
			count = count + 1
		end
	end
	self.palsize = 8

end

function clsProject:update(dt)
end

function clsProject:draw()
	self:drawPalette()
	--self:drawInfo()
end

function clsProject:drawPalette()
	local v = 1
	for i = 0, 255 do
		local x = (i % 32)*self.palsize
		local y = math.floor(i / 32)*self.palsize

		x = x + love.graphics.getWidth()-(32*self.palsize)-self.palsize
		y = y + love.graphics.getHeight()-(8*self.palsize)-self.palsize

		if(self.voxels[v].palette ~= nil) then
			love.graphics.setColor(self.voxels[v].palette[i+1][1]/255, self.voxels[v].palette[i+1][2]/255, self.voxels[v].palette[i+1][3]/255, 1.0)
		end

		love.graphics.rectangle("fill", x, y, self.palsize, self.palsize)
	end

end

function clsProject:drawInfo()
	love.graphics.setColor(1.0, 1.0, 1.0)
	--love.graphics.print(string.format("Pivot: %d, %d, %d", self.voxel.pivot.x, self.voxel.pivot.y, self.voxel.pivot.z), 10, 25)
	--love.graphics.print(string.format("Size:  %d, %d, %d", self.voxel.size.x, self.voxel.size.y, self.voxel.size.z), 10, 40)
	--love.graphics.print(string.format("Voxels:  %d", self.voxel.count), 10, 55)
end


return clsProject