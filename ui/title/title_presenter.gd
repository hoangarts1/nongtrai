## LifeTitlePresenter — latest-save display and existing start-flow requests.
class_name LifeTitlePresenter
extends RefCounted

var _menu: StartMenu
var _screen: LifeTitleScreen
var _start: Callable
var _resume: Callable
var _exit: Callable

func configure(menu: StartMenu, screen: LifeTitleScreen, start: Callable, resume: Callable, exit: Callable) -> void:
	_menu = menu
	_screen = screen
	_start = start
	_resume = resume
	_exit = exit

func refresh() -> void:
	var inspected: Dictionary = SaveService.inspect_latest()
	var payload: Dictionary = inspected.payload
	_screen.latest.display(payload)
	_screen.display_save_report(inspected.report)
	_screen.actions.continue_button.disabled = payload.is_empty()
	var meta: Dictionary = LifeTitleParts.dictionary(payload.get("meta",{}))
	var version: String = LifeTitleParts.text(meta,&"game_version")
	if version.is_empty():
		var configured: Variant = ProjectSettings.get_setting("application/config/version","")
		version = configured if configured is String else ""
	_screen.display_version(version)

func request(id: StringName) -> void:
	match id:
		&"new":
			_menu.call("_show_new_game_fields")
		&"settings":
			_menu.call("_toggle_settings")
		&"continue":
			refresh()
			if not _screen.actions.continue_button.disabled and _resume.is_valid():
				_resume.call()
		&"exit":
			if _exit.is_valid():
				_exit.call()

func submit() -> void:
	if not _menu.visible or _screen.mode != LifeTitleScreen.Mode.PROFILE or not _screen.profile.begin_submission():
		return
	_menu.appearance_selected.emit(_screen.profile.get_selection())
	if _start.is_valid():
		_start.call(
			_screen.profile.player_name.text if not _screen.profile.player_name.text.is_empty() else TranslationServer.translate(&"UI_DEFAULT_PLAYER"),
			_screen.profile.farm_name.text if not _screen.profile.farm_name.text.is_empty() else TranslationServer.translate(&"UI_DEFAULT_FARM"))
	_menu.hide()
