precision highp float;

uniform vec2 uSize;
uniform float uTime;

// ------------------------------------------
// Smooth Noise
// ------------------------------------------
float noise(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float smoothNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

  float a = noise(i);
  float b = noise(i + vec2(1.0, 0.0));
  float c = noise(i + vec2(0.0, 1.0));
  float d = noise(i + vec2(1.0, 1.0));

  vec2 u = f*f*(3.0 - 2.0*f);

  return mix(a, b, u.x) +
         (c - a) * u.y * (1.0 - u.x) +
         (d - b) * u.x * u.y;
}

// ------------------------------------------
// fbm ripple motion (soft pastel)
// ------------------------------------------
float fbm(vec2 p) {
  float val = 0.0;
  float amp = 0.6;

  for (int i = 0; i < 5; i++) {
    val += smoothNoise(p) * amp;
    p *= 2.0;
    amp *= 0.47;
  }
  return val;
}

void main() {
  vec2 uv = gl_FragCoord.xy / uSize.xy;
  float t = uTime * 0.09;

  // ripple motion
  float ripple = fbm(uv * 5.0 + t);

  // soft pastel pink blending
  vec3 pastelPink = vec3(
    1.0,     // soft white-pink glow
    0.78,    // blush tint
    1.0      // lavender highlight
  );

  vec3 pastelPurple = vec3(
    0.92,
    0.80,
    1.0
  );

  vec3 color = mix(pastelPink, pastelPurple, ripple);

  gl_FragColor = vec4(color, 1.0);
}