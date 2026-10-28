## ChibiCharacterLineup — isolated C1 day/night model-review scene.
## API:
##   func build_lineup() -> bool
##   func set_review_view(view_index: int, night: bool) -> void
##   func set_focus_model(model_id: StringName) -> void
##   func get_review_model_names() -> PackedStringArray
class_name ChibiCharacterLineup
extends Node3D

const PALETTE: Resource = preload("res://data/art/palette/chibi_valley.tres")
const MODEL_ENTRIES: Array[Dictionary] = [
	{"id": &"player", "label": "PLAYER", "path": "res://assets/generated/models/characters/chr_player_base.tscn", "origin": Vector3(-2.0, 0.0, 1.15), "height": 0.72, "size": 2.35},
	{"id": &"an", "label": "AN", "path": "res://assets/generated/models/characters/chr_an.tscn", "origin": Vector3(0.0, 0.0, 1.15), "height": 0.72, "size": 2.35},
	{"id": &"lam", "label": "LAM", "path": "res://assets/generated/models/characters/chr_lam.tscn", "origin": Vector3(2.0, 0.0, 1.15), "height": 0.72, "size": 2.35},
	{"id": &"linh", "label": "LINH", "path": "res://assets/generated/models/characters/chr_linh.tscn", "origin": Vector3(-2.0, 0.0, -1.15), "height": 0.72, "size": 2.35},
	{"id": &"minh", "label": "MINH", "path": "res://assets/generated/models/characters/chr_minh.tscn", "origin": Vector3(0.0, 0.0, -1.15), "height": 0.72, "size": 2.35},
	{"id": &"dog", "label": "DOG", "path": "res://assets/generated/models/characters/pet_dog.tscn", "origin": Vector3(2.0, 0.0, -1.15), "height": 0.36, "size": 1.75}
]

var _camera: Camera3D
var _sun: DirectionalLight3D
var _fill: OmniLight3D
var _environment: Environment
var _focus_model: StringName = &""
var _review_angle: float = deg_to_rad(45.0)
var _review_is_game_pitch: bool = true
var _models: Dictionary = {}
var _labels: Dictionary = {}
var last_error: String = ""

func _ready() -> void:
	build_lineup()

func build_lineup() -> bool:
	if _camera != null:
		return last_error.is_empty()
	last_error = ""
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_COLOR
	_environment.background_color = Color("f4e9d5")
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color("e8d5c9")
	_environment.ambient_light_energy = 0.72
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	world_environment.environment = _environment
	add_child(world_environment)
	_sun = DirectionalLight3D.new()
	_sun.name = "ReviewSun"
	_sun.rotation_degrees = Vector3(-52.0, -36.0, 0.0)
	_sun.shadow_enabled = true
	_sun.shadow_opacity = 0.52
	add_child(_sun)
	_fill = OmniLight3D.new()
	_fill.name = "ReviewFill"
	_fill.position = Vector3(0.0, 4.0, 4.0)
	_fill.omni_range = 18.0
	add_child(_fill)
	_camera = Camera3D.new()
	_camera.name = "ReviewCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 7.2
	_camera.near = 0.05
	_camera.far = 48.0
	_camera.current = true
	add_child(_camera)
	_add_ground()
	for entry: Dictionary in MODEL_ENTRIES:
		if not _add_model(entry):
			return false
	set_review_view(0, false)
	return true

func get_review_model_names() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for entry: Dictionary in MODEL_ENTRIES:
		names.append(String(entry["id"]))
	return names

func get_model_path(model_id: StringName) -> String:
	for entry: Dictionary in MODEL_ENTRIES:
		if StringName(entry["id"]) == model_id:
			return String(entry["path"])
	return ""

func set_review_view(view_index: int, night: bool) -> void:
	if _camera == null:
		return
	var angles: Array[float] = [45.0, 135.0, 225.0, 315.0]
	var angle: float = deg_to_rad(angles[clampi(view_index, 0, angles.size() - 1)])
	_review_angle = angle
	_review_is_game_pitch = view_index == 0
	_apply_camera(angle, _review_is_game_pitch)
	if night:
		_environment.background_color = Color("34415d")
		_environment.ambient_light_color = Color("7685aa")
		_environment.ambient_light_energy = 0.56
		_sun.light_color = Color("9fb3e5")
		_sun.light_energy = 0.86
		_fill.light_color = Color("f2bd8a")
		_fill.light_energy = 0.78
	else:
		_environment.background_color = Color("f4e9d5")
		_environment.ambient_light_color = Color("e8d5c9")
		_environment.ambient_light_energy = 0.72
		_sun.light_color = PALETTE.get_color(&"sunlight")
		_sun.light_energy = 1.18
		_fill.light_color = Color.WHITE
		_fill.light_energy = 0.38

func set_focus_model(model_id: StringName) -> void:
	_focus_model = model_id if _models.has(model_id) else &""
	for entry: Dictionary in MODEL_ENTRIES:
		var entry_id: StringName = StringName(entry["id"])
		var model: Node3D = _models.get(entry_id) as Node3D
		var label: Label3D = _labels.get(entry_id) as Label3D
		var should_show: bool = _focus_model.is_empty() or entry_id == _focus_model
		if model != null:
			model.visible = should_show
		if label != null:
			# A focused sheet already has a 2D caption. Hide the floating model
			# name there so it cannot cover the character's silhouette.
			label.visible = should_show and _focus_model.is_empty()
	if _camera != null:
		_apply_camera(_review_angle, _review_is_game_pitch)

func _add_ground() -> void:
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "ReviewGround"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(7.6, 5.6)
	ground.mesh = plane
	var ground_material: StandardMaterial3D = StandardMaterial3D.new()
	ground_material.albedo_color = PALETTE.get_color(&"ground")
	ground_material.roughness = 1.0
	ground.material_override = ground_material
	add_child(ground)
	var grid_mesh: ImmediateMesh = ImmediateMesh.new()
	grid_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for coordinate: int in range(-3, 4):
		var value: float = float(coordinate)
		grid_mesh.surface_add_vertex(Vector3(value, 0.012, -2.4))
		grid_mesh.surface_add_vertex(Vector3(value, 0.012, 2.4))
		grid_mesh.surface_add_vertex(Vector3(-3.4, 0.012, value))
		grid_mesh.surface_add_vertex(Vector3(3.4, 0.012, value))
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

func _add_model(entry: Dictionary) -> bool:
	var model_id: StringName = StringName(entry["id"])
	var path: String = String(entry["path"])
	if not ResourceLoader.exists(path):
		last_error = "missing generated C1 character model: %s" % path
		return false
	var scene: PackedScene = load(path) as PackedScene
	if scene == null:
		last_error = "cannot load generated C1 character model: %s" % path
		return false
	var instance: Node = scene.instantiate()
	var model: Node3D = instance as Node3D
	if model == null:
		last_error = "generated C1 character model root is not Node3D: %s" % path
		instance.queue_free()
		return false
	model.name = String(model_id).capitalize()
	model.position = entry["origin"] as Vector3
	model.set_meta("character_model_id", model_id)
	add_child(model)
	_models[model_id] = model
	var label: Label3D = Label3D.new()
	label.name = "%sLabel" % model.name
	label.text = String(entry["label"])
	label.position = model.position + Vector3(0.0, 0.04, 0.82)
	label.pixel_size = 0.0045
	label.font_size = 32
	label.outline_size = 7
	label.modulate = Color("4b3c47")
	label.outline_modulate = Color("fff4dd")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	_labels[model_id] = label
	return true

func _apply_camera(angle: float, use_game_pitch: bool) -> void:
	var target: Vector3 = Vector3(0.0, 0.72, 0.0)
	var camera_size: float = 7.2
	if not _focus_model.is_empty():
		var model: Node3D = _models.get(_focus_model) as Node3D
		if model != null:
			target = model.position + Vector3(0.0, _focus_height(_focus_model), 0.0)
			camera_size = _focus_size(_focus_model)
	_camera.size = camera_size
	# The first tile is exactly the game's 45-degree/35-degree view. The three
	# supporting angles sit lower so the visual review can inspect expressions.
	var camera_height: float = 5.3 if use_game_pitch else 3.4
	_camera.position = target + Vector3(cos(angle) * 7.4, camera_height, sin(angle) * 7.4)
	_camera.look_at(target, Vector3.UP)

func _focus_height(model_id: StringName) -> float:
	for entry: Dictionary in MODEL_ENTRIES:
		if StringName(entry["id"]) == model_id:
			return float(entry["height"])
	return 0.72

func _focus_size(model_id: StringName) -> float:
	for entry: Dictionary in MODEL_ENTRIES:
		if StringName(entry["id"]) == model_id:
			return float(entry["size"])
	return 2.35
