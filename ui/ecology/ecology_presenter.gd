## EcologyPresenter — localized detached display data, never an action or simulation.
## API: static describe(snapshot,config=CONFIG)->Dictionary; text(config,field)->String.
class_name EcologyPresenter
extends RefCounted

const CONFIG: EcologyJournalConfig = preload("res://data/ecology_journal_config.tres")

static func text(config: EcologyJournalConfig, field: String) -> String:
	return TranslationServer.translate(StringName(config.texts[field]))

static func describe(snapshot: Dictionary, config: EcologyJournalConfig = CONFIG) -> Dictionary:
	if config == null or not config.validation_errors(LifeEcologyRuntime.PROFILE).is_empty():
		return {"ok": false, "reason": &"invalid_config"}
	if not EcologySnapshot.valid(snapshot):
		return {"ok": false, "title": text(config, "title"), "message": text(config, "waiting")}
	var rows: Array[Dictionary] = []
	for definition: Dictionary in config.rows:
		var id: String = String(definition.id)
		var available: bool = snapshot.sample.available[id]
		var row: Dictionary = {"id": id, "available": available,
			"label": TranslationServer.translate(StringName(definition.label_key)),
			"hint": TranslationServer.translate(StringName(definition.hint_key))}
		if not available:
			row["value_text"] = text(config, "unmeasured")
			rows.append(row)
			continue
		var metric: EcologyMetricData = LifeEcologyRuntime.PROFILE.get_metric(StringName(id))
		row["value"] = float(snapshot.state.metrics[id])
		row["maximum"] = metric.maximum
		row["minimum"] = metric.minimum
		row["value_text"] = text(config, "current") % [row.value, metric.maximum]
		row["target_text"] = text(config, "target") % [float(snapshot.sample.targets[id]), metric.maximum]
		row["source_text"] = TranslationServer.translate(StringName(definition.count_text_key)) % [int(snapshot.sample.counts[definition.count_key]), int(snapshot.goals[definition.count_key])]
		row["ease_text"] = text(config, "ease") % metric.ease_percent
		for threshold: Dictionary in LifeEcologyRuntime.PROFILE.get_thresholds():
			if threshold.id == definition.threshold_id:
				row["active"] = float(row.value) >= float(threshold.value)
				row["threshold_text"] = text(config, "next") % [TranslationServer.translate(StringName(definition.threshold_key)), float(threshold.value)]
				row["status_text"] = text(config, "active" if row.active else "below")
		rows.append(row)
	return {"ok": true, "title": text(config, "title"), "scope": text(config, "scope"), "back": text(config, "back"), "rows": rows,
		"news_title": text(config, "news_title"), "news_summary": text(config, "news_summary") % [float(snapshot.state.metrics.tree_cover), float(snapshot.state.metrics.biodiversity)]}
