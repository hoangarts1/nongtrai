extends GutTest

const VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1920, 1080)
]

func test_hud_regions_are_inside_viewport_and_do_not_overlap() -> void:
	var main_scene: PackedScene = preload("res://scenes/main/main.tscn")
	for viewport_size: Vector2i in VIEWPORT_SIZES:
		get_tree().root.size = viewport_size
		get_viewport().size = viewport_size
		var main: Node = main_scene.instantiate()
		get_tree().root.add_child(main)
		await get_tree().process_frame
		var debug_menu: Control = main.get_node("DebugMenu")
		var inventory: Control = main.get_node("InventoryPanel")
		var hotbar: Control = main.get_node("HotbarPanel")
		var button_bar: Control = main.get_node("HudButtonBar")
		var clock: Control = main.get_node("ClockHud")
		var weather: Control = main.get_node("WeatherHud")
		var prompt: Control = main.get_node("GrayBoxWorld/InteractionLayer/InteractionPrompt")
		debug_menu.visible = true
		inventory.visible = false
		prompt.visible = true
		var tutorial: Control = main.get_node("TutorialPanel")
		var quest: Control = main.get_node("QuestPanel")
		tutorial.visible = true
		quest.visible = false
		var controls: Array[Control] = []
		controls.append(clock)
		controls.append(weather)
		controls.append(debug_menu)
		controls.append(inventory)
		controls.append(hotbar)
		controls.append(button_bar)
		controls.append(prompt)
		controls.append(tutorial)
		for control: Control in controls:
			var rect: Rect2 = control.get_global_rect()
			assert_true(Rect2(Vector2.ZERO, Vector2(viewport_size)).encloses(rect), "Outside viewport at %s: %s %s" % [viewport_size, control.name, rect])
		var pairs: Array[Array] = [
			[clock, debug_menu], [clock, inventory], [debug_menu, inventory],
			[clock, weather], [clock, tutorial], [debug_menu, tutorial],
			[debug_menu, hotbar], [debug_menu, button_bar], [inventory, hotbar],
			[inventory, button_bar], [hotbar, button_bar], [prompt, hotbar],
			[tutorial, hotbar], [tutorial, button_bar]
		]
		for pair: Array in pairs:
			assert_false(pair[0].get_global_rect().intersects(pair[1].get_global_rect()), "Overlap at %s: %s %s / %s %s" % [viewport_size, pair[0].name, pair[0].get_global_rect(), pair[1].name, pair[1].get_global_rect()])
		main.queue_free()
