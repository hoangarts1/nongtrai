## TutorialPanel — first-run and repeatable controls help.
## API:
##   func open_help() -> void
##   func close_help() -> void
##   func is_help_open() -> bool
class_name TutorialPanel
extends PanelContainer

var _player: Player
var _check: CheckButton
var _close_other_modal: Callable

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_ui()

func configure(player: Player) -> void:
	_player = player
	if not Settings.is_tutorial_dismissed():
		open_help()

func configure_modal(close_other_modal: Callable) -> void:
	_close_other_modal = close_other_modal

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_help"):
		if visible:
			close_help()
		else:
			open_help()
		get_viewport().set_input_as_handled()

func open_help() -> void:
	if _close_other_modal.is_valid():
		_close_other_modal.call()
	visible = true
	if _player != null:
		_player.movement_enabled = false

func close_help() -> void:
	if _check != null and _check.button_pressed:
		Settings.set_tutorial_dismissed(true)
	visible = false
	if _player != null and not GameClock.is_sleeping():
		_player.movement_enabled = true

func is_help_open() -> bool:
	return visible

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.name = "MarginContainer"
	for side: StringName in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 20)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.name = "VBoxContainer"
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	var title: Label = Label.new()
	title.text = tr("UI_HELP_TITLE")
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	var instructions: Label = Label.new()
	instructions.name = "Instructions"
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instructions.text = _build_instruction_text()
	column.add_child(instructions)
	_check = CheckButton.new()
	_check.name = "DoNotShowAgain"
	_check.text = tr("UI_HELP_DONT_SHOW")
	column.add_child(_check)
	var understood: Button = Button.new()
	understood.name = "Understood"
	understood.text = tr("UI_HELP_UNDERSTOOD")
	understood.pressed.connect(close_help)
	column.add_child(understood)

func _build_instruction_text() -> String:
	var lines: Array[String] = [
		tr("UI_HELP_MOVE") % _keys_for_action(&"move_up", &"move_down", &"move_left", &"move_right"),
		tr("UI_HELP_SPRINT") % _key_for_action(&"sprint"),
		tr("UI_HELP_HOTBAR") % _keys_for_hotbar(),
		tr("UI_HELP_TOOL") % _key_for_action(&"use_tool"),
		tr("UI_HELP_SLEEP") % _key_for_action(&"interact"),
		tr("UI_HELP_INVENTORY") % _key_for_action(&"open_inventory"),
		tr("UI_HELP_TARGET_COLORS")
	]
	if OS.is_debug_build():
		lines.append(tr("UI_HELP_DEBUG") % _key_for_action(&"toggle_debug_menu"))
	return "\n".join(lines)

func _key_for_action(action: StringName) -> String:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	return events[0].as_text() if not events.is_empty() else String(action)

func _keys_for_action(first: StringName, second: StringName, third: StringName, fourth: StringName) -> String:
	return "%s/%s %s/%s" % [_key_for_action(first), _key_for_action(second), _key_for_action(third), _key_for_action(fourth)]

func _keys_for_hotbar() -> String:
	return "%s-%s" % [_key_for_action(&"hotbar_1"), _key_for_action(&"hotbar_9")]
