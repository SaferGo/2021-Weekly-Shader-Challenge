#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;


void main() {
    vec2 uv = gl_FragCoord.xy;
    uv -= 0.5;
    uv.x *= u_resolution.y / u_resolution.x;

    vec3 color = vec3(0.0);

    gl_FragColor = vec4(color, 1.0);
}