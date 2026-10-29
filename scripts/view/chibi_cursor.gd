## ChibiCursor — runtime-drawn cursor with gentle paw and selected-tool cues.
## API:
##   func set_ui_hovered(hovered: bool) -> void
##   func set_pressed(pressed: bool) -> void
##   func set_tool_mode(tool_id: StringName) -> void
##   func get_visual_mode() -> StringName
##   func get_tool_mode() -> StringName
class_name ChibiCursor
extends Control

const PALETTE: Resource = preload("res://data/art/palette/chibi_valley.tres")
const CURSOR_SIZE: Vector2 = Vector2(38.0, 42.0)
const HOTSPOT: Vector2 = Vector2(6.0, 5.0)

var _tool_id: StringName = &""
var _ui_hovered: bool = false
var _pressed: bool = false
var _phase: float = 0.0
var _owns_mouse_mode: bool = false
var _previous_mouse_mode: int = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	name = "ChibiCursor"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 200
	custom_minimum_size = CURSOR_SIZE
	size = CURSOR_SIZE
	pivot_offset = HOTSPOT
	if DisplayServer.get_name() != "headless":
		_previous_mouse_mode = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		_owns_mouse_mode = true
	_follow_pointer()
	queue_redraw()

func _exit_tree() -> void:
	if _owns_mouse_mode:
		Input.set_mouse_mode(_previous_mouse_mode)
		_owns_mouse_mode = false

func _process(delta: float) -> void:
	_phase += delta
	_follow_pointer()
	queue_redraw()

func set_ui_hovered(hovered: bool) -> void:
	_ui_hovered = hovered
	queue_redraw()

func set_pressed(pressed: bool) -> void:
	_pressed = pressed
	queue_redraw()

func set_tool_mode(tool_id: StringName) -> void:
	_tool_id = tool_id
	queue_redraw()

func get_visual_mode() -> StringName:
	if _pressed:
		return &"pressed"
	if _ui_hovered:
		return &"ui"
	return _tool_id if not _tool_id.is_empty() else &"world"

func get_tool_mode() -> StringName:
	return _tool_id

func _follow_pointer() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return
	position = viewport.get_mouse_position() - HOTSPOT

func _draw() -> void:
	var outline: Color = _palette_color(&"outline", Color("4b3c47"))
	var shadow: Color = _palette_color(&"shadow", Color("82749a"))
	var cream: Color = _palette_color(&"sunlight", Color("fff3cf"))
	var accent: Color = _palette_color(&"ui_accent", Color("f3a58e"))
	var body_center: Vector2 = Vector2(15.0, 23.0)
	var press_offset: float = 2.0 if _pressed else 0.0
	var bob: float = sin(_phase * 5.0) * (0.55 if not _pressed else 0.18)
	var shadow_center: Vector2 = body_center + Vector2(2.0, 4.0 + press_offset)
	draw_circle(shadow_center, 10.2, Color(shadow, 0.34))
	_draw_paw(body_center + Vector2(0.0, bob + press_offset), cream, accent, outline)
	if not _ui_hovered and not _tool_id.is_empty():
		_draw_tool_badge(Vector2(25.0, 7.0 + bob), outline, accent)

func _draw_paw(center: Vector2, cream: Color, accent: Color, outline: Color) -> void:
	var toe_positions: Array[Vector2] = [
		center + Vector2(-7.8, -7.7),
		center + Vector2(-2.6, -10.1),
		center + Vector2(3.1, -9.4),
		center + Vector2(8.0, -6.1)
	]
	for toe: Vector2 in toe_positions:
		draw_circle(toe, 4.3, outline)
		draw_circle(toe + Vector2(0.0, -0.45), 3.05, cream)
	draw_circle(center, 11.0, outline)
	draw_circle(center + Vector2(0.0, -0.7), 8.6, cream)
	draw_circle(center + Vector2(0.0, 0.4), 4.4, accent)
	draw_circle(center + Vector2(-1.5, -0.5), 1.0, Color(1.0, 0.93, 0.82, 0.72))

func _draw_tool_badge(origin: Vector2, outline: Color, accent: Color) -> void:
	match _tool_id:
		&"hoe":
			draw_line(origin + Vector2(-2.0, 8.0), origin + Vector2(5.0, -3.0), outline, 4.0, true)
			draw_line(origin + Vector2(-1.2, 7.0), origin + Vector2(5.8, -4.0), accent, 2.0, true)
			draw_line(origin + Vector2(2.5, 0.5), origin + Vector2(9.0, 1.2), outline, 3.0, true)
		&"watering_can":
			draw_circle(origin + Vector2(2.5, 3.0), 5.0, outline)
			draw_circle(origin + Vector2(2.5, 2.5), 3.5, Color("8bd2db"))
			draw_line(origin + Vector2(6.0, 0.2), origin + Vector2(10.0, -1.5), outline, 2.5, true)
			draw_circle(origin + Vector2(11.0, 2.8), 1.2, accent)
		&"seed":
			draw_circle(origin + Vector2(2.0, 3.0), 5.5, outline)
			draw_circle(origin + Vector2(2.0, 2.3), 4.0, accent)
			draw_circle(origin + Vector2(0.0, 1.0), 1.1, Color("fff3cf"))
		&"harvest":
			draw_arc(origin + Vector2(3.0, 6.0), 5.0, PI, TAU, 12, outline, 2.5, true)
			draw_line(origin + Vector2(-3.0, 6.0), origin + Vector2(9.0, 6.0), accent, 3.0, true)
			draw_circle(origin + Vector2(3.0, 1.5), 2.0, Color("d8a65a"))
		_:
			pass

func _palette_color(role: StringName, fallback: Color) -> Color:
	if PALETTE == null:
		return fallback
	var value: Variant = PALETTE.call("get_color", role)
	return value if value is Color else fallback
