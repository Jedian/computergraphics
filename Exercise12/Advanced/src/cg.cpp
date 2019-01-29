#include "cg.h"

using std::cout;
using std::endl;


CG::CG(int w, int h) : Window(w,h)
{
    shaderManager.registerProgram("rt", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);
    //    shaderManager.registerProgram("rt10", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);
    //    shaderManager.registerProgram("universe3", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);

    shaderManager.registerProgram("simple_color", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);

    shaderManager.registerProgram("sky", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);
    shaderManager.registerProgram("plane", SHADERTYPE_FLAG::VERTEX | SHADERTYPE_FLAG::FRAGMENT);
    shaderManager.update();

    sphereMesh.loadFromFile("data/icosphere_smooth.obj");

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


    camera.lookAt( vec3(-2,3,8),vec3 (-2,1.5,0), vec3(0,1,0));

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
        //        { vec3(0,1,1), 1.1f, 0.6f }
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

    auto r = glm::rotate(time*0.5f,normalize(vec3(1,10,1)));
    auto t = glm::translate(vec3(0,3,0));
    boxTrans = inverse(t * r);

}


void CG::render()
{
    glClearColor(0,0,0,0);

    glDepthMask(GL_TRUE);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);


    //    glEnable(GL_CULL_FACE);


    glm::mat4 proj = camera.getProjectionMatrix() ;
    glm::mat4 projView = camera.getProjectionMatrix() * camera.getViewMatrix();



    if(raytrace)
    {
        glUseProgram(shaderManager.getProgramGL("rt"));
        glUniform3fv(0,1,&camera.getViewPosition()[0]);
        glUniformMatrix4fv(1,1,GL_FALSE,&projView[0][0]);
        glUniform3fv(2,1,&lightDir[0]);
        glUniform1i(3,maxDepth);
        glUniform1f(4,shadow);
        glUniform1f(7,sunIntensity);
        glUniform1f(10,airRefractionIndex);
        glUniform1i(11,debug);
        glUniform1f(8,time);
        glUniform1i(9, schlick);
        glUniform1i(5, reflection);
        glUniform1i(6, refraction);
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
    else
    {
        glUseProgram(shaderManager.getProgramGL("simple_color"));
        glUniformMatrix4fv(0, 1, GL_FALSE, &projView[0][0]);
        glUniform3fv(3,1,&lightDir[0]);
        glUniform3fv(4,1,&camera.getViewPosition()[0]);


        for(int i = 0; i < spheres.size(); ++i)
        {
            vec4 p = spheres[i];
            vec3 color = materials[i].color;
            glUniform4fv(2,1,&vec4(color,1)[0]);


            mat4 m = glm::translate(vec3(p)) * glm::scale(vec3(p.w));
            glUniformMatrix4fv(1, 1, GL_FALSE, &m[0][0]);
            sphereMesh.render();
        }

        glUseProgram(shaderManager.getProgramGL("sky"));
        glUniform3fv(2,1,&lightDir[0]);
        glUniform1f(3,sunIntensity);

        glUniformMatrix4fv(0, 1, GL_FALSE, &projView[0][0]);
        glUniform3fv(1,1,&camera.getViewPosition()[0]);
        planeMesh.render();


        glUseProgram(shaderManager.getProgramGL("plane"));
        glUniformMatrix4fv(0, 1, GL_FALSE, &projView[0][0]);
        glUniform3fv(3,1,&lightDir[0]);
        //plane
        glUniform4fv(2,1,&vec4(0.7,0.7,0.7,1)[0]);
        mat4 m = glm::scale(vec3(1000));
        glUniformMatrix4fv(1, 1, GL_FALSE, &m[0][0]);
        planeMesh.render();
    }

}


void CG::renderGui()
{
    ImGui::SetNextWindowPos(ImVec2(0, 0), ImGuiSetCond_Always);
    ImGui::SetNextWindowSize(ImVec2(250,400), ImGuiSetCond_Always);
    ImGui::Begin("Raytracing 1");

    ImGui::SliderFloat("timeScale",&timeScale,0,2);

    ImGui::Text("FPS: %f",fps);

    ImGui::Checkbox("rayTrace (press space)",&raytrace);
    ImGui::Direction("lightDir",lightDir);
    ImGui::SliderFloat("sunIntensity",&sunIntensity,0,2);
//    ImGui::Checkbox("schlick", &schlick);

    ImGui::Separator();

    ImGui::Checkbox("reflection", &reflection);
    ImGui::Checkbox("refraction", &refraction);
    ImGui::SliderFloat("shadow",&shadow,0,1);
    ImGui::SliderInt("maxDepth",&maxDepth,0,20);
    ImGui::InputFloat("airRefractionIndex", &airRefractionIndex, 0.01, 0.1);

    const char* items[4] = {
        "All",
        "R",
        "T",
        "D",
    };
    ImGui::Combo("debug",&debug,items,4);

    std::vector<std::string> names = {
        "Sphere 1",
        "Sphere 2",
        "Sphere 3",
        "Sphere 4",
        "Ground Plane",
        "Spikeball",
        "Cube",
    };

    for(int i = 0;i < materials.size(); ++i)
    {

        Material& m = materials[i];

        if(ImGui::CollapsingHeader(names[i].c_str())){
            ImGui::PushID(i);
            ImGui::ColorEdit3("color",&m.color[0]);
            ImGui::Text("Refractive Index");
            //ImGui::SliderFloat("n",&m.refractionN,0,2);
            ImGui::InputFloat("n", &m.refractionN, 0.01, 0.1);
            ImGui::SliderFloat("glass", &m.glass, 0, 1);
            ImGui::PopID();
        }
    }


    //    ImGui::Text("Refractive Index - Spheres");
    //    ImGui::SliderFloat("sphereN",&sphereN,0,2);
    //    ImGui::Text("Refractive Index - Spikeball");
    //    ImGui::SliderFloat("spikeN",&spikeN,0,2);



    ImGui::End();
}



void CG::processEvent(const SDL_Event &event)
{
    if(event.type == SDL_KEYDOWN)
    {
        switch(event.key.keysym.sym)
        {
        case SDLK_SPACE:
            raytrace = !raytrace;
            break;
        }
    }
}
