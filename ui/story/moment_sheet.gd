class_name LifeStoryMomentSheet
extends PanelContainer
var body: LifeStoryMomentBody
var actions: LifeStoryMomentActions
var error: Label
func _ready() -> void:
	hide()
	LifeTheme.bind(self,&"LifeHudPaper")
	var column: VBoxContainer = LifeHudParts.column(self)
	body = preload("res://ui/story/moment_body.tscn").instantiate() as LifeStoryMomentBody
	column.add_child(body)
	error = LifePauseParts.label(column,&"",&"LifeText16")
	actions = preload("res://ui/story/moment_actions.tscn").instantiate() as LifeStoryMomentActions
	column.add_child(actions)
func display(model: Dictionary, failed: bool = false) -> void:
	body.display(model)
	actions.refresh()
	error.text = tr("STORY_STALE") if failed else ""
	error.visible = failed
	actions.confirm.disabled = failed
