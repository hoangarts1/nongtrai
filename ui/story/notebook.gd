## Lazy journal branch, presentation only; each list has its own scroll.
class_name LifeStoryNotebook
extends VBoxContainer
signal back_requested()
signal page_requested(page_id: StringName)
var page_title: Label
var page_links: Array[LifeStoryPageLink] = []
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
	page_title = LifePauseParts.label(objectives.column,&"STORY_PAGES",&"LifeText18")
	for _page: StoryPageData in LifeStorySnapshot.CONFIG.pages:
		var link: LifeStoryPageLink = preload("res://ui/story/page_link.tscn").instantiate() as LifeStoryPageLink
		objectives.column.add_child(link)
		link.page_requested.connect(_request_page)
		page_links.append(link)
	milestones = preload("res://ui/story/milestone_list.tscn").instantiate() as LifeStoryMilestoneList
	columns.add_child(milestones)
	back_button = LifePauseParts.button(self,&"STORY_BACK")
	back_button.pressed.connect(func() -> void: back_requested.emit())
func display(model: Dictionary) -> void:
	header.display(model)
	objectives.visible = bool(model.get("ok",false))
	milestones.visible = objectives.visible
	if objectives.visible:
		page_title.text = tr("STORY_PAGES")
		for index: int in range(page_links.size()): page_links[index].display(model.pages[index])
		objectives.display(model.objectives)
		milestones.display(model.milestones)
	back_button.text = tr("STORY_BACK")

func _request_page(id: StringName) -> void:
	page_requested.emit(id)
