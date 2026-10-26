extends GutTest

func test_profile_is_smooth_and_wraps_midnight() -> void:
	var profile: Resource = preload("res://data/day_night_profile.tres")
	var noon: Dictionary = profile.call("sample", 720)
	var sunset: Dictionary = profile.call("sample", 1110)
	var night: Dictionary = profile.call("sample", 1320)
	assert_true(float(noon["sun_energy"]) > float(sunset["sun_energy"]))
	assert_true(float(sunset["sun_energy"]) > float(night["sun_energy"]))
	var before_midnight: float = float(profile.call("sample", 1439)["sun_energy"])
	var after_midnight: float = float(profile.call("sample", 0)["sun_energy"])
	assert_true(absf(before_midnight - after_midnight) < 0.02)
	for minute: int in range(0, 1440, 2):
		var first: float = float(profile.call("sample", minute)["sun_energy"])
		var second: float = float(profile.call("sample", minute + 1)["sun_energy"])
		assert_true(absf(first - second) < 0.03)

func test_world_applies_lighting_and_house_light_from_clock() -> void:
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var world: GrayBoxWorld = main.get_node("GrayBoxWorld") as GrayBoxWorld
	GameClock.set_time(12, 0)
	assert_true(world.sun.light_energy > 1.0)
	assert_false(world.house_light.visible)
	GameClock.set_time(22, 0)
	assert_true(world.moon.light_energy > 0.0)
	assert_true(world.house_light.visible)
	main.queue_free()
