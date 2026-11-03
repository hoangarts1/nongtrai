## LifeDayWeatherSymbol — replaceable forecast drawing, never a weather authority.
class_name LifeDayWeatherSymbol
extends Control

var weather_id: StringName = &""

func _ready() -> void:
	custom_minimum_size = Vector2(56,52)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func display(id: StringName) -> void:
	weather_id = id
	queue_redraw()

func _draw() -> void:
	if weather_id.is_empty():
		return
	var center: Vector2 = Vector2(size.x*0.5,20)
	var ink: Color = get_theme_color(&"ink",&"LifeTokens")
	var sky: Color = get_theme_color(&"sky",&"LifeTokens")
	if weather_id == &"sunny":
		draw_circle(center,12,ink,true,-1,true)
		draw_circle(center,9,get_theme_color(&"coin",&"LifeTokens"),true,-1,true)
		for index: int in range(8):
			var direction: Vector2 = Vector2.from_angle(TAU*index/8.0)
			draw_line(center+direction*15,center+direction*19,ink,2,true)
	else:
		for offset: Vector2 in [Vector2(-12,4),Vector2(0,-3),Vector2(12,4)]:
			draw_circle(center+offset,11,ink,true,-1,true)
		for offset: Vector2 in [Vector2(-12,4),Vector2(0,-3),Vector2(12,4)]:
			draw_circle(center+offset,8,sky.lightened(0.65),true,-1,true)
		if weather_id in [&"rain",&"storm"]:
			for offset: float in [-10.0,0.0,10.0]:
				draw_line(center+Vector2(offset,20),center+Vector2(offset-3,27),sky,3,true)
