
local ui_menu_container = ui_base:extend("ui_menu_container",
{

})

function ui_menu_container:eventOnInit()
    self.flag_clickable = false
    self.flag_hoverable = false
    self.flag_render_background = false
    self.flag_render_border = true
    self.visible = false

    event:register(self.event_draw_post, self.eventOnDrawPost, self)
end


function ui_menu_container:eventOnDrawPost()
    if self.flag_render_border then
        love.graphics.rectangle("line", self.x1, self.y1, self.w, self.h)
        love.graphics.line(self.x1+self.parent.image_margin_size, self.y1, self.x1+self.parent.image_margin_size, self.y2)
    end

end

return ui_menu_container








