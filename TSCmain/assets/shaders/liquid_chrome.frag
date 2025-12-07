precision highp float;

uniform vec2 uSize;
uniform float uTime;

// Smooth noise
float noise(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Interpolated noise
float smoothNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

  float a = noise(i);
  float b = noise(i + vec2(1.0, 0.0));
  float c = noise(i + vec2(0.0, 1.0));
  float d = noise(i + vec2(1.0, 1.0));

  vec2 u = f * f * (3.0 - 2.0 * f);

  return mix(a, b, u.x) +
    (c - a) * u.y * (1.0 - u.x) +
    (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
  float value = 0.0;
  float scale = 0.5;

  for(int i = 0; i < 5; i++) {
    value += smoothNoise(p) * scale;
    p *= 2.0;
    scale *= 0.5;
  }

  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / uSize.xy;
  float t = uTime * 0.12;

  float base = fbm(uv * 4.0 + t);
  float flow = fbm(uv * 8.0 - t);

  float chrome = mix(base, flow, 0.6);

  vec3 color = vec3(
    0.9 + chrome * 0.2,
    0.7 + chrome * 0.3,
    1.0 + chrome * 0.15
  );

  gl_FragColor = vec4(color, 1.0);
}precision highp float;

uniform vec2 uSize;
uniform float uTime;

// Smooth noise
float noise(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Interpolated noise
float smoothNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

  float a = noise(i);
  float b = noise(i + vec2(1.0, 0.0));
  float c = noise(i + vec2(0.0, 1.0));
  float d = noise(i + vec2(1.0, 1.0));

  vec2 u = f * f * (3.0 - 2.0 * f);

  return mix(a, b, u.x) +
    (c - a) * u.y * (1.0 - u.x) +
    (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
  float value = 0.0;
  float scale = 0.5;

  for(int i = 0; i < 5; i++) {
    value += smoothNoise(p) * scale;
    p *= 2.0;
    scale *= 0.5;
  }

  return value;
}

void main() {
  vec2 uv = gl_FragCoord.xy / uSize.xy;
  float t = uTime * 0.12;

  float base = fbm(uv * 4.0 + t);
  float flow = fbm(uv * 8.0 - t);

  float chrome = mix(base, flow, 0.6);

  vec3 color = vec3(
    0.9 + chrome * 0.2,
    0.7 + chrome * 0.3,
    1.0 + chrome * 0.15
  );

  gl_FragColor = vec4(color, 1.0);
}