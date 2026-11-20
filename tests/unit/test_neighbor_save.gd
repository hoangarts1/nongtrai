extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/neighbor_fixture.gd")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_current18_keeps_two_real_introductions_and_clearing_through_slot_continue_newgame() -> void:
	assert_true(f.clear_at(f.TARGETS[0]).ok)
	await f.converse(self,&"an")
	f.main.npc_system.close_panels()
	await f.converse(self,&"bac_lam")
	f.main.npc_system.close_panels()
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	assert_eq(int(payload.meta.save_version),18)
	assert_eq(payload.social.introduced,["an","bac_lam"])
	var before: Dictionary = f.owners()
	assert_true(f.main.call("_load_game_from_slot",98))
	assert_eq(f.owners(),before)
	assert_null(f.debris(f.TARGETS[0]))
	assert_true(f.main.call("_return_to_start_menu"))
	f.main.call("_continue_game")
	assert_eq(f.owners(),before)
	f.main.call("_start_new_game","Mai","Garden")
	assert_true(f.main.npc_system.state.get_introduced_ids().is_empty())
	assert_false(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))
	assert_eq(f.main.clearing_state.get_count(),0)

func test_pre18_injected_new_npc_history_and_goal_are_dropped_in_migration_and_direct_load() -> void:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v17.json"))
	raw.social.introduced = ["an","bac_lam"]
	raw.social.heard = ["an_intro","bac_lam_intro"]
	raw.social.talk_days = {"an":0,"bac_lam":0}
	raw.story.completed_objectives.append("meet_neighbors")
	var expected_clear: Dictionary = raw.clearing.duplicate(true)
	var migrated: Dictionary = SaveService._migrate(raw,17)
	assert_eq(migrated.social.introduced,[])
	assert_false(migrated.story.completed_objectives.has("meet_neighbors"))
	assert_eq(migrated.clearing,expected_clear)
	assert_true(f.main.call("_load_payload",raw))
	assert_true(f.main.npc_system.state.get_introduced_ids().is_empty())
	assert_false(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))

func test_all17_immutable_goldens_and_new18_actual_migration_preserve_old_owners() -> void:
	for version: int in range(1,18):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		var hash_before: String = FileAccess.get_sha256(path)
		var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		var migrated: Dictionary = SaveService._migrate(raw,version)
		assert_eq(int(migrated.meta.save_version),18)
		assert_eq(migrated.social.introduced,[])
		assert_eq(migrated.clock,raw.clock)
		assert_eq(migrated.wallet,raw.wallet if raw.has("wallet") else {"coins":100})
		assert_eq(FileAccess.get_sha256(path),hash_before)
	var raw17: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v17.json"))
	var expected: Dictionary = JSON.parse_string(JSON.stringify(SaveService._migrate(raw17,17),"",true,true))
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v18.json"))
	assert_eq(int(golden.meta.save_version),18)
	assert_eq(golden,expected)

func test_malformed_marker_does_not_infer_goal_from_friendship_or_heard_alone() -> void:
	await f.converse(self,&"an")
	f.main.npc_system.close_panels()
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	payload.social.introduced = ["an","bac_lam"]
	payload.social.heard.append("bac_lam_intro")
	payload.social.talk_days.bac_lam = 0.5
	payload.story = {"completed_objectives":["m2_4_station"],"read_pages":[]}
	assert_true(f.main.call("_load_payload",payload))
	assert_false(f.main.story_state.serialize().completed_objectives.has("meet_neighbors"))
	assert_false(f.main.npc_system.state.get_introduced_ids().has("bac_lam"))

func test_direct_load_missing_invalid_or_future_version_cannot_keep_new_goal_after_dropping_history() -> void:
	await f.converse(self,&"an")
	f.main.npc_system.close_panels()
	await f.converse(self,&"bac_lam")
	f.main.npc_system.close_panels()
	assert_true(f.main.call("_save_game_to_slot",98))
	var payload: Dictionary = SaveService.load_game(98)
	for version: Variant in [null,"18",false,18.5,INF,SaveService.CURRENT_VERSION+1]:
		var raw: Dictionary = payload.duplicate(true)
		raw.story.completed_objectives = ["first_sowing","meet_neighbors"]
		if version==null: raw.erase("meta")
		else: raw.meta.save_version = version
		# Compare the same legacy codec context: other components have their own
		# documented pre-version fallbacks, independent of this injected new history.
		var control: Dictionary = raw.duplicate(true)
		control.social.introduced = []
		control.story.completed_objectives = ["first_sowing"]
		assert_true(f.main.call("_load_payload",control))
		var other_owners: Dictionary = f.non_social_owners()
		assert_true(f.main.call("_load_payload",raw))
		assert_true(f.main.npc_system.state.get_introduced_ids().is_empty())
		assert_eq(f.main.story_state.serialize().completed_objectives,["first_sowing"])
		assert_eq(f.non_social_owners(),other_owners)
