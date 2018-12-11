
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
        // TODO 8.3 a)
        // Compute tangent and bitangent for this vertex.
        // Hint: Compute them in object space (where 'normalObject' is already given)
		// and then transform them to world space using the model matrix 'model'!
        tangent = vec3(0);
        bitangent = vec3(0);
    }

    if(translateVertices)
    {
        // TODO 8.3 c)
        // Translate object space vertices ('positionObjectSpace') along object space normals ('normalObject').
        // Use the texture 'earthBump' and the uniform 'heightScale'.
        positionObjectSpace += vec3(0);
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
        // TODO 8.3 a)
        // Compute TBN matrix from vertex shader inputs: 'tangent', 'bitangent', and 'normal'.
        // Load normal from the texture and transform it to world space.
		// Note that all directions (with components in [-1, 1]) are stored in a textures
		// which only supports positive values. That is why you have to map the normal 
		// from [0, 1] back to [-1, 1] before you can transform it with the TBN matrix.
        // The final normal in world space should be stored in 'n'.
        mat3 TBN = mat3(
                    vec3(1,0,0),
                    vec3(0,1,0),
                    vec3(0,0,1)
                    );
        n = vec3(0);
    }
    if(normalMethod == 2)
    {
        // TODO 8.3 b)
        // - Compute the screen space derivatives of the position and texture coordinates with dFdx(...) and dFdy(...).
        // - Use the formula on the exercise sheet to compute T and B.
        // - Compute the world space normal similar to 8.3 a).

        mat3 TBN = mat3(
                    vec3(1,0,0),
                    vec3(0,1,0),
                    vec3(0,0,1)
                    );
        n = vec3(0);
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
            // TODO 8.3 d)
            // Diminish dayColor to fake cloud shadows.
			// For a cloud value of 1, the dayColor should 
			// be diminished by a factor of 0.2. For a
			// cloud value of 0, the dayColor should not 
			// be diminished at all. For all values in between,
			// you should interpolate!
            float clouds = 0.5f;
            dayColor *=  clouds; 
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
