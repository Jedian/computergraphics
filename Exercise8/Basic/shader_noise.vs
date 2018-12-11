#version 300 es

precision mediump float;

in vec3 vVertex;
in vec2 vTexCoord;

uniform mat4 modelMatrix; // model matrix
uniform mat4 cameraMatrix; // camera matrix
uniform mat4 projectionMatrix; // projection matrix


out vec2 texcoord;

void main(void)
{

	mat4 MVP = projectionMatrix * cameraMatrix * modelMatrix;
	gl_Position = MVP * vec4(vVertex, 1);
	
	texcoord = vTexCoord;
}