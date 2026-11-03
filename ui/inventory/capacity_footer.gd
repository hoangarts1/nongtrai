## LifeInventoryFooter — capacity, empty-filter feedback and contextual controls.
class_name LifeInventoryFooter
extends VBoxContainer

signal sort_requested()
var capacity: Label
var bar: ProgressBar
var sort_button: Button
var hints: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	var row: HBoxContainer = HBoxContainer.new()
	row.theme_type_variation = &"LifeInvRow"
	add_child(row)
	capacity = LifeHudParts.label(row,&"LifeInvNote")
	bar = ProgressBar.new()
	bar.theme_type_variation = &"LifeProgressGold"
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size.y = 16
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)
	sort_button = Button.new()
	sort_button.theme_type_variation = &"LifeInvFilter"
	sort_button.pressed.connect(func() -> void: sort_requested.emit())
	row.add_child(sort_button)
	hints = LifeDayEndParts.wrapped(self,&"LifeInvNote")

func display(used: int, maximum: int, empty_filter: bool) -> void:
	capacity.text = tr("INV_CAPACITY") % [used,maximum]
	bar.max_value = maximum
	bar.value = used
	sort_button.text = tr("INV_SORT")
	hints.text = tr("INV_NO_MATCHES") if empty_filter else tr("INV_KEY_HINTS")
