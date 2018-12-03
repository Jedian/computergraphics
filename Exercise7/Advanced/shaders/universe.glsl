
--vertex
layout(location = 0) in vec3 in_position;


out vec3 position;

void main() {
        position = vec3(in_position.x,in_position.z,1);
        gl_Position =  vec4(position, 1);
        gl_Position.z = 0.999999f; //draw quad behind everything (almost) on the far plane
}

--fragment

#include "helper.glsl"

layout (location = 0) uniform mat4 projView;
layout (location = 1) uniform vec3 cameraPos;

layout (location = 10) uniform sampler2D color;

layout (location = 0) out vec4 out_color;

in vec3 position;

void main() {

    vec4 wp = inverse(projView)* vec4(position, position.z); // <-- replace this line

    vec3 direction = normalize(normalize(cameraPos)-normalize(vec3(wp))); // <-- replace this line

    vec2 tc = sphericalToTexture(cartesianToSpherical(direction)); // <-- replace this line
    out_color = texture(color,tc);

}
