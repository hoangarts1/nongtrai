## LifeDayLedgerView — bounded scrolling list, totals and truthful history note.
class_name LifeDayLedgerView
extends VBoxContainer

var list: VBoxContainer
var scroll: ScrollContainer
var income: Label
var expense: Label
var profit: Label
var note: Label
var heading: Label
var _captions: Dictionary = {}

func _ready() -> void:
	LifeTheme.bind(self,&"LifeDayColumn")
	heading = LifeDayEndParts.heading(self,&"END_LEDGER")
	_captions[heading] = &"END_LEDGER"
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.y = 120
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	list = LifeHudParts.column(scroll)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	income = _total(&"END_INCOME",&"LifeDayIncome")
	expense = _total(&"END_EXPENSE",&"LifeDayExpense")
	profit = _total(&"END_PROFIT",&"LifeDayTotal")
	note = LifeDayEndParts.wrapped(self,&"LifeSmall")

func _total(key: StringName, variation: StringName) -> Label:
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	var label: Label = LifeHudParts.label(row)
	label.text = tr(String(key))
	_captions[label] = key
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return LifeHudParts.label(row,variation)

func display(rows: Array[Dictionary], totals: Dictionary, complete: bool) -> void:
	for child: Node in list.get_children():
		list.remove_child(child)
		child.free()
	for entry: Dictionary in rows:
		var row: LifeDayLedgerRow = preload("res://ui/day_end/ledger_row.tscn").instantiate() as LifeDayLedgerRow
		list.add_child(row)
		row.display(entry["title"],entry["quantity"],entry["amount"],entry["icon"])
	if rows.is_empty():
		LifeDayEndParts.wrapped(list,&"LifeSecondaryText").text = tr("END_NO_TRANSACTIONS")
	income.text = LifeDayEndParts.money(int(totals["income"]),true)
	expense.text = LifeDayEndParts.money(-int(totals["expense"]),true)
	profit.text = LifeDayEndParts.money(int(totals["profit"]),true)
	note.text = tr("END_HISTORY_COMPLETE" if complete else "END_HISTORY_INCOMPLETE")

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		for label: Label in _captions:
			label.text = tr(String(_captions[label]))
