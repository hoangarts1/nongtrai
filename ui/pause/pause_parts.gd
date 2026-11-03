## LifePauseParts — shared-theme native construction; no preference/game state.
class_name LifePauseParts
extends RefCounted

static func paper(parent: Node) -> VBoxContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.theme_type_variation = &"LifeHudPaper"
	parent.add_child(panel)
	return LifeHudParts.column(panel)

static func label(parent: Node, key: StringName, variation: StringName = &"LifeText18") -> Label:
	var result: Label = LifeHudParts.label(parent,variation)
	result.text = TranslationServer.translate(key)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return result

static func button(parent: Node, key: StringName, tone: StringName = &"LifeSecondary") -> Button:
	var result: Button = Button.new()
	result.theme_type_variation = tone
	result.text = TranslationServer.translate(key)
	result.custom_minimum_size.y = 44
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(result)
	return result

static func unavailable(parent: Node, key: StringName) -> CheckButton:
	var result: CheckButton = CheckButton.new()
	result.theme_type_variation = &"LifeToggle"
	result.text = TranslationServer.translate(key)
	result.disabled = true
	result.tooltip_text = TranslationServer.translate(&"PAUSE_UNAVAILABLE")
	result.custom_minimum_size.y = 40
	parent.add_child(result)
	return result

static func refresh_unavailable(button: CheckButton, key: StringName) -> void:
	button.text = TranslationServer.translate(key)
	button.tooltip_text = TranslationServer.translate(&"PAUSE_UNAVAILABLE")
