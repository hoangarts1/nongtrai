## WaterSourceConfig — shared static source geometry/presentation, independent of Nodes.
class_name WaterSourceConfig
extends Resource

@export var world: IsometricWorldConfig
@export var sources: Array[WaterSourceData] = []
@export var clearance_cells: int = 1
@export var water_color: Color = Color("62abc4")
@export var shore_color: Color = Color("b8bd83")
@export var path_color: Color = Color("b49c72")
@export var well_color: Color = Color("9c947e")

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if world==null or not _positive(world.map_region) or not _positive(world.player_region) or not world.map_region.encloses(world.player_region):
		return PackedStringArray(["water sources require valid nested world/player regions"])
	if clearance_cells<0 or clearance_cells>mini(world.player_region.size.x,world.player_region.size.y):
		errors.append("water source clearance must fit the playable region")
	if sources.is_empty():
		errors.append("water sources are required")
	var ids: Dictionary = {}
	var pattern: RegEx = RegEx.new()
	pattern.compile("^[a-z][a-z0-9_]*$")
	for source: WaterSourceData in sources:
		if source==null:
			errors.append("water source is missing")
			continue
		if pattern.search(String(source.source_id))==null or ids.has(source.source_id):
			errors.append("water source IDs must be unique snake_case")
		ids[source.source_id] = true
		if source.kind not in [&"well",&"stream",&"pond"] or source.display_name_key.is_empty():
			errors.append("water source kind/name is invalid")
		if not _positive(source.region) or not world.player_region.encloses(source.region):
			errors.append("water source must be positive and inside playable bounds")
		if source.kind==&"well" and source.region.size!=Vector2i.ONE:
			errors.append("well footprint must occupy one cell")
		if _positive(source.region) and not source.region.has_point(source.label_cell):
			errors.append("water source label must stay on its source")
		if source.access_waypoints.is_empty():
			errors.append("water source requires a dry approach")
		for index: int in range(source.access_waypoints.size()):
			var point: Vector2i = source.access_waypoints[index]
			if not world.player_region.has_point(point):
				errors.append("water source approach is outside playable bounds")
			if index>0:
				var delta: Vector2i = point-source.access_waypoints[index-1]
				if delta.x!=0 and delta.y!=0:
					errors.append("water source approach segments must be orthogonal")
	return errors

func get_blocked_regions() -> Array[Rect2i]:
	var result: Array[Rect2i] = []
	for source: WaterSourceData in sources:
		if source!=null and _positive(source.region) and not result.has(source.region):
			result.append(source.region)
	return result

func _positive(region: Rect2i) -> bool:
	return region.size.x>0 and region.size.y>0
