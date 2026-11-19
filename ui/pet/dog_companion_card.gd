## LifeDogCompanionCard - small read-only companion entry below profile.
class_name LifeDogCompanionCard
extends VBoxContainer
signal rename_requested()
var title: Label
var dog_name: Label
var rename: Button
func _ready() -> void:
	title = LifeTitleParts.label(self, &"DOG_COMPANION", &"LifeText16")
	dog_name = LifeTitleParts.label(self, &"DOG_UNNAMED", &"LifeText18")
	rename = LifeTitleParts.button(self, &"DOG_NAME_OPEN")
	rename.pressed.connect(func() -> void: rename_requested.emit())
