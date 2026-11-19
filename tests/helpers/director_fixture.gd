## DirectorFixture - real Main/owners and isolated complete save-family protection.
extends RefCounted

const BASE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
var main: Node
var viewport: SubViewport
var _base: RefCounted
var _saved: Dictionary = {}

func _owned_file(name: String) -> bool:
	for slot: int in [0, 1, 98]:
		if name == "slot_%d.json" % slot or name.begins_with("slot_%d.json." % slot):
			return true
	return false

func _clear_files() -> void:
	for name: String in DirAccess.get_files_at(SaveService.SAVE_DIRECTORY):
		if _owned_file(name):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(SaveService.SAVE_DIRECTORY.path_join(name)))

func setup(host: Node) -> void:
	for name: String in DirAccess.get_files_at(SaveService.SAVE_DIRECTORY):
		if _owned_file(name):
			var file: FileAccess = FileAccess.open(SaveService.SAVE_DIRECTORY.path_join(name), FileAccess.READ)
			_saved[name] = file.get_buffer(file.get_length())
	_clear_files()
	_base = BASE.new()
	_base.setup(host)
	main = _base.main
	viewport = _base.viewport

func cleanup() -> void:
	_base.cleanup()
	_clear_files()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SaveService.SAVE_DIRECTORY))
	for name: String in _saved:
		var file: FileAccess = FileAccess.open(SaveService.SAVE_DIRECTORY.path_join(name), FileAccess.WRITE)
		file.store_buffer(_saved[name])
	_saved.clear()

func settle(host: Node) -> void:
	await _base.settle(host)

func key(host: Node, code: Key) -> void:
	await _base.key(host, code)

func open_coop(coins: int = 1000) -> void:
	_base.open(coins)

func mouse(host: Node, position: Vector2) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		viewport.push_input(event, true)
		await host.get_tree().process_frame
	await settle(host)

func use(tool: StringName, cell: Vector2i) -> void:
	main.world.player.move_to_cell(cell + Vector2i(0, 1))
	if tool == &"seed":
		main.tool_controller.select_seed()
	else:
		main.tool_controller.select_tool(tool)
	main.tool_controller._hovered_cell = cell
	main.tool_controller._hovered_valid = true
	main.tool_controller._use_selected_tool()

func current_counts() -> Dictionary:
	return main.director_activity.serialize().current_counts

func owners() -> Dictionary:
	var result: Dictionary = _base.owners()
	result["ecology"] = main.ecology_state.serialize()
	result["director_activity"] = main.director_activity.serialize()
	result["director"] = main.director_state.serialize()
	result["land"] = main.land_ownership.serialize()
	result["placements"] = main.machine_placements.serialize()
	result["profile"] = main.profile.duplicate(true)
	result["ledger"] = main.day_end_flow.ledger.serialize()
	result["day_end"] = main.day_end_flow.state.serialize()
	return result

func advance(host: Node, count: int = 1, biodiversity: float = 0.0, canopy: float = 0.0) -> void:
	for _index: int in range(count):
		main.morning_flow.reset()
		main.ui_coordinator.close_active()
		var weather: Dictionary = main.weather_state.serialize()
		weather.today = "sunny"
		weather.forecast = ["sunny", "sunny", "sunny"]
		main.weather_state.deserialize(weather)
		var ecology: Dictionary = main.ecology_state.serialize()
		ecology.metrics.biodiversity = biodiversity
		ecology.metrics.tree_cover = canopy
		main.ecology_state.deserialize(ecology)
		GameClock.sleep_to_morning()
		GameClock.paused = true
		await settle(host)
		main.morning_flow.reset()
		main.ui_coordinator.close_active()

func prepare_bloom(host: Node) -> void:
	assert(main.director_runtime.set_enabled(true))
	await advance(host, 6, 100.0, 100.0)
	assert(main.director_runtime.queue_force(&"butterfly_bloom"))
	await advance(host, 1, 100.0, 100.0)
	assert(main.director_state.serialize().history.back().event_id == "butterfly_bloom")

func prepare_dust(host: Node) -> void:
	await prepare_bloom(host)
	assert(main.director_runtime.queue_force(&"gentle_dust"))
	await advance(host, 1, 100.0, 0.0)
	assert(main.director_state.serialize().pending.size() == 1)
