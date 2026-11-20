## SceneryToolDragStroke - reuse farm stroke lifetime with optional supplied-art picking.
class_name SceneryToolDragStroke
extends ToolDragStroke
var scenery_picker: Callable

func _pick_cell(point: Vector2, world: GrayBoxWorld, farm_view: Node) -> Variant:
	if scenery_picker.is_valid():
		var cell: Variant = scenery_picker.call(point)
		if cell is Vector2i: return cell
	return super._pick_cell(point,world,farm_view)
