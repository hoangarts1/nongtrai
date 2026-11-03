## LifeHudClockArc — visual time arc and replaceable weather symbol.
class_name LifeHudClockArc
extends Control

var minute: int = 360
var weather_id: StringName = &"sunny"

func _ready() -> void:
	custom_minimum_size = Vector2(160,44)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func display(value: int, weather: StringName) -> void:
	minute = value
	weather_id = weather
	queue_redraw()

func _draw() -> void:
	var ink: Color = get_theme_color(&"ink",&"LifeTokens")
	var gold: Color = get_theme_color(&"coin",&"LifeTokens")
	var center: Vector2 = Vector2(size.x*0.5,32)
	var radius: float = minf(size.x*0.41,80)
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(49):
		var angle: float = PI+PI*index/48.0
		points.append(center+Vector2(cos(angle)*radius,sin(angle)*24))
	draw_polyline(points,ink,5,true)
	for index: int in range(17):
		var angle: float = PI + PI*float(index)/16.0
		draw_circle(center+Vector2(cos(angle)*radius,sin(angle)*24),1.8,gold,true,-1,true)
	var progress: float = clampf(float(minute-360)/1200.0,0,1)
	var angle: float = PI+PI*progress
	var point: Vector2 = center+Vector2(cos(angle)*radius,sin(angle)*24)
	draw_circle(point,9,ink,true,-1,true)
	draw_circle(point,7,gold,true,-1,true)
	if minute >= 1200:
		draw_circle(point+Vector2(4,-3),8,get_theme_color(&"paper",&"LifeTokens"),true,-1,true)
	else:
		for index: int in range(8):
			var direction: Vector2 = Vector2.from_angle(TAU*index/8.0)
			draw_line(point+direction*10,point+direction*12,ink,2,true)
	if weather_id in [&"rain",&"storm"]:
		var cloud: Vector2 = Vector2(size.x*0.5,18)
		draw_circle(cloud,10,ink,true,-1,true)
		draw_circle(cloud-Vector2(10,-3),8,ink,true,-1,true)
		draw_circle(cloud+Vector2(10,3),8,ink,true,-1,true)
		draw_circle(cloud,7,get_theme_color(&"sky",&"LifeTokens"),true,-1,true)
		for offset: float in [-8.0,0.0,8.0]:
			draw_line(cloud+Vector2(offset,14),cloud+Vector2(offset-2,20),get_theme_color(&"sky",&"LifeTokens"),2,true)
