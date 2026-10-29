## StartMenu — new-game and continue entry screen.
## API:
##   signal appearance_selected(appearance: Dictionary)
##   func configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable) -> void
##   func get_appearance_selection() -> Dictionary
class_name StartMenu
extends PanelContainer

signal appearance_selected(appearance: Dictionary)

const CHARACTER_CATALOG: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")

var _new_game_callback: Callable
var _continue_callback: Callable
var _exit_callback: Callable
var _name_box: VBoxContainer
var _settings_box: VBoxContainer
var _player_name: LineEdit
var _farm_name: LineEdit
var _save_summary: Label
var _appearance_grid: GridContainer
var _hair_style: OptionButton
var _skin_tone: OptionButton
var _hair_color: OptionButton
var _outfit_color: OptionButton
var _main_actions: Array[Button] = []
var _title_logo: Label
var _logo_phase: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)

func apply_chibi_style() -> void:
	var column: VBoxContainer = get_node("MarginContainer/Column")
	var title: Label = column.get_child(0) as Label
	_title_logo = title
	title.text = tr("UI_GAME_TITLE").to_upper()
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", _palette_color(&"outline", Color("4b3c47")))
	title.add_theme_color_override("font_outline_color", _palette_color(&"sunlight", Color("fff3cf")))
	title.add_theme_constant_override("outline_size", 2)
	_save_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_save_summary.add_theme_font_size_override("font_size", 15)
	var subtitle: Label = column.get_node_or_null("Tagline") as Label
	if subtitle == null:
		subtitle = Label.new()
		subtitle.name = "Tagline"
		subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(subtitle)
		column.move_child(subtitle, 1)
	subtitle.text = tr("UI_TITLE_TAGLINE")
	subtitle.add_theme_color_override("font_color", Color(_palette_color(&"outline", Color("4b3c47")), 0.82))
	for child: Node in column.get_children():
		if child is Button:
			var button: Button = child as Button
			var icon: StringName = &"play"
			if button.text == tr("UI_SETTINGS"):
				icon = &"settings"
			elif button.text == tr("UI_MAIN_EXIT"):
				icon = &"close"
			UiIcons.decorate(button, icon)
	call_deferred("_focus_primary_control")

func _process(delta: float) -> void:
	_logo_phase += delta
	if _title_logo == null or not _title_logo.is_visible_in_tree():
		return
	_title_logo.pivot_offset = _title_logo.size * 0.5
	var scale_amount: float = 1.0 + sin(_logo_phase * 1.45) * 0.012
	_title_logo.scale = Vector2(scale_amount, scale_amount)

func _on_visibility_changed() -> void:
	if visible:
		call_deferred("_focus_primary_control")

func configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable) -> void:
	_new_game_callback = new_game_callback
	_continue_callback = continue_callback
	_exit_callback = exit_callback
	refresh_continue()

func refresh_continue() -> void:
	var continue_button: Button = get_node("MarginContainer/Column/Continue")
	continue_button.disabled = SaveService.load_latest().is_empty()
	_save_summary.text = _continue_summary()

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
	_save_summary = Label.new()
	_save_summary.name = "SaveSummary"
	_save_summary.text = _continue_summary()
	column.add_child(_save_summary)
	_name_box = VBoxContainer.new()
	_name_box.visible = false
	_player_name = LineEdit.new()
	_player_name.placeholder_text = tr("UI_DEFAULT_PLAYER")
	_farm_name = LineEdit.new()
	_farm_name.placeholder_text = tr("UI_DEFAULT_FARM")
	_name_box.add_child(_player_name)
	_name_box.add_child(_farm_name)
	_appearance_grid = GridContainer.new()
	_appearance_grid.name = "AppearanceGrid"
	_appearance_grid.columns = 2
	_appearance_grid.add_theme_constant_override("h_separation", 12)
	_appearance_grid.add_theme_constant_override("v_separation", 6)
	_build_appearance_fields()
	_name_box.add_child(_appearance_grid)
	var confirm: Button = Button.new()
	confirm.name = "ConfirmNewGame"
	confirm.text = tr("UI_CONFIRM")
	confirm.pressed.connect(_submit_new_game)
	_name_box.add_child(confirm)
	var back: Button = Button.new()
	back.name = "BackToTitle"
	back.text = tr("UI_BACK")
	back.pressed.connect(_hide_new_game_fields)
	_name_box.add_child(back)
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
	new_button.name = "NewGame"
	new_button.text = tr("UI_MAIN_NEW_GAME")
	new_button.pressed.connect(_show_new_game_fields)
	column.add_child(new_button)
	_main_actions.append(new_button)
	var settings_button: Button = Button.new()
	settings_button.name = "SettingsButton"
	settings_button.text = tr("UI_SETTINGS")
	settings_button.pressed.connect(_toggle_settings)
	column.add_child(settings_button)
	_main_actions.append(settings_button)
	var continue_button: Button = Button.new()
	continue_button.name = "Continue"
	continue_button.text = tr("UI_MAIN_CONTINUE")
	continue_button.pressed.connect(func() -> void: _continue_callback.call())
	column.add_child(continue_button)
	_main_actions.append(continue_button)
	var exit_button: Button = Button.new()
	exit_button.name = "Exit"
	exit_button.text = tr("UI_MAIN_EXIT")
	exit_button.pressed.connect(func() -> void: _exit_callback.call())
	column.add_child(exit_button)
	_main_actions.append(exit_button)

func _show_new_game_fields() -> void:
	_settings_box.hide()
	if _name_box.visible:
		return
	_name_box.visible = true
	_set_main_actions_visible(false)
	call_deferred("_focus_player_name")

func _hide_new_game_fields() -> void:
	_name_box.hide()
	_set_main_actions_visible(true)
	call_deferred("_focus_primary_control")

func _submit_new_game() -> void:
	appearance_selected.emit(get_appearance_selection())
	if _new_game_callback.is_valid():
		_new_game_callback.call(
			_player_name.text if not _player_name.text.is_empty() else tr("UI_DEFAULT_PLAYER"),
			_farm_name.text if not _farm_name.text.is_empty() else tr("UI_DEFAULT_FARM")
		)
	visible = false

func _toggle_settings() -> void:
	_hide_new_game_fields()
	_settings_box.visible = not _settings_box.visible
	if _settings_box.visible:
		call_deferred("_focus_settings")

func get_appearance_selection() -> Dictionary:
	return _normalize_appearance_selection({
		"hair_style": _hair_style.get_item_metadata(_hair_style.selected),
		"skin_index": _skin_tone.selected,
		"hair_color_index": _hair_color.selected,
		"outfit_color_index": _outfit_color.selected
	})

func _build_appearance_fields() -> void:
	var options_variant: Variant = CHARACTER_CATALOG.call("get_player_customization")
	var options: Dictionary = options_variant if options_variant is Dictionary else {}
	_hair_style = _add_appearance_option("HairStyle", tr("UI_APPEARANCE_HAIR_STYLE"))
	var styles: PackedStringArray = options.get("hair_styles", PackedStringArray())
	for style: String in styles:
		_hair_style.add_item(tr("UI_APPEARANCE_HAIR_%s" % style.to_upper()))
		_hair_style.set_item_metadata(_hair_style.item_count - 1, style)
	_skin_tone = _add_appearance_option("SkinTone", tr("UI_APPEARANCE_SKIN_TONE"))
	_hair_color = _add_appearance_option("HairColor", tr("UI_APPEARANCE_HAIR_COLOR"))
	_outfit_color = _add_appearance_option("OutfitColor", tr("UI_APPEARANCE_OUTFIT_COLOR"))
	var skin_tones: Array = options.get("skin_tones", []) as Array
	var hair_colors: Array = options.get("hair_colors", []) as Array
	var outfit_colors: Array = options.get("outfit_colors", []) as Array
	for index: int in range(skin_tones.size()):
		_skin_tone.add_item(tr("UI_APPEARANCE_OPTION_NUMBER") % [tr("UI_APPEARANCE_SKIN_TONE"), index + 1])
	for index: int in range(hair_colors.size()):
		_hair_color.add_item(tr("UI_APPEARANCE_OPTION_NUMBER") % [tr("UI_APPEARANCE_HAIR_COLOR"), index + 1])
	for index: int in range(outfit_colors.size()):
		_outfit_color.add_item(tr("UI_APPEARANCE_OPTION_NUMBER") % [tr("UI_APPEARANCE_OUTFIT_COLOR"), index + 1])

func _add_appearance_option(option_name: String, caption: String) -> OptionButton:
	var label: Label = Label.new()
	label.name = "%sLabel" % option_name
	label.text = caption
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_appearance_grid.add_child(label)
	var option: OptionButton = OptionButton.new()
	option.name = option_name
	option.custom_minimum_size.y = 40.0
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_appearance_grid.add_child(option)
	return option

func _set_main_actions_visible(is_visible: bool) -> void:
	for button: Button in _main_actions:
		button.visible = is_visible

func _normalize_appearance_selection(selection: Dictionary) -> Dictionary:
	var normalized: Variant = CHARACTER_CATALOG.call("normalize_player_customization", selection)
	return normalized if normalized is Dictionary else {}

func _continue_summary() -> String:
	var summary: Dictionary = SaveService.get_latest_summary()
	if summary.is_empty():
		return ""
	return tr("UI_TITLE_SAVE_SUMMARY") % [
		summary.get("farm_name", ""),
		summary.get("day_index", 1)
	]

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

func _focus_primary_control() -> void:
	if not visible or _name_box == null or _settings_box == null:
		return
	if _name_box.visible:
		_focus_player_name()
		return
	if _settings_box.visible:
		_focus_settings()
		return
	var new_game: Button = get_node_or_null("MarginContainer/Column/NewGame") as Button
	if new_game != null:
		new_game.grab_focus()

func _focus_player_name() -> void:
	if visible and _name_box != null and _name_box.visible and _player_name != null:
		_player_name.grab_focus()

func _focus_settings() -> void:
	if not visible or _settings_box == null or not _settings_box.visible:
		return
	var language: Control = _settings_box.get_child(0) as Control if _settings_box.get_child_count() > 0 else null
	if language != null:
		language.grab_focus()

func _palette_color(role: StringName, fallback: Color) -> Color:
	var palette: Resource = ChibiMaterialFactory.get_palette()
	if palette == null:
		return fallback
	var value: Variant = palette.call("get_color", role)
	return value if value is Color else fallback
