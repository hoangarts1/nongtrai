extends GutTest
const CONFIG: ClearingConfig = preload("res://data/clearing_config.tres")
var state: ClearingState
func before_each() -> void:
	state = ClearingState.new()
	assert_true(state.configure(CONFIG))

func test_data_uses_real_debris_ids_outside_protected_land_and_can_reach_first_goal() -> void:
	var candidates: Array[Dictionary] = state.get_candidates()
	assert_gte(candidates.size(),CONFIG.story_goal)
	for row: Dictionary in candidates:
		var entry: Dictionary = CONFIG.scenery.get_entry(row.asset_id)
		assert_true(entry.kind in [&"rock",&"grass_clump"])
		assert_true(CONFIG.world.player_region.has_point(row.cell))
		assert_false(CONFIG.land.initial_region.has_point(row.cell))
		for parcel: ExpansionParcelData in CONFIG.land.parcels: assert_false(parcel.region.has_point(row.cell))
	assert_eq(state.get_goal(),CONFIG.story_goal)
	assert_eq(state.serialize(),{"cleared":[]})

func test_exact_token_cancel_fail_and_once_only_commit_preserve_canonical_json() -> void:
	var row: Dictionary = state.get_candidates()[0]
	var before: Dictionary = state.serialize()
	assert_false(state.reserve(row.cell,&"tree_fruit").ok)
	var reserved: Dictionary = state.reserve(row.cell,row.asset_id)
	assert_true(reserved.ok)
	assert_true(state.is_busy())
	assert_eq(state.serialize(),before,"A preview/reservation is never progress")
	assert_false(state.commit(RefCounted.new()))
	assert_false(state.cancel(RefCounted.new()))
	assert_true(state.cancel(reserved.token))
	assert_eq(state.serialize(),before)
	reserved = state.reserve(row.cell,row.asset_id)
	assert_true(state.commit(reserved.token))
	assert_false(state.commit(reserved.token))
	assert_true(state.is_busy())
	assert_false(state.cancel(reserved.token))
	assert_true(state.finish(reserved.token))
	assert_false(state.finish(reserved.token))
	assert_false(state.reserve(row.cell,row.asset_id).ok)
	assert_true(state.is_cleared(row.cell,row.asset_id))
	assert_eq(state.get_count(),1)
	assert_false(state.is_busy())
	var wire: Dictionary = state.serialize()
	assert_eq(wire.size(),1)
	var copy: ClearingState = ClearingState.new()
	assert_true(copy.configure(CONFIG))
	assert_true(copy.deserialize(JSON.parse_string(JSON.stringify(wire))))
	assert_eq(copy.serialize(),wire)
	wire.cleared.clear()
	assert_eq(copy.get_count(),1)

func test_publication_reentry_cannot_commit_cancel_reset_or_reconfigure() -> void:
	var row: Dictionary = state.get_candidates()[0]
	var reservation: Dictionary = state.reserve(row.cell,row.asset_id)
	var attempts: Array[bool] = []
	var observer: Callable = func() -> void:
		attempts.append(state.is_busy())
		attempts.append(state.commit(reservation.token))
		attempts.append(state.cancel(reservation.token))
		attempts.append(state.finish(reservation.token))
		attempts.append(state.deserialize(ClearingSaveCodec.empty()))
		attempts.append(state.configure(CONFIG))
		attempts.append(state.reserve(row.cell,row.asset_id).ok)
	state.changed.connect(observer)
	assert_true(state.commit(reservation.token))
	state.changed.disconnect(observer)
	assert_eq(attempts,[true,false,false,false,false,false,false])
	assert_eq(state.get_count(),1)
	assert_true(state.finish(reservation.token))
	assert_false(state.is_busy())

func test_bad_restore_is_atomic_silent_restore_and_frozen_context_do_not_share_data() -> void:
	var row: Dictionary = state.get_candidates()[0]
	var token: RefCounted = state.reserve(row.cell,row.asset_id).token
	assert_true(state.commit(token))
	assert_true(state.finish(token))
	var before: Dictionary = state.serialize()
	var calls: Array[int] = [0]
	state.changed.connect(func() -> void: calls[0] += 1)
	assert_true(state.deserialize(before))
	assert_eq(calls[0],0)
	assert_false(state.deserialize({"cleared":[{"x":row.cell.x,"y":row.cell.y,"asset_id":"tree_fruit"}]}))
	assert_false(state.configure(null))
	assert_eq(state.serialize(),before)
	var candidates: Array[Dictionary] = state.get_candidates()
	candidates[0].asset_id = &"tree_fruit"
	assert_ne(state.get_candidates()[0].asset_id,&"tree_fruit")
