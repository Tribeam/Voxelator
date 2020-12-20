local clsOptions = class("clsOptions", {})



function clsOptions:init()

    self.stime = love.timer.getTime()
	self.filename = love.filesystem.getSourceBaseDirectory() .. "/convert.ini"
	self.options = ""
	self.default = {}
	self.data = {}

	self:exists()
	self:convert()
	self:process()
	self:setup()
	self:validate()

	self.etime = love.timer.getTime()
    self.total_time = (self.etime-self.stime)*1000
	print(string.format("Convert.ini loaded in %.3fms", self.total_time))
    return true
end

function clsOptions:exists()
    local check = io.open(self.filename)
    if not check then
		error("Could not find convert.ini")
    else
        check:close()
    end
end

function clsOptions:convert()

	local inilines = {}
	inilines[1] = "local c = {"
	for line in io.lines(self.filename) do
		inilines[#inilines+1] = string.format("%s", line)
	end

	for i = 2, #inilines do

		-- remove spaces and tabs from the line
		inilines[i] = inilines[i]:gsub("\t", "")
		inilines[i] = inilines[i]:gsub(" ", "")

		-- look for comments
		local c = 0
		while c <= #inilines[i] do

			if(inilines[i]:sub(c, c) == ";") then
				inilines[i] = inilines[i]:sub(1, c-1)
				break
			end
			c = c + 1
		end

		-- if the line begins with [, add a quote
		if(inilines[i]:sub(1, 1) == "[") then
			inilines[i] = string.format('["%s', inilines[i]:sub(2))

		-- if the line is blank, add a bracket
		elseif(inilines[i] == "") then
			inilines[i] = "},\n"

		-- last line
		elseif(i == #inilines) then
			if(inilines[i] == "") then
				inilines[i] = "},\n} return c"
			else
				inilines[#inilines+1] = "},\n} return c"
			end
		else
			inilines[i] = string.format('%s,', inilines[i]:sub(1, -1))
		end

		-- if the line ends with ], add ]={
		if(inilines[i]:sub(-1) == "]") then
			inilines[i] = string.format('%s"]={', inilines[i]:sub(1, -2))
		end
	end

	self.options = table.concat(inilines, "\n")
end

function clsOptions:process()
    -- load chunk
    local ok, chunk, err = pcall(loadstring, self.options)

    -- check chunk
    if not chunk then
        error("Convert.ini Syntax Error.")
    elseif not ok then
        error("Unknown Convert.ini Error.")
    else
        setfenv(chunk, {})

        -- run chunk
        local ok, result = pcall(chunk)

        -- error checking
        if not ok then return print("Convert.ini Error: " .. result) end

        -- save options in config table
        self.data = result
    end
end

function clsOptions:setup()

	self.data.default 					= self.data.default 				or {}
	self.default.pivot_x_auto			= self.data.default.pivot_x_auto	or "center"
	self.default.pivot_y_auto			= self.data.default.pivot_y_auto	or "center"
	self.default.pivot_z_auto			= self.data.default.pivot_z_auto	or "center"
	self.default.pivot_x_off			= self.data.default.pivot_x_off		or 0
	self.default.pivot_y_off			= self.data.default.pivot_y_off		or 0
	self.default.pivot_z_off			= self.data.default.pivot_z_off		or 0
	self.default.transindex 			= self.data.default.transindex 		or 255
	self.default.angle 					= self.data.default.angle 			or 0
	self.default.pitch 					= self.data.default.pitch 			or 0
	self.default.axis 					= self.data.default.axis 			or "x"
	self.default.axis_reverse 			= self.data.default.axis_reverse 	or false
	self.default.export_obj 			= self.data.default.export_obj 		or ""
	self.default.export_vox 			= self.data.default.export_vox 		or self.filename
	self.default.export_slice 			= self.data.default.export_slice 	or ""
	self.default.hollow 				= self.data.default.hollow 			or true
	self.default.palette 				= self.data.default.palette 		or ""
	self.default.colorcorrect 			= self.data.default.colorcorrect 	or true
	self.default.slice_depth 			= self.data.default.slice_depth 	or 0
	self.default.slice_width 			= self.data.default.slice_width
	self.default.slice_height 			= self.data.default.slice_height
	self.default.type					= self.data.default.type

	for k, v in pairs(self.data) do
		if(string.upper(k) ~= "DEFAULT") then

			v.pivot_x_auto			= v.pivot_x_auto	or self.default.pivot_x_auto
			v.pivot_y_auto			= v.pivot_y_auto	or self.default.pivot_y_auto
			v.pivot_z_auto			= v.pivot_z_auto	or self.default.pivot_z_auto
			v.pivot_x_off			= v.pivot_x_off		or self.default.pivot_x_off
			v.pivot_y_off			= v.pivot_y_off		or self.default.pivot_y_off
			v.pivot_z_off			= v.pivot_z_off		or self.default.pivot_z_off
			v.transindex 			= v.transindex 		or self.default.transindex
			v.angle 				= v.angle 			or self.default.angle
			v.pitch 				= v.pitch 			or self.default.pitch
			v.axis 					= v.axis 			or self.default.axis
			v.axis_reverse 			= v.axis_reverse 	or self.default.axis_reverse
			v.export_obj 			= v.export_obj 		or self.default.export_obj
			v.export_vox 			= v.export_vox 		or self.default.export_vox
			v.export_slice 			= v.export_slice 	or self.default.export_slice
			v.hollow 				= v.hollow 			or self.default.hollow
			v.palette 				= v.palette 		or self.default.palette
			v.colorcorrect 			= v.colorcorrect 	or self.default.colorcorrect
			v.slice_depth 			= v.slice_depth 	or self.default.slice_depth
			v.slice_width			= v.slice_width		or self.default.slice_width
			v.slice_height			= v.slice_height	or self.default.slice_height
			v.type					= v.type			or self.default.type
			v.filename				= k .. "." .. v.type
		end
	end
end

function clsOptions:validate()
	for k, v in pairs(self.data) do
		if(string.upper(k) ~= "DEFAULT") then
			if(v.slice_width == nil) then error(string.format("Convert.ini Error: %s is missing it's width property.", k)) end
			if(v.slice_height == nil) then error(string.format("Convert.ini Error: %s is missing it's height property.", k)) end
			if(v.type == nil) then error(string.format("Convert.ini Error: %s is missing it's type property.", k)) end

			if(type(v.slice_width) ~= "number") then error(string.format("Convert.ini Error: %s width property is not a number.", k)) end
			if(type(v.slice_height) ~= "number") then error(string.format("Convert.ini Error: %s height property is not a number.", k)) end
			if(type(v.type) ~= "string") then error(string.format("Convert.ini Error: %s type property is not a string.", k)) end

			if(v.type ~= "png" and v.type ~= "vox") then error(string.format("Convert.ini Error: %s type property is not a png or vox.", k)) end
		end
	end
end


return clsOptions




