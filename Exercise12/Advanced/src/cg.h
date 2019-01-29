#pragma once

#include "framework/cg_helper.h"


//#define SKELETON

#include "../shaders/rt.h"

class CG : public Window
{
public:
    CG(int w, int h);
    ~CG();
    virtual void update(float dt);
    virtual void render();
    virtual void renderGui();
private:
    float time = 0;
    float timeScale = 1;
    bool raytrace = true;
    Camera camera;
    Mesh  planeMesh, sphereMesh;

    int debug = 0;
    vec3 lightDir = normalize(vec3(0.39,-0.92,-0.03));
    int maxDepth = 10;
    float sunIntensity = 1;
    float shadow = 0.2;
    bool schlick = false;
    bool reflection = true;
    bool refraction = true;
    float airRefractionIndex = 1;
    mat4 boxTrans;

    std::vector<vec4> spheres;
    std::vector<Material> materials;

    virtual void processEvent(const SDL_Event& event);

};
