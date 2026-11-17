## WaterSourceData — fixed world geometry and a dry approach; no runtime can state.
class_name WaterSourceData
extends Resource

@export var source_id: StringName
@export var kind: StringName
@export var display_name_key: StringName
@export var region: Rect2i
@export var label_cell: Vector2i
@export var access_waypoints: Array[Vector2i] = []
