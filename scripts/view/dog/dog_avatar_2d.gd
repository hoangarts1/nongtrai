## DogAvatar2D - read-only provisional silhouette and bounded cosmetic pose.
class_name DogAvatar2D
extends Node2D
var _profile: DogVisualProfile
var _phase: float = 0.0
var _walking: bool = false
var _facing: float = 1.0

func configure(profile: DogVisualProfile) -> bool:
	if profile == null or not profile.validation_errors().is_empty(): return false
	_profile = profile.frozen_copy()
	set_process(false)
	queue_redraw()
	return true

func set_motion(walking: bool, direction: Vector2 = Vector2.ZERO) -> void:
	_walking = walking
	if not is_zero_approx(direction.x): _facing = signf(direction.x)
	queue_redraw()

func advance(delta: float, playing: bool = true) -> void:
	if _profile == null or not playing or not is_finite(delta) or delta <= 0.0: return
	_phase = fposmod(_phase + delta * TAU / _profile.cycle_seconds, TAU)
	queue_redraw()

func get_phase() -> float: return _phase

func _draw() -> void:
	if _profile == null: return
	for part: Dictionary in _profile.parts:
		var offset: Vector2 = Vector2.ZERO
		var angle: float = 0.0
		if part.motion != "ground":
			offset.y = -absf(sin(_phase)) * _profile.bob if _walking else 0.0
		if part.motion == "leg" and _walking: offset.x += sin(_phase + part.phase) * _profile.stride
		if part.motion == "tail": angle = sin(_phase) * _profile.tail_angle
		var points: PackedVector2Array = []
		for point: Vector2 in part.points:
			var moved: Vector2 = (point - part.pivot).rotated(angle) + part.pivot + offset
			points.append(Vector2(moved.x * _facing, moved.y))
		draw_colored_polygon(points, _profile.color(part.role))
		if part.motion != "ground":
			points.append(points[0])
			draw_polyline(points, _profile.color("outline"), _profile.outline_width, true)
