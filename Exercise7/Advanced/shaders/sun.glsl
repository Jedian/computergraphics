
--vertex
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_normal;

layout (location = 0) uniform mat4 projView;
layout (location = 1) uniform mat4 model;

out vec3 normal;
out vec2 tc;

void main() {
        gl_Position = projView * model * vec4(in_position, 1);
        normal = vec3(model * vec4(in_normal,0));
        tc = vec2(in_position.xz);
}

--fragment

layout (location = 2) uniform vec4 color;
layout (location = 0) out vec4 out_color;


in vec2 tc;

void main() {

    float d = distance(tc,vec2(0.0));

    ivec2 iResolution = ivec2(500,500);
//    glfr

//    vec2 position = vec2((gl_FragCoord.x - iResolution.x / 2.0) / iResolution.y, (gl_FragCoord.y - iResolution.y / 2.0) / iResolution.y);
    vec2 position = tc;


    //https://www.shadertoy.com/view/4dl3zr
            vec3 ray_start = vec3(0, 0.2, -2);
            vec3 ray_dir = normalize(vec3(position,0) - ray_start);


    const float dayspeed = 0.04;
    float subtime = 0.0;
    float middayperc = 0.15;
    vec3 light1_pos = vec3(0.0,0,1 );

    float sunperc = pow(max(0.0, min(dot(ray_dir, normalize(light1_pos)), 1.0)), 60.0);
    vec3 suncolor = (1.0 - max(0.0, middayperc)) * vec3(1.5, 1.2, middayperc + 0.5) + max(0.0, middayperc) * vec3(1.0, 1.0, 1.0) * 4.0;
    vec3 color = suncolor * sunperc;
//    vec3 color = vec3(1) * sunperc;

    out_color = vec4(color,1);
//    out_color = vec4(suncolor,sunperc);
}
