extends GutTest
func test_cli_1000_fixture_commands_grouped_and_json_continuation() -> void:
	var output: Array = []
	assert_eq(OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/sim_story.gd"]),output,true),0)
	var report: Dictionary = {}
	for line: String in String(output[0]).split("\n"):
		if line.strip_edges().begins_with("{"):
			var parsed: Variant = JSON.parse_string(line)
			if parsed is Dictionary and parsed.has("fixture_commands"): report = parsed
	assert_eq(report.get("status"),"PASS")
	assert_eq(report.get("fixture_commands"),1000.0)
	assert_true(report.get("grouped_match",false))
	assert_true(report.get("json_match",false))
	assert_gt(int(report.get("rejected",0)),0)
	assert_false(report.get("planned_complete",true))
func test_cli_invalid_fixture_and_unknown_argument_exit_one() -> void:
	for argument: String in ["--fixture=invalid","--unknown"]:
		var output: Array = []
		assert_eq(OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/sim_story.gd","--",argument]),output,true),1)
