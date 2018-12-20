#include "quaternion.h"


Quaternion::Quaternion()
{
    real = 1;
    img = vec3(0.0, 0.0, 0.0);
    
}

Quaternion::Quaternion(vec3 axis, float angle)
{
    img = axis * sin(angle/2);
    real = cos(angle/2);
}



mat3 Quaternion::toMat3()
{
    // Conversion Quaternion -> mat3
    // You won't have to implement it this year :).
    mat3 Result;
    float qxx(img.x * img.x);
    float qyy(img.y * img.y);
    float qzz(img.z * img.z);
    float qxz(img.x * img.z);
    float qxy(img.x * img.y);
    float qyz(img.y * img.z);
    float qwx(real * img.x);
    float qwy(real * img.y);
    float qwz(real * img.z);

    Result[0][0] = float(1) - float(2) * (qyy +  qzz);
    Result[0][1] = float(2) * (qxy + qwz);
    Result[0][2] = float(2) * (qxz - qwy);

    Result[1][0] = float(2) * (qxy - qwz);
    Result[1][1] = float(1) - float(2) * (qxx +  qzz);
    Result[1][2] = float(2) * (qyz + qwx);

    Result[2][0] = float(2) * (qxz + qwy);
    Result[2][1] = float(2) * (qyz - qwx);
    Result[2][2] = float(1) - float(2) * (qxx +  qyy);
    return Result;
}

mat4 Quaternion::toMat4()
{
    return mat4(toMat3());
}


float Quaternion::norm() const
{
    float n = real*real + img.x*img.x + img.y*img.y + img.z*img.z;
    return sqrt(n);

}

Quaternion Quaternion::normalize()
{
    float n = norm();
    img /= n;
    real /= n;
    return *this;

}

Quaternion Quaternion::conjugate() const
{
    Quaternion result(-img, real);
    return result;

}

Quaternion Quaternion::inverse() const
{
    Quaternion result = conjugate();
    float s = 1.0/(norm()*norm());
    result.real *= s;
    result.img *= s; 
    return result;

}



float dot(Quaternion x, Quaternion y)
{
    float d = x.real * y.real + dot(x.img,y.img);
    return d;

}



Quaternion operator*(Quaternion l, Quaternion r)
{
    Quaternion result;
    result.real = (l.real*r.real) - dot(l.img, r.img);
    result.img = l.real*r.img + r.real*l.img + cross(l.img, r.img);//ad + bc + bxd
    return result;

}

vec3 operator*(Quaternion l, vec3 r)
{
    Quaternion aux(r, 0.0f);
    aux = l * aux * l.inverse();
    return l.img;

}

Quaternion operator*(Quaternion l, float r)
{
    Quaternion result;
    result.img = r*l.img;
    result.real = r*l.real;
    return result;

}

Quaternion operator+(Quaternion l, Quaternion r)
{
    Quaternion result;
    result.real = l.real + r.real;
    result.img = l.img + r.img;
    return result;

}



Quaternion slerp(Quaternion x, Quaternion y, float t)
{
	float epsilon = 0.00001;

    Quaternion difs;
    Quaternion result;
    if(dot(x, y) > 1-epsilon){
	difs.img = y.img - x.img;
	difs.real = y.real - x.real;
	result = x + difs*t;
	return result;
    }

    float omega = acos(dot(x, y));
    float s1 = sin((1-t)*omega)/sin(omega);
    float s2 = sin(t*omega)/sin(omega);
    result = x*s1 + y*s2;
    
    return result;


}

std::ostream& operator<<(std::ostream &str, Quaternion r)
{
    str << "( " << r.real << "," << r.img.x << "," << r.img.y << "," << r.img.z << " )";
        return str;
}
