## LifeQuestDetail — actual task terms/goals, fixed unsupported actions.
class_name LifeQuestDetail
extends VBoxContainer

var scroll: ScrollContainer
var title: Label
var giver: Label
var description: Label
var status: Label
var visit: Label
var portrait: LifeCharacterPortrait
var objectives: VBoxContainer
var rewards: LifeQuestReward
var pin_button: Button
var map_button: Button
var _goals_heading: Label
var _rewards_heading: Label

func _ready() -> void:
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	var body: VBoxContainer = LifeHudParts.column(scroll)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var header: HBoxContainer = HBoxContainer.new()
	body.add_child(header)
	var captions: VBoxContainer = LifeHudParts.column(header)
	captions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title = LifeTitleParts.label(captions,&"BOOK_SELECT",&"LifeDayTitle")
	giver = LifeTitleParts.label(captions,&"",&"LifeText16")
	status = LifeTitleParts.label(captions,&"",&"LifeDayHeading")
	portrait = preload("res://ui/character/avatar_portrait.tscn").instantiate() as LifeCharacterPortrait
	header.add_child(portrait)
	description = LifeTitleParts.label(body,&"")
	_goals_heading = LifeTitleParts.label(body,&"BOOK_OBJECTIVES",&"LifeDayHeading")
	objectives = LifeHudParts.column(body)
	_rewards_heading = LifeTitleParts.label(body,&"BOOK_REWARDS",&"LifeDayHeading")
	rewards = preload("res://ui/quests/reward_card.tscn").instantiate() as LifeQuestReward
	body.add_child(rewards)
	visit = LifeTitleParts.label(body,&"",&"LifeText16")
	var actions: HBoxContainer = HBoxContainer.new()
	add_child(actions)
	pin_button = LifeTitleParts.button(actions,&"BOOK_PIN")
	map_button = LifeTitleParts.button(actions,&"BOOK_MAP")
	pin_button.disabled = true
	map_button.disabled = true

func display(row: Dictionary, main: Node) -> void:
	var populated: bool = not row.is_empty()
	title.text = tr(String(row.title_key)) if populated else tr("BOOK_SELECT")
	portrait.hide()
	giver.text = ""
	giver.visible = populated and not bool(row.tutorial)
	status.visible = populated
	description.visible = populated
	status.text = tr("BOOK_STATUS_"+String(row.status).to_upper()) if populated else ""
	description.text = tr(String(row.description_key)) if populated else ""
	visit.text = ""
	if populated and not bool(row.tutorial):
		var npc: NpcData = main.npc_system.state.get_npc(StringName(row.giver_id))
		giver.text = tr("BOOK_UNKNOWN_GIVER")
		if npc != null:
			giver.text = tr("BOOK_GIVER") % tr(String(npc.display_name_key))
			portrait.show()
			portrait.display_npc(npc.npc_id,npc.color)
			visit.text = tr("BOOK_VISIT") % tr(String(npc.display_name_key))
	_goals_heading.text = tr("BOOK_OBJECTIVES")
	visit.visible = not visit.text.is_empty()
	_rewards_heading.text = tr("BOOK_REWARDS")
	_goals_heading.visible = populated
	_rewards_heading.visible = populated
	rewards.visible = populated
	var goals: Array = row.get("objectives",[])
	while objectives.get_child_count()>goals.size():
		var child: Node = objectives.get_child(objectives.get_child_count()-1)
		objectives.remove_child(child)
		child.queue_free()
	for index: int in range(goals.size()):
		var goal: LifeQuestObjective
		if index<objectives.get_child_count():
			goal = objectives.get_child(index) as LifeQuestObjective
		else:
			goal = preload("res://ui/quests/objective_row.tscn").instantiate() as LifeQuestObjective
			objectives.add_child(goal)
		goal.display(goals[index])
	rewards.display(row)
	pin_button.text = tr("BOOK_PIN")
	map_button.text = tr("BOOK_MAP")
	pin_button.tooltip_text = tr("INV_UNAVAILABLE")
	map_button.tooltip_text = tr("INV_UNAVAILABLE")
