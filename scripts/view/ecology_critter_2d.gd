## LifeEcologyCritter2D — provisional native 2D silhouette, cosmetic phase only.
class_name LifeEcologyCritter2D
extends Node2D

var _definition: Dictionary = {}
var _phase: float = 0.0
var _flap: float = 0.0

func configure(definition: Dictionary, start_phase: float) -> void:
	_definition = definition.duplicate(true)
	_phase = fposmod(start_phase, TAU)
	_flap = _phase
	set_process(false)
	queue_redraw()

func advance(delta: float) -> void:
	if _definition.is_empty() or not is_finite(delta) or delta <= 0.0:
		return
	_phase = fposmod(_phase + delta * float(_definition.speed), TAU)
	_flap = fposmod(_flap + delta * float(_definition.flap_speed), TAU)
	queue_redraw()

func get_phase() -> Vector2:
	return Vector2(_phase, _flap)

func _draw() -> void:
	if _definition.is_empty():
		return
	var span: Vector2 = _definition.span
	var origin: Vector2 = Vector2(cos(_phase) * span.x, sin(_phase) * span.y - float(_definition.altitude))
	var scale_value: float = float(_definition.scale)
	draw_set_transform(origin, 0.0, Vector2.ONE * scale_value)
	draw_colored_polygon(_definition.body, _definition.body_color)
	var flap: float = absf(sin(_flap))
	if not is_zero_approx(flap):
		for side: float in [-1.0, 1.0]:
			var wing_scale: Vector2 = Vector2(side * flap, 1.0) if _definition.id == "butterflies" else Vector2(1.0, side * flap)
			draw_set_transform(origin, 0.0, wing_scale * scale_value)
			draw_colored_polygon(_definition.wing, _definition.wing_color)
	draw_set_transform(Vector2.ZERO)
