shader_type spatial;

uniform vec4 color : hint_color = vec4(0,1,1,1);
uniform float speed : hint_range(0, 1) = 0.5;
uniform vec4 emission : hint_color = vec4(0,0,0,1);
uniform float offset = 0;
uniform bool pulse = false;

void vertex() {
    VERTEX.x += sin(-VERTEX.y*100. + (TIME + offset)*20.*speed)*0.005;
}

void fragment() {
    ALBEDO = color.rgb;
    if (pulse)
        EMISSION = emission.rgb * (1.0+sin(TIME*5.0+offset));
    else
        EMISSION = emission.rgb * 0.5;
    //ROUGHNESS = 0.0;
    //METALLIC = 1.0;
}