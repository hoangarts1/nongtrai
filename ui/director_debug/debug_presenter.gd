## LifeDirectorDebugPresenter - localizes actual preview/saved records, never selects.
class_name LifeDirectorDebugPresenter
extends RefCounted

const KEYS: PackedStringArray = ["DIR_DEBUG_ENTRY", "DIR_DEBUG_TITLE", "DIR_DEBUG_ENABLE", "DIR_DEBUG_CLEAR", "DIR_DEBUG_COVERAGE", "DIR_DEBUG_METRICS", "DIR_DEBUG_PERCENT", "DIR_DEBUG_UNKNOWN", "DIR_DEBUG_MODE", "DIR_DEBUG_FORCE", "DIR_DEBUG_FORCE_HINT", "DIR_DEBUG_SCORE", "DIR_DEBUG_NOT_SCORED", "DIR_DEBUG_EVENT_INFO", "DIR_DEBUG_TRACE", "DIR_DEBUG_EMPTY", "DIR_DEBUG_RECORD", "DIR_DEBUG_RNG", "DIR_DEBUG_CANDIDATE", "DIR_DEBUG_ACTIVITY", "DIR_DEBUG_COUNT", "DIR_DEBUG_INTENT", "DIR_DEBUG_NONE", "DIR_DEBUG_ENABLED", "DIR_DEBUG_DISABLED", "DIR_DEBUG_QUEUED", "DIR_DEBUG_CLEARED", "DIR_DEBUG_BLOCKED", "DIR_DEBUG_HINT", "DIR_DEBUG_WAIT"]
const REASONS: Dictionary = {"eligible": "DIR_REASON_ELIGIBLE", "ready": "DIR_REASON_ELIGIBLE", "disabled": "DIR_REASON_DISABLED", "locked": "DIR_REASON_LOCKED", "observations_incomplete": "DIR_REASON_OBSERVATIONS", "rain_at_start": "DIR_REASON_RAIN", "threshold": "DIR_REASON_THRESHOLD", "regular_visit": "DIR_REASON_REGULAR", "cooldown": "DIR_REASON_COOLDOWN", "event_cap": "DIR_REASON_QUOTA", "negative_cap": "DIR_REASON_QUOTA", "grace": "DIR_REASON_GRACE", "negative_spacing": "DIR_REASON_SPACING", "conflict": "DIR_REASON_CONFLICT", "positive_pity": "DIR_REASON_POSITIVE", "pity_waiting_eligible": "DIR_REASON_WAIT", "no_eligible_event": "DIR_REASON_WAIT", "metric_unavailable": "DIR_REASON_UNKNOWN", "invalid_observations": "DIR_REASON_UNKNOWN", "invalid_snapshot": "DIR_REASON_UNKNOWN", "busy": "DIR_REASON_BUSY", "chosen": "DIR_REASON_CHOSEN", "forced": "DIR_REASON_FORCED", "forced_ineligible": "DIR_REASON_DECLINED", "no_event": "DIR_REASON_NONE", "zero_weight": "DIR_REASON_WAIT", "day_overflow": "DIR_REASON_UNKNOWN"}
const ACTIVITIES: Dictionary = {"plot_tilled": "DIR_ACTIVITY_TILL", "crop_planted": "DIR_ACTIVITY_PLANT", "plot_watered": "DIR_ACTIVITY_WATER", "crop_harvested": "DIR_ACTIVITY_HARVEST", "item_purchased": "DIR_ACTIVITY_BUY", "item_sold": "DIR_ACTIVITY_SELL"}

static func translation_keys() -> PackedStringArray:
	var keys: PackedStringArray = KEYS.duplicate()
	for key: String in REASONS.values() + ACTIVITIES.values():
		if not keys.has(key):
			keys.append(key)
	return keys

static func reason(value: String) -> String:
	return TranslationServer.translate(StringName(REASONS.get(value, "DIR_REASON_UNKNOWN")))

static func event_name(id: String) -> String:
	var event: DirectorEventData = LifeDirectorRuntime.PROFILE.get_event(StringName(id))
	return TranslationServer.translate(event.title_key) if event != null else TranslationServer.translate(&"DIR_DEBUG_NONE")

static func metric(model: Dictionary, id: String) -> String:
	return TranslationServer.translate(&"DIR_DEBUG_PERCENT") % float(model.metrics[id]) if bool(model.available.get(id, false)) and model.metrics.has(id) else TranslationServer.translate(&"DIR_DEBUG_UNKNOWN")

static func trace_text(model: Dictionary) -> String:
	var lines: PackedStringArray = []
	for id: String in LifeDirectorRuntime.ACTIVITY.activity_ids:
		var amount: String = str(int(model.coverage.totals[id])) if model.coverage.available else TranslationServer.translate(&"DIR_DEBUG_UNKNOWN")
		lines.append(TranslationServer.translate(&"DIR_DEBUG_COUNT") % [TranslationServer.translate(StringName(ACTIVITIES[id])), amount])
	var output: String = TranslationServer.translate(&"DIR_DEBUG_ACTIVITY") % " · ".join(lines)
	if model.history.is_empty():
		return output + "\n\n" + TranslationServer.translate(&"DIR_DEBUG_EMPTY")
	var last: Dictionary = model.history.back()
	var seed_text: String = str(int(last.seed_used)) if last.seed_used != null else TranslationServer.translate(&"DIR_DEBUG_UNKNOWN")
	var state_text: String = last.rng_state if not String(last.rng_state).is_empty() else TranslationServer.translate(&"DIR_DEBUG_UNKNOWN")
	output += "\n\n" + TranslationServer.translate(&"DIR_DEBUG_RNG") % [seed_text, state_text]
	for row: Dictionary in last.trace.get("candidates", []):
		output += "\n" + TranslationServer.translate(&"DIR_DEBUG_CANDIDATE") % [event_name(row.id), String.num(float(row.score), 2), reason(String(row.reason))]
	for index: int in range(model.history.size() - 1, -1, -1):
		var record: Dictionary = model.history[index]
		output += "\n" + TranslationServer.translate(&"DIR_DEBUG_RECORD") % [int(record.day_index) + 1, event_name(record.event_id), reason(record.reason)]
	return output

static func render(panel: LifeDirectorDebugSheet, model: Dictionary, result: StringName = &"") -> void:
	panel.banner.set_caption(&"DIR_DEBUG_TITLE")
	panel.close_button.text = TranslationServer.translate(&"UI_CLOSE")
	panel.enabled_button.text = TranslationServer.translate(&"DIR_DEBUG_ENABLE")
	panel.enabled_button.set_pressed_no_signal(bool(model.enabled))
	panel.enabled_button.disabled = not bool(model.can_control)
	panel.clear_button.text = TranslationServer.translate(&"DIR_DEBUG_CLEAR")
	panel.clear_button.disabled = not bool(model.can_control) or String(model.forced).is_empty()
	panel.coverage_label.text = TranslationServer.translate(&"DIR_DEBUG_COVERAGE") % [int(model.coverage.complete_days), int(model.coverage.window_days), int(model.day_index) + 1]
	panel.metrics_label.text = TranslationServer.translate(&"DIR_DEBUG_METRICS") % [metric(model, "tree_cover"), metric(model, "biodiversity"), metric(model, "water_clarity")]
	panel.notice_label.text = TranslationServer.translate(result) if not result.is_empty() else TranslationServer.translate(&"DIR_DEBUG_INTENT") % (event_name(model.forced) if not String(model.forced).is_empty() else TranslationServer.translate(&"DIR_DEBUG_NONE"))
	panel.hint_label.text = TranslationServer.translate(&"DIR_DEBUG_MODE") + "\n" + TranslationServer.translate(&"DIR_DEBUG_HINT")
	panel.ensure_rows(model.candidates.size())
	for index: int in range(model.candidates.size()):
		var row: Dictionary = model.candidates[index]
		var score: String = TranslationServer.translate(&"DIR_DEBUG_SCORE") % [float(row.score), float(row.base_weight), float(row.activity_bonus)] if model.ready else TranslationServer.translate(&"DIR_DEBUG_NOT_SCORED")
		panel.rows[index].display({"id": row.id, "title": TranslationServer.translate(StringName(row.title_key)), "reason": reason(String(row.reason)), "score": score, "hint": TranslationServer.translate(&"DIR_DEBUG_EVENT_INFO") % [TranslationServer.translate(StringName(row.explanation_key)), TranslationServer.translate(StringName(row.counter_hint_key))], "force_label": TranslationServer.translate(&"DIR_DEBUG_FORCE"), "force_hint": TranslationServer.translate(&"DIR_DEBUG_FORCE_HINT"), "can_force": model.can_control and model.ready and bool(row.eligible)})
	panel.trace_panel.display(TranslationServer.translate(&"DIR_DEBUG_TRACE"), trace_text(model))
