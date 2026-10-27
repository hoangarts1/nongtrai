shader_type spatial;
render_mode diffuse_toon, specular_disabled;

uniform vec4 water_color : source_color = vec4(0.37, 0.68, 0.77, 1.0);
uniform vec4 foam_color : source_color = vec4(1.0, 0.95, 0.81, 1.0);
uniform float wave_height : hint_range(0.0, 0.12) = 0.025;
uniform float wave_speed : hint_range(0.0, 6.0) = 1.2;

void vertex() {
	VERTEX.y += sin(TIME * wave_speed + VERTEX.x * 3.2 + VERTEX.z * 2.1) * wave_height;
}

void fragment() {
	float foam = smoothstep(0.80, 1.0, sin(UV.x * 18.0 + TIME * wave_speed) * 0.5 + 0.5);
	ALBEDO = mix(water_color.rgb, foam_color.rgb, foam * 0.16);
	METALLIC = 0.08;
	ROUGHNESS = 0.28;
}
