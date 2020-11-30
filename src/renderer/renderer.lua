local code_dir = (...):gsub('.[^%.]+$', '')
local file_dir = code_dir:gsub('%.', '/')

local M = require(code_dir..'.base_renderer'):extend()

local Cpml = require 'cpml'
local Mat4 = Cpml.mat4

local Model = require(code_dir..'.model')
local Util = require(code_dir..'.util')
local send_uniform = Util.send_uniform

local lg = love.graphics

local brdf_lut_size = 1
local brdf_lut

local default_options = {
  vertex_code = false,
  pixel_code = false,
  macros = false,
  msaa = 1,
}

function M:init(options)
  self.options = Util.merge_options(default_options, options or {})
  local opts = self.options

  self.render_shader = Util.new_shader(
    file_dir..'/shader/forward.glsl',
    file_dir..'/shader/vertex.glsl',
    opts.pixel_code, opts.vertex_code, opts.macros
  )
  Util.send_uniforms(self.render_shader, {
    { 'y_flip', -1 }
  })

  local w, h = lg.getDimensions()
  self.output_canvas = lg.newCanvas(w, h, { msaa = opts.msaa })


end

function M:render(scene, time, draw_to_screen)
  if not scene.ambient_color then scene.ambient_color = { 0.1, 0.1, 0.1 } end

  self.time = time or love.timer.getTime()

  -- lg.setWireframe(true)
  self:render_scene(scene)
  -- lg.setWireframe(false)

  if draw_to_screen or draw_to_screen == nil then
    self:draw_to_screen()
  end

  return self.output_canvas
end

function M:attach(...)
  self.old_canvas = lg.getCanvas()
  lg.setCanvas({ self.output_canvas, depth = true })
  self.camera:attach(...)
end


function M:render_scene(scene)
  local render_shader = self.render_shader

  Util.push_render_env({ self.output_canvas, depth = true }, self.render_shader)
  lg.clear(0, 0, 0, 0)

  Util.send_uniforms(render_shader, {
	  { "projViewMat", 'column', self.proj_view_mat },
	  { "ambientColor", scene.ambient_color },
	  { "cameraClipDist", { self.camera.near, self.camera.far } },
  })

	for i = 1, #scene.model do
		self:render_model(scene.model[i], render_shader)
	end

  if scene.ordered_model then
    for i = 1, #scene.ordered_model do
      self:render_model(scene.ordered_model[i], render_shader)
    end
  end

  Util.pop_render_env()
end

return M
