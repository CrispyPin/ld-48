shader_type spatial;

uniform vec4 color : hint_color = vec4(0,1,1,1);
uniform float speed : hint_range(0, 1) = 0.5;
uniform vec4 emission : hint_color = vec4(0,0,0,1);
uniform float offset = 0;
uniform bool pulse = false;
uniform bool circular = false;
uniform bool frontStill = false;
uniform float amplitude = 1;

varying flat float vertY;



void vertex() {
    float fac = 1.0;
    if (frontStill)
        fac*=min(VERTEX.z,0);
    VERTEX.x += amplitude*sin(VERTEX.z*1.0 + (TIME + offset)*20.0*speed)*0.5*fac;
    if (circular)
        VERTEX.y += amplitude*cos(VERTEX.z*1.0 + (TIME + offset)*20.0*speed)*0.5*fac;
}

void fragment() {
    ALBEDO = color.rgb;
    //ROUGHNESS = 0.0;
    //METALLIC = 0.0;

    //if (pulse)
    if (true)
        EMISSION = emission.rgb * (1.0+sin(TIME*5.0+offset));
    else
        EMISSION = emission.rgb * 0.5;
}
