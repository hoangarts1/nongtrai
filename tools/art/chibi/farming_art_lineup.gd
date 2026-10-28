## ChibiFarmingLineup -- isolated C2 generated-farming asset review scene.
## API:
##   func build_lineup() -> bool
##   func set_review_view(view_index: int, night: bool) -> void
##   func set_focus_group(group_id: StringName) -> void
##   func get_review_group_ids() -> PackedStringArray
class_name ChibiFarmingLineup
extends Node3D

const PALETTE: Resource = preload("res://data/art/palette/chibi_valley.tres")
const MODEL_DIRECTORY: String = "res://assets/generated/models/farming"
const CROP_IDS: Array[String] = ["turnip", "spring_carrot", "spring_pea", "summer_tomato", "summer_corn", "autumn_wheat", "autumn_pumpkin", "winter_radish", "winter_cabbage"]
const ITEM_IDS: Array[String] = ["turnip_seed", "turnip", "spring_carrot_seed", "spring_carrot", "spring_pea_seed", "spring_pea", "summer_tomato_seed", "summer_tomato", "summer_corn_seed", "summer_corn", "autumn_wheat_seed", "autumn_wheat", "autumn_pumpkin_seed", "autumn_pumpkin", "winter_radish_seed", "winter_radish", "winter_cabbage_seed", "winter_cabbage"]
const TOOL_IDS: Array[String] = ["hoe", "watering_can", "seed", "harvest"]

var _camera: Camera3D
var _sun: DirectionalLight3D
var _fill: OmniLight3D
var _environment: Environment
var _models: Node3D
var _labels: Node3D
var _focus_group: StringName = &"lineup"
var _review_angle: float = deg_to_rad(45.0)
var _review_is_game_pitch: bool = true
var last_error: String = ""

func _ready() -> void:
	build_lineup()

func build_lineup() -> bool:
	if _camera != null:
		return last_error.is_empty()
	last_error = ""
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
	_fill.omni_range = 20.0
	add_child(_fill)
	_camera = Camera3D.new()
	_camera.name = "ReviewCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.near = 0.05
	_camera.far = 48.0
	_camera.current = true
	add_child(_camera)
	_models = Node3D.new()
	_models.name = "GeneratedModels"
	add_child(_models)
	_labels = Node3D.new()
	_labels.name = "ModelLabels"
	add_child(_labels)
	_add_ground()
	set_focus_group(&"lineup")
	set_review_view(0, false)
	return last_error.is_empty()

func get_review_group_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray(["lineup"])
	for crop_id: String in CROP_IDS:
		ids.append("crop_%s" % crop_id)
	for group_index: int in range(3):
		ids.append("items_%d" % group_index)
	ids.append("tools")
	return ids

func set_focus_group(group_id: StringName) -> void:
	if _models == null:
		return
	_focus_group = group_id if get_review_group_ids().has(String(group_id)) else &"lineup"
	_clear_children(_models)
	_clear_children(_labels)
	last_error = ""
	if _focus_group == &"lineup":
		_populate_lineup()
	elif String(_focus_group).begins_with("crop_"):
		_populate_crop_stages(StringName(String(_focus_group).trim_prefix("crop_")))
	elif String(_focus_group).begins_with("items_"):
		_populate_items(int(String(_focus_group).trim_prefix("items_")))
	else:
		_populate_tools()
	_apply_camera(_review_angle, _review_is_game_pitch)

func set_review_view(view_index: int, night: bool) -> void:
	if _camera == null:
		return
	var angles: Array[float] = [45.0, 135.0, 225.0, 315.0]
	_review_angle = deg_to_rad(angles[clampi(view_index, 0, angles.size() - 1)])
	_review_is_game_pitch = view_index == 0
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
		_sun.light_color = PALETTE.get_color(&"sunlight")
		_sun.light_energy = 1.18
		_fill.light_color = Color.WHITE
		_fill.light_energy = 0.38
	_apply_camera(_review_angle, _review_is_game_pitch)

func _populate_lineup() -> void:
	for index: int in range(CROP_IDS.size()):
		var crop_id: String = CROP_IDS[index]
		var origin: Vector3 = Vector3((float(index % 3) - 1.0) * 1.85, 0.0, (float(index / 3) - 1.0) * 1.55)
		_add_model("crop_%s_stage_3.tscn" % crop_id, origin, 0.88, crop_id.to_upper())
	for index: int in range(TOOL_IDS.size()):
		var origin: Vector3 = Vector3(-2.8 + float(index) * 1.85, 0.0, 2.50)
		_add_model("tool_%s.tscn" % TOOL_IDS[index], origin, 0.88, String(TOOL_IDS[index]).to_upper())

func _populate_crop_stages(crop_id: StringName) -> void:
	for stage: int in range(4):
		_add_model("crop_%s_stage_%d.tscn" % [crop_id, stage], Vector3((float(stage) - 2.0) * 1.10, 0.0, 0.0), 1.0, "S%d" % stage)
	_add_model("crop_%s_withered.tscn" % crop_id, Vector3(2.20, 0.0, 0.0), 1.0, "WILT")

func _populate_items(group_index: int) -> void:
	var start: int = group_index * 6
	for offset: int in range(6):
		var index: int = start + offset
		if index >= ITEM_IDS.size():
			break
		var origin: Vector3 = Vector3((float(index % 3) - 1.0) * 1.35, 0.0, (float(offset / 3) - 0.5) * 1.35)
		_add_model("item_%s.tscn" % ITEM_IDS[index], origin, 0.96, String(ITEM_IDS[index]).to_upper())

func _populate_tools() -> void:
	for index: int in range(TOOL_IDS.size()):
		_add_model("tool_%s.tscn" % TOOL_IDS[index], Vector3((float(index) - 1.5) * 1.35, 0.0, 0.0), 1.0, String(TOOL_IDS[index]).to_upper())

func _add_model(filename: String, origin: Vector3, scale_value: float, label_text: String) -> void:
	var path: String = "%s/%s" % [MODEL_DIRECTORY, filename]
	if not ResourceLoader.exists(path):
		last_error = "missing generated C2 farming model: %s" % path
		return
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		last_error = "cannot load generated C2 farming model: %s" % path
		return
	var model: Node3D = scene.instantiate() as Node3D
	if model == null:
		last_error = "generated C2 farming root is not Node3D: %s" % path
		return
	model.name = filename.trim_suffix(".tscn")
	model.position = origin
	model.scale = Vector3.ONE * scale_value
	_models.add_child(model)
	if _focus_group != &"lineup":
		return
	var label: Label3D = Label3D.new()
	label.name = "%sLabel" % model.name
	label.text = label_text
	label.position = origin + Vector3(0.0, 0.04, 0.65)
	label.pixel_size = 0.0038
	label.font_size = 24
	label.outline_size = 6
	label.modulate = Color("4b3c47")
	label.outline_modulate = Color("fff4dd")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_labels.add_child(label)

func _add_ground() -> void:
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "ReviewGround"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(10.5, 8.5)
	ground.mesh = plane
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = PALETTE.get_color(&"ground")
	material.roughness = 1.0
	ground.material_override = material
	add_child(ground)
	var grid_mesh: ImmediateMesh = ImmediateMesh.new()
	grid_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for coordinate: int in range(-5, 6):
		var value: float = float(coordinate)
		grid_mesh.surface_add_vertex(Vector3(value, 0.012, -4.0))
		grid_mesh.surface_add_vertex(Vector3(value, 0.012, 4.0))
		grid_mesh.surface_add_vertex(Vector3(-5.0, 0.012, value * 0.75))
		grid_mesh.surface_add_vertex(Vector3(5.0, 0.012, value * 0.75))
	grid_mesh.surface_end()
	var grid: MeshInstance3D = MeshInstance3D.new()
	grid.name = "OneMeterGrid"
	grid.mesh = grid_mesh
	var grid_material: StandardMaterial3D = StandardMaterial3D.new()
	grid_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grid_material.albedo_color = Color("79955c", 0.42)
	grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid.material_override = grid_material
	add_child(grid)

func _apply_camera(angle: float, use_game_pitch: bool) -> void:
	if _camera == null:
		return
	var target: Vector3 = Vector3(0.0, 0.55, 0.0)
	var size: float = 9.0
	if String(_focus_group).begins_with("crop_"):
		size = 4.6
	elif String(_focus_group).begins_with("items_"):
		size = 4.4
	elif _focus_group == &"tools":
		size = 4.0
	var height: float = 6.5 if use_game_pitch else 3.8
	_camera.size = size
	_camera.position = target + Vector3(cos(angle) * 8.5, height, sin(angle) * 8.5)
	_camera.look_at(target, Vector3.UP)

func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		child.free()
