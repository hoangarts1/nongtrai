extends GutTest

const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"
const PALETTE_SCRIPT: Script = preload("res://scripts/data/art_palette.gd")
const VALIDATOR: Script = preload("res://scripts/core/data_validator.gd")
const MATERIAL_FACTORY: Script = preload("res://scripts/view/chibi_material_factory.gd")
const MESH_BUILDER: Script = preload("res://tools/art/chibi/chibi_mesh_builder.gd")
const MESH_AUDIT: Script = preload("res://tools/art/chibi/chibi_mesh_audit.gd")
const REVIEW_LAYOUT: Script = preload("res://tools/art/chibi/art_review.gd")
const LINEUP_SCENE: PackedScene = preload("res://tools/art_lineup.tscn")

const MODEL_ENTRIES: Array[Dictionary] = [
	{"path": "res://assets/generated/models/chibi_core/chr_calibration.tscn", "kind": &"character"},
	{"path": "res://assets/generated/models/chibi_core/prop_calibration_a.tscn", "kind": &"prop"},
	{"path": "res://assets/generated/models/chibi_core/crp_calibration_s0.tscn", "kind": &"crop"},
	{"path": "res://assets/generated/models/chibi_core/bld_calibration_lv1.tscn", "kind": &"building"},
	{"path": "res://assets/generated/models/chibi_core/env_tree_calibration_01.tscn", "kind": &"tree"}
]

func test_palette_is_data_valid_and_has_all_four_seasons() -> void:
	var palette: Resource = load(PALETTE_PATH) as Resource
	assert_not_null(palette)
	assert_eq(String(palette.get("palette_id")), "chibi_valley")
	var errors: PackedStringArray = palette.validate()
	assert_eq(errors.size(), 0)
	assert_eq(VALIDATOR.validate_art_palette_path(PALETTE_PATH).size(), 0)
	for season: StringName in [&"spring", &"summer", &"autumn", &"winter"]:
		for role: StringName in [&"ground", &"foliage", &"water", &"roof"]:
			var color: Color = palette.get_color(role, season)
			assert_gt(color.a, 0.0, "Palette role exists: %s/%s" % [role, season])
	var invalid: Resource = PALETTE_SCRIPT.new() as Resource
	invalid.set("palette_id", &"Invalid Palette")
	assert_true((invalid.validate() as PackedStringArray).size() > 0)

func test_calibration_models_load_within_data_defined_budgets() -> void:
	var palette: Resource = load(PALETTE_PATH) as Resource
	for entry: Dictionary in MODEL_ENTRIES:
		var path: String = String(entry["path"])
		var kind: StringName = StringName(entry["kind"])
		assert_true(ResourceLoader.exists(path), "Generated scene exists: %s" % path)
		var scene: PackedScene = load(path) as PackedScene
		assert_not_null(scene)
		var model: Node3D = scene.instantiate() as Node3D
		add_child_autofree(model)
		var budget: int = palette.get_triangle_budget(kind)
		var audit_errors: PackedStringArray = MESH_AUDIT.validate_model(model, budget)
		assert_eq(audit_errors.size(), 0, "Model audit: %s" % kind)
		var triangles: int = MESH_AUDIT.triangle_count(model)
		assert_gt(triangles, 0)
		assert_true(triangles <= budget, "Triangle budget: %s" % kind)
		assert_true(MESH_AUDIT.collect_meshes(model).size() > 0)
		assert_true(_has_shader_material(model), "Calibration model uses a generated shader: %s" % kind)
	var calibration_character: Node3D = MESH_BUILDER.build_character(palette)
	add_child_autofree(calibration_character)
	assert_true(MESH_AUDIT.validate_model(calibration_character, palette.get_triangle_budget(&"character")).is_empty())

func test_character_head_ratio_and_mesh_geometry_follow_the_art_bible() -> void:
	var palette: Resource = load(PALETTE_PATH) as Resource
	var character: Node3D = MESH_BUILDER.build_character(palette)
	add_child_autofree(character)
	await get_tree().process_frame
	var total_bounds: AABB = MESH_AUDIT.combined_bounds(character)
	var head: MeshInstance3D = character.get_node("Head") as MeshInstance3D
	var hair: MeshInstance3D = character.get_node("Hair") as MeshInstance3D
	var head_bounds: AABB = _combined_mesh_bounds([head, hair])
	var head_ratio: float = head_bounds.size.y / total_bounds.size.y
	assert_true(head_ratio >= float(palette.get("head_height_ratio_min")))
	assert_true(head_ratio <= float(palette.get("head_height_ratio_max")))
	assert_false(MESH_AUDIT.has_degenerate_triangles(character))

func test_generated_shaders_and_materials_load_and_bind_to_a_viewport() -> void:
	var shader_expectations: Dictionary = _shader_expectations()
	for shader_id: StringName in shader_expectations:
		var shader_path: String = "res://assets/generated/shaders/chibi_%s.gdshader" % shader_id
		var material_path: String = "res://assets/generated/materials/mat_chibi_%s.tres" % shader_id
		assert_true(ResourceLoader.exists(shader_path), "Shader exists: %s" % shader_id)
		assert_true(ResourceLoader.exists(material_path), "Material exists: %s" % shader_id)
		var shader: Shader = load(shader_path) as Shader
		var material: ShaderMaterial = load(material_path) as ShaderMaterial
		assert_not_null(shader)
		assert_not_null(material)
		assert_eq(material.shader, shader)
		var uniform_names: PackedStringArray = _uniform_names(shader)
		for uniform_name: String in shader_expectations[shader_id]:
			assert_true(uniform_names.has(uniform_name), "Shader uniform: %s/%s" % [shader_id, uniform_name])
	var runtime_material: ShaderMaterial = MATERIAL_FACTORY.create_material(&"toon", &"wood", &"spring")
	assert_not_null(runtime_material.shader)
	assert_eq(runtime_material.get_shader_parameter(&"base_color"), (load(PALETTE_PATH) as Resource).get_color(&"wood"))
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(96, 96)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child_autofree(viewport)
	var root: Node3D = Node3D.new()
	viewport.add_child(root)
	var camera: Camera3D = Camera3D.new()
	camera.position = Vector3(0.0, 0.0, 3.0)
	camera.current = true
	root.add_child(camera)
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35.0, 25.0, 0.0)
	root.add_child(light)
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.material_override = runtime_material
	root.add_child(mesh_instance)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	assert_not_null(viewport.get_texture())

func test_lineup_and_contact_sheet_layout_are_stable() -> void:
	var lineup: Node3D = LINEUP_SCENE.instantiate() as Node3D
	add_child_autofree(lineup)
	await get_tree().process_frame
	assert_not_null(lineup.get_node_or_null("Character"))
	assert_not_null(lineup.get_node_or_null("Prop"))
	assert_not_null(lineup.get_node_or_null("Crop"))
	assert_not_null(lineup.get_node_or_null("Building"))
	assert_not_null(lineup.get_node_or_null("Tree"))
	assert_not_null(lineup.get_node_or_null("OneMeterGrid"))
	lineup.set_review_view(3, true)
	lineup.set_focus_model(&"Character")
	assert_true((lineup.get_node("Character") as Node3D).visible)
	assert_false((lineup.get_node("Tree") as Node3D).visible)
	lineup.set_focus_model(&"")
	assert_true((lineup.get_node("Tree") as Node3D).visible)
	var tile_size: int = 512
	assert_eq(REVIEW_LAYOUT.sheet_size(tile_size), Vector2i(2048, 1024))
	assert_eq(REVIEW_LAYOUT.tile_origin(0, false, tile_size), Vector2i.ZERO)
	assert_eq(REVIEW_LAYOUT.tile_origin(3, true, tile_size), Vector2i(1536, 512))

func _uniform_names(shader: Shader) -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for uniform_data: Dictionary in shader.get_shader_uniform_list():
		names.append(String(uniform_data.get("name", "")))
	return names

func _shader_expectations() -> Dictionary:
	return {
		&"toon": PackedStringArray(["base_color", "shadow_color", "rim_color", "rim_strength"]),
		&"outline": PackedStringArray(["outline_color", "outline_width"]),
		&"foliage": PackedStringArray(["base_color", "wind_color", "wind_strength"]),
		&"water": PackedStringArray(["water_color", "foam_color", "wave_height"]),
		&"dither_fade": PackedStringArray(["base_color", "fade_amount"])
	}

func _has_shader_material(root: Node) -> bool:
	for mesh_instance: MeshInstance3D in MESH_AUDIT.collect_meshes(root):
		if mesh_instance.material_override is ShaderMaterial:
			return true
	return false

func _combined_mesh_bounds(meshes: Array[MeshInstance3D]) -> AABB:
	var combined: AABB = AABB()
	var has_bounds: bool = false
	for mesh_instance: MeshInstance3D in meshes:
		var bounds: AABB = _transform_mesh_bounds(mesh_instance)
		if not has_bounds:
			combined = bounds
			has_bounds = true
			continue
		var first_end: Vector3 = combined.end
		var second_end: Vector3 = bounds.end
		var minimum: Vector3 = Vector3(
			minf(combined.position.x, bounds.position.x),
			minf(combined.position.y, bounds.position.y),
			minf(combined.position.z, bounds.position.z)
		)
		var maximum: Vector3 = Vector3(
			maxf(first_end.x, second_end.x),
			maxf(first_end.y, second_end.y),
			maxf(first_end.z, second_end.z)
		)
		combined = AABB(minimum, maximum - minimum)
	return combined

func _transform_mesh_bounds(mesh_instance: MeshInstance3D) -> AABB:
	var local_bounds: AABB = mesh_instance.mesh.get_aabb()
	var start: Vector3 = local_bounds.position
	var end: Vector3 = local_bounds.end
	var corners: Array[Vector3] = [
		Vector3(start.x, start.y, start.z),
		Vector3(end.x, start.y, start.z),
		Vector3(start.x, end.y, start.z),
		Vector3(end.x, end.y, start.z),
		Vector3(start.x, start.y, end.z),
		Vector3(end.x, start.y, end.z),
		Vector3(start.x, end.y, end.z),
		Vector3(end.x, end.y, end.z)
	]
	var minimum: Vector3 = mesh_instance.global_transform * corners[0]
	var maximum: Vector3 = minimum
	for corner: Vector3 in corners:
		var transformed: Vector3 = mesh_instance.global_transform * corner
		minimum = Vector3(minf(minimum.x, transformed.x), minf(minimum.y, transformed.y), minf(minimum.z, transformed.z))
		maximum = Vector3(maxf(maximum.x, transformed.x), maxf(maximum.y, transformed.y), maxf(maximum.z, transformed.z))
	return AABB(minimum, maximum - minimum)
