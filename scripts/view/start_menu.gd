## StartMenu — compatible adapter for the modular reference01 title.
## API:
##   signal appearance_selected(appearance: Dictionary)
##   func configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable) -> void
##   func get_appearance_selection() -> Dictionary
##   func handle_back() -> bool
class_name StartMenu
extends PanelContainer

signal appearance_selected(appearance: Dictionary)
var screen: LifeTitleScreen
var presenter: LifeTitlePresenter = LifeTitlePresenter.new()
var _name_box: VBoxContainer
var _settings_box: VBoxContainer
var _title_logo: Label
var _logo_phase: float = 0.0

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudClearPanel")
	mouse_filter = Control.MOUSE_FILTER_STOP
	screen = preload("res://ui/title/title_screen.tscn").instantiate() as LifeTitleScreen
	add_child(screen)
	_name_box = screen.profile
	_settings_box = screen.settings
	_title_logo = screen.logo
	presenter.configure(self,screen,Callable(),Callable(),Callable())
	screen.actions.requested.connect(presenter.request)
	screen.profile.submitted.connect(_submit_new_game)
	screen.profile.cancelled.connect(_hide_new_game_fields)
	screen.settings.cancelled.connect(_show_title)
	visibility_changed.connect(_on_visibility_changed)

func configure(new_game_callback: Callable, continue_callback: Callable, exit_callback: Callable) -> void:
	presenter.configure(self,screen,new_game_callback,continue_callback,exit_callback)
	refresh_continue()

func apply_chibi_style() -> void:
	_title_logo.text = tr("UI_GAME_TITLE").to_upper()
	call_deferred("_focus_primary_control")

func _process(delta: float) -> void:
	_logo_phase += delta
	if _title_logo == null or not _title_logo.is_visible_in_tree():
		return
	_title_logo.pivot_offset = _title_logo.size*0.5
	_title_logo.scale = Vector2.ONE*(1.0+sin(_logo_phase*1.45)*0.012)

func refresh_continue() -> void:
	presenter.refresh()

func _on_visibility_changed() -> void:
	if visible:
		_show_title()

func _show_title() -> void:
	screen.set_mode(LifeTitleScreen.Mode.TITLE)
	refresh_continue()
	call_deferred("_focus_primary_control")

func _show_new_game_fields() -> void:
	if screen.mode == LifeTitleScreen.Mode.PROFILE:
		return
	screen.profile.reset_submission()
	screen.set_mode(LifeTitleScreen.Mode.PROFILE)
	call_deferred("_focus_player_name")

func _hide_new_game_fields() -> void:
	_show_title()

func _submit_new_game() -> void:
	presenter.submit()

func _toggle_settings() -> void:
	if screen.mode == LifeTitleScreen.Mode.SETTINGS:
		_show_title()
	else:
		screen.settings.begin()
		screen.set_mode(LifeTitleScreen.Mode.SETTINGS)
		call_deferred("_focus_settings")

func get_appearance_selection() -> Dictionary:
	return screen.profile.get_selection()

func handle_back() -> bool:
	if screen.mode == LifeTitleScreen.Mode.TITLE:
		return false
	_show_title()
	return true

func _focus_primary_control() -> void:
	if visible and screen.mode == LifeTitleScreen.Mode.TITLE:
		screen.actions.new_game_button.grab_focus()

func _focus_player_name() -> void:
	if visible and _name_box.visible:
		screen.profile.player_name.grab_focus()

func _focus_settings() -> void:
	if visible and _settings_box.visible:
		if screen.settings.panel.active_tab == 3:
			screen.settings.panel.game.language.grab_focus()
		else:
			screen.settings.panel.audio.music.grab_focus()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and screen != null and screen.latest != null and screen.latest.coins != null:
		presenter.refresh()
