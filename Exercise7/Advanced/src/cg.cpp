#include "cg.h"

using std::cout;
using std::endl;


CG::CG(int w, int h) : Window(w,h)
{
    shaderManager.registerProgram("earth", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT | SHADERTYPE_FLAG::TESSCONTROL | SHADERTYPE_FLAG::TESSEVALUATION);
    shaderManager.registerProgram("sun", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);
    shaderManager.registerProgram("universe", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);
    shaderManager.update();

    sphereMesh.loadFromFile("data/icosphere_highres.obj");

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

    earthColor.loadFromFile("data/earthColor2.png");
    earthNight.loadFromFile("data/earthNight.png");
    earthSpec.loadFromFile("data/earthSpec.png");
    universe.loadFromFile("data/universe.png");

    sun =  glm::scale(vec3(10));

    camera.lookAt( vec3(28.1349,1.20666,3.97974),vec3 (27.6059,1.07783,3.141), vec3(0,1,0));

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

    camera.setSpeed(cameraSpeed);

    float earthRotationAngularVelocity = glm::two_pi<float>() / 200;
    mat4 rotateEarth = glm::rotate(time * earthRotationAngularVelocity + 2.2f,normalize(vec3(0,1,0)));
    mat4 rotateInitial = glm::rotate(glm::radians(23.0f),normalize(vec3(0,0,1)));
    earth = glm::translate(vec3(30,0,0))  * rotateInitial * rotateEarth  * glm::scale(vec3(3.5));

}


void CG::render()
{
    glClearColor(0,0,0,0);

    glDepthMask(GL_TRUE);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);


    glEnable(GL_CULL_FACE);

    if(wireFrame)
    {
        glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
    }

    glm::mat4 proj = camera.getProjectionMatrix() ;
    glm::mat4 projView = camera.getProjectionMatrix() * camera.getViewMatrix();

    glUseProgram(shaderManager.getProgramGL("earth"));
    glUniformMatrix4fv(0, 1, GL_FALSE, &projView[0][0]);
    glUniformMatrix4fv(1, 1, GL_FALSE, &earth[0][0]);

    vec3 sunPosition = vec3(sun[3]);
    glUniform3fv(2,1,&sunPosition[0]);
    glUniform3fv(3,1,&vec3(1,1,1)[0]);
    glUniform3fv(4,1,&camera.getViewPosition()[0]);


    earthColor.bind(0,10);
    earthNight.bind(3,13);
    earthSpec.bind(5,15);

    glUniform1f(5,Tesselation);
    glUniform1f(7,heightScale);

    glUniform1i(20,useColor);

    glPatchParameteri(GL_PATCH_VERTICES, 3);
    glBindVertexArray(sphereMesh.vao);
    glDrawElements(GL_PATCHES,sphereMesh.numElements,GL_UNSIGNED_INT,0);
    sphereMesh.render();
    glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );

    glUseProgram(shaderManager.getProgramGL("universe"));


    glUniformMatrix4fv(0, 1, GL_FALSE, &projView[0][0]);
    glUniform3fv(1,1,&camera.getViewPosition()[0]);
    universe.bind(0,10);
    planeMesh.render();


    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);

    glUseProgram(shaderManager.getProgramGL("sun"));
    glUniformMatrix4fv(0, 1, GL_FALSE, &projView[0][0]);

    //rotate sun to camera
    mat4 v = inverse(camera.getViewMatrix());
    v = mat4(mat3(v)); //only use rotation part
    mat4 sunTransformation = sun *  v * glm::rotate(glm::radians(-90.0f),vec3(1,0,0));
    glUniformMatrix4fv(1, 1, GL_FALSE, &sunTransformation[0][0]);
    planeMesh.render();

    glDisable(GL_BLEND);
}


void CG::renderGui()
{
    ImGui::SetNextWindowPos(ImVec2(0, 0), ImGuiSetCond_FirstUseEver);
    ImGui::SetNextWindowSize(ImVec2(400,200), ImGuiSetCond_FirstUseEver);
    ImGui::Begin("Texture Mapping");

    ImGui::SliderFloat("timeScale",&timeScale,0,2);

    ImGui::Checkbox("wireFrame",&wireFrame);

    ImGui::SliderFloat("cameraSpeed",&cameraSpeed,0,0.2);

    ImGui::Separator();

    ImGui::Checkbox("useColor",&useColor);

    ImGui::End();
}



