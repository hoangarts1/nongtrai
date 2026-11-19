## LifeDirectorPresenter - selected plans are not a claim that effects actually ran.
class_name LifeDirectorPresenter
extends RefCounted

const KEYS: PackedStringArray = ["DIR_NEWS_TITLE", "DIR_READ_WAIT", "DIR_READ_OFF", "DIR_READ_PARTIAL", "DIR_READ_EMPTY", "DIR_READ_ACTIVE", "DIR_READ_PENDING", "DIR_READ_PERIOD", "DIR_READ_SELECTED", "DIR_READ_HISTORY", "DIR_READ_HISTORY_NOTE", "DIR_READ_NONE", "DIR_READ_WATER", "DIR_READ_NORMAL", "DIR_READ_DUST", "DIR_READ_RAIN", "DIR_READ_CANOPY", "DIR_READ_UNMEASURED", "DIR_READ_REFILL", "DIR_READ_RECORD", "DIR_READ_DETAIL"]

static func text(key: StringName) -> String:
	return TranslationServer.translate(key)

static func status(model: Dictionary) -> String:
	if not model.get("ok", false):
		return text(&"DIR_READ_WAIT")
	if not model.enabled:
		return text(&"DIR_READ_OFF")
	return text(&"DIR_READ_PARTIAL") if not model.ready else text(&"DIR_READ_EMPTY")

static func event_text(event: Dictionary, phase: StringName) -> String:
	return text(&"DIR_READ_DETAIL") % [text(phase), text(StringName(event.title_key)), text(&"DIR_READ_PERIOD") % [int(event.start_day) + 1, int(event.end_day)], text(StringName(event.explanation_key)), text(StringName(event.counter_hint_key))]

static func water_text(model: Dictionary) -> String:
	if not model.get("ok", false):
		return text(&"DIR_READ_WAIT")
	var key: StringName = &"DIR_READ_NORMAL"
	match String(model.dust_reason):
		"extra_charge": key = &"DIR_READ_DUST"
		"rain": key = &"DIR_READ_RAIN"
		"canopy": key = &"DIR_READ_CANOPY"
		"canopy_unmeasured": key = &"DIR_READ_UNMEASURED"
	return text(&"DIR_READ_WATER") % int(model.charge_cost) + " · " + text(key) + "
" + text(&"DIR_READ_REFILL")

static func describe(model: Dictionary) -> Dictionary:
	var lines: PackedStringArray = []
	var brief: PackedStringArray = []
	var history: PackedStringArray = []
	if model.get("ok", false):
		for event: Dictionary in model.pending:
			lines.append(event_text(event, &"DIR_READ_PENDING"))
			brief.append(text(&"DIR_READ_PENDING") + ": " + text(StringName(event.title_key)) + " · " + text(&"DIR_READ_PERIOD") % [int(event.start_day) + 1, int(event.end_day)])
		for event: Dictionary in model.active:
			var phase: StringName = &"DIR_READ_ACTIVE" if model.enabled else &"DIR_READ_SELECTED"
			lines.append(event_text(event, phase))
			brief.append(text(phase) + ": " + text(StringName(event.title_key)))
		for index: int in range(model.history.size() - 1, -1, -1):
			var record: Dictionary = model.history[index]
			var line: String = text(&"DIR_READ_RECORD") % [int(record.day_index) + 1, LifeDirectorDebugPresenter.event_name(record.event_id), LifeDirectorDebugPresenter.reason(record.reason)]
			if not record.event.is_empty():
				line += "
" + event_text(record.event, &"DIR_READ_SELECTED")
			history.append(line)
	var summary: String = "
".join(brief) if not brief.is_empty() else status(model)
	var details: String = "

".join(lines) if not lines.is_empty() else status(model)
	return {"heading": text(&"DIR_NEWS_TITLE"), "summary": summary, "details": details, "water": water_text(model), "history_title": text(&"DIR_READ_HISTORY"), "history_note": text(&"DIR_READ_HISTORY_NOTE"), "history": "

".join(history) if not history.is_empty() else text(&"DIR_READ_NONE")}
