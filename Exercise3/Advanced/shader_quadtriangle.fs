precision mediump float;

uniform vec3 color;
uniform vec2 pointA;
uniform vec2 pointB;
uniform vec2 pointC;


void main(void)
{
  float area = 0.5 * (-pointB.y*pointC.x + pointA.y*(-pointB.x + pointC.x) +
      pointA.x*(pointB.y - pointC.y) + pointB.x*pointC.y);
  float s = 1.0/(2.0*area)*(pointA.y*pointC.x - pointA.x*pointC.y + (pointC.y -
        pointA.y)*gl_FragCoord.x + (pointA.x - pointC.x)*gl_FragCoord.y);
  float t = 1.0/(2.0*area)*(pointA.x*pointB.y - pointA.y*pointB.x + (pointA.y -
        pointB.y)*gl_FragCoord.x + (pointB.x - pointA.x)*gl_FragCoord.y);

  // Check if point is inside the triangle
  if(s <= 0.0 || t <= 0.0 || (1.0-s-t)<=0.0)
	  discard;
  else
    gl_FragColor = vec4(color, 1);
}
