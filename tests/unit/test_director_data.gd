extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const LOCALES: Array[String] = ["res://localization/strings_vi.csv", "res://localization/strings_en.csv"]

func test_approved_policy_is_data_owned_and_disabled_with_three_real_bindings() -> void:
	assert_eq(DataValidator.validate_director_profile(PROFILE, LOCALES), PackedStringArray())
	assert_false(PROFILE.enabled)
	assert_eq(PROFILE.events.size(), 3)
	assert_eq(PROFILE.grace_days, 7)
	assert_eq(PROFILE.pity_days, 7)
	assert_eq(PROFILE.max_negative_per_season, 2)
	assert_eq(PROFILE.min_negative_gap, 3)
	assert_eq(PROFILE.history_limit, 128)
	assert_eq(PROFILE.no_event_weight, 1.0)
	assert_eq(PROFILE.activity_bonus_max, 0.5)
	assert_eq(PROFILE.seasons.size(), 4)
	assert_null(PROFILE.get_event(&"unknown"))
	for resource: Resource in PROFILE.events:
		var event: DirectorEventData = resource as DirectorEventData
		assert_eq(event.weight, 1.0)
		assert_eq(event.cooldown_days, 7)
		assert_eq(event.effects.size(), 1)
		assert_eq(String(event.effects[0].kind), DirectorProfile.EVENT_EFFECTS[String(event.id)])

func test_dust_terms_have_actual_measured_canopy_rain_refill_counter_and_forewarning() -> void:
	var event: DirectorEventData = PROFILE.get_event(&"gentle_dust")
	assert_true(event.is_negative)
	assert_eq(event.telegraph_days, 2)
	assert_eq(event.duration_days, 1)
	assert_eq(event.max_per_season, 2)
	var effect: DirectorEffectData = event.effects[0] as DirectorEffectData
	assert_eq(effect.extra_charge, 1)
	assert_true(effect.waive_rain)
	assert_eq(effect.exempt_metric_id, &"tree_cover")
	assert_eq(effect.exempt_threshold_id, &"birds")
	assert_eq(float(PROFILE.ecology.get_metric(&"tree_cover").thresholds[0].value), 30.0)
	var terms: Dictionary = effect.terms()
	terms.extra_charge = 999
	assert_eq(effect.extra_charge, 1)

func test_visit_reuses_current_merchant_market_and_hours_and_bloom_changes_no_counts() -> void:
	var visit: DirectorEventData = PROFILE.get_event(&"merchant_visit")
	assert_false(visit.is_negative)
	assert_eq(visit.duration_days, 1)
	assert_eq(visit.telegraph_days, 0)
	assert_eq(visit.max_per_season, 0)
	assert_eq(visit.effects[0].npc_id, &"minh")
	assert_eq(visit.effects[0].location_id, &"minh_market")
	var found: bool = false
	for npc: NpcData in PROFILE.npc_world.npcs:
		if npc.npc_id == &"minh":
			for entry: NpcScheduleEntry in npc.schedule:
				if entry.location_id == &"minh_market":
					assert_eq(entry.start_minute, 1020)
					assert_eq(entry.end_minute, 1320)
					found = true
	assert_true(found)
	var bloom: DirectorEventData = PROFILE.get_event(&"butterfly_bloom")
	assert_eq(bloom.duration_days, 2)
	assert_eq(bloom.conditions[0].metric_id, &"biodiversity")
	assert_eq(bloom.conditions[0].threshold_id, &"butterflies")
	assert_eq(bloom.effects[0].kind, &"butterfly_accent")
	assert_false(bloom.effects[0].terms().has("count"))

func test_frozen_copy_detaches_nested_definitions_calendars_thresholds_and_weather() -> void:
	var copy: DirectorProfile = PROFILE.frozen_copy()
	assert_eq(copy.validation_errors(), PackedStringArray())
	copy.get_event(&"gentle_dust").effects[0].extra_charge = 9
	copy.get_event(&"gentle_dust").conditions[0].kind = &"unknown"
	copy.ecology.get_metric(&"tree_cover").thresholds[0].value = 99.0
	copy.weather.entries[0].probability = 0
	(copy.seasons[0] as SeasonData).days_in_season = 90
	(copy.npc_world.npcs[0] as NpcData).schedule[0].start_minute = 1
	assert_eq(PROFILE.get_event(&"gentle_dust").effects[0].extra_charge, 1)
	assert_eq(PROFILE.get_event(&"gentle_dust").conditions[0].kind, &"dry_start")
	assert_eq(float(PROFILE.ecology.get_metric(&"tree_cover").thresholds[0].value), 30.0)
	assert_eq(PROFILE.weather.entries[0].probability, 55)
	assert_eq((PROFILE.seasons[0] as SeasonData).days_in_season, 28)
	assert_eq((PROFILE.npc_world.npcs[0] as NpcData).schedule[0].start_minute, 1020)
