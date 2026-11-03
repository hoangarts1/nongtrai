## LifeMorningMarket — current shipping-bin prices from item data.
class_name LifeMorningMarket
extends VBoxContainer

var heading: Label
var note: Label
var scroll: ScrollContainer
var rows_box: VBoxContainer

func _ready() -> void:
	heading = LifeTitleParts.label(self,&"NEWS_PRICES",&"LifeDayHeading")
	note = LifeTitleParts.label(self,&"NEWS_PRICE_NOTE",&"LifeText16")
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	rows_box = LifeHudParts.column(scroll)
	rows_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func display(rows: Array[Dictionary]) -> void:
	heading.text = tr("NEWS_PRICES")
	note.text = tr("NEWS_PRICE_NOTE")
	for child: Node in rows_box.get_children():
		rows_box.remove_child(child)
		child.queue_free()
	for entry: Dictionary in rows:
		var row: LifeMorningPriceRow = preload("res://ui/morning/price_row.tscn").instantiate() as LifeMorningPriceRow
		rows_box.add_child(row)
		row.display(StringName(entry.id),StringName(entry.name_key),int(entry.price))
