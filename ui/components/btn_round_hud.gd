## LifeBtnRoundHud — native round HUD button with an InputMap-derived key hint.
class_name LifeBtnRoundHud
extends Button

var _icon_view: LifeIconPlaceholder
var hint: Label
var _action: StringName = &"open_inventory"

func _ready() -> void:
	LifeTheme.bind(self,&"LifeRound")
	var column: VBoxContainer = VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(column)
	_icon_view = LifeIconPlaceholder.new()
	_icon_view.name = "Icon"
	_icon_view.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	column.add_child(_icon_view)
	hint = Label.new()
	hint.name = "Key"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.theme_type_variation = &"LifeSmall"
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(hint)
	set_hint(_action)

func set_hint(action: StringName) -> void:
	_action = action
	if hint != null:
		hint.text = LifeKeyHint.action_text(action)
		_icon_view.text_key = &"UI_KIT_ICON_BAG" if action==&"open_inventory" else (&"UI_KIT_ICON_QUEST" if action==&"open_journal" else &"UI_SETTINGS")
		_icon_view.queue_redraw()
