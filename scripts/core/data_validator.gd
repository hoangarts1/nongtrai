## DataValidator — validates shipped gameplay Resources before tests or builds.
## API:
##   static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray
##   static func validate_crop_references(crops: Array[Resource], items: Array[Resource]) -> PackedStringArray
##   static func validate_translation_keys(paths: Array[String], required_keys: PackedStringArray) -> PackedStringArray
##   static func validate_weather_profile(path: String) -> PackedStringArray
##   static func validate_art_palette_path(path: String) -> PackedStringArray
##   static func validate_character_catalog_path(path: String) -> PackedStringArray
class_name DataValidator
extends RefCounted

static func validate_item_resources(resources: Array[Resource]) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var ids: Dictionary = {}
	for item_data: Resource in resources:
		if item_data == null:
			errors.append("item resource is missing")
			continue
		var resource_id: String = _resource_identifier(item_data)
		if resource_id.is_empty():
			errors.append("item/crop id is empty")
		elif not _is_snake_case(resource_id):
			errors.append("item/crop id is not snake_case: %s" % resource_id)
		elif ids.has(resource_id):
			errors.append("duplicate item/crop id: %s" % resource_id)
		else:
			ids[resource_id] = true
		var max_stack: Variant = item_data.get("max_stack")
		if max_stack != null:
			if int(max_stack) <= 0:
				errors.append("item max_stack must be positive: %s" % resource_id)
	return errors

static func validate_item_paths(paths: Array[String]) -> PackedStringArray:
	var resources: Array[Resource] = []
	for path: String in paths:
		if not ResourceLoader.exists(path):
			resources.append(null)
			continue
		var resource: Resource = load(path)
		if resource == null:
			resources.append(null)
			continue
		resources.append(resource)
	return validate_item_resources(resources)

static func validate_crop_references(crops: Array[Resource], items: Array[Resource]) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var item_dict: Dictionary = {}
	for item: Resource in items:
		if item != null:
			var i_id: Variant = item.get("item_id")
			if i_id != null:
				item_dict[StringName(i_id)] = item
	for crop: Resource in crops:
		if crop == null:
			errors.append("crop resource is null")
			continue
		var crop_id: String = String(crop.get("crop_id"))
		var seed_id: StringName = StringName(crop.get("seed_item"))
		var prod_id: StringName = StringName(crop.get("product_item"))
		if int(crop.get("yield_qty")) <= 0:
			errors.append("crop %s yield_qty must be positive" % crop_id)
		if not item_dict.has(seed_id):
			errors.append("crop %s references unknown seed item %s" % [crop_id, seed_id])
		if not item_dict.has(prod_id):
			errors.append("crop %s references unknown product item %s" % [crop_id, prod_id])
		if item_dict.has(seed_id) and item_dict.has(prod_id):
			var seed_item: Resource = item_dict[seed_id]
			var prod_item: Resource = item_dict[prod_id]
			var buy_price: int = int(seed_item.get("buy_price"))
			var sell_price: int = int(prod_item.get("sell_price"))
			if buy_price <= 0:
				errors.append("seed item %s for crop %s must have positive buy_price" % [seed_id, crop_id])
			if sell_price <= 0:
				errors.append("product item %s for crop %s must have positive sell_price" % [prod_id, crop_id])
			if sell_price <= buy_price:
				errors.append("crop %s product sell_price (%d) must exceed seed buy_price (%d)" % [crop_id, sell_price, buy_price])
	for i: int in range(crops.size()):
		var crop_a: Resource = crops[i]
		if crop_a == null:
			continue
		var growth_a: int = int(crop_a.get("growth_days"))
		var seed_a: Resource = item_dict.get(StringName(crop_a.get("seed_item")))
		var prod_a: Resource = item_dict.get(StringName(crop_a.get("product_item")))
		if seed_a == null or prod_a == null:
			continue
		for j: int in range(i + 1, crops.size()):
			var crop_b: Resource = crops[j]
			if crop_b == null:
				continue
			var growth_b: int = int(crop_b.get("growth_days"))
			var seed_b: Resource = item_dict.get(StringName(crop_b.get("seed_item")))
			var prod_b: Resource = item_dict.get(StringName(crop_b.get("product_item")))
			if seed_b == null or prod_b == null:
				continue
			if growth_a > growth_b:
				if int(seed_a.get("buy_price")) < int(seed_b.get("buy_price")):
					errors.append("crop %s seed buy_price is lower than faster crop %s" % [crop_a.get("crop_id"), crop_b.get("crop_id")])
				if int(prod_a.get("sell_price")) < int(prod_b.get("sell_price")):
					errors.append("crop %s product sell_price is lower than faster crop %s" % [crop_a.get("crop_id"), crop_b.get("crop_id")])
			elif growth_b > growth_a:
				if int(seed_b.get("buy_price")) < int(seed_a.get("buy_price")):
					errors.append("crop %s seed buy_price is lower than faster crop %s" % [crop_b.get("crop_id"), crop_a.get("crop_id")])
				if int(prod_b.get("sell_price")) < int(prod_a.get("sell_price")):
					errors.append("crop %s product sell_price is lower than faster crop %s" % [crop_b.get("crop_id"), crop_a.get("crop_id")])
	return errors

static func validate_crop_paths(crop_paths: Array[String], item_paths: Array[String]) -> PackedStringArray:
	var crops: Array[Resource] = []
	for path: String in crop_paths:
		if ResourceLoader.exists(path):
			crops.append(load(path))
		else:
			crops.append(null)
	var items: Array[Resource] = []
	for path: String in item_paths:
		if ResourceLoader.exists(path):
			items.append(load(path))
		else:
			items.append(null)
	return validate_crop_references(crops, items)

static func validate_translation_keys(paths: Array[String], required_keys: PackedStringArray) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var found_keys: Dictionary = {}
	for path: String in paths:
		if not FileAccess.file_exists(path):
			errors.append("missing translation file: %s" % path)
			continue
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file == null:
			errors.append("unable to read translation file: %s" % path)
			continue
		var header: String = file.get_line()
		if header.strip_edges().is_empty():
			continue
		while not file.eof_reached():
			var line: String = file.get_line()
			if line.strip_edges().is_empty():
				continue
			var fields: PackedStringArray = _parse_csv_line(line)
			if fields.size() < 2:
				continue
			var key: String = fields[0].strip_edges()
			if not key.is_empty():
				found_keys[key] = true
	for key: String in required_keys:
		if not found_keys.has(key):
			errors.append("missing translation key: %s" % key)
	return errors

static func validate_weather_profile(path: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not ResourceLoader.exists(path):
		errors.append("weather profile is missing: %s" % path)
		return errors
	var profile: Resource = load(path)
	if profile == null:
		errors.append("weather profile cannot be loaded: %s" % path)
		return errors
	var total: int = 0
	for entry: Dictionary in profile.get("entries"):
		var weather_id: String = String(entry.get("id", ""))
		if weather_id.is_empty() or not _is_snake_case(weather_id):
			errors.append("weather id is invalid: %s" % weather_id)
		var probability: int = int(entry.get("probability", 0))
		if probability < 0:
			errors.append("weather probability is negative: %s" % weather_id)
		total += probability
	if total <= 0:
		errors.append("weather probabilities must have a positive total")
	return errors

static func validate_art_palette_path(path: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not ResourceLoader.exists(path):
		errors.append("art palette is missing: %s" % path)
		return errors
	var resource: Resource = load(path)
	var palette: Resource = resource as Resource
	if palette == null:
		errors.append("art palette cannot be loaded: %s" % path)
		return errors
	if not palette.has_method(&"validate"):
		errors.append("art palette has no validate API: %s" % path)
		return errors
	var validation: Variant = palette.call(&"validate")
	if not validation is PackedStringArray:
		errors.append("art palette validate API returned an invalid result: %s" % path)
		return errors
	return validation as PackedStringArray

static func validate_character_catalog_path(path: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not ResourceLoader.exists(path):
		errors.append("character catalog is missing: %s" % path)
		return errors
	var catalog: Resource = load(path) as Resource
	if catalog == null:
		errors.append("character catalog cannot be loaded: %s" % path)
		return errors
	if not catalog.has_method(&"validate"):
		errors.append("character catalog has no validate API: %s" % path)
		return errors
	var validation: Variant = catalog.call(&"validate")
	if not validation is PackedStringArray:
		errors.append("character catalog validate API returned an invalid result: %s" % path)
		return errors
	return validation as PackedStringArray

static func validate_quest_resources(quests: Array[Resource], items: Array[Resource]) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var item_ids: Dictionary = {}
	for item: Resource in items:
		if item != null:
			var i_id: Variant = item.get("item_id")
			if i_id != null:
				item_ids[StringName(i_id)] = true
	var quest_ids: Dictionary = {}
	for quest: Resource in quests:
		if quest == null:
			errors.append("quest resource is null")
			continue
		var q_id: String = String(quest.get("quest_id"))
		if q_id.is_empty():
			errors.append("quest id is empty")
		elif not _is_snake_case(q_id):
			errors.append("quest id is not snake_case: %s" % q_id)
		elif quest_ids.has(q_id):
			errors.append("duplicate quest id: %s" % q_id)
		else:
			quest_ids[q_id] = true
		
		var req_item: Variant = quest.get("required_item_id")
		if req_item != null and not String(req_item).is_empty():
			if not item_ids.has(StringName(req_item)):
				errors.append("quest %s references unknown required_item %s" % [q_id, req_item])
		var req_qty: int = int(quest.get("required_item_quantity"))
		if req_qty < 0:
			errors.append("quest %s required_item_quantity cannot be negative" % q_id)
		if req_qty > 0 and (req_item == null or String(req_item).is_empty()):
			errors.append("quest %s positive requirement needs an item id" % q_id)
		
		var rew_coins: int = int(quest.get("reward_coins"))
		if rew_coins < 0:
			errors.append("quest %s reward_coins cannot be negative" % q_id)
		
		var rew_item: Variant = quest.get("reward_item_id")
		if rew_item != null and not String(rew_item).is_empty():
			if not item_ids.has(StringName(rew_item)):
				errors.append("quest %s references unknown reward_item %s" % [q_id, rew_item])
		var rew_qty: int = int(quest.get("reward_item_quantity"))
		if rew_qty < 0:
			errors.append("quest %s reward_item_quantity cannot be negative" % q_id)
		if rew_qty > 0 and (rew_item == null or String(rew_item).is_empty()):
			errors.append("quest %s positive reward needs an item id" % q_id)
	return errors

static func validate_quest_paths(quest_paths: Array[String], item_paths: Array[String]) -> PackedStringArray:
	var quests: Array[Resource] = []
	for path: String in quest_paths:
		if ResourceLoader.exists(path):
			quests.append(load(path))
		else:
			quests.append(null)
	var items: Array[Resource] = []
	for path: String in item_paths:
		if ResourceLoader.exists(path):
			items.append(load(path))
		else:
			items.append(null)
	return validate_quest_resources(quests, items)

static func validate_npc_world(data: NpcWorldData, items: Array[Resource], quests: Array[Resource], locale_paths: Array[String]) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if data == null or data.locations == null or data.day_night_profile == null:
		return PackedStringArray(["NPC world requires locations and lighting profile"])
	if data.days_per_week <= 0 or data.interaction_reach <= 0.0 or data.night_moon_energy <= 0.0:
		errors.append("NPC schedule parameters must be positive")
	var keys: PackedStringArray = PackedStringArray()
	var ids: Dictionary = {}
	var quest_ids: Dictionary = {}
	var item_ids: Dictionary = {}
	for item: Resource in items:
		item_ids[item.get("item_id")] = item
	for quest: Resource in quests:
		quest_ids[quest.get("quest_id")] = quest
		keys.append(String(quest.get("title_key")))
		keys.append(String(quest.get("description_key")))
	for resource: Resource in data.npcs:
		var npc: NpcData = resource as NpcData
		if npc == null or not _is_snake_case(String(npc.npc_id)) or ids.has(npc.npc_id):
			errors.append("Invalid or duplicate NPC id")
			continue
		ids[npc.npc_id] = npc
		keys.append(String(npc.display_name_key))
		if not data.locations.has_location(npc.home_location):
			errors.append("Unknown NPC home: %s" % npc.npc_id)
		if npc.friendship_max <= 0 or npc.talk_friendship < 0 or npc.move_speed <= 0.0:
			errors.append("Invalid NPC movement/friendship: %s" % npc.npc_id)
		for block: Resource in npc.schedule:
			var entry: NpcScheduleEntry = block as NpcScheduleEntry
			if entry == null:
				errors.append("Invalid NPC schedule resource")
				continue
			if not data.locations.has_location(entry.location_id) or entry.start_minute >= entry.end_minute:
				errors.append("Invalid NPC schedule location/time")
			for weekday: int in entry.weekdays:
				if weekday < 1 or weekday > data.days_per_week:
					errors.append("Invalid NPC weekday")
			for season: String in entry.seasons:
				if not season in ["spring", "summer", "autumn", "winter"]:
					errors.append("Invalid NPC season")
	var line_ids: Dictionary = {}
	for resource: Resource in data.dialogues:
		var line: DialogueData = resource as DialogueData
		if line == null or not _is_snake_case(String(line.dialogue_id)) or line_ids.has(line.dialogue_id):
			errors.append("Invalid or duplicate dialogue id")
			continue
		line_ids[line.dialogue_id] = true
		keys.append(String(line.text_key))
		if not ids.has(line.npc_id) or (not line.quest_id.is_empty() and not quest_ids.has(line.quest_id)):
			errors.append("Unresolved dialogue NPC/quest")
	var offer_ids: Dictionary = {}
	for resource: Resource in data.offers:
		var offer: MerchantOfferData = resource as MerchantOfferData
		if offer == null or not _is_snake_case(String(offer.offer_id)) or offer_ids.has(offer.offer_id):
			errors.append("Invalid or duplicate merchant offer id")
			continue
		offer_ids[offer.offer_id] = true
		if not item_ids.has(offer.item_id) or offer.quantity <= 0 or offer.unit_price <= 0 or not offer.kind in ["discount", "request"]:
			errors.append("Invalid merchant offer: %s" % offer.offer_id)
		elif offer.kind == "discount":
			var item: Resource = item_ids[offer.item_id]
			if offer.unit_price >= int(item.get("buy_price")) or offer.unit_price < int(item.get("sell_price")):
				errors.append("Merchant discount must be below buy price and at least sell price")
	if errors.is_empty():
		var schedule: NpcSchedule = NpcSchedule.new()
		schedule.configure(data)
		for resource: Resource in data.npcs:
			var npc: NpcData = resource as NpcData
			for block: Resource in npc.schedule:
				var entry: NpcScheduleEntry = block as NpcScheduleEntry
				if schedule.route(schedule.location_cell(npc.home_location), schedule.location_cell(entry.location_id)).is_empty():
					errors.append("Unreachable NPC destination: %s" % entry.location_id)
	errors.append_array(validate_translation_keys(locale_paths, keys))
	return errors

static func validate_vietnamese_values(english_path: String, vietnamese_path: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var english: Dictionary = _read_translation_values(english_path)
	var vietnamese: Dictionary = _read_translation_values(vietnamese_path)
	for key: String in english:
		if not vietnamese.has(key) or String(vietnamese[key]).strip_edges().is_empty():
			errors.append("missing Vietnamese translation: %s" % key)
	return errors

static func _read_translation_values(path: String) -> Dictionary:
	var values: Dictionary = {}
	if not FileAccess.file_exists(path):
		return values
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return values
	file.get_line()
	while not file.eof_reached():
		var fields: PackedStringArray = _parse_csv_line(file.get_line())
		if fields.size() >= 2 and not fields[0].strip_edges().is_empty():
			values[fields[0].strip_edges()] = fields[1].strip_edges()
	return values

static func _parse_csv_line(line: String) -> PackedStringArray:
	var parts: PackedStringArray = []
	var current: String = ""
	var in_quotes: bool = false
	for index: int in range(line.length()):
		var character: String = line.substr(index, 1)
		if character == "\"":
			if in_quotes and index + 1 < line.length() and line.substr(index + 1, 1) == "\"":
				current += "\""
				index += 1
			else:
				in_quotes = not in_quotes
		elif character == "," and not in_quotes:
			parts.append(current)
			current = ""
		else:
			current += character
	parts.append(current)
	return parts

static func _resource_identifier(resource: Resource) -> String:
	var item_id: Variant = resource.get("item_id")
	if item_id != null and String(item_id) != "":
		return String(item_id)
	var crop_id: Variant = resource.get("crop_id")
	if crop_id != null and String(crop_id) != "":
		return String(crop_id)
	return ""

static func _is_snake_case(value: String) -> bool:
	return value == value.to_lower() and not value.contains(" ") and not value.contains("-")
