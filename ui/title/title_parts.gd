## LifeTitleParts — safe, localized display helpers; no gameplay ownership.
class_name LifeTitleParts
extends RefCounted

static func dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

static func text(data: Dictionary, key: StringName) -> String:
	var value: Variant = data.get(key,"")
	return value if value is String else ""

static func nonnegative_number(value: Variant) -> int:
	if not value is int and not value is float:
		return -1
	var result: int = DayLedgerState.number(value,-1)
	return result if result >= 0 and float(result) == float(value) else -1

static func label(parent: Node, key: StringName, tone: StringName = &"LifeText18") -> Label:
	return LifePauseParts.label(parent,key,tone)

static func button(parent: Node, key: StringName, tone: StringName = &"LifeSecondary") -> Button:
	return LifePauseParts.button(parent,key,tone)
