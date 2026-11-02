## LifeTabBar — five native view tabs; emits a request, with no gameplay navigation.
class_name LifeTabBar
extends HBoxContainer

signal tab_requested(index: int)
const KEYS: Array[StringName] = [&"UI_KIT_TAB_BAG",&"UI_KIT_TAB_CHARACTER",&"UI_KIT_TAB_QUEST",&"UI_KIT_TAB_CALENDAR",&"UI_KIT_TAB_MAP"]
var buttons: Array[Button] = []
var active: int = 0

func _ready() -> void:
	LifeTheme.bind(self)
	for index: int in range(KEYS.size()):
		var button: Button = Button.new()
		button.name = "Tab_%d" % index
		button.text = tr(String(KEYS[index]))
		button.theme_type_variation = &"LifeTab"
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_request.bind(index))
		add_child(button)
		buttons.append(button)
	set_active(active)

func set_active(index: int) -> void:
	active = clampi(index,0,KEYS.size()-1)
	for button_index: int in range(buttons.size()):
		buttons[button_index].set_pressed_no_signal(button_index == active)

func _request(index: int) -> void:
	set_active(index)
	tab_requested.emit(index)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		for index: int in range(buttons.size()):
			buttons[index].text = tr(String(KEYS[index]))
