shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 slash_color : source_color = vec4(1.0, 0.92, 0.62, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// Crescent swipe mask across UV
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float ring = smoothstep(0.45, 0.68, r) * (1.0 - smoothstep(0.84, 1.0, r));
	float ang = atan(p.y, p.x); // -pi..pi
	float arc_mask = smoothstep(-1.4, -0.6, ang) * (1.0 - smoothstep(0.6, 1.4, ang));
	float trail = smoothstep(progress - 0.55, progress, (ang + 1.4) / 2.8);
	ALBEDO = slash_color.rgb * 1.3;
	ALPHA = ring * arc_mask * trail * opacity * 0.85;
}
