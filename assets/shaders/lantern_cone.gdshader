shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 cone_color : source_color = vec4(1.0, 0.86, 0.36, 1.0);
uniform float intensity : hint_range(0.0, 2.0) = 0.0;

void fragment() {
	// UV.y goes 0 at lantern apex to 1 at far end of 6m cone
	float along = clamp(UV.y, 0.0, 1.0);
	float fade_len = smoothstep(0.0, 0.14, along) * (1.0 - smoothstep(0.35, 1.0, along));
	// Soft Fresnel fade so cone edges look like warm golden light beams, never hard plastic
	float ndv = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float fresnel = pow(ndv, 1.65);
	float shimmer = 0.90 + 0.10 * sin(TIME * 3.5 + along * 10.0 + UV.x * 12.566);
	float alpha = fade_len * fresnel * shimmer * 0.42 * intensity;
	ALBEDO = cone_color.rgb * (1.1 + 0.3 * (1.0 - along));
	ALPHA = clamp(alpha, 0.0, 0.85);
}
