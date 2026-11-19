## DogReactionFlow - bounded cosmetic rain and proven harvest receipt feedback.
class_name DogReactionFlow
extends RefCounted
var remaining: float = 0.0
var reactions: int = 0
var _main: Node
var _runtime: LifeDogRuntime
var _rain_day: int = -1
var _was_rainy: bool = false
var _harvest_day: int = -1
var _harvest_count: int = 0
func configure(main: Node, runtime: LifeDogRuntime) -> void:
	_main = main
	_runtime = runtime
	main.director_activity.activity_changed.connect(_activity)
	reset()
func reset() -> void:
	remaining = 0.0
	_rain_day = GameClock.day_index
	_was_rainy = _main.weather_state.is_rainy()
	_harvest_day = GameClock.day_index
	_harvest_count = int(_main.director_activity.serialize().get("current_counts",{}).get("crop_harvested",0))
	_runtime.actor.avatar.set_happy(false)
func _presentable() -> bool:
	return bool(_main.get("_game_started")) and not _main.start_menu.visible and not GameClock.paused and not GameClock.is_sleeping() and not GameClock.is_day_end_held() and not _main.day_end_flow.is_advancing() and _main.ui_coordinator.get_active_panel()==null
func _activity(day: int) -> void:
	var count: int = int(_main.director_activity.serialize().get("current_counts",{}).get("crop_harvested",0))
	var previous: int = _harvest_count if day==_harvest_day else 0
	_harvest_day = day
	_harvest_count = count
	# Existing collector publishes after actual tool inventory receipt, unlike producer signals.
	if day==GameClock.day_index and count>previous and _main.director_activity_collector.busy and _presentable(): _happy()
func _happy() -> void:
	remaining = _runtime.CONFIG.reaction_seconds
	reactions += 1
	_runtime.actor.avatar.set_happy(true)
func advance(delta: float, playing: bool) -> void:
	if not playing or not is_finite(delta) or delta<=0.0: return
	var rainy: bool = _main.weather_state.is_rainy()
	if rainy and (not _was_rainy or _rain_day!=GameClock.day_index): _happy()
	_was_rainy = rainy
	_rain_day = GameClock.day_index
	remaining = maxf(0.0,remaining-delta)
	_runtime.actor.avatar.set_happy(remaining>0.0)
func dispose() -> void:
	if is_instance_valid(_main) and _main.director_activity.activity_changed.is_connected(_activity): _main.director_activity.activity_changed.disconnect(_activity)
