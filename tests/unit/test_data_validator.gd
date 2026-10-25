extends GutTest

const VALIDATOR_SCRIPT: Script = preload("res://scripts/core/data_validator.gd")

func test_shipped_item_resources_are_valid() -> void:
	var paths: Array[String] = [
		"res://data/items/turnip_seed.tres",
		"res://data/items/turnip.tres"
	]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_paths(paths)
	assert_eq(errors.size(), 0)

func test_validator_rejects_empty_id() -> void:
	var item: Resource = preload("res://scripts/data/item_data.gd").new()
	item.set("item_id", &"")
	item.set("max_stack", 1)
	var resources: Array[Resource] = [item]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_resources(resources)
	assert_true(errors.size() > 0)
	assert_string_contains(errors[0], "empty")

func test_validator_rejects_non_snake_case_id() -> void:
	var item: Resource = preload("res://scripts/data/item_data.gd").new()
	item.set("item_id", &"TurnipSeed")
	item.set("max_stack", 1)
	var resources: Array[Resource] = [item]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_resources(resources)
	assert_true(errors.size() > 0)
	assert_string_contains(errors[0], "snake_case")

func test_validator_rejects_duplicate_id() -> void:
	var item_a: Resource = preload("res://scripts/data/item_data.gd").new()
	var item_b: Resource = preload("res://scripts/data/item_data.gd").new()
	item_a.set("item_id", &"turnip")
	item_b.set("item_id", &"turnip")
	item_a.set("max_stack", 1)
	item_b.set("max_stack", 1)
	var resources: Array[Resource] = [item_a, item_b]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_resources(resources)
	assert_true(errors.size() > 0)
	assert_string_contains(errors[0], "duplicate")

func test_validator_rejects_invalid_max_stack() -> void:
	var item: Resource = preload("res://scripts/data/item_data.gd").new()
	item.set("item_id", &"turnip")
	item.set("max_stack", 0)
	var resources: Array[Resource] = [item]
	var errors: PackedStringArray = VALIDATOR_SCRIPT.validate_item_resources(resources)
	assert_true(errors.size() > 0)
	assert_string_contains(errors[0], "max_stack")
