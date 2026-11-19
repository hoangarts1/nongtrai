## LifeDirectorActivityCollector - explicit command receipts, never a producer subscriber.
class_name LifeDirectorActivityCollector
extends Node

const SOURCES: PackedStringArray = ["tool", "water", "seed_shop", "shipping_bin", "minh", "chicken_feed"]
var busy: bool = false
var last_reason: StringName = &""
var _main: Node
var _token: RefCounted
var _captured: Dictionary = {}

func configure(main: Node) -> void:
	_main = main

func begin_command(source: StringName) -> Dictionary:
	if busy or not SOURCES.has(String(source)) or not is_instance_valid(_main) or GameClock.is_sleeping() or GameClock.is_day_end_held() or bool(_main.call("_purchase_in_progress")):
		return {"ok": false, "reason": &"command_busy_or_unavailable"}
	_token = RefCounted.new()
	_captured = {"day": GameClock.day_index, "activity": _main.director_activity, "director": _main.director_state, "farm": _main.farm_state, "inventory": _main.inventory, "wallet": _main.wallet, "observed": bool(_main.get("_game_started")) and not _main.start_menu.visible}
	busy = true
	return {"ok": true, "token": _token}

func finish_command(token: RefCounted, counts: Dictionary, proven: bool = true) -> bool:
	if token == null or token != _token:
		return false
	var owner: DirectorActivityState = _captured.activity
	var same: bool = is_instance_valid(_main) and _main.director_activity == owner and _main.director_state == _captured.director and _main.farm_state == _captured.farm and _main.inventory == _captured.inventory and _main.wallet == _captured.wallet and GameClock.day_index == int(_captured.day)
	var result: Dictionary = {"ok": false, "reason": &"unproven_command"}
	var observed: bool = same and _captured.observed and bool(_main.get("_game_started")) and not _main.start_menu.visible
	if observed:
		result = owner.record_many(int(_captured.day), counts)
	elif same:
		result = {"ok": false, "reason": &"inactive_command"}
	if not observed or not proven or not result.ok:
		var partial: Dictionary = owner.mark_partial(int(owner.serialize().get("current_day", -1)))
		if not partial.ok:
			push_warning("Director activity: unable to mark uncertain coverage while reserved")
	last_reason = StringName(result.reason) if proven else &"partial_command"
	_token = null
	_captured = {}
	busy = false
	if is_instance_valid(_main):
		_main.call("_mark_save_dirty")
	return observed and proven and result.ok

func cancel_command(token: RefCounted) -> bool:
	if token == null or token != _token:
		return false
	_token = null
	_captured = {}
	busy = false
	return true
