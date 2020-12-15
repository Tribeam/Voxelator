
function love.load()

	love.window.maximize()
	love.graphics.setLineStyle("rough")
	MR = require 'renderer'
	Cpml = require 'Cpml'


	class				= require("mod30log")
	event				= require("events")
	clsWorld			= require("clsWorld")
	clsVoxel			= require("clsVoxel")
	clsProject			= require("clsProject")
	fileVox				= require("fileVox")
	ui_base				= require("ui/ui_base")
	ui_menu				= require("ui/ui_menu")
	ui_menu_container	= require("ui/ui_menu_container")
	ui_menu_item		= require("ui/ui_menu_item")

	project = clsProject()

	mouse = {}
	mouse.x = 0
	mouse.y = 0
	mouse.dx = 0
	mouse.dy = 0

    void = ui_base(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), "void")
    void.color_back_normal = {21, 24, 28, 255}
    void.flag_render_border = false
    void.flag_render_clicked = false
    void.flag_render_hovered = false
    void.flag_render_focused = false
	void.flag_render_background = false
    void.focused = void
    void.focusedp = void

    local mnuMain = void:add(ui_menu, 50, 50, 100, 100, "mnuMain")

        local mnuFile = mnuMain:addItem("File", "mnuFile")
        local mnuImport = mnuFile:addItem("Import", "mnuImport")
			local mnuImportSlab 	= mnuImport:addItem("Slab", "mnuImportSlab")
			local mnuImportMagica 	= mnuImport:addItem("Magica", "mnuImportMagica")
			local mnuImportSlice 	= mnuImport:addItem("Slice", "mnuImportSlice")


        local mnuExport = mnuFile:addItem("Export", "mnuExport")
        local mnuExit = mnuFile:addItem("Exit", "mnuExit")

    event:register("EVENTSYS_LOADED", void.init)
    event:register("CORE_UPDATE", void.update)
    event:register("CORE_DRAW", void.draw)
    event:register("CORE_MOUSE_PRESSED", void.mousePressed)
    event:register("CORE_MOUSE_RELEASED", void.mouseReleased)
    event:register("CORE_MOUSE_MOVED", void.mouseMoved)
    event:broadcast("CORE_LOADED")

end

function love.update(dt)
	event:broadcast("CORE_UPDATE", void, dt)
	if love.keyboard.isDown('escape') then love.event.quit("User Requested.") end
	project:update(dt)
	mouse.dx = 0
	mouse.dy = 0
end

function love.draw()
	project:draw()
	event:broadcast("CORE_DRAW", void)
end

function love.resize(x, y)
	event:broadcast("CORE_RESIZE", void, w, h)
	project:resize()
end

function love.mousemoved(x, y, dx, dy, istouch)
	mouse.dx = dx
	mouse.dy = dy
	event:broadcast("CORE_MOUSE_MOVED", void, x, y, dx, dy)
end

function love.mousepressed(x, y, b)
    event:broadcast("CORE_MOUSE_PRESSED", void, x, y, b)
end

function love.mousereleased(x, y, b)
    event:broadcast("CORE_MOUSE_RELEASED", void, x, y, b)
end

function love.mousefocus(focus)
    event:broadcast("CORE_MOUSE_FOCUS", void, focus)
end

function love.wheelmoved(x, y)
    event:broadcast("CORE_MOUSE_WHEEL", void, x, y)
end

function love.textinput(text)
	event:broadcast("CORE_TEXT_INPUT", void, t)
	project:input()
end













