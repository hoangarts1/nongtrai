## PlaceholderAvatar2D — replaceable, view-only avatar with cosmetic and action feedback.
## API:
##   func configure_profile(profile: Dictionary, customization: Dictionary = {}) -> void
##   func play_tool(tool_id: StringName) -> void
##   func play_talk() -> void
##   func show_emotion_bubble(emotion_id: StringName) -> bool
class_name PlaceholderAvatar2D
extends Node2D

var outfit: Color = Color("88a66a")
var skin: Color = Color("efc69f")
var hair: Color = Color("68432c")
var action_id: StringName = &"Idle"
var _action_remaining: float = 0.0
var _motion: Vector2 = Vector2.ZERO
var _phase: float = 0.0
var _emotion: StringName = &""
var _emotion_remaining: float = 0.0
var _customization: Dictionary = {}

func configure(color: Color, _with_hat: bool = true) -> void:
	outfit = color
	queue_redraw()

func configure_profile(profile: Dictionary, customization: Dictionary = {}) -> void:
	_customization = customization.duplicate(true)
	var catalog: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")
	var resolved: Dictionary = profile
	if not customization.is_empty():
		var selection: Variant = catalog.call("resolve_player", customization)
		if selection is Resource:
			resolved = selection.call("to_builder_dictionary")
		elif selection is Dictionary:
			resolved = selection
	outfit = resolved.get("outfit_color", resolved.get("body_color", outfit))
	skin = resolved.get("skin_color", skin)
	hair = resolved.get("hair_color", hair)
	queue_redraw()

func set_motion(value: Vector2) -> void:
	_motion = value

func play_tool(tool_id: StringName) -> void:
	action_id = &"Tool"
	set_meta("tool_id", tool_id)
	_action_remaining = 0.48

func play_talk() -> void:
	action_id = &"Talk"
	_action_remaining = 0.8

func play_sleep() -> void:
	action_id = &"Sleep"
	_action_remaining = 1.0

func show_emotion_bubble(emotion_id: StringName, duration: float = 1.4) -> bool:
	if not [&"heart", &"surprise", &"question", &"music", &"sweat", &"sleep"].has(emotion_id):
		return false
	_emotion = emotion_id
	_emotion_remaining = duration
	return true

func get_emotion() -> StringName:
	return _emotion if _emotion_remaining > 0 else &""

func _process(delta: float) -> void:
	if not GameClock.paused:
		_phase += delta
	_action_remaining = maxf(0, _action_remaining - delta)
	_emotion_remaining = maxf(0, _emotion_remaining - delta)
	if _action_remaining <= 0:
		action_id = &"Walk" if _motion.length_squared() > 0 else &"Idle"
	queue_redraw()

func _draw() -> void:
	var ink: Color = Color("3a2412")
	var bob: float = sin(_phase * 10.0) * 1.5 if _motion.length_squared() > 0 else 0.0
	draw_ellipse_shadow()
	draw_set_transform(Vector2(0, bob))
	draw_line(Vector2(-5,-9), Vector2(-6,-1), ink, 6)
	draw_line(Vector2(5,-9), Vector2(6,-1), ink, 6)
	draw_rect(Rect2(-10,-26,20,18), ink)
	draw_rect(Rect2(-8,-25,16,15), outfit)
	draw_circle(Vector2(0,-36), 13, ink)
	draw_circle(Vector2(0,-36), 11, skin)
	draw_arc(Vector2(0,-38), 11, PI, TAU, 16, hair, 5)
	draw_circle(Vector2(-4,-36), 1.4, ink)
	draw_circle(Vector2(4,-36), 1.4, ink)
	draw_line(Vector2(-2,-31), Vector2(2,-31), ink, 1)
	draw_line(Vector2(-11,-24),Vector2(-14,-15),skin,5)
	draw_line(Vector2(11,-24),Vector2(14,-15),skin,5)
	if action_id == &"Tool":
		draw_line(Vector2(13,-20),Vector2(26,-8),ink,3)
		draw_circle(Vector2(26,-8),4,Color("ffd25a"))
	if _emotion_remaining > 0:
		draw_circle(Vector2(4,-60),8,Color("fff4d9"))
		draw_circle(Vector2(4,-60),3,Color("d6453a") if _emotion == &"heart" else Color("5fb230"))

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 13, Color(0.1,0.15,0.06,0.25))
	draw_set_transform(Vector2.ZERO)
