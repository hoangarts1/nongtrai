extends GutTest
func test_valid_cli_exits_zero() -> void:
	var output: Array = []
	assert_eq(OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/validate_story.gd"]),output,true),0)
	assert_true(String(output[0]).contains("[validate_story] PASS"))
func test_bad_disposable_cycle_and_unknown_fixture_exit_one() -> void:
	for fixture: String in ["--fixture=cycle","--fixture=unknown"]:
		var output: Array = []
		assert_eq(OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/validate_story.gd","--",fixture]),output,true),1)
