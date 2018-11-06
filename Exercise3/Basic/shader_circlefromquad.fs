precision mediump float;

// TODO 3.3)	Define a constant variable (uniform) to 
//              "send" the canvas size to all fragments.



void main(void)
{ 

	 float smoothMargin = 0.01;  
	 float r = 0.8;         
	 
	 // TODO 3.3)	Map the fragment's coordinate (gl_FragCoord.xy) into 
	 //				the range of [-1,1]. Discard all fragments outside the circle 
	 //				with the radius r. Smooth the circle's edge within 
	 //				[r-smoothMargin, r] by computing an appropriate alpha value.
	 gl_FragColor = vec4(1.0, 85.0 / 255.0, 0.0, 1.0);


}