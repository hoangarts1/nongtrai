## CameraRig — smooth orthographic follow with a fixed map-safe center.
## API:
##   func set_target(target_node: Node3D) -> void
class_name CameraRig
extends Node3D

@export var follow_speed: float = 6.0
@export var map_min: Vector2 = Vector2(-12.0, -12.0)
@export var map_max: Vector2 = Vector2(12.0, 12.0)
@export var camera_center_min: Vector2 = Vector2(-3.0, -3.0)
@export var camera_center_max: Vector2 = Vector2(3.0, 3.0)

var _target: Node3D

func set_target(target_node: Node3D) -> void:
	_target = target_node
	global_position = _safe_center(_target.global_position)

func _process(delta: float) -> void:
	if _target == null:
		return
	var target_position: Vector3 = _safe_center(_target.global_position)
	var blend: float = 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(target_position, blend)

func _safe_center(target_position: Vector3) -> Vector3:
	var center_x: float = clampf(target_position.x, camera_center_min.x, camera_center_max.x)
	var center_z: float = clampf(target_position.z, camera_center_min.y, camera_center_max.y)
	return Vector3(center_x, 0.0, center_z)
