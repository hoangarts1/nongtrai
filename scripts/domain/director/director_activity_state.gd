## DirectorActivityState — sole standalone observation owner; no runtime subscriptions.
## API: configure(config,day,full_day=false)->bool; record(day,activity,quantity)->Dictionary;
## advance_day(next_day)->Dictionary; get_window_snapshot(); serialize(); deserialize(raw)->bool.
## signal activity_changed(day_index:int); is_busy()->bool.
## record_many(day,counts)->Dictionary; mark_partial(day)->Dictionary;
## begin_day(next_day)->Dictionary; finish_day(token)->Dictionary; abort_day(token)->bool.
class_name DirectorActivityState
extends RefCounted

signal activity_changed(day_index: int)
var _config: DirectorActivityConfig
var _snapshot: Dictionary = {}
var _busy: bool = false
var _day_token: RefCounted
var _reserved_day: Dictionary = {}

func configure(config: DirectorActivityConfig, day: int, full_day: bool = false) -> bool:
	if is_busy():
		return false
	_busy = true
	if config == null or not DirectorActivityCodec.valid_integer(day) or not config.validation_errors().is_empty():
		_busy = false
		return false
	var frozen: DirectorActivityConfig = config.duplicate(true) as DirectorActivityConfig
	frozen.activity_ids = config.activity_ids.duplicate()
	var candidate: Dictionary = {"current_day": day, "started_day": day, "current_complete": full_day, "current_counts": DirectorActivityCodec.empty_counts(frozen), "completed_days": []}
	_config = frozen
	_snapshot = candidate
	_busy = false
	return true

func record(day: int, activity: StringName, quantity: int) -> Dictionary:
	return record_many(day, {String(activity): quantity})

func record_many(day: int, counts: Dictionary) -> Dictionary:
	if is_busy():
		return _failure(&"busy")
	if _config == null:
		return _failure(&"unconfigured")
	if day != int(_snapshot.current_day):
		return _failure(&"wrong_day")
	for id: Variant in counts:
		if not DirectorActivityConfig.valid_id(id) or not _config.activity_ids.has(String(id)):
			return _failure(&"unknown_activity")
		if not DirectorActivityCodec.valid_integer(counts[id]) or int(counts[id]) <= 0 or int(counts[id]) > DirectorActivityCodec.MAX_JSON_INTEGER - int(_snapshot.current_counts[String(id)]):
			return _failure(&"invalid_or_overflow_quantity")
	if counts.is_empty():
		return {"ok": true, "reason": &"no_receipts"}
	_busy = true
	var candidate: Dictionary = serialize()
	for id: Variant in counts:
		candidate.current_counts[String(id)] += int(counts[id])
	return _commit(candidate, &"recorded")

func mark_partial(day: int) -> Dictionary:
	if is_busy():
		return _failure(&"busy")
	if _config == null or day != int(_snapshot.current_day):
		return _failure(&"wrong_day")
	if not _snapshot.current_complete:
		return {"ok": true, "reason": &"already_partial"}
	_busy = true
	var candidate: Dictionary = serialize()
	candidate.current_complete = false
	return _commit(candidate, &"partial")

func begin_day(next_day: int) -> Dictionary:
	if is_busy():
		return _failure(&"busy")
	if _config == null:
		return _failure(&"unconfigured")
	if int(_snapshot.current_day) >= DirectorActivityCodec.MAX_JSON_INTEGER or next_day != int(_snapshot.current_day) + 1:
		return _failure(&"wrong_day")
	var candidate: Dictionary = serialize()
	candidate.completed_days.append({"day_index": int(candidate.current_day), "complete": candidate.current_complete, "counts": candidate.current_counts.duplicate()})
	if candidate.completed_days.size() > _config.window_days:
		candidate.completed_days.pop_front()
	candidate.current_day = next_day
	candidate.current_complete = true
	candidate.current_counts = DirectorActivityCodec.empty_counts(_config)
	var decoded: Dictionary = DirectorActivityCodec.decode(_config, candidate)
	if not decoded.ok:
		return _failure(&"invalid_or_overflow_snapshot")
	_reserved_day = decoded.snapshot
	_day_token = RefCounted.new()
	return {"ok": true, "token": _day_token}

func finish_day(token: RefCounted) -> Dictionary:
	if token == null or token != _day_token or _busy:
		return _failure(&"invalid_token")
	_busy = true
	var result: Dictionary = _commit(_reserved_day, &"advanced")
	if result.ok:
		_day_token = null
		_reserved_day = {}
	return result

func abort_day(token: RefCounted) -> bool:
	if token == null or token != _day_token or _busy:
		return false
	_day_token = null
	_reserved_day = {}
	return true

func advance_day(next_day: int) -> Dictionary:
	var reserved: Dictionary = begin_day(next_day)
	return finish_day(reserved.token) if reserved.ok else reserved

func _commit(candidate: Dictionary, reason: StringName) -> Dictionary:
	var decoded: Dictionary = DirectorActivityCodec.decode(_config, candidate)
	if not decoded.ok:
		_busy = false
		return _failure(&"invalid_or_overflow_snapshot")
	_snapshot = decoded.snapshot
	# Observers see an atomic committed owner while all mutation paths stay locked.
	activity_changed.emit(int(_snapshot.current_day))
	_busy = false
	return {"ok": true, "reason": reason}

func get_window_snapshot() -> Dictionary:
	if _config == null:
		return {"ok": false, "reason": &"unconfigured"}
	var totals: Dictionary = DirectorActivityCodec.empty_counts(_config)
	var complete: int = 0
	for row: Dictionary in _snapshot.completed_days:
		if row.complete:
			complete += 1
		for id: String in _config.activity_ids:
			totals[id] += int(row.counts[id])
	var observed: int = _snapshot.completed_days.size()
	var available: bool = observed == _config.window_days and complete == _config.window_days
	return {"ok": true, "day_index": int(_snapshot.current_day), "window_days": _config.window_days, "observed_days": observed, "complete_days": complete, "available": available, "totals": totals if available else {}}

func serialize() -> Dictionary:
	return _snapshot.duplicate(true)

func deserialize(raw: Dictionary) -> bool:
	if is_busy():
		return false
	_busy = true
	var decoded: Dictionary = DirectorActivityCodec.decode(_config, raw)
	if not decoded.ok:
		_busy = false
		return false
	_snapshot = decoded.snapshot
	_busy = false
	return true

func is_busy() -> bool:
	return _busy or _day_token != null

func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
