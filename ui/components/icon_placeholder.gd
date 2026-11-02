## LifeIconPlaceholder — replaceable 32px circle/initial for missing final icon assets.
class_name LifeIconPlaceholder
extends Control

@export var text_key: StringName = &"UI_KIT_ICON"
@export var tone: StringName = &"wood"

func _ready() -> void:
	custom_minimum_size = Vector2(32,32)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	LifeTheme.bind(self)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED or what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var color: Color = get_theme_color(tone,&"LifeTokens")
	draw_circle(center,15,get_theme_color(&"ink",&"LifeTokens"))
	draw_circle(center,12,color)
	draw_circle(center+Vector2(-4,-5),3,color.lightened(0.3))
	var initial: String = tr(String(text_key)).left(1).to_upper()
	var font: Font = get_theme_default_font()
	var width: float = font.get_string_size(initial,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x
	draw_string(font,center+Vector2(-width*0.5,5),initial,HORIZONTAL_ALIGNMENT_LEFT,-1,16,get_theme_color(&"ink",&"LifeTokens"))
