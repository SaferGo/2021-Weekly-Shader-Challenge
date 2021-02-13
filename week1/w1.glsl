#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

float remap01(float a, float b, float t) {
    return (t - a) / (b - a);
}

float remap(float a, float b, float c, float d, float t) {
    return remap01(a, b, t) * (d - c) + c;
}

vec4 Circle(float r,vec3 color, float blur, vec2 uv) {
    float new_circle = smoothstep(r, r - blur, length(uv));
    return vec4(vec3(new_circle) * color, 1.0);
}

mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

float Band(float a, float b, float t, float blur) {
    float band1 = smoothstep(a - blur, a + blur, t);
    float band2 = smoothstep(b + blur, b - blur, t);
    
    return band1 * band2;
}

vec4 Rect(float x1, float x2, float y1, float y2, vec2 uv, float blur, vec3 color) {
    float rect1 = Band(x1, x2, uv.x, blur);
    float rect2 = Band(y1, y2, uv.y, blur);
    return vec4(vec3(rect1 * rect2) * color, 1.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    uv -= 0.5;
    uv.x *= u_resolution.x / u_resolution.y;

    // Bright circle

    vec2 new_uv = uv;
    new_uv *= rotate(cos(u_time * 2.0) * 2.0);
    new_uv.x *= remap(-1.0, 1.0, 1.0, 0.8, sin(u_time * 3.0)) + 0.1;
    new_uv.y *= remap(-1.0, 1.0, 1.0, 0.8, sin(u_time * 4.0));
    float size_circle = remap(0.0, -2.0, 0.02, 0.3, cos(u_time * 0.5) - 1.0);
    vec3 color_mod = vec3(smoothstep(size_circle, 0.0, length(new_uv)));
    vec4 circle = Circle(0.26, vec3(0.32, 0.2, 1) * 4.0 * color_mod, 0.025, new_uv);

    // Sticks

    new_uv = uv;
    float a = (new_uv.y - 0.6) * (new_uv.y + 0.5);
    a *= sin(u_time * 2.7 + new_uv.y) / 3.5;
    new_uv.x += a + 0.4;
    
    float x1 = remap(-0.5, 0.5, 0.0, 0.05, uv.y);
    float height = sin(u_time + 5.0)*0.5;
    color_mod = vec3(smoothstep(-0.65, 0.5, new_uv.y));
    vec4 stickBlue = Rect(x1, 0.05, -0.5, height, new_uv, 0.005, vec3(0.1, 0.56, 0.71) * 2.0 * color_mod);

    /////////////////
    
    new_uv = uv;
    a = (new_uv.y - 0.6) * (new_uv.y + 0.5);
    a *= cos(u_time * 2.7 + new_uv.y) / 2.5;

    x1 = remap(-0.5, 0.5, 0.5, 0.52, uv.y * 1.5);
    new_uv.x += a + 0.4;
    height = sin(u_time * 0.5 + 5.0) * 0.5;
    color_mod = vec3(smoothstep(-0.62, 0.5, new_uv.y));
    vec4 stickGreen = Rect(x1, 0.52, -0.5, height, new_uv, 0.005, vec3(0.07, 0.92, 0.47) * 2.0 * color_mod);

    ////////////////

    new_uv = uv;
    a = (new_uv.y - 0.6) * (new_uv.y + 0.5);
    a *= cos(u_time * 2.7 + new_uv.y) / 2.5;

    x1 = remap(-0.5, 0.5, 0.785, 0.8, uv.y * 3.0);
    new_uv.x += a + 0.4;
    height = remap(-2.0, 1.0, -1.0, 0.01, sin(u_time * 0.65 + 4.8));
    color_mod = vec3(smoothstep(-0.55, 0.01, new_uv.y));
    vec4 stickOrange = Rect(x1, 0.8, -0.5, height, new_uv, 0.005, vec3(0.97, 0.58, 0) * 2.0 * color_mod);

    // Red flames
    new_uv = uv;
    new_uv.y += remap(-1.0, 1.0, 0.0, 0.4, sin(new_uv.x * 10.0 + u_time * 2.0) * 0.3);
    new_uv *= rotate(0.7);
    vec4 flameR = Rect(-0.5, 0.2, 0.65, 0.7, new_uv, 0.05, vec3(1, 0, 0.33) * 2.0);

    ////////////////

    new_uv = uv;
    new_uv.y += remap(-1.0, 1.0, 0.0, 0.4, cos(new_uv.x * 10.0 + u_time * 2.0) * 0.3);
    new_uv *= rotate(-0.7);
    vec4 flameL = Rect(-0.5, 0.5, 0.65, 0.7, new_uv, 0.05, vec3(1, 0, 0.33) * 2.0);

    gl_FragColor = circle + stickBlue + stickGreen + stickOrange + flameR + flameL;
}