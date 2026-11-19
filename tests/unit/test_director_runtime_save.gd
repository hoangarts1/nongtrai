extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/director_fixture.gd")
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

func test_actual_save_load_continue_preserve_pending_active_force_rng_and_all_existing_owners() -> void:
	await f.prepare_dust(self)
	main.inventory.add_item(&"turnip", 3)
	main.watering_can.deserialize({"capacity": 40, "charges": 7})
	main.wallet.deserialize({"coins": 6789})
	assert_true(main.director_runtime.queue_force(&"merchant_visit"))
	var before: Dictionary = f.owners()
	assert_true(main._save_game_to_slot(98))
	var raw: Dictionary = SaveService.load_game(98)
	assert_eq(int(raw.meta.save_version), SaveService.CURRENT_VERSION)
	assert_eq(raw.director, before.director)
	assert_eq(raw.director_activity, before.director_activity)
	assert_true(main._load_game_from_slot(98))
	assert_eq(f.owners(), before)
	assert_false(main.morning_flow.panel.visible)
	assert_true(main._save_game_to_slot(1))
	assert_true(main._return_to_start_menu())
	main._continue_game()
	assert_false(main.start_menu.visible)
	assert_eq(f.owners(), before)
	assert_false(main.morning_flow.panel.visible)

func test_thirteen_legacy_payloads_are_partial_off_without_replay_and_keep_previous_progress() -> void:
	for version: int in range(1, 14):
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		var before: Dictionary = raw.duplicate(true)
		assert_true(main._load_payload(raw), str(version))
		assert_eq(GameClock.day_index, int(raw.clock.day_index))
		assert_false(main.director_state.is_enabled())
		assert_eq(main.director_state.serialize().history, [])
		assert_eq(main.director_state.serialize().pending, [])
		assert_false(main.director_activity.serialize().current_complete)
		assert_eq(main.director_activity.serialize().completed_days, [])
		assert_eq(raw, before)
		assert_false(main.morning_flow.panel.visible)
		assert_true(main._save_game_to_slot(98))
		assert_eq(SaveService.load_game(98).director, main.director_state.serialize())

func test_real_codec_golden14_and_corrupt_pair_reset_only_new_components_with_diagnostic() -> void:
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v14.json"))
	assert_eq(int(golden.meta.save_version), 14)
	assert_true(main._load_payload(golden))
	var before: Dictionary = f.owners()
	var bad: Dictionary = golden.duplicate(true)
	bad.director.enabled = "wrong"
	var path: String = "user://saves/slot_98.json"
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(bad, "", true, true))
	file.close()
	var normalized: Dictionary = SaveService.load_game(98)
	assert_false(normalized.director.enabled)
	assert_eq(normalized.director.history, [])
	assert_false(normalized.director_activity.current_complete)
	assert_true(main._load_payload(normalized))
	var after: Dictionary = f.owners()
	for key: String in before:
		assert_eq(after[key], before[key], key)

func test_saved_debug_enabled_cannot_grant_story_or_bypass_actual_release_gate() -> void:
	await f.prepare_dust(self)
	assert_true(main._save_game_to_slot(98))
	main.director_runtime.debug_preview_allowed = false
	assert_true(main._load_game_from_slot(98))
	assert_true(main.director_state.is_enabled(), "Stored intent is preserved, effective authorization is separate")
	assert_false(main.director_runtime.authorization_allowed())
	assert_false(main.director_runtime.set_enabled(true))
	var source: Dictionary = main.director_runtime.capture_observation()
	assert_false(source.source.gates.story_unlocked)
	assert_false(source.source.gates.debug_preview)
	assert_false(source.ready)
	var projection: Dictionary = main.director_runtime.get_projection(true)
	assert_false(projection.enabled)
	assert_eq(projection.visitor, {})
	assert_eq(projection.accent, [])
	assert_eq(projection.water.event, {})
	await f.advance(self, 1, 100.0, 0.0)
	var decision: Dictionary = main.director_state.serialize().history.back()
	assert_eq(decision.reason, "locked")
	assert_null(decision.seed_used)
	assert_eq(decision.rng_state, "")
