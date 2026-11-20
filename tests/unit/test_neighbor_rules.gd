extends GutTest
const CONFIG: StoryConfig = preload("res://data/story/chapter1.tres")
func _social() -> Dictionary:
	return {"introduced":["an","bac_lam"],"heard":["an_intro","bac_lam_intro"],"talk_days":{"an":0,"bac_lam":0},"friendship":{"minh":4,"linh":8,"an":2,"bac_lam":2},"cells":{"minh":"-5,6"},"quests":{"active":["turnip_delivery"]}}

func test_two_distinct_explicit_introductions_require_actual_registered_history() -> void:
	assert_true(NeighborRules.validate(CONFIG).is_empty())
	var raw: Dictionary = _social()
	assert_eq(NeighborRules.observed(CONFIG,raw,0),PackedStringArray(["an","bac_lam"]))
	for invalid: Dictionary in [{"friendship":{"an":100,"bac_lam":100}}, {"introduced":["an","an"],"heard":raw.heard,"talk_days":raw.talk_days}, {"introduced":raw.introduced,"heard":[],"talk_days":raw.talk_days}, {"introduced":[],"heard":raw.heard,"talk_days":raw.talk_days}, {"introduced":raw.introduced,"heard":raw.heard,"talk_days":{"an":true,"bac_lam":0.5}}]:
		assert_true(NeighborRules.observed(CONFIG,invalid,0).is_empty())
	assert_false(StoryReceiptRules.neighbors(CONFIG,raw,0,false).ok)
	assert_eq(StoryReceiptRules.neighbors(CONFIG,raw,0,true).objective_ids,PackedStringArray(["meet_neighbors"]))
	raw.introduced = ["an"]
	assert_true(StoryReceiptRules.neighbors(CONFIG,raw,0,true).objective_ids.is_empty())

func test_legacy_and_malformed_new_facts_never_change_old_social_owners() -> void:
	var raw: Dictionary = _social()
	var before: Dictionary = raw.duplicate(true)
	var legacy: Dictionary = NeighborRules.normalize_social(CONFIG,raw,0,true)
	assert_true(legacy.ok)
	assert_eq(legacy.snapshot.introduced,[])
	assert_false(legacy.snapshot.heard.has("an_intro"))
	assert_false(legacy.snapshot.talk_days.has("bac_lam"))
	assert_eq(legacy.snapshot.friendship.minh,4)
	assert_eq(legacy.snapshot.friendship.linh,8)
	assert_eq(legacy.snapshot.cells,raw.cells)
	assert_eq(legacy.snapshot.quests,raw.quests)
	assert_eq(raw,before)
	raw.talk_days.an = 1
	var future: Dictionary = NeighborRules.normalize_social(CONFIG,raw,0)
	assert_false(future.snapshot.introduced.has("an"))
	assert_eq(NeighborRules.observed(CONFIG,future.snapshot,0),PackedStringArray(["bac_lam"]))
	assert_false(NeighborRules.normalize_social(null,raw,0).ok)

func test_registry_reference_alias_and_translations_are_real_and_detached() -> void:
	var previous_locale: String = TranslationServer.get_locale()
	var appearance: CharacterAppearanceCatalog = preload("res://data/art/characters/chibi_character_catalog.tres")
	assert_true(appearance.validate().is_empty())
	assert_eq(appearance.get_npc_appearance(&"bac_lam"),appearance.get_npc_appearance(&"lam"))
	assert_eq(appearance.get_npc_appearance(&"bac_lam").character_id,&"lam")
	var copy: StoryConfig = CONFIG.frozen_copy()
	copy.neighbor_introductions[&"an"] = &"minh_intro"
	assert_false(NeighborRules.validate(copy).is_empty())
	assert_true(NeighborRules.validate(CONFIG).is_empty())
	var locales: Array[String] = ["res://localization/strings_vi.csv","res://localization/strings_en.csv"]
	assert_true(DataValidator.validate_story_config(CONFIG,locales).is_empty())
	for line: Resource in CONFIG.land.npc_world.dialogues:
		if line.npc_id in [&"an",&"bac_lam"]:
			for locale: String in ["vi","en"]:
				TranslationServer.set_locale(locale)
				assert_lte(tr(String(line.text_key)).length(),120)
	TranslationServer.set_locale(previous_locale)

func test_programmatic_talk_is_not_a_visible_introduction_and_round_trip_keeps_committed_marker() -> void:
	var owner: NpcSocialState = NpcSocialState.new()
	owner.configure(CONFIG.land.npc_world)
	assert_not_null(owner.talk(&"an",0,&"spring"))
	assert_true(owner.get_introduced_ids().is_empty())
	assert_true(owner.record_introduction(&"an",&"an_intro",0))
	assert_true(owner.record_introduction(&"an",&"an_intro",0))
	assert_eq(owner.get_introduced_ids(),PackedStringArray(["an"]))
	assert_eq(int(owner.friendship.an),2)
	var restored: NpcSocialState = NpcSocialState.new()
	restored.configure(CONFIG.land.npc_world)
	restored.deserialize(JSON.parse_string(JSON.stringify(owner.serialize())))
	assert_eq(restored.serialize(),owner.serialize())
	assert_false(restored.record_introduction(&"bac_lam",&"bac_lam_intro",0))

func test_cli_verifies_actual_data_and_json_fixtures_without_script_errors() -> void:
	for invalid: bool in [false,true]:
		var args: PackedStringArray = ["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/sim_neighbors.gd"]
		if invalid: args.append_array(["--","--invalid"])
		var output: Array = []
		assert_eq(OS.execute(OS.get_executable_path(),args,output,true),1 if invalid else 0)
		assert_false(String(output[0]).contains("SCRIPT ERROR"))
		assert_false(String(output[0]).contains("ERROR:"))
		assert_false(String(output[0]).contains("leaked"))
		if not invalid:
			var report: Dictionary = {}
			for line: String in String(output[0]).split("\n"):
				if line.strip_edges().begins_with("{"): report = JSON.parse_string(line)
			assert_true(report.get("ok",false))
			assert_eq(int(report.get("registered_npcs",0)),4)
			assert_eq(int(report.get("fixture_introductions",0)),2)
			assert_true(report.get("json_match",false))

func test_social_publication_cannot_reenter_talk_deserialize_or_mark_introduction() -> void:
	var owner: NpcSocialState = NpcSocialState.new()
	owner.configure(CONFIG.land.npc_world)
	var attempts: Array[bool] = []
	var observer: Callable = func() -> void:
		attempts.append(owner.is_busy())
		attempts.append(owner.talk(&"bac_lam",0,&"spring")!=null)
		attempts.append(owner.record_introduction(&"an",&"an_intro",0))
		owner.deserialize({})
	owner.changed.connect(observer)
	assert_not_null(owner.talk(&"an",0,&"spring"))
	owner.changed.disconnect(observer)
	assert_eq(attempts,[true,false,false])
	assert_true(owner.heard.has(&"an_intro"))
	assert_eq(int(owner.friendship.an),2)
	assert_true(owner.get_introduced_ids().is_empty())
