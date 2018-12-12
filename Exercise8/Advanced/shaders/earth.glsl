
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

layout (location = 11) uniform sampler2D earthBump;

layout (location = 23) uniform bool translateVertices = false;
//layout (location = 24) uniform bool useNormalMap = false;
//layout (location = 25) uniform bool numericNormal = false;
layout (location = 26) uniform int normalMethod = 0;

out vec3 positionWorldSpace;
out vec3 normalObject;
out vec3 normal;
out vec3 tangent;
out vec3 bitangent;
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

    if(normalMethod == 1) //Vertex TBN
    {
        tangent = cross(vec3(0, 1, 0), normal);
        bitangent = cross(normal, tangent);
    }

    if(translateVertices)
    {
	vec4 text = texture(earthBump, tc);
        positionObjectSpace += normalObject * text.x * heightScale;
    }

    positionWorldSpace = vec3(model * vec4(positionObjectSpace, 1));
    gl_Position = projView  * vec4(positionWorldSpace, 1);
}

--fragment

in vec3 positionWorldSpace;
in vec3 normal;
in vec3 normalObject;
in vec2 tc;
in vec3 tangent;
in vec3 bitangent;

#include "helper.glsl"
layout (location = 1) uniform mat4 model;
layout (location = 2) uniform vec3 sunPosition;
layout (location = 3) uniform vec3 sunColor;
layout (location = 4) uniform vec3 cameraPosition;
layout (location = 7) uniform float heightScale;
layout (location = 10) uniform sampler2D earthColor;
layout (location = 11) uniform sampler2D earthBump;
layout (location = 12) uniform sampler2D earthClouds;
layout (location = 13) uniform sampler2D earthNight;
layout (location = 14) uniform sampler2D earthNormal;
layout (location = 15) uniform sampler2D earthSpec;

layout (location = 20) uniform bool useColor = false;
layout (location = 22) uniform bool useClouds = false;
layout (location = 23) uniform bool translateVertices = false;
layout (location = 26) uniform int normalMethod = 0;

layout (location = 0) out vec4 out_color;


void main() {


    vec3 n = vec3(0);
    if(normalMethod == 0)
    {
        n = normalize(normal);
    }
    if(normalMethod == 1)
    {
        mat3 TBN = mat3(
                    normalize(tangent),
                    normalize(bitangent),
                    normal
                    );
	vec4 text = 2*texture(earthNormal, tc) - vec4(1, 1, 1, 1);
        n = TBN * vec3(text);
    }
    if(normalMethod == 2)
    {
	vec3 px = dFdx(positionWorldSpace);
	vec3 py = dFdy(positionWorldSpace);
	vec2 cx = dFdx(tc);
	vec2 cy = dFdy(tc);
	vec3 tangentp = (cross(py, normal)*cx.x) + (cross(normal, px)*cy.x);
	vec3 bitangentp = (cross(py, normal)*cx.y) + (cross(normal, px)*cy.y);
        mat3 TBN = mat3(
                    normalize(tangentp),
                    normalize(bitangentp),
                    normal
                    );
	vec4 text = 2*texture(earthNormal, tc) - vec4(1, 1, 1, 1);
        n = TBN * vec3(text);
    }


    vec3 l = normalize(sunPosition - positionWorldSpace);
    vec3 v = normalize(cameraPosition - positionWorldSpace);


    vec3 color;
    {
        vec3 r = normalize(2.0 * dot(n, l) * n - l);

        vec3 dayColor = vec3(1);
        vec3 nightColor = vec3(0);
		
		if (useColor)
		{
			dayColor = texture(earthColor, tc).rgb;
			nightColor = texture(earthNight, tc).rgb;
		}
        if(useClouds)
        {
            vec4 text = texture(earthClouds, tc);
            float clouds = text.x * clamp(dot(n, normalize(sunPosition-positionWorldSpace)), 0, 1);

	    dayColor *= mix(1.0, 0.0, clouds); 
	}
	vec3 color_diffuse = sunColor * mix(nightColor, dayColor, max(0, dot(n, l)));




        float spec = 0.2;
        spec = texture(earthSpec,tc).r * 0.7;
        spec = max(0.2,spec);
        vec3 color_specular = sunColor * spec * pow(max(0.0, dot(v, r)), 20);
        color = color_diffuse + color_specular;
    }

    out_color = vec4(color,1);
}
