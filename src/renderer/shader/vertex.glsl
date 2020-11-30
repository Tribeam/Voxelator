#pragma language glsl3

varying vec3 modelNormal;
varying vec3 fragPos;
varying vec4 fragAlbedo;
varying vec4 fragPhysics;
varying vec3 lightProjPos;

uniform mat4 projViewMat;
uniform mat4 lightProjViewMat;
uniform float y_flip = 1;
uniform float Time;

attribute vec3 VertexNormal;
attribute vec3 ModelPos;
attribute vec3 ModelAngle;
attribute vec3 ModelScale;
attribute vec4 ModelAlbedo;
attribute vec4 ModelPhysics;

#include_vertex_pass
#include_glsl transform_helper.glsl

vec4 position(mat4 transform_projection, vec4 vertex_position) {
  mat4 model_mat = transform_mat(ModelAngle, ModelScale);
  vec4 mpos = model_mat * vertex_position;
  vec4 world_pos = vec4(mpos.xyz / mpos.w + ModelPos, 1.0);

  fragAlbedo = ModelAlbedo;

  vec4 r = projViewMat * world_pos;
  r.y *= y_flip;
  return r;
}

