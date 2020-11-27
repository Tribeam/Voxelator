local clsWorld = class("clsWorld", {})


function clsWorld:init()

	self.renderer = MR.renderer.new()
	self.camera = MR.camera.new()
	self.scene = MR.scene.new()
	self.scene.ambient_color = { 1.0, 1.0, 1.0 }
	self.speed = 100
	self.av = Cpml.vec3(0, 0, 0)
	self.rv = math.pi
	self.camera:move_to(0, 0, 0, math.rad(60), 0, 0)
	self.renderer.render_shadow = false

	-- ground
	self.ground_model = MR.model.new_plane(16, 16)
	self.ground_model:set_opts({ instance_usage = 'static' })

	local instances = {}
	local r1 = 0.1
	local g1 = 0.15
	local b1 = 0.2

	local r2 = 0.2
	local g2 = 0.25
	local b2 = 0.3

	local r3 = r1
	local g3 = g1
	local b3 = b1

	local color_alternate = false

	for x = 1, 64 do
		color_alternate = not color_alternate
		for y = 1, 64 do
			color_alternate = not color_alternate
			if(color_alternate) then
				r3 = r1
				g3 = g1
				b3 = b1
			else
				r3 = r2
				g3 = g2
				b3 = b2
			end
			table.insert(instances,
			{
				640-x*16, 0, 640-y*16,
				0, 0, 0,
				1, 1, 1,
				r3, g3, b3, 1,
				0, 0
			})
		end
	end

	self.ground_model:set_raw_instances(instances)

	local apppath = love.filesystem.getSourceBaseDirectory()
	self.vox = fileVox(apppath .. "/voxels/1975_tank_shoot1.vox")

	self.projection = "perspective"
end

function clsWorld:update(dt)

	if self.camera then

		-- mouse
		self.rv = math.pi * dt
		self.av.x = self.av.x - self.rv * mouse.dy
		self.av.y = self.av.y - self.rv * mouse.dx

		local a = -self.camera.rotation.y-math.rad(90)
		local p = self.camera.rotation.x-math.rad(90)
		local speed = 0

		-- keyboard
		if(love.keyboard.isDown('w')) then
			speed = self.speed
		end
		if(love.keyboard.isDown('s')) then
			speed = -self.speed
		end
		if(love.keyboard.isDown('a')) then
			speed = self.speed
			a = a-math.rad(90)
			p = 0
		end
		if(love.keyboard.isDown('d')) then
			speed = self.speed
			a = a+math.rad(90)
			p = 0
		end

		if(love.keyboard.isDown('a') and love.keyboard.isDown('w')) then
			a = a+math.rad(45)
			p = self.camera.rotation.x-math.rad(90)
		end
		if(love.keyboard.isDown('a') and love.keyboard.isDown('s')) then
			a = a-math.rad(45)
			p = self.camera.rotation.x-math.rad(90)
		end
		if(love.keyboard.isDown('d') and love.keyboard.isDown('w')) then
			a = a-math.rad(45)
			p = self.camera.rotation.x-math.rad(90)
		end

		if(love.keyboard.isDown('rshift') or love.keyboard.isDown('lshift')) then
			speed = speed * 3
		end

		local x = self.camera.pos.x + math.cos(a) * math.cos(p) * (dt * speed)
		local z = self.camera.pos.z + math.sin(a) * math.cos(p) * (dt * speed)
		local y = self.camera.pos.y + math.sin(p) * (dt * speed)

		--if(y <= 0) then y = 0 else y = y - 0.1 end

		self.camera:move_to(x, y, z, (self.camera.rotation + self.av):unpack())

		speed = 0
		self.av.x = 0
		self.av.y = 0
	end

end

function clsWorld:draw()
	local w, h = love.graphics.getDimensions()
	if(self.projection == "perspective") then
		local hw, hh = w * 0.5, h * 0.5
		self.camera:perspective(70, w / h, 1, 3000)
	else
		local hw, hh = w / 2, h / 2
		self.camera:orthogonal(-hw, hw, hh, -hh, 1, 3000)
	end
	self.renderer:apply_camera(self.camera)
	self.scene:add_model(self.vox.voxel.model)
	self.scene:add_model(self.ground_model)

	love.graphics.clear(0.05, 0.1, 0.15)
	self.renderer:render(self.scene:build())
	self.scene:clean_model()

end

return clsWorld
