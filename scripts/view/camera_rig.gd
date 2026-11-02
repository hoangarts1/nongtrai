## CameraRig — follows the player with its child Camera2D; handles documented zoom actions.
## API:
##   func set_target(target_node: Player) -> void
class_name CameraRig
extends Node

const CONFIG: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
var _target: Player
var _zoom_index: int = CONFIG.zoom_index
var _center: Vector2

func set_target(target_node: Player) -> void:
	_target = target_node
	_center = _safe_center(target_node.global_position)
	_apply_camera()
	_target.camera.reset_smoothing()
	_target.camera.force_update_scroll()

func _process(delta: float) -> void:
	if _target == null:
		return
	_center = _center.lerp(_safe_center(_target.global_position), 1.0 - exp(-CONFIG.camera_follow_speed * delta))
	_apply_camera()

func _unhandled_input(event: InputEvent) -> void:
	if _target == null or not _target.movement_enabled:
		return
	var step: int = 0
	if event.is_action_pressed("camera_zoom_in"):
		step = 1
	elif event.is_action_pressed("camera_zoom_out"):
		step = -1
	if step == 0:
		return
	_zoom_index = clampi(_zoom_index + step, 0, CONFIG.zoom_levels.size() - 1)
	_apply_camera()
	get_viewport().set_input_as_handled()

func _safe_center(point: Vector2) -> Vector2:
	return point.clamp(CONFIG.camera_center_min, CONFIG.camera_center_max) + CONFIG.camera_offset

func _apply_camera() -> void:
	_target.camera.global_position = _center
	_target.camera.zoom = Vector2.ONE * CONFIG.zoom_levels[_zoom_index]
	_target.camera.force_update_scroll()
