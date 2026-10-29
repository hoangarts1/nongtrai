## ChibiWorldLineup -- isolated C3 generated world-art review diorama.
## API:
##   func build_lineup() -> bool
##   func set_focus_group(group_id: StringName) -> void
##   func get_review_group_ids() -> PackedStringArray
##   func set_review_view(view_index: int, night: bool, season: StringName) -> void
class_name ChibiWorldLineup
extends Node3D

const CATALOG_PATH: String = "res://data/art/world/chibi_world_catalog.tres"
const PALETTE_PATH: String = "res://data/art/palette/chibi_valley.tres"

var _catalog: Resource
var _palette: Resource
var _camera: Camera3D
var _sun: DirectionalLight3D
var _fill: OmniLight3D
var _environment: Environment
var _ground: MeshInstance3D
var _models: Node3D
var _labels: Node3D
var _focus_group: StringName = &"buildings"
var _review_angle: float = deg_to_rad(45.0)
var _review_is_game_pitch: bool = true
var _review_season: StringName = &"spring"
var last_error: String = ""

func _ready() -> void:
	build_lineup()

func build_lineup() -> bool:
	if _camera != null:
		return last_error.is_empty()
	last_error = ""
	_catalog = load(CATALOG_PATH) as Resource
	_palette = load(PALETTE_PATH) as Resource
	if _catalog == null or not _catalog.has_method(&"get_model_path"):
		last_error = "cannot load C3 world art catalog"
		return false
	if _palette == null or not _palette.has_method(&"get_color"):
		last_error = "cannot load C3 chibi palette"
		return false
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.background_color = Color("f6ead4")
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color("ead8c4")
	_environment.ambient_light_energy = 0.72
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	world_environment.environment = _environment
	add_child(world_environment)
	_sun = DirectionalLight3D.new()
	_sun.name = "ReviewSun"
	_sun.rotation_degrees = Vector3(-52.0, -36.0, 0.0)
	_sun.shadow_enabled = true
	_sun.shadow_opacity = 0.48
	add_child(_sun)
	_fill = OmniLight3D.new()
	_fill.name = "ReviewFill"
	_fill.position = Vector3(0.0, 4.0, 4.0)
	_fill.omni_range = 26.0
	add_child(_fill)
	_camera = Camera3D.new()
	_camera.name = "ReviewCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.near = 0.05
	_camera.far = 52.0
	_camera.current = true
	add_child(_camera)
	_models = Node3D.new()
	_models.name = "GeneratedModels"
	add_child(_models)
	_labels = Node3D.new()
	_labels.name = "ModelLabels"
	add_child(_labels)
	_add_ground()
	set_focus_group(&"buildings")
	set_review_view(0, false, &"spring")
	return last_error.is_empty()

func get_review_group_ids() -> PackedStringArray:
	return PackedStringArray(["buildings", "trees_boundary", "terrain_water", "village_props", "critters"])

func set_focus_group(group_id: StringName) -> void:
	if _models == null:
		return
	_focus_group = group_id if get_review_group_ids().has(String(group_id)) else &"buildings"
	_clear_children(_models)
	_clear_children(_labels)
	last_error = ""
	var asset_ids: PackedStringArray = _asset_ids_for_group(_focus_group)
	for index: int in range(asset_ids.size()):
		_add_model(StringName(asset_ids[index]), index, asset_ids.size())
	_apply_camera(_review_angle, _review_is_game_pitch)

func set_review_view(view_index: int, night: bool, season: StringName) -> void:
	if _camera == null:
		return
	var angles: Array[float] = [45.0, 135.0, 225.0, 315.0]
	_review_angle = deg_to_rad(angles[clampi(view_index, 0, angles.size() - 1)])
	_review_is_game_pitch = view_index == 0
	_review_season = season if season in [&"spring", &"summer", &"autumn", &"winter"] else &"spring"
	if night:
		_environment.background_color = Color("33405d")
		_environment.ambient_light_color = Color("7787aa")
		_environment.ambient_light_energy = 0.56
		_sun.light_color = Color("9db2e6")
		_sun.light_energy = 0.86
		_fill.light_color = Color("f2bd8a")
		_fill.light_energy = 0.78
	else:
		_environment.background_color = Color("f6ead4")
		_environment.ambient_light_color = Color("ead8c4")
		_environment.ambient_light_energy = 0.72
		_sun.light_color = _palette_color(&"sunlight", _review_season)
		_sun.light_energy = 1.18
		_fill.light_color = Color.WHITE
		_fill.light_energy = 0.38
	WorldArtFactory.apply_season(_models, _review_season)
	if _ground != null:
		var material: StandardMaterial3D = _ground.material_override as StandardMaterial3D
		if material != null:
			material.albedo_color = _palette_color(&"ground", _review_season)
	_apply_camera(_review_angle, _review_is_game_pitch)

func _asset_ids_for_group(group_id: StringName) -> PackedStringArray:
	match group_id:
		&"buildings":
			return PackedStringArray(["bld_player_cottage", "bld_seed_market", "bld_shipping_bin", "bld_npc_cottage", "bld_observatory"])
		&"trees_boundary":
			return PackedStringArray(["env_round_tree", "env_cliff_border"])
		&"terrain_water":
			return PackedStringArray(["env_pond_bridge", "prop_path_stone", "prop_rock_cluster"])
		&"village_props":
			return PackedStringArray(["prop_fence_wood", "prop_well", "prop_lamp", "prop_mailbox", "prop_signpost", "prop_bench", "prop_woodpile", "prop_flower_patch"])
		&"critters":
			return PackedStringArray(["env_bird", "env_butterfly", "env_firefly"])
	return PackedStringArray()

func _add_model(asset_id: StringName, index: int, count: int) -> void:
	var path: String = String(_catalog.call(&"get_model_path", asset_id))
	if path.is_empty() or not ResourceLoader.exists(path):
		last_error = "missing generated C3 world model: %s" % path
		return
	var model: Node3D = WorldArtFactory.create_asset(asset_id, _review_season)
	model.name = String(asset_id).to_pascal_case()
	var columns: int = 4
	var row: int = index / columns
	var column: int = index % columns
	var rows: int = ceili(float(count) / float(columns))
	model.position = Vector3((float(column) - 1.5) * 3.00, 0.0, (float(row) - float(rows - 1) * 0.5) * 3.00)
	model.scale = Vector3.ONE * _model_scale(asset_id)
	_models.add_child(model)
	var label: Label3D = Label3D.new()
	label.name = "%sLabel" % model.name
	label.text = String(asset_id).trim_prefix("bld_").trim_prefix("env_").trim_prefix("prop_").to_upper()
	label.position = model.position + Vector3(0.0, 0.04, 1.25)
	label.pixel_size = 0.0042
	label.font_size = 22
	label.outline_size = 5
	label.modulate = Color("4b3c47")
	label.outline_modulate = Color("fff4dd")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_labels.add_child(label)

func _model_scale(asset_id: StringName) -> float:
	if String(asset_id).begins_with("bld_"):
		return 0.78
	if asset_id == &"env_round_tree":
		return 0.88
	if String(asset_id).begins_with("env_"):
		return 1.05
	return 1.0

func _add_ground() -> void:
	_ground = MeshInstance3D.new()
	_ground.name = "ReviewGround"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(14.0, 11.0)
	_ground.mesh = plane
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = _palette_color(&"ground", &"spring")
	material.roughness = 1.0
	_ground.material_override = material
	add_child(_ground)

func _apply_camera(angle: float, use_game_pitch: bool) -> void:
	if _camera == null:
		return
	var target: Vector3 = Vector3(0.0, 0.9, 0.0)
	var size: float = 10.0
	if _focus_group == &"buildings":
		size = 12.5
	elif _focus_group == &"village_props":
		size = 10.5
	elif _focus_group == &"critters":
		size = 7.0
	var height: float = 7.5 if use_game_pitch else 4.4
	_camera.size = size
	_camera.position = target + Vector3(cos(angle) * 10.5, height, sin(angle) * 10.5)
	_camera.look_at(target, Vector3.UP)

func _palette_color(role: StringName, season: StringName) -> Color:
	var color: Variant = _palette.call(&"get_color", role, season)
	return color as Color if color is Color else Color.WHITE

func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		child.free()
