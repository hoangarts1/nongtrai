## FarmView — placeholder grid renderer driven by FarmGridState.
## API:
##   func configure(farm_state: FarmGridState) -> void
##   func get_cell_view(cell: Vector2i) -> MeshInstance3D
##   func get_crop_view(cell: Vector2i) -> MeshInstance3D
class_name FarmView
extends Node3D

@export var grid_size: Vector2i = Vector2i(6, 6)
@export var cell_size: float = 1.0

var _farm_state: FarmGridState
var _cells: Dictionary = {}
var _crops: Dictionary = {}

func _ready() -> void:
	_build_grid()

func configure(farm_state: FarmGridState) -> void:
	_farm_state = farm_state
	_farm_state.plot_changed.connect(_on_plot_changed)
	_render_all()

func get_cell_view(cell: Vector2i) -> MeshInstance3D:
	return _cells.get(cell) as MeshInstance3D

func get_crop_view(cell: Vector2i) -> MeshInstance3D:
	return _crops.get(cell) as MeshInstance3D

func _build_grid() -> void:
	for child: Node in get_children():
		child.free()
	_cells.clear()
	_crops.clear()
	for z: int in range(grid_size.y):
		for x: int in range(grid_size.x):
			var cell: Vector2i = Vector2i(x, z)
			var soil: MeshInstance3D = MeshInstance3D.new()
			soil.name = "Cell_%d_%d" % [x, z]
			var mesh: BoxMesh = BoxMesh.new()
			mesh.size = Vector3(cell_size * 0.92, 0.08, cell_size * 0.92)
			soil.mesh = mesh
			soil.position = GridMath.cell_to_world(cell) + Vector3(0.0, 0.04, 0.0)
			add_child(soil)
			_cells[cell] = soil
			var crop: MeshInstance3D = MeshInstance3D.new()
			crop.name = "Crop_%d_%d" % [x, z]
			var crop_mesh: BoxMesh = BoxMesh.new()
			crop_mesh.size = Vector3(0.28, 0.35, 0.28)
			crop.mesh = crop_mesh
			crop.position = GridMath.cell_to_world(cell) + Vector3(0.0, 0.25, 0.0)
			crop.visible = false
			add_child(crop)
			_crops[cell] = crop
	_render_all()

func _render_all() -> void:
	for cell: Vector2i in _cells.keys():
		_render_cell(cell)

func _on_plot_changed(cell: Vector2i) -> void:
	_render_cell(cell)

func _render_cell(cell: Vector2i) -> void:
	var soil: MeshInstance3D = get_cell_view(cell)
	var crop: MeshInstance3D = get_crop_view(cell)
	if soil == null or crop == null:
		return
	var plot: Dictionary = {} if _farm_state == null else _farm_state.get_plot(cell)
	var tilled: bool = bool(plot.get("tilled", false))
	var watered: bool = bool(plot.get("watered", false))
	var crop_id: StringName = plot.get("crop_id", &"")
	var color: Color = Color(0.30, 0.52, 0.24, 1.0)
	if tilled:
		color = Color(0.38, 0.22, 0.11, 1.0)
	if watered:
		color = Color(0.20, 0.32, 0.55, 1.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	soil.material_override = material
	crop.visible = not crop_id.is_empty()
	if crop.visible:
		var crop_material: StandardMaterial3D = StandardMaterial3D.new()
		crop_material.albedo_color = Color(0.32, 0.75, 0.20, 1.0)
		crop.material_override = crop_material
