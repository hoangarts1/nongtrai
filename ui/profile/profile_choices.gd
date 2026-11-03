## LifeProfileChoices — existing catalogue choices, normalized only for display/request.
class_name LifeProfileChoices
extends VBoxContainer

signal changed(selection: Dictionary)
const CATALOG: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")
var hair_style: LifeProfileChoiceRow
var skin_tone: LifeProfileChoiceRow
var hair_color: LifeProfileChoiceRow
var outfit_color: LifeProfileChoiceRow

func _ready() -> void:
	var options: Dictionary = CATALOG.call("get_player_customization")
	hair_style = _row()
	hair_style.configure_styles(options.hair_styles)
	skin_tone = _row()
	skin_tone.configure_colors(options.skin_tones,&"UI_APPEARANCE_SKIN_TONE")
	hair_color = _row()
	hair_color.configure_colors(options.hair_colors,&"UI_APPEARANCE_HAIR_COLOR")
	outfit_color = _row()
	outfit_color.configure_colors(options.outfit_colors,&"UI_APPEARANCE_OUTFIT_COLOR")

func _row() -> LifeProfileChoiceRow:
	var result: LifeProfileChoiceRow = preload("res://ui/profile/choice_row.tscn").instantiate() as LifeProfileChoiceRow
	add_child(result)
	result.selected_changed.connect(_selected)
	return result

func _selected(_index: int) -> void:
	changed.emit(get_selection())

func get_selection() -> Dictionary:
	return CATALOG.call("normalize_player_customization",{
		"hair_style":hair_style.get_item_metadata(hair_style.selected),
		"skin_index":skin_tone.selected,"hair_color_index":hair_color.selected,
		"outfit_color_index":outfit_color.selected
	})
