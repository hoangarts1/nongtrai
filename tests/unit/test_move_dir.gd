extends GutTest

func test_camera_relative_direction_is_normalized() -> void:
	# D33 replaces camera-yaw projection with screen axes; undo y compression to compare speed.
	var direction: Vector2 = Player.screen_direction(Vector2.ONE)
	assert_almost_eq(Vector2(direction.x, direction.y * 2).length(), 1.0, 0.00001)
	assert_lt(direction.length(), 1.0)
	assert_eq(Player.screen_direction(Vector2.ZERO),Vector2.ZERO)

func test_camera_relative_direction_uses_camera_basis() -> void:
	assert_eq(Player.screen_direction(Vector2(0,-1)),Vector2(0,-0.5))
	assert_eq(Player.screen_direction(Vector2.RIGHT),Vector2.RIGHT)
	assert_eq(Player.screen_direction(Vector2(0.25,0)),Vector2(0.25,0))
