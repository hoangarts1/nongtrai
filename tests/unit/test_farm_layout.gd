extends GutTest

const VIEWPORT_SIZES: Array[Vector2i] = [
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1920, 1080)
]

func test_grid_cells_fit_farm_plot_and_project_clear_of_ui_and_house() -> void:
	var scene: Node = preload("res://scenes/world/gray_box_world.tscn").instantiate()
	get_tree().root.add_child(scene)
	await get_tree().process_frame
	var farm_view: FarmView = scene.get_node("FarmView")
	var farm_plot: MeshInstance3D = scene.get_node("FarmPlot")
	var farm_bounds: AABB = farm_plot.get_aabb()
	for cell: Vector2i in _all_cells(farm_view.grid_size):
		var center: Vector3 = farm_view.get_cell_view(cell).global_position
		assert_true(farm_bounds.has_point(farm_plot.to_local(center)), "Cell outside FarmPlot: %s" % cell)
	var house: MeshInstance3D = scene.get_node("House")
	for viewport_size: Vector2i in VIEWPORT_SIZES:
		get_tree().root.size = viewport_size
		get_viewport().size = viewport_size
		await get_tree().process_frame
		var camera: Camera3D = scene.get_node("CameraRig/Camera")
		var ui_rects: Array[Rect2] = [
			Rect2(Vector2(0, 0), Vector2(viewport_size.x, 52)),
			Rect2(Vector2(0, viewport_size.y - 156), Vector2(viewport_size.x, 156)),
			Rect2(Vector2(viewport_size.x - 220, viewport_size.y - 100), Vector2(220, 100))
		]
		var house_screen_rect: Rect2 = _project_aabb(camera, house)
		for cell: Vector2i in _all_cells(farm_view.grid_size):
			var screen: Vector2 = camera.unproject_position(farm_view.get_cell_view(cell).global_position)
			assert_true(Rect2(Vector2.ZERO, Vector2(viewport_size)).has_point(screen), "Cell off-screen: %s at %s" % [cell, viewport_size])
			for ui_rect: Rect2 in ui_rects:
				assert_false(ui_rect.has_point(screen), "Cell under UI: %s at %s" % [cell, viewport_size])
			assert_false(house_screen_rect.has_point(screen), "Cell under House: %s at %s" % [cell, viewport_size])
	scene.queue_free()

func _all_cells(size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for z: int in range(size.y):
		for x: int in range(size.x):
			cells.append(Vector2i(x, z))
	return cells

func _project_aabb(camera: Camera3D, mesh: MeshInstance3D) -> Rect2:
	var local_aabb: AABB = mesh.get_aabb()
	var points: Array[Vector2] = []
	for x: float in [local_aabb.position.x, local_aabb.end.x]:
		for y: float in [local_aabb.position.y, local_aabb.end.y]:
			for z: float in [local_aabb.position.z, local_aabb.end.z]:
				points.append(camera.unproject_position(mesh.to_global(Vector3(x, y, z))))
	var rect: Rect2 = Rect2(points[0], Vector2.ZERO)
	for point: Vector2 in points:
		rect = rect.expand(point)
	return rect
