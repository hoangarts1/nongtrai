## QuestBookSnapshot — detached display data, never accepts/delivers a quest.
class_name QuestBookSnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	var goals: Array[Dictionary] = []
	var completed: int = 0
	for index: int in range(main.quest_panel.STEP_KEYS.size()):
		var done: bool = main.quest_state.is_step_completed(index)
		goals.append({"key":main.quest_panel.STEP_KEYS[index],"done":done,"item_id":&"","have":0,"target":0})
		completed += int(done)
	var entries: Array[Dictionary] = [{"key":"onboarding","id":&"","tutorial":true,"title_key":&"BOOK_TUTORIAL","description_key":&"BOOK_TUTORIAL_DESC",
		"giver_id":&"","status":&"completed" if main.quest_state.is_complete() else &"active","progress":completed,"target":goals.size(),"objectives":goals,
		"coins":0,"reward_item":&"","reward_quantity":0}]
	var social: NpcSocialState = main.npc_system.state
	for resource: Resource in DataRegistry.get_all_quests():
		var quest: QuestData = social.quests.get_quest(StringName(resource.get("quest_id")))
		if quest == null:
			continue
		var done: bool = social.quests.is_quest_completed(quest.quest_id)
		var have: int = main.inventory.get_quantity(quest.required_item_id)
		var objective: Array[Dictionary] = [{"key":&"BOOK_IN_BAG","done":done,"item_id":quest.required_item_id,"have":have,"target":quest.required_item_quantity}]
		entries.append({"key":"delivery:"+String(quest.quest_id),"id":quest.quest_id,"tutorial":false,"title_key":quest.title_key,"description_key":quest.description_key,
			"giver_id":quest.giver_id,"status":&"completed" if done else (&"active" if social.quests.is_quest_active(quest.quest_id) else &"new"),
			"progress":have,"target":quest.required_item_quantity,"objectives":objective,
			"coins":quest.reward_coins,"reward_item":quest.reward_item_id,"reward_quantity":quest.reward_item_quantity})
	var people: Array[Dictionary] = []
	for resource: Resource in social.content.npcs:
		var npc: NpcData = resource as NpcData
		people.append({"name_key":npc.display_name_key,"points":int(social.friendship.get(npc.npc_id,0)),"maximum":npc.friendship_max})
	return {"entries":entries,"people":people}
