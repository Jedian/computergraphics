precision mediump float;
uniform vec3 color;
uniform vec2 pointA;
uniform vec2 pointB;
uniform vec2 pointC;

float distancePoint2Edge(vec2 pt, vec2 pta, vec2 ptb){
  float A = pt.x - pta.x;
  float B = pt.y - pta.y;
  float C = ptb.x - pta.x;
  float D = ptb.y - pta.y;
  float dot = A * C + B * D;
  float len_sq = C * C + D * D;
  float param = -1.0;
  if(len_sq != 0.0)
    param = dot/len_sq;

  float xx, yy;
  if(param < 0.){
    xx = pta.x;
    yy = pta.y;
  } else if(param > 1.){
    xx = ptb.x;
    yy = ptb.y;
  } else {
    xx = pta.x + param * C;
    yy = pta.y + param * D;
  }
  float dx = pt.x - xx;
  float dy = pt.y - yy;
  return sqrt(dx*dx+ dy*dy);
}

void main(void)
{

  float area = 0.5 * (-pointB.y*pointC.x + pointA.y*(-pointB.x + pointC.x) +
      pointA.x*(pointB.y - pointC.y) + pointB.x*pointC.y);
  float s = 1.0/(2.0*area)*(pointA.y*pointC.x - pointA.x*pointC.y + (pointC.y -
        pointA.y)*gl_FragCoord.x + (pointA.x - pointC.x)*gl_FragCoord.y);
  float t = 1.0/(2.0*area)*(pointA.x*pointB.y - pointA.y*pointB.x + (pointA.y -
        pointB.y)*gl_FragCoord.x + (pointB.x - pointA.x)*gl_FragCoord.y);

  if(s <= 0.0 || t <= 0.0 || (1.0-s-t)<=0.0)

    // Point is outside triangle
	  discard;

  else{

    // Point is inside of triangle, set it yellow
    gl_FragColor = vec4(color, 1);

    vec2 pt = vec2(gl_FragCoord.x, gl_FragCoord.y);
    float dab = distancePoint2Edge(pt, pointA, pointB); 
    float dbc = distancePoint2Edge(pt, pointB, pointC); 
    float dac = distancePoint2Edge(pt, pointA, pointC); 

    float mind = min(dab, min(dbc, dac));
    float mod = mind - (14.0 * floor(mind/14.0));
    
    // Point is in range of 1 pixel from a iso line, blend it black with yellow
    if(mod <= 1.0)
      gl_FragColor = mix(vec4(color, 1), vec4(0, 0, 0, 1), 1.0-mod);
    if(mod >= 13.0)
      gl_FragColor = mix(vec4(color, 1), vec4(0, 0, 0, 1), 1.0-(14.0-mod));
  }
}
