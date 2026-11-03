## LifeCharacterRelationships — all actual villagers in a scrollable grid.
class_name LifeCharacterRelationships
extends VBoxContainer

var heading: Label
var empty: Label
var scroll: ScrollContainer
var cards: GridContainer

func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	heading = LifeTitleParts.label(self,&"CHAR_RELATIONSHIPS",&"LifeDayHeading")
	scroll = ScrollContainer.new()
	scroll.custom_minimum_size.y = 140
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var content: VBoxContainer = LifeHudParts.column(scroll)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty = LifeTitleParts.label(content,&"CHAR_NO_NPCS")
	cards = GridContainer.new()
	cards.columns = 2
	cards.theme_type_variation = &"LifeInvGrid"
	content.add_child(cards)

func display(rows: Array[Dictionary]) -> void:
	heading.text = tr("CHAR_RELATIONSHIPS")
	empty.text = tr("CHAR_NO_NPCS")
	empty.visible = rows.is_empty()
	# Reuse stable NPC cards across locale/owner refreshes, preserving scroll position.
	while cards.get_child_count()>rows.size():
		var child: Node = cards.get_child(cards.get_child_count()-1)
		cards.remove_child(child)
		child.queue_free()
	for index: int in range(rows.size()):
		var card: LifeCharacterRelationship
		if index<cards.get_child_count():
			card = cards.get_child(index) as LifeCharacterRelationship
		else:
			card = preload("res://ui/character/relationship_card.tscn").instantiate() as LifeCharacterRelationship
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cards.add_child(card)
		card.display(rows[index])
