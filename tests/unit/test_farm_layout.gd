extends GutTest

const VIEWPORT_SIZES: Array[Vector2i] = [Vector2i(1152,648),Vector2i(1280,720),Vector2i(1920,1080)]
func test_grid_cells_fit_farm_plot_and_project_clear_of_ui_and_house() -> void:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = VIEWPORT_SIZES[0]
	viewport.world_2d = World2D.new()
	add_child_autofree(viewport)
	var main: Node = preload("res://scenes/main/main.tscn").instantiate()
	viewport.add_child(main)
	main.start_menu.hide()
	main.tutorial_panel.close_help()
	main.ui_coordinator.close_active()
	await get_tree().process_frame
	for dimensions: Vector2i in VIEWPORT_SIZES:
		viewport.size = dimensions
		main.world.camera.force_update_scroll()
		await get_tree().process_frame
		await get_tree().process_frame
		var house: Node2D = main.world.objects.get_node("House")
		var house_rect: Rect2 = Rect2(house.get_global_transform_with_canvas() * Vector2(-40,-83),Vector2(80,83)*main.world.camera.zoom)
		for y: int in range(6):
			for x: int in range(6):
				var cell: Vector2i = Vector2i(x,y)
				assert_eq(main.farm_view.get_cell_view(cell).global_position,main.world.cell_to_global(cell))
				var point: Vector2 = main.world.grid.cell_to_screen(cell)
				assert_true(Rect2(Vector2.ZERO,Vector2(dimensions)).has_point(point),"Farm cell stays on screen at %s" % dimensions)
				assert_false(house_rect.has_point(point),"Farm cell is not under a building")
				for control: Control in [main.hotbar_panel,main.hud_button_bar,main.quest_panel,main.get_node("ClockHud")]:
					if control.visible:
						assert_false(control.get_global_rect().has_point(point),"Farm cell is not hidden by %s" % control.name)
