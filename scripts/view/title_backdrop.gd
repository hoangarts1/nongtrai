## TitleBackdrop — illustrated opening screen; decoration never receives input.
class_name TitleBackdrop
extends TextureRect

var menu: Control
var _elapsed: float = 0.0

func _ready() -> void:
	texture = preload("res://assets/ui/title_valley.png")
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 79

func _process(delta: float) -> void:
	visible = menu != null and menu.visible
	if visible:
		_elapsed += delta
		queue_redraw()

func _draw() -> void:
	# A quiet paper-colored veil supports readable real text over the illustration.
	for index: int in range(18):
		var alpha: float = 0.018 * float(18 - index)
		draw_rect(Rect2(0, 0, size.x * (0.30 + float(index) * 0.018), size.y), Color(1.0, 0.96, 0.85, alpha))
	for index: int in range(12):
		var x: float = fmod(float(index) * 137.0 + _elapsed * 8.0, maxf(1.0, size.x))
		var y: float = size.y * 0.28 + sin(_elapsed * 0.6 + float(index)) * 36.0 + float(index % 5) * 80.0
		draw_circle(Vector2(x, y), 2.2, Color(1, 0.98, 0.76, 0.6))
