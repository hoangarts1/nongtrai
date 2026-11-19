## DirectorState - sole pure decision/schedule owner, default off and atomically guarded.
## API: configure(profile,day)->bool; set_enabled(value,authorized=false)->bool;
## queue_force(id,authorized=false)->bool; begin_day(day)->Dictionary;
## finish_day(token,snapshot)->Dictionary; abort_day(token)->bool;
## get_context()->Dictionary; serialize(); deserialize(raw)->bool; is_busy()->bool.
class_name DirectorState
extends RefCounted

signal director_changed(day_index: int)
var _profile: DirectorProfile
var _snapshot: Dictionary = {}
var _token: RefCounted
var _next_day: int = -1
var _notifying: bool = false

func configure(profile: DirectorProfile, day: int) -> bool:
	if is_busy() or profile == null or not profile.validation_errors().is_empty() or not DirectorActivityCodec.valid_integer(day):
		return false
	_profile = profile.frozen_copy()
	_snapshot = DirectorSnapshotCodec.baseline(day)
	return true

func is_busy() -> bool:
	return _token != null or _notifying

func get_day_index() -> int:
	return int(_snapshot.get("day_index", -1))

func is_enabled() -> bool:
	return bool(_snapshot.get("enabled", false))

func set_enabled(value: bool, authorized: bool = false) -> bool:
	if is_busy() or _profile == null or (value and not authorized):
		return false
	if value == is_enabled():
		return true
	var candidate: Dictionary = serialize()
	candidate.enabled = value
	if value:
		candidate.enabled_day = get_day_index()
		candidate.last_positive_day = null
	else:
		candidate.pending = []
		candidate.active = []
		candidate.forced = ""
	return _commit(candidate)

func queue_force(id: StringName, authorized: bool = false) -> bool:
	if is_busy() or not authorized or not is_enabled() or (not id.is_empty() and _profile.get_event(id) == null):
		return false
	var candidate: Dictionary = serialize()
	candidate.forced = String(id)
	return _commit(candidate)

func begin_day(day: int) -> Dictionary:
	if is_busy() or _profile == null:
		return {"ok": false, "reason": &"director_busy_or_unconfigured"}
	if get_day_index() >= DirectorActivityCodec.MAX_JSON_INTEGER or day != get_day_index() + 1:
		return {"ok": false, "reason": &"wrong_day"}
	_token = RefCounted.new()
	_next_day = day
	return {"ok": true, "token": _token}

func finish_day(token: RefCounted, snapshot: Dictionary = {}) -> Dictionary:
	if token == null or token != _token or _notifying:
		return {"ok": false, "reason": &"invalid_token"}
	var candidate: Dictionary = DirectorScheduleRules.advance(_snapshot, _next_day)
	var decision: Dictionary = DirectorHistoryRules.empty_decision(_next_day)
	if is_enabled():
		if not DirectorSnapshot.valid(_profile, snapshot) or int(snapshot.day_index) != _next_day or not snapshot.source.gates.enabled:
			return {"ok": false, "reason": &"invalid_snapshot"}
		decision = EventDirector.decide(_profile, snapshot, DirectorScheduleRules.context(candidate), StringName(candidate.forced))
		if not decision.ok:
			if decision.get("reason") != &"forced_ineligible":
				return decision
			# Consume a declined intent once; it never falls back to another lottery.
			var trace: Dictionary = decision.get("trace", {}).duplicate(true)
			decision = DirectorHistoryRules.empty_decision(_next_day, "forced_ineligible")
			decision.trace = trace
	if not decision.event.is_empty():
		DirectorScheduleRules.book(_profile, candidate, decision.event)
	candidate.forced = ""
	DirectorHistoryRules.append(_profile, candidate, decision)
	if not _commit(candidate):
		return {"ok": false, "reason": &"invalid_candidate"}
	_token = null
	_next_day = -1
	return {"ok": true, "decision": decision.duplicate(true)}

func abort_day(token: RefCounted) -> bool:
	if token == null or token != _token or _notifying:
		return false
	_token = null
	_next_day = -1
	return true

func get_context() -> Dictionary:
	return DirectorScheduleRules.context(_snapshot) if _profile != null else {}

func serialize() -> Dictionary:
	return _snapshot.duplicate(true)

func deserialize(raw: Dictionary) -> bool:
	if is_busy():
		return false
	var decoded: Dictionary = DirectorSnapshotCodec.decode(_profile, raw)
	if not decoded.ok:
		return false
	_snapshot = decoded.snapshot
	return true

func _commit(candidate: Dictionary) -> bool:
	var decoded: Dictionary = DirectorSnapshotCodec.decode(_profile, candidate)
	if not decoded.ok:
		return false
	_snapshot = decoded.snapshot
	_notifying = true
	director_changed.emit(get_day_index())
	_notifying = false
	return true
