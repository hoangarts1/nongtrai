## LifePauseActions — reference-14 left wood/paper action card.
class_name LifePauseActions
extends LifeHudFrame

signal requested(id: StringName)
var resume_button: Button
var save_button: Button
var load_button: Button
var settings_button: Button
var menu_button: Button
var summary: Label
var _title: Label

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	var banner: PanelContainer = PanelContainer.new()
	banner.theme_type_variation = &"LifeBannerRed"
	column.add_child(banner)
	_title = LifePauseParts.label(banner,&"UI_PAUSE_TITLE",&"LifeDayTitle")
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var space: Control = Control.new()
	space.custom_minimum_size.y = 24
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(space)
	resume_button = _action(column,&"UI_RESUME",&"resume",&"LifePrimary")
	save_button = _action(column,&"UI_SAVE",&"save")
	settings_button = _action(column,&"UI_SETTINGS",&"settings",&"LifeAccent")
	menu_button = _action(column,&"UI_EXIT_MENU",&"menu")
	load_button = _action(column,&"UI_LOAD",&"load")
	for button: Button in [resume_button,save_button,settings_button,menu_button]:
		button.custom_minimum_size.y = 52
	var fill: Control = Control.new()
	fill.size_flags_vertical = Control.SIZE_EXPAND_FILL
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(fill)
	summary = LifePauseParts.label(column,&"PAUSE_NO_SAVE",&"LifeText16")
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	refresh()

func _action(parent: Node, key: StringName, id: StringName, tone: StringName = &"LifeSecondary") -> Button:
	var result: Button = LifePauseParts.button(parent,key,tone)
	result.pressed.connect(func() -> void: requested.emit(id))
	return result

func refresh() -> void:
	_title.text = tr("UI_PAUSE_TITLE")
	resume_button.text = tr("UI_RESUME")
	save_button.text = tr("UI_SAVE")
	load_button.text = tr("UI_LOAD")
	settings_button.text = tr("UI_SETTINGS")
	menu_button.text = tr("UI_EXIT_MENU")

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and summary != null:
		refresh()
