## LifeHudFrame — 9-slice style wood border, bevel lines, and golden corner studs.
class_name LifeHudFrame
extends PanelContainer

func _ready() -> void:
	LifeTheme.bind(self, &"LifeHudWood")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var wood: Color = get_theme_color(&"wood", &"LifeTokens")
	var ink: Color = get_theme_color(&"ink", &"LifeTokens")
	var gold: Color = get_theme_color(&"coin", &"LifeTokens")
	if size.x < 24.0 or size.y < 24.0:
		return
	# Top warm highlight & bottom bevel inside wooden frame
	for inset: float in [4.5, 7.5]:
		draw_line(Vector2(18, inset), Vector2(size.x - 18, inset), wood.lightened(0.28), 1.5, true)
		draw_line(Vector2(18, size.y - inset), Vector2(size.x - 18, size.y - inset), wood.darkened(0.22), 1.5, true)
	# Subtle vertical wood plank joints
	if size.x > 120.0:
		for seam_x: float in [size.x * 0.28, size.x * 0.72]:
			draw_line(Vector2(seam_x, 3), Vector2(seam_x, 9), wood.darkened(0.18), 1.2)
			draw_line(Vector2(seam_x, size.y - 9), Vector2(seam_x, size.y - 3), wood.darkened(0.18), 1.2)
	# Four golden corner studs with specular shine (matching 15-bo-ui-kit.png)
	for point: Vector2 in [Vector2(11, 11), Vector2(size.x - 11, 11), Vector2(11, size.y - 11), size - Vector2(11, 11)]:
		draw_circle(point, 5.2, ink, true, -1, true)
		draw_circle(point, 3.4, gold, true, -1, true)
		draw_circle(point - Vector2(1.0, 1.0), 1.3, Color("fff8df"), true, -1, true)
