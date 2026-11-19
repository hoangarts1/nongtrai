## LifeDirectorDebugSnapshot - actual current evaluation and stored history, no draw.
class_name LifeDirectorDebugSnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	var owner: Dictionary = main.director_state.serialize()
	var coverage: Dictionary = main.director_activity.get_window_snapshot()
	var observation: Dictionary = main.director_runtime.capture_observation()
	var evaluated: Dictionary = DirectorCandidateRules.evaluate(LifeDirectorRuntime.PROFILE, observation, main.director_state.get_context()) if observation.get("ok", false) else {"ok": false}
	var candidates: Array[Dictionary] = []
	for event: DirectorEventData in LifeDirectorRuntime.PROFILE.events:
		var row: Dictionary = {"id": String(event.id), "title_key": String(event.title_key), "explanation_key": String(event.explanation_key), "counter_hint_key": String(event.counter_hint_key), "eligible": false, "reason": String(observation.get("reason", &"invalid_snapshot")), "score": null, "base_weight": null, "activity_bonus": null}
		if evaluated.ok:
			for actual: Dictionary in evaluated.candidates:
				if actual.id == String(event.id):
					row.merge(actual.duplicate(true), true)
		candidates.append(row)
	var busy: bool = bool(main.call("_purchase_in_progress"))
	var authorized: bool = main.director_runtime.authorization_allowed()
	var ready: bool = bool(evaluated.get("ready", false))
	return {"ok": true, "day_index": GameClock.day_index, "enabled": bool(owner.enabled), "authorized": authorized, "busy": busy, "ready": ready, "reason": String(evaluated.get("reason", observation.get("reason", &"invalid_snapshot"))), "coverage": coverage.duplicate(true), "metrics": observation.get("metrics", {}).duplicate(true), "available": observation.get("available", {}).duplicate(true), "candidates": candidates, "history": owner.history.duplicate(true), "pending": owner.pending.duplicate(true), "active": owner.active.duplicate(true), "forced": String(owner.forced), "can_control": authorized and bool(main.get("_game_started")) and not main.start_menu.visible and not busy and not GameClock.is_sleeping() and not GameClock.is_day_end_held()}
