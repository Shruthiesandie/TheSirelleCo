#version 300 es
precision highp float;

out vec4 fragColor;
uniform float uTime;
uniform vec2 uResolution;

// Simple chrome wave effect

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    uv -= 0.5;

    float t = uTime * 0.35;

    float wave = sin(uv.x * 6.0 + t) * 0.25 +
                 sin(uv.y * 8.0 - t * 1.4) * 0.35 +
                 sin((uv.x + uv.y) * 4.0 + t * 0.7) * 0.15;

    float metallic = smoothstep(0.15, 0.45, abs(wave));

    vec3 color = mix(
        vec3(1.0, 0.85, 1.0),      // soft candy pink
        vec3(0.92, 0.72, 1.0),     // lavender shimmer
        metallic
    );

    fragColor = vec4(color, 0.65);   // 65% transparency
}