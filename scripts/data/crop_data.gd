## CropData — data-only definition for a plantable crop.
class_name CropData
extends Resource

@export var crop_id: StringName = &""
@export var display_name_key: StringName = &""
@export var seed_item: StringName = &""
@export var product_item: StringName = &""
@export var yield_qty: int = 1
@export_range(1, 999) var growth_days: int = 1
@export_range(0, 999) var water_need: int = 1
@export var seasons: PackedStringArray = PackedStringArray()
