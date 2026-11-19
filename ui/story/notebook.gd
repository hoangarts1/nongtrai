## Lazy journal branch, presentation only; each list has its own scroll.
class_name LifeStoryNotebook
extends VBoxContainer
signal back_requested()
var header: LifeStoryChapterHeader
var objectives: LifeStoryObjectiveList
var milestones: LifeStoryMilestoneList
var back_button: Button
func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	header = preload("res://ui/story/chapter_header.tscn").instantiate() as LifeStoryChapterHeader
	add_child(header)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.theme_type_variation = &"LifeInvColumns"
	add_child(columns)
	objectives = preload("res://ui/story/objective_list.tscn").instantiate() as LifeStoryObjectiveList
	columns.add_child(objectives)
	milestones = preload("res://ui/story/milestone_list.tscn").instantiate() as LifeStoryMilestoneList
	columns.add_child(milestones)
	back_button = LifePauseParts.button(self,&"STORY_BACK")
	back_button.pressed.connect(func() -> void: back_requested.emit())
func display(model: Dictionary) -> void:
	header.display(model)
	objectives.visible = bool(model.get("ok",false))
	milestones.visible = objectives.visible
	if objectives.visible:
		objectives.display(model.objectives)
		milestones.display(model.milestones)
	back_button.text = tr("STORY_BACK")
