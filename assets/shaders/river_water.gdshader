shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.14, 0.52, 0.58, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.28, 0.74, 0.72, 1.0);
uniform vec4 foam_color : source_color = vec4(0.92, 0.98, 0.96, 1.0);
uniform vec4 sparkle_color : source_color = vec4(1.0, 0.94, 0.65, 1.0);
uniform float speed : hint_range(0.0, 3.0) = 0.75;

void fragment() {
	vec2 uv = UV * vec2(18.0, 4.0);
	float t = TIME * speed;
	float w1 = sin(uv.x * 2.2 + t * 1.4 + sin(uv.y * 3.1 - t)) * 0.5 + 0.5;
	float w2 = cos(uv.x * 3.7 - t * 1.1 + uv.y * 4.2) * 0.5 + 0.5;
	float blend_w = clamp(w1 * 0.6 + w2 * 0.4, 0.0, 1.0);
	vec3 col = mix(deep_color.rgb, shallow_color.rgb, blend_w);

	// Soft foam near north & south riverbanks (UV.y near 0 or 1)
	float edge = min(UV.y, 1.0 - UV.y);
	float foam_wave = sin(uv.x * 4.0 + t * 2.2) * 0.025;
	float foam = 1.0 - smoothstep(0.02, 0.14 + foam_wave, edge);
	col = mix(col, foam_color.rgb, foam * 0.72);

	// Golden afternoon sun sparkles dancing on the water
	float sp = pow(max(0.0, sin(uv.x * 9.5 + t * 2.6) * cos(uv.y * 11.0 - t * 2.1)), 12.0);
	ALBEDO = col;
	ROUGHNESS = 0.22;
	METALLIC = 0.05;
	EMISSION = sparkle_color.rgb * sp * 1.1;
}
