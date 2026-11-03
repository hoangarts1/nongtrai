## AvatarHair2D — shared cosmetic silhouettes for normalized player selections.
class_name AvatarHair2D
extends RefCounted

static func draw_back(canvas: CanvasItem, style: StringName, color: Color, ink: Color) -> void:
	canvas.draw_circle(Vector2(0,-37),15,ink,true,-1,true)
	canvas.draw_circle(Vector2(0,-37),13,color,true,-1,true)
	match style:
		&"round_bob":
			canvas.draw_rect(Rect2(-15,-37,30,14),ink)
			canvas.draw_rect(Rect2(-13,-37,26,12),color)
		&"soft_bangs":
			canvas.draw_line(Vector2(-13,-36),Vector2(-14,-27),ink,5,true)
			canvas.draw_line(Vector2(13,-36),Vector2(14,-27),color,4,true)
		&"leaf_braid":
			for index: int in range(4):
				var point: Vector2 = Vector2(14,-30+index*5)
				canvas.draw_circle(point,4,ink,true,-1,true)
				canvas.draw_circle(point,2.5,color,true,-1,true)
		&"twin_puffs":
			for x: float in [-16.0,16.0]:
				canvas.draw_circle(Vector2(x,-44),8,ink,true,-1,true)
				canvas.draw_circle(Vector2(x,-44),6,color,true,-1,true)

static func draw_front(canvas: CanvasItem, style: StringName, color: Color, ink: Color) -> void:
	var cap: PackedVector2Array = []
	for index: int in range(17):
		var angle: float = PI+PI*float(index)/16.0
		cap.append(Vector2(0,-38)+Vector2(cos(angle),sin(angle))*11.0)
	canvas.draw_colored_polygon(cap,color)
	canvas.draw_arc(Vector2(0,-38),11,PI,TAU,16,color,5,true)
	match style:
		&"round_bob":
			canvas.draw_line(Vector2(-10,-42),Vector2(10,-42),color,4,true)
		&"soft_bangs":
			for x: float in [-7.0,-1.0,5.0]:
				canvas.draw_circle(Vector2(x,-42),4,color,true,-1,true)
		&"leaf_braid":
			canvas.draw_line(Vector2(-10,-43),Vector2(7,-45),color,5,true)
		&"side_swoop":
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-12,-44),Vector2(1,-51),Vector2(13,-38),Vector2(7,-36),Vector2(-1,-41)]),ink)
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-10,-44),Vector2(1,-48),Vector2(10,-39),Vector2(7,-38),Vector2(-1,-43)]),color)
		&"short_peak":
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-10,-45),Vector2(-4,-53),Vector2(0,-48),Vector2(4,-55),Vector2(11,-44)]),ink)
			canvas.draw_colored_polygon(PackedVector2Array([Vector2(-8,-45),Vector2(-4,-50),Vector2(0,-46),Vector2(4,-52),Vector2(9,-44)]),color)
