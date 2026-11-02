## IsometricGrid — view-only TileMapLayer adapter; no gameplay state or projection formula.
## API:
##   func cell_to_global(cell: Vector2i) -> Vector2
##   func global_to_cell(point: Vector2) -> Vector2i
##   func screen_to_cell(point: Vector2) -> Vector2i
##   func cell_to_screen(cell: Vector2i) -> Vector2
class_name IsometricGrid
extends RefCounted

var layer: TileMapLayer

func _init(tile_layer: TileMapLayer) -> void:
	layer = tile_layer

func cell_to_global(cell: Vector2i) -> Vector2:
	return layer.to_global(layer.map_to_local(cell))

func global_to_cell(point: Vector2) -> Vector2i:
	return layer.local_to_map(layer.to_local(point))

func screen_to_cell(point: Vector2) -> Vector2i:
	return layer.local_to_map(layer.get_global_transform_with_canvas().affine_inverse() * point)

func cell_to_screen(cell: Vector2i) -> Vector2:
	return layer.get_global_transform_with_canvas() * layer.map_to_local(cell)

func mouse_cell() -> Vector2i:
	return global_to_cell(layer.get_global_mouse_position())

static func diamond(size: Vector2) -> PackedVector2Array:
	return PackedVector2Array([Vector2(0, -size.y * 0.5), Vector2(size.x * 0.5, 0), Vector2(0, size.y * 0.5), Vector2(-size.x * 0.5, 0)])
