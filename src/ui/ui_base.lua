--[[
    Ui system

    How it works:

        -- creating the very first object that will house all other objects
        local void = ui_base(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), "void")
        void.color_back_normal = {21, 24, 28, 255}
        void.flag_render_border = false
        void.flag_render_clicked = false
        void.flag_render_hovered = false
        void.flag_render_focused = false

        -- lets add a menu to it
        local menMain = void:add(ui_menu, 50, 50, 100, 100, "mnuMain")
        local mnuFile = mnuMain:addMenu("File")
        local mnuEdit = mnuMain:addMenu("Edit")
        local mnuView = mnuMain:addMenu("View")
        local mnuHelp = mnuMain:addMenu("Help")

        -- register the mnuFile object's click event to a function
        event:register(mnuFile.event_mouse_down, eventOnMousePressed)
        function eventOnMousePressed(x, y, b)
            print(string.format("x: %d, y: %d, b: %s", x, y, b)
        end

    Function list for the base object(all other ui objects inheirt from this class):

        Internal functions:
            ui_base:init(x1, y1, x2, y2, uid, parent)              -- called when the object is created
            ui_base:update(dt)                                     -- called every update
            ui_base:draw()                                         -- called every frame
            ui_base:mousePressed()                                 -- called when the mouse is pressed on the object
            ui_base:mouseReleased()                                -- called when the mouse is released off the object
            ui_base:mouseMoved()                                   -- called when the mouse is moving

        Helper functions:
            ui_base:add(obj, x1, y1, x2, y2, uid)                  -- adds a child object
            ui_base:focus()                                        -- sets an object as focused
            ui_base:front()                                        -- brings the object to the front of it's siblings
            ui_base:back()                                         -- sends the object to the back of it's siblings
            ui_base:hasSiblings()                                  -- checks if the object has siblings
            ui_base:siblingTop()                                   -- gets the top sibling of this object
            ui_base:siblingBottom()                                -- gets the bottom sibling of this object
            ui_base:siblingTopZ()                                  -- gets the highest z number from the object's siblings
            ui_base:siblingBottomZ()                               -- gets the lowest z number from the object's siblings
            ui_base:siblingZSort()                                 -- sorts the object's siblings
            ui_base:hasChildren()                                  -- checks if the object has children
            ui_base:childTop()                                     -- gets the top child of this object
            ui_base:childBottom()                                  -- gets the bottom child of this object
            ui_base:childTopZ()                                    -- gets the highest z number from the object's children
            ui_base:childBottomZ()                                 -- gets the lowest z number from the object's children
            ui_base:childZSort()                                   -- sorts the object's children
            ui_base:isHovered()                                    -- checks if the object is hovered
            ui_base:isClicked()                                    -- checks if the object is captured
            ui_base:isFocused()                                    -- checks if the object is focused
            ui_base:isChecked()                                    -- checks if the object is checked
            ui_base:isChildFocused()                               -- checks if any of the object's children are focused
            ui_base:getFocusedObject()                             -- gets the currently focused object
            ui_base:getFocusedObjectPrevious()                     -- gets the previously focused object
            ui_base:getCapturedObject()                            -- gets the currently captured object
            ui_base:getCapturedObjectPrevious()                    -- gets the previously captured object
            ui_base:getHoveredObject()                             -- gets the currently hovered object
            ui_base:getHoveredObjectPrevious()                     -- gets the previously hovered object

            -- this event is automaticly registered
            ui_base:eventOnInit()
]]





local ui_base = class("ui_base",
{
    -- properties
    x1                       = 0,                               -- object's left position
    y1                       = 0,                               -- object's top position
    x2                       = 0,                               -- object's right position
    y2                       = 0,                               -- object's bottom position
    w                        = 0,                               -- object's width(readonly)
    h                        = 0,                               -- object's height(readonly)
    z                        = 0,                               -- object's z
    px1                      = 0,                               -- object's previous left position
    py1                      = 0,                               -- object's previous top position
    px2                      = 0,                               -- object's previous right position
    py2                      = 0,                               -- object's previous bottom position
    font                     = nil,                             -- object's font
    checked                  = false,                           -- is the object checked?
    disabled                 = false,                           -- is the object disabled?
    visible                  = true,                            -- is the object visible?
    text                     = "",                              -- text
    text_x                   = 0,                               -- text x position(readonly)
    text_y                   = 0,                               -- text y position(readonly)
    text_xoff                = 0,                               -- text x offset
    text_yoff                = 0,                               -- text y offset
    text_halign              = "center",                        -- text horiz alignment(left, center, right)
    text_valign              = "center",                        -- text vert alignment(top, center, bottom)
    anchor                   = { false, false, false, false },  -- this object's parent anchors {top, bottom, left, right}

    -- colors
    color_back_normal        = {0.1, 0.2, 0.3, 1.0},            -- normal back color
    color_back_hovered       = {0.4, 0.5, 0.6, 1.0},            -- hovered back color
    color_back_focused       = {0.2, 0.3, 0.4, 1.0},            -- focused back color
    color_back_clicked       = {0.0, 0.1, 0.2, 1.0},            -- clicked back color
    color_back_disabled      = {0.3, 0.3, 0.3, 1.0},            -- disabled back color
    color_back_checked       = {0.3, 0.4, 0.5, 1.0},            -- checked back color

    color_border_normal      = {0.9, 0.9, 0.9, 1.0},            -- normal border color
    color_border_hovered     = {1.0, 1.0, 1.0, 1.0},            -- hovered border color
    color_border_focused     = {1.0, 1.0, 1.0, 1.0},            -- focused border color
    color_border_clicked     = {0.4, 0.4, 0.4, 1.0},            -- clicked border color
    color_border_disabled    = {0.5, 0.5, 0.5, 1.0},            -- disabled border color
    color_border_checked     = {0.0, 0.8, 0, 1.0},              -- disabled border color

    color_text_normal        = {1.0, 1.0, 1.0, 1.0},            -- normal text color
    color_text_hovered       = {1.0, 1.0, 1.0, 1.0},            -- hovered text color
    color_text_focused       = {1.0, 1.0, 1.0, 1.0},            -- focused text color
    color_text_clicked       = {1.0, 1.0, 1.0, 1.0},            -- clicked text color
    color_text_disabled      = {1.0, 1.0, 1.0, 1.0},            -- disabled text color
    color_text_checked       = {1.0, 1.0, 1.0, 1.0},            -- disabled text color

    -- flags
    flag_render_background   = true,                            -- should we render the background?
    flag_render_border       = true,                            -- should we render the border?
    flag_render_clicked      = true,                            -- should we render being clicked?
    flag_render_hovered      = true,                            -- should we render being hovered?
    flag_render_focused      = true,                            -- should we render when we are the focused object?
    flag_render_checked      = true,                            -- should we render being checked?
    flag_render_disabled     = true,                            -- should we render being disabled?
    flag_render_text         = false,                           -- should we render text?
    flag_clickable           = true,                            -- is this object clickable?
    flag_hoverable           = true,                            -- is this object hoverable?
    flag_focusable           = true,                            -- is this object focusable?
    flag_checkable           = false,                           -- is this object chackable?
    flag_passthough          = false,                           -- allow the click to pass through this object?
    flag_anchorable          = true,                            -- allow the sides of this object to be anchored to it's parent

    -- internal
    children                 = {},                              -- table with all of the children objects
    parent                   = nil,                             -- this object's parent
    root                     = nil,                             -- this objects's first generation parent
    focused                  = nil,                             -- object pointer to the currently focused object
    focusedp                 = nil,                             -- object pointer to the currently focused object, previous frame
    captured                 = nil,                             -- object pointer to the currently captured(clicked) object
    capturedp                = nil,                             -- object pointer to the currently captured(clicked) object, previous frame
    hovered                  = nil,                             -- object pointer to the currently hovered object
    hoveredp                 = nil,                             -- object pointer to the previous hovered object, previous frame

    -- events
    -- these are dynamicly created with the objects uid
    event_init                      = "",                       -- name of the init event
    event_update_pre                = "",                       -- name of the update event
    event_update_post               = "",                       -- name of the update event
    event_draw_pre                  = "",                       -- name of the draw event
    event_draw_post                 = "",                       -- name of the draw event
    event_add                       = "",                       -- name of the add event
    event_focused                   = "",                       -- name of the focused event
    event_unfocused                 = "",                       -- name of the unfocused event
    event_checked                   = "",                       -- name of the checked event
    event_mouse_down                = "",                       -- name of the mouse down event
    event_mouse_up                  = "",                       -- name of the mouse up event
    event_mouse_enter               = "",                       -- name of the enter event
    event_mouse_leave               = "",                       -- name of the leave event
})

--------------------------------------------------------------
-- make object
--------------------------------------------------------------
function ui_base:init(x1, y1, x2, y2, uid, parent, ...)

    -- uid check
    if type(uid) ~= "string" then debugEx:err("Invalid GUI Object UID") end

    -- setup relationships
    if parent == nil then parent = self end
    if parent.root == nil then self.root = self end
    self.parent = parent
    self.root = self.parent.root

    -- setup properties
    self.uid = string.upper(uid)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2
    self.font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))

    -- bring this object to the front
    self:front()

    -- setup events
    self.event_init             = string.format("GUI_%s_INIT", self.uid)
    self.event_update_pre       = string.format("GUI_%s_UPDATE_PRE", self.uid)
    self.event_update_post      = string.format("GUI_%s_UPDATE_POST", self.uid)
    self.event_draw_pre         = string.format("GUI_%s_DRAW_PRE", self.uid)
    self.event_draw_post        = string.format("GUI_%s_DRAW_POST", self.uid)
    self.event_add              = string.format("GUI_%s_ADD", self.uid)
    self.event_focused          = string.format("GUI_%s_FOCUSED", self.uid)
    self.event_unfocused        = string.format("GUI_%s_UNFOCUSED", self.uid)
    self.event_mouse_down       = string.format("GUI_%s_MOUSE_PRESSED", self.uid)
    self.event_mouse_up         = string.format("GUI_%s_MOUSE_RELEASED", self.uid)
    self.event_mouse_moved      = string.format("GUI_%s_MOUSE_MOVED", self.uid)
    self.event_mouse_enter      = string.format("GUI_%s_MOUSE_ENTERED", self.uid)
    self.event_mouse_leave      = string.format("GUI_%s_MOUSE_LEFT", self.uid)
    self.event_checked          = string.format("GUI_%s_CHECKED", self.uid)

    -- broadcast that this object has finished loading
    event:register(self.event_init, self.eventOnInit, self)
    event:broadcast(self.event_init, self, ...)
end

--------------------------------------------------------------
-- update object
--------------------------------------------------------------
function ui_base:update(dt)

    -- broadcast the pre update event
    event:broadcast(self.event_update_pre, self, dt)

    -- calculate width/height of the object(read-only)
    self.w = self.x2-self.x1+1
    self.h = self.y2-self.y1

    -- anchoring
    if self.flag_anchorable then

        -- top
        if self.parent.y1 ~= self.parent.py1 then
            if self.anchor[1] then
                self.y1 = self.y1 + (self.parent.y1 - self.parent.py1)
                if not self.anchor[2] then
                    self.y2 = self.y1 + self.h
                end
            end
        end

        -- bottom
        if self.parent.y2 ~= self.parent.py2 then
            if self.anchor[2] then
                self.y2 = self.y2 + (self.parent.y2 - self.parent.py2)
                if not self.anchor[1] then
                    self.y1 = self.y2 - self.h
                end
            end
        end

        -- left
        if self.parent.x1 ~= self.parent.px1 then
            if self.anchor[3] then
                self.x1 = self.x1 + (self.parent.x1 - self.parent.px1)
                if not self.anchor[4] then
                    self.x2 = self.x1 + self.w
                end
            end
        end

        -- right
        if self.parent.x2 ~= self.parent.px2 then
            if self.anchor[4]  then
                self.x2 = self.x2 + (self.parent.x2 - self.parent.px2)
                if not self.anchor[3] then
                    self.x1 = self.x2 - self.w
                end
            end
        end
    end

    -- run through the children and call their update function
    for i = 1, #self.children do
        self.children[i]:update(dt)
    end

    -- set previous values for next update
    self.px1 = self.x1
    self.px2 = self.x2
    self.py1 = self.y1
    self.py2 = self.y2

    -- broadcast the post update event
    event:broadcast(self.event_update_post, self, dt)
end

--------------------------------------------------------------
-- draw object
--------------------------------------------------------------
function ui_base:draw()

    if self.visible == false then return end

    --love.graphics.setcolor(1.0, 1.0, 1.0, 1.0)
    -- send out pre draw event
    event:broadcast(self.event_draw_pre, self)

    -- should we render the background?
    if self.flag_render_background then

        -- set backcolor
        love.graphics.setColor(self.color_back_normal)
        if self.checked and self.flag_render_checked then love.graphics.setColor(self.color_back_checked) end
        if self:isFocused() and self.flag_render_focused then love.graphics.setColor(self.color_back_focused) end
        if self:isHovered() and self.flag_render_hovered then love.graphics.setColor(self.color_back_hovered) end
        if self:isClicked() and self.flag_render_clicked then love.graphics.setColor(self.color_back_clicked) end
        if self.disabled and self.flag_render_disabled then love.graphics.setColor(self.color_back_disabled) end

        love.graphics.rectangle("fill", self.x1, self.y1, self.w, self.h)

    end

    -- should we render the border?
    if self.flag_render_border then

        -- set border color
        love.graphics.setColor(self.color_border_normal)
        if self.checked and self.flag_render_checked then love.graphics.setColor(self.color_border_checked) end
        if self:isFocused() and self.flag_render_focused then love.graphics.setColor(self.color_border_focused) end
        if self:isHovered() and self.flag_render_hovered then love.graphics.setColor(self.color_border_hovered) end
        if self:isClicked() and self.flag_render_clicked then love.graphics.setColor(self.color_border_clicked) end
        if self.disabled and self.flag_render_disabled then love.graphics.setColor(self.color_border_disabled) end

        love.graphics.rectangle("line", self.x1, self.y1, self.w, self.h)

    end

    -- should we render the text?
    if self.flag_render_text then
        love.graphics.setFont(self.font)

        love.graphics.setColor(self.color_text_normal)
        if self.checked and self.flag_render_checked then love.graphics.setColor(self.color_text_checked) end
        if self:isFocused() and self.flag_render_focused then love.graphics.setColor(self.color_text_focused) end
        if self:isHovered() and self.flag_render_hovered then love.graphics.setColor(self.color_text_hovered) end
        if self:isClicked() and self.flag_render_clicked then love.graphics.setColor(self.color_text_clicked) end
        if self.disabled and self.flag_render_disabled then love.graphics.setColor(self.color_text_disabled) end

        if self.text_valign == "center" then
            self.text_y = ((self.h/2)-(self.font:getHeight()/2))
        end

        if self.text_valign == "bottom" then
            self.text_y = self.h-self.font:getHeight()
        end

        love.graphics.printf(self.text, self.x1+self.text_x+self.text_xoff, self.y1+self.text_y+self.text_yoff, self.w, self.text_halign)
    end

    -- run through the children and call their draw functions
    for i = 1, #self.children do
        self.children[i]:draw()
    end

    -- send out post draw event
    event:broadcast(self.event_draw_post, self)

end

--------------------------------------------------------------
-- mouse pressed
--------------------------------------------------------------
function ui_base:mousePressed(x, y, b)

    if self.visible == false then return end

    -- run through all the children first, and backwards
    for i = #self.children, 1, -1 do
        self.children[i]:mousePressed(x, y, b)
    end

    -- check if an object has claimed the click
    if self.root.captured == nil then

        -- check bounds
        if x >= self.x1 and x <= self.x2 and y >= self.y1 and y <= self.y2 then

            -- check if this object is clickable
            if self.flag_clickable then

                -- if this object is checkable
                if self.flag_checkable then

                    -- swap its checked state
                    self.checked = not self.checked
                    event:broadcast(self.event_checked, self)
                end

                --bring this object to the front
                self:front()

                -- set this object as the focused object
                self:focus()

                -- send mouse pressed event
                event:broadcast(self.event_mouse_down, self)
            end

            -- tell all other objects that an object has been clicked
            -- do this outside the clickable flag so the mouse click doesnt fall through the object
            if not self.flag_passthrough then
                self.root.capturedp = self.root.captured
                self.root.captured = self
            end
        end
    end
end

--------------------------------------------------------------
-- mouse released
--------------------------------------------------------------
function ui_base:mouseReleased(x, y, b)

    if self.visible == false then return end

    -- run through all the children first, and backwards
    for i = #self.children, 1, -1 do
        self.children[i]:mouseReleased(x, y, b)
    end

    -- check if we are at the end of the line on the hierarchy
    if self.root == self then

        -- is this object clickable?
        if self.flag_clickable then

            -- send mouse released event
            event:broadcast(self.root.captured.event_mouse_up, self.root.captured)
        end

        -- reset captured object for the next mouse press run
        self.root.capturedp = self.root.captured
        self.root.captured = nil
    end
end


--------------------------------------------------------------
-- mouse moved
--------------------------------------------------------------
function ui_base:mouseMoved(x, y, dx, dy)

    if self.visible == false then return end

    -- if we are at the end of the hierarchy
    if self.root == self then

        -- save the previous hovered object
        self.root.hoveredp = self.root.hovered

        -- remove the hovered object for the next mouse move
        self.root.hovered = nil
    end

    -- run through all the children first, and backwards
    for i = #self.children, 1, -1 do
        self.children[i]:mouseMoved(x, y, dx, dy)
    end

    -- check if an object has claimed the hover
    if self.root.hovered == nil then

        -- check bounds
        if x >= self.x1 and x <= self.x2 and y >= self.y1 and y <= self.y2 then

            -- check if the previous hovered object is not this object
            -- instead of having the system constantly call the hovered event every mouse move
            -- this allows it to only happen once
            if self.root.hoveredp ~= self then

                -- check if this object is hoverable
                if self.flag_hoverable then

                    -- only do an enter event if something isnt captured by a click
                    if self.root.captured == nil then

                        -- send entered event
                        event:broadcast(self.event_mouse_enter, self)
                    end
                end
            end

            -- tell all other objects that an object has been hovered
            -- do this outside the clickable flag so the mouse click doesnt fall through the object
            if not self.flag_passthrough then
                self.root.hovered = self
            end
        end
    end

    -- check if the mouse has left this object
    if self.root.hoveredp == self and self.root.hovered ~= self then

        -- only do an enter event if something isnt captured by a click
        if self.root.captured == nil then

            if self.flag_hoverable then
                -- send mouse left event
                event:broadcast(self.event_mouse_leave, self)
            end
        end
    end
end


--------------------------------------------------------------
-- add object
--------------------------------------------------------------
function ui_base:add(obj, x1, y1, x2, y2, uid)

    -- get next child index
    local i = #self.children+1

    -- create child object
    self.children[i] = obj(x1, y1, x2, y2, uid, self)

    -- sen out an add object event
    event:broadcast(self.event_add, self, self.children[i])

    -- return the newly created object
    return self.children[i]
end

--------------------------------------------------------------
-- sets this object as the focused object
--------------------------------------------------------------
function ui_base:focus()

    -- check if this object is focusable
    if self.flag_focusable then

        -- set the focused object as ourself
        self.root.focusedp = self.root.focused
        self.root.focused = self

        -- send out a focus lost event on behalf of the previous focused object
        event:broadcast(self.root.focusedp.event_unfocused, self.root.focusedp)

        -- send out a focus event
        event:broadcast(self.event_focused, self)
    end
end

--------------------------------------------------------------
-- bring the object to the front of all it's siblings
--------------------------------------------------------------
function ui_base:front()
    if self.parent == self then return false end
    self.z = self:siblingTopZ() + 1
    self:siblingZSort()
    self.parent:front()
end

--------------------------------------------------------------
-- send the object to the back of all it's siblings
--------------------------------------------------------------
function ui_base:back()
    self.z = self:siblingBottomZ() - 1
    self:siblingZSort()
    self.parent:back()
end

--------------------------------------------------------------
-- returns true if this object has any siblings
--------------------------------------------------------------
function ui_base:hasSiblings()
    if #self.parent.children > 1 then return true else return false end
end

--------------------------------------------------------------
-- returns the object that is at the top of the child list
--------------------------------------------------------------
function ui_base:getSiblingTop()
    return self.parent.children[1]
end

--------------------------------------------------------------
-- returns the object that is at the bottom of the child list
--------------------------------------------------------------
function ui_base:getSiblingBottom()
    return self.parent.children[#self.parent.children]
end

--------------------------------------------------------------
-- get the top most sibling z
--------------------------------------------------------------
function ui_base:siblingTopZ()
    local last = 0
    for i, v in ipairs(self.parent.children) do
        last = v.z
    end

    return last
end

--------------------------------------------------------------
-- get the bottom most sibling z
--------------------------------------------------------------
function ui_base:siblingBottomZ()
    local last = nil
    for i, v in ipairs(self.parent.children) do
        last = v
    end
    return last.z
end

--------------------------------------------------------------
-- sort siblings by z
--------------------------------------------------------------
function ui_base:siblingZSort()
    table.sort(self.parent.children,
    function(a,b)
        if a and b then
            return a.z<b.z
        end
    end)
end

--------------------------------------------------------------
-- returns true if this object has any children
--------------------------------------------------------------
function ui_base:hasChildren()
    if #self.children > 0 then return true else return false end
end

--------------------------------------------------------------
-- returns the object that is at the top of the child list
--------------------------------------------------------------
function ui_base:getChildTop()
    return self.children[1]
end

--------------------------------------------------------------
-- returns the object that is at the bottom of the child list
--------------------------------------------------------------
function ui_base:getChildBottom()
    return self.children[#self.children]
end


--------------------------------------------------------------
-- get the top most child z
--------------------------------------------------------------
function ui_base:childTopZ()
    local last = 0
    for i, v in ipairs(self.children) do
        last = v.z
    end

    return last
end

--------------------------------------------------------------
-- get the bottom most child z
--------------------------------------------------------------
function ui_base:childBottomZ()
    local last = nil
    for i, v in ipairs(self.children) do
        last = v
    end
    return last.z
end

--------------------------------------------------------------
-- sort children by z
--------------------------------------------------------------
function ui_base:childZSort()
    table.sort(self.children,
    function(a,b)
        if a and b then
            return a.z<b.z
        end
    end)
end

--------------------------------------------------------------
-- returns true if the object is being hovered over
--------------------------------------------------------------
function ui_base:isHovered()
    if self.root.hovered == self and self.flag_hoverable then return true end
    return false
end

--------------------------------------------------------------
-- returns true if the object is being clicked
--------------------------------------------------------------
function ui_base:isClicked()
    if self.root.captured == self and self.flag_clickable then return true end
    return false
end

--------------------------------------------------------------
-- returns true if the object is checked
--------------------------------------------------------------
function ui_base:isFocused()
    if self:getFocusedObject() == self and self.flag_focusable then return true end
    return false
end

--------------------------------------------------------------
-- returns true if any of this object's children are focused
--------------------------------------------------------------
function ui_base:isChildFocused()
    for i = 1, #self.children do
        if self.children[i] == self:getFocusedObject() then
            return true
        end
    end
    return false
end

--------------------------------------------------------------
-- returns true if any of this object's children are hovered
--------------------------------------------------------------
function ui_base:isChildHovered()
    for i = 1, #self.children do
        if self.children[i] == self:getHoveredObject() then
            return true
        end
    end
    return false
end

--------------------------------------------------------------
-- returns the object that is currently focused
--------------------------------------------------------------
function ui_base:getFocusedObject()
    return self.root.focused
end

--------------------------------------------------------------
-- returns the object that that was previously focused
--------------------------------------------------------------
function ui_base:getFocusedObjectPrevious()
    return self.root.focusedp
end

--------------------------------------------------------------
-- returns the object that is currently focused
--------------------------------------------------------------
function ui_base:getCapturedObject()
    return self.root.captured
end

--------------------------------------------------------------
-- returns the object that is currently focused
--------------------------------------------------------------
function ui_base:getCapturedObjectPrevious()
    return self.root.capturedp
end

--------------------------------------------------------------
-- returns the object that is currently focused
--------------------------------------------------------------
function ui_base:getHoveredObject()
    return self.root.hovered
end

--------------------------------------------------------------
-- returns the object that is currently focused
--------------------------------------------------------------
function ui_base:getHoveredObjectPrevious()
    return self.root.hoveredp
end

--------------------------------------------------------------
-- event callbacks
--------------------------------------------------------------
function ui_base:eventOnInit() end

return ui_base





