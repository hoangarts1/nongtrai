extends GutTest

func test_real_catalog_cli_passes_without_selling_unpriced_products() -> void:
	var result: Dictionary = _run_case("normal","")
	assert_eq(int(result.exit_code),0,result.shell_output)
	assert_string_contains(result.stdout,"[recipe_economy] PASS: recipes=7 machines=7 zero_sale_outputs=7")
	assert_false(result.stderr.contains("SCRIPT ERROR"),result.stderr)

func test_over_cap_fixture_really_exits_one_with_identified_recipe_reason() -> void:
	var result: Dictionary = _run_case("over_cap","over-cap")
	assert_eq(int(result.exit_code),1,result.shell_output)
	assert_string_contains(result.stdout,"recipe stove_carrot_meal exceeds value-added cap")
	assert_false(result.stdout.contains("[recipe_economy] PASS"))
	assert_false(result.stderr.contains("SCRIPT ERROR"),result.stderr)

func test_missing_reference_fixture_really_exits_one_for_reference_error() -> void:
	var result: Dictionary = _run_case("unknown_item","invalid-reference")
	assert_eq(int(result.exit_code),1,result.shell_output)
	assert_string_contains(result.stdout,"references unknown item missing_recipe_input")
	assert_false(result.stdout.contains("[recipe_economy] PASS"))
	assert_false(result.stderr.contains("SCRIPT ERROR"),result.stderr)

func _run_case(stem: String, fixture: String) -> Dictionary:
	var log: String = ProjectSettings.globalize_path("user://phase67_cli_%d_%s" % [OS.get_process_id(),stem])
	var arguments: String = '--headless --path "%s" --script res://tools/validate_recipe_economy.gd' % ProjectSettings.globalize_path("res://")
	if not fixture.is_empty():
		arguments += " -- --fixture="+fixture
	var output: Array = []
	# Reuse the unchanged Windows harness: hidden child, isolated saves,15s native wait/kill.
	var code: int = OS.execute("powershell.exe",PackedStringArray(["-NoProfile","-ExecutionPolicy","Bypass","-File",ProjectSettings.globalize_path("res://tools/run_godot_bounded.ps1"),"-Godot",OS.get_executable_path(),"-Arguments",arguments,"-OutputPath",log,"-TimeoutMs","15000"]),output,true,false)
	return {"exit_code":code,"stdout":FileAccess.get_file_as_string(log+".stdout") if FileAccess.file_exists(log+".stdout") else "","stderr":FileAccess.get_file_as_string(log+".stderr") if FileAccess.file_exists(log+".stderr") else "","shell_output":str(output)}
