## LifeCharacterIdentity — actual profile and avatar, no invented level/XP.
class_name LifeCharacterIdentity
extends VBoxContainer

var portrait: LifeCharacterPortrait
var player_name: Label
var farm_name: Label
var note: Label

func _ready() -> void:
	portrait = preload("res://ui/character/avatar_portrait.tscn").instantiate() as LifeCharacterPortrait
	portrait.custom_minimum_size = Vector2(240,220)
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(portrait)
	player_name = LifeTitleParts.label(self,&"",&"LifeDayTitle")
	player_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	farm_name = LifeTitleParts.label(self,&"")
	farm_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note = LifeTitleParts.label(self,&"CHAR_PROFILE_NOTE",&"LifeText16")
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func display(snapshot: Dictionary) -> void:
	var name_text: String = String(snapshot.player_name)
	var farm_text: String = String(snapshot.farm_name)
	player_name.text = name_text if not name_text.is_empty() else tr("UI_DEFAULT_PLAYER")
	farm_name.text = farm_text if not farm_text.is_empty() else tr("UI_DEFAULT_FARM")
	player_name.tooltip_text = player_name.text
	farm_name.tooltip_text = farm_name.text
	note.text = tr("CHAR_PROFILE_NOTE")
	portrait.display_player(snapshot.appearance)
