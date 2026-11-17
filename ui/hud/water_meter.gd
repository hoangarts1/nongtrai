## LifeHudWaterMeter — read-only actual water amount, styled alongside the tool caption.
class_name LifeHudWaterMeter
extends PanelContainer

var amount: Label
var _charges: int = 0
var _capacity: int = 0

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudCaption")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: HBoxContainer = HBoxContainer.new()
	row.name = "Row"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	var icon: TextureRect = LifeHudParts.texture(row,UiIcons.get_icon(&"watering_can"),24)
	icon.name = "Icon"
	amount = LifeHudParts.label(row,&"LifeHudCaptionText")
	amount.name = "Amount"
	_refresh()

func display(charges: int, capacity: int) -> void:
	_charges = charges
	_capacity = capacity
	_refresh()

func _notification(what: int) -> void:
	if what==NOTIFICATION_TRANSLATION_CHANGED:
		_refresh()

func _refresh() -> void:
	if is_instance_valid(amount):
		amount.text = tr("WATER_CAN_COUNT") % [_charges,_capacity]
		tooltip_text = tr("WATER_CAN_EMPTY" if _charges<=0 else "UI_TOOL_WATER")
