## LifeDogPresenter - localized companion and naming presentation only.
class_name LifeDogPresenter
extends RefCounted
const KEYS: PackedStringArray = ["DOG_COMPANION","DOG_UNNAMED","DOG_NAME_OPEN","DOG_NAME_TITLE","DOG_NAME_SAVE","DOG_NAME_CANCEL","DOG_NAME_INVALID","DOG_NAME_STALE"]
static func name_text(snapshot: Dictionary) -> String:
	return String(snapshot.name) if not String(snapshot.name).is_empty() else TranslationServer.translate(&"DOG_UNNAMED")
static func card(panel: LifeDogCompanionCard, snapshot: Dictionary) -> void:
	panel.title.text = TranslationServer.translate(&"DOG_COMPANION")
	panel.dog_name.text = name_text(snapshot)
	panel.rename.text = TranslationServer.translate(&"DOG_NAME_OPEN")
static func form(panel: LifeDogNameSheet, result: Dictionary = {}) -> void:
	panel.form.title.text = TranslationServer.translate(&"DOG_NAME_TITLE")
	panel.form.field.placeholder_text = TranslationServer.translate(&"DOG_UNNAMED")
	panel.form.save.text = TranslationServer.translate(&"DOG_NAME_SAVE")
	panel.form.cancel.text = TranslationServer.translate(&"DOG_NAME_CANCEL")
	panel.form.error.text = "" if result.is_empty() else TranslationServer.translate(&"DOG_NAME_STALE" if result.get("reason")==&"stale_dog_quote" else &"DOG_NAME_INVALID")
