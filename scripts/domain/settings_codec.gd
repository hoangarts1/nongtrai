## SettingsCodec — supported preference values, with separate load/draft validation.
## API: static decode(raw:Dictionary,strict:bool=false)->{ok,values,errors}.
class_name SettingsCodec
extends RefCounted

static func defaults() -> Dictionary:
	return {"music_volume": 1.0, "effects_volume": 1.0, "locale": "vi", "tutorial_dismissed": false}

static func decode(raw: Dictionary, strict: bool = false) -> Dictionary:
	var values: Dictionary = defaults()
	var errors: PackedStringArray = PackedStringArray()
	for key: String in ["music_volume", "effects_volume"]:
		var value: Variant = raw.get(key, values[key])
		if (value is int or value is float) and is_finite(float(value)):
			values[key] = clampf(float(value), 0.0, 1.0)
			if value < 0 or value > 1:
				errors.append(key)
		else:
			errors.append(key)
	var locale: Variant = raw.get("locale", "vi")
	if (locale is String or locale is StringName) and String(locale) in ["vi", "en"]:
		values.locale = String(locale)
	else:
		errors.append("locale")
	var tutorial: Variant = raw.get("tutorial_dismissed", false)
	if tutorial is bool:
		values.tutorial_dismissed = tutorial
	else:
		errors.append("tutorial_dismissed")
	return {"ok": not strict or errors.is_empty(), "values": values, "errors": errors}
