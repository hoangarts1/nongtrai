## EcologyState — standalone day-based ecology owner with local guarded notifications.
## API: configure(profile,start_day=0)->bool; advance_day(day,targets)->Dictionary;
## serialize()->Dictionary; deserialize(raw)->bool; get_metrics(); get_triggered();
## get_day_index()->int; is_busy()->bool; is_threshold_active(id)->bool.
class_name EcologyState
extends RefCounted

signal ecology_changed(metrics: Dictionary)
signal threshold_crossed(threshold_id: StringName)

var _profile: EcologyProfile
var _metrics: Dictionary = {}
var _triggered: Dictionary = {}
var _day: int = 0
var _busy: bool = false

func configure(profile: EcologyProfile, start_day: int = 0) -> bool:
	if _busy:
		return false
	_busy = true
	if profile == null or not EcologySnapshotCodec.valid_day(start_day) or not profile.validation_errors().is_empty():
		_busy = false
		return false
	# Explicitly copy nested Resources as well as their threshold dictionaries.
	var frozen: EcologyProfile = EcologyProfile.new()
	var metrics: Dictionary = {}
	for resource: Resource in profile.metrics:
		var source: EcologyMetricData = resource as EcologyMetricData
		var metric: EcologyMetricData = source.duplicate(true) as EcologyMetricData
		metric.thresholds = source.thresholds.duplicate(true)
		frozen.metrics.append(metric)
		metrics[String(metric.metric_id)] = metric.initial_value
	_profile = frozen
	_metrics = metrics
	_triggered = {}
	_day = start_day
	_busy = false
	return true

func advance_day(day: int, targets: Dictionary) -> Dictionary:
	if _busy:
		return _failure(&"busy")
	if _profile == null:
		return _failure(&"unconfigured")
	_busy = true
	if not EcologySnapshotCodec.valid_day(day) or _day >= EcologySnapshotCodec.MAX_JSON_INTEGER or day != _day + 1:
		_busy = false
		return _failure(&"wrong_day")
	var decoded: Dictionary = EcologySnapshotCodec.decode_metrics(_profile, targets)
	if not decoded.ok:
		_busy = false
		return _failure(&"invalid_targets")
	var next: Dictionary = {}
	for resource: Resource in _profile.metrics:
		var metric: EcologyMetricData = resource as EcologyMetricData
		var key: String = String(metric.metric_id)
		var before: float = _metrics[key]
		next[key] = before + (float(decoded.metrics[key]) - before) * (metric.ease_percent / EcologyMetricData.PERCENT_SCALE)
	var crossings: Array[StringName] = []
	var history: Dictionary = _triggered.duplicate()
	for row: Dictionary in _profile.get_thresholds():
		var previous: bool = float(_metrics[row.metric_id]) >= float(row.value)
		var active: bool = float(next[row.metric_id]) >= float(row.value)
		if previous != active:
			crossings.append(StringName(row.id))
			if active:
				history[row.id] = true
	var changed: bool = next != _metrics
	_metrics = next
	_triggered = history
	_day = day
	# Every observer sees a fully committed owner; reentry stays locked until done.
	if changed:
		ecology_changed.emit(get_metrics())
	for id: StringName in crossings:
		threshold_crossed.emit(id)
	var result: Dictionary = {"ok": true, "reason": &"advanced", "snapshot": serialize()}
	_busy = false
	return result

func serialize() -> Dictionary:
	if _profile == null:
		return {}
	var history: Array[String] = []
	for id: String in get_triggered():
		history.append(id)
	return {"day_index": _day, "metrics": get_metrics(), "triggered": history}

func deserialize(raw: Dictionary) -> bool:
	if _busy:
		return false
	_busy = true
	var decoded: Dictionary = EcologySnapshotCodec.decode(_profile, raw)
	if not decoded.ok:
		_busy = false
		return false
	_metrics = decoded.snapshot.metrics
	_day = decoded.snapshot.day_index
	_triggered = {}
	for id: String in decoded.snapshot.triggered:
		_triggered[id] = true
	_busy = false
	return true

func get_metrics() -> Dictionary:
	return _metrics.duplicate(true)

func get_triggered() -> PackedStringArray:
	var result: PackedStringArray = []
	if _profile != null:
		for row: Dictionary in _profile.get_thresholds():
			if _triggered.has(row.id):
				result.append(row.id)
	return result

func is_threshold_active(id: StringName) -> bool:
	if _profile != null:
		for row: Dictionary in _profile.get_thresholds():
			if row.id == String(id):
				return float(_metrics[row.metric_id]) >= float(row.value)
	return false

func get_day_index() -> int:
	return _day

func is_busy() -> bool:
	return _busy

func _failure(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
