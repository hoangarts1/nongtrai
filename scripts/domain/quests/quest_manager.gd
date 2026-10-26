## QuestManager — tracks accepted quests, delivery validation, and atomic reward payout.
## API:
##   func register_quest(quest: QuestData) -> void
##   func accept_quest(quest_id: StringName) -> bool
##   func is_quest_active(quest_id: StringName) -> bool
##   func is_quest_completed(quest_id: StringName) -> bool
##   func get_active_quest_ids() -> Array[StringName]
##   func get_completed_quest_ids() -> Array[StringName]
##   func get_quest(quest_id: StringName) -> QuestData
##   func can_deliver(quest_id: StringName, inventory: InventoryState) -> bool
##   func confirm_delivery(quest_id: StringName, inventory: InventoryState, wallet: WalletState) -> bool
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
##   signal quest_accepted(quest_id: StringName)
##   signal quest_completed(quest_id: StringName, reward_coins: int, reward_item_id: StringName, reward_quantity: int)
class_name QuestManager
extends RefCounted

signal quest_accepted(quest_id: StringName)
signal quest_completed(quest_id: StringName, reward_coins: int, reward_item_id: StringName, reward_quantity: int)

var _quests: Dictionary = {}
var _active_quests: Array[StringName] = []
var _completed_quests: Array[StringName] = []

func register_quest(quest: QuestData) -> void:
	if quest != null and not quest.quest_id.is_empty():
		_quests[quest.quest_id] = quest

func get_quest(quest_id: StringName) -> QuestData:
	return _quests.get(quest_id) as QuestData

func accept_quest(quest_id: StringName) -> bool:
	if not _quests.has(quest_id):
		return false
	if _active_quests.has(quest_id) or _completed_quests.has(quest_id):
		return false
	_active_quests.append(quest_id)
	quest_accepted.emit(quest_id)
	return true

func is_quest_active(quest_id: StringName) -> bool:
	return _active_quests.has(quest_id)

func is_quest_completed(quest_id: StringName) -> bool:
	return _completed_quests.has(quest_id)

func get_active_quest_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	result.assign(_active_quests)
	return result

func get_completed_quest_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	result.assign(_completed_quests)
	return result

func can_deliver(quest_id: StringName, inventory: InventoryState) -> bool:
	if not is_quest_active(quest_id):
		return false
	var quest: QuestData = get_quest(quest_id)
	if quest == null:
		return false
	if not quest.required_item_id.is_empty() and quest.required_item_quantity > 0:
		if inventory == null or not inventory.has_item(quest.required_item_id, quest.required_item_quantity):
			return false
	if not quest.reward_item_id.is_empty() and quest.reward_item_quantity > 0:
		if inventory == null:
			return false
		if not inventory.can_add_item(quest.reward_item_id, quest.reward_item_quantity):
			# If removing required item frees up a slot, delivering can still succeed
			var freeing_slot: bool = false
			if not quest.required_item_id.is_empty() and quest.required_item_quantity > 0:
				if inventory.get_quantity(quest.required_item_id) == quest.required_item_quantity:
					freeing_slot = true
			if not freeing_slot:
				return false
	return true

func confirm_delivery(quest_id: StringName, inventory: InventoryState, wallet: WalletState) -> bool:
	if not can_deliver(quest_id, inventory):
		return false
	var quest: QuestData = get_quest(quest_id)
	if quest == null:
		return false
	
	# Atomically deduct required items only upon confirmed delivery
	if not quest.required_item_id.is_empty() and quest.required_item_quantity > 0:
		var removed: bool = inventory.remove_item(quest.required_item_id, quest.required_item_quantity)
		if not removed:
			return false
		Events.item_delivered.emit(quest.required_item_id, quest.required_item_quantity, quest.giver_id)
	
	# Payout rewards using WalletState and InventoryState
	if quest.reward_coins > 0 and wallet != null:
		wallet.add_coins(quest.reward_coins, &"quest_reward")
	if not quest.reward_item_id.is_empty() and quest.reward_item_quantity > 0 and inventory != null:
		inventory.add_item(quest.reward_item_id, quest.reward_item_quantity)
	
	_active_quests.erase(quest_id)
	if not _completed_quests.has(quest_id):
		_completed_quests.append(quest_id)
	
	quest_completed.emit(quest_id, quest.reward_coins, quest.reward_item_id, quest.reward_item_quantity)
	return true

func serialize() -> Dictionary:
	var active_arr: Array = []
	for q_id: StringName in _active_quests:
		active_arr.append(String(q_id))
	var completed_arr: Array = []
	for q_id: StringName in _completed_quests:
		completed_arr.append(String(q_id))
	return {
		"active": active_arr,
		"completed": completed_arr
	}

func deserialize(data: Dictionary) -> void:
	_active_quests.clear()
	for item: Variant in data.get("active", []):
		var q_id: StringName = StringName(item)
		if not _active_quests.has(q_id):
			_active_quests.append(q_id)
	_completed_quests.clear()
	for item: Variant in data.get("completed", []):
		var q_id: StringName = StringName(item)
		if not _completed_quests.has(q_id):
			_completed_quests.append(q_id)
