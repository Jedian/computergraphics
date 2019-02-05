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
    Camera camera;
    Mesh  planeMesh;


    int debug = 0;
    float lightSize = 1;
    float lightHeight = 8;

    int lightSamples = 16;
    int pixelSamples = 8;
    mat4 boxTrans;

    std::vector<vec4> spheres;
    std::vector<Material> materials;

    virtual void processEvent(const SDL_Event& event);

};
