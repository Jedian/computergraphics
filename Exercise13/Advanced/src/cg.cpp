#include "cg.h"

using std::cout;
using std::endl;


CG::CG(int w, int h) : Window(w,h)
{
    shaderManager.registerProgram("rt", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);
    shaderManager.update();


    {
        //create plane mesh
        std::vector<int> indices = {0,1,2,2,3,0};
        std::vector<VertexNT> vertices;

        VertexNT v;
        v.normal = vec4(0,1,0,0);

        v.position = vec4(-1,0,-1,1);
        v.texture = vec2(0,0);
        vertices.push_back(v);
        v.position = vec4(1,0,-1,1);
        v.texture = vec2(1,0);
        vertices.push_back(v);
        v.position = vec4(1,0,1,1);
        v.texture = vec2(1,1);
        vertices.push_back(v);
        v.position = vec4(-1,0,1,1);
        v.texture = vec2(0,1);
        vertices.push_back(v);

        planeMesh.create(vertices,indices,GL_TRIANGLES);
    }


    camera.lookAt( vec3(-6,3,9),vec3 (-2,1.5,0), vec3(0,1,0));

    spheres = {
        vec4(-6,2.51,-2,2.5),
        vec4(0,1.01,3,1),
        vec4(-4,1.31,2,1.3),
        vec4(-2,4.1,-10,4),

        vec4(0,1,0,0),

        vec4(4,3,1.5,2.5)
    };

    materials = {
        { vec3(1,1,0), 1.5f, 0.8f },
        { vec3(1,0,0), 1.8f, 0 },
        { vec3(0,0,1), 1.8f, 0 },
        { vec3(0,1,0), 1.5f, 0 },
        { vec3(1,1,1), 1.3f, 0 },
        { vec3(0,1,1), 1.7f, 0 },
        { vec3(1,0,1), 1.5f, 1 }
    };


}

CG::~CG()
{
    imgui.shutdown();
}

void CG::update(float dt)
{
    shaderManager.update();

    if(!ImGui::GetIO().WantCaptureMouse)
        camera.update(dt);

    dt *= timeScale;
    time += dt;
}


void CG::render()
{
    glClearColor(0,0,0,0);

    glDepthMask(GL_TRUE);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);


    glm::mat4 proj = camera.getProjectionMatrix() ;
    glm::mat4 projView = camera.getProjectionMatrix() * camera.getViewMatrix();




    glUseProgram(shaderManager.getProgramGL("rt"));
    glUniform3fv(0,1,&camera.getViewPosition()[0]);
    glUniformMatrix4fv(1,1,GL_FALSE,&projView[0][0]);
    glUniform1i(3,lightSamples);
    glUniform1i(4,pixelSamples);

    vec3 lightPos = vec3(0,lightHeight,0);
    glUniform3fv(13,1,&lightPos[0]);

    glUniform1f(14,lightSize);
    glUniform1f(8,time);
    glUniform1i(9,debug);
    glUniformMatrix4fv(12,1,GL_FALSE,&boxTrans[0][0]);
    for(int i = 0; i < spheres.size(); ++i)
    {
        glUniform4fv(20+i,1,&spheres[i][0]);
    }

    for(int i = 0; i < materials.size(); ++i)
    {
        Material m = materials[i];
        glUniform3fv(50+i*3+0,1,&m.color[0]);
        glUniform1fv(50+i*3+1,1,&m.refractionN);
        glUniform1f(50+i*3+2,m.glass);
    }

    planeMesh.render();


}


void CG::renderGui()
{
    ImGui::SetNextWindowPos(ImVec2(0, 0), ImGuiSetCond_Always);
    ImGui::SetNextWindowSize(ImVec2(250,400), ImGuiSetCond_Always);
    ImGui::Begin("Raytracing 3");

    ImGui::SliderFloat("timeScale",&timeScale,0,2);

    ImGui::Text("FPS: %f",fps);

    ImGui::Separator();

    ImGui::SliderFloat("lightSize",&lightSize,0.1,5);
    ImGui::SliderFloat("lightHeight",&lightHeight,0,15);
    ImGui::SliderInt("lightSamples",&lightSamples,1,50);
    ImGui::SliderInt("pixelSamples",&pixelSamples,1,16);



    const char* items[2] = {
        "No Debug",
        "Random",
    };
    ImGui::Combo("debug",&debug,items,2);

    ImGui::End();
}



void CG::processEvent(const SDL_Event &event)
{

}
