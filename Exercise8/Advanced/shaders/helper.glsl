vec2 cartesianToSpherical(vec3 n)
{
#ifdef SKELETON
    // TODO 7.4 a)
    // Convert cartesian coordinates to spherical coordinates.
    float theta = 0;
    float phi = 0;
#else
    float theta = atan( n.z, n.x );
    float phi = acos( n.y );
#endif
    return vec2(theta,phi);
}

vec3 sphericalToCartesian(vec2 a)
{
    float theta = a.x;
    float phi = a.y;

#ifdef SKELETON
    // TODO 7.4 a)
    // Convert spherical coordinates to cartesian coordinates.
    return vec3(0,0,0);
#else
    return vec3(
                sin(phi)*cos(theta),
                cos(phi),
                sin(phi)*sin(theta)
                );
#endif
}


vec2 sphericalToTexture(vec2 a)
{
    const float PI = 3.14159265;
    float theta = a.x; //in range [-PI,PI]
    float phi = a.y; // in range [0,PI]

#ifdef SKELETON
    // TODO 7.4 a)
    // Compute texture coordinates from spherical coordinates.
	// Do not forget to mirror both coordinates to have the north pole at the top 
	// and France located west of Germany! ;)
    return vec2(0,0);
#else
    vec2 tc;
    //transform to range [0,1]
    tc.x = (theta+PI) / (2*PI);
    tc.y = phi / (PI);
    //mirror!! Don't forget that or everthing will be upside down!!
    tc.x = 1.0f - tc.x;
    tc.y = 1.0f - tc.y;
    return tc;
#endif
}

