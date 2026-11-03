## LifeQuestList — scrollable native selections with stable reused rows.
class_name LifeQuestList
extends ScrollContainer

signal selected(key: String)
var rows: VBoxContainer
var empty: Label

func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	custom_minimum_size.y = 120
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var content: VBoxContainer = LifeHudParts.column(self)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty = LifeTitleParts.label(content,&"BOOK_EMPTY")
	rows = LifeHudParts.column(content)

func display(values: Array[Dictionary], key: String) -> void:
	empty.text = tr("BOOK_EMPTY")
	empty.visible = values.is_empty()
	while rows.get_child_count()>values.size():
		var child: Node = rows.get_child(rows.get_child_count()-1)
		rows.remove_child(child)
		child.queue_free()
	for index: int in range(values.size()):
		var row: LifeQuestRow
		if index<rows.get_child_count():
			row = rows.get_child(index) as LifeQuestRow
		else:
			row = preload("res://ui/quests/quest_row.tscn").instantiate() as LifeQuestRow
			rows.add_child(row)
			row.pressed.connect(_requested.bind(row))
		row.display(values[index],String(values[index].key)==key)

func _requested(row: LifeQuestRow) -> void:
	selected.emit(row.key)
