extends GutTest
const CONFIG: DogConfig = preload("res://data/dog_config.tres")

func test_owner_names_cells_copies_revision_and_silent_valid_json_restore() -> void:
	var owner: DogState = DogState.new()
	assert_true(owner.configure(CONFIG, Vector2i(3, 3)))
	assert_eq(owner.serialize(), {"name": "", "cell_x": 3, "cell_y": 3})
	assert_true(owner.try_set_name(" Sóc ", owner.get_revision()).ok)
	assert_eq(owner.get_name(), "Sóc")
	var revision: int = owner.get_revision()
	assert_true(owner.try_set_cell(Vector2i(-2, 0), revision).ok)
	assert_false(owner.try_set_name("Milo", revision).ok)
	var calls: Array[int] = []
	var callback: Callable = func(_cell: Vector2i, _name: String) -> void: calls.append(1)
	owner.changed.connect(callback)
	var raw: Dictionary = owner.serialize()
	assert_true(owner.deserialize(JSON.parse_string(JSON.stringify(raw, "", true, true))))
	assert_eq(calls, [])
	assert_gt(owner.get_revision(), revision)
	raw.name = "Changed"
	assert_eq(owner.get_name(), "Sóc")
	owner.changed.disconnect(callback)

func test_invalid_mutations_and_reentrant_configure_restore_rename_move_are_atomic() -> void:
	var owner: DogState = DogState.new()
	assert_false(owner.try_set_name("Milo").ok)
	assert_true(owner.configure(CONFIG, Vector2i.ZERO))
	var before: Dictionary = owner.serialize()
	assert_false(owner.deserialize({"name": "Bad", "cell_x": false, "cell_y": 0}))
	assert_false(owner.try_set_name(" ").ok)
	assert_false(owner.try_set_cell(CONFIG.world.player_region.end).ok)
	assert_eq(owner.serialize(), before)
	var results: Array[bool] = []
	var callback: Callable = func(_cell: Vector2i, _name: String) -> void:
		results.append(owner.is_busy())
		results.append(owner.configure(CONFIG, Vector2i.ONE))
		results.append(owner.deserialize(before))
		results.append(owner.try_set_name("Nested").ok)
		results.append(owner.try_set_cell(Vector2i.ONE).ok)
	owner.changed.connect(callback)
	assert_true(owner.try_set_name("Milo").ok)
	owner.changed.disconnect(callback)
	assert_eq(results, [true, false, false, false, false])
	assert_eq(owner.get_name(), "Milo")
	assert_eq(owner.get_cell(), Vector2i.ZERO)

func test_config_is_detached_and_rejected_reconfigure_does_not_replace_progress() -> void:
	var config: DogConfig = CONFIG.frozen_copy()
	var owner: DogState = DogState.new()
	assert_true(owner.configure(config, Vector2i.ZERO))
	config.world.player_region = Rect2i(400, 400, 1, 1)
	assert_true(owner.try_set_cell(Vector2i(1, 0)).ok)
	assert_true(owner.try_set_name("Mây").ok)
	var before: Dictionary = owner.serialize()
	assert_false(owner.configure(config, Vector2i.ZERO))
	assert_eq(owner.serialize(), before)
