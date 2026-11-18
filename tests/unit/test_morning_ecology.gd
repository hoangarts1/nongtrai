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

func _owners() -> Dictionary:
	var snapshot: Dictionary = _fixture.owners()
	snapshot.ecology = _main.ecology_state.serialize()
	snapshot.weather = _main.weather_state.serialize()
	return snapshot

func test_completed_morning_reads_saved_ecology_and_reentry_or_load_never_duplicates() -> void:
	assert_false(_main.morning_flow.panel.visible)
	GameClock.sleep_to_morning()
	await _fixture.settle(self)
	var panel: LifeMorningSheet = _main.morning_flow.panel
	assert_true(panel.visible)
	var saved: Dictionary = SaveService.load_game(0)
	var snapshot: Dictionary = MorningSnapshot.capture(_main)
	assert_true(snapshot.ecology.ok)
	assert_eq(snapshot.ecology.state, saved.ecology)
	assert_eq(panel.ecology.summary.text, EcologyPresenter.describe(snapshot.ecology).news_summary)
	assert_eq(panel.ecology.water_value.text, tr("ECO_UNMEASURED"))
	var before: Dictionary = _owners()
	_main.morning_flow.refresh()
	assert_eq(_owners(), before)
	_main.morning_flow.dismiss()
	_main.call("_on_day_started", GameClock.day_index)
	await _fixture.settle(self)
	assert_false(panel.visible)
	assert_true(_main.call("_load_payload", saved))
	await _fixture.settle(self)
	assert_false(panel.visible)
	assert_eq(_main.ecology_state.serialize(), saved.ecology)

func test_native_both_locales_three_sizes_actual_values_counts_tooltips_and_captures() -> void:
	assert_true(_main.ecology_state.deserialize({"day_index": GameClock.day_index, "metrics": {"tree_cover": 30.0, "biodiversity": 25.0, "water_clarity": 99.0}, "triggered": []}))
	GameClock.sleep_to_morning()
	await _fixture.settle(self)
	var panel: LifeMorningSheet = _main.morning_flow.panel
	var before: Dictionary = _owners()
	var save: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_0.json")
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for dimensions: Vector2i in SIZES:
			_fixture.viewport.size = dimensions
			_main.morning_flow.refresh()
			await _fixture.settle(self)
			var model: Dictionary = EcologyPresenter.describe(EcologySnapshot.capture(_main))
			assert_eq(panel.ecology.summary.text, model.news_summary)
			assert_eq(panel.ecology.water_value.text, tr("ECO_UNMEASURED"))
			assert_true(panel.ecology.trees.text.contains("0 / 8"))
			assert_true(panel.ecology.species.text.contains("0 / 8"))
			assert_true(panel.ecology.trees.tooltip_text.contains(model.rows[0].target_text))
			assert_true(Rect2(Vector2.ZERO, Vector2(dimensions)).encloses(panel.get_global_rect()))
			for control: Control in [panel.ecology, panel.tasks, panel.weather, panel.garden, panel.market, panel.begin_button]:
				assert_true(panel.get_global_rect().encloses(control.get_global_rect()), control.name)
			assert_false(panel.ecology.get_global_rect().intersects(panel.tasks.get_global_rect()))
			await _capture("%s_%d" % [locale, dimensions.x])
	assert_eq(_owners(), before)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_0.json"), save)
	panel.begin_button.grab_focus()
	await _fixture.key(self, KEY_ENTER)
	assert_false(panel.visible)
	assert_eq(_owners(), before)

func test_missing_or_busy_readout_has_waiting_text_without_invented_zero_metrics() -> void:
	var panel: LifeMorningSheet = _main.morning_flow.panel
	var reserved: Dictionary = _main.ecology_state.begin_day(GameClock.day_index + 1)
	assert_true(reserved.ok)
	MorningPresenter.render(panel, MorningSnapshot.capture(_main))
	assert_eq(panel.ecology.summary.text, tr("ECO_WAITING"))
	assert_false(panel.ecology.counts.visible)
	assert_eq(panel.ecology.trees.text, "")
	assert_eq(panel.ecology.species.text, "")
	assert_eq(panel.ecology.water_value.text, tr("ECO_UNMEASURED"))
	assert_true(_main.ecology_state.abort_day(reserved.token))
	var before: Dictionary = _owners()
	var snapshot: Dictionary = MorningSnapshot.capture(_main)
	snapshot.erase("ecology")
	MorningPresenter.render(panel, snapshot)
	assert_eq(panel.ecology.summary.text, tr("ECO_WAITING"))
	assert_eq(_owners(), before)

func _capture(id: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	_fixture.viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	assert_eq(_fixture.viewport.get_texture().get_image().save_png("user://eco_morning_%s.png" % id), OK)
