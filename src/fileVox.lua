local vox = class("fileVOX", {})

function vox:init(filepath)
	self.raw = ""
	self.voxel = clsVoxel()
	self:open(filepath)
	self:readHeader()
	self:readPalette()
	self:readVoxel()
	collectgarbage()
end

function vox:readHeader()
	self.voxel.size.x, self.voxel.size.y, self.voxel.size.z = love.data.unpack("<LLL", self.raw, 1)
end

function vox:readPalette()
	local p = 0
	for i = 1, 256*3, 3 do
		local r, g, b = love.data.unpack("<BBB", self.raw, -768+(i-1))
		p = p + 1
		local r2, g2, b2 = love.math.colorFromBytes(r, g, b, 255)
		self.voxel:setPaletteEntry(p, {r2*4, g2*4, b2*4, 255})
	end
end

function vox:readVoxel()
	for x = 0, self.voxel.size.x-1 do
		for y = 0, self.voxel.size.y-1 do
			for z = 0, self.voxel.size.z-1 do
				local index = (x * self.voxel.size.y + y) * self.voxel.size.z + z
				self.voxel:setPoint(x+1, y+1, z+1, love.data.unpack("<B", self.raw, index+13))
			end
		end
	end
end

function vox:open(path)
	local file = assert(io.open(path, "rb"))
	self.raw = file:read("*all")
	file:close()
end

function vox:save(path)
	local file = assert(io.open(path, "wb"))

	file:write(love.data.pack("string", "<LLL", self.voxel.size.x, self.voxel.size.y, self.voxel.size.z))

	for x = 0, self.voxel.size.x-1 do
		for y = 0, self.voxel.size.y-1 do
			for z = 0, self.voxel.size.z-1 do
				local index = (x * self.voxel.size.y + y) * self.voxel.size.z + z
				file:write(love.data.pack("string", "<B", self.voxel:getPoint(x+1, y+1, z+1)))
			end
		end
	end

	for p = 1, #self.voxel.palette do
		local entry = self.voxel:getPaletteEntry(p)

		local r2, g2, b2 = love.math.colorToBytes(entry[1], entry[2], entry[3], 255)
		file:write(love.data.pack("string", "<BBB", r2, g2, b2))
	end

	file:close()
end

return vox