## NpcSocialState — authoritative friendship, dialogue history and NPC cells.
## API:
##   func configure(data: NpcWorldData) -> void
##   func talk(npc_id: StringName, day: int, season: StringName) -> DialogueData
##   func get_dialogue(npc_id: StringName, season: StringName) -> DialogueData
##   func update_schedule(day: int, minute: int, season: StringName, rainy: bool) -> void
##   func refresh_routes() -> void
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name NpcSocialState
extends RefCounted

signal changed()
var quests: QuestManager = QuestManager.new()
var merchant: MerchantService = MerchantService.new()
var scheduler: NpcSchedule = NpcSchedule.new()
var content: NpcWorldData
var friendship: Dictionary = {}
var heard: Array[StringName] = []
var cells: Dictionary = {}
var targets: Dictionary = {}
var paths: Dictionary = {}
var _talk_days: Dictionary = {}
var _introduced: Array[StringName] = []
var _busy: bool = false

func is_busy() -> bool:
	return _busy

func get_introduced_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	if content==null: return ids
	for resource: Resource in content.npcs:
		var npc: NpcData = resource as NpcData
		if npc!=null and _introduced.has(npc.npc_id): ids.append(String(npc.npc_id))
	return ids

func record_introduction(npc_id: StringName, dialogue_id: StringName, day: int) -> bool:
	if _busy or content==null or day<0 or get_npc(npc_id)==null or not heard.has(dialogue_id) or int(_talk_days.get(npc_id,-1))!=day: return false
	var valid_line: bool = false
	for resource: Resource in content.dialogues:
		var line: DialogueData = resource as DialogueData
		if line!=null and line.npc_id==npc_id and line.dialogue_id==dialogue_id: valid_line = true
	if not valid_line: return false
	if _introduced.has(npc_id): return true
	_busy = true
	_introduced.append(npc_id)
	changed.emit()
	_busy = false
	return true

func configure(data: NpcWorldData) -> void:
	if _busy: return
	content = data
	scheduler.configure(data)
	merchant.offers = data.offers
	for quest: Resource in DataRegistry.get_all_quests():
		quests.register_quest(quest as QuestData)
	for resource: Resource in data.npcs:
		var npc: NpcData = resource as NpcData
		cells[npc.npc_id] = scheduler.location_cell(npc.home_location)
		friendship[npc.npc_id] = 0
	quests.quest_accepted.connect(_on_quest_accepted)
	quests.quest_completed.connect(_on_quest_completed)

func _on_quest_accepted(_id: StringName) -> void:
	changed.emit()

func _on_quest_completed(_id: StringName, _coins: int, _item: StringName, _quantity: int) -> void:
	changed.emit()

func get_npc(npc_id: StringName) -> NpcData:
	for resource: Resource in content.npcs:
		var npc: NpcData = resource as NpcData
		if npc.npc_id == npc_id:
			return npc
	return null

func get_dialogue(npc_id: StringName, season: StringName) -> DialogueData:
	for resource: Resource in content.dialogues:
		var line: DialogueData = resource as DialogueData
		if line.npc_id != npc_id or (not line.seasons.is_empty() and not line.seasons.has(String(season))):
			continue
		var active: bool = quests.is_quest_active(line.quest_id)
		var complete: bool = quests.is_quest_completed(line.quest_id)
		if line.quest_condition == "active" and not active:
			continue
		if line.quest_condition == "completed" and not complete:
			continue
		if line.quest_condition == "new" and (active or complete):
			continue
		return line
	return null

func talk(npc_id: StringName, day: int, season: StringName) -> DialogueData:
	if _busy or content==null or day<0: return null
	var npc: NpcData = get_npc(npc_id)
	var line: DialogueData = get_dialogue(npc_id, season)
	if npc == null or line == null:
		return null
	_busy = true
	if not heard.has(line.dialogue_id):
		heard.append(line.dialogue_id)
	if int(_talk_days.get(npc_id, -1)) != day:
		friendship[npc_id] = mini(npc.friendship_max, int(friendship.get(npc_id, 0)) + npc.talk_friendship)
		_talk_days[npc_id] = day
	changed.emit()
	_busy = false
	return line

func update_schedule(day: int, minute: int, season: StringName, rainy: bool, extra_visit: Dictionary = {}) -> void:
	if _busy: return
	for resource: Resource in content.npcs:
		var npc: NpcData = resource as NpcData
		var target: StringName = scheduler.destination(npc, day, minute, season, rainy, extra_visit)
		if targets.get(npc.npc_id, &"") == target:
			continue
		targets[npc.npc_id] = target
		paths[npc.npc_id] = scheduler.route(cells[npc.npc_id], scheduler.location_cell(target))
		if not paths[npc.npc_id].is_empty():
			paths[npc.npc_id].pop_front()

func refresh_routes() -> void:
	if _busy: return
	for npc_id: StringName in targets:
		paths[npc_id] = scheduler.route(cells[npc_id],scheduler.location_cell(targets[npc_id]))
		if not paths[npc_id].is_empty():
			paths[npc_id].pop_front()

func advance_step(npc_id: StringName) -> void:
	if _busy: return
	var path: Array = paths.get(npc_id, [])
	if not path.is_empty():
		cells[npc_id] = path.pop_front()

func is_indoors(npc_id: StringName) -> bool:
	var npc: NpcData = get_npc(npc_id)
	return npc != null and cells.get(npc_id) == scheduler.location_cell(npc.home_location) and targets.get(npc_id, npc.home_location) == npc.home_location

func serialize() -> Dictionary:
	var saved_cells: Dictionary = {}
	for id: StringName in cells:
		var cell: Vector2i = cells[id]
		saved_cells[String(id)] = "%d,%d" % [cell.x, cell.y]
	return {"quests": quests.serialize(), "merchant": merchant.serialize(), "friendship": friendship.duplicate(), "heard": heard.duplicate(), "talk_days": _talk_days.duplicate(), "cells": saved_cells, "introduced":Array(get_introduced_ids())}

func deserialize(data: Dictionary) -> void:
	if _busy: return
	quests.deserialize(_dictionary(data.get("quests")))
	merchant.deserialize(_dictionary(data.get("merchant")))
	var points: Dictionary = _dictionary(data.get("friendship"))
	var talks: Dictionary = _dictionary(data.get("talk_days"))
	var positions: Dictionary = _dictionary(data.get("cells"))
	_talk_days.clear()
	heard.clear()
	_introduced.clear()
	var history: Variant = data.get("heard", [])
	if history is Array:
		for value: Variant in history:
			if not value is String and not value is StringName:
				continue
			for resource: Resource in content.dialogues:
				var line: DialogueData = resource as DialogueData
				if line.dialogue_id == StringName(value) and not heard.has(line.dialogue_id):
					heard.append(line.dialogue_id)
	for resource: Resource in content.npcs:
		var npc: NpcData = resource as NpcData
		var point: Variant = points.get(String(npc.npc_id), 0)
		friendship[npc.npc_id] = clampi(int(point), 0, npc.friendship_max) if point is int or point is float else 0
		var day: Variant = talks.get(String(npc.npc_id), -1)
		if (day is int or day is float) and int(day) >= 0:
			_talk_days[npc.npc_id] = int(day)
		var cell: Vector2i = scheduler.location_cell(npc.home_location)
		var raw: Variant = positions.get(String(npc.npc_id), "")
		if raw is String:
			var parts: PackedStringArray = raw.split(",")
			if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
				var candidate: Vector2i = Vector2i(parts[0].to_int(), parts[1].to_int())
				if not scheduler.route(candidate, cell).is_empty():
					cell = candidate
		cells[npc.npc_id] = cell
	var introduced: Variant = data.get("introduced",[])
	if introduced is Array:
		var valid: bool = true
		for value: Variant in introduced:
			if typeof(value) not in [TYPE_STRING,TYPE_STRING_NAME] or get_npc(StringName(value))==null or _introduced.has(StringName(value)):
				valid = false
				break
			_introduced.append(StringName(value))
		if not valid: _introduced.clear()
	targets.clear()
	paths.clear()
	changed.emit()

func _dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
