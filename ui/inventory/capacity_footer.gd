## LifeInventoryFooter — capacity, empty-filter feedback and contextual controls.
class_name LifeInventoryFooter
extends VBoxContainer

signal sort_requested()
signal upgrade_requested()
signal watering_upgrade_requested()
var capacity: Label
var bar: ProgressBar
var sort_button: Button
var hints: Label
var upgrade_button: Button
var watering_upgrade_button: Button

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudShortcutColumn")
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
	upgrade_button = Button.new()
	upgrade_button.theme_type_variation = &"LifeInvFilter"
	upgrade_button.pressed.connect(func() -> void: upgrade_requested.emit())
	row.add_child(upgrade_button)
	upgrade_button.hide()
	var actions: HBoxContainer = HBoxContainer.new()
	actions.theme_type_variation = &"LifeInvRow"
	add_child(actions)
	hints = LifeDayEndParts.wrapped(actions,&"LifeInvNote")
	hints.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	watering_upgrade_button = Button.new()
	watering_upgrade_button.theme_type_variation = &"LifeInvFilter"
	watering_upgrade_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	watering_upgrade_button.pressed.connect(func() -> void: watering_upgrade_requested.emit())
	actions.add_child(watering_upgrade_button)
	watering_upgrade_button.hide()

func display(used: int, maximum: int, empty_filter: bool) -> void:
	capacity.text = tr("INV_CAPACITY") % [used,maximum]
	bar.max_value = maximum
	bar.value = used
	sort_button.text = tr("INV_SORT")
	upgrade_button.text = tr("BAG_UP_ACTION")
	watering_upgrade_button.text = tr("WATER_UP_ACTION")
	hints.text = tr("INV_NO_MATCHES") if empty_filter else tr("INV_KEY_HINTS")
