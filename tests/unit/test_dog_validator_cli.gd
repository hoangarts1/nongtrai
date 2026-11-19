extends GutTest

func test_actual_positive_and_invalid_distance_cli_exit_and_keep_source_bytes() -> void:
	var path: String = "res://data/dog_config.tres"
	var before: String = FileAccess.get_sha256(path)
	for invalid: bool in [false, true]:
		var log: String = ProjectSettings.globalize_path("user://dog_config_cli_%d_%s" % [OS.get_process_id(), str(invalid)])
		var args: String = '--headless --path "%s" --script tools/validate_data.gd' % ProjectSettings.globalize_path("res://")
		if invalid:
			args += " -- --dog-fixture=invalid-distance"
		var output: Array = []
		var result: int = OS.execute("powershell.exe", PackedStringArray(["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ProjectSettings.globalize_path("res://tools/run_godot_bounded.ps1"), "-Godot", OS.get_executable_path(), "-Arguments", args, "-OutputPath", log, "-TimeoutMs", "15000"]), output, true, false)
		var stdout: String = FileAccess.get_file_as_string(log + ".stdout")
		var stderr: String = FileAccess.get_file_as_string(log + ".stderr")
		assert_eq(result, 1 if invalid else 0, str(output))
		assert_eq(stdout.contains("[validate_data] PASS"), not invalid)
		if invalid:
			assert_true(stderr.contains("dog follow distances require start>stop>=1"))
		assert_false(stderr.contains("SCRIPT ERROR"), stderr)
		assert_eq(FileAccess.get_sha256(path), before)
