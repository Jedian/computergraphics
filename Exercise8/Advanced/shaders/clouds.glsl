
--vertex
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_normal;

layout (location = 0) uniform mat4 projView;
layout (location = 1) uniform mat4 model;

out vec3 normal;
out vec3 normalObject;
out vec2 tc;
out vec3 positionWorldSpace;

#include "helper.glsl"

void main() {

      normalObject = normalize(in_position);

      positionWorldSpace = vec3(model * vec4(in_position, 1));
      gl_Position = projView * vec4(positionWorldSpace, 1);
        normal = vec3(model * vec4(in_normal,0));


        vec2 vertexAngles = cartesianToSpherical(normalize(normalObject));
        tc = sphericalToTexture(vertexAngles);
//        tc = vec2(in_position.xz);
}

--fragment

layout (location = 0) out vec4 out_color;
layout (location = 2) uniform vec3 sunPosition;
layout (location = 12) uniform sampler2D earthClouds;

in vec3 normal;
in vec2 tc;
in vec3 normalObject;
in vec3 positionWorldSpace;


void main() {

    vec4 text = texture(earthClouds, tc);
    float cloudAlpha = clamp(dot(normal, normalize(sunPosition-positionWorldSpace)), 0, 1) * text.x;
    out_color = vec4(1,1,1,cloudAlpha);
}
