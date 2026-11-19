## DogFollowRules — deterministic hysteresis and nearest reachable goal, no state owner.
class_name DogFollowRules
extends RefCounted

static func distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)

static func decide(config: DogConfig, navigation: DogNavigation, origin: Vector2i, player: Vector2i, following: bool = false) -> Dictionary:
	if config == null or not config.validation_errors().is_empty() or navigation == null or not config.world.player_region.has_point(player):
		return {"ok": false, "reason": &"invalid_follow_context"}
	if not navigation.is_walkable(origin): return {"ok": false, "reason": &"blocked_origin"}
	var gap: int = distance(origin, player)
	if gap <= config.follow_stop_distance or (not following and gap < config.follow_start_distance):
		return {"ok": true, "mode": &"idle", "following": false, "goal": origin, "path": [origin]}
	var component: Dictionary = navigation.reachable(origin)
	if not component.ok: return component
	var goal: Vector2i = origin
	var best_margin: int = maxi(0, gap - config.follow_stop_distance)
	var best_cost: int = 0
	for cell: Vector2i in component.cells:
		var margin: int = maxi(0, distance(cell, player) - config.follow_stop_distance)
		var cost: int = int(component.distances[cell])
		if margin < best_margin or (margin == best_margin and (cost < best_cost or (cost == best_cost and (cell.y < goal.y or (cell.y == goal.y and cell.x < goal.x))))):
			goal = cell
			best_margin = margin
			best_cost = cost
	var path: Array[Vector2i] = navigation.route(origin, goal)
	return {"ok": true, "mode": &"follow" if path.size() > 1 else &"wait", "following": true, "goal": goal, "path": path}

static func nearest_walkable(config: DogConfig, navigation: DogNavigation, desired: Vector2i) -> Dictionary:
	if config == null or not config.validation_errors().is_empty() or navigation == null: return {"ok": false, "reason": &"invalid_follow_context"}
	var found: bool = false
	var best: Vector2i = Vector2i.ZERO
	var best_distance: int = 0
	var region: Rect2i = config.world.player_region
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			var cell: Vector2i = Vector2i(x, y)
			if not navigation.is_walkable(cell): continue
			var gap: int = distance(cell, desired)
			if not found or gap < best_distance:
				found = true
				best = cell
				best_distance = gap
	return {"ok": true, "cell": best} if found else {"ok": false, "reason": &"no_dog_cell"}
