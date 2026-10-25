extends GutTest

func test_world_to_cell_handles_boundaries_and_negative_values() -> void:
	assert_eq(GridMath.world_to_cell(Vector3(0.999, 0.0, 0.999)), Vector2i(0, 0))
	assert_eq(GridMath.world_to_cell(Vector3(1.0, 0.0, 1.0)), Vector2i(1, 1))
	assert_eq(GridMath.world_to_cell(Vector3(-0.01, 0.0, -0.01)), Vector2i(-1, -1))

func test_cell_to_world_returns_cell_center() -> void:
	assert_eq(GridMath.cell_to_world(Vector2i(2, -3)), Vector3(2.5, 0.0, -2.5))

func test_rotated_footprint_keeps_all_cells_unique() -> void:
	var cells: Array[Vector2i] = GridMath.footprint_cells(Vector2i(4, 5), Vector2i(2, 3), 1)
	var unique_cells: Dictionary = {}
	for cell: Vector2i in cells:
		unique_cells[cell] = true
	assert_eq(cells.size(), 6)
	assert_eq(unique_cells.size(), 6)
	assert_has(cells, Vector2i(6, 5))
	assert_has(cells, Vector2i(4, 6))
