## LifePanelWood — reusable 9-slice style wood/paper frame with golden corner studs.
class_name LifePanelWood
extends PanelContainer

func _ready() -> void:
	LifeTheme.bind(self, &"LifeWood")
	resized.connect(queue_redraw)

func _draw() -> void:
	if size.x < 40.0 or size.y < 40.0:
		return
	var wood: Color = get_theme_color(&"wood", &"LifeTokens")
	var ink: Color = get_theme_color(&"ink", &"LifeTokens")
	var gold: Color = get_theme_color(&"coin", &"LifeTokens")
	var outer: Rect2 = Rect2(Vector2(3, 3), size - Vector2(6, 6))
	var inner: Rect2 = Rect2(Vector2(14, 14), size - Vector2(28, 28))
	# Wood border strips around paper interior
	draw_rect(Rect2(outer.position.x, outer.position.y, outer.size.x, 11), wood)
	draw_rect(Rect2(outer.position.x, outer.end.y - 11, outer.size.x, 11), wood.darkened(0.1))
	draw_rect(Rect2(outer.position.x, outer.position.y, 11, outer.size.y), wood)
	draw_rect(Rect2(outer.end.x - 11, outer.position.y, 11, outer.size.y), wood.darkened(0.08))
	draw_rect(inner, ink, false, 2.5)
	for point: Vector2 in [Vector2(10, 10), Vector2(size.x - 10, 10), Vector2(10, size.y - 10), size - Vector2(10, 10)]:
		draw_circle(point, 4.8, ink, true, -1, true)
		draw_circle(point, 3.1, gold, true, -1, true)
		draw_circle(point - Vector2(0.8, 0.8), 1.1, Color("fff8df"), true, -1, true)
