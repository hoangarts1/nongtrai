## ToolDragStroke — view-only pointer stroke that visits each farm cell once.
## API:
##   func handle(event: InputEventMouse, world: GrayBoxWorld, farm_view: Node, farm_state: FarmGridState, selected_tool: StringName, crop_inspector: CropInspector, can_apply: Callable, apply_cell: Callable) -> bool
class_name ToolDragStroke
extends RefCounted

var _active: bool = false
var _visited_cells: Dictionary = {}

func handle(
	event: InputEventMouse,
	world: GrayBoxWorld,
	farm_view: Node,
	farm_state: FarmGridState,
	selected_tool: StringName,
	crop_inspector: CropInspector,
	can_apply: Callable,
	apply_cell: Callable
) -> bool:
	if event is InputEventMouseButton:
		return _handle_button(event as InputEventMouseButton, world, farm_view, farm_state, selected_tool, crop_inspector, can_apply, apply_cell)
	if event is InputEventMouseMotion:
		return _handle_motion(event as InputEventMouseMotion, world, farm_view, can_apply, apply_cell)
	return false

func _handle_button(
	event: InputEventMouseButton,
	world: GrayBoxWorld,
	farm_view: Node,
	farm_state: FarmGridState,
	selected_tool: StringName,
	crop_inspector: CropInspector,
	can_apply: Callable,
	apply_cell: Callable
) -> bool:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return false
	if not event.pressed:
		var was_active: bool = _active
		_end()
		return was_active
	if not bool(can_apply.call()):
		_end()
		return false
	_active = true
	_visited_cells.clear()
	var cell: Variant = _pick_cell(event.position, world, farm_view)
	if cell == null:
		return false
	var target: Vector2i = cell as Vector2i
	if selected_tool == &"hoe" and crop_inspector != null and not StringName(farm_state.get_plot(target).get("crop_id", &"")).is_empty():
		crop_inspector.show_cell(target)
		_end()
		return true
	_apply_once(target, apply_cell)
	return true

func _handle_motion(event: InputEventMouseMotion, world: GrayBoxWorld, farm_view: Node, can_apply: Callable, apply_cell: Callable) -> bool:
	if not _active:
		return false
	if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0 or not bool(can_apply.call()):
		_end()
		return true
	var cell: Variant = _pick_cell(event.position, world, farm_view)
	if cell != null:
		_apply_once(cell as Vector2i, apply_cell)
	return true

func _apply_once(cell: Vector2i, apply_cell: Callable) -> void:
	if _visited_cells.has(cell):
		return
	_visited_cells[cell] = true
	apply_cell.call(cell)

func _pick_cell(point: Vector2, world: GrayBoxWorld, farm_view: Node) -> Variant:
	var crop_cell: Variant = farm_view.call("pick_crop", point, world.camera)
	if crop_cell is Vector2i:
		return crop_cell
	return world.pick_cell(point)

func _end() -> void:
	_active = false
	_visited_cells.clear()
