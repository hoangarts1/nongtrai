## LifeHeartRow — five view-only affection hearts, without friendship calculations.
class_name LifeHeartRow
extends Control

var filled: int = 0

func _ready() -> void:
	LifeTheme.bind(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_hearts(count: int) -> void:
	filled = clampi(count,0,5)
	queue_redraw()

func _draw() -> void:
	var outline: Color = get_theme_color(&"ink",&"LifeTokens")
	for index: int in range(5):
		var origin: Vector2 = Vector2(6+index*30,4)
		var points: PackedVector2Array = PackedVector2Array([Vector2(12,23),Vector2(1,12),Vector2(0,6),Vector2(3,1),Vector2(8,0),Vector2(12,4),Vector2(16,0),Vector2(21,1),Vector2(24,6),Vector2(23,12)])
		for point_index: int in range(points.size()):
			points[point_index] += origin
		draw_colored_polygon(points,get_theme_color(&"red" if index < filled else &"paper",&"LifeTokens"))
		points.append(points[0])
		draw_polyline(points,outline,2,true)
