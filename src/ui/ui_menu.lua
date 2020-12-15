
local ui_menu = ui_base:extend("ui_menu",
{
    child_padding = 0,
    text_padding = 10,
    activated = false,
})

function ui_menu:eventOnInit()

    self.x1 = self.parent.x1
    self.x2 = self.parent.x2
    self.y1 = self.parent.y1
    self.y2 = self.parent.y1+20
    self.flag_render_clicked = false
    self.flag_render_hovered = false
    self.flag_render_focused = false

end

function ui_menu:addItem(name, uid)
    local item = self:add(ui_menu_item, 0, 0, 0, 0, uid)
    item.text = name

    self:refreshPositions()
    return item
end

function ui_menu:refreshPositions()
    local x1 = 0
    local x2 = 0
    for i = 1, #self.children do
        if i == 1 then
            x1 = self.child_padding
            x2 = x1 + self.font:getWidth(self.children[i].text)+self.text_padding
        else
            x1 = self.children[i-1].x2 + self.child_padding
            x2 = x1 + self.font:getWidth(self.children[i].text)+self.text_padding
        end
        self.children[i].x1 = x1
        self.children[i].x2 = x2
        self.children[i].y1 = self.y1
        self.children[i].y2 = self.y2
    end
end

return ui_menu








