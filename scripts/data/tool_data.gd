## ToolData — data-only definition for a farm tool.
class_name ToolData
extends Resource

@export var tool_id: StringName = &""
@export var action_id: StringName = &""
@export_range(1, 99) var reach_cells: int = 1
@export var item_id: StringName = &""
