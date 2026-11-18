## LifeEcologyMetricRow — read-only metric bar and explanations; water stays nonnumeric.
class_name LifeEcologyMetricRow
extends VBoxContainer

var title: Label
var value: Label
var bar: LifeProgressBar
var summary: LifeEcologySourceSummary

func _ready() -> void:
	LifeTheme.bind(self, &"LifeInvColumn")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title = LifePauseParts.label(self, &"", &"LifeHeading")
	value = LifePauseParts.label(self, &"", &"LifeText18")
	bar = preload("res://ui/components/progress_bar_styled.tscn").instantiate() as LifeProgressBar
	bar.custom_minimum_size.y = 14
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.step = 0.0
	add_child(bar)
	summary = preload("res://ui/ecology/source_summary.tscn").instantiate() as LifeEcologySourceSummary
	add_child(summary)

func display(row: Dictionary) -> void:
	title.text = String(row.get("label", ""))
	value.text = String(row.get("value_text", ""))
	bar.visible = bool(row.get("available", false))
	if bar.visible:
		bar.min_value = float(row.minimum)
		bar.max_value = float(row.maximum)
		bar.value = float(row.value)
	summary.display(row)
