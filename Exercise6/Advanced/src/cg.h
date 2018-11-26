#pragma once

#include "framework/window.h"
#include "framework/camera.h"
#include "framework/pngLoader.h"
#include "framework/objLoader.h"
#include "framework/cg_helper.h"

using namespace glm;

#define SKELETON


struct Light
{
    int type = 0;
    bool enable = true;
    vec3 colorDiffuse = vec3(1);
    float diffuseIntensity = 0.7;

    float specularIntensity = 0.1;
    float shiny = 30;

    float ambientIntensity = 0.1;

    //only for spot and point light
    vec3 position;

    //only for spot and directional light
    vec3 direction = normalize(vec3(-1,-2,-1));

    //only for point and spot light
    vec3 attenuation = vec3(0.1,0.4,0.4);

    float angle = glm::radians(45.0f);
    float sharpness = 0.85f;

    void uploadUniform(int location);
    void renderImgui();
};


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
    Mesh teapotMesh, armadilloMesh, planeMesh, lanternMesh, lanternLampMesh, bonfireMesh;

    mat4 teapot, armadillo, plane, lantern, lanternLamp, bonfire, fire;

    Light directionalLight;
    Light spotLight;
    Light pointLight;

    bool cellShading = false;
};
