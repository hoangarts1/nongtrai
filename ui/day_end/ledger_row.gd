## LifeDayLedgerRow — item/reason, optional quantity and signed amount.
class_name LifeDayLedgerRow
extends HBoxContainer

func display(title: String, quantity: int, amount: int, texture: Texture2D) -> void:
	LifeTheme.bind(self,&"LifeDayRow")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	LifeHudParts.texture(self,texture,32)
	var name_label: Label = LifeDayEndParts.wrapped(self)
	name_label.text = title
	if quantity > 0:
		var count: Label = LifeHudParts.label(self,&"LifeSmall")
		count.text = tr("END_QUANTITY") % quantity
		count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var cash: Label = LifeHudParts.label(self,&"LifeDayIncome" if amount >= 0 else &"LifeDayExpense")
	cash.text = LifeDayEndParts.money(amount,true)
	cash.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cash.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cash.custom_minimum_size.x = 95
	custom_minimum_size.y = 42
