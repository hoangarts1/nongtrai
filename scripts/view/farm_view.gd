## FarmView — renders existing farm state with TileMapLayer terrain and y-sorted crop sprites.
## API:
##   func configure(farm_state: FarmGridState) -> void
##   func get_cell_view(cell: Vector2i) -> Polygon2D
##   func get_crop_view(cell: Vector2i) -> Sprite2D
##   func get_crop_label(cell: Vector2i) -> Label
##   func pick_crop(screen_position: Vector2, camera: Camera2D) -> Variant
class_name FarmView
extends Node2D

@export var grid_size: Vector2i = Vector2i(6, 6)
var _farm_state: FarmGridState
var _cells: Dictionary = {}
var _crops: Dictionary = {}
var _crop_labels: Dictionary = {}
var _highlight: Polygon2D
var _effects: FarmEffects
var _world: GrayBoxWorld
var _in_reach: bool = false

func setup(world: GrayBoxWorld) -> void:
	_world = world
	_build_grid()

func configure(farm_state: FarmGridState) -> void:
	_farm_state = farm_state
	if not _farm_state.plot_changed.is_connected(_on_plot_changed):
		_farm_state.plot_changed.connect(_on_plot_changed)
	_render_all()

func get_cell_view(cell: Vector2i) -> Polygon2D:
	return _cells.get(cell) as Polygon2D

func get_crop_view(cell: Vector2i) -> Sprite2D:
	return _crops.get(cell) as Sprite2D

func get_crop_label(cell: Vector2i) -> Label:
	return _crop_labels.get(cell) as Label

func play_action_fx(cell: Vector2i, action_id: StringName) -> void:
	if _effects != null:
		_effects.play_action(cell, action_id)

func pick_crop(screen_position: Vector2, _camera: Camera2D) -> Variant:
	var selected: Variant = null
	var front_y: float = -INF
	for cell: Vector2i in _crops:
		var crop: Sprite2D = _crops[cell] as Sprite2D
		if not crop.visible or crop.texture == null:
			continue
		var local_point: Vector2 = crop.get_global_transform_with_canvas().affine_inverse() * screen_position
		if crop.get_rect().grow(4).has_point(local_point) and crop.global_position.y >= front_y:
			selected = cell
			front_y = crop.global_position.y
	return selected

func _build_grid() -> void:
	for y: int in range(grid_size.y):
		for x: int in range(grid_size.x):
			var cell: Vector2i = Vector2i(x,y)
			var soil: Polygon2D = Polygon2D.new()
			soil.name = "Cell_%d_%d" % [x,y]
			soil.polygon = IsometricGrid.diamond(Vector2(_world.CONFIG.tile_size) * 0.92)
			_world.farmland.add_child(soil)
			soil.global_position = _world.cell_to_global(cell)
			_cells[cell] = soil
			var crop: Sprite2D = Sprite2D.new()
			crop.name = "Crop_%d_%d" % [x,y]
			crop.visible = false
			_world.objects.add_child(crop)
			crop.global_position = _world.cell_to_global(cell)
			_crops[cell] = crop
			var label: Label = Label.new()
			label.name = "CropLabel_%d_%d" % [x,y]
			label.visible = false
			add_child(label)
			_crop_labels[cell] = label
	_highlight = _world.get_node("WorldCanvas/Highlight") as Polygon2D
	_highlight.polygon = IsometricGrid.diamond(Vector2(_world.CONFIG.tile_size) * 0.96)
	_highlight.hide()
	_effects = FarmEffects.new()
	_effects.name = "FarmEffects"
	_effects.grid = _world.grid
	_world.get_node("WorldCanvas").add_child(_effects)
	_render_all()

func set_hovered_cell(cell: Vector2i, shown: bool, in_reach: bool) -> void:
	if _highlight == null:
		return
	_highlight.visible = shown
	_in_reach = in_reach
	if shown:
		_highlight.global_position = _world.cell_to_global(cell)
		_highlight.color = Color(0.35,0.9,0.3,0.35) if in_reach else Color(0.9,0.25,0.2,0.35)

func is_target_highlight_visible() -> bool:
	return _highlight != null and _highlight.visible

func is_target_in_reach() -> bool:
	return is_target_highlight_visible() and _in_reach

func _render_all() -> void:
	for cell: Vector2i in _cells:
		_render_cell(cell)

func _on_plot_changed(cell: Vector2i) -> void:
	_render_cell(cell)

func _render_cell(cell: Vector2i) -> void:
	var soil: Polygon2D = get_cell_view(cell)
	var crop: Sprite2D = get_crop_view(cell)
	var label: Label = get_crop_label(cell)
	if soil == null or crop == null:
		return
	var plot: Dictionary = _farm_state.get_plot(cell) if _farm_state != null else {}
	var tilled: bool = bool(plot.get("tilled", false))
	var watered: bool = bool(plot.get("watered", false))
	var withered: bool = bool(plot.get("withered", false))
	var crop_id: StringName = plot.get("crop_id", &"")
	if tilled:
		_world.farmland.set_cell(cell, 0, Vector2i(2 if watered else 1, 0))
	else:
		_world.farmland.set_cell(cell, 0, Vector2i(3, 0))
	SoilPresentation.render(soil, tilled, watered, cell)
	crop.visible = not crop_id.is_empty()
	label.visible = false
	if not crop.visible:
		CropPresentation.clear(crop)
		return
	var crop_data: Resource = DataRegistry.get_crop(crop_id)
	var required_days: int = maxi(1, int(crop_data.get("growth_days")))
	var growth_days: int = int(plot.get("growth_days", 0))
	label.text = tr("CROP_STATUS_WITHERED") if withered else (tr("CROP_STATUS_READY") if growth_days >= required_days else tr("CROP_STATUS_REMAINING") % maxi(1,required_days-growth_days))
	if not withered and growth_days < required_days and not watered:
		label.text += "\n" + tr("CROP_STATUS_NEEDS_WATER")
	CropPresentation.render(crop,crop_id,float(growth_days)/float(required_days),crop_data.get("color"),withered,watered,cell)
