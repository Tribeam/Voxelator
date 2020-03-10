


local clsVoxel = class("clsVoxel", {})

function clsVoxel:init()

	self.pos = {}
	self.pos.x = 0
	self.pos.y = 0
	self.pos.z = 0

	self.size = {}
	self.size.x = 0
	self.size.y = 0
	self.size.z = 0

	self.pivot = {}
	self.pivot.x = 0
	self.pivot.y = 0
	self.pivot.z = 0

	self.previews = {}

	self.palette = {}
	for p = 1, 256 do
		self.palette[p] = {0, 0, 0, 0}
	end

	self.voxel = {{{}}}
end


function clsVoxel:setPoint(x, y, z, p)
	if(self.voxel[x] == nil) then self.voxel[x] = {} end
	if(self.voxel[x][y] == nil) then self.voxel[x][y] = {} end

	self.voxel[x][y][z] = p
end

function clsVoxel:getPoint(x, y, z)
	return self.voxel[x][y][z]
end

function clsVoxel:setPaletteEntry(p, t)
	self.palette[p] = t
end

function clsVoxel:getPaletteEntry(p)
	return self.palette[p]
end

function clsVoxel:buildPreviews()

	self.previews[1] = love.graphics.newCanvas(self.xsize, self.zsize) -- front
	self.previews[2] = love.graphics.newCanvas(self.xsize, self.zsize) -- back
	self.previews[3] = love.graphics.newCanvas(self.ysize, self.zsize) -- left
	self.previews[4] = love.graphics.newCanvas(self.ysize, self.zsize) -- right
	self.previews[5] = love.graphics.newCanvas(self.xsize, self.ysize) -- top
	self.previews[6] = love.graphics.newCanvas(self.xsize, self.ysize) -- bottom

	for p = 1, #self.previews do
		love.graphics.setCanvas(self.previews[p])
		for x = 1, #self.voxel do
			for y = 1, #self.voxel[x] do
				for z = 1, #self.voxel[x][y] do
					local palentry = self.voxel[x][y][z]+1
					if(palentry ~= 256) then
						love.graphics.setColor(self.palette[palentry][1], self.palette[palentry][2], self.palette[palentry][3], self.palette[palentry][4])
						love.graphics.points(x, z)
					end
				end
			end
		end
	end

	love.graphics.setCanvas()
end

function clsVoxel:drawPreviews()
	for p = 1, #self.previews do
		love.graphics.draw(self.previews[p], self.pos.x((self.size.x+1)*p), self.pos.y)
	end
end


return clsVoxel