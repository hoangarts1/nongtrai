## Deterministically writes C0 generated shader/material/model assets.
extends SceneTree

const OUTPUT_ROOT: String = "res://assets/generated"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const MESH_BUILDER: Script = preload("res://tools/art/chibi/chibi_mesh_builder.gd")
const MESH_AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")

const TOON_SHADER: String = """shader_type spatial;
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
"""

const OUTLINE_SHADER: String = """shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 outline_color : source_color = vec4(0.29, 0.24, 0.28, 1.0);
uniform float outline_width : hint_range(0.0, 0.08) = 0.018;

void vertex() {
	VERTEX += NORMAL * outline_width;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
"""

const FOLIAGE_SHADER: String = """shader_type spatial;
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
"""

const WATER_SHADER: String = """shader_type spatial;
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
"""

const DITHER_FADE_SHADER: String = """shader_type spatial;
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
"""

const SHADER_SOURCES: Dictionary = {
	"chibi_toon.gdshader": TOON_SHADER,
	"chibi_outline.gdshader": OUTLINE_SHADER,
	"chibi_foliage.gdshader": FOLIAGE_SHADER,
	"chibi_water.gdshader": WATER_SHADER,
	"chibi_dither_fade.gdshader": DITHER_FADE_SHADER
}

func _init() -> void:
	var errors: PackedStringArray = PackedStringArray()
	errors.append_array(_ensure_directories())
	if errors.is_empty():
		errors.append_array(_write_shaders())
	if errors.is_empty():
		errors.append_array(_save_materials())
	if errors.is_empty():
		errors.append_array(_save_calibration_models())
	if errors.is_empty():
		errors.append_array(_write_manifest())
	if not errors.is_empty():
		for message: String in errors:
			printerr("[build_chibi_core] %s" % message)
		quit(1)
		return
	print("[build_chibi_core] wrote C0 assets under %s" % OUTPUT_ROOT)
	quit(0)

func _ensure_directories() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	for path: String in [
		"%s/shaders" % OUTPUT_ROOT,
		"%s/materials" % OUTPUT_ROOT,
		"%s/models/chibi_core" % OUTPUT_ROOT
	]:
		var result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
		if result != OK:
			errors.append("cannot create %s: %s" % [path, error_string(result)])
	return errors

func _write_shaders() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	for filename: String in SHADER_SOURCES:
		var path: String = "%s/shaders/%s" % [OUTPUT_ROOT, filename]
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			errors.append("cannot write shader: %s" % path)
			continue
		file.store_string(String(SHADER_SOURCES[filename]))
		file.close()
	return errors

func _save_materials() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var palette: Resource = load(PALETTE_PATH) as Resource
	if palette == null:
		return PackedStringArray(["cannot load palette: %s" % PALETTE_PATH])
	for shader_id: String in ["toon", "outline", "foliage", "water", "dither_fade"]:
		var shader_path: String = "%s/shaders/chibi_%s.gdshader" % [OUTPUT_ROOT, shader_id]
		var shader: Shader = load(shader_path) as Shader
		if shader == null:
			errors.append("cannot load generated shader: %s" % shader_path)
			continue
		var material: ShaderMaterial = _make_material(shader_id, shader, palette)
		var save_path: String = "%s/materials/mat_chibi_%s.tres" % [OUTPUT_ROOT, shader_id]
		var result: Error = ResourceSaver.save(material, save_path)
		if result != OK:
			errors.append("cannot save material %s: %s" % [shader_id, error_string(result)])
	return errors

func _make_material(shader_id: String, shader: Shader, palette: Resource) -> ShaderMaterial:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.resource_name = "mat_chibi_%s" % shader_id
	material.shader = shader
	match shader_id:
		"toon":
			material.set_shader_parameter(&"base_color", palette.get_color(&"wood"))
			material.set_shader_parameter(&"shadow_color", palette.get_color(&"shadow"))
			material.set_shader_parameter(&"rim_color", palette.get_color(&"sunlight"))
			material.set_shader_parameter(&"rim_strength", 0.18)
		"outline":
			material.set_shader_parameter(&"outline_color", palette.get_color(&"outline"))
			material.set_shader_parameter(&"outline_width", 0.018)
		"foliage":
			material.set_shader_parameter(&"base_color", palette.get_color(&"foliage"))
			material.set_shader_parameter(&"wind_color", palette.get_color(&"sunlight"))
			material.set_shader_parameter(&"wind_strength", 0.035)
		"water":
			material.set_shader_parameter(&"water_color", palette.get_color(&"water"))
			material.set_shader_parameter(&"foam_color", palette.get_color(&"sunlight"))
			material.set_shader_parameter(&"wave_height", 0.025)
		"dither_fade":
			material.set_shader_parameter(&"base_color", palette.get_color(&"roof"))
			material.set_shader_parameter(&"fade_amount", 1.0)
	return material

func _save_calibration_models() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var palette: Resource = load(PALETTE_PATH) as Resource
	if palette == null:
		return PackedStringArray(["cannot load palette for calibration models"])
	var models: Dictionary = {
		"chr_calibration.tscn": MESH_BUILDER.build_character(palette),
		"prop_calibration_a.tscn": MESH_BUILDER.build_prop(palette),
		"crp_calibration_s0.tscn": MESH_BUILDER.build_crop(palette),
		"bld_calibration_lv1.tscn": MESH_BUILDER.build_building(palette),
		"env_tree_calibration_01.tscn": MESH_BUILDER.build_tree(palette)
	}
	for filename: String in models:
		var model: Node3D = models[filename] as Node3D
		var kind: StringName = StringName(model.get_meta("art_kind", &""))
		var audit: PackedStringArray = MESH_AUDIT.validate_model(model, palette.get_triangle_budget(kind))
		if not audit.is_empty():
			errors.append_array(audit)
			model.free()
			continue
		_assign_scene_owners(model, model)
		var packed: PackedScene = PackedScene.new()
		var pack_result: Error = packed.pack(model)
		if pack_result != OK:
			errors.append("cannot pack calibration model %s: %s" % [filename, error_string(pack_result)])
			model.free()
			continue
		var save_result: Error = ResourceSaver.save(packed, "%s/models/chibi_core/%s" % [OUTPUT_ROOT, filename])
		if save_result != OK:
			errors.append("cannot save calibration model %s: %s" % [filename, error_string(save_result)])
		model.free()
	return errors

func _assign_scene_owners(node: Node, scene_root: Node) -> void:
	for child: Node in node.get_children():
		child.owner = scene_root
		_assign_scene_owners(child, scene_root)

func _write_manifest() -> PackedStringArray:
	var entries: Array[Dictionary] = []
	var palette: Resource = load(PALETTE_PATH) as Resource
	if palette == null:
		return PackedStringArray(["cannot load palette for manifest"])
	for data: Dictionary in [
		{"file": "chr_calibration.tscn", "kind": &"character"},
		{"file": "prop_calibration_a.tscn", "kind": &"prop"},
		{"file": "crp_calibration_s0.tscn", "kind": &"crop"},
		{"file": "bld_calibration_lv1.tscn", "kind": &"building"},
		{"file": "env_tree_calibration_01.tscn", "kind": &"tree"}
	]:
		var scene: PackedScene = load("%s/models/chibi_core/%s" % [OUTPUT_ROOT, data["file"]]) as PackedScene
		if scene == null:
			return PackedStringArray(["cannot load saved calibration scene: %s" % data["file"]])
		var root: Node3D = scene.instantiate() as Node3D
		var kind: StringName = StringName(data["kind"])
		entries.append({"file": data["file"], "kind": String(kind), "triangles": MESH_AUDIT.triangle_count(root), "budget": palette.get_triangle_budget(kind)})
		root.free()
	var file: FileAccess = FileAccess.open("%s/models/chibi_core/manifest.json" % OUTPUT_ROOT, FileAccess.WRITE)
	if file == null:
		return PackedStringArray(["cannot write calibration manifest"])
	file.store_string(JSON.stringify({"palette_id": String(palette.palette_id), "models": entries}, "\t"))
	file.close()
	return PackedStringArray()
