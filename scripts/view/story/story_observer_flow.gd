## LifeStoryObserverFlow - extend existing receipt completion, never duplicate counters.
class_name LifeStoryObserverFlow
extends LifeDirectorActivityCollector
signal command_committed(day: int, source: StringName, counts: Dictionary)
var _source: StringName = &""
var _dispatching: bool = false
func is_dispatching() -> bool: return _dispatching
func begin_command(source: StringName) -> Dictionary:
	if _dispatching: return {"ok":false,"reason":&"command_busy_or_unavailable"}
	var receipt: Dictionary = super.begin_command(source)
	if receipt.ok: _source = source
	return receipt
func finish_command(token: RefCounted, counts: Dictionary, proven: bool = true) -> bool:
	var day: int = GameClock.day_index
	var source: StringName = _source
	var committed: bool = super.finish_command(token,counts,proven)
	if committed:
		# The base tests proven after publishing counters; only its true return is proof.
		# Retain the original busy window through this extra read-only receipt publication.
		_dispatching = true
		busy = true
		command_committed.emit(day,source,counts.duplicate(true))
		busy = false
		_dispatching = false
	if not busy: _source = &""
	return committed
func reset_receipt() -> bool:
	if busy or _dispatching: return false
	_source = &""
	return true
