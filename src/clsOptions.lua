local clsOptions = class("clsOptions", {})

function clsOptions:init()

    -- keep track of how long the options take to load
    self.stime = love.timer.getTime()

    -- check if options exists
    local check = io.open("options.cfg")
    if not check then
		error("Could not find options.cfg")
    else
        check:close()
    end

    -- load chunk
    local ok, chunk, err = pcall(loadfile, "options.cfg", "t")

    -- check chunk
    if not chunk then
        error("Options Error: " .. err)
    elseif not ok then
        error("Options Error: " .. err)
    else
        setfenv(chunk, {})

        -- run chunk
        local ok, result = pcall(chunk)

        -- error checking
        if not ok then return print("Options Error: " .. result) end
        if type(result) ~= "table" then error("Error: Could not load options: File did not return a table.") end

        -- save options in config table
        self.data = result
    end

	self.etime = love.timer.getTime()
    self.total_time = (self.etime-self.stime)*1000
	print(string.format("Options loaded in %.3fms", self.total_time))
    return true
end

return clsOptions