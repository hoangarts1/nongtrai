extends GutTest

func test_player_position_near_house_can_interact() -> void:
	var player_position: Vector2 = Vector2(11, 8)
	var house_position: Vector2 = Vector2(11, 10)
	assert_true(GrayBoxWorld.is_player_near_interactable(player_position, house_position, 2.5))

func test_player_position_far_from_house_cannot_interact() -> void:
	var player_position: Vector2 = Vector2(0, 0)
	var house_position: Vector2 = Vector2(11, 10)
	assert_false(GrayBoxWorld.is_player_near_interactable(player_position, house_position, 2.5))

func test_prompt_is_visible_with_text_near_house_and_hidden_when_far() -> void:
	GameClock.set_time(20, 0)
	TranslationServer.set_locale("vi")
	var world: GrayBoxWorld = preload("res://scenes/world/gray_box_world.tscn").instantiate()
	get_tree().root.add_child(world)
	await get_tree().process_frame
	var prompt: InteractionPrompt = world.get_node("InteractionLayer/InteractionPrompt")
	world.player.move_to_cell(Vector2i(11, 8))
	await get_tree().process_frame
	assert_true(prompt.visible)
	assert_eq(prompt.message_label.text, "[E] Ngủ")
	world.player.move_to_cell(Vector2i(0, 0))
	await get_tree().process_frame
	assert_false(prompt.visible)
	world.queue_free()

func test_daytime_interaction_has_no_prompt_and_does_not_start_sleep() -> void:
	GameClock.set_time(12, 0)
	var world: GrayBoxWorld = preload("res://scenes/world/gray_box_world.tscn").instantiate()
	get_tree().root.add_child(world)
	await get_tree().process_frame
	world.player.move_to_cell(Vector2i(11, 8))
	await get_tree().process_frame
	var prompt: InteractionPrompt = world.get_node("InteractionLayer/InteractionPrompt")
	assert_false(prompt.visible)
	assert_false(GameClock.is_sleeping())
	world.queue_free()

func test_sleep_locks_player_until_next_morning() -> void:
	GameClock.set_time(20, 0)
	var world: GrayBoxWorld = preload("res://scenes/world/gray_box_world.tscn").instantiate()
	get_tree().root.add_child(world)
	await get_tree().process_frame
	world.player.move_to_cell(Vector2i(11, 8))
	assert_true(GameClock.try_sleep())
	await get_tree().process_frame
	assert_false(world.player.movement_enabled)
	assert_eq(world.get_node("InteractionLayer/InteractionPrompt").message_label.text, "Đang ngủ...")
	GameClock.advance_minutes(600)
	await get_tree().process_frame
	assert_true(world.player.movement_enabled)
	assert_eq(GameClock.day_index, 1)
	world.queue_free()
