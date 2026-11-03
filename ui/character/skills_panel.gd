## LifeCharacterSkills — reference categories only; no skill domain exists.
class_name LifeCharacterSkills
extends VBoxContainer

const KEYS: Array[StringName] = [&"CHAR_SKILL_GARDEN",&"CHAR_SKILL_WATER",&"CHAR_SKILL_HARVEST",&"CHAR_SKILL_FISH",&"CHAR_SKILL_TRADE"]
var heading: Label
var note: Label
var rows: Array[LifeCharacterSkill] = []

func _ready() -> void:
	heading = LifeTitleParts.label(self,&"CHAR_SKILLS",&"LifeDayHeading")
	for key: StringName in KEYS:
		var row: LifeCharacterSkill = preload("res://ui/character/skill_row.tscn").instantiate() as LifeCharacterSkill
		add_child(row)
		rows.append(row)
	note = LifeTitleParts.label(self,&"CHAR_SKILLS_NOTE",&"LifeText16")
	refresh()

func refresh() -> void:
	heading.text = tr("CHAR_SKILLS")
	note.text = tr("CHAR_SKILLS_NOTE")
	for index: int in range(rows.size()):
		rows[index].display(KEYS[index])
