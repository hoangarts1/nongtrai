## AvatarHair2D — shared 2D chibi hair silhouettes and farmer straw hat for player selections.
class_name AvatarHair2D
extends RefCounted

static func draw_back(canvas: CanvasItem, style: StringName, color: Color, ink: Color) -> void:
	var dark: Color = color.darkened(0.16)
	canvas.draw_circle(Vector2(0, -37), 15.5, ink, true, -1, true)
	canvas.draw_circle(Vector2(0, -37), 13.5, dark, true, -1, true)
	match style:
		&"round_bob":
			canvas.draw_rect(Rect2(-15, -37, 30, 15), ink)
			canvas.draw_rect(Rect2(-13, -37, 26, 13), color)
			canvas.draw_circle(Vector2(-12, -25), 4.0, color, true, -1, true)
			canvas.draw_circle(Vector2(12, -25), 4.0, color, true, -1, true)
		&"soft_bangs":
			for side: float in [-13.0, 13.0]:
				canvas.draw_line(Vector2(side, -36), Vector2(side * 1.1, -22), ink, 6.0, true)
				canvas.draw_line(Vector2(side, -36), Vector2(side * 1.1, -22), color, 4.0, true)
		&"leaf_braid":
			for index: int in range(4):
				var point: Vector2 = Vector2(14 + index * 1.2, -30 + index * 5)
				canvas.draw_circle(point, 4.5, ink, true, -1, true)
				canvas.draw_circle(point, 3.0, color, true, -1, true)
			canvas.draw_circle(Vector2(18, -11), 3.0, Color("5fb230"), true, -1, true)
		&"twin_puffs":
			for x: float in [-16.0, 16.0]:
				canvas.draw_circle(Vector2(x, -42), 8.5, ink, true, -1, true)
				canvas.draw_circle(Vector2(x, -42), 6.5, color, true, -1, true)
				canvas.draw_circle(Vector2(x - 1.5, -44), 2.2, color.lightened(0.22), true, -1, true)
		&"side_swoop":
			canvas.draw_circle(Vector2(-13, -31), 5.5, ink, true, -1, true)
			canvas.draw_circle(Vector2(-13, -31), 3.8, color, true, -1, true)

static func draw_front(canvas: CanvasItem, style: StringName, color: Color, ink: Color) -> void:
	var shine: Color = color.lightened(0.22)
	var cap: PackedVector2Array = []
	for index: int in range(17):
		var angle: float = PI + PI * float(index) / 16.0
		cap.append(Vector2(0, -38) + Vector2(cos(angle), sin(angle)) * 11.5)
	canvas.draw_colored_polygon(cap, color)
	canvas.draw_arc(Vector2(0, -38), 11.5, PI, TAU, 16, ink, 2.2, true)
	canvas.draw_arc(Vector2(0, -43), 6.5, PI * 1.15, PI * 1.85, 10, shine, 2.0, true)
	match style:
		&"round_bob":
			canvas.draw_line(Vector2(-10, -42), Vector2(10, -42), color, 4.5, true)
			canvas.draw_line(Vector2(-11, -39), Vector2(-11, -28), color, 3.5, true)
			canvas.draw_line(Vector2(11, -39), Vector2(11, -28), color, 3.5, true)
		&"soft_bangs":
			for x: float in [-7.0, -1.0, 5.0]:
				canvas.draw_circle(Vector2(x, -42), 4.2, color, true, -1, true)
		&"leaf_braid":
			canvas.draw_line(Vector2(-10, -43), Vector2(8, -45), color, 5.0, true)
			canvas.draw_circle(Vector2(10, -42), 3.2, Color("5fb230"), true, -1, true)
		&"side_swoop":
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-12, -44), Vector2(1, -51), Vector2(13, -38), Vector2(7, -36), Vector2(-1, -41)]), ink)
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-10, -44), Vector2(1, -48), Vector2(10, -39), Vector2(7, -38), Vector2(-1, -43)]), color)
		&"short_peak":
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-10, -45), Vector2(-4, -54), Vector2(0, -48), Vector2(4, -56), Vector2(11, -44)]), ink)
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-8, -45), Vector2(-4, -51), Vector2(0, -46), Vector2(4, -53), Vector2(9, -44)]), color)
		&"twin_puffs":
			canvas.draw_circle(Vector2(-5, -42), 3.6, color, true, -1, true)
			canvas.draw_circle(Vector2(5, -42), 3.6, color, true, -1, true)
	_draw_straw_hat(canvas, ink)

static func _draw_straw_hat(canvas: CanvasItem, ink: Color) -> void:
	var straw: Color = Color("edd07b")
	var straw_shade: Color = Color("d5b256")
	var ribbon: Color = Color("5fb230")
	# Rounded hat crown dome
	var dome_ink: PackedVector2Array = []
	var dome_fill: PackedVector2Array = []
	for index: int in range(13):
		var angle: float = PI + PI * float(index) / 12.0
		dome_ink.append(Vector2(0, -47) + Vector2(cos(angle) * 11.5, sin(angle) * 9.5))
		dome_fill.append(Vector2(0, -47) + Vector2(cos(angle) * 9.8, sin(angle) * 7.8))
	canvas.draw_colored_polygon(dome_ink, ink)
	canvas.draw_colored_polygon(dome_fill, straw)
	# Green ribbon band
	canvas.draw_line(Vector2(-9.5, -49.0), Vector2(9.5, -49.0), ribbon, 2.8, true)
	# Curved hat brim
	var brim_ink: PackedVector2Array = PackedVector2Array([Vector2(-19, -46.5), Vector2(-10, -49.5), Vector2(10, -49.5), Vector2(19, -46.5), Vector2(10, -44.5), Vector2(-10, -44.5)])
	var brim_fill: PackedVector2Array = PackedVector2Array([Vector2(-17, -46.5), Vector2(-9, -48.3), Vector2(9, -48.3), Vector2(17, -46.5), Vector2(9, -45.6), Vector2(-9, -45.6)])
	canvas.draw_colored_polygon(brim_ink, ink)
	canvas.draw_colored_polygon(brim_fill, straw_shade)
	# Little daisy flower on hat
	canvas.draw_circle(Vector2(7.5, -50.5), 3.0, Color("fff8df"), true, -1, true)
	canvas.draw_circle(Vector2(7.5, -50.5), 1.4, Color("f7bc32"), true, -1, true)
