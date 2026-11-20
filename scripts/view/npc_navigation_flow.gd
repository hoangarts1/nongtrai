## NpcNavigationFlow - derived VIEW cache, never positions/history/day simulation.
## API: configure(main,system,extra); set_extra(regions); refresh(); advance(delta).
class_name NpcNavigationFlow
extends RefCounted
var _main: Node
var _system: NpcSystem
var _extra: Array[Rect2i] = []
var _last: Array[Rect2i] = []
var _elapsed: float = 0.0

func configure(main: Node, system: NpcSystem, extra: Array[Rect2i]) -> void:
	_main = main
	_system = system
	_extra.assign(extra)
	main.machine_presentation.refreshed.connect(refresh)
	main.clearing_runtime.cleared.connect(_cleared)
	main.land_runtime.purchased.connect(_purchased)
	refresh()

func advance(delta: float) -> void:
	_elapsed += maxf(0.0,delta)
	if _elapsed>=_system.content.navigation_poll_seconds:
		_elapsed = 0.0
		refresh()

func set_extra(regions: Array[Rect2i]) -> void:
	_extra.assign(regions)
	refresh()

func refresh() -> void:
	if not is_instance_valid(_main) or not is_instance_valid(_system) or _main.is_queued_for_deletion() or not is_instance_valid(_main.presentation) or _system.state.is_busy(): return
	var regions: Array[Rect2i] = _main.presentation.get_navigation_blockers()
	for row: Dictionary in _main.machine_placements.get_all_placements():
		var region: Rect2i = Rect2i(row.cell,MachinePlacementState.MACHINE_SIZE)
		if not regions.has(region): regions.append(region)
	for region: Rect2i in _extra:
		if not regions.has(region): regions.append(region)
	regions.sort_custom(func(a: Rect2i, b: Rect2i) -> bool:
		for pair: Vector2i in [Vector2i(a.position.y,b.position.y),Vector2i(a.position.x,b.position.x),Vector2i(a.size.x,b.size.x),Vector2i(a.size.y,b.size.y)]:
			if pair.x!=pair.y: return pair.x<pair.y
		return false)
	if regions==_last: return
	_last.assign(regions)
	_system.state.scheduler.set_dynamic_obstacles(regions)
	_system.state.refresh_routes()

func _cleared(_cell: Vector2i, _id: StringName, _count: int) -> void:
	refresh()

func _purchased(_id: StringName) -> void:
	refresh()
