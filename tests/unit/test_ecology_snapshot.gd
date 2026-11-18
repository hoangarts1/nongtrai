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

func _row(id: String, x: int, mature: bool = false, repeating: bool = false, dead: bool = false) -> Dictionary:
	var crop: CropData = DataRegistry.get_crop(StringName(id)) as CropData
	var target: int = crop.regrow_days if repeating else crop.growth_days
	return {"cell_x": x, "cell_y": 0, "crop_id": id, "tilled": true, "growth_days": target if mature else 0, "growth_target": target,
		"regrowing": repeating, "watered": false, "consecutive_dry_days": 0, "withered": dead, "withered_days": 1 if dead else 0}

func _garden() -> void:
	_main.farm_state.deserialize({"plots": [_row("orange", 0, true), _row("banana", 1, false, true), _row("carrot", 2), _row("spring_carrot", 3), _row("strawberry", 4), _row("pepper", 5, false, false, true), _row("apple", 6, true)]})

func test_snapshot_has_actual_owned_counts_targets_and_unchanged_eased_values() -> void:
	_garden()
	var before: Dictionary = _fixture.owners()
	var ecology: Dictionary = _main.ecology_state.serialize()
	var snapshot: Dictionary = EcologySnapshot.capture(_main)
	assert_true(snapshot.ok)
	assert_eq(snapshot.sample.counts, {"mature_fruit_trees": 2, "healthy_plants": 5, "species": 4})
	assert_eq(snapshot.sample.targets.tree_cover, 25.0)
	assert_eq(snapshot.sample.targets.biodiversity, 50.0)
	assert_eq(snapshot.state.metrics.tree_cover, 0.0, "Current daily estimate is not replaced by live target")
	assert_eq(_fixture.owners(), before)
	assert_eq(_main.ecology_state.serialize(), ecology)
	var model: Dictionary = EcologyPresenter.describe(snapshot)
	assert_true(model.ok)
	assert_true(model.rows[0].source_text.contains("2 / 8"))
	assert_true(model.rows[1].source_text.contains("4 / 8"))

func test_both_locales_and_exact_thresholds_never_show_numeric_unmeasured_water() -> void:
	assert_true(_main.ecology_state.deserialize({"day_index": GameClock.day_index, "metrics": {"tree_cover": 30.0, "biodiversity": 25.0, "water_clarity": 99.0}, "triggered": []}))
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		var model: Dictionary = EcologyPresenter.describe(EcologySnapshot.capture(_main))
		assert_true(model.ok)
		assert_true(model.rows[0].active)
		assert_true(model.rows[1].active)
		var water: Dictionary = model.rows[2]
		assert_false(water.available)
		assert_eq(water.value_text, TranslationServer.translate(&"ECO_UNMEASURED"))
		for field: String in ["value", "maximum", "target_text", "source_text", "threshold_text", "active"]:
			assert_false(water.has(field), field)
		assert_ne(model.title, "ECO_TITLE")
		assert_true(model.rows[0].threshold_text.contains("30"))
		assert_true(model.rows[1].threshold_text.contains("25"))

func test_busy_stale_invalid_snapshot_and_false_water_availability_have_no_fake_readout() -> void:
	var held: Dictionary = _main.ecology_state.begin_day(GameClock.day_index + 1)
	assert_true(held.ok)
	assert_false(EcologySnapshot.capture(_main).ok)
	assert_true(_main.ecology_state.abort_day(held.token))
	var snapshot: Dictionary = EcologySnapshot.capture(_main)
	assert_true(snapshot.ok)
	snapshot.sample.available.water_clarity = true
	assert_false(EcologySnapshot.valid(snapshot))
	assert_false(EcologyPresenter.describe(snapshot).ok)
	assert_false(EcologyPresenter.describe({"ok": true}).ok)
	assert_false(EcologySnapshot.capture(null).ok)
	var day: int = GameClock.day_index
	GameClock.day_index += 1
	assert_false(EcologySnapshot.capture(_main).ok)
	GameClock.day_index = day
	assert_true(EcologySnapshot.capture(_main).ok)

func test_snapshot_and_formatted_rows_are_detached_and_refresh_never_writes_save() -> void:
	_garden()
	var before: Dictionary = _fixture.owners()
	var ecology: Dictionary = _main.ecology_state.serialize()
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes("user://saves/slot_1.json")
	var snapshot: Dictionary = EcologySnapshot.capture(_main)
	var model: Dictionary = EcologyPresenter.describe(snapshot)
	snapshot.state.metrics.tree_cover = 999
	snapshot.sample.counts.species = 999
	snapshot.goals.species = 1
	model.rows[0].value = 999
	model.rows.clear()
	assert_eq(_fixture.owners(), before)
	assert_eq(_main.ecology_state.serialize(), ecology)
	assert_eq(FileAccess.get_file_as_bytes("user://saves/slot_1.json"), bytes)
	assert_eq(EcologySnapshot.capture(_main).sample.counts.species, 4)
	assert_true(EcologyPresenter.describe(EcologySnapshot.capture(_main)).ok)
