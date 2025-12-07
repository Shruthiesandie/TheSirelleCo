// liquid_chrome.frag

precision highp float;

uniform float uTime;
uniform vec2 uSize;

void main() {
    vec2 uv = gl_FragCoord.xy / uSize.xy;
    uv = uv * 2.0 - 1.0;

    float t = uTime * 0.3;
    float swirl = sin(uv.x * 3.0 + t) * 0.2 +
                  cos(uv.y * 4.0 - t) * 0.2;

    uv += swirl;

    float shade = 0.6 + 0.4 * sin(uv.x * 2.0 + t) *
                            cos(uv.y * 2.5 - t);

    vec3 chrome = vec3(1.2, 0.75, 0.95) * shade;

    gl_FragColor = vec4(chrome, 1.0);
}