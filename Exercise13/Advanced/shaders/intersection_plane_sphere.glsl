
IntersectionResult intersectRaySphere(Ray ray, vec4 sphereData) {
    vec3 c = sphereData.xyz;
    float r = sphereData.w;


    //dt + o = p
    //|c-p|^2 = r^2

    //student solution by solving the system of equations
    vec3 d = ray.direction;

    vec3 a = ray.origin - c;
    float ad = dot(a,d);
    float aa = dot(a,a);
    float rr = r * r;

    float k = ad * ad - aa + rr;

    if(k < 0)
        return noIntersection;

    float ks = sqrt(k);

    float t1 = ((-ad) + ks);
    float t2 = ((-ad) - ks);

    //only use the smaller t that is still larger than 0
    if(t2 < t1){
        float tmp = t1;
        t1 = t2;
        t2 = tmp;
    }
    float tmin = t1;
    if(t2 < 0)
        return noIntersection;
    if(t1 < 0)
        tmin = t2;

    vec3 p =ray.origin + tmin*ray.direction;
    return IntersectionResult(true, tmin,normalize(p-c),p,EPSILON);


    //more efficient solution
    /*
    float rr = r * r;
    vec3 l = c - ray.origin;
    float ll = dot(l, l);
    float s = dot(l, ray.direction);
    if (s < 0 && ll > rr)
        return noIntersection;

    float mm = ll - s*s;
    if (mm > rr)
        return noIntersection;

    float u = sign(ll - rr);
    float tHit = s - sqrt(rr - mm) * u;
    vec3 pos =ray.origin+tHit*ray.direction;
    return IntersectionResult(true, u <= 0, tHit,normalize(pos-c),pos,EPSILON);
    */

}

IntersectionResult intersectRayPlane(Ray ray, vec4 planeData) {
    vec3 n = planeData.xyz;
    float k = planeData.w;
    vec3 d = ray.direction;
    vec3 o = ray.origin;

    float t = (k - dot(n,o)) / dot(d,n);
    vec3 p = o + t * d;
    return IntersectionResult(t > 0, t,n, p,EPSILON);

}

 vec3 boxNormal(vec3 p, vec3 bmin, vec3 bmax) {
    vec3 amin = abs(p - bmin);
    vec3 amax = abs(p - bmax);

    float normalEpsilon = 0.0001f;

    return normalize(vec3(
        (amin.x < normalEpsilon) ? -1.0f : ((amax.x < normalEpsilon) ? 1.0f : 0.0f),
        (amin.y < normalEpsilon) ? -1.0f : ((amax.y < normalEpsilon) ? 1.0f : 0.0f),
        (amin.z < normalEpsilon) ? -1.0f : ((amax.z < normalEpsilon) ? 1.0f : 0.0f)));
}



IntersectionResult intersectRayAabb(Ray ray, vec3 mi, vec3 ma)
{
#if 0
    float t;
    vec3 dirfrac = 1.0f / ray.direction;

    float t1 = (mi.x - ray.origin.x)*dirfrac.x;
    float t2 = (ma.x - ray.origin.x)*dirfrac.x;
    float t3 = (mi.y - ray.origin.y)*dirfrac.y;
    float t4 = (ma.y - ray.origin.y)*dirfrac.y;
    float t5 = (mi.z - ray.origin.z)*dirfrac.z;
    float t6 = (ma.z - ray.origin.z)*dirfrac.z;

    float tmin = max(max(min(t1, t2), min(t3, t4)), min(t5, t6));
    float tmax = min(min(max(t1, t2), max(t3, t4)), max(t5, t6));

    // if tmax < 0, ray (line) is intersecting AABB, but whole AABB is behing us
    if (tmax < 0)
    {
        t = tmax;
        return noIntersection;
    }

    // if tmin > tmax, ray doesn't intersect AABB
    if (tmin > tmax)
    {
        t = tmax;
        return noIntersection;
    }

    t = tmin;

    vec3 p = ray.origin + t*ray.direction;
    vec3 n = vec3(0,1,0);
    return IntersectionResult(true, t,n,p,EPSILON);
#else
    vec3 id = 1.0f / ray.direction; // 1 DIV
      vec3 pid = ray.origin * id; // 1 MUL
      vec3 l = mi*id - pid; // 1 MAD
      vec3 h = ma*id - pid; // 1 MAD
      vec3 tn3 = min(l, h);
      vec3 tf3 = max(l, h);
      float tf = min(tf3.x, min(tf3.y, tf3.z));
      float tn = max(tn3.x, max(tn3.y, tn3.z));

      if(max(tn, 0) <= tf)
      {
          float t= (tn < 0 ? tf : tn);
          vec3 p = ray.origin + t*ray.direction;
          vec3 n = boxNormal(p,mi,ma);
          return IntersectionResult(true, t,n,p,EPSILON);
      }else{
          return noIntersection;
      }
//      return max(tn, 0) <= tf ?  : INFINITY;
//    n = vec3(0,1,0) * d;
#endif

}

