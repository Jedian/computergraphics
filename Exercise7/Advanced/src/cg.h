#pragma once

#include "framework/cg_helper.h"


//#define SKELETON


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
    bool wireFrame = false;
    Camera camera;
    Mesh sphereMesh, planeMesh;

    Texture earthColor, earthNight, earthSpec, universe;
    mat4 sun, earth, clouds;

    int Tesselation = 1;
    float heightScale = 0.035f;
    float cameraSpeed = 0.02;

    bool useColor = false;
};
