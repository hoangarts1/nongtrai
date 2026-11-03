## LifeHudToolbarSlot — native input, icon/key/quantity presentation only.
class_name LifeHudToolbarSlot
extends Button

var key_label: Label
var quantity_label: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudSlot")
	custom_minimum_size = Vector2(58,62)
	expand_icon = true
	key_label = LifeHudParts.label(self,&"LifeHudNote")
	key_label.position = Vector2(6,2)
	quantity_label = LifeHudParts.label(self,&"LifeQuantity")
	quantity_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	quantity_label.offset_right = -5
	quantity_label.offset_bottom = -3

func display(key: String, texture: Texture2D, quantity: int, selected: bool, title: String) -> void:
	key_label.text = key
	icon = texture
	quantity_label.text = str(quantity) if quantity > 0 else ""
	tooltip_text = title
	theme_type_variation = &"LifeHudSlotSelected" if selected else &"LifeHudSlot"
