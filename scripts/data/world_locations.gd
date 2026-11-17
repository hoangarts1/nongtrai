## WorldLocations — named world positions and the walkable navigation grid for NPCs.
## API:
##   func get_solid_regions() -> Array[Rect2i]
##   func has_location(location_id: StringName) -> bool
##   func get_location_position(location_id: StringName) -> Vector3
class_name WorldLocations
extends Resource

## StringName -> Vector3 (y is ignored; NPCs walk on the ground plane).
@export var locations: Dictionary = {}
## Cell region (GridMath cells) used by AStarGrid2D.
@export var nav_region: Rect2i = Rect2i(-12, -12, 24, 24)
## Blocked cell rectangles (buildings, farm plot, props).
@export var solid_rects: Array[Rect2i] = []
@export var water_sources: WaterSourceConfig

func get_solid_regions() -> Array[Rect2i]:
	var result: Array[Rect2i] = []
	for region: Rect2i in solid_rects:
		if not result.has(region):
			result.append(region)
	if water_sources!=null:
		for region: Rect2i in water_sources.get_blocked_regions():
			if not result.has(region):
				result.append(region)
	return result

func has_location(location_id: StringName) -> bool:
	return locations.has(location_id)

func get_location_position(location_id: StringName) -> Vector3:
	var value: Variant = locations.get(location_id, Vector3.ZERO)
	var position: Vector3 = value if value is Vector3 else Vector3.ZERO
	return Vector3(position.x, 0.0, position.z)
