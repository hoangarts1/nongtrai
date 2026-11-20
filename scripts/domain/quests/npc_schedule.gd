## NpcSchedule — pure schedule resolution and obstacle-aware cell routing.
## API:
##   func destination(npc: NpcData, day: int, minute: int, season: StringName, rainy: bool) -> StringName
##   func route(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]
##   func set_dynamic_obstacles(regions: Array[Rect2i]) -> void
class_name NpcSchedule
extends RefCounted

var content: NpcWorldData
var _grid: AStarGrid2D = AStarGrid2D.new()
var _dynamic: Array[Rect2i] = []

func configure(data: NpcWorldData) -> void:
	content = data
	_grid.region = data.locations.nav_region
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_grid.update()
	_grid.fill_solid_region(_grid.region,false)
	var regions: Array[Rect2i] = data.locations.get_solid_regions()
	regions.append_array(_dynamic)
	for blocked: Rect2i in regions:
		var clipped: Rect2i = blocked.intersection(_grid.region)
		if clipped.has_area():
			_grid.fill_solid_region(clipped, true)

func set_dynamic_obstacles(regions: Array[Rect2i]) -> void:
	_dynamic.assign(regions)
	if content!=null:
		configure(content)

func destination(npc: NpcData, day: int, minute: int, season: StringName, rainy: bool, extra_visit: Dictionary = {}) -> StringName:
	var light: Dictionary = content.day_night_profile.sample(minute)
	if rainy or float(light.get("moon_energy", 0.0)) >= content.night_moon_energy:
		return npc.home_location
	if extra_visit.size() == 3 and (extra_visit.get("npc_id") is String or extra_visit.get("npc_id") is StringName) and (extra_visit.get("location_id") is String or extra_visit.get("location_id") is StringName) and DirectorActivityCodec.valid_integer(extra_visit.get("day_index")) and int(extra_visit.day_index) == day and String(extra_visit.npc_id) == String(npc.npc_id) and npc.is_merchant and content.locations.has_location(StringName(extra_visit.location_id)):
		for resource: Resource in npc.schedule:
			var entry: NpcScheduleEntry = resource as NpcScheduleEntry
			if entry != null and entry.location_id == StringName(extra_visit.location_id) and entry.applies_to(season, minute):
				return entry.location_id
	var weekday: int = posmod(day, content.days_per_week) + 1
	for resource: Resource in npc.schedule:
		var entry: NpcScheduleEntry = resource as NpcScheduleEntry
		if entry != null and entry.applies_to(season, minute) and (entry.weekdays.is_empty() or entry.weekdays.has(weekday)):
			return entry.location_id
	return npc.home_location

func location_cell(location_id: StringName) -> Vector2i:
	return GridMath.world_to_cell(content.locations.get_location_position(location_id))

func route(from_cell: Vector2i, to_cell: Vector2i) -> Array[Vector2i]:
	if not _grid.region.has_point(from_cell) or not _grid.region.has_point(to_cell):
		return []
	if _grid.is_point_solid(to_cell):
		return []
	if not _grid.is_point_solid(from_cell): return _grid.get_id_path(from_cell,to_cell)
	# A valid legacy actor can start inside a newly derived one-cell prop/machine.
	# Permit that starting cell only; fixed/water and multi-cell blockers stay closed.
	for fixed: Rect2i in content.locations.get_solid_regions():
		if fixed.has_point(from_cell): return []
	for dynamic: Rect2i in _dynamic:
		if dynamic.has_point(from_cell) and dynamic.size!=Vector2i.ONE: return []
	_grid.set_point_solid(from_cell,false)
	var path: Array[Vector2i] = _grid.get_id_path(from_cell,to_cell)
	_grid.set_point_solid(from_cell,true)
	return path
