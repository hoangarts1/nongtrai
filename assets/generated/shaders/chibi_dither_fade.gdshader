shader_type spatial;
render_mode blend_mix, cull_back;

uniform vec4 base_color : source_color = vec4(1.0);
uniform float fade_amount : hint_range(0.0, 1.0) = 1.0;

float dither_pattern(vec2 coordinate) {
	return fract(sin(dot(floor(coordinate * 32.0), vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	if (dither_pattern(UV) > fade_amount) {
		discard;
	}
	ALBEDO = base_color.rgb;
	ROUGHNESS = 0.90;
}
