## LifeProfileNameFields — paired native name edits retain transient text.
class_name LifeProfileNameFields
extends HBoxContainer

signal changed()
var player_name: LineEdit
var farm_name: LineEdit
var _player_label: Label
var _farm_label: Label

func _ready() -> void:
	var player: VBoxContainer = LifeHudParts.column(self)
	player.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_player_label = LifeTitleParts.label(player,&"TITLE_PLAYER_NAME",&"LifeText16")
	player_name = _entry(player,&"UI_DEFAULT_PLAYER")
	var farm: VBoxContainer = LifeHudParts.column(self)
	farm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_farm_label = LifeTitleParts.label(farm,&"TITLE_FARM_NAME",&"LifeText16")
	farm_name = _entry(farm,&"UI_DEFAULT_FARM")

func _entry(parent: Node, placeholder: StringName) -> LineEdit:
	var result: LineEdit = LineEdit.new()
	result.placeholder_text = tr(String(placeholder))
	result.custom_minimum_size = Vector2(80,44)
	result.text_changed.connect(func(_text: String) -> void: changed.emit())
	parent.add_child(result)
	return result

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and farm_name != null:
		_player_label.text = tr("TITLE_PLAYER_NAME")
		_farm_label.text = tr("TITLE_FARM_NAME")
		player_name.placeholder_text = tr("UI_DEFAULT_PLAYER")
		farm_name.placeholder_text = tr("UI_DEFAULT_FARM")
