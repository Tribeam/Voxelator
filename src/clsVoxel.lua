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

	self.count = 0

	self.previews = {}

	self.palette = {}
	for p = 1, 256 do
		self.palette[p] = {0, 0, 0, 0}
	end

	self.points = {{{}}}
	self.marked = {}
	self.cubescale = 1
	self.model = MR.model.new_box(self.cubescale)

end

-- Set a point in space
function clsVoxel:setPoint(x, y, z, p)
	if(self.points[x] == nil) then self.points[x] = {} end
	if(self.points[x][y] == nil) then self.points[x][y] = {} end

	self.points[x][y][z] = p
end

-- Get a point in space
function clsVoxel:getPoint(x, y, z)
	return self.points[x][y][z]
end

-- Set the color of palette entry
function clsVoxel:setPaletteEntry(p, t)
	self.palette[p] = t
end

-- Get the color of a palette entry
function clsVoxel:getPaletteEntry(p)
	return self.palette[p]
end

function clsVoxel:hollow()
	for x = 1, #self.points do
		for y = 1, #self.points[x] do
			for z = 1, #self.points[x][y] do
				local p = self.points[x][y][z]
				local delete = 0
				if(p ~= 255) then
					if(x-1 >= 1 and 					self.points[x-1][y][z] ~= 255) then delete = delete + 1 end
					if(x+1 <= #self.points and			self.points[x+1][y][z] ~= 255) then delete = delete + 1 end
					if(y-1 >= 1 and						self.points[x][y-1][z] ~= 255) then delete = delete + 1 end
					if(y+1 <= #self.points[x] and		self.points[x][y+1][z] ~= 255) then delete = delete + 1 end
					if(z-1 >= 1 and						self.points[x][y][z-1] ~= 255) then delete = delete + 1 end
					if(z+1 <= #self.points[x][y] and 	self.points[x][y][z+1] ~= 255) then delete = delete + 1 end
					if(delete == 6) then self.marked[#self.marked+1] = {x, y, z} end
				end
			end
		end
	end

	for i = 1, #self.marked do
		self.points[self.marked[i][1]][self.marked[i][2]][self.marked[i][3]] = 255
	end
end

-- build the model
function clsVoxel:buildModel()
	self.count = 0
	self.model:set_opts({ instance_usage = 'dynamic' })
	local instances = {}
	for x = 1, #self.points do
		for y = 1, #self.points[x] do
			for z = 1, #self.points[x][y] do
				local p = self.points[x][y][z]
				if(p ~= 255) then
					self.count = self.count + 1
					table.insert(instances, {
					  (self.size.x/2)-(x*self.cubescale), ((-z*self.cubescale)+#self.points[x][y]), (self.size.y/2)-(y*self.cubescale), -- positions
					  0, 0, 0, -- rotations
					  1, 1, 1, -- scale
					  0, p/255.0, 0, 1, -- color
					  1, 0, -- ispaletted, unused
					})
				end
			end
		end
	end

	self.model:set_raw_instances(instances)
end


return clsVoxel















