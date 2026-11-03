## LifeProfileSwatch — native color toggle, palette comes from existing data.
class_name LifeProfileSwatch
extends Button

var paint: Color = Color.WHITE

func _ready() -> void:
	custom_minimum_size = Vector2(48,44)
	toggle_mode = true
	LifeTheme.bind(self,&"LifeSecondary")
	toggled.connect(func(_selected: bool) -> void: queue_redraw())
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2(8,8),size-Vector2(16,16)),paint)
	if button_pressed:
		var center: Vector2 = size*0.5
		var ink: Color = get_theme_color(&"ink",&"LifeTokens")
		draw_circle(center,10,ink,true,-1,true)
		draw_circle(center,8,get_theme_color(&"green",&"LifeTokens"),true,-1,true)
		draw_polyline(PackedVector2Array([center+Vector2(-4,0),center+Vector2(-1,3),center+Vector2(4,-3)]),get_theme_color(&"paper",&"LifeTokens"),2,true)
