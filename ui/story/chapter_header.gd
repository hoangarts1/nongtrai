class_name LifeStoryChapterHeader
extends VBoxContainer
var title: Label
var description: Label
var progress: Label
func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	title = LifePauseParts.label(self,&"",&"LifeHeading")
	description = LifePauseParts.label(self,&"",&"LifeSecondaryText")
	progress = LifePauseParts.label(self,&"",&"LifeText18")
func display(model: Dictionary) -> void:
	title.text = String(model.get("title",tr("STORY_ENTRY")))
	description.text = String(model.get("description",tr("STORY_WAITING")))
	progress.text = String(model.get("progress",""))
