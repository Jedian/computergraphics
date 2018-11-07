precision mediump float;

attribute vec3 vVertex;

uniform mat4 MVP;	// model view projection matrix
					// You will learn about this in the following lectures, 
					// you do not need to care about it right now.

uniform float time;

varying vec3 position;

// returns a quasi-random value from a pair of floats
float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(void)
{

	float amplitude = 0.5 * rand(vec2(vVertex.x, vVertex.z));
	float period = rand(vec2(vVertex.z, vVertex.x));

  vec3 p = vVertex;

  p.y = amplitude * rand(vec2(period, time/5000000.0));

	gl_Position = MVP * vec4(p, 1);

	vec4 pos = vec4(p, 1);
	position = pos.xyz / pos.w;


}
