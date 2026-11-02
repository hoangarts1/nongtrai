extends GutTest

func test_weather_is_seeded_and_serializes_forecast() -> void:
	var weather: Object = preload("res://scripts/domain/weather_state.gd").new()
	weather.call("configure", preload("res://data/weather_profile.tres"), 42)
	var first: Array = weather.get("forecast").duplicate()
	var payload: Dictionary = weather.call("serialize")
	var restored: Object = preload("res://scripts/domain/weather_state.gd").new()
	restored.call("configure", preload("res://data/weather_profile.tres"), 0)
	restored.call("deserialize", payload)
	assert_eq(restored.get("forecast"), first)
	assert_eq(restored.get("today"), weather.get("today"))

func test_rain_waters_all_planted_crops() -> void:
	var farm: FarmGridState = preload("res://scripts/domain/farm_grid_state.gd").new()
	assert_true(farm.till_cell(Vector2i(0, 0)))
	assert_true(farm.plant_crop(Vector2i(0, 0), &"turnip"))
	farm.water_all_crops()
	assert_true(bool(farm.get_plot(Vector2i(0, 0)).get("watered", false)))

func test_weather_hud_and_rain_fx_are_inside_world_and_update() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(main)
	main.set("_game_started", true)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	await get_tree().process_frame
	var weather: Object = main.weather_state
	weather.call("force_weather", &"rain")
	await get_tree().process_frame
	var hud: Label = main.get_node("WeatherHud") as Label
	var rain: Node2D = main.get_node("GrayBoxWorld/WorldCanvas/WeatherFx/RainParticles") as Node2D
	assert_true(hud.visible)
	assert_true(hud.text.contains("Mưa"))
	assert_true(rain.visible)
	main.queue_free()

func test_v1_save_migrates_with_empty_weather_payload() -> void:
	var save: Dictionary = {
		"meta": {"save_version": 1},
		"clock": {"day_index": 0, "minute": 360}
	}
	var path: String = "user://saves/slot_98.json"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save))
	file.close()
	var loaded: Dictionary = SaveService.load_game(98)
	assert_eq(int((loaded["meta"] as Dictionary)["save_version"]), 4)
	assert_true((loaded["weather"] as Dictionary).is_empty())
	SaveService.delete_save(98)
