## PlaceholderAvatar2D — 2D isometric chibi character renderer with cosmetic and action animations.
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
var _hair_style: StringName = &""
var _accum: float = 0.0

func configure(color: Color, _with_hat: bool = true) -> void:
	outfit = color
	queue_redraw()

func configure_profile(profile: Dictionary, customization: Dictionary = {}) -> void:
	_customization = customization.duplicate(true)
	_hair_style = &""
	var catalog: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")
	var resolved: Dictionary = profile
	if not customization.is_empty():
		var selection: Variant = catalog.call("resolve_player", customization)
		if selection is Resource:
			resolved = selection.call("to_builder_dictionary")
		elif selection is Dictionary:
			resolved = selection
		_hair_style = StringName(resolved.get("hair_style", &""))
	outfit = resolved.get("outfit_color", resolved.get("body_color", outfit))
	skin = resolved.get("skin_color", skin)
	hair = resolved.get("hair_color", hair)
	queue_redraw()

func get_hair_style() -> StringName:
	return _hair_style

func set_motion(value: Vector2) -> void:
	_motion = value

func play_tool(tool_id: StringName) -> void:
	action_id = &"Tool"
	set_meta("tool_id", tool_id)
	_action_remaining = 0.48
	queue_redraw()

func play_talk() -> void:
	action_id = &"Talk"
	_action_remaining = 0.8
	queue_redraw()

func play_sleep() -> void:
	action_id = &"Sleep"
	_action_remaining = 1.0
	queue_redraw()

func show_emotion_bubble(emotion_id: StringName, duration: float = 1.4) -> bool:
	if not [&"heart", &"surprise", &"question", &"music", &"sweat", &"sleep"].has(emotion_id):
		return false
	_emotion = emotion_id
	_emotion_remaining = duration
	queue_redraw()
	return true

func get_emotion() -> StringName:
	return _emotion if _emotion_remaining > 0 else &""

func _process(delta: float) -> void:
	var prev_action: StringName = action_id
	var prev_emotion: bool = _emotion_remaining > 0.0
	_action_remaining = maxf(0.0, _action_remaining - delta)
	_emotion_remaining = maxf(0.0, _emotion_remaining - delta)
	if _action_remaining <= 0.0:
		action_id = &"Walk" if _motion.length_squared() > 0.0 else &"Idle"
	if GameClock.paused:
		if action_id != prev_action or (_emotion_remaining > 0.0) != prev_emotion:
			queue_redraw()
		return
	_phase += delta
	_accum += delta
	var interval: float = 0.05 if (_motion.length_squared() > 0.0 or _action_remaining > 0.0 or _emotion_remaining > 0.0) else 0.2
	if action_id != prev_action or _accum >= interval:
		_accum = 0.0
		queue_redraw()

func _draw() -> void:
	var ink: Color = Color("3a2412")
	var boot_color: Color = Color("6e472b")
	var shirt_color: Color = outfit.lightened(0.24)
	var overall_dark: Color = outfit.darkened(0.16)
	var walking: bool = _motion.length_squared() > 0.0
	var bob: float = sin(_phase * 10.0) * 1.8 if walking else (sin(_phase * 2.6) * 0.7 if _phase > 0.0 else 0.0)
	var stride: float = sin(_phase * 10.0) * 2.6 if walking else 0.0
	draw_ellipse_shadow()
	draw_set_transform(Vector2(0, bob))
	# Cozy boots and legs
	draw_rect(Rect2(-8, -10 + stride * 0.5, 7, 9), ink)
	draw_rect(Rect2(1, -10 - stride * 0.5, 7, 9), ink)
	draw_rect(Rect2(-7, -9 + stride * 0.5, 5, 7), boot_color)
	draw_rect(Rect2(2, -9 - stride * 0.5, 5, 7), boot_color)
	# Torso & cozy overalls (matching 02-tao-nhan-vat.png)
	draw_rect(Rect2(-11, -27, 22, 18), ink)
	draw_rect(Rect2(-9, -25, 18, 15), shirt_color)
	draw_rect(Rect2(-7, -23, 14, 13), outfit)
	draw_rect(Rect2(-5, -20, 10, 6), overall_dark)
	draw_line(Vector2(-5, -25), Vector2(-5, -20), overall_dark, 2.0)
	draw_line(Vector2(5, -25), Vector2(5, -20), overall_dark, 2.0)
	draw_circle(Vector2(-5, -21), 1.3, Color("ffd25a"))
	draw_circle(Vector2(5, -21), 1.3, Color("ffd25a"))
	# Swinging arms & hands
	var arm_swing: float = -stride * 0.8
	var right_hand: Vector2 = Vector2(13, -15 - arm_swing) if action_id != &"Tool" else Vector2(15, -21)
	draw_line(Vector2(-10, -24), Vector2(-13, -15 + arm_swing), ink, 6.0, true)
	draw_line(Vector2(-10, -24), Vector2(-13, -15 + arm_swing), outfit, 4.0, true)
	draw_circle(Vector2(-13, -14 + arm_swing), 3.2, ink)
	draw_circle(Vector2(-13, -14 + arm_swing), 2.2, skin)
	draw_line(Vector2(10, -24), right_hand, ink, 6.0, true)
	draw_line(Vector2(10, -24), right_hand, outfit, 4.0, true)
	draw_circle(right_hand + Vector2(0, 1), 3.2, ink)
	draw_circle(right_hand + Vector2(0, 1), 2.2, skin)
	# Back hair
	if not _hair_style.is_empty():
		AvatarHair2D.draw_back(self, _hair_style, hair, ink)
	else:
		draw_circle(Vector2(0, -37), 14.0, ink, true, -1, true)
		draw_circle(Vector2(0, -37), 12.2, hair.darkened(0.15), true, -1, true)
	# Head & face
	draw_circle(Vector2(0, -36), 13.0, ink)
	draw_circle(Vector2(0, -36), 11.2, skin)
	# Front hair + straw hat
	if _hair_style.is_empty():
		draw_arc(Vector2(0, -38), 11.0, PI, TAU, 16, hair, 5.5, true)
	else:
		AvatarHair2D.draw_front(self, _hair_style, hair, ink)
	# Rosy cheeks, eyes & mouth
	draw_circle(Vector2(-6.5, -33.5), 2.4, Color(0.92, 0.52, 0.45, 0.55))
	draw_circle(Vector2(6.5, -33.5), 2.4, Color(0.92, 0.52, 0.45, 0.55))
	var blinking: bool = action_id == &"Sleep" or (_phase > 0.0 and fmod(_phase, 3.8) > 3.62)
	if blinking:
		draw_line(Vector2(-6, -36), Vector2(-2, -36), ink, 1.6, true)
		draw_line(Vector2(2, -36), Vector2(6, -36), ink, 1.6, true)
	else:
		draw_circle(Vector2(-4.2, -36.2), 1.9, ink)
		draw_circle(Vector2(4.2, -36.2), 1.9, ink)
		draw_circle(Vector2(-4.7, -36.8), 0.7, Color.WHITE)
		draw_circle(Vector2(3.7, -36.8), 0.7, Color.WHITE)
	if action_id == &"Talk" and int(_phase * 8.0) % 2 == 0:
		draw_circle(Vector2(0, -31.2), 2.0, ink)
	else:
		draw_arc(Vector2(0, -32.2), 2.4, 0.15 * PI, 0.85 * PI, 8, ink, 1.5, true)
	if action_id == &"Tool":
		_draw_active_tool(ink)
	if _emotion_remaining > 0.0:
		_draw_emotion_bubble(ink)
	draw_set_transform(Vector2.ZERO)

func _draw_active_tool(ink: Color) -> void:
	var tool_id: StringName = StringName(get_meta("tool_id", &"hoe"))
	var swing: float = sin((1.0 - _action_remaining / 0.48) * PI) * 6.0
	var tip: Vector2 = Vector2(26, -8 + swing)
	draw_line(Vector2(14, -20), tip, ink, 3.5, true)
	if tool_id in [&"water", &"watering_can"]:
		draw_rect(Rect2(tip.x - 5, tip.y - 4, 10, 8), Color("6fb7f0"))
		draw_circle(tip + Vector2(6, 4), 2.0, Color("9bd2e5"))
		draw_circle(tip + Vector2(9, 8), 1.6, Color("9bd2e5"))
	elif tool_id == &"harvest":
		draw_arc(tip, 5.0, -PI * 0.5, PI * 0.4, 8, Color("dcdcdc"), 2.5, true)
	else:
		draw_circle(tip, 4.2, Color("ffd25a"))

func _draw_emotion_bubble(ink: Color) -> void:
	var center: Vector2 = Vector2(6, -64 + sin(_phase * 6.0) * 1.5)
	draw_circle(center, 9.5, ink)
	draw_circle(center, 8.0, Color("fff8df"))
	var accent: Color = Color("d6453a") if _emotion == &"heart" else (Color("6fb7f0") if _emotion == &"sweat" else Color("5fb230"))
	draw_circle(center, 3.4, accent)

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.38))
	draw_circle(Vector2.ZERO, 14.0, Color(0.1, 0.15, 0.06, 0.28))
	draw_set_transform(Vector2.ZERO)
