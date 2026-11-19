## DogNameRules — canonical printable name, never truncates user text.
class_name DogNameRules
extends RefCounted

static func normalize(config: DogConfig, value: Variant, allow_empty: bool = false) -> Dictionary:
	if config == null or config.name_max_length < 1 or config.name_max_length > DogConfig.MAX_NAME_CODEPOINTS:
		return {"ok": false, "reason": &"invalid_config"}
	if not value is String and not value is StringName:
		return {"ok": false, "reason": &"invalid_name"}
	var name: String = String(value)
	for index: int in range(name.length()):
		if _control(name.unicode_at(index)):
			return {"ok": false, "reason": &"invalid_name"}
	name = name.strip_edges()
	if name.length() > config.name_max_length or (name.is_empty() and not allow_empty):
		return {"ok": false, "reason": &"invalid_name"}
	return {"ok": true, "name": name}

static func _control(codepoint: int) -> bool:
	# Unicode control/line/format ranges, not gameplay parameters. Combining
	# Vietnamese accents are printable and remain exact codepoints in saves.
	return codepoint < 32 or (codepoint >= 127 and codepoint <= 159) or (codepoint >= 0x200b and codepoint <= 0x200f) or (codepoint >= 0x2028 and codepoint <= 0x202e) or (codepoint >= 0x2060 and codepoint <= 0x206f) or (codepoint >= 0xd800 and codepoint <= 0xdfff) or codepoint in [0xfeff, 0xfffd, 0xfffe, 0xffff]
