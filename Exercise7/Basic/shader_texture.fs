precision mediump float;

uniform mat4 cameraMatrixInverse;

uniform vec3 lightPosition;
uniform vec2 planeSize;

uniform bool cobblestone;

uniform sampler2D checkerboardTexture;

uniform sampler2D cobblestoneTexture;

varying vec3 normal;
varying vec3 position;

varying vec2 texCoord;

void main(void) {

	float shiny = 10.0;

	vec3 n;
	vec3 color;
	if (cobblestone) {
		color = vec3(0.5, 0.5, 0.5);

		vec4 acolor = texture2D(cobblestoneTexture, texCoord / planeSize);

		vec3 remap = vec3((acolor[0]*2.0)-1.0,(acolor[1]*2.0)-1.0,(acolor[2]*2.0)-1.0);

		n = remap;
	}
	else {
		n = normal;

		vec4 acolor = texture2D(checkerboardTexture, texCoord);

		color = vec3(acolor[0]*acolor[3],acolor[1]*acolor[3],acolor[2]*acolor[3]);
	}

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
	n = normalize(n);
	vec3 l = normalize(lightPosition - position);
	color_diffuse = k_diff * max(0.0, dot(n, l));

	/////////////////////////////////
	////////  specular term  ////////
	/////////////////////////////////
	vec3 cameraPosition = (cameraMatrixInverse * vec4(0, 0, 0, 1)).xyz;
	vec3 v = normalize(cameraPosition - position);
	vec3 r = normalize(2.0 * dot(n, l) * n - l);
	color_specular = k_spec * pow(max(0.0, dot(v, r)), shiny);

	///////////////////////////////////
	////////  resulting color  ////////
	///////////////////////////////////
	vec3 color_result = vec3(0);
	color_result += color_ambient;
	color_result += color_diffuse;
	color_result += color_specular;
	gl_FragColor = vec4(color_result, 1.0);
}