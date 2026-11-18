## LifeEcologySourceSummary — localized source/hint lines from a detached readout.
class_name LifeEcologySourceSummary
extends VBoxContainer

var labels: Dictionary = {}

func _ready() -> void:
	LifeTheme.bind(self, &"LifeInvColumn")
	for field: String in ["target_text", "source_text", "ease_text", "threshold_text", "status_text", "hint"]:
		var label: Label = LifePauseParts.label(self, &"", &"LifeText16")
		labels[field] = label

func display(row: Dictionary) -> void:
	for field: String in labels:
		var label: Label = labels[field] as Label
		label.text = String(row.get(field, ""))
		label.visible = not label.text.is_empty()
