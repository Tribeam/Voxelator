#pragma language glsl3

#include_macros

#define PI 3.14159265359
#define ao 1.0
#define gamma 2.2


// ------------------------------------------------

varying vec3 modelNormal;
varying vec3 fragPos;
varying vec4 fragAlbedo;
varying vec4 fragPhysics;
varying vec3 lightProjPos;

uniform vec3 ambientColor;
uniform vec3 sunDir;
uniform vec3 sunColor;
uniform vec3 cameraPos;

const int MAX_LIGHTS = 64;
uniform vec3 lightsPos[MAX_LIGHTS];
uniform vec3 lightsColor[MAX_LIGHTS];
uniform float lightsLinear[MAX_LIGHTS];
uniform float lightsQuadratic[MAX_LIGHTS];
uniform float lightsCount;

uniform bool render_shadow = true;
uniform float shadow_bias = -0.003;

uniform bool useSkybox;
uniform Image DepthMap;
uniform float Time;
uniform vec2 cameraClipDist;

uniform Image MainTex;

// ----------------------------------------------------------------------------

#include_pixel_pass

//#include_glsl calc_shadow.glsl
//#include_glsl pbr_light.glsl
//#include_glsl skybox_light.glsl

// ----------------------------------------------------------------------------

void effect() {
    vec4 tex_color = Texel(MainTex, VaryingTexCoord.xy) * VaryingColor;
    if (tex_color.a == 0) { discard; }

    vec4 albedo = fragAlbedo;
    vec3 albedo_rgb = tex_color.rgb * tex_color.a * albedo.rgb;

    love_Canvases[0] = vec4(albedo_rgb, tex_color.a * albedo.a);
}

