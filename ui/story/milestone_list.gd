class_name LifeStoryMilestoneList
extends VBoxContainer
var title: Label
var scroll: ScrollContainer
var column: VBoxContainer
var rows: Array[LifeStoryMilestoneRow] = []
func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	title = LifePauseParts.label(self,&"STORY_MILESTONES",&"LifeText18")
	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.focus_mode = Control.FOCUS_ALL
	scroll.follow_focus = true
	add_child(scroll)
	column = LifeHudParts.column(scroll)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
func display(values: Array) -> void:
	title.text = tr("STORY_MILESTONES")
	while rows.size()<values.size():
		var row: LifeStoryMilestoneRow = preload("res://ui/story/milestone_row.tscn").instantiate() as LifeStoryMilestoneRow
		column.add_child(row)
		rows.append(row)
	for index: int in range(rows.size()):
		rows[index].visible = index<values.size()
		if index<values.size(): rows[index].display(values[index])
