extends GutTest

func test_camera_relative_direction_is_normalized() -> void:
	var direction: Vector3 = Player.camera_relative_direction(Vector2.ONE, Basis.IDENTITY)
	assert_almost_eq(direction.length(), 1.0, 0.0001)

func test_camera_relative_direction_uses_camera_basis() -> void:
	var direction: Vector3 = Player.camera_relative_direction(Vector2(0.0, -1.0), Basis.IDENTITY)
	assert_eq(direction, Vector3(0.0, 0.0, -1.0))
