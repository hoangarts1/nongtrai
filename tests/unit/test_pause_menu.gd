extends GutTest

func after_each() -> void:
	GameClock.paused = false
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func test_pause_menu_stops_clock_and_locks_player() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var pause_menu: PanelContainer = main.get_node("PauseMenu")
	pause_menu.open()
	assert_true(pause_menu.visible)
	assert_true(GameClock.paused)
	assert_false(main.world.player.movement_enabled)
	pause_menu.close()
	assert_false(GameClock.paused)
	assert_true(main.world.player.movement_enabled)
	main.queue_free()

func test_save_service_round_trips_profile_and_corrupt_save_is_empty() -> void:
	var payload: Dictionary = {"profile": {"player_name": "An", "farm_name": "Mùa"}}
	assert_true(SaveService.save_game(payload, 1))
	var loaded: Dictionary = SaveService.load_game(1)
	assert_eq(loaded["profile"]["player_name"], "An")
	var path: String = ProjectSettings.globalize_path("user://saves/slot_1.json")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	assert_true(SaveService.load_game(1).is_empty())
