shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 ray_color : source_color = vec4(1.0, 0.91, 0.56, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.22;

void vertex() {
	VERTEX.x += sin(TIME * 0.65 + UV.y * 2.0) * 0.35 * UV.y;
}

void fragment() {
	float horiz = 1.0 - abs(UV.x * 2.0 - 1.0);
	horiz = pow(clamp(horiz, 0.0, 1.0), 1.8);
	float vert = smoothstep(0.0, 0.25, UV.y) * (1.0 - smoothstep(0.55, 1.0, UV.y));
	float pulse = 0.85 + 0.15 * sin(TIME * 0.9 + UV.x * 5.0);
	ALBEDO = ray_color.rgb;
	ALPHA = horiz * vert * pulse * opacity;
}
