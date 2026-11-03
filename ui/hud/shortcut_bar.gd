## LifeHudShortcutBar — supported round shortcut controls, no dead calendar/map buttons.
class_name LifeHudShortcutBar
extends HBoxContainer

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudRow")
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func create_button(id: StringName, title: String, action: StringName) -> Button:
	var column: VBoxContainer = VBoxContainer.new()
	column.theme_type_variation = &"LifeHudShortcutColumn"
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(column)
	var button: Button = Button.new()
	button.name = String(id)
	button.theme_type_variation = &"LifeHudRound"
	button.custom_minimum_size = Vector2(48,48)
	button.icon = UiIcons.get_icon(&"backpack" if id==&"inventory" else (&"settings" if id==&"pause" else id))
	button.expand_icon = true
	button.tooltip_text = title
	column.add_child(button)
	var key: Label = LifeHudParts.label(column,&"LifeHudKey")
	key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key.text = "B" if id==&"inventory" else (tr("HUD_KEY_ESCAPE") if id==&"pause" else LifeKeyHint.action_text(action))
	return button
