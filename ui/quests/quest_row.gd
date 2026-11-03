## LifeQuestRow — native selection Button, no gameplay callback.
class_name LifeQuestRow
extends Button

var key: String = ""

func _ready() -> void:
	custom_minimum_size.y = 82
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	clip_text = true

func display(row: Dictionary, selected: bool) -> void:
	key = String(row.key)
	var status: String = tr("BOOK_STATUS_"+String(row.status).to_upper())
	var progress: String = tr("BOOK_COUNT") % [int(row.progress),int(row.target)]
	text = tr(String(row.title_key))+"\n"+status+(" · "+progress if row.status!=&"completed" else "")
	tooltip_text = text
	theme_type_variation = &"LifeInvAction" if selected else &"LifeSecondary"
