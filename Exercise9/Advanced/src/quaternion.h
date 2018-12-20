#pragma once

#include "framework/config.h"


using namespace glm;


/**
 * A quaternion of the form
 * q = w + xi + yj + zk
 * with i,j,k imaginary elements.
 */
class Quaternion
{
public:
    float real; // <- Real part
    vec3 img; // <- Imaginary part

    Quaternion();
    Quaternion(vec3 axis, float angle);

    mat3 toMat3();
    mat4 toMat4();

    //simple functions
    float norm() const;
    Quaternion normalize();
    Quaternion conjugate() const;
    Quaternion inverse() const;
    friend float dot(Quaternion x, Quaternion y);

    //operators
    friend Quaternion operator*(Quaternion l, Quaternion r);
    friend Quaternion operator+(Quaternion l, Quaternion r);
    friend Quaternion operator*(Quaternion l, float r);
    friend vec3 operator*(Quaternion l, vec3 r);

    friend Quaternion slerp(Quaternion l, Quaternion r, float t);

    friend std::ostream& operator<<(std::ostream& str, Quaternion r);
};


