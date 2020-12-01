local clsWorld = class("clsWorld", {})


function clsWorld:init(voxel)

	self.renderer = MR.renderer.new()
	self.camera = MR.camera.new()
	self.scene = MR.scene.new()
	self.renderer.render_shadow = false

	self.speed = 200
	self.gravity = 200
	self.vely = 0
	self.av = Cpml.vec3(0, 0, 0)
	self.rv = math.pi
	self.camera:move_to(0, 0, 0, math.rad(60), 0, 0)
	self.projection = "perspective"
	self.voxel = voxel
	self.renderer.render_shader:send("pal", unpack(self.voxel.palette))
	self.fly = true
	self.buttonheld = false
	self.shade = true
	self.renderer.render_shader:send("cubeshade", self.shade)

	-- ground
	self.ground_model = MR.model.new_plane(16, 16)
	self.ground_model:set_opts({ instance_usage = 'static' })
	local instances = {}
	local r1 = 0.3
	local g1 = 0.2
	local b1 = 0.1

	local r2 = 0.2
	local g2 = 0.25
	local b2 = 0.3

	local r3 = r1
	local g3 = g1
	local b3 = b1

	local color_alternate = false
--[[
	for x = 1,256 do
		color_alternate = not color_alternate
		for y = 1, 256 do
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
				(256/2)-x, -0.5, (256/2)-y,
				0, 0, 0,
				0.06, 0.06, 0.06,
				r3, g3, b3, 1,
				0, 1
			})
		end
	end
	]]
	table.insert(instances,
	{
		0, 0, 0,
		0, 0, 0,
		25, 25, 25,
		r3, g3, b3, 1,
		0, 1
	})
	self.ground_model:set_raw_instances(instances)

end

function clsWorld:resize()
	self.renderer = MR.renderer.new()
	self.renderer.render_shadow = false
	self.renderer.render_shader:send("pal", unpack(self.voxel.palette))
	self.renderer.render_shader:send("cubeshade", self.shade)
end


function clsWorld:update(dt)

	if self.camera then

		-- keyboard
		if(love.keyboard.isDown("c")) then
			love.mouse.setRelativeMode(false)
		else
			love.mouse.setRelativeMode(true)
			self.rv = math.pi * dt
			self.av.x = self.av.x - self.rv * (mouse.dy/2)
			self.av.y = self.av.y - self.rv * (mouse.dx/2)

			local a = -self.camera.rotation.y-math.rad(90)
			local p = self.camera.rotation.x-math.rad(90)
			local speed = 0

			-- forwards
			if(love.keyboard.isDown('w')) then
				speed = self.speed
			end

			-- backwards
			if(love.keyboard.isDown('s')) then
				speed = -self.speed
			end

			-- left
			if(love.keyboard.isDown('a')) then
				speed = self.speed
				a = a-math.rad(90)
				p = 0
			end

			-- right
			if(love.keyboard.isDown('d')) then
				speed = self.speed
				a = a+math.rad(90)
				p = 0
			end

			-- left-forwards
			if(love.keyboard.isDown('a') and love.keyboard.isDown('w')) then
				a = a+math.rad(45)
				p = self.camera.rotation.x-math.rad(90)
			end

			-- left-backwards
			if(love.keyboard.isDown('a') and love.keyboard.isDown('s')) then
				a = a+math.rad(-225)
				p = self.camera.rotation.x+math.rad(90)
			end

			-- right-forwards
			if(love.keyboard.isDown('d') and love.keyboard.isDown('w')) then
				a = a+math.rad(-45)
				p = self.camera.rotation.x-math.rad(90)
			end

			-- right-backwards
			if(love.keyboard.isDown('d') and love.keyboard.isDown('s')) then
				a = a+math.rad(225)
				p = self.camera.rotation.x+math.rad(90)
			end

			-- ZOOOOOM
			if(love.keyboard.isDown('rshift', 'lshift')) then
				speed = speed * 2
			end

			if(self.buttonheld == false) then
				-- hallow
				if(love.keyboard.isDown("h")) then
					self.voxel:hollow()
					self.voxel:buildModel()
					self.buttonheld = true
				end

				-- light
				if(love.keyboard.isDown("l")) then
					self.shade = not self.shade
					self.renderer.render_shader:send("cubeshade", self.shade)
					self.buttonheld = true
				end

				-- fly
				if(love.keyboard.isDown("f")) then
					self.fly = not self.fly
					self.buttonheld = true
				end
				-- help
				if(love.keyboard.isDown("f1")) then
					self.buttonheld = true
				end
			end

			if(not love.keyboard.isDown("l", "h", "f", "f1")) then self.buttonheld = false end

			-- set positions
			local x, y, z
			x = self.camera.pos.x + math.cos(a) * math.cos(p) * (dt * speed)
			z = self.camera.pos.z + math.sin(a) * math.cos(p) * (dt * speed)

			-- if fly mode is not on
			if(self.fly == false) then
				y = self.camera.pos.y

				if(y <= 40) then
					if(love.keyboard.isDown('space')) then
						self.vely = -self.speed
					else
						y = 40
						self.vely = 0
					end
				end

				self.vely = self.vely + self.gravity * dt
				y = y - self.vely * dt

			-- fly mode is enabled
			else
				y = self.camera.pos.y + math.sin(p) * (dt * speed)

				-- up
				if(love.keyboard.isDown('space')) then
					y = y + self.speed * dt
				end

				-- down
				if(love.keyboard.isDown('rctrl', 'lctrl')) then
					y = y - self.speed * dt
				end
			end

			-- clamp angles
			self.camera.rotation = self.camera.rotation + self.av
			if(self.camera.rotation.x <= 0.0000001) then self.camera.rotation.x = 0.0000001 end
			if(self.camera.rotation.x >= math.pi) then self.camera.rotation.x = math.pi end

			-- move the camera
			self.camera:move_to(x, y, z, (self.camera.rotation):unpack())

			-- cleanup for next frame
			speed = 0
			self.av.x = 0
			self.av.y = 0
		end
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

	-- make camera work
	self.renderer:apply_camera(self.camera)

	-- draw the man of the hour
	self.scene:add_model(self.voxel.model)

	-- draw ground
	self.scene:add_model(self.ground_model)

	love.graphics.clear(0.05, 0.1, 0.15)
	self.renderer:render(self.scene:build())
	self.scene:clean_model()
end

return clsWorld
