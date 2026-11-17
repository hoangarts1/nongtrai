## CropData — data-only definition for a plantable crop.
class_name CropData
extends Resource

@export var crop_id: StringName = &""
@export var display_name_key: StringName = &""
@export var seed_item: StringName = &""
@export var product_item: StringName = &""
@export_range(1, 999) var yield_qty: int = 1
@export_range(1, 999) var growth_days: int = 1
@export_range(0, 999) var regrow_days: int = 0
@export_range(0, 999) var water_need: int = 1
@export_range(0, 999) var max_consecutive_dry_days: int = 0
@export var seasons: PackedStringArray = PackedStringArray()
@export var color: Color = Color.WHITE
@export var stage_textures: Array[Texture2D] = []
@export var wilted_textures: Array[Texture2D] = []
@export var pivot: Vector2 = Vector2.ZERO
@export var perennial: bool = false
@export var planting_item: StringName = &"seed"
@export_range(0, 9999) var planting_item_buy_price: int = 0
@export_range(0, 9999) var produce_sell_price: int = 0
