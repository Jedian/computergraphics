
vec3 floorColor(vec3 color, vec3 position)
{
    vec3 c1 = color;
    vec3 c2 = color * 0.5;
    float steps = 0.1;
    vec2 tc = position.xz ;
    vec2 tc2 = tc * steps;
    vec2 cp = fract(tc2);
    float d= length(tc);
    float s = 0.01f + d / 1000;
    vec2 pp = smoothstep(vec2(0.5),vec2(0.5+s),cp) + (1-smoothstep(vec2(0),vec2(s),cp));
    vec3 surfaceColor = mix(c1, c2, pp.x * pp.y + (1 - pp.y) * (1 - pp.x));
    float a = smoothstep(30,100,d);
    return mix(surfaceColor, (c1 + c2) * 0.5,a);
}
