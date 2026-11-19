extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
const SIZES: Array[Vector2i] = [Vector2i(1152, 648), Vector2i(1280, 720), Vector2i(1920, 1080)]
var _fixture: RefCounted
var _main: Node

func before_each() -> void:
	_fixture = FIXTURE.new()
	_fixture.setup(self)
	_main = _fixture.main

func after_each() -> void:
	await _fixture.settle(self)
	_fixture.cleanup()

func _payload() -> Dictionary:
	var payload: Dictionary = SaveService.load_game(1)
	var plots: Array[Dictionary] = []
	var config: EcologySamplingConfig = LifeEcologyRuntime.SAMPLING
	var region: Rect2i = (preload("res://data/land_expansion_config.tres") as LandExpansionConfig).initial_region
	var species: Dictionary = {}
	for index: int in range(config.mature_tree_goal):
		var id: StringName = StringName(config.fruit_tree_ids[index % config.fruit_tree_ids.size()])
		plots.append(_plot(id, plots.size(), region))
		species[String(id)] = true
	for crop: CropData in DataRegistry.get_all_crops():
		var id: String = String(config.species_aliases.get(String(crop.crop_id), String(crop.crop_id)))
		if species.has(id) or (not crop.seasons.is_empty() and not crop.seasons.has("spring")):
			continue
		plots.append(_plot(crop.crop_id, plots.size(), region))
		species[id] = true
		if species.size() >= config.species_goal:
			break
	payload.farm = {"plots": plots}
	payload.ecology = {"day_index": 0, "metrics": {"tree_cover": 30.0, "biodiversity": 25.0, "water_clarity": 99.0}, "triggered": []}
	return payload

func _plot(id: StringName, index: int, region: Rect2i) -> Dictionary:
	var crop: CropData = DataRegistry.get_crop(id) as CropData
	return {"cell_x": region.position.x + index % region.size.x, "cell_y": region.position.y + floori(float(index) / float(region.size.x)), "crop_id": String(id), "tilled": true, "growth_days": crop.growth_days, "growth_target": crop.growth_days, "regrowing": false, "watered": true, "consecutive_dry_days": 0, "withered": false, "withered_days": 0}

func _owners() -> Dictionary:
	var result: Dictionary = _fixture.owners()
	result.ecology = _main.ecology_state.serialize()
	result.weather = _main.weather_state.serialize()
	result.land = _main.land_ownership.serialize()
	result.player_cell = _main.world.get_player_cell()
	result.profile = _main.profile.duplicate(true)
	return result

func test_native_review_autosave_bulletin_journal_and_feedback_both_locales_three_sizes() -> void:
	var payload: Dictionary = _payload()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_fixture.viewport.size = dimensions
			assert_true(_main.call("_load_payload", payload))
			var readout: Dictionary = EcologySnapshot.capture(_main)
			assert_true(readout.ok)
			assert_gte(int(readout.sample.counts.mature_fruit_trees), LifeEcologyRuntime.SAMPLING.mature_tree_goal)
			assert_gte(int(readout.sample.counts.species), LifeEcologyRuntime.SAMPLING.species_goal)
			GameClock.set_time(20, 0)
			assert_true(_main.day_end_flow.request())
			_main.day_end_flow.panel.continue_button.grab_focus()
			await _fixture.key(self, KEY_ENTER)
			assert_eq(GameClock.day_index, 1)
			assert_true(_main.morning_flow.panel.visible)
			assert_eq(_main.ecology_effects_flow.get_presentation_snapshot().size(), 14)
			var saved: Dictionary = SaveService.load_game(0)
			assert_eq(int(saved.meta.save_version), 15)
			assert_eq(saved.ecology, _main.ecology_state.serialize())
			for id: String in ["tree_cover", "biodiversity"]:
				var metric: EcologyMetricData = LifeEcologyRuntime.PROFILE.get_metric(StringName(id))
				var expected: float = float(payload.ecology.metrics[id]) + (float(readout.sample.targets[id]) - float(payload.ecology.metrics[id])) * metric.ease_percent / EcologyMetricData.PERCENT_SCALE
				assert_eq(float(saved.ecology.metrics[id]), expected)
			assert_eq(float(saved.ecology.metrics.water_clarity), 99.0)
			var before: Dictionary = _owners()
			var bytes: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_0.json")
			_main.day_end_flow.confirm()
			_main.morning_flow.refresh()
			await _capture("%s_%d_morning" % [locale, dimensions.x])
			_main.morning_flow.panel.begin_button.grab_focus()
			await _fixture.key(self, KEY_ENTER)
			await _fixture.key(self, KEY_J)
			assert_true(_main.npc_system.journal.visible)
			await _click(_main.npc_system.journal.book.ecology_button)
			var sheet: LifeEcologySheet = _main.npc_system.journal.book.ecology_sheet
			assert_not_null(sheet)
			assert_eq(sheet.metric_rows[0].bar.value, float(saved.ecology.metrics.tree_cover))
			assert_eq(sheet.metric_rows[1].bar.value, float(saved.ecology.metrics.biodiversity))
			assert_false(sheet.metric_rows[2].bar.visible)
			assert_eq(sheet.metric_rows[2].value.text, tr("ECO_UNMEASURED"))
			assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(_main.npc_system.journal.get_global_rect()))
			await _capture("%s_%d_journal" % [locale, dimensions.x])
			sheet.back_button.grab_focus()
			await _fixture.key(self, KEY_ENTER)
			await _fixture.key(self, KEY_ESCAPE)
			assert_false(_main.npc_system.journal.visible)
			await _capture("%s_%d_world" % [locale, dimensions.x])
			assert_eq(_owners(), before)
			assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_0.json"), bytes)

func test_forced_review_restore_completed_load_and_continue_do_not_replay_days_or_history_effects() -> void:
	assert_true(_main.call("_load_payload", _payload()))
	GameClock.set_time(25, 59)
	GameClock.advance_minutes(1)
	assert_true(_main.day_end_flow.panel.visible)
	var review: Dictionary = SaveService.load_game(1)
	var original: Dictionary = _main.ecology_state.serialize()
	assert_true(_main.call("_load_payload", review))
	assert_true(_main.day_end_flow.panel.visible)
	assert_eq(_main.ecology_state.serialize(), original)
	_main.day_end_flow.confirm()
	await _fixture.settle(self)
	assert_eq(GameClock.day_index, 1)
	var completed: Dictionary = SaveService.load_game(0)
	assert_true(_main.call("_load_payload", completed))
	await _fixture.settle(self)
	assert_false(_main.morning_flow.panel.visible)
	assert_eq(_main.ecology_effects_flow.get_presentation_snapshot().size(), 14)
	var before: Dictionary = _owners()
	_main.call("_on_day_started", GameClock.day_index)
	assert_eq(_owners(), before)
	completed.ecology.metrics.tree_cover = 0.0
	completed.ecology.metrics.biodiversity = 0.0
	completed.ecology.triggered = ["birds", "butterflies"]
	assert_true(_main.call("_load_payload", completed))
	assert_eq(_main.ecology_effects_flow.get_presentation_snapshot().size(), 0)
	assert_true(_main.call("_return_to_start_menu"))
	SaveService.delete_save(0)
	assert_false(FileAccess.file_exists("user://saves/slot_0.json"), "Isolated fixture leaves only its title autosave")
	_main.call("_continue_game")
	await _fixture.settle(self)
	assert_false(_main.start_menu.visible)
	assert_eq(_main.ecology_state.serialize(), completed.ecology)
	assert_eq(_main.ecology_effects_flow.get_presentation_snapshot().size(), 0)
	assert_false(_main.morning_flow.panel.visible)

func _click(button: Button) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = point
	_fixture.viewport.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = pressed
		_fixture.viewport.push_input(event, true)
		await get_tree().process_frame
	await _fixture.settle(self)

func _capture(id: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_fixture.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	assert_eq(_fixture.viewport.get_texture().get_image().save_png("user://eco_e2e_%s.png" % id), OK)
