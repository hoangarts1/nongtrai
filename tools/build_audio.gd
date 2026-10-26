## Generates the small original PCM effects used by the existing farming action calls.
extends SceneTree

const AUDIO_DIRECTORY: String = "res://assets/audio"
const SAMPLE_RATE: int = 22050
const BITS_PER_SAMPLE: int = 16

func _init() -> void:
	var result: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(AUDIO_DIRECTORY))
	if result != OK:
		printerr("[build_audio] cannot create audio directory: %s" % error_string(result))
		quit(1)
		return
	_write_wav("hoe", _make_hoe())
	_write_wav("seed", _make_seed())
	_write_wav("water", _make_water())
	_write_wav("harvest", _make_harvest())
	print("[build_audio] wrote original farming effects to %s" % AUDIO_DIRECTORY)
	quit()

func _write_wav(sound_id: String, samples: PackedFloat32Array) -> void:
	var path: String = "%s/%s.wav" % [AUDIO_DIRECTORY, sound_id]
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("[build_audio] cannot open %s" % path)
		return
	var data_bytes: int = samples.size() * 2
	file.store_buffer("RIFF".to_ascii_buffer())
	file.store_32(36 + data_bytes)
	file.store_buffer("WAVE".to_ascii_buffer())
	file.store_buffer("fmt ".to_ascii_buffer())
	file.store_32(16)
	file.store_16(1)
	file.store_16(1)
	file.store_32(SAMPLE_RATE)
	file.store_32(SAMPLE_RATE * 2)
	file.store_16(2)
	file.store_16(BITS_PER_SAMPLE)
	file.store_buffer("data".to_ascii_buffer())
	file.store_32(data_bytes)
	for sample: float in samples:
		var pcm: int = int(roundi(clampf(sample, -1.0, 1.0) * 32767.0))
		file.store_16(pcm & 0xffff)
	file.close()

func _make_hoe() -> PackedFloat32Array:
	var duration: float = 0.22
	var samples: PackedFloat32Array = _silence(duration)
	for index: int in range(samples.size()):
		var time: float = float(index) / float(SAMPLE_RATE)
		var envelope: float = pow(maxf(0.0, 1.0 - time / duration), 1.85)
		var thud: float = sin(TAU * (76.0 * time + 24.0 * time * time)) * 0.43
		var earth: float = sin(TAU * (660.0 * time + 310.0 * time * time)) * 0.11
		samples[index] = (thud + earth) * envelope
	return samples

func _make_seed() -> PackedFloat32Array:
	var duration: float = 0.26
	var samples: PackedFloat32Array = _silence(duration)
	for index: int in range(samples.size()):
		var time: float = float(index) / float(SAMPLE_RATE)
		var value: float = 0.0
		for hit_time: float in [0.035, 0.132]:
			var local_time: float = time - hit_time
			if local_time >= 0.0 and local_time < 0.07:
				value += sin(TAU * (920.0 + hit_time * 400.0) * local_time) * pow(1.0 - local_time / 0.07, 2.2) * 0.22
		samples[index] = value
	return samples

func _make_water() -> PackedFloat32Array:
	var duration: float = 0.43
	var samples: PackedFloat32Array = _silence(duration)
	for index: int in range(samples.size()):
		var time: float = float(index) / float(SAMPLE_RATE)
		var envelope: float = sin(PI * clampf(time / duration, 0.0, 1.0))
		var pour: float = sin(TAU * (210.0 * time + 55.0 * sin(TAU * 6.0 * time))) * 0.10
		var sparkle: float = sin(TAU * (1730.0 * time + 160.0 * time * time)) * 0.045
		samples[index] = (pour + sparkle) * envelope
	return samples

func _make_harvest() -> PackedFloat32Array:
	var duration: float = 0.46
	var samples: PackedFloat32Array = _silence(duration)
	for index: int in range(samples.size()):
		var time: float = float(index) / float(SAMPLE_RATE)
		var envelope: float = pow(maxf(0.0, 1.0 - time / duration), 1.45)
		var chime: float = sin(TAU * 660.0 * time) * 0.18
		chime += sin(TAU * 880.0 * time) * 0.14
		chime += sin(TAU * 1320.0 * time) * 0.08
		samples[index] = chime * envelope
	return samples

func _silence(duration: float) -> PackedFloat32Array:
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(roundi(duration * float(SAMPLE_RATE)))
	return samples
