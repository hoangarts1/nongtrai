## LifeMachineHeader — compact native shop heading, no state ownership.
class_name LifeMachineHeader
extends HBoxContainer

signal closed()
signal land_requested()
signal director_requested()
var director_button: Button
var banner: LifeBanner
var land_button: Button
var close_button: Button

func _ready() -> void:
	theme_type_variation = &"LifeHudRow"
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	banner = preload("res://ui/components/banner.tscn").instantiate() as LifeBanner
	banner.tone = &"red"
	banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(banner)
	land_button = LifeMachinePresenter.button(self, &"LAND_TITLE", "land")
	director_button = LifeMachinePresenter.button(self, &"DIR_DEBUG_ENTRY", "director")
	close_button = LifeMachinePresenter.button(self, &"UI_CLOSE", "close", &"LifeDanger")
	close_button.custom_minimum_size.x = 96
	for button: Button in [land_button, director_button, close_button]:
		# A wrapping Button reports only its margins as minimum width. Shrinking
		# that width wrapped every letter and stretched the entire header.
		button.autowrap_mode = TextServer.AUTOWRAP_OFF
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	director_button.pressed.connect(func() -> void: director_requested.emit())
	land_button.pressed.connect(func() -> void: land_requested.emit())
	close_button.pressed.connect(func() -> void: closed.emit())

func display(operation_mode: bool) -> void:
	banner.set_caption(&"MUI_OPERATION_TITLE" if operation_mode else &"UI_MACHINE_SHOP_TITLE")
	director_button.visible = OS.is_debug_build() and not operation_mode
	director_button.text = tr("DIR_DEBUG_ENTRY")
	land_button.visible = not operation_mode
	land_button.text = tr("LAND_TITLE")
	close_button.text = tr("UI_CLOSE")
