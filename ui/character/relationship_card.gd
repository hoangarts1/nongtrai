## LifeCharacterRelationship — actual numeric friendship, no remote actions.
class_name LifeCharacterRelationship
extends PanelContainer

var portrait: LifeCharacterPortrait
var title: Label
var points: Label
var hearts: LifeHeartRow

func _ready() -> void:
	theme_type_variation = &"LifeInvInset"
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	portrait = preload("res://ui/character/avatar_portrait.tscn").instantiate() as LifeCharacterPortrait
	row.add_child(portrait)
	var text: VBoxContainer = LifeHudParts.column(row)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title = LifeTitleParts.label(text,&"",&"LifeDayHeading")
	hearts = LifeHeartRow.new()
	hearts.custom_minimum_size = Vector2(158,30)
	text.add_child(hearts)
	points = LifeTitleParts.label(text,&"",&"LifeText16")

func display(row: Dictionary) -> void:
	title.text = tr(String(row.name_key))
	points.text = tr("CHAR_FRIENDSHIP") % [int(row.points),int(row.maximum)]
	# Five hearts describe the existing ratio; they never unlock a benefit.
	hearts.set_hearts(int(floor(float(row.points)*5.0/float(row.maximum))) if int(row.maximum)>0 else 0)
	portrait.display_npc(StringName(row.id),row.color)
