## LifeDialogueSnapshot — detached read-only view data from existing NPC systems.
## API: static build(state:NpcSocialState,inventory:InventoryState,npc_id:StringName,day:int,season:StringName)->Dictionary.
class_name LifeDialogueSnapshot
extends RefCounted

static func build(state: NpcSocialState, inventory: InventoryState, npc_id: StringName, day: int, season: StringName) -> Dictionary:
	if state == null or inventory == null or state.content == null:
		return {}
	var npc: NpcData = state.get_npc(npc_id)
	var line: DialogueData = state.get_dialogue(npc_id, season)
	if npc == null or line == null:
		return {}
	var details: Array[String] = []
	var actions: Array[Dictionary] = []
	var quest: QuestData = state.quests.get_quest(line.quest_id)
	if quest != null:
		if line.start_quest:
			actions.append({"id": &"AcceptQuest", "text": TranslationServer.translate(&"UI_NPC_ACCEPT_QUEST"), "enabled": true})
		if state.quests.is_quest_active(quest.quest_id):
			details.append(TranslationServer.translate(&"UI_QUEST_REQUIREMENT") % [_item_name(quest.required_item_id), quest.required_item_quantity, inventory.get_quantity(quest.required_item_id)])
			details.append(TranslationServer.translate(&"UI_QUEST_REWARD") % [quest.reward_coins, _item_name(quest.reward_item_id), quest.reward_item_quantity])
			var can_deliver: bool = state.quests.can_deliver(quest.quest_id, inventory)
			if not can_deliver:
				details.append(TranslationServer.translate(&"UI_NPC_DELIVERY_BLOCKED"))
			actions.append({"id": &"DeliverQuest", "text": TranslationServer.translate(&"UI_CONFIRM_DELIVERY"), "enabled": can_deliver})
	if npc.is_merchant:
		var offer: MerchantOfferData = state.merchant.get_offer(day, season)
		if offer != null:
			details.append(TranslationServer.translate(StringName("UI_NPC_OFFER_" + offer.kind.to_upper())) % [_item_name(offer.item_id), offer.quantity, offer.unit_price * offer.quantity])
			actions.append({"id": &"ConfirmOffer", "text": TranslationServer.translate(&"UI_NPC_CONFIRM_TRADE"), "enabled": not state.merchant.is_consumed(day)})
	return {"npc_id": npc_id, "name": TranslationServer.translate(npc.display_name_key), "color": npc.color, "body": TranslationServer.translate(line.text_key), "details": "\n".join(details), "friendship": int(state.friendship.get(npc_id, 0)), "friendship_max": npc.friendship_max, "quest_id": line.quest_id, "dialogue_id": line.dialogue_id, "actions": actions}

static func _item_name(id: StringName) -> String:
	var item: Resource = DataRegistry.get_item(id)
	return TranslationServer.translate(StringName(item.get("display_name_key"))) if item != null else ""
