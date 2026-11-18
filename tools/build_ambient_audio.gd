## Offline original ambience/music synthesis; no runtime or gameplay randomness.
## CLI: --output=<directory> required; writes only profile's eight known track IDs.
extends SceneTree

const PROFILE: AmbientAudioProfile = preload("res://data/ambient_audio_profile.tres")
const IDS: Array[StringName] = [&"amb_farm_day", &"amb_forest_day", &"amb_village_day", &"amb_water_day", &"amb_night", &"amb_rain", &"mus_farm_morning", &"mus_farm_afternoon"]
const NOTES: Array[float] = [261.6256, 329.6276, 391.9954, 329.6276, 293.6648, 349.2282, 440.0, 349.2282]

func _init() -> void:
	var output: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--output=") and output.is_empty():
			output = argument.trim_prefix("--output=")
		else:
			_fail("unknown/duplicate argument")
			return
	if output.is_empty() or not PROFILE.validation_errors().is_empty() or PROFILE.tracks.size() != IDS.size():
		_fail("explicit output and valid eight-track profile required")
		return
	output = ProjectSettings.globalize_path(output)
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		_fail("cannot create output directory")
		return
	for id: StringName in IDS:
		var row: Dictionary = PROFILE.get_track(id)
		if row.is_empty() or _write(output.path_join(String(id) + ".wav"), id, float(row.seconds)) != OK:
			_fail("write failed for %s" % id)
			return
	print("[build_ambient_audio] PASS: 8 original PCM loops; output=", output)
	quit(0)

func _fail(message: String) -> void:
	printerr("[build_ambient_audio] ", message)
	quit(1)

func _write(path: String, id: StringName, duration: float) -> Error:
	var count: int = roundi(duration * PROFILE.mix_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(count * 2)
	# A fixed local generator is for authored noise only, never game state/RNG.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 3107 + IDS.find(id)
	var smooth: float = 0.0
	for index: int in range(count):
		var time: float = float(index) / PROFILE.mix_rate
		var noise: float = rng.randf_range(-1.0, 1.0)
		smooth = lerpf(smooth, noise, 0.12)
		var sample: float = _sample(id, time, noise, smooth)
		# Short endpoint ramps prevent a discontinuity at the cyclic boundary.
		var edge: float = minf(1.0, minf(time, float(count - 1 - index) / PROFILE.mix_rate) / 0.04)
		bytes.encode_s16(index * 2, roundi(clampf(sample * edge, -0.9, 0.9) * 32767.0))
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer("RIFF".to_ascii_buffer())
	file.store_32(36 + bytes.size())
	file.store_buffer("WAVEfmt ".to_ascii_buffer())
	file.store_32(16)
	file.store_16(1)
	file.store_16(1)
	file.store_32(PROFILE.mix_rate)
	file.store_32(PROFILE.mix_rate * 2)
	file.store_16(2)
	file.store_16(16)
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(bytes.size())
	file.store_buffer(bytes)
	file.flush()
	var error: Error = file.get_error()
	file.close()
	return error

func _sample(id: StringName, time: float, noise: float, smooth: float) -> float:
	match id:
		&"amb_farm_day":
			return smooth * 0.22 + _bird(time, 4.0, 1700.0) * 0.07
		&"amb_forest_day":
			return smooth * 0.32 + _bird(time, 3.0, 2100.0) * 0.07 + _bird(time + 1.3, 5.0, 1350.0) * 0.04
		&"amb_village_day":
			return smooth * 0.16 + _bell(time, 4.0, 440.0) * 0.05
		&"amb_water_day":
			return smooth * 0.42 + noise * 0.025 + sin(TAU * (380.0 * time + sin(TAU * 1.5 * time))) * 0.025
		&"amb_night":
			var pulse: float = pow(maxf(0.0, sin(TAU * 3.0 * time)), 8.0)
			return smooth * 0.12 + sin(TAU * 2600.0 * time) * pulse * 0.045
		&"amb_rain":
			return smooth * 0.48 + noise * 0.07
		&"mus_farm_morning":
			return _music(time, false)
		&"mus_farm_afternoon":
			return _music(time, true)
	return 0.0

func _bird(time: float, period: float, pitch: float) -> float:
	var phase: float = fposmod(time, period)
	if phase >= 0.36:
		return 0.0
	var envelope: float = sin(PI * phase / 0.36)
	return sin(TAU * (pitch * phase + 240.0 * phase * phase)) * envelope * envelope

func _bell(time: float, period: float, pitch: float) -> float:
	var phase: float = fposmod(time, period)
	return sin(TAU * pitch * phase) * exp(-4.0 * phase) * minf(1.0, phase / 0.02)

func _music(time: float, afternoon: bool) -> float:
	var index: int = int(time / 2.0) % NOTES.size()
	var pitch: float = NOTES[(index + (2 if afternoon else 0)) % NOTES.size()]
	var phase: float = fposmod(time, 2.0)
	var envelope: float = minf(1.0, phase / 0.03) * exp(-2.2 * phase)
	return (sin(TAU * pitch * phase) * 0.18 + sin(TAU * pitch * 2.0 * phase) * 0.025) * envelope
