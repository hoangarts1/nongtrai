## MachineBuildConfig — data-owned region for the first mouse-placement slice.
class_name MachineBuildConfig
extends Resource

@export var allowed_region: Rect2i

func is_valid(map_region: Rect2i) -> bool:
	return allowed_region.size.x > 0 and allowed_region.size.y > 0 and map_region.encloses(allowed_region)
