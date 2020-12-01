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

uniform vec4 pal[256];
uniform bool haspal;

const float gridSize = 25.0;
const float cellSize = 10.05;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
  mat4 model_mat = transform_mat(ModelAngle, ModelScale);
  vec4 mpos = model_mat * vertex_position;
  vec4 world_pos = vec4(mpos.xyz / mpos.w + ModelPos, 1.0);

  fragAlbedo = ModelAlbedo;
  fragPhysics = ModelPhysics;

    if(fragPhysics.x == 1)
    {
      int index = int(fragAlbedo.g*255);
      fragAlbedo = pal[index];
    }

    if(fragPhysics.y == 1)
    {
        vec2 coords = VertexTexCoord.xy;

        // Distance-based alpha (1. at the middle, 0. at edges)
        float alpha = 1. - smoothstep(.15, .50, distance(coords, vec2(.5)));

        // Grid coordinate
        coords *= gridSize;
        coords /= cellSize;

        vec2 c = abs(fract(coords - 0.5) - 0.5) / abs(coords.x) + abs(coords.y);
        float line = clamp(1.0 - min(c.x, c.y), 0.0, 1.0);
        vec3 value = mix(vec3(0.1, 0.1, 0.11), (vec3(1.04)), line);

        fragAlbedo = vec4(vec3(value), 1);
    }

  vec3 normal = mat3(transpose(inverse(model_mat))) * VertexNormal;
  #ifdef VERTEX_PASS
    vertex_pass(world_pos, normal);
  #endif

  fragPos = world_pos.xyz;
  modelNormal = normal;
  vec4 light_proj_pos = lightProjViewMat * world_pos;
  // -1 - 1 to 0 - 1
  lightProjPos = light_proj_pos.xyz / light_proj_pos.w * 0.5 + 0.5;

  vec4 r = projViewMat * world_pos;
  r.y *= y_flip;
  return r;
}

