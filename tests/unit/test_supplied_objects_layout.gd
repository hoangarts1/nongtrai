extends GutTest

func test_object_sorting_locales_zoom_day_night_and_rain_render_only_actual_world_state() -> void:
	var clock: Dictionary = GameClock.serialize()
	var paused: bool = GameClock.paused
	var locale_before: String = TranslationServer.get_locale()
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.call("_start_new_game", "Mai", "Garden")
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	GameClock.paused = true
	await _settle()
	var subject: Node2D
	for node: Node in main.presentation.get_world_art_root().get_children():
		if node.get_meta("asset_id", &"") == &"tree_fruit" and node.visible:
			subject = node as Node2D
			break
	assert_not_null(subject)
	var tree_cell: Vector2i = subject.get_meta("cell")
	main.world.player.move_to_cell(tree_cell+Vector2i(1,0))
	await _settle()
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152,648), Vector2i(1280,720), Vector2i(1920,1080)]:
			viewport.size = size
			GameClock.set_time(12, 0)
			main.weather_state.force_weather(&"sunny")
			await _settle()
			for step: int in range(5): await _key(viewport, KEY_MINUS)
			for index: int in range(main.world.CONFIG.zoom_levels.size()):
				var before: Dictionary = _owners(main)
				assert_almost_eq(main.world.camera.zoom.x, float(main.world.CONFIG.zoom_levels[index]), 0.0001)
				for node: Node in main.presentation.get_world_art_root().get_children():
					if node.get_meta("passive_tree", false):
						var cell: Vector2i = node.get_meta("cell")
						assert_eq(node.global_position, main.world.grid.cell_to_global(cell))
						assert_eq(main.world.grid.screen_to_cell(main.world.grid.cell_to_screen(cell)), cell)
						assert_eq(node.z_index, 0)
				assert_true(main.world.objects.y_sort_enabled)
				assert_true(main.presentation.get_world_art_root().y_sort_enabled)
				assert_gt(main.world.player.global_position.y, subject.global_position.y)
				await _capture(viewport, "%s_%d_zoom%d_day" % [locale,size.x,index])
				assert_eq(_owners(main), before)
				if index < main.world.CONFIG.zoom_levels.size()-1: await _key(viewport, KEY_EQUAL)
			for condition: String in ["night", "rain"]:
				GameClock.set_time(22 if condition=="night" else 12, 0)
				main.weather_state.force_weather(&"rain" if condition=="rain" else &"sunny")
				await _settle()
				var before: Dictionary = _owners(main)
				await _capture(viewport, "%s_%d_%s" % [locale,size.x,condition])
				assert_eq(_owners(main), before)
	GameClock.set_time(12, 0)
	main.weather_state.force_weather(&"sunny")
	viewport.size = Vector2i(1152,648)
	for side: int in [-1, 1]:
		# Keep x aligned and use a fraction of an adapter-projected neighbour so
		# the actual avatar overlaps the trunk/canopy in both sort-order probes.
		var neighbour: Vector2 = main.world.grid.cell_to_global(tree_cell+Vector2i(side,side))
		main.world.player.global_position = subject.global_position.lerp(neighbour, 0.25)
		await _settle()
		assert_eq(signf(main.world.player.global_position.y-subject.global_position.y), float(side))
		await _capture(viewport, "sort_%d" % side)
	viewport.free()
	TranslationServer.set_locale(locale_before)
	GameClock.deserialize(clock)
	GameClock.paused = paused
	SaveService.delete_save(1)

func _owners(main: Node) -> Dictionary:
	return {"clock":GameClock.serialize(), "farm":main.farm_state.serialize(), "bag":main.inventory.serialize(), "wallet":main.wallet.serialize(), "water":main.watering_can.serialize(), "coop":main.chicken_coop.serialize(), "weather":main.weather_state.serialize(), "ledger":main.day_end_flow.ledger.serialize(), "stock":main.machine_inventory.serialize(), "placements":main.machine_placements.serialize(), "jobs":main.machine_operations.serialize(), "land":main.land_ownership.serialize(), "social":main.npc_system.state.serialize()}

func _capture(viewport: SubViewport, suffix: String) -> void:
	if DisplayServer.get_name() != "headless":
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_post_draw
		assert_eq(viewport.get_texture().get_image().save_png("user://audit_f6_%s.png" % suffix), OK)

func _key(viewport: SubViewport, code: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		viewport.push_input(event, true)
		await get_tree().process_frame
	await _settle()

func _settle() -> void:
	for frame: int in range(5): await get_tree().process_frame
