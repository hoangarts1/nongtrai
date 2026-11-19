extends GutTest

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const CAN: WateringCanConfig = preload("res://data/watering_can_config.tres")
const OBS: Script = preload("res://tests/unit/test_director_candidates.gd")
const STATES: Script = preload("res://tests/unit/test_director_state.gd")

static func dust_owner() -> DirectorState:
	var owner: DirectorState = STATES.enabled_owner()
	for day: int in range(7, 11):
		STATES.step(owner, day, OBS.snapshot(day, 0, 30.0, 0.0))
	owner.queue_force(&"gentle_dust", true)
	STATES.step(owner, 11)
	return owner

static func observation(owner: DirectorState, tree: float = 29.0, rain: bool = false, authorized: bool = true, measured: bool = true) -> Dictionary:
	var source: Dictionary = OBS.snapshot(owner.get_day_index(), 0, tree).source
	source.weather.today = "rain" if rain else "sunny"
	source.gates.enabled = owner.is_enabled()
	source.gates.debug_preview = authorized
	source.ecology.available.tree_cover = measured
	return DirectorSnapshot.capture(PROFILE, source.clock, source.ecology, source.activity, source.weather, source.gates)

static func active_dust() -> DirectorState:
	var owner: DirectorState = dust_owner()
	STATES.step(owner, 12)
	STATES.step(owner, 13)
	return owner

func test_pending_active_expired_use_only_absolute_captured_days_and_actual_cost() -> void:
	var owner: DirectorState = dust_owner()
	assert_eq(owner.get_day_index(), 11)
	var pending: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), observation(owner))
	assert_true(pending.ok)
	assert_eq(DirectorEffectTermsCodec.water(CAN, pending.water).charge_cost, 1)
	assert_true(STATES.step(owner, 12).ok)
	assert_true(STATES.step(owner, 13).ok)
	var active: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), observation(owner))
	assert_true(active.ok)
	assert_eq(active.dust_reason, "extra_charge")
	assert_eq(DirectorEffectTermsCodec.water(CAN, active.water).charge_cost, 2)
	assert_true(STATES.step(owner, 14).ok)
	var expired: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), observation(owner))
	assert_eq(DirectorEffectTermsCodec.water(CAN, expired.water).charge_cost, 1)

func test_current_rain_and_measured_canopy_exact_threshold_waive_extra_and_unknown_is_not_zero() -> void:
	var owner: DirectorState = active_dust()
	for row: Dictionary in [{"tree": 29.999, "rain": false, "measured": true, "cost": 2, "reason": "extra_charge"}, {"tree": 30.0, "rain": false, "measured": true, "cost": 1, "reason": "canopy"}, {"tree": 29.0, "rain": true, "measured": true, "cost": 1, "reason": "rain"}, {"tree": 0.0, "rain": false, "measured": false, "cost": 1, "reason": "canopy_unmeasured"}]:
		var projected: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), observation(owner, row.tree, row.rain, true, row.measured))
		assert_true(projected.ok)
		assert_eq(projected.dust_reason, row.reason)
		assert_eq(DirectorEffectTermsCodec.water(CAN, projected.water).charge_cost, row.cost)

func test_saved_debug_flag_cannot_bypass_actual_runtime_gate_and_off_clears_application() -> void:
	var owner: DirectorState = active_dust()
	var locked: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), observation(owner, 29.0, false, false))
	assert_false(locked.enabled)
	assert_eq(locked.water.event, {})
	assert_eq(locked.visitor, {})
	assert_eq(locked.accent, [])
	assert_true(owner.set_enabled(false))
	var off: Dictionary = DirectorEffectProjector.project(PROFILE, owner.serialize(), observation(owner))
	assert_false(off.enabled)
	assert_eq(off.event_ids, [])

func test_incomplete_new_observations_do_not_reroll_or_cancel_an_already_captured_event() -> void:
	var owner: DirectorState = active_dust()
	var source: Dictionary = observation(owner).source
	source.activity.completed_days[0].complete = false
	var partial: Dictionary = DirectorSnapshot.capture(PROFILE, source.clock, source.ecology, source.activity, source.weather, source.gates)
	assert_true(partial.ok)
	assert_false(partial.ready)
	var before: Dictionary = owner.serialize()
	var projected: Dictionary = DirectorEffectProjector.project(PROFILE, before, partial)
	assert_eq(DirectorEffectTermsCodec.water(CAN, projected.water).charge_cost, 2)
	projected.water.event.effect.extra_charge = 100
	assert_eq(owner.serialize(), before)
