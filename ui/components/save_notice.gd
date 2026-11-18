## LifeSaveNotice — localized read-only source/error notice, never performs I/O.
class_name LifeSaveNotice
extends PanelContainer

var label: Label
var presentation_enabled: bool = true
var _report: Dictionary = {}

func _ready() -> void:
	theme_type_variation = &"LifeCompactPanel"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin: MarginContainer = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8 if side in ["left", "right"] else 4)
	add_child(margin)
	label = LifePauseParts.label(margin, &"", &"LifeText16")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	display(_report)

static func message(report: Dictionary, include_primary: bool = false) -> String:
	var status: Variant = report.get("status", &"")
	if status == &"primary":
		return TranslationServer.translate(&"SAVE_NOTICE_PRIMARY") if include_primary else ""
	if status == &"recovered":
		var index: Variant = report.get("source_index")
		if (index is int or index is float) and is_finite(float(index)) and float(index) == floorf(float(index)) and index >= 1 and index <= SaveService.MAX_BACKUPS:
			return TranslationServer.translate(&"SAVE_NOTICE_RECOVERED") % int(index)
		return TranslationServer.translate(&"SAVE_NOTICE_INVALID")
	if report.get("error") == &"unsupported_future":
		return TranslationServer.translate(&"SAVE_NOTICE_FUTURE")
	return TranslationServer.translate(&"SAVE_NOTICE_INVALID") if status == &"error" else ""

func display(report: Dictionary) -> void:
	_report = report.duplicate(true)
	if label == null:
		return
	label.text = message(_report, true)
	visible = presentation_enabled and not label.text.is_empty()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and label != null:
		display(_report)
