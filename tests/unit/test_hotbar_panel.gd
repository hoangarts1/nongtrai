extends GutTest

func test_hotbar_reflects_inventory_and_selects_existing_slot() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var inventory = main.inventory
	inventory.add_item(&"turnip_seed", 5)
	await get_tree().process_frame
	var hotbar: HotbarPanel = main.get_node("HotbarPanel")
	assert_eq(hotbar.get_selected_slot(), {})
	var first_slot: Button = hotbar.get_node("MarginContainer/HBoxContainer").get_child(0) as Button
	first_slot.pressed.emit()
	assert_eq(hotbar.get_selected_slot()["item_id"], &"turnip_seed")
	assert_eq(inventory.get_quantity(&"turnip_seed"), 5)
	main.queue_free()

func test_hotbar_empty_slot_does_not_change_selection() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var hotbar: HotbarPanel = main.get_node("HotbarPanel")
	var empty_slot: Button = hotbar.get_node("MarginContainer/HBoxContainer").get_child(0) as Button
	empty_slot.pressed.emit()
	assert_eq(hotbar.get_selected_slot(), {})
	main.queue_free()
