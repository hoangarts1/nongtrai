extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
const SIZES: Array[Vector2i] = [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]
var _fixture: RefCounted
var _main: Node
var _flow: LifeEcologyEffectsFlow

func before_each() -> void:
	_fixture = FIXTURE.new()
	_fixture.setup(self)
	_main = _fixture.main
	_flow = _main.ecology_effects_flow
	_flow.set_process(false)

func after_each() -> void:
	await _fixture.settle(self)
	_fixture.cleanup()

func _load(tree_value: float, diversity: float, history: Array = []) -> void:
	var payload: Dictionary = SaveService.load_game(1)
	payload.ecology = {"day_index": int(payload.clock.day_index), "metrics": {"tree_cover": tree_value, "biodiversity": diversity, "water_clarity": 100.0}, "triggered": history}
	assert_true(_main.call("_load_payload", payload))

func _owners() -> Dictionary:
	var values: Dictionary = _fixture.owners()
	values.ecology = _main.ecology_state.serialize()
	values.land = _main.land_ownership.serialize()
	values.weather = _main.weather_state.serialize()
	return values

func _nodes() -> Array[Node]:
	var nodes: Array[Node] = []
	for child: Node in _main.world.objects.get_children():
		if child is LifeEcologyCritter2D:
			nodes.append(child)
	return nodes

func test_exact_threshold_load_reuses_fourteen_nodes_and_history_cannot_keep_them_active() -> void:
	assert_eq(_nodes().size(), 0)
	_load(30.0, 25.0)
	assert_eq(_nodes().size(), 14)
	var before: Dictionary = _owners()
	var rows: Array[Dictionary] = _flow.get_presentation_snapshot()
	var save: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_1.json")
	for _index: int in range(20):
		_flow.refresh()
		assert_eq(_flow.get_presentation_snapshot(), rows)
		assert_eq(_nodes().size(), 14)
	assert_eq(_owners(), before)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_1.json"), save)
	_load(0.0, 0.0, ["birds", "butterflies", "clear_water"])
	assert_eq(_nodes().size(), 0)
	_load(100.0, 0.0)
	assert_eq(_nodes().size(), 6)
	_load(0.0, 100.0)
	assert_eq(_nodes().size(), 8)

func test_completed_day_downward_crossing_clears_nodes_and_busy_refresh_is_readonly() -> void:
	_load(30.0, 25.0)
	assert_eq(_nodes().size(), 14)
	GameClock.sleep_to_morning()
	await _fixture.settle(self)
	_flow.call("_process", 0.0)
	assert_eq(_nodes().size(), 0)
	assert_eq(SaveService.load_game(0).ecology, _main.ecology_state.serialize())
	assert_true(_main.morning_flow.panel.visible)
	var reservation: Dictionary = _main.ecology_state.begin_day(GameClock.day_index + 1)
	assert_true(reservation.ok)
	var before: Dictionary = _owners()
	_flow.refresh()
	assert_eq(_nodes().size(), 0)
	assert_eq(_owners(), before)
	assert_true(_main.ecology_state.abort_day(reservation.token))

func test_owned_expansion_polling_grid_projection_pause_and_weather_are_cosmetic() -> void:
	_load(30.0, 25.0)
	var old: Array[Dictionary] = _flow.get_presentation_snapshot()
	assert_true(_main.land_ownership.grant_next(_main.land_ownership.next_parcel_id()))
	_flow.call("_process", LifeEcologyEffectsFlow.PROFILE.refresh_seconds)
	var east: bool = false
	for row: Dictionary in _flow.get_presentation_snapshot():
		assert_true(_main.land_ownership.can_use_cell(row.cell))
		assert_almost_eq((row.global_position as Vector2).distance_to(_main.world.grid.cell_to_global(row.cell)), 0.0, 0.001)
		if row.cell.x >= 6:
			east = true
	assert_true(east)
	var rows: Array[Dictionary] = _flow.get_presentation_snapshot()
	for index: int in range(rows.size()):
		assert_eq(rows[index].instance_id, old[index].instance_id)
	var before: Dictionary = _owners()
	_flow.call("_process", 0.25)
	assert_eq(_flow.get_presentation_snapshot(), rows, "Paused phases remain frozen")
	GameClock.paused = false
	_flow.call("_process", 0.25)
	GameClock.paused = true
	assert_ne(_flow.get_presentation_snapshot()[0].phase, rows[0].phase)
	assert_eq(_owners(), before)
	GameClock.set_time(23, 0)
	_main.weather_state.force_weather(&"rain")
	assert_true(_main.weather_state.is_rainy())
	_flow.refresh()
	for row: Dictionary in _flow.get_presentation_snapshot():
		assert_almost_eq(float(row.opacity), LifeEcologyEffectsFlow.PROFILE.night_opacity * LifeEcologyEffectsFlow.PROFILE.rain_opacity, 0.0001)
		assert_false(row.has("water_effect"))

func test_native_pan_zoom_locales_sizes_and_night_rain_capture_leave_owners_unchanged() -> void:
	_load(30.0, 25.0)
	var before: Dictionary = _owners()
	var anchors: Array[Dictionary] = _flow.get_presentation_snapshot()
	_main.world.player.movement_enabled = true
	for pressed: bool in [true, false]:
		var button: InputEventMouseButton = InputEventMouseButton.new()
		button.button_index = MOUSE_BUTTON_MIDDLE
		button.position = Vector2(600, 360)
		button.pressed = pressed
		_fixture.viewport.push_input(button, true)
		if pressed:
			var motion: InputEventMouseMotion = InputEventMouseMotion.new()
			motion.position = Vector2(650, 380)
			motion.relative = Vector2(50, 20)
			_fixture.viewport.push_input(motion, true)
		await _fixture.settle(self)
	assert_ne(_main.world.camera_rig.get_pan_offset(), Vector2.ZERO)
	var zoom_before: Vector2 = _main.world.camera.zoom
	var zoom: InputEventAction = InputEventAction.new()
	zoom.action = &"camera_zoom_in"
	zoom.pressed = true
	_fixture.viewport.push_input(zoom, true)
	await _fixture.settle(self)
	assert_ne(_main.world.camera.zoom, zoom_before)
	assert_eq(_flow.get_presentation_snapshot(), anchors, "Camera changes presentation transform, never logical anchors")
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_fixture.viewport.size = dimensions
			_flow.refresh()
			await _fixture.settle(self)
			assert_eq(_nodes().size(), 14)
			await _capture("%s_%d_active" % [locale, dimensions.x])
	assert_eq(_owners(), before)
	GameClock.set_time(23, 0)
	_main.weather_state.force_weather(&"rain")
	assert_true(_main.weather_state.is_rainy())
	var night: Dictionary = _owners()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_fixture.viewport.size = dimensions
			_flow.refresh()
			await _capture("%s_%d_night_rain" % [locale, dimensions.x])
	assert_eq(_owners(), night)

func test_repeated_load_title_new_game_and_free_release_every_owned_node() -> void:
	var baseline: int = _main.world.objects.get_child_count()
	for _index: int in range(10):
		_load(30.0, 25.0)
		assert_eq(_main.world.objects.get_child_count(), baseline + 14)
		_load(0.0, 0.0, ["birds", "butterflies"])
		assert_eq(_main.world.objects.get_child_count(), baseline)
	_load(30.0, 25.0)
	assert_true(_main.call("_return_to_start_menu"))
	assert_eq(_nodes().size(), 0)
	_main.call("_start_new_game", "New", "Garden")
	_main.tutorial_panel.close_help()
	assert_eq(_nodes().size(), 0)
	_load(30.0, 25.0)
	_flow.free()
	_main.ecology_effects_flow = null
	assert_eq(_nodes().size(), 0)
	await _fixture.settle(self)
	assert_eq(_main.world.objects.get_child_count(), baseline)

func _capture(id: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_fixture.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	assert_eq(_fixture.viewport.get_texture().get_image().save_png("user://eco_effects_%s.png" % id), OK)
