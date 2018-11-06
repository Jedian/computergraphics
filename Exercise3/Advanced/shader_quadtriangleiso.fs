precision mediump float;

uniform vec3 color;
uniform vec2 pointA;
uniform vec2 pointB;
uniform vec2 pointC;


void main(void)
{

	// TODO 3.4)	Use the fragment coordinate (gl_FragCoord) and clip
	//				it against the triangle that is defined by the three
	//				points A,B and C. If the fragment lies in the triangle
	//				set the gl_FragColor, otherwise discard the fragment
	//				(using "discard;"). If the fragment is inside the triangle
	//				and in the range of a iso line (within 1 pixel radius from
	//				a iso line) blend the color linearly with the color of the
	//				iso line (black). Draw all iso lines with a multiple of 14
	//				pixels distance.
	discard;
}
