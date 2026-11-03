## LifeMorningPriceRow — actual produce unit price, no trade action.
class_name LifeMorningPriceRow
extends HBoxContainer

var icon: TextureRect
var title: Label
var amount: Label

func _ready() -> void:
	icon = LifeHudParts.texture(self,null,30)
	title = LifeTitleParts.label(self,&"")
	amount = LifeHudParts.label(self,&"LifeDayHeading")
	amount.custom_minimum_size.x = 66
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	custom_minimum_size.y = 44
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func display(id: StringName, name_key: StringName, price: int) -> void:
	icon.texture = LifeInventoryIcon.for_item(id)
	title.text = tr(String(name_key))
	amount.text = tr("UI_WALLET_COINS") % price
