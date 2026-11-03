## LifeCharacterSkill — unavailable category label, never fictional progress.
class_name LifeCharacterSkill
extends PanelContainer

var title: Label
var status: Label

func _ready() -> void:
	theme_type_variation = &"LifeKeyHint"
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	title = LifeTitleParts.label(row,&"",&"LifeText18")
	status = LifeTitleParts.label(row,&"INV_UNAVAILABLE",&"LifeText16")
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func display(key: StringName) -> void:
	title.text = tr(String(key))
	status.text = tr("INV_UNAVAILABLE")
