## GameClock — owns the in-game day clock and morning rollover.
## API:
##   func advance_real_seconds(seconds: float) -> void
##   func sleep_to_morning() -> void
##   func can_sleep() -> bool
##   func try_sleep() -> bool
##   func is_sleeping() -> bool
##   func format_time(total_minutes: int) -> String
##   func set_time(hour: int, minute_in_hour: int) -> void
##   func set_speed(multiplier: float) -> void
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
extends Node

const MINUTES_PER_DAY: int = 1440
const MORNING_MINUTE: int = 360
const DAY_END_MINUTE: int = 1560
const SLEEP_END_MINUTE: int = 1800
const DEFAULT_DAY_REAL_SECONDS: float = 720.0

signal time_changed(day_index: int, minute: int)
signal day_started(day_index: int)
signal hour_changed(hour: int)
signal sleep_started()
signal sleep_finished(day_index: int)
@warning_ignore("unused_signal")
signal season_changed(season: StringName)

@export var day_real_seconds: float = DEFAULT_DAY_REAL_SECONDS

var day_index: int = 0
var minute: int = MORNING_MINUTE
var season: StringName = &"spring"
var year: int = 1
var paused: bool = false
var time_speed: float = 1.0
var _sleeping: bool = false
var _sleep_restore_speed: float = 1.0
var _real_seconds_accumulator: float = 0.0

func _process(delta: float) -> void:
	if not paused:
		advance_real_seconds(delta * time_speed)

func advance_real_seconds(seconds: float) -> void:
	if seconds <= 0.0 or day_real_seconds <= 0.0:
		return
	_real_seconds_accumulator += seconds
	var game_minutes: int = floori(_real_seconds_accumulator * float(MINUTES_PER_DAY) / day_real_seconds)
	if game_minutes <= 0:
		return
	_real_seconds_accumulator -= float(game_minutes) * day_real_seconds / float(MINUTES_PER_DAY)
	advance_minutes(game_minutes)

func advance_minutes(minutes: int) -> void:
	if minutes <= 0:
		return
	var previous_hour: int = get_hour()
	minute += minutes
	if _sleeping and minute >= SLEEP_END_MINUTE:
		_finish_sleep()
		return
	if not _sleeping and minute >= DAY_END_MINUTE:
		sleep_to_morning()
		return
	if get_hour() != previous_hour:
		hour_changed.emit(get_hour())
		Events.hour_changed.emit(get_hour())
	time_changed.emit(day_index, minute)

func sleep_to_morning() -> void:
	day_index += 1
	minute = MORNING_MINUTE
	_real_seconds_accumulator = 0.0
	time_changed.emit(day_index, minute)
	day_started.emit(day_index)
	Events.day_started.emit(day_index)

func can_sleep() -> bool:
	return minute >= 1200 and minute < DAY_END_MINUTE

func try_sleep() -> bool:
	if not can_sleep() or _sleeping:
		return false
	_sleeping = true
	_sleep_restore_speed = time_speed
	time_speed = 20.0
	sleep_started.emit()
	return true

func is_sleeping() -> bool:
	return _sleeping

func _finish_sleep() -> void:
	_sleeping = false
	day_index += 1
	minute = MORNING_MINUTE
	time_speed = _sleep_restore_speed
	_real_seconds_accumulator = 0.0
	time_changed.emit(day_index, minute)
	day_started.emit(day_index)
	sleep_finished.emit(day_index)
	Events.day_started.emit(day_index)

func set_time(hour: int, minute_in_hour: int) -> void:
	if _sleeping:
		return
	var requested_minute: int = maxi(0, hour * 60 + minute_in_hour)
	minute = clampi(requested_minute, MORNING_MINUTE, DAY_END_MINUTE - 1)
	_real_seconds_accumulator = 0.0
	time_changed.emit(day_index, minute)

func set_speed(multiplier: float) -> void:
	if _sleeping:
		return
	time_speed = maxf(multiplier, 0.0)

func get_hour() -> int:
	return floori(float(minute) / 60.0) % 24

func get_minute_in_hour() -> int:
	return minute % 60

func format_time(total_minutes: int) -> String:
	var display_minutes: int = posmod(total_minutes, MINUTES_PER_DAY)
	return "%02d:%02d" % [floori(float(display_minutes) / 60.0), display_minutes % 60]

func serialize() -> Dictionary:
	return {
		"day_index": day_index,
		"minute": minute,
		"season": String(season),
		"year": year
	}

func deserialize(data: Dictionary) -> void:
	day_index = maxi(0, int(data.get("day_index", 0)))
	minute = clampi(int(data.get("minute", MORNING_MINUTE)), MORNING_MINUTE, DAY_END_MINUTE)
	season = StringName(data.get("season", "spring"))
	year = maxi(1, int(data.get("year", 1)))
	_real_seconds_accumulator = 0.0
	time_changed.emit(day_index, minute)
