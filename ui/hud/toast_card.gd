## LifeHudToastCard — one read-only result message.
class_name LifeHudToastCard
extends PanelContainer

var caption: Label
var symbol: TextureRect

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudToast")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	symbol = LifeHudParts.texture(row,null,30)
	caption = LifeHudParts.label(row,&"LifeHudToastText")
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func display(message: String, icon_id: StringName) -> void:
	caption.text = message
	symbol.texture = UiIcons.get_icon(icon_id)
