## MerchantOfferData — isolated daily trade quote; never mutates ItemData prices.
class_name MerchantOfferData
extends Resource

@export var offer_id: StringName = &""
@export var item_id: StringName = &""
@export_enum("discount", "request") var kind: String = "discount"
@export var unit_price: int = 0
@export var quantity: int = 1
@export var seasons: PackedStringArray = PackedStringArray()
