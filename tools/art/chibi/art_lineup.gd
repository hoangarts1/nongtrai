## ChibiArtLineup — standalone proportion/review scene for C0 calibration models.
## API:
##   func build_lineup() -> void
##   func set_review_view(view_index: int, night: bool) -> void
##   func set_focus_model(model_name: StringName) -> void
extends Node3D

const PALETTE: Resource = preload("res://data/art/palette/chibi_valley.tres")
const MESH_BUILDER: Script = preload("res://tools/art/chibi/chibi_mesh_builder.gd")

var _camera: Camera3D
var _sun: DirectionalLight3D
var _fill: OmniLight3D
var _environment: Environment
var _focus_model: StringName = &""

func _ready() -> void:
	build_lineup()

func build_lineup() -> void:
	if _camera != null:
		return
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
	_sun.shadow_opacity = 0.56
	add_child(_sun)
	_fill = OmniLight3D.new()
	_fill.name = "ReviewFill"
	_fill.position = Vector3(0.0, 4.0, 4.0)
	_fill.omni_range = 18.0
	add_child(_fill)
	_camera = Camera3D.new()
	_camera.name = "ReviewCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 9.0
	_camera.near = 0.05
	_camera.far = 48.0
	_camera.current = true
	add_child(_camera)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "ReviewGround"
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(8.8, 7.6)
	ground.mesh = plane
	var ground_material: StandardMaterial3D = StandardMaterial3D.new()
	ground_material.albedo_color = PALETTE.get_color(&"ground")
	ground_material.roughness = 1.0
	ground.material_override = ground_material
	add_child(ground)
	_add_ground_grid()
	_add_model("Character", MESH_BUILDER.build_character(PALETTE), _model_origin(&"Character"))
	_add_model("Prop", MESH_BUILDER.build_prop(PALETTE), _model_origin(&"Prop"))
	_add_model("Crop", MESH_BUILDER.build_crop(PALETTE), _model_origin(&"Crop"))
	_add_model("Building", MESH_BUILDER.build_building(PALETTE), _model_origin(&"Building"))
	_add_model("Tree", MESH_BUILDER.build_tree(PALETTE), _model_origin(&"Tree"))
	set_review_view(0, false)

func set_review_view(view_index: int, night: bool) -> void:
	if _camera == null:
		return
	var angles: Array[float] = [45.0, 135.0, 225.0, 315.0]
	var angle: float = deg_to_rad(angles[clampi(view_index, 0, angles.size() - 1)])
	_apply_camera(angle)
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

func _add_model(model_name: String, model: Node3D, origin: Vector3) -> void:
	model.name = model_name
	model.position = origin
	add_child(model)
	var label: Label3D = Label3D.new()
	label.name = "%sLabel" % model_name
	label.text = model_name.to_upper()
	label.position = origin + Vector3(0.0, 0.04, 0.88)
	label.pixel_size = 0.0045
	label.font_size = 34
	label.outline_size = 7
	label.modulate = Color("4b3c47")
	label.outline_modulate = Color("fff4dd")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func set_focus_model(model_name: StringName) -> void:
	_focus_model = model_name
	for candidate: StringName in _model_names():
		var model: Node3D = get_node_or_null(NodePath(String(candidate))) as Node3D
		var label: Label3D = get_node_or_null(NodePath("%sLabel" % candidate)) as Label3D
		var visible: bool = model_name.is_empty() or candidate == model_name
		if model != null:
			model.visible = visible
		if label != null:
			label.visible = visible

func _apply_camera(angle: float) -> void:
	var target: Vector3 = Vector3(0.0, 0.92, 0.0)
	var camera_size: float = 9.0
	if not _focus_model.is_empty():
		target = _model_origin(_focus_model) + Vector3(0.0, _model_focus_height(_focus_model), 0.0)
		camera_size = _model_focus_size(_focus_model)
	_camera.size = camera_size
	_camera.position = target + Vector3(cos(angle) * 8.4, 5.9, sin(angle) * 8.4)
	_camera.look_at(target, Vector3.UP)

func _add_ground_grid() -> void:
	var grid_mesh: ImmediateMesh = ImmediateMesh.new()
	grid_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for coordinate: int in range(-4, 5):
		var value: float = float(coordinate)
		grid_mesh.surface_add_vertex(Vector3(value, 0.012, -3.45))
		grid_mesh.surface_add_vertex(Vector3(value, 0.012, 3.45))
		grid_mesh.surface_add_vertex(Vector3(-4.05, 0.012, value))
		grid_mesh.surface_add_vertex(Vector3(4.05, 0.012, value))
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

func _model_names() -> PackedStringArray:
	return PackedStringArray(["Character", "Prop", "Crop", "Building", "Tree"])

func _model_origin(model_name: StringName) -> Vector3:
	match model_name:
		&"Character":
			return Vector3(-2.65, 0.0, 1.45)
		&"Prop":
			return Vector3(0.0, 0.0, 1.45)
		&"Crop":
			return Vector3(2.55, 0.0, 1.45)
		&"Building":
			return Vector3(-1.65, 0.0, -1.70)
		&"Tree":
			return Vector3(1.70, 0.0, -1.70)
	return Vector3.ZERO

func _model_focus_height(model_name: StringName) -> float:
	match model_name:
		&"Character":
			return 0.62
		&"Prop":
			return 0.32
		&"Crop":
			return 0.42
		&"Building":
			return 0.86
		&"Tree":
			return 1.02
	return 0.8

func _model_focus_size(model_name: StringName) -> float:
	match model_name:
		&"Character", &"Prop", &"Crop":
			return 2.8
		&"Building", &"Tree":
			return 4.1
	return 4.0
