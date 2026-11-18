extends GutTest

const SHIPPED: EcologyProfile = preload("res://data/ecology_profile.tres")
var _source: EcologyProfile
var _state: EcologyState

func before_each() -> void:
	_source = EcologyProfile.new()
	for resource: Resource in SHIPPED.metrics:
		var source: EcologyMetricData = resource as EcologyMetricData
		var copy: EcologyMetricData = source.duplicate(true) as EcologyMetricData
		copy.thresholds = source.thresholds.duplicate(true)
		_source.metrics.append(copy)
	_state = EcologyState.new()
	assert_true(_state.configure(_source))

func after_each() -> void:
	_state = null
	_source = null

func _targets(value: float) -> Dictionary:
	return {"tree_cover": value, "water_clarity": value, "biodiversity": value}

func test_initialization_and_ten_percent_ease_respond_both_directions() -> void:
	var instance: Object = _state
	assert_false(instance is Node)
	assert_eq(_state.get_metrics(), _targets(0.0))
	assert_eq(_state.get_day_index(), 0)
	assert_eq(_state.get_triggered(), PackedStringArray())
	assert_false(_state.is_threshold_active(&"unknown"))
	assert_true(_state.advance_day(1, _targets(100.0)).ok)
	assert_eq(_state.get_metrics(), _targets(10.0))
	assert_true(_state.advance_day(2, _targets(100.0)).ok)
	assert_eq(_state.get_metrics(), _targets(19.0))
	assert_true(_state.advance_day(3, _targets(0.0)).ok)
	for value: float in _state.get_metrics().values():
		assert_almost_eq(value, 17.1, 0.00000001)
	assert_eq(_state.get_day_index(), 3)

func test_boundaries_up_down_and_recross_emit_once_and_history_is_permanent() -> void:
	for resource: Resource in _source.metrics:
		(resource as EcologyMetricData).ease_percent = 100.0
	assert_true(_state.configure(_source))
	var crossed: Array[StringName] = []
	var changes: Array[int] = [0]
	_state.threshold_crossed.connect(func(id: StringName) -> void: crossed.append(id))
	_state.ecology_changed.connect(func(_values: Dictionary) -> void: changes[0] += 1)
	var at: Dictionary = {"tree_cover": 30.0, "water_clarity": 50.0, "biodiversity": 25.0}
	assert_true(_state.advance_day(1, at).ok)
	assert_eq(crossed, [&"birds", &"clear_water", &"butterflies"])
	for id: StringName in crossed:
		assert_true(_state.is_threshold_active(id))
	assert_true(_state.advance_day(2, at).ok)
	assert_eq(crossed.size(), 3)
	assert_eq(changes[0], 1, "No changed signal while values stand still")
	assert_true(_state.advance_day(3, {"tree_cover": 29.0, "water_clarity": 49.0, "biodiversity": 24.0}).ok)
	assert_eq(crossed.size(), 6)
	assert_false(_state.is_threshold_active(&"birds"))
	assert_eq(_state.get_triggered(), PackedStringArray(["birds", "clear_water", "butterflies"]))
	assert_true(_state.advance_day(4, _targets(0.0)).ok)
	assert_eq(crossed.size(), 6, "Remaining below never spams crossings")
	assert_true(_state.advance_day(5, at).ok)
	assert_eq(crossed.size(), 9)
	assert_eq(_state.get_triggered().size(), 3)

func test_shipped_ease_reaches_real_thresholds_on_expected_days_without_spam() -> void:
	var crossed: Array[Dictionary] = []
	_state.threshold_crossed.connect(func(id: StringName) -> void: crossed.append({"id": id, "day": _state.get_day_index()}))
	for day: int in range(1, 11):
		assert_true(_state.advance_day(day, _targets(100.0)).ok)
	assert_eq(crossed, [{"id": &"butterflies", "day": 3}, {"id": &"birds", "day": 4}, {"id": &"clear_water", "day": 7}])
	assert_eq(_state.get_triggered(), PackedStringArray(["birds", "clear_water", "butterflies"]))

func test_bad_targets_days_and_configuration_leave_the_entire_committed_owner_unchanged() -> void:
	assert_true(_state.advance_day(1, _targets(100.0)).ok)
	var before: Dictionary = _state.serialize()
	for day: int in [-1, 0, 1, 3, EcologySnapshotCodec.MAX_JSON_INTEGER + 1]:
		assert_false(_state.advance_day(day, _targets(100.0)).ok)
		assert_eq(_state.serialize(), before)
	for value: Variant in [true, "50", null, NAN, INF, -1.0, 101.0]:
		var targets: Dictionary = _targets(50.0)
		targets.water_clarity = value
		assert_false(_state.advance_day(2, targets).ok)
		assert_eq(_state.serialize(), before)
	assert_false(_state.advance_day(2, {"tree_cover": 20.0}).ok)
	assert_false(_state.configure(null))
	assert_false(_state.configure(EcologyProfile.new()))
	assert_false(_state.configure(_source, -1))
	assert_eq(_state.serialize(), before)
	assert_true(_state.advance_day(2, _targets(100.0)).ok, "Rejected attempts do not consume the next day")
	assert_true(_state.configure(_source, EcologySnapshotCodec.MAX_JSON_INTEGER))
	before = _state.serialize()
	assert_false(_state.advance_day(EcologySnapshotCodec.MAX_JSON_INTEGER + 1, _targets(100.0)).ok)
	assert_eq(_state.serialize(), before)

func test_callback_reentry_sees_complete_state_and_cannot_reconfigure_restore_or_advance() -> void:
	var attempts: Array[bool] = []
	var targets: Dictionary = _targets(100.0)
	_state.ecology_changed.connect(func(values: Dictionary) -> void:
		assert_true(_state.is_busy())
		assert_eq(_state.get_metrics(), _targets(10.0))
		assert_eq(_state.get_day_index(), 1)
		values.tree_cover = -999.0
		targets.water_clarity = 0.0
		_source.get_metric(&"tree_cover").ease_percent = 100.0
		attempts.append(_state.configure(_source))
		attempts.append(_state.deserialize(_state.serialize()))
		attempts.append(_state.advance_day(2, _targets(100.0)).ok))
	assert_true(_state.advance_day(1, targets).ok)
	assert_eq(attempts, [false, false, false])
	assert_eq(_state.get_metrics(), _targets(10.0))
	assert_false(_state.is_busy())
	# Disconnect this one-day observer before checking the independently frozen config.
	for connection: Dictionary in _state.ecology_changed.get_connections():
		_state.ecology_changed.disconnect(connection.callable)
	assert_true(_state.advance_day(2, _targets(100.0)).ok)
	assert_eq(_state.get_metrics(), _targets(19.0))

func test_threshold_callback_reentry_and_getters_cannot_mutate_history_or_metrics() -> void:
	for resource: Resource in _source.metrics:
		(resource as EcologyMetricData).ease_percent = 100.0
	assert_true(_state.configure(_source))
	var attempts: Array[bool] = []
	_state.threshold_crossed.connect(func(_id: StringName) -> void:
		assert_true(_state.is_busy())
		assert_eq(_state.get_metrics(), _targets(100.0))
		assert_eq(_state.get_triggered().size(), 3)
		var snapshot: Dictionary = _state.serialize()
		snapshot.metrics.clear()
		snapshot.triggered.clear()
		var history: PackedStringArray = _state.get_triggered()
		history.clear()
		attempts.append(_state.advance_day(2, _targets(0.0)).ok))
	var result: Dictionary = _state.advance_day(1, _targets(100.0))
	assert_eq(attempts, [false, false, false])
	result.snapshot.metrics.tree_cover = 0.0
	assert_eq(_state.get_metrics(), _targets(100.0))
	assert_eq(_state.get_triggered().size(), 3)

func test_silent_json_restore_preserves_history_and_failed_restore_keeps_prior_state() -> void:
	for day: int in range(1, 8):
		assert_true(_state.advance_day(day, _targets(100.0)).ok)
	var saved: Dictionary = _state.serialize()
	var restored: EcologyState = EcologyState.new()
	assert_true(restored.configure(SHIPPED))
	var emitted: Array[String] = []
	restored.ecology_changed.connect(func(_values: Dictionary) -> void: emitted.append("changed"))
	restored.threshold_crossed.connect(func(_id: StringName) -> void: emitted.append("crossed"))
	var wire: Dictionary = JSON.parse_string(JSON.stringify(saved))
	assert_true(restored.deserialize(wire))
	assert_eq(restored.serialize(), saved)
	assert_eq(emitted, [])
	wire.metrics.tree_cover = 0.0
	assert_eq(restored.serialize(), saved)
	assert_false(restored.deserialize({}))
	assert_eq(restored.serialize(), saved)
	assert_eq(restored.advance_day(8, _targets(0.0)).snapshot, _state.advance_day(8, _targets(0.0)).snapshot)

func test_two_owners_remain_independent_and_no_game_clock_or_registry_is_consulted() -> void:
	var other: EcologyState = EcologyState.new()
	assert_eq(other.serialize(), {})
	assert_false(other.advance_day(1, _targets(100.0)).ok)
	assert_false(other.deserialize(_state.serialize()))
	assert_true(other.configure(_source))
	var clock: Dictionary = GameClock.serialize()
	assert_true(_state.advance_day(1, _targets(100.0)).ok)
	assert_eq(other.get_metrics(), _targets(0.0))
	assert_eq(GameClock.serialize(), clock)
	_source.get_metric(&"tree_cover").thresholds[0].value = 1.0
	assert_true(other.advance_day(1, _targets(100.0)).ok)
	assert_false(other.is_threshold_active(&"birds"), "Nested source edits never change either frozen owner")
