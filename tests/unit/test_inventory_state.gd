extends GutTest

var inventory

func before_each() -> void:
	inventory = preload("res://scripts/domain/inventory_state.gd").new(2)

func test_add_item_and_check_quantity() -> void:
	assert_eq(inventory.add_item(&"turnip_seed", 10), 10)
	assert_true(inventory.has_item(&"turnip_seed", 10))
	assert_eq(inventory.get_quantity(&"turnip_seed"), 10)

func test_same_item_stacks_until_maximum() -> void:
	assert_eq(inventory.add_item(&"turnip", 25), 25)
	assert_eq(inventory.get_slots().size(), 2)
	assert_eq(inventory.get_slots()[0]["quantity"], 20)
	assert_eq(inventory.get_slots()[1]["quantity"], 5)

func test_remove_requires_sufficient_quantity() -> void:
	inventory.add_item(&"turnip_seed", 10)
	assert_false(inventory.remove_item(&"turnip_seed", 11))
	assert_eq(inventory.get_quantity(&"turnip_seed"), 10)
	assert_true(inventory.remove_item(&"turnip_seed", 4))
	assert_eq(inventory.get_quantity(&"turnip_seed"), 6)

func test_full_inventory_rejects_items_without_free_slot() -> void:
	assert_eq(inventory.add_item(&"turnip", 40), 40)
	assert_eq(inventory.add_item(&"turnip_seed", 1), 0)
	assert_eq(inventory.get_slots().size(), 2)

func test_serialize_and_deserialize_preserve_slots() -> void:
	inventory.add_item(&"turnip_seed", 12)
	inventory.add_item(&"turnip", 3)
	var saved: Dictionary = inventory.serialize()
	var restored = preload("res://scripts/domain/inventory_state.gd").new(1)
	restored.deserialize(saved)
	assert_eq(restored.capacity, 2)
	assert_eq(restored.get_quantity(&"turnip_seed"), 12)
	assert_eq(restored.get_quantity(&"turnip"), 3)

func test_inventory_changed_signal_emits_for_add_and_remove() -> void:
	watch_signals(inventory)
	inventory.add_item(&"turnip_seed", 1)
	inventory.remove_item(&"turnip_seed", 1)
	assert_signal_emit_count(inventory, "inventory_changed", 2)
