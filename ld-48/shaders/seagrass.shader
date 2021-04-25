shader_type spatial;
render_mode cull_disabled;

uniform vec4 color : hint_color = vec4(0,0.5,0.1,1);
uniform float speed : hint_range(0, 1) = 0.5;

void vertex() {
    VERTEX.x += sin(-VERTEX.y*50. + TIME*5.*speed)*0.05*VERTEX.y;
    VERTEX.z += sin(-VERTEX.y*50. + TIME*5.*speed)*0.05*VERTEX.y;
}

void fragment() {
    ALBEDO = color.rgb;
    vec3 norm = (CAMERA_MATRIX * vec4(NORMAL,0)).xyz;
	ALBEDO *= sin((norm.x + norm.y + norm.z)*1337.42069)*0.25+0.5;
}