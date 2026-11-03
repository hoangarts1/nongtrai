## LifeHudParts — small construction helpers, no game data or layout authority.
class_name LifeHudParts
extends RefCounted

static func label(parent: Node, variation: StringName = &"LifeText18") -> Label:
	var result: Label = Label.new()
	result.theme_type_variation = variation
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

static func texture(parent: Node, icon: Texture2D, extent: int = 32) -> TextureRect:
	var result: TextureRect = TextureRect.new()
	result.texture = icon
	result.custom_minimum_size = Vector2(extent,extent)
	result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

static func column(parent: Node) -> VBoxContainer:
	var result: VBoxContainer = VBoxContainer.new()
	result.theme_type_variation = &"LifeHudColumn"
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result
