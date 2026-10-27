shader_type spatial;
render_mode diffuse_toon, specular_disabled;

uniform vec4 base_color : source_color = vec4(0.45, 0.67, 0.44, 1.0);
uniform vec4 wind_color : source_color = vec4(1.0, 0.95, 0.81, 1.0);
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.35);
uniform float wind_strength : hint_range(0.0, 0.15) = 0.035;
uniform float wind_speed : hint_range(0.0, 8.0) = 1.4;

void vertex() {
	float mask = clamp(UV.y, 0.0, 1.0);
	float sway = sin(TIME * wind_speed + VERTEX.x * 2.3 + VERTEX.z * 1.7) * wind_strength * mask;
	VERTEX += normalize(wind_direction) * sway;
}

void fragment() {
	ALBEDO = mix(base_color.rgb, wind_color.rgb, 0.04);
	ROUGHNESS = 0.92;
}
