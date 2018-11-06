precision mediump float;

// TODO 3.2a)	Define the varying variable again
//				using the same name to enable 
//				communication between vertex and
//				fragment shader.

varying vec3 varyColor;


void main(void)
{

	float epsilon = .01;

	// TODO 3.2a)	Give each pixel the interpolated
	//				triangle color.
	gl_FragColor = vec4(varyColor[0], varyColor[1], varyColor[2], 1.0);


	
	// TODO 3.2b)	Use the color as barycentric coordinates
	//				and discard all pixels not considered 
	//				edges (farther away from an edge than 
	//				epsilon). Use the GLSL mechanism 'discard'.
	
	if( !(varyColor[0] <= epsilon || varyColor[1] <= epsilon || varyColor[2] <= epsilon))
		discard;
}