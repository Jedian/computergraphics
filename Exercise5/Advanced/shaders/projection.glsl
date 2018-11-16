
vec3 projectVertexToPlane(vec3 vertex, vec3 direction, vec3 pointOnPlane, vec3 planeNormal)
{
    vec3 projectedPoint;

    // TODO 5.3 a)
    // Project 'vertex' on the plane defined by 'pointOnPlane' and 'planeNormal'.
    // The projection direction is given by 'direction'.

    float t = (dot(planeNormal, pointOnPlane) - dot(planeNormal, vertex)) / dot(planeNormal, direction);

    projectedPoint = vertex + direction*t;

    return projectedPoint;
}

