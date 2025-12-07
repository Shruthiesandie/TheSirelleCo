#version 460 core
#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uSize;

out vec4 fragColor;

void main() {
  // Frag coord from Flutter helper
  vec2 fragCoord = FlutterFragCoord().xy;

  // Normalized coords -1..1
  vec2 uv = fragCoord / uSize;
  uv = uv * 2.0 - 1.0;

  float t = uTime * 0.3;

  // Wave swirl distortion
  float swirl = sin(uv.x * 3.0 + t) * 0.2 +
                cos(uv.y * 4.0 - t) * 0.2;

  uv += swirl;

  // Chrome shading
  float shade = 0.6 + 0.4 * sin(uv.x * 2.0 + t) *
                          cos(uv.y * 2.5 - t);

  // Soft pink chrome tone
  vec3 chrome = vec3(1.2, 0.75, 0.95) * shade;

  fragColor = vec4(chrome, 1.0);
}