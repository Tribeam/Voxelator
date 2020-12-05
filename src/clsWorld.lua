local clsWorld = class("clsWorld", {})


function clsWorld:init(voxel)

	self.renderer = MR.renderer.new()
	self.camera = MR.camera.new()
	self.scene = MR.scene.new()

	self.speed = 200
	self.gravity = 400
	self.vely = 0
	self.av = Cpml.vec3(0, 0, 0)
	self.rv = math.pi
	self.camera:move_to(0, 0, 0, math.rad(60), 0, 0)
	self.projection = "perspective"
	self.voxel = voxel
	self.renderer.render_shader:send("pal", unpack(self.voxel.palette))
	self.fly = true
	self.buttonheld = false
	self.shade = 0
	self.renderer.render_shader:send("cubeshade", true)
	self.gridsize = 32
	self.codeseq = {}
	self.sunrotation = math.rad(45)
	self.sundist = 100
	self.sunheight = 100
	self.sunshow = false
	self.sunbright = 1
	self.scene.sun_dir = { math.cos(self.sunrotation) * self.sundist, self.sunheight, math.sin(self.sunrotation) * self.sundist }
	self.cursormode = false
	self.wireframe = false
	self.modelshow = true
	self.bordershow = true
	self.compassshow = true
	self.groundshow = true

	local instances = {}

	-- sun
	self.sun_model = MR.model.new_sphere(1)

	-- axis compass
	self.compass_model = MR.model.new_box(1)
	instances = {}

	-- x
	instances[#instances+1] =
	{
		-0.5, (self.voxel.size.z/2)-0.5, -0.5,
		0, 0, 0,
		self.voxel.size.x+8, 0.2, 0.2,
		0, 0, 1, 1,
		0, 1
	}

	-- x "arrow"
	instances[#instances+1] =
	{
		(self.voxel.size.x/2)+4-0.5, (self.voxel.size.z/2)-0.5, -0.5,
		0, 0, 0,
		2, 0.5, 0.5,
		0, 0, 1, 1,
		0, 1
	}

	-- y
	instances[#instances+1] =
	{
		-0.5, (self.voxel.size.z/2)-0.5, -0.5,
		0, 0, 0,
		0.2, self.voxel.size.z+8, 0.2,
		0, 1, 0, 1,
		0, 1
	}

	-- y "arrow"
	instances[#instances+1] =
	{
		-0.5, (self.voxel.size.z)+4-0.5, -0.5,
		0, 0, 0,
		0.5, 2, 0.5,
		0, 1, 0, 1,
		0, 1
	}

	-- z
	instances[#instances+1] =
	{
		-0.5, (self.voxel.size.z/2)-0.5, -0.5,
		0, 0, 0,
		0.2, 0.2, self.voxel.size.y+8,
		1, 0, 0, 1,
		0, 1
	}
	-- z "arrow"
	instances[#instances+1] =
	{
		-0.5, (self.voxel.size.z/2)-0.5, (-(self.voxel.size.y/2)-4)-0.5,
		0, 0, 0,
		0.5, 0.5, 2,
		1, 0, 0, 1,
		0, 1
	}
	self.compass_model:set_raw_instances(instances)

	-- ground
	self.ground_model = MR.model.new_plane(16, 16)
	self.ground_model:set_opts({ instance_usage = 'static' })
	instances = {}
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

	for x = 1, self.gridsize do
		color_alternate = not color_alternate
		for y = 1, self.gridsize do
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
			instances[#instances+1] =
			{
				(16*self.gridsize/2)-(x*16), -0.5, (16*self.gridsize/2)-(y*16),
				0, 0, 0,
				1, 1, 1,
				r3, g3, b3, 1,
				0, 1
			}
		end
	end

	self.ground_model:set_raw_instances(instances)

	-- border
	self.border_model = MR.model.new_box(1)
	instances = {}

	-------------------------------------------------
	-- left
	-------------------------------------------------
	-- bottom
	instances[#instances+1] =
	{
		self.voxel.pos.x+(self.voxel.size.x/2)-0.4, self.voxel.pos.z-0.3, self.voxel.pos.y-0.5,
		0, 0, 0,
		0.2, 0.2, self.voxel.size.y+0.4,
		1, 1, 0, 1,
		0, 1
	}
	-- top
	instances[#instances+1] =
	{
		self.voxel.pos.x+(self.voxel.size.x/2)-0.4, self.voxel.pos.z+self.voxel.size.z-0.1, self.voxel.pos.y-0.5,
		0, 0, 0,
		0.2, 0.2, self.voxel.size.y+0.4,
		1, 1, 0, 1,
		0, 1
	}

	-- left
	instances[#instances+1] =
	{
		self.voxel.pos.x+(self.voxel.size.x/2)-0.4, (self.voxel.size.z/2)-0.2, self.voxel.pos.y+(self.voxel.size.y/2)-0.4,
		0, 0, 0,
		0.2, self.voxel.size.z, 0.2,
		1, 1, 0, 1,
		0, 1
	}

	-- right
	instances[#instances+1] =
	{
		self.voxel.pos.x+(self.voxel.size.x/2)-0.4, (self.voxel.size.z/2)-0.2, self.voxel.pos.y-(self.voxel.size.y/2)-0.6,
		0, 0, 0,
		0.2, self.voxel.size.z, 0.2,
		1, 1, 0, 1,
		0, 1
	}

	-------------------------------------------------
	-- right
	-------------------------------------------------
	-- bottom
	instances[#instances+1] =
	{
		self.voxel.pos.x-(self.voxel.size.x/2)-0.6, self.voxel.pos.z-0.3, self.voxel.pos.y-0.5,
		0, 0, 0,
		0.2, 0.2, self.voxel.size.y+0.4,
		1, 1, 0, 1,
		0, 1
	}
	-- top
	instances[#instances+1] =
	{
		self.voxel.pos.x-(self.voxel.size.x/2)-0.6, self.voxel.pos.z+self.voxel.size.z-0.1, self.voxel.pos.y-0.5,
		0, 0, 0,
		0.2, 0.2, self.voxel.size.y+0.4,
		1, 1, 0, 1,
		0, 1
	}

	-- left
	instances[#instances+1] =
	{
		self.voxel.pos.x-(self.voxel.size.x/2)-0.6, (self.voxel.size.z/2)-0.2, self.voxel.pos.y+(self.voxel.size.y/2)-0.4,
		0, 0, 0,
		0.2, self.voxel.size.z, 0.2,
		1, 1, 0, 1,
		0, 1
	}

	-- right
	instances[#instances+1] =
	{
		self.voxel.pos.x-(self.voxel.size.x/2)-0.6, (self.voxel.size.z/2)-0.2, self.voxel.pos.y-(self.voxel.size.y/2)-0.6,
		0, 0, 0,
		0.2, self.voxel.size.z, 0.2,
		1, 1, 0, 1,
		0, 1
	}

	-------------------------------------------------
	-- front
	-------------------------------------------------

	-- bottom
	instances[#instances+1] =
	{
		self.voxel.pos.x-0.5, self.voxel.pos.z-0.3, self.voxel.pos.y-(self.voxel.size.y/2)-0.6,
		0, 0, 0,
		self.voxel.size.x, 0.2, 0.2,
		1, 1, 0, 1,
		0, 1
	}

	-- top
	instances[#instances+1] =
	{
		self.voxel.pos.x-0.5,  self.voxel.pos.z+self.voxel.size.z-0.1, self.voxel.pos.y-(self.voxel.size.y/2)-0.6,
		0, 0, 0,
		self.voxel.size.x, 0.2, 0.2,
		1, 1, 0, 1,
		0, 1
	}

	-------------------------------------------------
	-- back
	-------------------------------------------------

	-- bottom
	instances[#instances+1] =
	{
		self.voxel.pos.x-0.5, self.voxel.pos.z-0.3, self.voxel.pos.y+(self.voxel.size.y/2)-0.4,
		0, 0, 0,
		self.voxel.size.x, 0.2, 0.2,
		1, 1, 0, 1,
		0, 1
	}

	-- top
	instances[#instances+1] =
	{
		self.voxel.pos.x-0.5,  self.voxel.pos.z+self.voxel.size.z-0.1, self.voxel.pos.y+(self.voxel.size.y/2)-0.4,
		0, 0, 0,
		self.voxel.size.x, 0.2, 0.2,
		1, 1, 0, 1,
		0, 1
	}


	self.border_model:set_raw_instances(instances)
end

function clsWorld:resize()
	self.renderer = MR.renderer.new()
	self.renderer.render_shadow = false
	self.renderer.render_shader:send("pal", unpack(self.voxel.palette))
end

function clsWorld:update(dt)

	if self.camera then

		-- keyboard
		if(self.cursormode) then
			love.mouse.setRelativeMode(false)
			if(self.buttonheld == false) then
				-- cursor mode
				if(love.keyboard.isDown("c")) then
					self.cursormode = not self.cursormode
					self.buttonheld = true
				end
			end

			if(not love.keyboard.isDown("c")) then self.buttonheld = false end
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

			-- rotate sun counter-clockwise
			if(love.keyboard.isDown('[')) then
				self.sunrotation = self.sunrotation + 1 * dt
				self.scene.sun_dir = { math.cos(self.sunrotation) * self.sundist, self.sunheight, math.sin(self.sunrotation) * self.sundist }
			end

			-- rotate sun clockwise
			if(love.keyboard.isDown(']')) then
				self.sunrotation = self.sunrotation - 1 * dt
				self.scene.sun_dir = { math.cos(self.sunrotation) * self.sundist, self.sunheight, math.sin(self.sunrotation) * self.sundist }
			end

			-- move sun inward
			if(love.keyboard.isDown('-')) then
				self.sundist = self.sundist - 50 * dt
				self.scene.sun_dir = { math.cos(self.sunrotation) * self.sundist, self.sunheight, math.sin(self.sunrotation) * self.sundist }
			end

			-- move sun outward
			if(love.keyboard.isDown("=")) then
				self.sundist = self.sundist + 50 * dt
				self.scene.sun_dir = { math.cos(self.sunrotation) * self.sundist, self.sunheight, math.sin(self.sunrotation) * self.sundist }
			end

			-- move sun up
			if(love.keyboard.isDown(';')) then
				self.sunheight = self.sunheight + 50 * dt
				self.scene.sun_dir = { math.cos(self.sunrotation) * self.sundist, self.sunheight, math.sin(self.sunrotation) * self.sundist }
			end

			-- move sun down
			if(love.keyboard.isDown("'")) then
				self.sunheight = self.sunheight - 50 * dt
				self.scene.sun_dir = { math.cos(self.sunrotation) * self.sundist, self.sunheight, math.sin(self.sunrotation) * self.sundist }
			end

			-- brighten sun
			if(love.keyboard.isDown(".")) then
				self.sunbright = self.scene.sun_color[1] + 10 * dt
				self.scene.sun_color = { self.sunbright, self.sunbright, self.sunbright }
			end

			-- darken sun
			if(love.keyboard.isDown(",")) then
				self.sunbright = self.scene.sun_color[1] - 10 * dt
				self.scene.sun_color = { self.sunbright, self.sunbright, self.sunbright }
			end

			if(self.buttonheld == false) then

				-- show model
				if(love.keyboard.isDown("m")) then
					self.modelshow = not self.modelshow
					self.buttonheld = true
				end


				-- wireframe
				if(love.keyboard.isDown("v")) then
					self.renderer.wireframe = not self.renderer.wireframe
					self.buttonheld = true
				end

				-- cursor mode
				if(love.keyboard.isDown("c")) then
					self.cursormode = not self.cursormode
					self.buttonheld = true
				end

				-- hollow
				if(love.keyboard.isDown("h")) then
					self.voxel:hollow()
					self.voxel:buildModel()
					self.buttonheld = true
				end

				-- light
				if(love.keyboard.isDown("l")) then
					self.shade = self.shade + 1
					if(self.shade > 2) then self.shade = 0 end
					if(self.shade == 0) then
						self.renderer.render_shader:send("cubeshade", false)
						self.sunshow = false
					elseif(self.shade == 1) then
						self.renderer.render_shader:send("cubeshade", true)
					elseif(self.shade == 2) then
						self.sunshow = true
					end
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

			-- buttons that shouldnt repeat when held
			if(not love.keyboard.isDown("c", "l", "h", "f", "f1", "m", "v")) then self.buttonheld = false end

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

	-- do camera
	self.renderer:apply_camera(self.camera)

	-- draw compass
	if(self.compassshow) then
		self.scene:add_model(self.compass_model)
	end

	-- draw border
	if(self.bordershow) then
		self.scene:add_model(self.border_model)
	end

	-- draw the man of the hour
	if(self.modelshow) then
		self.scene:add_model(self.voxel.model)
	end

	-- draw ground
	if(self.groundshow) then
		self.scene:add_model(self.ground_model)
	end

	-- draw sun
	if(self.sunshow) then
		self.scene:add_model(self.sun_model, self.scene.sun_dir)
	end

	love.graphics.clear(0.03, 0.07, 0.1)
	self.renderer:render(self.scene:build())
	self.scene:clean()

end

function clsWorld:input(text)
	--self.codeseq[#self.codeseq+1] = text
end

return clsWorld
