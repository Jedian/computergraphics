precision mediump float;

varying vec3 varyColor;

void main(void)
{

	float epsilon = .01;

	gl_FragColor = vec4(varyColor[0], varyColor[1], varyColor[2], 1.0);

	if( !(varyColor[0] <= epsilon || varyColor[1] <= epsilon || varyColor[2] <= epsilon))
		discard;
}