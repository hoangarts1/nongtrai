## CharacterPresenter — localized read-only profile/social display.
class_name CharacterPresenter
extends RefCounted

static func render(panel: LifeCharacterSheet, snapshot: Dictionary) -> void:
	panel.identity.display(snapshot)
	panel.skills.refresh()
	var rows: Array[Dictionary] = []
	rows.assign(snapshot.npcs)
	panel.relationships.display(rows)
	panel.hint.text = TranslationServer.translate(&"CHAR_KEYS")
