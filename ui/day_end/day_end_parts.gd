## LifeDayEndParts — localized display helpers only.
class_name LifeDayEndParts
extends RefCounted

static func money(value: int, signed: bool = false) -> String:
	var result: String = str(absi(value))
	var index: int = result.length()-3
	while index > 0:
		result = result.insert(index,"." if TranslationServer.get_locale().begins_with("vi") else ",")
		index -= 3
	return ("-" if value < 0 else ("+" if signed and value > 0 else ""))+result

static func heading(parent: Node, key: StringName) -> Label:
	var result: Label = LifeHudParts.label(parent,&"LifeDayHeading")
	result.text = TranslationServer.translate(key)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result

static func wrapped(parent: Node, variation: StringName = &"LifeText18") -> Label:
	var result: Label = LifeHudParts.label(parent,variation)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return result
