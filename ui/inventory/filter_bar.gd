## LifeInventoryFilters — metadata category requests; no inventory mutation.
class_name LifeInventoryFilters
extends HBoxContainer

signal filter_requested(category: StringName)
const CATEGORIES: Array[StringName] = [&"",&"seed",&"produce",&"tool",&"material"]
const KEYS: Array[StringName] = [&"INV_FILTER_ALL",&"INV_CATEGORY_SEED",&"INV_CATEGORY_PRODUCE",&"INV_CATEGORY_TOOL",&"INV_CATEGORY_MATERIAL"]
var buttons: Array[Button] = []
var active: StringName = &""

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvRow")
	for index: int in range(CATEGORIES.size()):
		var button: Button = Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void: filter_requested.emit(CATEGORIES[index]))
		add_child(button)
		buttons.append(button)
	_refresh()

func set_active(category: StringName) -> void:
	active = category
	_refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	for index: int in range(buttons.size()):
		buttons[index].text = tr(String(KEYS[index]))
		buttons[index].theme_type_variation = &"LifeInvFilterActive" if active==CATEGORIES[index] else &"LifeInvFilter"
