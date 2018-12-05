precision mediump float;

attribute vec3 vVertex;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

uniform mat4 modelMatrix; // model matrix
uniform mat4 cameraMatrix; // camera matrix
uniform mat4 projectionMatrix; // projection matrix

uniform mat4 normalMatrix;

varying vec3 normal;
varying vec3 position;

varying vec2 texCoord;

void main(void)
{

	mat4 MVP = projectionMatrix * cameraMatrix * modelMatrix;
	gl_Position = MVP * vec4(vVertex, 1);

	normal = normalize((normalMatrix * vec4(normalize(vNormal), 0)).xyz);
	vec4 pos = modelMatrix * vec4(vVertex, 1);
	position = pos.xyz / pos.w;

	texCoord = vTexCoord;

}