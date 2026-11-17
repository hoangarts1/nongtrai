## MachinePlacementRequest — stateless placement/tool permission adapter, no Nodes.
## API: configure(build, farm, config, map_region, reach); preview/place; can_return/return_to_storage; can_use_farm_tool -> Dictionary.
##   func can_begin_move(cell: Vector2i, player_cell: Vector2i) -> Dictionary
##   func preview_move(source: Dictionary, target_cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary
##   func move(source: Dictionary, target_cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary
class_name MachinePlacementRequest
extends RefCounted

var _build: MachineBuildService
var _farm: FarmGridState
var _config: MachineBuildConfig
var _map_region: Rect2i
var _reach: float
var _land: LandOwnershipState

func configure(build: MachineBuildService, farm: FarmGridState, config: MachineBuildConfig, map_region: Rect2i, reach: float, land: LandOwnershipState = null) -> void:
	_build = build
	_farm = farm
	_config = config
	_map_region = map_region
	_reach = reach
	_land = land

func preview(id: StringName, cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary:
	if not _configured():
		return _failure(&"invalid_state")
	var result: Dictionary = _build.can_place(id,cell,rotation)
	if not bool(result.ok):
		return result
	return _target_policy(cell,player_cell)

func _target_policy(cell: Vector2i, player_cell: Vector2i) -> Dictionary:
	if _land!=null and not _land.can_use_cell(cell):
		return _failure(&"land_locked")
	if _land==null and not _config.allowed_region.has_point(cell):
		return _failure(&"outside_build_region")
	if cell==player_cell:
		return _failure(&"player_occupied")
	if not _near(cell,player_cell):
		return _failure(&"out_of_reach")
	var plot: Dictionary = _farm.get_plot(cell)
	if bool(plot.get("tilled",false)) or not StringName(plot.get("crop_id",&"")).is_empty():
		return _failure(&"plot_occupied")
	return {"ok":true,"reason":&"editable"}

func place(id: StringName, cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary:
	var result: Dictionary = preview(id,cell,rotation,player_cell)
	return _build.place(id,cell,rotation) if bool(result.ok) else result

func can_return(cell: Vector2i, player_cell: Vector2i) -> Dictionary:
	if not _configured():
		return _failure(&"invalid_state")
	var result: Dictionary = _build.can_remove(cell)
	if not bool(result.ok):
		return result
	return result if _near(cell,player_cell) else _failure(&"out_of_reach")

func return_to_storage(cell: Vector2i, player_cell: Vector2i) -> Dictionary:
	var result: Dictionary = can_return(cell,player_cell)
	return _build.remove(cell) if bool(result.ok) else result

func can_begin_move(cell: Vector2i, player_cell: Vector2i) -> Dictionary:
	var result: Dictionary = can_return(cell,player_cell)
	if not bool(result.ok):
		return result
	var source: Dictionary = _build.placement_state.get_placement(cell)
	result = _build.can_move(cell,cell,int(source.rotation))
	return {"ok":true,"reason":&"editable","source":source} if bool(result.ok) else result

func preview_move(source: Dictionary, target_cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary:
	if not _configured():
		return _failure(&"invalid_state")
	if not source.get("cell") is Vector2i or not source.get("rotation") is int or not (source.get("machine_id") is StringName or source.get("machine_id") is String):
		return _failure(&"invalid_state")
	var cell: Vector2i = source.cell
	if _build.placement_state==null or _build.placement_state.get_placement(cell)!=source:
		return _failure(&"stale_source")
	var result: Dictionary = can_begin_move(cell,player_cell)
	if not bool(result.ok):
		return result
	result = _build.can_move(cell,target_cell,rotation)
	if not bool(result.ok):
		return result
	# Existing source footprints (including legacy crops) are not newly occupied.
	return result if cell==target_cell else _target_policy(target_cell,player_cell)

func move(source: Dictionary, target_cell: Vector2i, rotation: int, player_cell: Vector2i) -> Dictionary:
	var result: Dictionary = preview_move(source,target_cell,rotation,player_cell)
	return _build.move(source.cell,target_cell,rotation) if bool(result.ok) else result

func can_use_farm_tool(cell: Vector2i, action_id: StringName) -> Dictionary:
	if not _configured() or _build.placement_state==null:
		return _failure(&"invalid_state")
	if action_id in [&"hoe",&"seed"] and not _build.placement_state.get_placement(cell).is_empty():
		return _failure(&"cell_unavailable")
	if _land!=null and action_id in [&"hoe",&"seed"] and not _land.can_use_cell(cell):
		# Keep established plots in old saves usable without granting surrounding land.
		if not bool(_farm.get_plot(cell).get("tilled",false)):
			return _failure(&"land_locked")
	return {"ok":true,"reason":&"editable"}

func _configured() -> bool:
	return _build!=null and _farm!=null and _config!=null and _config.is_valid(_map_region) and is_finite(_reach) and _reach>0

func _near(cell: Vector2i, player_cell: Vector2i) -> bool:
	return Vector2(cell).distance_squared_to(Vector2(player_cell))<=_reach*_reach

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
