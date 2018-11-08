precision mediump float;


varying vec3 position;


void main(void)
{

	vec3 dark_blue = vec3(0, 0, 0.3);
	vec3 light_blue = vec3(0.4, 0.4, 1.0);
 	gl_FragColor = vec4(mix(dark_blue, light_blue, position.y+0.5), 1.0);

}
