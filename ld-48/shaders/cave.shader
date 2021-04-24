shader_type spatial;
render_mode cull_front;//, unshaded;

void fragment() {
	ALBEDO = vec3(0.1);
	vec3 norm = (CAMERA_MATRIX * vec4(NORMAL,0)).xyz;
	//ALBEDO += dot(NORMAL, vec3(0,1,0))*0.5+0.25;
	ALBEDO += sin((norm.x + norm.y + norm.z)*1337.0)*0.02;
	//ALBEDO = norm;
}