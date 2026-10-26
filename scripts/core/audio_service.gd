## AudioService — optional original effect playback for existing presentation events.
## API:
##   func play_sound(sound_id: StringName) -> void
##   func get_sound_path(sound_id: StringName) -> String
extends Node

const AUDIO_DIRECTORY: String = "res://assets/audio/"
const AUDIO_EXTENSIONS: Array[String] = [".ogg", ".wav"]

func play_sound(sound_id: StringName) -> void:
	var path: String = get_sound_path(sound_id)
	if path.is_empty():
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = linear_to_db(maxf(0.001, Settings.get_effects_volume()))
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func get_sound_path(sound_id: StringName) -> String:
	for extension: String in AUDIO_EXTENSIONS:
		var path: String = "%s%s%s" % [AUDIO_DIRECTORY, String(sound_id), extension]
		if ResourceLoader.exists(path):
			return path
	return ""
