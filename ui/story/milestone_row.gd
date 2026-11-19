class_name LifeStoryMilestoneRow
extends VBoxContainer
var title: Label
var status: Label
var description: Label
func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title = LifePauseParts.label(self,&"",&"LifeText18")
	status = LifePauseParts.label(self,&"",&"LifeSecondaryText")
	description = LifePauseParts.label(self,&"",&"LifeText16")
	add_child(HSeparator.new())
func display(row: Dictionary) -> void:
	title.text = String(row.title)
	status.text = String(row.status)
	description.text = String(row.description)
