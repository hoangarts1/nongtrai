## IsometricWorldConfig — data-owned map, interaction and 2D presentation parameters.
class_name IsometricWorldConfig
extends Resource

@export var tile_size: Vector2i = Vector2i(64, 32)
@export var map_region: Rect2i = Rect2i(-12, -12, 27, 27)
@export var player_region: Rect2i = Rect2i(-10, -10, 22, 22)
@export var spawn_cell: Vector2i = Vector2i(3, 3)
@export var house_cell: Vector2i = Vector2i(11, 10)
@export var shipping_bin_cell: Vector2i = Vector2i(5, 10)
@export var shop_cell: Vector2i = Vector2i(-2, 7)
@export var debug_home_cell: Vector2i = Vector2i(11, 8)
@export var interaction_reach: float = 2.5
@export var zoom_levels: PackedFloat32Array = PackedFloat32Array([0.85, 1.0, 1.25])
@export var zoom_index: int = 1
@export var camera_follow_speed: float = 6.0
@export var camera_center_min: Vector2 = Vector2(-128, -48)
@export var camera_center_max: Vector2 = Vector2(128, 192)
@export var camera_offset: Vector2 = Vector2(0, -48)
@export var ground_color: Color = Color("92b967")
@export var ground_line_color: Color = Color("779c55")
@export var dry_soil_color: Color = Color("a97849")
@export var wet_soil_color: Color = Color("68513c")
@export var rain_amount: int = 120
@export var rain_area: Vector2 = Vector2(1152, 648)
