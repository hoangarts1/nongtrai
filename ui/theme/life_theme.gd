## LifeTheme — access to the single shared UI Theme; never mutates its resources at runtime.
class_name LifeTheme
extends RefCounted

const PATH: String = "res://ui/theme/the_life_theme.tres"

static func get_theme() -> Theme:
	return load(PATH) as Theme

static func bind(control: Control, variation: StringName = &"") -> void:
	control.theme = get_theme()
	if not variation.is_empty():
		control.theme_type_variation = variation

static func text_variation(size: int) -> StringName:
	return StringName("LifeText%d" % size)
