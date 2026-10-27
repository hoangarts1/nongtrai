shader_type spatial;
render_mode diffuse_toon, specular_disabled;

uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 shadow_color : source_color = vec4(0.51, 0.45, 0.60, 1.0);
uniform vec4 rim_color : source_color = vec4(1.0, 0.95, 0.81, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.18;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.88;

void fragment() {
	ALBEDO = mix(base_color.rgb, rim_color.rgb, rim_strength * 0.08);
	ROUGHNESS = roughness_value;
	RIM = rim_strength;
}

void light() {
	float illumination = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float band = smoothstep(0.32, 0.58, illumination);
	vec3 tinted_light = mix(shadow_color.rgb, vec3(1.0), band);
	DIFFUSE_LIGHT = tinted_light * LIGHT_COLOR * ATTENUATION;
}
