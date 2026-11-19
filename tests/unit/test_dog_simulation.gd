extends GutTest
func test_independent_cli_1000_adjacent_steps_grouped_and_json_checkpoint() -> void:
	var output: Array = []
	var result: int = OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/sim_dog.gd"]),output,true)
	assert_eq(result,0)
	var report: Dictionary = {}
	var reports: int = 0
	for line: String in String(output[0]).split("\n"):
		if not line.strip_edges().begins_with("{"): continue
		var value: Variant = JSON.parse_string(line)
		if value is Dictionary and value.has("adjacent_commits"):
			report = value
			reports += 1
	assert_eq(reports,1)
	assert_eq(report.get("status"),"PASS")
	assert_eq(report.get("adjacent_commits"),1000.0)
	assert_true(report.get("grouped_match",false))
	assert_true(report.get("json_match",false))
	assert_gt(int(report.get("repairs",0)),0)
func test_independent_cli_unknown_argument_exits_one() -> void:
	var output: Array = []
	assert_eq(OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/sim_dog.gd","--","--dog-fixture=unknown"]),output,true),1)
