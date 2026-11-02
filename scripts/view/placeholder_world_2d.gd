## PlaceholderWorld2D — replaceable non-colliding 2D scenery with a ground-level pivot.
class_name PlaceholderWorld2D
extends Node2D

var kind: StringName = &"cottage"
var color: Color = Color("bc8340")
var label: Label

func configure(visual_kind: StringName, title: String, tint: Color) -> void:
	kind = visual_kind
	color = tint
	if label == null:
		label = Label.new()
		label.name = "NameLabel"
		label.position = Vector2(-70,-88)
		label.size = Vector2(140,24)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.theme = preload("res://scenes/main/ui_theme.tres")
		label.add_theme_font_size_override("font_size", 13)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
	label.text = title
	label.visible = not title.is_empty()
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var ink: Color = Color("3a2412")
	match kind:
		&"tree":
			draw_line(Vector2(0,-3),Vector2(0,-35),ink,8)
			draw_circle(Vector2(0,-44),24,ink)
			draw_circle(Vector2(0,-46),22,color)
			draw_circle(Vector2(-9,-51),9,color.lightened(0.1))
		&"bin":
			draw_rect(Rect2(-21,-27,42,25),ink)
			draw_rect(Rect2(-18,-25,36,20),color)
			draw_line(Vector2(-21,-27),Vector2(21,-27),Color("f5e3b0"),4)
			draw_rect(Rect2(-8,-22,16,4),ink)
		&"market":
			draw_rect(Rect2(-30,-46,60,42),ink)
			draw_rect(Rect2(-27,-43,54,35),color)
			draw_colored_polygon(PackedVector2Array([Vector2(-37,-49),Vector2(37,-49),Vector2(29,-66),Vector2(-29,-66)]),Color("d6453a"))
			for x: int in range(-24,25,16):
				draw_rect(Rect2(x,-47,8,12),Color("f5e3b0"))
			draw_rect(Rect2(-24,-21,48,12),Color("8c6339"))
		_:
			draw_rect(Rect2(-32,-54,64,50),ink)
			draw_rect(Rect2(-29,-52,58,46),color)
			draw_colored_polygon(PackedVector2Array([Vector2(-39,-54),Vector2(0,-83),Vector2(39,-54)]),ink)
			draw_colored_polygon(PackedVector2Array([Vector2(-32,-56),Vector2(0,-78),Vector2(32,-56)]),Color("b55b42"))
			draw_rect(Rect2(-7,-29,14,24),ink)
			var window_color: Color = Color("ffd25a") if GameClock.minute >= 1080 else Color("9bd2e5")
			draw_rect(Rect2(14,-41,11,12),ink)
			draw_rect(Rect2(16,-39,7,8),window_color)
