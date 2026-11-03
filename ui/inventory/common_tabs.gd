## LifeInventoryTabs — shared reference tabs, only implemented screens are enabled.
class_name LifeInventoryTabs
extends HBoxContainer

signal tab_requested(index: int)
var buttons: Array[Button] = []
var close_button: Button
var active: int = 0
signal close_requested()

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvRow")
	for index: int in range(LifeTabBar.KEYS.size()):
		var button: Button = Button.new()
		button.theme_type_variation = &"LifeInvTab"
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		button.disabled = index not in [0,1,2]
		button.pressed.connect(_request.bind(index))
		add_child(button)
		buttons.append(button)
	close_button = Button.new()
	close_button.name = "CloseInventory"
	close_button.theme_type_variation = &"LifeDanger"
	close_button.icon = UiIcons.get_icon(&"close")
	close_button.expand_icon = true
	close_button.custom_minimum_size = Vector2(44,44)
	close_button.pressed.connect(func() -> void: close_requested.emit())
	add_child(close_button)
	_refresh()

func set_active(index: int) -> void:
	active = index
	_refresh()

func _request(index: int) -> void:
	# Clicking the current native toggle must keep its selected-tab appearance.
	_refresh()
	tab_requested.emit(index)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	for index: int in range(buttons.size()):
		buttons[index].text = tr(String(LifeTabBar.KEYS[index]))
		buttons[index].tooltip_text = tr("INV_UNAVAILABLE") if buttons[index].disabled else buttons[index].text
		buttons[index].set_pressed_no_signal(index==active)
	if close_button != null:
		close_button.tooltip_text = tr("UI_CLOSE")
