## LifeEcologySheet — scrollable actual ecology readout inside the existing journal.
class_name LifeEcologySheet
extends VBoxContainer

signal back_requested()
var title: Label
var scope: Label
var waiting: Label
var scroll: ScrollContainer
var rows_column: VBoxContainer
var metric_rows: Array[LifeEcologyMetricRow] = []
var back_button: Button

func _ready() -> void:
	LifeTheme.bind(self, &"LifeInvColumn")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	title = LifePauseParts.label(self, &"ECO_TITLE", &"LifeHeading")
	scope = LifePauseParts.label(self, &"ECO_SCOPE", &"LifeSecondaryText")
	waiting = LifePauseParts.label(self, &"ECO_WAITING", &"LifeText18")
	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.focus_mode = Control.FOCUS_ALL
	scroll.follow_focus = true
	add_child(scroll)
	rows_column = LifeHudParts.column(scroll)
	rows_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button = LifePauseParts.button(self, &"ECO_BACK")
	back_button.pressed.connect(func() -> void: back_requested.emit())

func display(model: Dictionary) -> void:
	var ready: bool = bool(model.get("ok", false))
	title.text = String(model.get("title", tr("ECO_TITLE")))
	scope.text = String(model.get("scope", tr("ECO_SCOPE")))
	back_button.text = String(model.get("back", tr("ECO_BACK")))
	waiting.visible = not ready
	scroll.visible = ready
	if not ready:
		waiting.text = String(model.get("message", tr("ECO_WAITING")))
		return
	while metric_rows.size() < model.rows.size():
		var row: LifeEcologyMetricRow = preload("res://ui/ecology/metric_row.tscn").instantiate() as LifeEcologyMetricRow
		rows_column.add_child(row)
		metric_rows.append(row)
	for index: int in range(metric_rows.size()):
		metric_rows[index].visible = index < model.rows.size()
		if index < model.rows.size():
			metric_rows[index].display(model.rows[index])
