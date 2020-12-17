local png = class("filePNG", {})


-- Constructor
function png:init(options)

	self.options = options
	self.voxel = clsVoxel()

    self.sheet = {}
	self.sheet.name 	= options.filename											-- sheet filename
	self.sheet.data 	= self:loadImageData()										-- sheet image data
	self.sheet.image 	= love.graphics.newImage(self.sheet.data)					-- sheet image object
	self.sheet.width 	= self.sheet.data:getWidth()								-- sheet image x res
	self.sheet.height 	= self.sheet.data:getHeight()								-- sheet image y res

	self.slice 			= {}
	self.slice.width 	= options.slice_width
	self.slice.height 	= options.slice_height

	if self.sheet.width % self.slice.width ~= 0 then error("Sheet width is not a multiple of slice width") end
	if self.sheet.height % self.slice.height ~= 0 then error("Sheet height is not a multiple of slice height") end

	self.sheet.xcount 	= self.sheet.width / self.slice.width			-- number of slices on the x axis within the sheet
	self.sheet.ycount 	= self.sheet.height / self.slice.height			-- number of slices on the y axis within the sheet
	self.sheet.total 	= self.sheet.xcount*self.sheet.ycount

	self:readPalette()
	self:setPivot()

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

function png:readPalette()

	-- read the palette from the png
	if self.options.palette == "" then
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
				self.voxel:setPaletteEntry(entry, {string.byte(chunks["PLTE"].data:sub(c, c)), string.byte(chunks["PLTE"].data:sub(c+1, c+1)), string.byte(chunks["PLTE"].data:sub(c+2, c+2)), 1.0})
				entry = entry + 1
			end
		else
			error("Error: Sheet png has no palette, you must use 8bit indexed pngs.")
		end

	-- read the palette from an external file
	else
		local file = assert(io.open(love.filesystem.getSourceBaseDirectory() .. "/palettes/" .. self.options.palette .. ".pal", "rb"))
		local raw = file:read("*all")
		file:close()

		local entry = 1
		for c = 1, #raw, 3 do
			self.voxel:setPaletteEntry(entry, {string.byte(raw:sub(c, c)), string.byte(raw:sub(c+1, c+1)), string.byte(raw:sub(c+2, c+2)), 1.0})
			entry = entry + 1
		end
	end
end

function png:setPivot()
	if type(self.options.pivot_x) == "number" then
		self.voxel.pivot.x = self.options.pivot_x
	else

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
end

return png















