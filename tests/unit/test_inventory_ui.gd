extends GutTest

func before_each() -> void:
	GameClock._sleeping = false
	GameClock.paused = true
	GameClock.time_speed = 1.0
	GameClock.minute = GameClock.MORNING_MINUTE

func test_inventory_button_opens_and_closes_panel() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var panel: InventoryPanel = main.get_node("InventoryPanel")
	var bar = main.get_node("HudButtonBar")
	var button: Button = bar.get_button(&"inventory")
	assert_false(panel.visible)
	button.pressed.emit()
	assert_true(panel.visible)
	assert_true(button.button_pressed)
	button.pressed.emit()
	assert_false(panel.visible)
	assert_false(button.button_pressed)
	main.queue_free()

func test_inventory_button_is_disabled_while_sleeping() -> void:
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var bar = main.get_node("HudButtonBar")
	var button: Button = bar.get_button(&"inventory")
	GameClock.minute = 1200
	GameClock.try_sleep()
	await get_tree().process_frame
	assert_true(button.disabled)
	assert_false((main.get_node("InventoryPanel") as InventoryPanel).visible)
	GameClock._sleeping = false
	GameClock.time_speed = 1.0
	main.queue_free()
