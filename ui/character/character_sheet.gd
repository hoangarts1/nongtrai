## LifeCharacterSheet — reference07 composition, presentation only.
class_name LifeCharacterSheet
extends VBoxContainer

var companion: LifeDogCompanionCard
var tabs: LifeInventoryTabs
var identity: LifeCharacterIdentity
var skills: LifeCharacterSkills
var relationships: LifeCharacterRelationships
var hint: Label

func _ready() -> void:
	hide()
	LifeTheme.bind(self,&"LifeInvColumn")
	mouse_filter = Control.MOUSE_FILTER_STOP
	tabs = preload("res://ui/inventory/common_tabs.tscn").instantiate() as LifeInventoryTabs
	add_child(tabs)
	tabs.set_active(1)
	var frame: LifeHudFrame = LifeHudFrame.new()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(frame)
	var paper: VBoxContainer = LifePauseParts.paper(frame)
	var body: HBoxContainer = HBoxContainer.new()
	body.theme_type_variation = &"LifeInvColumns"
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paper.add_child(body)
	identity = preload("res://ui/character/identity_card.tscn").instantiate() as LifeCharacterIdentity
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.x = 240
	body.add_child(scroll)
	var left: VBoxContainer = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(left)
	left.add_child(identity)
	companion = preload("res://ui/pet/dog_companion_card.tscn").instantiate() as LifeDogCompanionCard
	left.add_child(companion)
	var right: VBoxContainer = LifeHudParts.column(body)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 2.3
	skills = preload("res://ui/character/skills_panel.tscn").instantiate() as LifeCharacterSkills
	right.add_child(skills)
	relationships = preload("res://ui/character/relationship_list.tscn").instantiate() as LifeCharacterRelationships
	right.add_child(relationships)
	var hint_plate: PanelContainer = PanelContainer.new()
	hint_plate.theme_type_variation = &"LifeKeyHint"
	add_child(hint_plate)
	hint = LifeTitleParts.label(hint_plate,&"CHAR_KEYS",&"LifeText16")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
