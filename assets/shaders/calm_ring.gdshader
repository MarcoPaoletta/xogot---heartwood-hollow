shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform vec4 ring_color : source_color = vec4(1.0, 0.85, 0.28, 1.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float outer = smoothstep(0.96, 0.88, r);
	float inner = smoothstep(0.68, 0.76, r);
	float ring = outer * inner;
	// Sweep angle 0..1 clockwise from top
	float ang = (atan(p.x, -p.y) + 3.14159265) / 6.2831853;
	float filled = step(ang, progress);
	float bg = 0.22 * smoothstep(0.01, 0.08, progress);
	float glow = ring * (filled * 0.95 + bg);
	ALBEDO = ring_color.rgb * (1.2 + 0.5 * filled);
	ALPHA = clamp(glow, 0.0, 1.0);
}
