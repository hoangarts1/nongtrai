## LifeTitleActions — reference01 actions emit requests through native buttons.
class_name LifeTitleActions
extends VBoxContainer

signal requested(id: StringName)
var continue_button: Button
var new_game_button: Button
var settings_button: Button
var exit_button: Button

func _ready() -> void:
	continue_button = _action(self,&"UI_MAIN_CONTINUE",&"continue",&"LifePrimary")
	continue_button.custom_minimum_size.y = 60
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	new_game_button = _action(row,&"UI_MAIN_NEW_GAME",&"new")
	settings_button = _action(row,&"UI_SETTINGS",&"settings")
	exit_button = _action(self,&"UI_MAIN_EXIT",&"exit",&"LifeDanger")
	exit_button.custom_minimum_size.y = 48

func _action(parent: Node, key: StringName, id: StringName, tone: StringName = &"LifeSecondary") -> Button:
	var result: Button = LifeTitleParts.button(parent,key,tone)
	result.pressed.connect(func() -> void: requested.emit(id))
	return result

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and exit_button != null:
		continue_button.text = tr("UI_MAIN_CONTINUE")
		new_game_button.text = tr("UI_MAIN_NEW_GAME")
		settings_button.text = tr("UI_SETTINGS")
		exit_button.text = tr("UI_MAIN_EXIT")
