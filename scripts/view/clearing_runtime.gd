## ClearingRuntime - proven shovel/presentation adapter; no rewards or day simulation.
## API: configure(main); clear(cell)->Dictionary; pick(point)->Variant;
## prepare(payload)->Dictionary; restore(candidate)->bool; reset()->bool;
## is_committed(cell,id,count)->bool. Signal cleared while busy, after both owners settle.
class_name ClearingRuntime
extends Node
signal cleared(cell: Vector2i, asset_id: StringName, count: int)
const CONFIG: ClearingConfig = preload("res://data/clearing_config.tres")
var busy: bool = false
var _main: Node
var _receipt: Dictionary = {}

func configure(main: Node) -> void:
	_main = main
	main.tool_controller.configure_clearing(self)

func _process(_delta: float) -> void:
	if _main!=null and _main.presentation!=null and not busy and not bool(_main.call("_purchase_in_progress")):
		_main.presentation.refresh_clearing_safety()

func pick(point: Vector2) -> Variant:
	if _main==null or _main.presentation==null: return null
	return _main.presentation.pick_scenery(point)

func prepare(payload: Dictionary) -> Dictionary:
	var meta: Variant = payload.get("meta")
	var version: Variant = meta.get("save_version") if meta is Dictionary else null
	var legacy: bool = not (version is int or version is float) or not is_finite(float(version)) or float(version)<ClearingSaveCodec.INTRODUCED_VERSION
	return ClearingSaveCodec.normalize(CONFIG,payload.get("clearing"),legacy)

func restore(candidate: Dictionary) -> bool:
	if busy or typeof(candidate.get("ok"))!=TYPE_BOOL or candidate.ok!=true or not candidate.get("snapshot") is Dictionary: return false
	busy = true
	if not _main.clearing_state.deserialize(candidate.snapshot):
		busy = false
		return false
	_main.presentation.refresh_clearing()
	busy = false
	return true

func reset() -> bool:
	return restore({"ok":true,"snapshot":ClearingSaveCodec.empty()})

func clear(cell: Vector2i) -> Dictionary:
	if not _available() or _main.tool_controller.get_selected_tool()!=&"shovel": return _failure(&"input_locked")
	var tool: ToolData = DataRegistry.get_tool(&"shovel") as ToolData
	if tool==null or not ToolAction.is_in_reach(_main.world.get_player_cell(),cell,tool.reach_cells): return _failure(&"out_of_reach")
	if not _main.farm_state.get_plot(cell).is_empty() or not _main.machine_placements.get_placement(cell).is_empty() or _main.world.get_player_cell()==cell or _main.npc_system.state.cells.values().has(cell) or _main.dog_state.get_cell()==cell: return _failure(&"occupied")
	var target: Dictionary = _main.presentation.get_scenery_target(cell)
	if target.is_empty(): return _failure(&"no_debris")
	var id: StringName = target.asset_id
	var reservation: Dictionary = _main.clearing_state.reserve(cell,id)
	if not reservation.ok: return reservation
	busy = true
	if not _main.presentation.remove_scenery(cell,id):
		_main.clearing_state.cancel(reservation.token)
		busy = false
		return _failure(&"stale_target")
	if not _main.clearing_state.commit(reservation.token):
		_main.clearing_state.cancel(reservation.token)
		_main.presentation.refresh_clearing()
		busy = false
		return _failure(&"commit_rejected")
	var count: int = _main.clearing_state.get_count()
	_receipt = {"cell":cell,"asset_id":id,"count":count}
	cleared.emit(cell,id,count)
	_receipt = {}
	_main.clearing_state.finish(reservation.token)
	busy = false
	_main.feedback.show_message(tr("CLEARING_PROGRESS") % [count,_main.clearing_state.get_goal()])
	return {"ok":true,"reason":&"cleared","count":count}

func is_committed(cell: Vector2i, id: StringName, count: int) -> bool:
	return busy and _receipt=={"cell":cell,"asset_id":id,"count":count} and _main.clearing_state.is_cleared(cell,id) and count==_main.clearing_state.get_count()

func _available() -> bool:
	return not busy and _main!=null and bool(_main.get("_game_started")) and not _main.start_menu.visible and _main.world.player.movement_enabled and not GameClock.is_sleeping() and not GameClock.is_day_end_held() and not bool(_main.call("_purchase_in_progress"))

func _failure(reason: StringName) -> Dictionary:
	return {"ok":false,"reason":reason}
