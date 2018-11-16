#pragma once

#include "framework/window.h"
#include "framework/camera.h"
#include "framework/pngLoader.h"
#include "framework/objLoader.h"
#include "framework/cg_helper.h"

using namespace glm;

//#define SKELETON


class CG : public Window
{
public:
    CG(int w, int h);
    virtual void update(float dt);
    virtual void render();
    virtual void renderGui();
private:
    float time = 0;
    float timeScale = 1;
    Camera camera;
    Mesh teapotMesh, planeMesh;

    mat4 teapot, plane;

    struct Particle
    {
		vec3 position;			// the position of the particle in world space
		vec3 velocity;			// the velocity of the particle
		float lifeTime;			// the time until the particle is resetted to the starting position
		float timeOffset;		// an individual time offset to get particles out of sync
    };

    vec3 particleStart;
    std::vector<Particle> particles;

    vec3 lightDir = normalize(-vec3(2,5,-0.1));

    vec3 pointOnPlane;
    vec3 planeNormal;

    bool enableGeometry = true;
    bool enableTeapotShadows = false;
    bool enableParticles = false;
    bool enableParticleShadows = false;

    void renderOpaqueGeometry();
    void renderOpaqueGeometryShadows();

    void renderParticles();
    void renderParticleShadows();

};
