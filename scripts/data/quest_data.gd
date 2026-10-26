## QuestData — data-only definition of a quest with requirements and rewards.
class_name QuestData
extends Resource

@export var quest_id: StringName = &""
@export var title_key: StringName = &""
@export var description_key: StringName = &""
@export var giver_id: StringName = &""
@export var required_item_id: StringName = &""
@export_range(0, 999) var required_item_quantity: int = 0
@export var reward_coins: int = 0
@export var reward_item_id: StringName = &""
@export_range(0, 999) var reward_item_quantity: int = 0
