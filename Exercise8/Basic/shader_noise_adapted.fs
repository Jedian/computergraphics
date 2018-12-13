#version 300 es

precision mediump float;

in vec2 texcoord;

out vec4 fragColor;

//------------------------------------------------
// WebGL Noise:
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl
//------------------------------------------------
//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 
//------------------------------------------------

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
	return mod289(((x*34.0) + 1.0)*x);
}

float snoise(vec2 v)
{
	const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
		0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
		-0.577350269189626,  // -1.0 + 2.0 * C.x
		0.024390243902439); // 1.0 / 41.0
							// First corner
	vec2 i = floor(v + dot(v, C.yy));
	vec2 x0 = v - i + dot(i, C.xx);

	// Other corners
	vec2 i1;
	//i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
	//i1.y = 1.0 - i1.x;
	i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	// x0 = x0 - 0.0 + 0.0 * C.xx ;
	// x1 = x0 - i1 + 1.0 * C.xx ;
	// x2 = x0 - 1.0 + 2.0 * C.xx ;
	vec4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;

	// Permutations
	i = mod289(i); // Avoid truncation effects in permutation
	vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
		+ i.x + vec3(0.0, i1.x, 1.0));

	vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
	m = m*m;
	m = m*m;

	// Gradients: 41 points uniformly over a line, mapped onto a diamond.
	// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;

	// Normalise gradients implicitly by scaling m
	// Approximation of: m *= inversesqrt( a0*a0 + h*h );
	m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);

	// Compute final noise value at P
	vec3 g;
	g.x = a0.x  * x0.x + h.x  * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	return 130.0 * dot(m, g);
}

//------------------------------------------------

// "Fractal brownian motion"
// vec2 p: 2D position used to evaluate the noise
// float n: number of octaves, smoothly interpolate
//          between floor(n) and ceil(n).
float fbm(vec2 p, float n) {
	float s = 0.0;
	float freq = 1.0;
	float am = 1.0;

	for (int i = 0; i < int(n); ++i) {
		s += snoise(p * freq)*am;
		freq *= 2.0;
		am *= 0.7;
	}

	s += snoise(p*freq)*am*fract(n);
	s = s * 0.5 + 0.5;
	return s;
}

void main(void) {

	vec2 iResolution = vec2(300, 300);	// screen resolution of canvas
	vec2 tc = texcoord;					// texture coordinates in [0...1]

	float maxLevel = 4.0;				// the maximum level for fbm()
	float baseFreq = 12.0;				// the base frequency, chosen as 12

	float n;							// the level to which aggregation should take place



	// TODO 8.2		Follow the steps to implement "MIP mapping" for procedural
	//				texturing!

	// 1. Compute the texture coordinates in pixel space, using the resolution of the canvas.
    vec2 tc_ps = vec2(tc.x*iResolution.x, tc.y*iResolution.y);

	// 2. Compute the derivatives of these coordinates - the higher, the farther away the point on the plane is.
	//	  Use the functions dFdx() and dFdy() provided by GLSL.
    vec2 tc_psdx = dFdx(tc_ps);
    vec2 tc_psdy = dFdy(tc_ps);

	// 3. Compute the delta value also used by the normal OpenGL MIP mapping procedure.
	//    Use equation 3.21 in chapter 3.9.11 of the OpenGL specification
	//    (https://www.khronos.org/registry/OpenGL/specs/gl/glspec42.core.pdf), but for only two coordinates.
	//    Subsequently, use delta to compute lambda as in equation 3.17.
    float delta = max(sqrt(tc_psdx.x*tc_psdx.x + tc_psdx.y*tc_psdx.y), sqrt(tc_psdy.x*tc_psdy.x + tc_psdy.y*tc_psdy.y));
    float lambda = log2(delta);

	// 4. The higher lambda is, the farther the fragment is away, so we want to choose a smaller n
	//    in order to prevent minification. Therefore, choose n as (maxLevel - lambda) and clamp it to
	//	  the range from 0 to maxLevel. Replace the dummy line that sets n to maxLevel no matter how far the plane is!
	n = clamp(maxLevel-lambda, 0.0, maxLevel);

	fragColor = vec4(vec3(fbm(tc*baseFreq, n)), 1);

	// uncomment this to have a color clue about the used n
	//if (n < 1.0) fragColor += vec4(0.1, 0, 0, 1.0);
	//else if (n < 2.0) fragColor += vec4(0, 0.1, 0, 1.0);
	//else if (n < 3.0) fragColor += vec4(0, 0, 0.1, 1.0);
	//else fragColor += vec4(0.1, 0, 0, 1.0);


}
