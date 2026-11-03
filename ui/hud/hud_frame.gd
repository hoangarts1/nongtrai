## LifeHudFrame — replaceable wood grain and corner studs, palette-owned decoration.
class_name LifeHudFrame
extends PanelContainer

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudWood")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var wood: Color = get_theme_color(&"wood",&"LifeTokens")
	var ink: Color = get_theme_color(&"ink",&"LifeTokens")
	for inset: float in [5.0,8.0]:
		draw_line(Vector2(18,inset),Vector2(size.x-18,inset),wood.lightened(0.3),1.0,true)
		draw_line(Vector2(18,size.y-inset),Vector2(size.x-18,size.y-inset),wood.darkened(0.2),1.0,true)
	for point: Vector2 in [Vector2(11,11),Vector2(size.x-11,11),Vector2(11,size.y-11),size-Vector2(11,11)]:
		draw_circle(point,5.0,ink,true,-1,true)
		draw_circle(point-Vector2(0,1),3.0,wood.lightened(0.5),true,-1,true)
