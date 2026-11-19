extends GutTest

const FIXTURE: Script = preload("res://tests/helpers/chicken_coop_fixture.gd")
var _fixture: RefCounted
var _main: Node

func before_each() -> void:
	_fixture = FIXTURE.new()
	_fixture.setup(self)
	_main = _fixture.main

func after_each() -> void:
	await get_tree().process_frame
	_fixture.cleanup()

func _golden(version: int) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))

func _write(raw: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open("user://saves/slot_98.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(raw, "", true, true))
	file.close()

func _saved(day: int) -> Dictionary:
	return {"day_index": day, "metrics": {"tree_cover": 29.999999999999996, "water_clarity": 42.125, "biodiversity": 24.999999999999996}, "triggered": ["birds"]}

func test_all_thirteen_goldens_migrate_and_restore_ecology_without_other_progress_loss() -> void:
	var owner: EcologyState = _main.ecology_state
	for version: int in range(1, 15):
		var raw: Dictionary = _golden(version)
		var before: Dictionary = raw.duplicate(true)
		_write(raw)
		var loaded: Dictionary = SaveService.load_game(98)
		assert_eq(int(loaded.meta.save_version), 16)
		assert_eq(int(loaded.ecology.day_index), int(loaded.clock.day_index))
		assert_eq(loaded.inventory.slots, raw.inventory.slots)
		assert_eq(loaded.clock, raw.clock)
		assert_eq(loaded.get("wallet", {}), raw.get("wallet", loaded.get("wallet", {})))
		assert_true(_main.call("_load_payload", loaded))
		assert_eq(_main.ecology_state, owner)
		assert_eq(owner.serialize(), loaded.ecology)
		assert_eq(owner.get_day_index(), GameClock.day_index)
		assert_false(_main.morning_flow.panel.visible)
		assert_eq(raw, before)

func test_native_disk_full_precision_keeps_threshold_side_history_and_existing_owners() -> void:
	var snapshot: Dictionary = _saved(GameClock.day_index)
	assert_true(_main.ecology_state.deserialize(snapshot))
	var before: Dictionary = _fixture.owners()
	watch_signals(_main.ecology_state)
	assert_true(_main.call("_save_game_to_slot", 98))
	var loaded: Dictionary = SaveService.load_game(98)
	assert_eq(loaded.ecology, snapshot)
	assert_true(_main.call("_load_game_from_slot", 98))
	assert_eq(_fixture.owners(), before)
	assert_eq(_main.ecology_state.serialize(), snapshot)
	assert_false(_main.ecology_state.is_threshold_active(&"birds"))
	assert_false(_main.ecology_state.is_threshold_active(&"butterflies"))
	assert_signal_not_emitted(_main.ecology_state, "ecology_changed")
	assert_signal_not_emitted(_main.ecology_state, "threshold_crossed")

func test_legacy_cannot_smuggle_ecology_history_and_current_corruption_calibrates_explicitly() -> void:
	var raw: Dictionary = _golden(12)
	raw.ecology = _saved(int(raw.clock.day_index))
	_write(raw)
	var loaded: Dictionary = SaveService.load_game(98)
	assert_eq(loaded.ecology.triggered, [])
	assert_ne(loaded.ecology.metrics, raw.ecology.metrics)
	raw.meta.save_version = 13
	for ecology: Variant in [null, {}, [], {"day_index": 29, "metrics": {"tree_cover": 100, "water_clarity": 100, "biodiversity": 100}, "triggered": []}]:
		raw.ecology = ecology
		assert_true(_main.call("_load_payload", raw))
		assert_eq(_main.ecology_state.get_day_index(), GameClock.day_index)
		assert_eq(_main.ecology_state.get_triggered(), PackedStringArray())
		assert_ne(_main.ecology_runtime.last_restore_reason, &"restored")
		assert_eq(_main.ecology_state.get_metrics().water_clarity, 0.0)

func test_title_continue_and_new_game_reuse_owner_and_reset_history_without_replay() -> void:
	var owner: EcologyState = _main.ecology_state
	assert_true(owner.deserialize(_saved(GameClock.day_index)))
	var saved: Dictionary = owner.serialize()
	assert_true(_main.call("_return_to_start_menu"))
	_main.call("_continue_game")
	assert_eq(owner.serialize(), saved)
	assert_eq(_main.ecology_state, owner)
	watch_signals(owner)
	_main.call("_start_new_game", "An", "New Garden")
	assert_eq(_main.ecology_state, owner)
	assert_eq(owner.get_day_index(), 0)
	assert_eq(owner.get_triggered(), PackedStringArray())
	assert_eq(owner.get_metrics(), {"tree_cover": 0.0, "water_clarity": 0.0, "biodiversity": 0.0})
	assert_signal_not_emitted(owner, "ecology_changed")
	assert_signal_not_emitted(owner, "threshold_crossed")

func test_invalid_context_preflight_leaves_live_owners_and_existing_save_unchanged() -> void:
	assert_true(_main.call("_save_game_to_slot", 98))
	var file_before: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_98.json")
	var before: Dictionary = _fixture.owners()
	var ecology: Dictionary = _main.ecology_state.serialize()
	var invalid: Dictionary = {"clock": {"day_index": 30}, "farm": {"plots": "bad"}}
	assert_false(_main.call("_load_payload", invalid))
	assert_eq(_fixture.owners(), before)
	assert_eq(_main.ecology_state.serialize(), ecology)
	assert_false(_main.ecology_runtime.busy)
	assert_false(SaveService.save_game(invalid, 98))
	assert_eq(SaveService.get_write_report().error, &"invalid_ecology_context")
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_98.json"), file_before)

func test_restore_callbacks_cannot_reenter_main_save_load_new_game_or_title() -> void:
	var calls: Array[int] = [0]
	var callback: Callable = func(_cell: Vector2i) -> void:
		calls[0] += 1
		assert_true(_main.ecology_runtime.busy)
		assert_false(_main.call("_save_game_to_slot", 98))
		assert_false(_main.call("_load_payload", _golden(13)))
		assert_false(_main.call("_return_to_start_menu"))
		_main.call("_start_new_game", "Reentry", "Wrong")
	_main.farm_state.plot_changed.connect(callback)
	assert_true(_main.call("_load_payload", _golden(13)))
	_main.farm_state.plot_changed.disconnect(callback)
	assert_eq(calls[0], 1)
	var expected: Dictionary = EcologySnapshotCodec.decode(LifeEcologyRuntime.PROFILE, _golden(13).ecology).snapshot
	assert_eq(_main.ecology_state.serialize(), expected)
	assert_eq(typeof(_main.ecology_state.serialize().day_index), TYPE_INT)
	assert_false(_main.ecology_runtime.busy)
	assert_ne(_main.profile.get("player_name", ""), "Reentry")
