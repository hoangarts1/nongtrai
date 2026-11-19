## LifeDirectorRuntime - composition/lifecycle/read adapter; domain owns all progress.
class_name LifeDirectorRuntime
extends Node

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const ACTIVITY: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
var busy: bool = false
var debug_preview_allowed: bool = true
var last_reason: StringName = &""
var _main: Node
var _pending: Dictionary = {}
var _cache: Dictionary = {}
var _dirty: bool = true

func configure(main: Node) -> void:
	_main = main
	name = "DirectorRuntime"
	main.director_activity.configure(ACTIVITY, GameClock.day_index)
	main.director_state.configure(PROFILE, GameClock.day_index)
	main.director_activity_collector = LifeDirectorActivityCollector.new()
	main.director_activity_collector.name = "DirectorActivityCollector"
	main.add_child(main.director_activity_collector)
	main.director_activity_collector.configure(main)
	main.director_daily_flow = LifeDirectorDailyFlow.new()
	main.director_daily_flow.name = "DirectorDailyFlow"
	main.add_child(main.director_daily_flow)
	main.director_daily_flow.configure(main)
	main.director_water_bridge = LifeDirectorWaterBridge.new()
	main.director_water_bridge.name = "DirectorWaterBridge"
	main.add_child(main.director_water_bridge)
	main.director_water_bridge.configure(main)
	main.director_npc_bridge = LifeDirectorNpcBridge.new()
	main.director_npc_bridge.name = "DirectorNpcBridge"
	main.add_child(main.director_npc_bridge)
	main.director_npc_bridge.configure(main)
	main.director_effects_flow = LifeDirectorEffectsFlow.new()
	main.director_effects_flow.name = "DirectorEffectsFlow"
	main.add_child(main.director_effects_flow)
	main.director_effects_flow.configure(main)
	main.director_activity.activity_changed.connect(invalidate)
	main.director_state.director_changed.connect(invalidate)
	main.director_activity.activity_changed.connect(main._mark_save_dirty)
	main.director_state.director_changed.connect(main._mark_save_dirty)
	main.ecology_state.ecology_changed.connect(invalidate)
	main.farm_state.plot_changed.connect(invalidate)
	main.weather_state.weather_changed.connect(invalidate)
	main.tool_controller.configure_director(main.director_activity_collector)
	main.seed_shop_panel.configure_director(main.director_activity_collector)
	main.shipping_bin_panel.configure_director(main.director_activity_collector)

func is_busy() -> bool:
	return busy or (is_instance_valid(_main) and (_main.director_activity.is_busy() or _main.director_state.is_busy() or _main.director_activity_collector.busy or _main.director_daily_flow.busy))

func authorization_allowed() -> bool:
	# M2.4 has no implemented story flag. A saved preview flag never grants one.
	return OS.is_debug_build() and debug_preview_allowed

func invalidate(_value: Variant = null) -> void:
	_dirty = true

func capture_observation(internal: bool = false) -> Dictionary:
	if not is_instance_valid(_main) or not bool(_main.get("_game_started")) or _main.start_menu.visible:
		return {"ok": false, "reason": &"not_playing"}
	var sample: Dictionary = EcologySampler.sample(LifeEcologyRuntime.SAMPLING, _main.farm_state.serialize(), DataRegistry.get_all_crops(), _main.land_ownership.get_owned_regions(), _main.ecology_state.get_metrics())
	if not sample.ok:
		return {"ok": false, "reason": &"invalid_garden"}
	return DirectorSnapshot.capture(PROFILE, GameClock.serialize(), {"state": _main.ecology_state.serialize(), "available": sample.available}, _main.director_activity.serialize(), _main.weather_state.serialize(), {"enabled": _main.director_state.is_enabled(), "story_unlocked": false, "debug_preview": authorization_allowed(), "busy": not internal and bool(_main.call("_purchase_in_progress"))})

static func neutral(day: int) -> Dictionary:
	return {"ok": true, "day_index": day, "enabled": false, "water": {"day_index": day, "event": {}}, "visitor": {}, "accent": [], "event_ids": [], "dust_reason": "inactive"}

func get_projection(force: bool = false) -> Dictionary:
	if not is_instance_valid(_main) or is_busy() or not bool(_main.get("_game_started")) or _main.start_menu.visible or not _main.director_state.is_enabled() or not authorization_allowed():
		return neutral(GameClock.day_index)
	if not force and not _dirty and int(_cache.get("day_index", -1)) == GameClock.day_index:
		return _cache.duplicate(true)
	var observation: Dictionary = capture_observation()
	var result: Dictionary = DirectorEffectProjector.project(PROFILE, _main.director_state.serialize(), observation) if observation.get("ok", false) else observation
	if not result.get("ok", false):
		last_reason = StringName(result.get("reason", &"effect_unavailable"))
		return neutral(GameClock.day_index)
	_cache = result.duplicate(true)
	_dirty = false
	return result

func prepare_restore(payload: Dictionary, new_game: bool = false) -> Dictionary:
	var context: Dictionary = DirectorSaveContext.capture(PROFILE, payload, DataRegistry.get_all_crops())
	if not context.ok:
		return context
	var meta: Variant = payload.get("meta", {})
	var version: Variant = meta.get("save_version", 0) if meta is Dictionary else 0
	var legacy: bool = not DirectorActivityCodec.valid_integer(version) or int(version) < SaveService.DIRECTOR_INTRODUCED_VERSION
	var pair: Dictionary = DirectorSaveCodec.normalize(PROFILE, ACTIVITY, payload.get("director_activity"), payload.get("director"), context, legacy or new_game)
	if not pair.ok:
		return pair
	if new_game:
		pair.director_activity.current_complete = true
	return {"ok": true, "context": context, "pair": pair}

func begin_restore(prepared: Dictionary) -> bool:
	if is_busy() or not prepared.get("ok", false):
		return false
	_pending = prepared.duplicate(true)
	busy = true
	return true

func finish_restore() -> bool:
	if not busy or _pending.is_empty() or int(_pending.context.day_index) != GameClock.day_index:
		return false
	var pair: Dictionary = _pending.pair
	var result: Dictionary = DirectorLifecycle.restore(_main.director_activity, _main.director_state, PROFILE, ACTIVITY, pair.director_activity, pair.director, _pending.context)
	last_reason = StringName(pair.reason)
	_pending = {}
	busy = false
	invalidate()
	return result.ok

func refresh_effects() -> void:
	invalidate()
	_main.director_effects_flow.refresh()

func _can_control() -> bool:
	return is_instance_valid(_main) and bool(_main.get("_game_started")) and not _main.start_menu.visible and not GameClock.is_sleeping() and not GameClock.is_day_end_held() and not bool(_main.call("_purchase_in_progress"))

func set_enabled(value: bool) -> bool:
	if not _can_control() or (value and not authorization_allowed()) or not _main.director_state.set_enabled(value, authorization_allowed()):
		return false
	refresh_effects()
	return true

func queue_force(id: StringName) -> bool:
	return _can_control() and authorization_allowed() and _main.director_state.queue_force(id, true)
