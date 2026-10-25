## ToolAction — pure farm action dispatcher for the MVP tools.
## API:
##   static func is_in_reach(player_cell: Vector2i, target_cell: Vector2i, reach_cells: int) -> bool
##   static func apply(tool_id: StringName, farm_state: FarmGridState, cell: Vector2i, crop_id: StringName) -> bool
class_name ToolAction
extends RefCounted

static func is_in_reach(player_cell: Vector2i, target_cell: Vector2i, reach_cells: int) -> bool:
	if reach_cells < 0:
		return false
	return maxi(absi(player_cell.x - target_cell.x), absi(player_cell.y - target_cell.y)) <= reach_cells

static func apply(
	tool_id: StringName,
	farm_state: FarmGridState,
	cell: Vector2i,
	crop_id: StringName
) -> bool:
	match tool_id:
		&"hoe":
			return farm_state.till_cell(cell)
		&"water":
			return farm_state.water_cell(cell)
		&"seed":
			return farm_state.plant_crop(cell, crop_id)
		_:
			return false
