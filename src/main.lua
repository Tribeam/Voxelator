
function love.load()
	MR = require 'renderer'
	Cpml = require 'Cpml'

	lg = love.graphics
	lkb = love.keyboard

	renderer = MR.renderer.new()
	camera = MR.camera.new()
	scene = MR.scene.new()

	mouse = {}
	mouse.x = 0
	mouse.y = 0
	mouse.dx = 0
	mouse.dy = 0
	mouse.px = 0
	mouse.py = 0

	-- voxel setup
	love.graphics.setDefaultFilter("nearest", "nearest", 0)
	love.graphics.setLineStyle("rough")
	love.mouse.setRelativeMode(true)

	class		= require("mod30log")
	clsVoxel	= require("clsVoxel")
	fileVox		= require("fileVox")

	local apppath = love.filesystem.getSourceBaseDirectory()
	vox = fileVox(apppath .. "/voxels/WALL57_2.vox")

	camera:move_to(0, 0, 0, math.rad(60), 0, 0)

end

local test = 0
function love.update(dt)
	test = test + dt
	if camera then

		-- keyboard
		local mv = 200 * dt
		local dv = Cpml.vec3(0, 0, 0)
		if lkb.isDown('a') then dv.x = dv.x - mv end
		if lkb.isDown('d') then dv.x = dv.x + mv end
		if lkb.isDown('w') then dv.z = dv.z - mv end
		if lkb.isDown('s') then dv.z = dv.z + mv end
		if lkb.isDown('q') then dv.y = dv.y - mv end
		if lkb.isDown('e') then dv.y = dv.y + mv end
		if lkb.isDown('[') then near = near - mv end
		if lkb.isDown(']') then near = near + mv end
		if lkb.isDown('-') then far = far - mv end
		if lkb.isDown('=') then far = far + mv end
		if lkb.isDown('t') then fov = fov + dt * 20 end
		if lkb.isDown('g') then fov = fov - dt * 20 end
		if lkb.isDown('escape') then love.event.quit("User Requested.") end

		local rv = math.pi * dt
		local av = Cpml.vec3(0, 0, 0)
		if lkb.isDown('j') then av.y = av.y - rv end
		if lkb.isDown('l') then av.y = av.y + rv end
		if lkb.isDown('i') then av.x = av.x - rv end
		if lkb.isDown('k') then av.x = av.x + rv end
		if lkb.isDown('u') then av.z = av.z - rv end
		if lkb.isDown('o') then av.z = av.z + rv end

		-- mouse
		av.x = av.x - rv * mouse.dy
		av.y = av.y - rv * mouse.dx

		local yangle = camera.rotation.y + av.y
		local xangle = camera.rotation.z + av.z

		local c = math.cos(-yangle)
		local s = math.sin(-yangle)
		local r = math.sin(-xangle)

		dv.x, dv.z = c * dv.x - s * dv.z, s * dv.x + c * dv.z


		local p = camera.pos + dv
		camera:move_to(p.x, p.y, p.z, (camera.rotation + av):unpack())

		mouse.dy = 0
		mouse.dx = 0
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	mouse.x = x
	mouse.y = y
	mouse.dx = dx
	mouse.dy = dy
end


function love.draw()
	local w, h = love.graphics.getDimensions()
	local hw, hh = w * 0.5, h * 0.5
	camera:perspective(70, w / h, 1, 3000)

	local x = math.cos(test)*128
	local y = math.sin(test)*128

	renderer:apply_camera(camera)

	scene:add_model(vox.voxel.model)

	lg.clear(0.0, 0.0, 0.0)
	renderer:render(scene:build())
	scene:clean_model()

end