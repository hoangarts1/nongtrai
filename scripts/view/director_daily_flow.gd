## LifeDirectorDailyFlow - reserved appendix of the existing completed-morning path.
class_name LifeDirectorDailyFlow
extends Node

var busy: bool = false
var last_reason: StringName = &""
var _main: Node
var _activity_token: RefCounted
var _director_token: RefCounted
var _day: int = -1

func configure(main: Node) -> void:
	_main = main

func begin(day: int) -> Dictionary:
	if busy or day != GameClock.day_index or _main.director_runtime.busy or _main.director_activity_collector.busy:
		return {"ok": false, "reason": &"director_daily_busy"}
	if not bool(_main.get("_game_started")) or _main.start_menu.visible:
		_main.director_activity.mark_partial(int(_main.director_activity.serialize().current_day))
	var observed: Dictionary = _main.director_activity.begin_day(day)
	if not observed.ok:
		return observed
	var decision: Dictionary = _main.director_state.begin_day(day)
	if not decision.ok:
		_main.director_activity.abort_day(observed.token)
		return decision
	_activity_token = observed.token
	_director_token = decision.token
	_day = day
	busy = true
	return {"ok": true}

func finish(day: int) -> bool:
	if not busy or day != _day or day != GameClock.day_index or _main.ecology_state.get_day_index() != day or int(_main.chicken_coop.coop.serialize().current_day) != day or int(_main.weather_state.get_day_index()) != day:
		return false
	if not _main.director_activity.finish_day(_activity_token).ok:
		return false
	_activity_token = null
	if not bool(_main.get("_game_started")) or _main.start_menu.visible:
		_main.director_activity.mark_partial(day)
	var observation: Dictionary = _main.director_runtime.capture_observation(true) if _main.director_state.is_enabled() else {}
	if _main.director_state.is_enabled() and not observation.get("ok", false):
		# Raw debug clock/calendar edits cannot strand already completed core progress.
		last_reason = &"observation_unavailable_disabled"
		_main.director_state.abort_day(_director_token)
		_main.director_state.set_enabled(false)
		var retry: Dictionary = _main.director_state.begin_day(day)
		if not retry.ok:
			return false
		_director_token = retry.token
		observation = {}
	var result: Dictionary = _main.director_state.finish_day(_director_token, observation)
	if not result.ok:
		return false
	_director_token = null
	_day = -1
	busy = false
	_main.director_runtime.invalidate()
	return true

func abort() -> bool:
	if not busy:
		return false
	var activity_ok: bool = _activity_token == null or _main.director_activity.abort_day(_activity_token)
	var director_ok: bool = _director_token == null or _main.director_state.abort_day(_director_token)
	if activity_ok and director_ok:
		_activity_token = null
		_director_token = null
		_day = -1
		busy = false
	return activity_ok and director_ok
