
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

#ifdef SKELETON
    //TODO 7.4 b)

    // 1. Compute world position of current fragment.
	//	  Use the matrix 'projView' to do so.
    vec4 wp = vec4(0); // <-- replace this line

    // 2. Compute view direction.
	//	  Use the variable 'cameraPos' to do so.
    vec3 direction; // <-- replace this line

    // 3. Convert view direction to texture coordinates and read from the 'color' texture.
    vec2 tc = vec2(0); // <-- replace this line
    out_color = texture(color,tc);
#else
    //world position of fragment at far plane
    vec4 wp = inverse(projView) * vec4(position,1);
    //don't forget this division!!!
    wp = wp / wp.w;

    //view direction
    vec3 direction = normalize( vec3(wp) - cameraPos );

    //use view direction to sample spherical texture
    vec2 s = cartesianToSpherical(direction);
    vec2 tc = sphericalToTexture(s);
	out_color = texture(color, tc);
#endif

}
