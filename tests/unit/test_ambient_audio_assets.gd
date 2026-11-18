extends GutTest

const PROFILE: AmbientAudioProfile = preload("res://data/ambient_audio_profile.tres")

func test_profile_has_real_unique_tracks_routes_and_detached_lookup() -> void:
	assert_eq(PROFILE.validation_errors(), PackedStringArray())
	assert_eq(PROFILE.tracks.size(), 8)
	var before: Array[Dictionary] = PROFILE.tracks.duplicate(true)
	for row: Dictionary in PROFILE.tracks:
		assert_true(FileAccess.file_exists(row.path))
		assert_true(ResourceLoader.exists(row.path))
		assert_eq(row.bus, &"Music" if String(row.id).begins_with("mus_") else &"Ambience")
		var detached: Dictionary = PROFILE.get_track(row.id)
		detached.gain = -1.0
		assert_eq(PROFILE.get_track(row.id), row)
	assert_eq(PROFILE.tracks, before)
	assert_eq(PROFILE.get_track(&"missing"), {})
	assert_eq(PROFILE.get_track(PROFILE.morning_music).bus, &"Music")
	assert_eq(PROFILE.get_track(PROFILE.rain_track).bus, &"Ambience")

func test_profile_rejects_bad_numbers_paths_references_routes_and_zone_geometry() -> void:
	var profile: AmbientAudioProfile = PROFILE.duplicate(true) as AmbientAudioProfile
	for value: Variant in [-0.1, NAN, INF, true, "0.5"]:
		profile.tracks[0]["gain"] = value
		assert_false(profile.validation_errors().is_empty())
	profile = PROFILE.duplicate(true) as AmbientAudioProfile
	profile.tracks[0].path = "res://assets/audio/../hoe.wav"
	assert_false(profile.validation_errors().is_empty())
	profile = PROFILE.duplicate(true) as AmbientAudioProfile
	profile.tracks.append(profile.tracks[0].duplicate(true))
	assert_false(profile.validation_errors().is_empty())
	profile = PROFILE.duplicate(true) as AmbientAudioProfile
	profile.tracks[0].seconds = INF
	profile.tracks[0].bus = &"Unknown"
	assert_false(profile.validation_errors().is_empty())
	profile = PROFILE.duplicate(true) as AmbientAudioProfile
	profile.day_by_zone["farm"] = &"missing"
	profile.morning_music = &"amb_night"
	assert_false(profile.validation_errors().is_empty())
	profile = PROFILE.duplicate(true) as AmbientAudioProfile
	profile.zones[0].region = Rect2i(0, 0, -1, 3)
	profile.zones[1].zone = &"unknown"
	assert_false(profile.validation_errors().is_empty())
	profile = PROFILE.duplicate(true) as AmbientAudioProfile
	profile.fade_seconds = NAN
	profile.mix_rate = 0
	profile.night_start = profile.day_start
	assert_false(profile.validation_errors().is_empty())
	assert_eq(PROFILE.validation_errors(), PackedStringArray(), "Malformed clones never mutate shipped data")

func test_native_pcm_has_signal_headroom_valid_duration_and_click_free_endpoints() -> void:
	for row: Dictionary in PROFILE.tracks:
		var bytes: PackedByteArray = FileAccess.get_file_as_bytes(row.path)
		assert_gt(bytes.size(), 44)
		assert_eq(bytes.slice(0, 4).get_string_from_ascii(), "RIFF")
		assert_eq(bytes.slice(8, 16).get_string_from_ascii(), "WAVEfmt ")
		assert_eq(bytes.decode_u16(20), 1)
		assert_eq(bytes.decode_u16(22), 1)
		assert_eq(bytes.decode_u16(34), 16)
		assert_eq(bytes.decode_u32(24), PROFILE.mix_rate)
		var count: int = (bytes.size() - 44) / 2
		assert_eq(count, roundi(float(row.seconds) * PROFILE.mix_rate))
		assert_eq(bytes.decode_u32(40), count * 2)
		var sum: float = 0.0
		var squared: float = 0.0
		var peak: float = 0.0
		var jump: float = 0.0
		var previous: float = 0.0
		for index: int in range(count):
			var sample: float = float(bytes.decode_s16(44 + index * 2)) / 32767.0
			sum += sample
			squared += sample * sample
			peak = maxf(peak, absf(sample))
			jump = maxf(jump, absf(sample - previous))
			previous = sample
		assert_gt(sqrt(squared / count), 0.003, "%s must contain real signal" % row.id)
		assert_lt(peak, 0.85, "%s keeps PCM headroom" % row.id)
		assert_lt(absf(sum / count), 0.02, "%s avoids large DC offset" % row.id)
		assert_lt(jump, 0.65, "%s has no abrupt sample jump" % row.id)
		assert_eq(bytes.decode_s16(44), 0)
		assert_eq(bytes.decode_s16(bytes.size() - 2), 0)
		var stream: AudioStreamWAV = load(row.path) as AudioStreamWAV
		assert_not_null(stream)
		assert_eq(stream.format, AudioStreamWAV.FORMAT_16_BITS)
		assert_eq(stream.mix_rate, PROFILE.mix_rate)
		assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_DISABLED, "Shared imported stream stays unmodified")
		assert_almost_eq(stream.get_length(), float(row.seconds), 0.001)

func test_offline_builder_reproduces_exact_bytes_and_reports_missing_or_unwritable_output() -> void:
	var prefix: String = "user://ambient_build_%d" % Time.get_ticks_usec()
	var result: Dictionary = _run_builder("--output=" + prefix, prefix + "_first")
	assert_eq(result.code, 0, result.stderr)
	assert_string_contains(result.stdout, "PASS: 8 original PCM loops")
	for row: Dictionary in PROFILE.tracks:
		assert_eq(FileAccess.get_file_as_bytes(prefix.path_join(String(row.id) + ".wav")), FileAccess.get_file_as_bytes(row.path))
	var corrupted: FileAccess = FileAccess.open(prefix.path_join("amb_farm_day.wav"), FileAccess.WRITE)
	corrupted.store_string("corrupt probe output")
	corrupted.close()
	result = _run_builder("--output=" + prefix, prefix + "_second")
	assert_eq(result.code, 0, result.stderr)
	for row: Dictionary in PROFILE.tracks:
		assert_eq(FileAccess.get_file_as_bytes(prefix.path_join(String(row.id) + ".wav")), FileAccess.get_file_as_bytes(row.path))
	result = _run_builder("", prefix + "_missing")
	assert_eq(result.code, 1)
	assert_string_contains(result.stderr, "explicit output and valid eight-track profile required")
	var blocked: String = prefix + "_blocked"
	assert_eq(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(blocked.path_join("amb_farm_day.wav"))), OK)
	result = _run_builder("--output=" + blocked, prefix + "_blocked_log")
	assert_eq(result.code, 1)
	assert_string_contains(result.stderr, "write failed for amb_farm_day")

func _run_builder(options: String, log_id: String) -> Dictionary:
	var arguments: String = '--headless --path "%s" --script res://tools/build_ambient_audio.gd -- ' % ProjectSettings.globalize_path("res://") + options
	var output: Array = []
	var log: String = ProjectSettings.globalize_path(log_id)
	var code: int = OS.execute("powershell.exe", PackedStringArray(["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ProjectSettings.globalize_path("res://tools/run_godot_bounded.ps1"), "-Godot", OS.get_executable_path(), "-Arguments", arguments, "-OutputPath", log, "-TimeoutMs", "30000"]), output, true, false)
	var stderr: String = FileAccess.get_file_as_string(log + ".stderr") if FileAccess.file_exists(log + ".stderr") else "missing child stderr"
	assert_false(stderr.contains("SCRIPT ERROR"), stderr)
	assert_false(stderr.contains("ERROR:"), stderr)
	return {"code": code, "stdout": FileAccess.get_file_as_string(log + ".stdout") if FileAccess.file_exists(log + ".stdout") else "", "stderr": stderr}
