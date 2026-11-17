## CameraRig — follows the player with its child Camera2D; handles zoom and RMB/MMB map drag panning.
## API:
##   func set_target(target_node: Player) -> void
##   func get_pan_offset() -> Vector2
##   func reset_pan() -> void
##   func is_panning() -> bool
class_name CameraRig
extends Node

const CONFIG: IsometricWorldConfig = preload("res://data/isometric_world_config.tres")
var _target: Player
var _zoom_index: int = CONFIG.zoom_index
var _center: Vector2
var _pan_offset: Vector2 = Vector2.ZERO
var _dragging: bool = false

func set_target(target_node: Player) -> void:
	_target = target_node
	_pan_offset = Vector2.ZERO
	_dragging = false
	_center = _safe_center(target_node.global_position)
	_apply_camera()
	_target.camera.reset_smoothing()
	_target.camera.force_update_scroll()

func get_pan_offset() -> Vector2:
	return _pan_offset

func reset_pan() -> void:
	_pan_offset = Vector2.ZERO
	_dragging = false
	if _target != null:
		_apply_camera()

func is_panning() -> bool:
	return _dragging

func _process(delta: float) -> void:
	if _target == null:
		return
	if not _target.movement_enabled:
		_dragging = false
	elif not _dragging and _target.velocity.length_squared() > 1.0 and _pan_offset != Vector2.ZERO:
		_pan_offset = _pan_offset.lerp(Vector2.ZERO, 1.0 - exp(-CONFIG.camera_follow_speed * delta))
		if _pan_offset.length_squared() < 0.5:
			_pan_offset = Vector2.ZERO
	_center = _center.lerp(_safe_center(_target.global_position), 1.0 - exp(-CONFIG.camera_follow_speed * delta))
	_apply_camera()

func _unhandled_input(event: InputEvent) -> void:
	if _target == null or not _target.movement_enabled:
		_dragging = false
		return
	if event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if mouse_button.pressed and mouse_button.double_click:
				reset_pan()
			else:
				_dragging = mouse_button.pressed
			get_viewport().set_input_as_handled()
			return
		if mouse_button.pressed and mouse_button.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			# GUI/hotbar owns Shift-wheel and wheel over controls before world zoom.
			if mouse_button.shift_pressed or get_viewport().gui_get_hovered_control()!=null:
				return
			var wheel_step: int = 1 if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP else -1
			_zoom_index = clampi(_zoom_index + wheel_step, 0, CONFIG.zoom_levels.size() - 1)
			_apply_camera()
			get_viewport().set_input_as_handled()
			return
	elif event is InputEventMouseMotion and _dragging:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		var zoom_scale: float = CONFIG.zoom_levels[_zoom_index]
		_pan_offset = (_pan_offset - motion.relative / zoom_scale).clamp(CONFIG.camera_pan_min, CONFIG.camera_pan_max)
		_apply_camera()
		get_viewport().set_input_as_handled()
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
	_target.camera.global_position = _center + _pan_offset
	_target.camera.zoom = Vector2.ONE * CONFIG.zoom_levels[_zoom_index]
	_target.camera.force_update_scroll()
