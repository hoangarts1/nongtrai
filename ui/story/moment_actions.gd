class_name LifeStoryMomentActions
extends HBoxContainer
var confirm: Button
var cancel: Button
func _ready() -> void:
	theme_type_variation = &"LifeInvRow"
	confirm = LifePauseParts.button(self,&"STORY_CONFIRM",&"LifePrimary")
	cancel = LifePauseParts.button(self,&"STORY_CANCEL")
func refresh() -> void:
	confirm.text = tr("STORY_CONFIRM")
	cancel.text = tr("STORY_CANCEL")
