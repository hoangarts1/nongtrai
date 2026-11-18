extends GutTest

func test_real_decor_matrix_keeps_ground_picking_owners_and_camera_controls_at_five_zooms() -> void:
	var clock: Dictionary = GameClock.serialize()
	var paused: bool = GameClock.paused
	var locale_before: String = TranslationServer.get_locale()
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1152, 648)
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
	var before: Dictionary = _owners(main)
	for locale: String in ["vi", "en"]:
		TranslationServer.set_locale(locale)
		for size: Vector2i in [Vector2i(1152,648), Vector2i(1280,720), Vector2i(1920,1080)]:
			viewport.size = size
			await _settle()
			for step: int in range(5): await _key(viewport, KEY_MINUS)
			for index: int in range(main.world.CONFIG.zoom_levels.size()):
				assert_almost_eq(main.world.camera.zoom.x, float(main.world.CONFIG.zoom_levels[index]), 0.0001)
				for node: Node in main.presentation.get_world_art_root().get_children():
					if node is SuppliedSceneryView:
						var cell: Vector2i = node.get_meta("cell")
						assert_eq(main.world.grid.screen_to_cell(main.world.grid.cell_to_screen(cell)), cell)
						assert_eq(node.global_position, main.world.grid.cell_to_global(cell))
				assert_true(main.presentation.get_world_art_root().y_sort_enabled)
				if DisplayServer.get_name() != "headless":
					viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
					await RenderingServer.frame_post_draw
					assert_eq(viewport.get_texture().get_image().save_png("user://audit_f5_%s_%d_zoom%d.png" % [locale,size.x,index]), OK)
				if index < main.world.CONFIG.zoom_levels.size()-1: await _key(viewport, KEY_EQUAL)
	assert_eq(_owners(main), before)
	viewport.free()
	TranslationServer.set_locale(locale_before)
	GameClock.deserialize(clock)
	GameClock.paused = paused
	SaveService.delete_save(1)

func _owners(main: Node) -> Dictionary:
	return {"clock":GameClock.serialize(), "farm":main.farm_state.serialize(), "bag":main.inventory.serialize(), "wallet":main.wallet.serialize(), "water":main.watering_can.serialize(), "coop":main.chicken_coop.serialize(), "weather":main.weather_state.serialize(), "stock":main.machine_inventory.serialize(), "placements":main.machine_placements.serialize(), "jobs":main.machine_operations.serialize(), "land":main.land_ownership.serialize(), "social":main.npc_system.state.serialize()}

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
	for frame: int in range(4): await get_tree().process_frame
