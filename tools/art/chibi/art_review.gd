## ChibiArtReview — deterministic contact-sheet layout used by the review runner.
## API:
##   static func tile_origin(view_index: int, night: bool, tile_size: int) -> Vector2i
##   static func sheet_size(tile_size: int) -> Vector2i
class_name ChibiArtReview
extends RefCounted

const ANGLE_COUNT: int = 4
const LIGHTING_COUNT: int = 2

static func tile_origin(view_index: int, night: bool, tile_size: int) -> Vector2i:
	return Vector2i(clampi(view_index, 0, ANGLE_COUNT - 1) * tile_size, (1 if night else 0) * tile_size)

static func sheet_size(tile_size: int) -> Vector2i:
	return Vector2i(ANGLE_COUNT * tile_size, LIGHTING_COUNT * tile_size)
