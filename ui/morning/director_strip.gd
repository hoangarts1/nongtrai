## LifeMorningDirectorStrip - compact selected-event notice with full counter tooltip.
class_name LifeMorningDirectorStrip
extends PanelContainer

var heading: Label
var summary: Label

func _ready() -> void:
	LifeTheme.bind(self, &"LifeKeyHint")
	mouse_filter = Control.MOUSE_FILTER_PASS
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	heading = LifeTitleParts.label(row, &"", &"LifeText16")
	heading.autowrap_mode = TextServer.AUTOWRAP_OFF
	heading.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	summary = LifeTitleParts.label(row, &"", &"LifeText16")
	for label: Label in [heading, summary]:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func display(snapshot: Dictionary) -> void:
	var model: Dictionary = LifeDirectorPresenter.describe(snapshot)
	heading.text = model.heading
	summary.text = model.summary
	tooltip_text = model.details + "
" + model.water
