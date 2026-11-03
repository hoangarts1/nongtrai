## LifeTitleProfileForm — reference02 form facade; all changes are transient UI.
class_name LifeTitleProfileForm
extends VBoxContainer

signal submitted()
signal cancelled()
var player_name: LineEdit
var farm_name: LineEdit
var hair_style: LifeProfileChoiceRow
var skin_tone: LifeProfileChoiceRow
var hair_color: LifeProfileChoiceRow
var outfit_color: LifeProfileChoiceRow
var confirm_button: Button
var back_button: Button
var names: LifeProfileNameFields
var choices: LifeProfileChoices
var preview: LifeProfileAvatarPreview
var fields_scroll: ScrollContainer
var presenter: LifeProfilePresenter = LifeProfilePresenter.new()
var _title: Label
var _submitted: bool = false

func _ready() -> void:
	var inset: MarginContainer = MarginContainer.new()
	inset.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side: String in ["left","top","right","bottom"]:
		inset.add_theme_constant_override("margin_"+side,4)
	add_child(inset)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inset.add_child(columns)
	var left: LifeHudFrame = LifeProfileParts.frame(columns)
	left.size_flags_stretch_ratio = 0.55
	var column: VBoxContainer = LifePauseParts.paper(left)
	_title = LifeProfileParts.banner(column)
	var scroll: ScrollContainer = ScrollContainer.new()
	fields_scroll = scroll
	scroll.follow_focus = true
	scroll.name = "FieldsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var fields: VBoxContainer = LifeHudParts.column(scroll)
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names = preload("res://ui/profile/name_fields.tscn").instantiate() as LifeProfileNameFields
	fields.add_child(names)
	player_name = names.player_name
	farm_name = names.farm_name
	choices = preload("res://ui/profile/profile_choices.tscn").instantiate() as LifeProfileChoices
	fields.add_child(choices)
	hair_style = choices.hair_style
	skin_tone = choices.skin_tone
	hair_color = choices.hair_color
	outfit_color = choices.outfit_color
	var actions: HBoxContainer = HBoxContainer.new()
	column.add_child(actions)
	back_button = LifeTitleParts.button(actions,&"UI_BACK")
	back_button.name = "BackToTitle"
	back_button.custom_minimum_size.y = 52
	back_button.pressed.connect(func() -> void: cancelled.emit())
	confirm_button = LifeTitleParts.button(actions,&"PROFILE_START",&"LifePrimary")
	confirm_button.name = "ConfirmNewGame"
	confirm_button.custom_minimum_size.y = 52
	confirm_button.pressed.connect(func() -> void: submitted.emit())
	preview = preload("res://ui/profile/avatar_preview.tscn").instantiate() as LifeProfileAvatarPreview
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.size_flags_stretch_ratio = 0.45
	columns.add_child(preview)
	presenter.configure(self)

func get_selection() -> Dictionary:
	return choices.get_selection()

func begin_submission() -> bool:
	if _submitted:
		return false
	_submitted = true
	confirm_button.disabled = true
	return true

func reset_submission() -> void:
	_submitted = false
	confirm_button.disabled = false
	presenter.refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and confirm_button != null:
		_title.text = tr("PROFILE_TITLE")
		confirm_button.text = tr("PROFILE_START")
		back_button.text = tr("UI_BACK")
