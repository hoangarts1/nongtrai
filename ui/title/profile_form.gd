## LifeTitleProfileForm — original data-backed profile fields, no world state.
class_name LifeTitleProfileForm
extends VBoxContainer

signal submitted()
signal cancelled()
const CATALOG: Resource = preload("res://data/art/characters/chibi_character_catalog.tres")
var player_name: LineEdit
var farm_name: LineEdit
var appearance_grid: GridContainer
var hair_style: OptionButton
var skin_tone: OptionButton
var hair_color: OptionButton
var outfit_color: OptionButton
var confirm_button: Button
var back_button: Button
var _player_label: Label
var _farm_label: Label
var _captions: Array[Label] = []
const KEYS: Array[StringName] = [&"UI_APPEARANCE_HAIR_STYLE",&"UI_APPEARANCE_SKIN_TONE",&"UI_APPEARANCE_HAIR_COLOR",&"UI_APPEARANCE_OUTFIT_COLOR"]

func _ready() -> void:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "FieldsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	var fields: VBoxContainer = LifeHudParts.column(scroll)
	fields.name = "Fields"
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_player_label = LifeTitleParts.label(fields,&"TITLE_PLAYER_NAME")
	player_name = _entry(fields,&"UI_DEFAULT_PLAYER")
	_farm_label = LifeTitleParts.label(fields,&"TITLE_FARM_NAME")
	farm_name = _entry(fields,&"UI_DEFAULT_FARM")
	appearance_grid = GridContainer.new()
	appearance_grid.name = "AppearanceGrid"
	appearance_grid.columns = 2
	fields.add_child(appearance_grid)
	var options: Dictionary = LifeTitleParts.dictionary(CATALOG.call("get_player_customization"))
	hair_style = _option("HairStyle",KEYS[0])
	var styles: PackedStringArray = options.get("hair_styles",PackedStringArray())
	for style: String in styles:
		hair_style.add_item(tr("UI_APPEARANCE_HAIR_%s" % style.to_upper()))
		hair_style.set_item_metadata(hair_style.item_count-1,style)
	skin_tone = _option("SkinTone",KEYS[1])
	hair_color = _option("HairColor",KEYS[2])
	outfit_color = _option("OutfitColor",KEYS[3])
	var controls: Array[OptionButton] = [skin_tone,hair_color,outfit_color]
	var roles: Array[StringName] = [&"skin_tones",&"hair_colors",&"outfit_colors"]
	for index: int in range(controls.size()):
		var choices: Array = options.get(roles[index],[])
		for number: int in range(choices.size()):
			controls[index].add_item(tr("UI_APPEARANCE_OPTION_NUMBER") % [tr(String(KEYS[index+1])),number+1])
	confirm_button = LifeTitleParts.button(self,&"UI_CONFIRM",&"LifePrimary")
	confirm_button.name = "ConfirmNewGame"
	confirm_button.pressed.connect(func() -> void: submitted.emit())
	back_button = LifeTitleParts.button(self,&"UI_BACK")
	back_button.name = "BackToTitle"
	back_button.pressed.connect(func() -> void: cancelled.emit())

func _entry(parent: Node, placeholder: StringName) -> LineEdit:
	var result: LineEdit = LineEdit.new()
	result.placeholder_text = tr(String(placeholder))
	result.custom_minimum_size.y = 40
	parent.add_child(result)
	return result

func _option(option_name: String, key: StringName) -> OptionButton:
	var label: Label = LifeTitleParts.label(appearance_grid,key,&"LifeText16")
	label.custom_minimum_size.x = 100
	_captions.append(label)
	var result: OptionButton = OptionButton.new()
	result.name = option_name
	result.custom_minimum_size.y = 40
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	appearance_grid.add_child(result)
	return result

func get_selection() -> Dictionary:
	return LifeTitleParts.dictionary(CATALOG.call("normalize_player_customization",{
		"hair_style":hair_style.get_item_metadata(hair_style.selected),
		"skin_index":skin_tone.selected,"hair_color_index":hair_color.selected,
		"outfit_color_index":outfit_color.selected
	}))

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and back_button != null:
		_player_label.text = tr("TITLE_PLAYER_NAME")
		_farm_label.text = tr("TITLE_FARM_NAME")
		player_name.placeholder_text = tr("UI_DEFAULT_PLAYER")
		farm_name.placeholder_text = tr("UI_DEFAULT_FARM")
		confirm_button.text = tr("UI_CONFIRM")
		back_button.text = tr("UI_BACK")
		var controls: Array[OptionButton] = [hair_style,skin_tone,hair_color,outfit_color]
		for index: int in range(controls.size()):
			_captions[index].text = tr(String(KEYS[index]))
			for item: int in range(controls[index].item_count):
				var text: String = tr("UI_APPEARANCE_HAIR_%s" % String(hair_style.get_item_metadata(item)).to_upper()) if index == 0 else tr("UI_APPEARANCE_OPTION_NUMBER") % [tr(String(KEYS[index])),item+1]
				controls[index].set_item_text(item,text)
