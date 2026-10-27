## ChibiMaterialFactory — opt-in ShaderMaterial construction from the C0 palette.
## API:
##   static func create_material(shader_id: StringName, role: StringName, season: StringName = &"spring") -> ShaderMaterial
##   static func get_shader_paths() -> PackedStringArray
##   static func get_material_paths() -> PackedStringArray
class_name ChibiMaterialFactory
extends RefCounted

const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const SHADER_PATHS: Dictionary = {
	&"toon": "res://assets/generated/shaders/chibi_toon.gdshader",
	&"outline": "res://assets/generated/shaders/chibi_outline.gdshader",
	&"foliage": "res://assets/generated/shaders/chibi_foliage.gdshader",
	&"water": "res://assets/generated/shaders/chibi_water.gdshader",
	&"dither_fade": "res://assets/generated/shaders/chibi_dither_fade.gdshader"
}
const MATERIAL_PATHS: Dictionary = {
	&"toon": "res://assets/generated/materials/mat_chibi_toon.tres",
	&"outline": "res://assets/generated/materials/mat_chibi_outline.tres",
	&"foliage": "res://assets/generated/materials/mat_chibi_foliage.tres",
	&"water": "res://assets/generated/materials/mat_chibi_water.tres",
	&"dither_fade": "res://assets/generated/materials/mat_chibi_dither_fade.tres"
}

static func get_palette() -> Resource:
	return load(PALETTE_PATH) as Resource

static func get_shader_paths() -> PackedStringArray:
	var paths: PackedStringArray = PackedStringArray()
	for shader_id: StringName in SHADER_PATHS:
		paths.append(String(SHADER_PATHS[shader_id]))
	return paths

static func get_material_paths() -> PackedStringArray:
	var paths: PackedStringArray = PackedStringArray()
	for shader_id: StringName in MATERIAL_PATHS:
		paths.append(String(MATERIAL_PATHS[shader_id]))
	return paths

static func create_material(shader_id: StringName, role: StringName, season: StringName = &"spring") -> ShaderMaterial:
	var palette: Resource = get_palette()
	var material: ShaderMaterial = ShaderMaterial.new()
	if palette == null or not SHADER_PATHS.has(shader_id):
		return material
	material.shader = load(String(SHADER_PATHS[shader_id])) as Shader
	var base_color: Color = palette.get_color(role, season)
	match shader_id:
		&"toon":
			material.set_shader_parameter(&"base_color", base_color)
			material.set_shader_parameter(&"shadow_color", palette.get_color(&"shadow", season))
			material.set_shader_parameter(&"rim_color", palette.get_color(&"sunlight", season))
			material.set_shader_parameter(&"rim_strength", 0.18)
		&"outline":
			material.set_shader_parameter(&"outline_color", palette.get_color(&"outline", season))
			material.set_shader_parameter(&"outline_width", 0.018)
		&"foliage":
			material.set_shader_parameter(&"base_color", base_color)
			material.set_shader_parameter(&"wind_color", palette.get_color(&"sunlight", season))
			material.set_shader_parameter(&"wind_strength", 0.035)
		&"water":
			material.set_shader_parameter(&"water_color", base_color)
			material.set_shader_parameter(&"foam_color", palette.get_color(&"sunlight", season))
			material.set_shader_parameter(&"wave_height", 0.025)
		&"dither_fade":
			material.set_shader_parameter(&"base_color", base_color)
			material.set_shader_parameter(&"fade_amount", 1.0)
	return material
