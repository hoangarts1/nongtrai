## LifeDogNameForm - native input and actions, no owner or truncation.
class_name LifeDogNameForm
extends VBoxContainer
var title: Label
var field: LineEdit
var error: Label
var save: Button
var cancel: Button
func _ready() -> void:
	title = LifeTitleParts.label(self, &"DOG_NAME_TITLE", &"LifeDayTitle")
	field = LineEdit.new()
	field.custom_minimum_size.y = 48
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(field)
	error = LifeTitleParts.label(self, &"", &"LifeText16")
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	save = LifeTitleParts.button(row, &"DOG_NAME_SAVE", &"LifePrimary")
	cancel = LifeTitleParts.button(row, &"DOG_NAME_CANCEL")
