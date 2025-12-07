precision highp float;
uniform vec2 uSize;
uniform float uTime;

float noise(vec2 p){
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float smoothNoise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = noise(i);
    float b = noise(i + vec2(1.0,0.0));
    float c = noise(i + vec2(0.0,1.0));
    float d = noise(i + vec2(1.0,1.0));

    vec2 u= f*f*(3.0-2.0*f);

    return mix(a,b,u.x)+ (c-a)*u.y*(1.0-u.x) + (d-b)*u.x*u.y;
}

float fbm(vec2 p){
    float v =0.0;
    float a=0.6;
    for(int i=0;i<5;i++){
        v+= smoothNoise(p)*a;
        p*=2.0;
        a*=0.47;
    }
    return v;
}

void main(){
    vec2 uv = gl_FragCoord.xy/uSize.xy;
    float t = uTime * 0.09;
    float ripple = fbm(uv*5.0+t);

    vec3 c1 = vec3(1.0,0.78,1.0);
    vec3 c2 = vec3(0.92,0.80,1.0);

    gl_FragColor = vec4(mix(c1,c2,ripple),1.0);
}