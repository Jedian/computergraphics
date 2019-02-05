
--vertex
layout(location = 0) in vec3 in_position;

out vec3 position;

void main() {
    position = vec3(in_position.x,in_position.z,0);
    gl_Position =  vec4(position, 1);
}

--fragment


#define NUM_PLANES 1
#define NUM_SPHERES 4
#define NUM_SPIKE_BALLS 1
#define NUM_CUBES 1

#define NUM_OBJECTS (NUM_PLANES + NUM_SPHERES + NUM_SPIKE_BALLS + NUM_CUBES)



// Object IDs
#define SPHERE_1 0
#define SPHERE_2 1
#define SPHERE_3 2
#define SPHERE_4 3
#define PLANE NUM_SPHERES
#define SPIKEBALL (NUM_SPHERES+NUM_PLANES)
#define CUBE (SPIKEBALL+1)
#define LIGHT (CUBE+1)


#include "rt.h"

#define EPSILON 0.002
#define INFINITY 500
const IntersectionResult noIntersection = IntersectionResult(false, 0,vec3(0),vec3(0),EPSILON);


in vec3 position;

layout (location = 0) uniform vec3 cameraPos = vec3(0,0,0);
layout (location = 1) uniform mat4 projView;
layout (location = 2) uniform vec3 lightDir = normalize(-vec3(-1,5,4));

layout (location = 3) uniform int lightSamples = 5;
layout (location = 4) uniform int pixelSamples = 5;
layout (location = 7) uniform int sampling = 0;
layout (location = 8) uniform float uTime = 0;
layout (location = 9) uniform int debug = 0;
layout (location = 10) uniform vec2 screenSize = vec2(1280,720);
layout (location = 12) uniform mat4 boxTrans;
layout (location = 13) uniform vec3 lightPos = vec3(0,8,0);
layout (location = 14) uniform float lightSize = 1;
// XYZ - center of the sphere
// W - radius of the sphere
layout (location = 20) uniform vec4 objectData[NUM_OBJECTS];

layout (location = 50) uniform Material materials[NUM_OBJECTS];

layout (location = 0) out vec4 out_color;


#include "sky_floor_color.glsl"
#include "intersection_plane_sphere.glsl"


int intersectRayScene(Ray ray, out IntersectionResult result)
{

    int objectId = -1;
    float tMin = INFINITY;
    IntersectionResult tmp;

    //compute all intersections
    for (int i = 0; i < NUM_SPHERES; ++i)
    {
        tmp = intersectRaySphere(ray, objectData[i]);
        if (tmp.isIntersection && tmp.tHit < tMin)
        {
            objectId = i;
            result = tmp;
            tMin = tmp.tHit;
        }
    }

    tmp = intersectRayPlane(ray, objectData[PLANE]);
    if (tmp.isIntersection && tmp.tHit < tMin)
    {
        objectId = PLANE;
        result = tmp;
        tMin = tmp.tHit;
    }

    vec3 boxPos = vec3(6,0,1);
    vec3 boxScale = vec3(2,10,2);

    tmp = intersectRayAabb(ray, boxPos - 0.5*boxScale,boxPos+0.5*boxScale);
    if (tmp.isIntersection && tmp.tHit < tMin)
    {
        objectId = CUBE;
        result = tmp;
        tMin = tmp.tHit;

    }


    vec3 lightBoxMin = lightPos - vec3(lightSize,0.1,lightSize);
    vec3 lightBoxMax = lightPos + vec3(lightSize,0.1,lightSize);
    tmp = intersectRayAabb(ray, lightBoxMin, lightBoxMax);
    if (tmp.isIntersection && tmp.tHit < tMin)
    {
        objectId = LIGHT;
        result = tmp;
        tMin = tmp.tHit;

    }

    return objectId;
}


float halton(int i, int b)
{

    // TODO 13.3 a)
    // Compute the i-th number of the base b Halton sequence.
    float f = 1;
    float r = 0;
    while(i > 0.0f){
        f = f/b;
        r = r + f*(i%b);
        i = int(floor(float(i)/float(b)));
    }
    return r;


}


uint seed = 123456789;

uint xorshift32()
{

    // TODO 13.4 a)
    // Pseudorandom number generator with xor shift.
    // Use the global variable "seed".
    seed ^= seed << 13;
    seed ^= seed >> 17;
    seed ^= seed << 5;
    return seed;


}

float rand()
{

    // TODO 13.4 a)
    // Convert random uint value to a floating point in the range [0,1]
    uint u = xorshift32();
    float r = u/float(4294967295U);
    return r;


}



vec3 trace(Ray ray)
{
    if(debug==1) return vec3(rand());

    vec3 color = vec3(0.0);

    IntersectionResult inter;
    int objectId = intersectRayScene(ray,inter);


    if(objectId != -1)
    {


        Material m = materials[objectId];

        // Draw the light source in white
        if(objectId == LIGHT) return vec3(1);

        // Some special handling for the plane to create the checkerboard pattern
        if(objectId == PLANE) m.color = floorColor(m.color,inter.hitPosition);


        vec3 N = normalize(inter.normal);

        // TODO 13.4 c)
        // Create a loop that samples the light "lightSamples" times and averages the color.
        // Compute a random position on the light and store it in "lightSample".
        // You have to use the function rand() and the uniforms lightPos and lightSize.
        int i;
        for(i=0; i<lightSamples; i++){
            vec2 offset = (vec2(rand(), rand())*2*lightSize) - vec2(lightSize);
            vec3 lightSample = lightPos + vec3(offset.x, 0, offset.y);

            vec3 l = normalize(lightSample-inter.hitPosition);
            vec3 v = normalize(cameraPos - inter.hitPosition);
            vec3 r = normalize(2.0 * dot(N, l) * N - l);
            vec3 diff = max(0.0, dot(N, l)) * m.color;

            vec3 dir = normalize(lightSample-inter.hitPosition);
            Ray shadowRay = Ray(inter.hitPosition + inter.epsilon * N, dir);
            IntersectionResult inter2;
            int ob = intersectRayScene(shadowRay,inter2);
            float s = ob == LIGHT || ob == -1 ? 1 : 0;
            vec3 c = diff * s;

            color += c / lightSamples;

        }

    }

    return color;
}


void main() {


    // TODO 13.4 b)
    // Compute a random seed for every fragment
    // Use gl_FragCoord.
    //seed = 3520394563245;
	seed = uint(gl_FragCoord.x)*7919U + uint(gl_FragCoord.y)*15485863U;

    vec3 color = vec3(0);



    // TODO 13.3 b)
    // Create a loop and average "color" over "pixelSamples" iterations.
    // In each iteration:
    // - Compute the (2,3) Halton point.
    // - The sample offset is the Halton point scaled to the range [-1/screenSize,1/screenSize]
    int i;
    for(i=0; i<pixelSamples; i++){
        vec2 Hp = vec2(halton(i, 2), halton(i, 3));
        vec2 sampleOffset = vec2(Hp*(2.0/screenSize)) + vec2(-1.0/screenSize);

        // Setup primary ray
        vec4 wp = inverse(projView) * vec4(position.xy + sampleOffset, position.z, 1);
        wp = wp / wp.w;
        Ray primaryRay;
        primaryRay.origin = cameraPos;
        primaryRay.direction = normalize(vec3(wp) - cameraPos);

        // Trace Primary Ray
        color += trace(primaryRay)/pixelSamples;

    }



    out_color = vec4(color,1);
    return;

}
