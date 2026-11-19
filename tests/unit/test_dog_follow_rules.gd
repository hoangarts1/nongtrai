extends GutTest
const CONFIG: DogConfig = preload("res://data/dog_config.tres")

func test_hysteresis_goal_distance_and_deterministic_readonly_plan() -> void:
	var nav: DogNavigation = DogNavigation.new()
	assert_true(nav.configure(CONFIG))
	var origin: Vector2i = Vector2i(-10, -10)
	assert_eq(DogFollowRules.decide(CONFIG, nav, origin, origin + Vector2i(2, 0)).mode, &"idle")
	var state: Dictionary = nav.serialize()
	var first: Dictionary = DogFollowRules.decide(CONFIG, nav, origin, origin + Vector2i(4, 0))
	assert_eq(first.mode, &"follow")
	assert_eq(DogFollowRules.distance(first.goal, origin + Vector2i(4, 0)), 1)
	assert_eq(first.path.front(), origin)
	assert_eq(DogFollowRules.decide(CONFIG, nav, origin, origin + Vector2i(2, 0), true).mode, &"follow")
	assert_eq(DogFollowRules.decide(CONFIG, nav, origin, origin + Vector2i(1, 0), true).mode, &"idle")
	for _index: int in range(10): assert_eq(DogFollowRules.decide(CONFIG, nav, origin, origin + Vector2i(4, 0)), first)
	assert_eq(nav.serialize(), state)

func test_unreachable_target_waits_on_its_component_and_recovers_after_opening() -> void:
	var nav: DogNavigation = DogNavigation.new()
	var wall: Array[Rect2i] = [Rect2i(0, -18, 1, 39)]
	assert_true(nav.configure(CONFIG, wall))
	var origin: Vector2i = Vector2i(-1, -10)
	var player: Vector2i = Vector2i(4, -10)
	var waiting: Dictionary = DogFollowRules.decide(CONFIG, nav, origin, player, true)
	assert_eq(waiting.mode, &"wait")
	assert_eq(waiting.goal, origin)
	wall.clear()
	assert_true(nav.set_dynamic_obstacles(wall))
	assert_eq(DogFollowRules.decide(CONFIG, nav, origin, player, true).mode, &"follow")
	assert_false(DogFollowRules.decide(CONFIG, nav, Vector2i.ZERO, player).ok)
	assert_false(DogFollowRules.decide(CONFIG, nav, origin, Vector2i(999, 999)).ok)
