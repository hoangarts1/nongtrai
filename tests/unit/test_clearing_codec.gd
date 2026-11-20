extends GutTest
const CONFIG: ClearingConfig = preload("res://data/clearing_config.tres")

func test_strict_snapshot_rejects_duplicates_fraction_bool_unknown_id_and_outside_cells() -> void:
	var state: ClearingState = ClearingState.new()
	state.configure(CONFIG)
	var entry: Dictionary = state.get_candidates()[0]
	var row: Dictionary = {"x":entry.cell.x,"y":entry.cell.y,"asset_id":String(entry.asset_id)}
	var context: Dictionary = ClearingRules.compile(CONFIG)
	var malformed: Array = [null,[],{}, {"cleared":[],"coins":1}, {"cleared":true}, {"cleared":[row,row]}, {"cleared":[{"x":true,"y":row.y,"asset_id":row.asset_id}]}, {"cleared":[{"x":float(row.x)+0.5,"y":row.y,"asset_id":row.asset_id}]}, {"cleared":[{"x":row.x,"y":row.y,"asset_id":"tree_fruit"}]}, {"cleared":[{"x":0,"y":0,"asset_id":row.asset_id}]}, {"cleared":[{"x":2147483648,"y":row.y,"asset_id":row.asset_id}]}, {"cleared":[{"x":row.x,"y":row.y,"asset_id":row.asset_id,"paid":true}]}]
	for raw: Variant in malformed:
		assert_false(ClearingSaveCodec.decode(context,raw).ok,str(raw))
		var restored: Dictionary = ClearingSaveCodec.normalize(CONFIG,raw)
		assert_true(restored.ok)
		assert_true(restored.fallback)
		assert_eq(restored.snapshot,ClearingSaveCodec.empty())
	assert_false(ClearingSaveCodec.normalize(null,{}).ok)

func test_valid_native_json_is_canonical_and_legacy_never_imports_injected_cleanup() -> void:
	var state: ClearingState = ClearingState.new()
	state.configure(CONFIG)
	var entries: Array[Dictionary] = state.get_candidates()
	for index: int in range(CONFIG.story_goal):
		var token: RefCounted = state.reserve(entries[index].cell,entries[index].asset_id).token
		assert_true(state.commit(token))
		assert_true(state.finish(token))
	var wire: Dictionary = state.serialize()
	var reversed: Dictionary = wire.duplicate(true)
	reversed.cleared.reverse()
	var current: Dictionary = ClearingSaveCodec.normalize(CONFIG,JSON.parse_string(JSON.stringify(reversed)))
	assert_true(current.ok)
	assert_false(current.fallback)
	assert_eq(current.snapshot,wire)
	var legacy: Dictionary = ClearingSaveCodec.normalize(CONFIG,wire,true)
	assert_true(legacy.ok)
	assert_eq(legacy.snapshot,ClearingSaveCodec.empty())
	assert_eq(wire.cleared.size(),CONFIG.story_goal)
	current.snapshot.cleared.clear()
	assert_eq(state.get_count(),CONFIG.story_goal)

func test_invalid_data_fails_closed_and_config_copy_cannot_change_a_live_owner() -> void:
	var story: StoryConfig = (preload("res://data/story/chapter1.tres") as StoryConfig).frozen_copy()
	var config: ClearingConfig = story.clearing
	var state: ClearingState = ClearingState.new()
	assert_true(state.configure(config))
	var original_goal: int = state.get_goal()
	config.story_goal = 0
	assert_true(ClearingRules.compile(config).is_empty())
	assert_false(state.configure(config))
	assert_eq(state.get_goal(),original_goal)
	assert_eq(CONFIG.story_goal,original_goal)
	config.story_goal = original_goal
	config.world = null
	assert_false(config.validation_errors().is_empty())

func test_actual_data_reachability_and_json_command_fixture_cli() -> void:
	var output: Array = []
	assert_eq(OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/sim_clearing.gd"]),output,true),0)
	assert_false(String(output[0]).contains("SCRIPT ERROR"))
	assert_false(String(output[0]).contains("ERROR:"))
	assert_false(String(output[0]).contains("leaked"))
	var report: Dictionary = {}
	for line: String in String(output[0]).split("\n"):
		if line.strip_edges().begins_with("{"): report = JSON.parse_string(line)
	assert_true(report.get("ok",false))
	assert_gte(int(report.get("reachable_props",0)),CONFIG.story_goal)
	assert_eq(int(report.get("fixture_cleared",0)),CONFIG.story_goal)
	assert_eq(int(report.get("extra_days",-1)),0)
	assert_true(report.get("json_match",false))
	assert_eq(OS.execute(OS.get_executable_path(),PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/sim_clearing.gd","--","--invalid"]),output,true),1)
	assert_false(String(output[0]).contains("SCRIPT ERROR"))
	assert_false(String(output[0]).contains("ERROR:"))
