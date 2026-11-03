## LifeInventoryDiscard — explicit integer quantity confirmation; never removes items.
class_name LifeInventoryDiscard
extends VBoxContainer

signal confirmed(quantity: int)
signal cancelled()
var title: Label
var amount: SpinBox
var confirm_button: Button
var cancel_button: Button

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	title = LifeDayEndParts.wrapped(self,&"LifeDayHeading")
	amount = SpinBox.new()
	amount.min_value = 1
	amount.step = 1
	amount.rounded = true
	add_child(amount)
	confirm_button = Button.new()
	confirm_button.theme_type_variation = &"LifeDanger"
	confirm_button.custom_minimum_size.y = 44
	confirm_button.pressed.connect(func() -> void:
		amount.apply()
		confirmed.emit(int(amount.value))
	)
	add_child(confirm_button)
	cancel_button = Button.new()
	cancel_button.theme_type_variation = &"LifeSecondary"
	cancel_button.custom_minimum_size.y = 44
	cancel_button.pressed.connect(func() -> void: cancelled.emit())
	add_child(cancel_button)
	hide()

func display(item_name: String, quantity: int) -> void:
	title.text = tr("INV_DISCARD_CONFIRM") % item_name
	confirm_button.text = tr("INV_DISCARD")
	cancel_button.text = tr("INV_CANCEL")
	amount.max_value = quantity
	amount.value = 1
	show()
