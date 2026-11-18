## LifeDialogueSpeaker — actual NPC renderer and localized saved name, no role invention.
class_name LifeDialogueSpeaker
extends VBoxContainer

var portrait: LifeCharacterPortrait
var name_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait = preload("res://ui/character/avatar_portrait.tscn").instantiate() as LifeCharacterPortrait
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(portrait)
	var badge: PanelContainer = PanelContainer.new()
	badge.theme_type_variation = &"LifeBannerGreen"
	add_child(badge)
	name_label = LifePauseParts.label(badge, &"", &"LifeText24")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func display(snapshot: Dictionary) -> void:
	name_label.text = String(snapshot.get("name", ""))
	portrait.display_npc(StringName(snapshot.get("npc_id", &"")), snapshot.get("color", Color.WHITE))
