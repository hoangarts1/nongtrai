extends GutTest

const SLOT: int = 96

func after_each() -> void:
	SaveService.delete_save(SLOT)

func _state() -> NpcSocialState:
	var state: NpcSocialState = NpcSocialState.new()
	state.configure(preload("res://data/npcs/phase8_world.tres"))
	return state

func test_relationship_dialogue_quest_and_daily_talk_round_trip() -> void:
	var state: NpcSocialState = _state()
	assert_eq(state.talk(&"minh", 2, &"spring").dialogue_id, &"minh_intro")
	state.quests.accept_quest(&"turnip_delivery")
	assert_eq(state.talk(&"minh", 2, &"spring").dialogue_id, &"minh_active")
	assert_eq(int(state.friendship[&"minh"]), 2, "Daily talk cannot be farmed")
	var payload: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v4.json"))
	assert_true(SaveService.save_game(payload, SLOT))
	var loaded: Dictionary = SaveService.load_game(SLOT)
	state.deserialize(loaded["social"])
	assert_true(state.quests.is_quest_active(&"turnip_delivery"))
	assert_eq(int(state.friendship[&"minh"]), 4)
	assert_true(state.heard.has(&"minh_active"))
	assert_true(state.merchant.is_consumed(2))
	state.talk(&"minh", 2, &"spring")
	assert_eq(int(state.friendship[&"minh"]), 4, "Reload does not reset daily friendship limit")
	var restored: NpcSocialState = _state()
	restored.deserialize(state.serialize())
	assert_eq(restored.serialize(), state.serialize())
	assert_eq(loaded["quests"], payload["quests"], "Onboarding is separate")

func test_v3_migration_preserves_all_old_progress_and_older_fixtures() -> void:
	for version: int in [1, 2, 3]:
		var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/golden_saves/save_v%d.json" % version))
		original["quests"] = {"completed": [true, true, true, false, false, false, false]}
		original["profile"] = {"farm_name": "Vuon nha"}
		var file: FileAccess = FileAccess.open("user://saves/slot_%d.json" % SLOT, FileAccess.WRITE)
		file.store_string(JSON.stringify(original))
		file.close()
		var loaded: Dictionary = SaveService.load_game(SLOT)
		assert_eq(int(loaded["meta"]["save_version"]), 4)
		for field: String in ["quests", "profile", "clock", "inventory", "farm", "player"]:
			assert_eq(loaded[field], original[field], "v%d preserves %s" % [version, field])
		assert_eq(loaded["social"], {})
		assert_true(SaveService.save_game(loaded, SLOT))
		assert_eq(SaveService.load_game(SLOT)["quests"], original["quests"])

func test_bad_social_values_are_dropped_and_friendship_clamped() -> void:
	var state: NpcSocialState = _state()
	state.deserialize({"quests": {"active": ["unknown", 4], "completed": "bad"}, "friendship": {"minh": -12, "linh": 9999}, "heard": [null, {}, "unknown"], "cells": {"minh": "9999,9999"}, "merchant": {"consumed_days": "bad"}})
	assert_eq(int(state.friendship[&"minh"]), 0)
	assert_eq(int(state.friendship[&"linh"]), state.get_npc(&"linh").friendship_max)
	assert_true(state.heard.is_empty())
	assert_true(state.quests.get_active_quest_ids().is_empty())
	assert_eq(state.cells[&"minh"], state.scheduler.location_cell(&"minh_home"))
