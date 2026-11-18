## AudioService — optional original effect playback for existing presentation events.
## API:
##   func play_sound(sound_id: StringName) -> void
##   func get_sound_path(sound_id: StringName) -> String
extends Node

const AUDIO_DIRECTORY: String = "res://assets/audio/"
const AUDIO_EXTENSIONS: Array[String] = [".ogg", ".wav"]
var _router: LifeAudioBusRouter = LifeAudioBusRouter.new()

func _ready() -> void:
	if not _router.apply_accepted():
		push_warning("AudioService: required audio bus layout is unavailable")
	if not Settings.preferences_changed.is_connected(_preferences_changed):
		Settings.preferences_changed.connect(_preferences_changed)

func _preferences_changed(_values: Dictionary) -> void:
	# Accepted settings are authoritative; another listener may modify its detached arguments.
	_router.apply_accepted()
	var volume: float = Settings.get_effects_volume()
	for child: Node in get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).volume_linear = volume

func play_sound(sound_id: StringName) -> void:
	var path: String = get_sound_path(sound_id)
	if path.is_empty():
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX" if AudioServer.get_bus_index(&"SFX") >= 0 else &"Master"
	player.volume_linear = Settings.get_effects_volume()
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func get_sound_path(sound_id: StringName) -> String:
	for extension: String in AUDIO_EXTENSIONS:
		var path: String = "%s%s%s" % [AUDIO_DIRECTORY, String(sound_id), extension]
		if ResourceLoader.exists(path):
			return path
	return ""
