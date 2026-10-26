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
var _crop_labels: Dictionary = {}
var _highlight: MeshInstance3D

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

func get_crop_label(cell: Vector2i) -> Label3D:
	return _crop_labels.get(cell) as Label3D

func pick_crop(screen_position: Vector2, camera: Camera3D) -> Variant:
	var selected: Variant = null
	var nearest: float = INF
	for cell: Vector2i in _crops:
		var crop: MeshInstance3D = _crops[cell]
		if not crop.visible:
			continue
		var bounds: AABB = crop.get_aabb()
		var rectangle: Rect2 = Rect2(camera.unproject_position(crop.to_global(bounds.position)), Vector2.ONE)
		for endpoint: int in range(8):
			rectangle = rectangle.expand(camera.unproject_position(crop.to_global(bounds.get_endpoint(endpoint))))
		# The small sprout remains a reasonable click target without tiny world text.
		var distance: float = screen_position.distance_squared_to(rectangle.get_center())
		if rectangle.grow(8.0).has_point(screen_position) and distance < nearest:
			selected = cell
			nearest = distance
	return selected

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
			var label: Label3D = Label3D.new()
			label.name = "CropLabel_%d_%d" % [x, z]
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.no_depth_test = true
			label.font_size = 24
			label.outline_size = 8
			label.modulate = Color(1.0, 1.0, 1.0, 1.0)
			label.position = GridMath.cell_to_world(cell) + Vector3(0.0, 1.05, 0.0)
			label.visible = false
			add_child(label)
			_crop_labels[cell] = label
	_highlight = MeshInstance3D.new()
	_highlight.name = "TargetHighlight"
	var highlight_mesh: BoxMesh = BoxMesh.new()
	highlight_mesh.size = Vector3(cell_size * 0.96, 0.02, cell_size * 0.96)
	_highlight.mesh = highlight_mesh
	_highlight.visible = false
	add_child(_highlight)
	_render_all()

func set_hovered_cell(cell: Vector2i, visible: bool, in_reach: bool) -> void:
	if _highlight == null:
		return
	_highlight.visible = visible
	if not visible:
		return
	_highlight.position = GridMath.cell_to_world(cell) + Vector3(0.0, 0.10, 0.0)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.35, 0.90, 0.30, 0.65) if in_reach else Color(0.90, 0.25, 0.20, 0.65)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_highlight.material_override = material

func is_target_highlight_visible() -> bool:
	return _highlight != null and _highlight.visible

func is_target_in_reach() -> bool:
	if _highlight == null or not _highlight.visible:
		return false
	var material: Material = _highlight.material_override
	return material != null and (material as StandardMaterial3D).albedo_color.g > 0.5

func _render_all() -> void:
	for cell: Vector2i in _cells.keys():
		_render_cell(cell)

func _on_plot_changed(cell: Vector2i) -> void:
	_render_cell(cell)
	var soil: MeshInstance3D = get_cell_view(cell)
	if soil == null:
		return
	soil.scale = Vector3.ONE
	var tween: Tween = create_tween()
	tween.tween_property(soil, "scale", Vector3(1.06, 0.82, 1.06), 0.08)
	tween.tween_property(soil, "scale", Vector3.ONE, 0.12)

func _render_cell(cell: Vector2i) -> void:
	var soil: MeshInstance3D = get_cell_view(cell)
	var crop: MeshInstance3D = get_crop_view(cell)
	var label: Label3D = get_crop_label(cell)
	if soil == null or crop == null or label == null:
		return
	var plot: Dictionary = {} if _farm_state == null else _farm_state.get_plot(cell)
	var tilled: bool = bool(plot.get("tilled", false))
	var watered: bool = bool(plot.get("watered", false))
	var withered: bool = bool(plot.get("withered", false))
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
	# Detailed status is shown in the readable click inspector, not over every crop.
	label.visible = false
	if crop.visible:
		var crop_data: Resource = DataRegistry.get_crop(crop_id)
		var growth_days: int = int(plot.get("growth_days", 0))
		var required_days: int = maxi(1, int(crop_data.get("growth_days"))) if crop_data != null else 1
		var growth_ratio: float = clampf(float(growth_days) / float(required_days), 0.0, 1.0)
		if withered:
			label.text = tr("CROP_STATUS_WITHERED")
		elif growth_days >= required_days:
			label.text = tr("CROP_STATUS_READY")
		else:
			var remaining_days: int = maxi(1, required_days - growth_days)
			label.text = tr("CROP_STATUS_REMAINING") % remaining_days
			if not watered:
				label.text += "\n" + tr("CROP_STATUS_NEEDS_WATER")
		var crop_size: float = lerpf(0.18, 0.52, growth_ratio)
		crop.mesh = BoxMesh.new()
		(crop.mesh as BoxMesh).size = Vector3(crop_size, 0.22 + crop_size, crop_size)
		crop.position.y = 0.18 + crop_size * 0.5
		var target_color: Color = crop_data.get("color") if crop_data != null and crop_data.get("color") != null else Color(0.95, 0.78, 0.18, 1.0)
		var crop_material: StandardMaterial3D = StandardMaterial3D.new()
		if withered:
			crop_material.albedo_color = Color(0.35, 0.30, 0.25, 1.0)
		elif growth_ratio < 1.0:
			crop_material.albedo_color = Color(0.40, 0.82, 0.18, 1.0).lerp(target_color, growth_ratio * 0.75)
		else:
			crop_material.albedo_color = target_color
		crop.material_override = crop_material
