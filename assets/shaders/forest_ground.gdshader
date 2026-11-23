shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform vec4 moss_dark : source_color = vec4(0.24, 0.40, 0.14, 1.0);
uniform vec4 meadow_mid : source_color = vec4(0.37, 0.56, 0.20, 1.0);
uniform vec4 sunlit_fleck : source_color = vec4(0.56, 0.69, 0.26, 1.0);

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos.xz;
	// Multi-scale painterly forest moss & dappled sunlight patches
	float n1 = vnoise(p * 0.11);
	float n2 = vnoise(p * 0.34 + vec2(11.3, 7.1));
	float n3 = vnoise(p * 1.15 + vec2(3.7, 19.4));
	float dapple = n1 * 0.55 + n2 * 0.32 + n3 * 0.13;

	vec3 col = mix(moss_dark.rgb, meadow_mid.rgb, smoothstep(0.22, 0.62, dapple));
	col = mix(col, sunlit_fleck.rgb, smoothstep(0.60, 0.86, dapple) * 0.72);
	ALBEDO = col;
	ROUGHNESS = 0.92;
	METALLIC = 0.0;
}
