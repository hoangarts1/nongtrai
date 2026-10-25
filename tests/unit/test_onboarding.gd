extends GutTest

func after_each() -> void:
	Settings.set_tutorial_dismissed(false)

func test_help_action_and_tutorial_use_input_map_bindings() -> void:
	assert_true(InputMap.has_action(&"open_help"))
	var scene: PackedScene = preload("res://scenes/main/main.tscn")
	var main: Node = scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var tutorial: Control = main.get_node("TutorialPanel")
	assert_true(tutorial.visible)
	var instructions: Label = tutorial.get_node("MarginContainer/VBoxContainer/Instructions")
	assert_true(instructions.text.contains("W"))
	assert_true(instructions.text.contains("I"))
	assert_true(instructions.text.contains("Space hoặc chuột trái"))
	assert_false(instructions.text.contains("Physical"))
	var check: CheckButton = tutorial.get_node("MarginContainer/VBoxContainer/DoNotShowAgain")
	check.button_pressed = true
	tutorial.call("close_help")
	assert_false(tutorial.visible)
	assert_true(Settings.is_tutorial_dismissed())
	main.queue_free()

func test_farming_quest_steps_follow_domain_events_and_serialize() -> void:
	var quest = preload("res://scripts/domain/tutorial_quest_state.gd").new()
	Events.plot_tilled.emit(Vector2i(0, 0))
	Events.crop_planted.emit(Vector2i(0, 0), &"turnip")
	Events.plot_watered.emit(Vector2i(0, 0))
	GameClock.sleep_finished.emit(1)
	Events.crop_harvested.emit(Vector2i(0, 0), &"turnip", 1, 1)
	assert_true(quest.is_complete())
	var restored = preload("res://scripts/domain/tutorial_quest_state.gd").new()
	restored.deserialize(quest.serialize())
	assert_true(restored.is_complete())
