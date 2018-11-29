vec2 cartesianToSpherical(vec3 n)
{
    // TODO 7.4 a)
    // Convert cartesian coordinates to spherical coordinates.
    float theta = 0;
    float phi = 0;

    return vec2(theta,phi);
}

vec3 sphericalToCartesian(vec2 a)
{
    float theta = a.x;
    float phi = a.y;

    // TODO 7.4 a)
    // Convert spherical coordinates to cartesian coordinates.
    return vec3(0,0,0);

}


vec2 sphericalToTexture(vec2 a)
{
    const float PI = 3.14159265;
    float theta = a.x; //in range [-PI,PI]
    float phi = a.y; // in range [0,PI]

    // TODO 7.4 a)
    // Compute texture coordinates from spherical coordinates.
	// Do not forget to mirror both coordinates to have the north pole at the top 
	// and France located west of Germany! ;)
    return vec2(0,0);

}

