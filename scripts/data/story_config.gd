## StoryConfig - DATA catalogue; returns detached full Resource graphs on freeze.
class_name StoryConfig
extends Resource
@export var chapter_id: StringName = &""
@export var title_key: StringName = &""
@export var description_key: StringName = &""
@export var objectives: Array[StoryObjectiveData] = []
@export var milestones: Array[StoryObjectiveData] = []
@export var pages: Array[StoryPageData] = []
@export var delivery: QuestData
@export var land: LandExpansionConfig
@export var clearing: ClearingConfig
@export var neighbor_introductions: Dictionary[StringName, StringName] = {}
func get_objective(id: StringName) -> StoryObjectiveData:
	for row: StoryObjectiveData in objectives:
		if row != null and row.objective_id==id: return row
	return null
func get_page(id: StringName) -> StoryPageData:
	for row: StoryPageData in pages:
		if row != null and row.page_id==id: return row
	return null
func supported_ids() -> PackedStringArray:
	var result: PackedStringArray = []
	for row: StoryObjectiveData in objectives:
		if row != null and not row.planned: result.append(String(row.objective_id))
	return result
func translation_keys() -> PackedStringArray:
	var result: PackedStringArray = [String(title_key),String(description_key)]
	for row: StoryObjectiveData in objectives+milestones:
		if row != null: result.append_array(PackedStringArray([String(row.title_key),String(row.description_key)]))
	for page: StoryPageData in pages:
		if page != null: result.append_array(PackedStringArray([String(page.title_key),String(page.body_key)]))
	return result
func frozen_copy() -> StoryConfig:
	return _copy_data(self,{}) as StoryConfig
static func _copy_data(value: Variant, copies: Dictionary) -> Variant:
	if value is Resource and not value is Script:
		var source: Resource = value as Resource
		var identity: int = source.get_instance_id()
		if copies.has(identity): return copies[identity]
		var copy: Resource = source.duplicate(false)
		copies[identity] = copy
		for property: Dictionary in source.get_property_list():
			var key: String = String(property.name)
			if (int(property.usage)&PROPERTY_USAGE_STORAGE)!=0 and key not in ["script","resource_path"]: copy.set(key,_copy_data(source.get(key),copies))
		return copy
	if value is Array:
		var copy: Array = value.duplicate()
		for index: int in range(copy.size()): copy[index] = _copy_data(value[index],copies)
		return copy
	if value is Dictionary:
		var copy: Dictionary = value.duplicate()
		for key: Variant in copy: copy[key] = _copy_data(value[key],copies)
		return copy
	if value is PackedByteArray or value is PackedInt32Array or value is PackedInt64Array or value is PackedFloat32Array or value is PackedFloat64Array or value is PackedStringArray or value is PackedVector2Array or value is PackedVector3Array or value is PackedColorArray or value is PackedVector4Array:
		return value.duplicate()
	return value
