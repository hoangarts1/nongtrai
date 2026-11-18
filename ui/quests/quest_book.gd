## LifeQuestBook — reference08 two-page presentation under existing NpcJournal.
class_name LifeQuestBook
extends VBoxContainer

var tabs: LifeInventoryTabs
var filters: LifeQuestFilters
var list: LifeQuestList
var people: Label
var detail: LifeQuestDetail
var hint: Label
var navigation: HBoxContainer
var paper: VBoxContainer
var body: HBoxContainer
var ecology_button: Button
var ecology_sheet: LifeEcologySheet

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	navigation = HBoxContainer.new()
	add_child(navigation)
	ecology_button = LifeTitleParts.button(navigation, &"ECO_ENTRY", &"LifeSecondary")
	ecology_button.custom_minimum_size = Vector2(118, 42)
	ecology_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	tabs = preload("res://ui/inventory/common_tabs.tscn").instantiate() as LifeInventoryTabs
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation.add_child(tabs)
	tabs.set_active(2)
	var frame: LifeHudFrame = LifeHudFrame.new()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(frame)
	paper = LifePauseParts.paper(frame)
	body = HBoxContainer.new()
	body.theme_type_variation = &"LifeInvColumns"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paper.add_child(body)
	var left: VBoxContainer = LifeHudParts.column(body)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filters = preload("res://ui/quests/filter_bar.tscn").instantiate() as LifeQuestFilters
	left.add_child(filters)
	list = preload("res://ui/quests/quest_list.tscn").instantiate() as LifeQuestList
	left.add_child(list)
	people = LifeTitleParts.label(left,&"",&"LifeText16")
	detail = preload("res://ui/quests/quest_detail.tscn").instantiate() as LifeQuestDetail
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.size_flags_stretch_ratio = 1.3
	body.add_child(detail)
	var plate: PanelContainer = PanelContainer.new()
	plate.theme_type_variation = &"LifeKeyHint"
	add_child(plate)
	hint = LifeTitleParts.label(plate,&"BOOK_KEYS",&"LifeText16")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
