## LifePausePresenter — transient preference drafts and callback result display.
class_name LifePausePresenter
extends RefCounted

var _menu: PanelContainer
var _shell: LifePauseShell
var _save: Callable
var _load: Callable
var _exit: Callable

func configure(menu: PanelContainer, shell: LifePauseShell, save: Callable, load: Callable, exit: Callable) -> void:
	_menu = menu
	_shell = shell
	_save = save
	_load = load
	_exit = exit

func begin() -> void:
	_shell.settings.audio.set_values(Settings.get_music_volume(),Settings.get_effects_volume())
	_shell.settings.game.set_locale(Settings.get_locale())
	_shell.settings.controls.refresh()
	_shell.settings.select_tab(0)
	show_result(&"PAUSE_DRAFT_NOTE")
	refresh_summary()

func apply() -> void:
	Settings.set_music_volume(_shell.settings.audio.music.value)
	Settings.set_effects_volume(_shell.settings.audio.effects.value)
	Settings.set_locale(_shell.settings.game.get_locale())
	show_result(&"PAUSE_APPLIED")
	refresh_summary()

func defaults() -> void:
	_shell.settings.audio.set_values(1.0,1.0)
	_shell.settings.game.set_locale("vi")
	show_result(&"PAUSE_DEFAULT_DRAFT")

func request(id: StringName) -> void:
	match id:
		&"resume":
			_menu.call("close")
		&"settings":
			_shell.settings.select_tab(0)
			_shell.settings.tabs[0].grab_focus()
		&"save":
			var saved: bool = _save.is_valid() and _save.call() == true
			show_result(&"UI_SAVED" if saved else &"PAUSE_SAVE_FAILED")
			refresh_summary()
		&"load":
			var loaded: bool = _load.is_valid() and _load.call() == true
			show_result(&"PAUSE_LOADED" if loaded else &"PAUSE_LOAD_FAILED")
			refresh_summary()
		&"menu":
			if not _exit.is_valid() or _exit.call() != true:
				show_result(&"PAUSE_SAVE_FAILED")

func show_result(key: StringName) -> void:
	_shell.settings.show_status(key)

func refresh_summary() -> void:
	var summary: Dictionary = SaveService.get_latest_summary()
	_shell.actions.summary.text = TranslationServer.translate(&"PAUSE_NO_SAVE") if summary.is_empty() else TranslationServer.translate(&"PAUSE_SAVE_SUMMARY") % [int(summary.get("day_index",1)),String(summary.get("saved_at",""))]
