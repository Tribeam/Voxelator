local M = {}
M.__index = M

local code_dir = (...):gsub('.[^%.]+$', '')
-- local file_dir = code_dir:gsub('%.', '/')

local Cpml = require 'cpml'
local Mat4 = Cpml.mat4

local Util = require(code_dir..'.util')

local lg = love.graphics

function M:extend()
  local cls = {}
  for k, v in pairs(self) do
    if type(v) == 'function' then
      cls[k] = v
    end
  end

  cls.init = nil
  cls.__index = cls
  cls.new = function(...)
    local obj = setmetatable({}, cls)
    M.init(obj)
    obj:init(...)
    return obj
  end

  return cls
end

function M:init()
  self.camera = nil
  self.projection = nil
  self.view = nil
  self.camera_pos = nil
  self.look_at = nil
  self.camera_space_vertices = nil

  self.depth_map = nil
  self.output_canvas = nil
end

function M:apply_camera(camera)
  self.camera = camera
  self.projection = camera.projection
  self.view = camera.view
  self.camera_pos = { camera.pos:unpack() }
  self.look_at = { camera.focus:unpack() }
  self.camera_space_vertices = camera:get_space_vertices()

  local pv_mat = Mat4.new()
  pv_mat:mul(self.projection, self.view)
  self.proj_view_mat = pv_mat
end

-- scene:
-- {
--    model = { m1, m2, m3 },
--    lights = {
--      pos = { { x, y, z }, light2_pos, ... },
--      color = { { r, g, b }, light2_color, ... },
--      linear = { 0, light2_linear, ... },
--      quadratic = { 1, light2_quadratic, ... },
--    },
--    sun_dir = { x, y, z },
--    sun_color = { r, g, b },
--    ambient_color = { r, g, b },
-- }
-- draw_to_screen: default is true
-- function M:render(scene, time, draw_to_screen)
-- end

function M:draw_to_screen()
  lg.setBlendMode('alpha', 'premultiplied')
  lg.draw(self.output_canvas)
  lg.setBlendMode('alpha')
end

function M:attach(...)
  self.old_canvas = lg.getCanvas()
  lg.setCanvas({ self.output_canvas })
  self.camera:attach(...)
end

function M:detach()
  lg.setCanvas(self.old_canvas)
  self.old_canvas = nil
  self.camera:detach()
end

----------------------------

function M:render_model(model, render_shader)
  local model_opts = model.options

	lg.setDepthMode("less", model_opts.write_depth)
	lg.setMeshCullMode(model_opts.face_culling)

    lg.drawInstanced(model.mesh, model.total_instances)

	lg.setMeshCullMode('none')
	lg.setDepthMode()
end

return M
