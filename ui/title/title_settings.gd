## LifeTitleSettings — reusable ISO-7 pages with transient supported drafts.
class_name LifeTitleSettings
extends VBoxContainer

signal cancelled()
var panel: LifeSettingsPanel
var back_button: Button

func _ready() -> void:
	panel = preload("res://ui/pause/settings_panel.tscn").instantiate() as LifeSettingsPanel
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(panel)
	panel.applied.connect(apply)
	panel.defaulted.connect(defaults)
	panel.audio.music.value_changed.connect(_changed)
	panel.audio.effects.value_changed.connect(_changed)
	panel.game.language.item_selected.connect(func(_index: int) -> void: panel.show_status(&"PAUSE_DRAFT_NOTE"))
	back_button = LifeTitleParts.button(self,&"UI_BACK")
	back_button.pressed.connect(func() -> void: cancelled.emit())

func begin() -> void:
	panel.audio.set_values(Settings.get_music_volume(),Settings.get_effects_volume())
	panel.game.set_locale(Settings.get_locale())
	panel.controls.refresh()
	panel.select_tab(0)
	panel.show_status(&"PAUSE_DRAFT_NOTE")

func apply() -> void:
	Settings.set_music_volume(panel.audio.music.value)
	Settings.set_effects_volume(panel.audio.effects.value)
	Settings.set_locale(panel.game.get_locale())
	panel.show_status(&"PAUSE_APPLIED")

func defaults() -> void:
	panel.audio.set_values(1.0,1.0)
	panel.game.set_locale("vi")
	panel.show_status(&"PAUSE_DEFAULT_DRAFT")

func _changed(_value: float) -> void:
	panel.show_status(&"PAUSE_DRAFT_NOTE")

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and back_button != null:
		back_button.text = tr("UI_BACK")
