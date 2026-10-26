extends GutTest

func _quest(reward_quantity: int = 2) -> QuestData:
	var quest: QuestData = preload("res://data/quests/quest_turnip_delivery.tres").duplicate()
	quest.reward_item_quantity = reward_quantity
	return quest

func test_confirmation_requires_all_items_and_pays_once() -> void:
	var manager: QuestManager = QuestManager.new()
	var quest: QuestData = _quest()
	manager.register_quest(quest)
	manager.accept_quest(quest.quest_id)
	var inventory: InventoryState = InventoryState.new()
	var wallet: WalletState = WalletState.new(100)
	inventory.add_item(quest.required_item_id, quest.required_item_quantity - 1)
	var before: Dictionary = inventory.serialize()
	assert_false(manager.confirm_delivery(quest.quest_id, inventory, wallet))
	assert_eq(inventory.serialize(), before)
	assert_eq(wallet.get_coins(), 100)
	inventory.add_item(quest.required_item_id, 1)
	before = inventory.serialize()
	assert_true(manager.can_deliver(quest.quest_id, inventory))
	assert_eq(inventory.serialize(), before, "Preview never consumes items")
	assert_true(manager.confirm_delivery(quest.quest_id, inventory, wallet))
	assert_eq(inventory.get_quantity(quest.required_item_id), 0)
	assert_eq(inventory.get_quantity(quest.reward_item_id), quest.reward_item_quantity)
	assert_eq(wallet.get_coins(), 100 + quest.reward_coins)
	assert_false(manager.confirm_delivery(quest.quest_id, inventory, wallet))
	assert_eq(wallet.get_coins(), 100 + quest.reward_coins)

func test_reward_capacity_uses_exact_post_delivery_slots() -> void:
	var manager: QuestManager = QuestManager.new()
	var quest: QuestData = _quest(200)
	manager.register_quest(quest)
	manager.accept_quest(quest.quest_id)
	var inventory: InventoryState = InventoryState.new(1)
	var wallet: WalletState = WalletState.new(100)
	inventory.add_item(quest.required_item_id, quest.required_item_quantity)
	var before: Dictionary = inventory.serialize()
	assert_false(manager.confirm_delivery(quest.quest_id, inventory, wallet))
	assert_eq(inventory.serialize(), before)
	assert_eq(wallet.get_coins(), 100)
	quest.reward_item_quantity = 2
	assert_false(manager.confirm_delivery(quest.quest_id, inventory, null))
	assert_eq(inventory.serialize(), before)
	assert_true(manager.confirm_delivery(quest.quest_id, inventory, wallet), "Delivery frees its slot")

func test_reentrant_confirm_cannot_duplicate_rewards() -> void:
	var manager: QuestManager = QuestManager.new()
	var quest: QuestData = _quest()
	manager.register_quest(quest)
	manager.accept_quest(quest.quest_id)
	var inventory: InventoryState = InventoryState.new()
	var wallet: WalletState = WalletState.new(100)
	inventory.add_item(quest.required_item_id, quest.required_item_quantity * 2)
	inventory.item_removed.connect(func(_id: StringName, _quantity: int) -> void:
		assert_false(manager.confirm_delivery(quest.quest_id, inventory, wallet)))
	assert_true(manager.confirm_delivery(quest.quest_id, inventory, wallet))
	assert_eq(wallet.get_coins(), 100 + quest.reward_coins)
