## FarmingArtCatalog -- C2 visual-only recipes and stable generated farming asset paths.
## API:
##   func get_crop_scene_path(crop_id: StringName, stage_id: StringName) -> String
##   func get_tool_scene_path(tool_id: StringName) -> String
##   func validate() -> PackedStringArray
class_name FarmingArtCatalog
extends Resource

const MODEL_DIRECTORY: String = "res://assets/generated/models/farming"

@export var catalog_id: StringName = &"chibi_farming"
@export var crop_ids: PackedStringArray = PackedStringArray()
@export var crop_families: Dictionary = {}
@export var stage_scales: PackedFloat32Array = PackedFloat32Array()
@export var tool_ids: PackedStringArray = PackedStringArray()
@export var grass_color: Color = Color("9fbd7f")
@export var tilled_color: Color = Color("8d5d3d")
@export var wet_soil_color: Color = Color("604336")
@export var furrow_color: Color = Color("b37b50")
@export var dew_color: Color = Color("bdeaf1")
@export var sparkle_color: Color = Color("fff0a6")
@export var hoe_effect_color: Color = Color("d8a673")
@export var seed_effect_color: Color = Color("efc77a")
@export var water_effect_color: Color = Color("83c6e0")
@export var harvest_effect_color: Color = Color("ffe1a0")

func get_crop_scene_path(crop_id: StringName, stage_id: StringName) -> String:
	if not crop_ids.has(String(crop_id)):
		return ""
	var suffix: String = "withered" if stage_id == &"withered" else "stage_%d" % clampi(int(stage_id), 0, 3)
	return "%s/crop_%s_%s.tscn" % [MODEL_DIRECTORY, String(crop_id), suffix]

func get_crop_family(crop_id: StringName) -> StringName:
	return StringName(crop_families.get(String(crop_id), "root"))

func get_stage_scale(stage_id: int) -> float:
	if stage_scales.is_empty():
		return 1.0
	return stage_scales[clampi(stage_id, 0, stage_scales.size() - 1)]

func get_tool_scene_path(tool_id: StringName) -> String:
	if not tool_ids.has(String(tool_id)):
		return ""
	return "%s/tool_%s.tscn" % [MODEL_DIRECTORY, String(tool_id)]

func get_tool_icon_path(tool_id: StringName) -> String:
	if not tool_ids.has(String(tool_id)):
		return ""
	return "res://assets/generated/icons/tool_%s.png" % String(tool_id)

func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if catalog_id.is_empty():
		errors.append("farming art catalog id is empty")
	if crop_ids.size() != 9:
		errors.append("farming art catalog must list nine crop ids")
	var seen_crops: Dictionary = {}
	for crop_id: String in crop_ids:
		if crop_id.is_empty() or seen_crops.has(crop_id):
			errors.append("farming art catalog has invalid or duplicate crop id: %s" % crop_id)
		seen_crops[crop_id] = true
		if not crop_families.has(crop_id) or String(crop_families[crop_id]).is_empty():
			errors.append("farming art catalog has no family for crop id: %s" % crop_id)
	if stage_scales.size() != 4:
		errors.append("farming art catalog must list four stage scales")
	for scale_value: float in stage_scales:
		if scale_value <= 0.0 or scale_value > 1.0:
			errors.append("farming art catalog has invalid stage scale: %s" % scale_value)
	if tool_ids.size() != 4:
		errors.append("farming art catalog must list four tool ids")
	var seen_tools: Dictionary = {}
	for tool_id: String in tool_ids:
		if tool_id.is_empty() or seen_tools.has(tool_id):
			errors.append("farming art catalog has invalid or duplicate tool id: %s" % tool_id)
		seen_tools[tool_id] = true
	return errors
