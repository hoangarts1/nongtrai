extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
const VALIDATOR: Script = preload("res://scripts/core/data_validator.gd")
var f: RefCounted
var main: Node

func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
	main = f.main
	await f.settle(self)

func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func _saves() -> Dictionary:
	var hashes: Dictionary = {}
	for name: String in DirAccess.get_files_at(SaveService.SAVE_DIRECTORY):
		hashes[name] = FileAccess.get_sha256(SaveService.SAVE_DIRECTORY.path_join(name))
	return hashes

func test_preview_uses_actual_coverage_metric_availability_and_detached_saved_trace_without_writes() -> void:
	await f.prepare_dust(self)
	assert_true(main._save_game_to_slot(98))
	var before: Dictionary = f.owners()
	var saves: Dictionary = _saves()
	var flow: LifeDirectorDebugFlow = main.director_debug_flow
	assert_true(flow.open())
	for _index: int in range(12):
		flow.refresh()
		var model: Dictionary = LifeDirectorDebugSnapshot.capture(main)
		assert_eq(model.history, before.director.history)
		assert_eq(model.coverage, main.director_activity.get_window_snapshot())
		assert_false(model.available.water_clarity)
		assert_eq(LifeDirectorDebugPresenter.metric(model, "water_clarity"), tr("DIR_DEBUG_UNKNOWN"))
		model.history.clear()
		model.pending.clear()
		model.candidates.clear()
	assert_eq(f.owners(), before)
	assert_eq(_saves(), saves)
	assert_eq(flow.panel.rows.size(), LifeDirectorRuntime.PROFILE.events.size())
	assert_true(flow.panel.trace_panel.body_label.text.contains(str(int(before.director.history.back().seed_used))))
	assert_eq(main.director_state.serialize().history, before.director.history)

func test_partial_or_stale_observations_never_present_fabricated_scores_or_force_buttons() -> void:
	assert_true(main.director_debug_flow.open())
	assert_true(main.director_debug_flow.set_enabled(true))
	var model: Dictionary = main.director_debug_flow.model
	assert_false(model.ready)
	assert_eq(model.coverage.complete_days, 0)
	for row: LifeDirectorCandidateRow in main.director_debug_flow.panel.rows:
		assert_eq(row.score_label.text, tr("DIR_DEBUG_NOT_SCORED"))
		assert_true(row.force_button.disabled)
	var weather: Dictionary = main.weather_state.serialize()
	weather.day_index += 1
	main.weather_state.deserialize(weather)
	main.director_debug_flow.refresh()
	assert_false(main.director_debug_flow.model.ready)
	assert_false(main.director_debug_flow.queue_force(&"gentle_dust"))
	assert_eq(main.director_state.serialize().history, [])

func test_all_required_debug_text_exists_in_both_locales_and_missing_key_is_rejected() -> void:
	var locales: Array[String] = ["res://localization/strings_vi.csv", "res://localization/strings_en.csv"]
	assert_eq(VALIDATOR.validate_director_debug_text(locales, LifeDirectorDebugPresenter.translation_keys()), PackedStringArray())
	assert_false(VALIDATOR.validate_director_debug_text(locales, PackedStringArray(["DIR_MISSING_FIXTURE"])).is_empty())
