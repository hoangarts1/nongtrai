extends GutTest

var _backup_snapshots: Dictionary = {}

func before_each() -> void:
	_isolate_backups()

func after_each() -> void:
	_restore_backups()
	GameClock.paused = false
	SaveService.delete_save(0)
	SaveService.delete_save(1)

func test_pause_menu_stops_clock_and_locks_player() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	# Exercise a running game; a title screen must keep movement locked after closing.
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = false
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

func test_latest_save_chooses_newer_slot() -> void:
	SaveService.save_game({"profile": {"farm_name": "Cu"}, "clock": {"day_index": 1}}, 0)
	await get_tree().create_timer(0.01).timeout
	SaveService.save_game({"profile": {"farm_name": "Moi"}, "clock": {"day_index": 2}}, 1)
	assert_eq(SaveService.load_latest()["profile"]["farm_name"], "Moi")
	await get_tree().create_timer(1.1).timeout
	SaveService.save_game({"profile": {"farm_name": "Cu moi"}, "clock": {"day_index": 3}}, 0)
	assert_eq(SaveService.load_latest()["profile"]["farm_name"], "Cu moi")

func test_main_close_request_saves_started_game_but_not_start_screen() -> void:
	SaveService.delete_save(1)
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	main.call("_save_before_exit")
	assert_true(SaveService.load_game(1).is_empty())
	main.call("_start_new_game", "An", "Ruộng")
	main.call("_save_before_exit")
	assert_false(SaveService.load_game(1).is_empty())
	main.queue_free()

# Corruption without a usable backup must not inherit another test's recovery files.
func _isolate_backups() -> void:
	for slot: int in [0, 1]:
		for index: int in range(1, SaveService.MAX_BACKUPS + 1):
			var path: String = "%s/slot_%d.json.bak%d" % [SaveService.SAVE_DIRECTORY, slot, index]
			_backup_snapshots[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
			if FileAccess.file_exists(path):
				assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)

func _restore_backups() -> void:
	for path: String in _backup_snapshots:
		if FileAccess.file_exists(path):
			assert_eq(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)), OK)
		var bytes: Variant = _backup_snapshots[path]
		if bytes is PackedByteArray:
			var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
			assert_not_null(file)
			file.store_buffer(bytes)
			file.close()
	_backup_snapshots.clear()
