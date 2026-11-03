## LifeInventorySlot — native item button; index/quantity are display values only.
class_name LifeInventorySlot
extends Button

var inventory_index: int = -1
var quantity: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvSlot")
	custom_minimum_size = Vector2(64,64)
	expand_icon = true
	quantity = LifeHudParts.label(self,&"LifeQuantity")
	quantity.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	quantity.offset_right = -4
	quantity.offset_bottom = -3

func display(index: int, texture: Texture2D, count: int, title: String, selected: bool) -> void:
	inventory_index = index
	icon = texture
	quantity.text = str(count) if index >= 0 else ""
	tooltip_text = title
	disabled = index < 0
	theme_type_variation = &"LifeInvSlotSelected" if selected else &"LifeInvSlot"
