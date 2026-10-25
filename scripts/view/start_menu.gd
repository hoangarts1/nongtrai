## StartMenu — new-game and continue entry screen.
## API:
##   func configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable) -> void
extends PanelContainer

var _new_game_callback: Callable
var _continue_callback: Callable
var _name_box: VBoxContainer
var _settings_box: VBoxContainer
var _player_name: LineEdit
var _farm_name: LineEdit

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable) -> void:
	_new_game_callback = new_game_callback
	_continue_callback = continue_callback
	var continue_button: Button = get_node("MarginContainer/Column/Continue")
	continue_button.disabled = not SaveService.has_save()

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.name = "Column"
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var title: Label = Label.new()
	title.text = tr("UI_GAME_TITLE")
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	_name_box = VBoxContainer.new()
	_name_box.visible = false
	_player_name = LineEdit.new()
	_player_name.placeholder_text = tr("UI_DEFAULT_PLAYER")
	_farm_name = LineEdit.new()
	_farm_name.placeholder_text = tr("UI_DEFAULT_FARM")
	_name_box.add_child(_player_name)
	_name_box.add_child(_farm_name)
	column.add_child(_name_box)
	_settings_box = VBoxContainer.new()
	_settings_box.name = "Settings"
	_settings_box.visible = false
	var language: OptionButton = OptionButton.new()
	language.add_item(tr("UI_VIETNAMESE"))
	language.add_item(tr("UI_ENGLISH"))
	language.selected = 0 if Settings.get_locale() == "vi" else 1
	language.item_selected.connect(func(index: int) -> void: Settings.set_locale("vi" if index == 0 else "en"))
	_settings_box.add_child(language)
	_add_slider(_settings_box, tr("UI_MUSIC_VOLUME"), Settings.get_music_volume(), Settings.set_music_volume)
	_add_slider(_settings_box, tr("UI_EFFECTS_VOLUME"), Settings.get_effects_volume(), Settings.set_effects_volume)
	column.add_child(_settings_box)
	var new_button: Button = Button.new()
	new_button.text = tr("UI_MAIN_NEW_GAME")
	new_button.pressed.connect(_show_new_game_fields)
	column.add_child(new_button)
	var settings_button: Button = Button.new()
	settings_button.text = tr("UI_SETTINGS")
	settings_button.pressed.connect(func() -> void: _settings_box.visible = not _settings_box.visible)
	column.add_child(settings_button)
	var continue_button: Button = Button.new()
	continue_button.name = "Continue"
	continue_button.text = tr("UI_MAIN_CONTINUE")
	continue_button.pressed.connect(func() -> void: _continue_callback.call())
	column.add_child(continue_button)
	var exit_button: Button = Button.new()
	exit_button.text = tr("UI_MAIN_EXIT")
	exit_button.pressed.connect(func() -> void: get_tree().quit())
	column.add_child(exit_button)

func _show_new_game_fields() -> void:
	_name_box.visible = true
	var confirm: Button = Button.new()
	confirm.text = tr("UI_CONFIRM")
	confirm.pressed.connect(func() -> void:
		_new_game_callback.call(
			_player_name.text if not _player_name.text.is_empty() else tr("UI_DEFAULT_PLAYER"),
			_farm_name.text if not _farm_name.text.is_empty() else tr("UI_DEFAULT_FARM")
		)
		visible = false
	)
	_name_box.add_child(confirm)

func _add_slider(parent: VBoxContainer, label: String, value: float, callback: Callable) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	var caption: Label = Label.new()
	caption.text = label
	row.add_child(caption)
	var slider: HSlider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(callback)
	row.add_child(slider)
	parent.add_child(row)
