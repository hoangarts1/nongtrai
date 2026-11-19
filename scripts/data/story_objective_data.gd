## StoryObjectiveData - localized objective/source definition; no progress owner.
class_name StoryObjectiveData
extends Resource
@export var objective_id: StringName = &""
@export var title_key: StringName = &""
@export var description_key: StringName = &""
@export var source: StringName = &"planned"
@export var source_id: StringName = &""
@export var tutorial_step: int = -1
@export var target: int = 0
@export var planned: bool = true
@export var requires: PackedStringArray = []
