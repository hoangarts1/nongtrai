## LifeAmbientAudioFlow — four bounded native loop slots, presentation state only.
## API: configure(main,source=DEFAULT_PROFILE)->bool; get_playback_snapshot()->Dictionary.
class_name LifeAmbientAudioFlow
extends Node

const DEFAULT_PROFILE: AmbientAudioProfile = preload("res://data/ambient_audio_profile.tres")
var _main: Node
var _profile: AmbientAudioProfile
var _players: Array[AudioStreamPlayer] = []
var _ids: Array[StringName] = [&"", &"", &"", &""]
var _selected: Array[StringName] = [&"", &""]
var _starts: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _targets: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _elapsed: Array[float] = [0.0, 0.0]
var _dirty: bool = true
var _enabled: bool = false
var _has_cell: bool = false
var _cell: Vector2i
var _zone: StringName = &""

func configure(main: Node, source: AmbientAudioProfile = DEFAULT_PROFILE) -> bool:
	if _main != null:
		return _main == main
	if main == null or source == null or not source.validation_errors().is_empty():
		push_warning("AmbientAudioFlow: invalid owner/profile; playback remains disabled")
		return false
	_main = main
	_profile = source.duplicate(true) as AmbientAudioProfile
	for id: StringName in [&"MusicA", &"MusicB", &"AmbienceA", &"AmbienceB"]:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = String(id)
		player.bus = &"Music" if _players.size() < 2 else &"Ambience"
		player.volume_linear = 0.0
		add_child(player)
		_players.append(player)
	GameClock.time_changed.connect(_clock_changed)
	Events.weather_changed.connect(_weather_changed)
	return true

func _clock_changed(_day: int, _minute: int) -> void:
	_dirty = true

func _weather_changed(_id: StringName) -> void:
	_dirty = true

func _process(delta: float) -> void:
	if not is_instance_valid(_main) or _main.is_queued_for_deletion():
		_silence()
		return
	# Return-to-title can leave the existing game flag true.
	if not bool(_main.get("_game_started")) or _main.start_menu.visible:
		if _enabled:
			_silence()
		return
	_enabled = true
	var cell: Vector2i = _main.world.get_player_cell()
	if _dirty or not _has_cell or cell != _cell:
		_dirty = false
		_has_cell = true
		_cell = cell
		var context: Dictionary = AmbientAudioContext.select(_profile, cell, GameClock.minute, bool(_main.weather_state.call("is_rainy")))
		_zone = context.get("zone", &"")
		_select_layer(0, StringName(context.get("music", &"")))
		_select_layer(1, StringName(context.get("ambience", &"")))
	_fade(maxf(0.0, delta))

func _select_layer(layer: int, id: StringName) -> void:
	if _selected[layer] == id:
		return
	var first: int = layer * 2
	var slot: int = -1
	var gain: float = 0.0
	if not id.is_empty():
		var row: Dictionary = _profile.get_track(id)
		if not row.is_empty() and ResourceLoader.exists(row.path):
			var source: AudioStreamWAV = load(row.path) as AudioStreamWAV
			if source != null:
				gain = float(row.gain)
				for index: int in range(first, first + 2):
					if _ids[index] == id:
						slot = index
				if slot < 0:
					slot = first if _players[first].volume_linear <= _players[first + 1].volume_linear else first + 1
					var stream: AudioStreamWAV = source.duplicate(true) as AudioStreamWAV
					stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
					stream.loop_begin = 0
					stream.loop_end = roundi(stream.get_length() * stream.mix_rate)
					_players[slot].stop()
					_players[slot].stream = stream
					_players[slot].volume_linear = 0.0
					_players[slot].play()
					_ids[slot] = id
		if slot < 0:
			push_warning("AmbientAudioFlow: loop is unavailable: %s" % id)
	_selected[layer] = id if slot >= 0 else &""
	_elapsed[layer] = 0.0
	for index: int in range(first, first + 2):
		_starts[index] = _players[index].volume_linear
		_targets[index] = gain if index == slot else 0.0

func _fade(delta: float) -> void:
	for layer: int in range(2):
		_elapsed[layer] = minf(_profile.fade_seconds, _elapsed[layer] + delta)
		var weight: float = _elapsed[layer] / _profile.fade_seconds
		for index: int in range(layer * 2, layer * 2 + 2):
			_players[index].volume_linear = lerpf(_starts[index], _targets[index], weight)
			if weight == 1.0 and _targets[index] == 0.0:
				_players[index].stop()
				_players[index].stream = null
				_ids[index] = &""

func _silence() -> void:
	for index: int in range(_players.size()):
		if is_instance_valid(_players[index]):
			_players[index].stop()
			_players[index].stream = null
			_players[index].volume_linear = 0.0
		_ids[index] = &""
		_starts[index] = 0.0
		_targets[index] = 0.0
	_selected = [&"", &""]
	_enabled = false
	_has_cell = false
	_dirty = true
	_zone = &""

func _exit_tree() -> void:
	_silence()

func get_playback_snapshot() -> Dictionary:
	var rows: Array[Dictionary] = []
	for index: int in range(_players.size()):
		var player: AudioStreamPlayer = _players[index]
		rows.append({"id": _ids[index], "instance_id": player.get_instance_id(), "bus": player.bus, "playing": player.playing, "gain": player.volume_linear, "target_gain": _targets[index], "loop_mode": (player.stream as AudioStreamWAV).loop_mode if player.stream is AudioStreamWAV else AudioStreamWAV.LOOP_DISABLED})
	return {"enabled": _enabled, "zone": _zone, "selected": {"music": _selected[0], "ambience": _selected[1]}, "players": rows}
