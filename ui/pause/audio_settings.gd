## LifeAudioSettings — draft native sliders for existing preferences.
class_name LifeAudioSettings
extends VBoxContainer

var music: HSlider
var effects: HSlider
var music_value: Label
var effects_value: Label
var _music_label: Label
var _effects_label: Label
var _weather: CheckButton
var _note: Label
var _music_note: Label

func _ready() -> void:
	var first: HBoxContainer = HBoxContainer.new()
	add_child(first)
	_music_label = _caption(first,&"UI_MUSIC_VOLUME")
	music = _slider(first)
	music_value = _value_label(first)
	var second: HBoxContainer = HBoxContainer.new()
	add_child(second)
	_effects_label = _caption(second,&"UI_EFFECTS_VOLUME")
	effects = _slider(second)
	effects_value = _value_label(second)
	music.value_changed.connect(func(value: float) -> void: music_value.text = "%d%%" % roundi(value*100))
	effects.value_changed.connect(func(value: float) -> void: effects_value.text = "%d%%" % roundi(value*100))
	_music_note = LifePauseParts.label(self,&"PAUSE_MUSIC_NOTE",&"LifeText16")
	_weather = LifePauseParts.unavailable(self,&"PAUSE_WEATHER_AUDIO")
	_note = LifePauseParts.label(self,&"PAUSE_UNAVAILABLE",&"LifeText16")

func _caption(parent: Node, key: StringName) -> Label:
	var result: Label = LifePauseParts.label(parent,key)
	result.custom_minimum_size.x = 180
	result.size_flags_horizontal = Control.SIZE_FILL
	return result

func _value_label(parent: Node) -> Label:
	var result: Label = LifeHudParts.label(parent)
	result.custom_minimum_size.x = 52
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return result

func _slider(parent: Node) -> HSlider:
	var result: HSlider = preload("res://ui/components/slider_styled.tscn").instantiate() as HSlider
	result.min_value = 0.0
	result.max_value = 1.0
	result.step = 0.05
	result.custom_minimum_size = Vector2(80,44)
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(result)
	# Shared HSlider styles have zero track content height. A Theme-backed read-only
	# progress surface supplies the visible track while native HSlider keeps all input.
	var track: ProgressBar = ProgressBar.new()
	track.theme_type_variation = &"LifeProgressGreen"
	track.min_value = 0.0
	track.max_value = 1.0
	track.show_percentage = false
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	track.show_behind_parent = true
	result.add_child(track)
	track.anchor_left = 0.0
	track.anchor_right = 1.0
	track.offset_left = 0
	track.offset_right = 0
	track.anchor_top = 0.5
	track.anchor_bottom = 0.5
	track.offset_top = -10
	track.offset_bottom = 10
	result.value_changed.connect(func(value: float) -> void: track.value = value)
	return result

func set_values(music_volume: float, effects_volume: float) -> void:
	music.value = music_volume
	effects.value = effects_volume
	music_value.text = "%d%%" % roundi(music.value*100)
	effects_value.text = "%d%%" % roundi(effects.value*100)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _note != null:
		_music_label.text = tr("UI_MUSIC_VOLUME")
		_effects_label.text = tr("UI_EFFECTS_VOLUME")
		_music_note.text = tr("PAUSE_MUSIC_NOTE")
		LifePauseParts.refresh_unavailable(_weather,&"PAUSE_WEATHER_AUDIO")
		_note.text = tr("PAUSE_UNAVAILABLE")
