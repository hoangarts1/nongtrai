## LifeQuestObjective — read-only flags/current possession, not delivery history.
class_name LifeQuestObjective
extends HBoxContainer

var text: Label

func _ready() -> void:
	text = LifeTitleParts.label(self,&"")

func display(row: Dictionary) -> void:
	var caption: String = tr(String(row.key))
	var item: Resource = DataRegistry.get_item(StringName(row.item_id))
	if item != null:
		caption = tr("BOOK_ITEM_PROGRESS") % [tr(String(item.get("display_name_key"))),int(row.have),int(row.target)]
	text.text = ("✓ " if bool(row.done) else "○ ")+caption
