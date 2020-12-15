
local ui_menu_item = ui_base:extend("ui_menu_item",
{
    child_padding = 0,
    text_padding = 10,
    longest_child_text = 0,
    child_extention = 50,
    last_child_y2 = 0,
    image_margin_size = 32,
    is_submenu = false,
    container = nil,
})

function ui_menu_item:eventOnInit(subtext)

    self.flag_render_text = true

    --event:register(self.event_mouse_down, self.eventOnMouseDown, self)
    event:register(self.event_focused, self.eventOnFocused, self)
    event:register(self.event_unfocused, self.eventOnUnfocused, self)
    --event:register(self.event_draw, self.eventOnDraw, self)
    event:register(self.event_mouse_enter, self.eventOnMouseEnter, self)
    event:register(self.event_mouse_leave, self.eventOnMouseLeave, self)

end

function ui_menu_item:eventOnFocused()
    if self.container ~= nil then self.container.visible = true end
end

function ui_menu_item:eventOnUnfocused()
    if self.container ~= nil then self.container.visible = false end
end

function ui_menu_item:eventOnMouseEnter()
    if self.is_submenu then
        if self.container ~= nil then
            self.container.visible = true
        end
    end
end

function ui_menu_item:eventOnMouseLeave()
    if self.is_submenu then
        if self.container ~= nil then
            if not self.container:isChildHovered() then
                self.container.visible = false
            end
        end
    end
end

function ui_menu_item:addItem(name, uid)

    -- create the container only if we are adding children to this menu item
    if #self.children == 0 then
        self.container = self:add(ui_menu_container, 0, 0, 0, 0, self.uid .. "_PANEL")
    end

    -- create the item inside the container
    local item = self.container:add(ui_menu_item, 0, 0, 0, 0, uid)
    item.text = name
    item.visible = true
    item.text_halign = "left"
    item.text_xoff = self.image_margin_size+5
    item.flag_render_border = false
    item.is_submenu = true

    -- keep track of the longest name
    if self.longest_child_text < self.font:getWidth(name) then self.longest_child_text = self.font:getWidth(name) end

    -- reposition everything neatly
    self:repositionItems()

    return item
end

function ui_menu_item:repositionItems()

    -- set container position
    if self.is_submenu then
        self.container.x1 = self.x2
        self.container.y1 = self.y1
    else
        self.container.x1 = self.x1
        self.container.y1 = self.y2
    end

    self.container.x2 = self.container.x1+self.image_margin_size+self.child_extention+self.longest_child_text

    -- for each child object
    for i = 1, #self.container.children do

        -- if we are the first object in the child list
        if i == 1 then

            -- position it at the top
            self.container.children[i].y1 = self.container.y1
        else

            -- position it under the prvious child
            self.container.children[i].y1 = self.container.children[i-1].y2
        end

        -- fit the child to the container
        self.container.children[i].x1 = self.container.x1
        self.container.children[i].x2 = self.container.x2

        -- size it
        self.container.children[i].y2 = self.container.children[i].y1+self.font:getHeight()+self.text_padding

        -- set container height
        self.container.y2 = self.container.children[i].y2

    end

end

return ui_menu_item








