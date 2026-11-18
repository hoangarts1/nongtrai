## LifeAudioBusRouter — native bus gains from accepted preferences, no world state.
## API: static is_layout_ready()->bool; apply_accepted()->bool.
class_name LifeAudioBusRouter
extends RefCounted

static func is_layout_ready() -> bool:
	if AudioServer.get_bus_index(&"Master") != 0:
		return false
	for name: StringName in [&"Music", &"SFX", &"Ambience", &"UI"]:
		var index: int = AudioServer.get_bus_index(name)
		if index <= 0 or AudioServer.get_bus_send(index) != &"Master":
			return false
	return true

func apply_accepted() -> bool:
	# Validate the whole route first; do not change unrelated or incomplete layouts.
	if not is_layout_ready():
		return false
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Music"), Settings.get_music_volume())
	for name: StringName in [&"Ambience", &"UI"]:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(name), Settings.get_effects_volume())
	# Existing SFX players already apply effects_volume locally.
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"SFX"), 1.0)
	return true
