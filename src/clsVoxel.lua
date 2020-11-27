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
	self.pivot.x = 50
	self.pivot.y = 50
	self.pivot.z = 0

	self.previews = {}

	self.palette = {}
	for p = 1, 256 do
		self.palette[p] = {0, 0, 0, 0}
	end

	self.points = {{{}}}

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

-- Get the color of a palette entry
function clsVoxel:buildModel()
	self.model:set_opts({ instance_usage = 'stream' })
	local instances = {}
	for x = 1, #self.points do
		for y = 1, #self.points[x] do
			for z = 1, #self.points[x][y] do

				local palentry = self.points[x][y][z]+1
				if(palentry ~= 256) then
					table.insert(instances, {
					  x*self.cubescale, -z*self.cubescale, y*self.cubescale, -- positions
					  0, 0, 0, -- rotations
					  1, 1, 1, -- scale
					  self.palette[palentry][1]*4, self.palette[palentry][2]*4, self.palette[palentry][3]*4, 1, -- color
					  0, 0, -- pbr
					})
				end
			end
		end
	end

	self.model:set_raw_instances(instances)

end

return clsVoxel















