extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const CAN: WateringCanConfig = preload("res://data/watering_can_config.tres")
const STATES: Script = preload("res://tests/unit/test_director_state.gd")
const EFFECTS: Script = preload("res://tests/unit/test_director_effect_projection.gd")

func test_actual_merchant_and_butterfly_terms_expire_without_stock_nodes_or_state_mutation() -> void:
	for id: StringName in [&"merchant_visit", &"butterfly_bloom"]:
		var owner: DirectorState = STATES.enabled_owner()
		assert_true(owner.queue_force(id, true))
		assert_true(STATES.step(owner, 7).ok)
		var before: Dictionary = owner.serialize()
		var projected: Dictionary = DirectorEffectProjector.project(PROFILE, before, EFFECTS.observation(owner))
		assert_true(projected.ok)
		if id == &"merchant_visit":
			assert_eq(projected.visitor, {"day_index": 7, "npc_id": "minh", "location_id": "minh_market"})
		else:
			assert_eq(projected.accent.size(), 4)
			assert_eq(projected.accent, before.active[0].effect.accent)
		for index: int in range(10):
			assert_eq(DirectorEffectProjector.project(PROFILE, before, EFFECTS.observation(owner)), projected)
		assert_eq(owner.serialize(), before)
		var expired_day: int = int(before.active[0].end_day)
		for day: int in range(8, expired_day + 1):
			assert_true(STATES.step(owner, day).ok)
		var after: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), EFFECTS.observation(owner))
		assert_false(after.event_ids.has(String(id)))

func test_expired_forged_wrong_kind_and_extra_fields_never_become_water_modifiers() -> void:
	var owner: DirectorState = EFFECTS.active_dust()
	var water: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), EFFECTS.observation(owner)).water
	assert_true(DirectorEffectTermsCodec.water(CAN, water).ok)
	for value: Variant in [null, true, [], {"day_index": 13}, {"day_index": true, "event": {}}]:
		assert_false(DirectorEffectTermsCodec.water(CAN, value).ok)
	var bad: Dictionary = water.duplicate(true)
	bad.day_index = int(bad.event.end_day)
	assert_false(DirectorEffectTermsCodec.water(CAN, bad).ok)
	bad = water.duplicate(true)
	bad.event.effect.extra_charge = 99
	assert_false(DirectorEffectTermsCodec.water(CAN, bad).ok)
	bad = water.duplicate(true)
	bad.charge_cost = 999
	assert_false(DirectorEffectTermsCodec.water(CAN, bad).ok)
	var bloom: Dictionary = {"day_index": 7, "event": EventDirector.event_terms(PROFILE.get_event(&"butterfly_bloom"), 7)}
	assert_false(DirectorEffectTermsCodec.water(CAN, bloom).ok)

func test_projection_rejects_mismatched_or_forged_sources_and_cannot_invent_availability() -> void:
	var owner: DirectorState = EFFECTS.active_dust()
	var raw: Dictionary = owner.serialize()
	var before: Dictionary = raw.duplicate(true)
	var observation: Dictionary = EFFECTS.observation(owner)
	observation.metrics.tree_cover = 100.0
	assert_false(DirectorEffectProjector.project(PROFILE, raw, observation).ok)
	raw.day_index = 14
	assert_false(DirectorEffectProjector.project(PROFILE, raw, EFFECTS.observation(owner)).ok)
	assert_eq(owner.serialize(), before)
