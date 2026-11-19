## LifeDirectorSnapshot - committed plans/history and actual current counter, no commands.
class_name LifeDirectorSnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	if main == null or main.director_runtime == null or main.director_runtime.is_busy() or bool(main.call("_purchase_in_progress")) or not bool(main.get("_game_started")) or main.start_menu.visible:
		return {"ok": false}
	var owner: Dictionary = main.director_state.serialize()
	var observation: Dictionary = main.director_runtime.capture_observation()
	if not observation.get("ok", false) or int(owner.day_index) != GameClock.day_index:
		return {"ok": false}
	var projection: Dictionary = DirectorEffectProjector.project(LifeDirectorRuntime.PROFILE, owner, observation)
	if not projection.ok:
		return {"ok": false}
	var charges: Dictionary = DirectorEffectTermsCodec.water(preload("res://data/watering_can_config.tres"), projection.water)
	if not charges.ok:
		return {"ok": false}
	return {"ok": true, "day_index": GameClock.day_index, "enabled": bool(projection.enabled), "ready": bool(observation.ready), "reason": String(observation.reason), "pending": owner.pending.duplicate(true), "active": owner.active.duplicate(true), "history": owner.history.duplicate(true), "charge_cost": int(charges.charge_cost), "dust_reason": String(projection.dust_reason)}
