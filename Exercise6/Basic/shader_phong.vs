precision mediump float;

attribute vec3 vVertex;
attribute vec3 vNormal;

uniform mat4 modelMatrix; // model matrix
uniform mat4 cameraMatrix; // camera matrix
uniform mat4 projectionMatrix; // projection matrix

uniform mat4 normalMatrix;

varying vec4 varyNormal;


varying vec4 varyWorldPos;

void main(void)
{

	mat4 MVP = projectionMatrix * cameraMatrix * modelMatrix;
	gl_Position = MVP * vec4(vVertex, 1);

	varyNormal = normalize(modelMatrix * vec4(vNormal, 1));

	varyWorldPos = modelMatrix * vec4(vVertex, 1);
	varyWorldPos.x = varyWorldPos.x / varyWorldPos.w;
	varyWorldPos.y = varyWorldPos.y / varyWorldPos.w;
	varyWorldPos.z = varyWorldPos.z / varyWorldPos.w;
	varyWorldPos.w = varyWorldPos.w / varyWorldPos.w;

}