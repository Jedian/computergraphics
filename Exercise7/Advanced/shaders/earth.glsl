
--vertex
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_normal;

layout (location = 0) uniform mat4 projView;
layout (location = 1) uniform mat4 model;

out vec3 position;


void main() {
    position = in_position;
}


--tessControl

layout(vertices = 3) out;
layout (location = 5) uniform float Tesselation = 1;
in vec3 position[];
out vec3 tcPosition[];

void main()
{
    tcPosition[gl_InvocationID] = position[gl_InvocationID];
    if (gl_InvocationID == 0) {
        for(int i = 0; i < 2; ++i)
            gl_TessLevelInner[i] = Tesselation;
        for(int i = 0; i < 4; ++i)
            gl_TessLevelOuter[i] = Tesselation;
    }
}


--tessEval

#include "helper.glsl"

layout(triangles, equal_spacing, ccw) in;
in vec3 tcPosition[];

layout (location = 0) uniform mat4 projView;
layout (location = 1) uniform mat4 model;
layout (location = 7) uniform float heightScale;

out vec3 positionWorldSpace;
out vec3 normalObject;
out vec3 normal;
out vec2 tc;


void main()
{
    vec3 p0 = gl_TessCoord.x * tcPosition[0];
    vec3 p1 = gl_TessCoord.y * tcPosition[1];
    vec3 p2 = gl_TessCoord.z * tcPosition[2];

    vec3 positionObjectSpace = normalize(p0 + p1 + p2);
    normalObject = normalize(positionObjectSpace);
    normal = normalize(vec3(model * vec4(normalObject, 0)));

    //compute texture coordinate for this vertex
    vec2 vertexAngles = cartesianToSpherical(normalize(normalObject));
    tc = sphericalToTexture(vertexAngles);

    positionWorldSpace = vec3(model * vec4(positionObjectSpace, 1));
    gl_Position = projView  * vec4(positionWorldSpace, 1);
}

--fragment

in vec3 positionWorldSpace;
in vec3 normal;
in vec3 normalObject;
in vec2 tc;

#include "helper.glsl"
layout (location = 1) uniform mat4 model;
layout (location = 2) uniform vec3 sunPosition;
layout (location = 3) uniform vec3 sunColor;
layout (location = 4) uniform vec3 cameraPosition;
layout (location = 7) uniform float heightScale;
layout (location = 10) uniform sampler2D earthColor;
layout (location = 13) uniform sampler2D earthNight;
layout (location = 15) uniform sampler2D earthSpec;

layout (location = 20) uniform bool useColor = false;

layout (location = 0) out vec4 out_color;


void main() {


    vec3 n = vec3(0);
    n = normalize(normal);


    vec3 l = normalize(sunPosition - positionWorldSpace);
    vec3 v = normalize(cameraPosition - positionWorldSpace);


    vec3 color;
    {
        vec3 r = normalize(2.0 * dot(n, l) * n - l);

        vec3 dayColor = vec3(1);
        vec3 nightColor = vec3(0);

        // TODO 7.5 a)
        // Add color to the earth. Use 'nightColor' on the back side of the sphere, dayColor on the front side.
		// Blend between nightColor and dayColor depending on dot(n,l) in the diffuse term!
		// Make sure that the transition is smooth by using the GLSL function mix().
		
        if(useColor) //Note: 'useColor' is passed as a uniform and can be enabled in the GUI.
        {
            dayColor = vec3(1); //<- TODO: read from the texture 'earthColor' here
            nightColor = vec3(0); //<- TODO: read from the texture 'earthNight' here
        }

        vec3 color_diffuse = sunColor * dayColor * max(0, dot(n, l)); // <- change this line for 7.5a)

        // TODO 7.5 b)
        // Read and use the specular intensity value stored in the 'earthSpec' texture.
		// The texture stores values between 0 and 1. Scale these values to [0, 0.7] and 
		// then clamp values smaller than 0.2 to 0.2 to obtain a natural look.
        vec3 color_specular = sunColor * pow(max(0.0, dot(v, r)), 20); // <-- modify this line with the specular intensity value


        color = color_diffuse + color_specular;
    }

    out_color = vec4(color,1);
}
