precision mediump float;

uniform vec2 canvasSize;

void main(void)
{ 

	float smoothMargin = 0.01;  
	float r = 0.8;         

	float x = (2.0 * gl_FragCoord.xy[0] / canvasSize[0]) - 1.0;
	float y = (2.0 * gl_FragCoord.xy[1] / canvasSize[1]) - 1.0;

	float dist = sqrt((x * x) + (y * y));
	float rdistMargin = abs(r - smoothMargin);

	if(dist <= r){
		float alpha = clamp(dist, rdistMargin, r); //clamp(a,b,c) = min(max(a,b),c)
		alpha -= rdistMargin;
		alpha /= smoothMargin;

		gl_FragColor = vec4(1.0, 85.0 / 255.0, 0.0, 1.0 - alpha);
	}
	else
		discard;
}
