shader_type spatial;
render_mode cull_disabled;

void fragment() {
	ALBEDO = vec3(0.1);
	vec3 norm = (CAMERA_MATRIX * vec4(NORMAL,0)).xyz;
	ALBEDO += sin((norm.x + norm.y + norm.z)*1337.42069)*0.02;
	//ALBEDO = norm;
}