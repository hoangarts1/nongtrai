## AudioService — optional data-driven placeholder audio playback.
## API:
##   func play_sound(sound_id: StringName) -> void
extends Node

const AUDIO_DIRECTORY: String = "res://assets/audio/"

func play_sound(sound_id: StringName) -> void:
	var path: String = "%s%s.ogg" % [AUDIO_DIRECTORY, String(sound_id)]
	if not ResourceLoader.exists(path):
		return
	var stream: Resource = load(path)
	if stream == null:
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
