
local events =
{
    handlers = {},            -- holds all the handlers registered to each event
    stats =                   -- some fun info to keep track of because why not
    {
        success = 0,           -- number of handlers that were successfully called
        failed = 0,            -- number of handlers that crapped out
        amount = 0,            -- number of events that exist
    },
    status = nil,
    success = nil,
    err = nil,
}

-- register a function to an event
function events:register(event, func)
    if event == nil then print("Tried to register an event with no name.")  end
    if func == nil then print("Tried to register a non-existent function to event %s", event)  end
    if type(self.handlers[event]) ~= "table" then self.handlers[event] = {} end

    local i = #self.handlers[event]+1
    self.handlers[event][i] = func
    return i
end

-- delete an event
function events:deleteEvent(event)
    if type(self.handlers[event]) == "table" then
        self.handlers[event] = nil
        self.stats.amount = #self.handlers
        print(2, "Event %s deleted", event)
        return true
    end
    return false
end

-- delete an event handler
function events:deleteHandler(event, id)
    if type(self.handlers[event][id]) ~= "table" then
        self.handlers[event][id] = nil
        self.stats.amount = #self.handlers
        print(2, "Event handler %s:%s deleted", event, id)
        return true
    end
    return false
end


-- broadcast an event
function events:broadcast(event, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)

    -- if no event handlers exist, just end this function
    if self.handlers[event] == nil then return end

    -- go through all the handlers that are registered to this event
    for i = 1, #self.handlers[event] do

        -- protected call of registered function
        self.success, self.err = xpcall(self.handlers[event][i], debug.traceback, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)

        -- did the function succeed without error?
        if self.success then
            self.stats.success = self.stats.success + 1

        -- function failed
        else
            print("Failed to call a function in event %s: %s\n", event, self.err)
            self.stats.failed = self.stats.failed + 1
        end
    end
end

function events:init()
    self:broadcast("EVENTSYS_LOADED")
end

events:init()
return events







