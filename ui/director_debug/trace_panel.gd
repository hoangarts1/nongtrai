## LifeDirectorTracePanel - saved records only; no recomputed past decisions.
class_name LifeDirectorTracePanel
extends VBoxContainer

var title_label: Label
var body_label: Label

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label = LifePauseParts.label(self, &"", &"LifeText20")
	body_label = LifePauseParts.label(self, &"")
	body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func display(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
