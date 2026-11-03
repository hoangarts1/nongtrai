## LifeGameSettings — language draft and explicitly unavailable preferences.
class_name LifeGameSettings
extends VBoxContainer

var language: OptionButton
var _caption: Label
var _note: Label
var _rows: Array[CheckButton] = []
const KEYS: Array[StringName] = [&"PAUSE_KEY_HINTS",&"PAUSE_AUTOSAVE",&"PAUSE_SHAKE"]

func _ready() -> void:
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	_caption = LifePauseParts.label(row,&"PAUSE_LANGUAGE")
	language = OptionButton.new()
	language.custom_minimum_size = Vector2(170,44)
	language.add_item(tr("UI_VIETNAMESE"))
	language.add_item(tr("UI_ENGLISH"))
	row.add_child(language)
	for key: StringName in KEYS:
		_rows.append(LifePauseParts.unavailable(self,key))
	_note = LifePauseParts.label(self,&"PAUSE_AUTOSAVE_NOTE",&"LifeText16")

func set_locale(value: String) -> void:
	language.select(0 if value.begins_with("vi") else 1)

func get_locale() -> String:
	return "vi" if language.selected == 0 else "en"

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _note != null:
		_caption.text = tr("PAUSE_LANGUAGE")
		language.set_item_text(0,tr("UI_VIETNAMESE"))
		language.set_item_text(1,tr("UI_ENGLISH"))
		for index: int in range(KEYS.size()):
			LifePauseParts.refresh_unavailable(_rows[index],KEYS[index])
		_note.text = tr("PAUSE_AUTOSAVE_NOTE")
