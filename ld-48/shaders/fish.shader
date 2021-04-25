shader_type spatial;

uniform vec4 color : hint_color = vec4(0,1,1,1);
uniform float speed : hint_range(0, 1) = 0.5;

void vertex() {
    VERTEX.x += sin(-VERTEX.y*200. + TIME*20.*speed)*0.001;
}

void fragment() {
    ALBEDO = color.rgb;
}