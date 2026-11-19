extends GutTest

const F: Script = preload("res://tests/unit/test_director_candidates.gd")
const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")

func test_all_pinned_vectors_survive_native_json_without_changing_existing_golden_bytes() -> void:
	var path: String = "res://tests/fixtures/director_rng_v0.json"
	var hash: String = FileAccess.get_sha256(path)
	var golden: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_eq(golden.engine, Engine.get_version_info().string)
	for vector: Dictionary in golden.vectors:
		var snapshot: Dictionary = F.snapshot(int(vector.day), int(vector.world_seed))
		var context: Dictionary = F.context(int(vector.day))
		var original: Dictionary = EventDirector.decide(PROFILE, snapshot, context)
		var parsed: Dictionary = JSON.parse_string(JSON.stringify({"snapshot": snapshot, "context": context}, "", true, true))
		var continued: Dictionary = EventDirector.decide(PROFILE, parsed.snapshot, parsed.context)
		assert_true(original.ok and continued.ok)
		assert_eq(continued.event_id, vector.event_id)
		assert_eq(int(continued.seed_used), int(vector.seed_used))
		assert_eq(continued.rng_state, vector.rng_state)
		assert_true(DirectorSnapshot._same(original, continued))
	assert_eq(FileAccess.get_sha256(path), hash)

func test_real_save14_golden_pair_roundtrip_is_silent_and_old_golden_inputs_remain_bytes() -> void:
	var hashes: Dictionary = {}
	for version: int in range(1, 15):
		var path: String = "res://tests/golden_saves/save_v%d.json" % version
		hashes[path] = FileAccess.get_sha256(path)
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v14.json"))
	var normalized: Dictionary = SaveService._migrate(raw, 14)
	assert_true(DirectorSnapshot._same(raw.director, normalized.director))
	assert_true(DirectorSnapshot._same(raw.director_activity, normalized.director_activity))
	var owner: DirectorState = DirectorState.new()
	assert_true(owner.configure(PROFILE, int(raw.clock.day_index)))
	var seen: Array[int] = []
	var callback: Callable = func(day: int) -> void: seen.append(day)
	owner.director_changed.connect(callback)
	assert_true(owner.deserialize(normalized.director))
	assert_eq(seen, [])
	owner.director_changed.disconnect(callback)
	for path: String in hashes:
		assert_eq(FileAccess.get_sha256(path), hashes[path])
