precision mediump float;

uniform mat4 cameraMatrixInverse;

uniform vec3 color;
uniform vec3 lightPosition;
uniform float shiny;

uniform bool ambient;
uniform bool diffuse;
uniform bool specular;

varying vec4 varyNormal;

varying vec4 varyWorldPos;

void main(void)
{

	vec3 k_amb = 0.1 * color;
	vec3 k_diff = 0.5 * color;
	vec3 k_spec = 0.4 * vec3(1, 1, 1);

	vec3 color_ambient, color_diffuse, color_specular;

	////////////////////////////////
	////////  ambient term  ////////
	////////////////////////////////
	color_ambient = k_amb;


	////////////////////////////////
	////////  diffuse term  ////////
	////////////////////////////////

	vec3 l = vec3(-(lightPosition.x - varyWorldPos.x),
					-(lightPosition.y - varyWorldPos.y),
					-(lightPosition.z - varyWorldPos.z));

	l = normalize(l);

	float cosnl = dot(vec3(varyNormal),l);

	color_diffuse = cosnl * k_diff;

	/////////////////////////////////
	////////  specular term  ////////
	/////////////////////////////////

	vec3 r = 2.0 * cosnl * vec3(varyNormal) - l;
	vec4 camerapos = cameraMatrixInverse * vec4(0,0,0,1);
	vec3 v = vec3(varyWorldPos) - vec3(camerapos.x,camerapos.y,camerapos.z);
	v = normalize(-1.0 * v);
	color_specular = k_spec * pow(dot(v,r), shiny);

	///////////////////////////////////
	////////  resulting color  ////////
	///////////////////////////////////
	vec3 color_result = vec3(0);
	if (ambient) color_result += color_ambient;
	if (diffuse) color_result += color_diffuse;
	if (specular) color_result += color_specular;
	gl_FragColor = vec4(color_result, 1.0);

}
