## LifeDirectorHistory - lazy journal child inside existing ecology scroll.
class_name LifeDirectorHistory
extends VBoxContainer

var heading: Label
var current: Label
var water: Label
var note: Label
var records: Label

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	theme_type_variation = &"LifeInvColumn"
	heading = LifePauseParts.label(self, &"", &"LifeHeading")
	current = LifePauseParts.label(self, &"")
	water = LifePauseParts.label(self, &"")
	note = LifePauseParts.label(self, &"", &"LifeSecondaryText")
	records = LifePauseParts.label(self, &"")

func display(snapshot: Dictionary) -> void:
	var model: Dictionary = LifeDirectorPresenter.describe(snapshot)
	heading.text = model.history_title
	current.text = model.details
	water.text = model.water
	note.text = model.history_note
	records.text = model.history
