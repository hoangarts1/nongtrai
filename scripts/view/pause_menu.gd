## PauseMenu — pause controls and settings overlay.
## API:
##   func configure(save_callback: Callable, load_callback: Callable, main_menu_callback: Callable) -> void
extends PanelContainer

var _save_callback: Callable
var _load_callback: Callable
var _main_menu_callback: Callable
var _settings_box: VBoxContainer

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()

func configure(save_callback: Callable, load_callback: Callable, main_menu_callback: Callable) -> void:
	_save_callback = save_callback
	_load_callback = load_callback
	_main_menu_callback = main_menu_callback

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func open() -> void:
	visible = true
	GameClock.paused = true
	get_tree().paused = false
	_set_player_locked(true)

func close() -> void:
	visible = false
	GameClock.paused = false
	_set_player_locked(false)

func _set_player_locked(locked: bool) -> void:
	var world: GrayBoxWorld = get_parent().get_node_or_null("GrayBoxWorld") as GrayBoxWorld
	if world != null:
		world.player.movement_enabled = not locked

func _build_ui() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	var title: Label = Label.new()
	title.text = tr("UI_PAUSE_TITLE")
	title.add_theme_font_size_override("font_size", 18)
	column.add_child(title)
	_add_button(column, tr("UI_RESUME"), close)
	_add_button(column, tr("UI_SAVE"), func() -> void: _save_callback.call())
	_add_button(column, tr("UI_LOAD"), func() -> void: _load_callback.call())
	_add_button(column, tr("UI_SETTINGS"), _toggle_settings)
	_add_button(column, tr("UI_EXIT_MENU"), func() -> void: _main_menu_callback.call())
	_settings_box = VBoxContainer.new()
	_settings_box.visible = false
	column.add_child(_settings_box)
	var language: OptionButton = OptionButton.new()
	language.name = "Language"
	language.add_item(tr("UI_VIETNAMESE"))
	language.add_item(tr("UI_ENGLISH"))
	language.selected = 0 if Settings.get_locale() == "vi" else 1
	language.item_selected.connect(func(index: int) -> void: Settings.set_locale("vi" if index == 0 else "en"))
	_settings_box.add_child(language)
	_add_slider(_settings_box, tr("UI_MUSIC_VOLUME"), Settings.get_music_volume(), Settings.set_music_volume)
	_add_slider(_settings_box, tr("UI_EFFECTS_VOLUME"), Settings.get_effects_volume(), Settings.set_effects_volume)

func _add_button(parent: VBoxContainer, label: String, callback: Callable) -> void:
	var button: Button = Button.new()
	button.text = label
	button.pressed.connect(callback)
	parent.add_child(button)

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

func _toggle_settings() -> void:
	_settings_box.visible = not _settings_box.visible
