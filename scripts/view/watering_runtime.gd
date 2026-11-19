## WateringRuntime — Main-owned command/lifecycle adapter, never a second water owner.
## API:
##   func configure(main: Node) -> void
##   func water(cell: Vector2i) -> Dictionary
##   func can_refill() -> Dictionary
##   func refill() -> Dictionary
##   func reset() -> void
##   func restore(payload: Dictionary) -> void
##   func refresh() -> void
##   signal water_changed(charges: int, capacity: int)
class_name WateringRuntime
extends Node

signal water_changed(charges: int, capacity: int)
const CONFIG: WateringCanConfig = preload("res://data/watering_can_config.tres")
const SOURCES: WaterSourceConfig = preload("res://data/water_sources.tres")
var busy: bool = false
var _main: Node
var _water: WateringService = WateringService.new()
var _refill: WaterRefillService = WaterRefillService.new()

func configure(main: Node) -> void:
	name = "WateringRuntime"
	_main = main
	_water.configure(CONFIG,main.watering_can,main.farm_state)
	_refill.configure(CONFIG,main.watering_can,SOURCES,(preload("res://data/npcs/phase8_world.tres") as NpcWorldData).locations)
	main.tool_controller.configure_watering(self)
	main.world.configure_water_refill(can_refill,refill)

func water(cell: Vector2i) -> Dictionary:
	if not _available():
		return _failure(&"input_locked")
	var tool: Resource = DataRegistry.get_tool(&"watering_can")
	if tool==null or not ToolAction.is_in_reach(_main.world.get_player_cell(),cell,int(tool.get("reach_cells"))):
		_feedback("UI_CROP_OUT_OF_REACH")
		return _failure(&"out_of_reach")
	var permission: Dictionary = _main.machine_placement_request.can_use_farm_tool(cell,&"water")
	if not bool(permission.ok):
		_feedback("LAND_LOCKED" if permission.reason==&"land_locked" else "PLC_MACHINE_CELL")
		return permission
	if _main.director_water_bridge != null and not _main.director_water_bridge.apply():
		return _failure(&"invalid_modifier")
	var receipt: Dictionary = _main.director_activity_collector.begin_command(&"water") if _main.director_activity_collector != null else {"ok": true}
	if not receipt.ok:
		return _failure(&"input_locked")
	busy = true
	var result: Dictionary = _water.water(cell)
	if _main.director_activity_collector != null:
		_main.director_activity_collector.finish_command(receipt.token, {"plot_watered": 1} if result.ok else {})
	busy = false
	if bool(result.ok):
		refresh()
	else:
		_feedback("WATER_CAN_EMPTY" if result.reason==&"water_empty" else "UI_FEEDBACK_NOT_READY")
	return result

func set_director_terms(terms: Dictionary) -> bool:
	return _water.set_effect_terms(terms)

func get_charge_cost() -> int:
	return _water.get_charge_cost()

func can_refill() -> Dictionary:
	if not _available() or _main.tool_controller.get_selected_tool()!=&"water":
		return _failure(&"input_locked")
	return _refill.can_refill(_main.world.get_player_cell())

func refill() -> Dictionary:
	var ready: Dictionary = can_refill()
	if not bool(ready.ok):
		if ready.reason==&"already_full":
			_feedback("WATER_CAN_FULL")
		elif ready.reason!=&"input_locked":
			_feedback("WATER_REFILL_UNAVAILABLE")
		return ready
	busy = true
	var result: Dictionary = _refill.refill(_main.world.get_player_cell())
	busy = false
	if bool(result.ok):
		refresh()
		_feedback("WATER_REFILLED")
	else:
		_feedback("WATER_REFILL_UNAVAILABLE")
	return result

func reset() -> void:
	_main.watering_can.configure(CONFIG)
	refresh()

func restore(payload: Dictionary) -> void:
	var meta: Variant = payload.get("meta",{})
	var version: Variant = meta.get("save_version",0) if meta is Dictionary else 0
	var current: bool = (version is int or version is float) and is_finite(float(version)) and float(version)>=SaveService.WATERING_INTRODUCED_VERSION
	if not current:
		_main.watering_can.configure(CONFIG)
	else:
		var data: Variant = payload.get("watering_can",{})
		_main.watering_can.deserialize(data if data is Dictionary else {})
	refresh()

func refresh() -> void:
	if not busy and is_instance_valid(_main):
		water_changed.emit(_main.watering_can.get_charges(),_main.watering_can.get_capacity())

func _available() -> bool:
	return not busy and is_instance_valid(_main) and bool(_main.get("_game_started")) and _main.world.player.movement_enabled and not GameClock.is_sleeping() and not bool(_main.call("_purchase_in_progress"))

func _feedback(key: String) -> void:
	_main.feedback.show_message(tr(key))

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
