## DialogueData — localized, conditional dialogue and optional quest action.
class_name DialogueData
extends Resource

@export var dialogue_id: StringName = &""
@export var npc_id: StringName = &""
@export var text_key: StringName = &""
@export var quest_id: StringName = &""
@export_enum("any", "new", "active", "completed") var quest_condition: String = "any"
@export var seasons: PackedStringArray = PackedStringArray()
@export var start_quest: bool = false
