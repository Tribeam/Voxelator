local png = class("filePNG", {})


-- Constructor
function png:init(options)

	self.options = options
	self.voxel = clsVoxel()
	self.voxel.size.x = options.slice_width
	self.voxel.size.y = options.slice_depth
	self.voxel.size.z = options.slice_height

    self.sheet = {}
	self.sheet.name 	= options.filename											-- sheet filename
	self.sheet.data 	= self:loadImageData()										-- sheet image data
	self.sheet.image 	= love.graphics.newImage(self.sheet.data)					-- sheet image object
	self.sheet.width 	= self.sheet.data:getWidth()								-- sheet image x res
	self.sheet.height 	= self.sheet.data:getHeight()								-- sheet image y res

	self.slices 		= {}
	self.slices.width 	= options.slice_width
	self.slices.height 	= options.slice_height
	self.slices.slices  = {} -- my naming schemes are unmatched

	if self.sheet.width % self.slices.width ~= 0 then error("Sheet width is not a multiple of slice width") end
	if self.sheet.height % self.slices.height ~= 0 then error("Sheet height is not a multiple of slice height") end

	self.sheet.xcount 	= self.sheet.width / self.slices.width						-- number of slices on the x axis within the sheet
	self.sheet.ycount 	= self.sheet.height / self.slices.height					-- number of slices on the y axis within the sheet
	self.sheet.total 	= self.sheet.xcount*self.sheet.ycount

	if self.voxel.size.y == 0 then
		self.voxel.size.y = self.sheet.total
	end

	self:readPalette()
	self:setPivot()
	self:gatherSlices()
	self:buildVoxel()
end

function png:loadImageData()
    local f, err = io.open(love.filesystem.getSourceBaseDirectory() .. "/slices/" .. self.sheet.name, "rb")
    if f then
        local data = f:read("*all")
        f:close()
        if data then
            data = love.filesystem.newFileData(data, "")
            return love.image.newImageData(data)
        end
	else
		error(err)
    end
end

-- find nearest color in the palette
function png:colorNearest(r, g, b)

	local closest = 0
	local closesterror = 256

	r, g, b = love.math.colorToBytes(r, g, b)

	for c = 1, 256 do
		local dr = r - self.voxel.palette[c][1]
		local dg = g - self.voxel.palette[c][2]
		local db = b - self.voxel.palette[c][3]
		local err = dr * dr + dg * dg + db * db
		if err < closesterror then
			closesterror = err;
			closest = c
		end
	end

    return closest
end

function png:readPalette()

	local file = assert(io.open(love.filesystem.getSourceBaseDirectory() .. "/slices/" .. self.options.filename, "rb"))
	local raw = file:read("*all")
	file:close()

	-- gather png chunks
	local i = 9
	local chunks = {}
	while(i <= #raw) do
		local chunk_size = love.data.unpack(">L", raw, i)
		local chunk_type = love.data.unpack(">c4", raw, i+4)
		local chunk_data = ""
		local chunk_crc = ""

		if chunk_size > 0 then
			chunk_data = love.data.unpack(">c" .. tostring(chunk_size), raw, i+8)
			chunk_crc = love.data.unpack(">L", raw, i+8+chunk_size)
		else
			chunk_crc = love.data.unpack(">L", raw, i+8)
		end

		chunks[chunk_type] = {size=chunk_size, data=chunk_data, crc=chunk_crc}

		i = i + 8 + chunk_size + 4
	end

	-- check if palette exists
	if chunks["PLTE"] ~= nil then
		local entry = 1
		for c = 1, #chunks["PLTE"].data, 3 do

			local r2, g2, b2 = string.byte(chunks["PLTE"].data:sub(c, c)), string.byte(chunks["PLTE"].data:sub(c+1, c+1)), string.byte(chunks["PLTE"].data:sub(c+2, c+2))
			self.voxel:setPaletteEntry(entry, {r2, g2, b2, 1.0})
			entry = entry + 1
		end
	else
		error("Error: Sheet png has no palette, you must use 8bit indexed pngs.")
	end

	-- remove the trans color
	for x = 0, self.sheet.width-1 do
		for y = 0, self.sheet.height-1 do

			local r, g, b, a = self.sheet.data:getPixel(x, y)

			local c = self:colorNearest(r, g, b)
			if(c == self.options.transindex+1) then
				self.sheet.data:setPixel(x, y, r, g, b, 0)
			end
		end
	end
	self.sheet.image = love.graphics.newImage(self.sheet.data)

	-- read the palette from an external file if requested
	if self.options.palette ~= "" then

		local file = assert(io.open(love.filesystem.getSourceBaseDirectory() .. "/palettes/" .. self.options.palette .. ".pal", "rb"))
		local raw = file:read("*all")
		file:close()

		local entry = 1
		for c = 1, #raw, 3 do
			local r2, g2, b2 = string.byte(raw:sub(c, c)), string.byte(raw:sub(c+1, c+1)), string.byte(raw:sub(c+2, c+2))
			self.voxel:setPaletteEntry(entry, {r2, g2, b2, 1.0})
			entry = entry + 1
		end

		-- convert image to new pal
		for x = 0, self.sheet.width-1 do
			for y = 0, self.sheet.height-1 do
				local r, g, b, a = self.sheet.data:getPixel(x, y)
				local c = self:colorNearest(r, g, b)
				if(c ~= self.options.transindex+1) then
					local e = self.voxel:getPaletteEntry(c)
					self.sheet.data:setPixel(x, y, e[1], e[2], e[3], 1)
				end
			end
		end
		self.sheet.image = love.graphics.newImage(self.sheet.data)
	end
end


-- set the pivot point
function png:setPivot()

	-- x axis
	if self.options.pivot_x_auto == "center" then
		if self.options.slice_depth > 0 then
			self.voxel.pivot.x = math.floor(self.options.slice_depth/2)+self.options.pivot_x_off
		else
			self.voxel.pivot.x = math.floor(self.sheet.total/2)+self.options.pivot_x_off
		end
	end

	if self.options.pivot_x_auto == "front" then
		self.voxel.pivot.x = self.options.pivot_x_off
	end

	if self.options.pivot_x_auto == "back" then
		if self.options.slice_depth > 0 then
			self.voxel.pivot.x = self.options.slice_depth+self.options.pivot_x_off
		else
			self.voxel.pivot.x = self.sheet.total+self.options.pivot_x_off
		end
	end

	-- y axis
	if self.options.pivot_y_auto == "center" then
		self.voxel.pivot.y = math.floor(self.options.slice_width/2)+self.options.pivot_y_off
	end

	if self.options.pivot_y_auto == "left" then
		self.voxel.pivot.y = self.options.pivot_y_off
	end

	if self.options.pivot_y_auto == "right" then
		self.voxel.pivot.y = self.options.slice_width+self.options.pivot_y_off
	end

	-- z axis
	if self.options.pivot_z_auto == "center" then
		self.voxel.pivot.z = math.floor(self.options.slice_width/2)+self.options.pivot_y_off
	end

	if self.options.pivot_z_auto == "top" then
		self.voxel.pivot.z = self.options.pivot_z_off
	end

	if self.options.pivot_z_auto == "bottom" then
		self.voxel.pivot.z = self.options.slice_height+self.options.pivot_z_off
	end

end

-- chop out each slice
function png:gatherSlices()

	local depth = 0
	for h = 0, self.sheet.height-1, self.slices.height do
		for w = 0, self.sheet.width-1, self.slices.width do

			depth = depth + 1
			if depth > self.options.slice_depth and self.options.slice_depth > 0 then return end

			local i = #self.slices.slices+1
			self.slices.slices[i] = love.image.newImageData(self.slices.width, self.slices.height)

			for x = 0, self.slices.width-1 do
				for y = 0, self.slices.height-1 do
					local r, g, b, a = self.sheet.data:getPixel(x+w, y+h)
					self.slices.slices[i]:setPixel(x, y, r, g, b, a)
				end
			end
		end
	end
end

function png:buildVoxel()
	for y = 1, #self.slices.slices do
		for z = 0, self.slices.slices[y]:getHeight()-1 do
			for x = 0, self.slices.slices[y]:getWidth()-1 do

				local r, g, b, a = self.slices.slices[y]:getPixel(x, z)
				local c = self:colorNearest(r, g, b)

				if a ~= 0 then
					self.voxel:setPoint(x+1, y, z+1, c)
				else
					self.voxel:setPoint(x+1, y, z+1, 255)
				end
			end
		end
	end
end

-- Save the data to file
function png:save(path)
	local file = assert(io.open(path, "wb"))

	file:write(love.data.pack("string", "<LLL", self.voxel.size.x, self.voxel.size.y, self.voxel.size.z))

	for x = 0, self.voxel.size.x-1 do
		for y = 0, self.voxel.size.y-1 do
			for z = 0, self.voxel.size.z-1 do
				local index = (x * self.voxel.size.y + y) * self.voxel.size.z + z
				file:write(love.data.pack("string", ">B", self.voxel:getPoint(x+1, y+1, z+1)))
			end
		end
	end

	for p = 1, #self.voxel.palette do
		local entry = self.voxel:getPaletteEntry(p)

		local r2, g2, b2 = entry[1], entry[2], entry[3], 255
		file:write(love.data.pack("string", ">BBB", r2, g2, b2))
	end

	file:close()
end

return png















