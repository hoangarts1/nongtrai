## CharacterSnapshot — detached display values from existing profile/social owners.
class_name CharacterSnapshot
extends RefCounted

static func capture(main: Node) -> Dictionary:
	var profile: Dictionary = main.profile
	var selection: Dictionary = LifeTitleParts.dictionary(profile.get("appearance",{}))
	var result: Dictionary = {"player_name":LifeTitleParts.text(profile,&"player_name"),"farm_name":LifeTitleParts.text(profile,&"farm_name"),
		"appearance":LifeCharacterPortrait.CATALOG.normalize_player_customization(selection)}
	var rows: Array[Dictionary] = []
	var social: NpcSocialState = main.npc_system.state
	for resource: Resource in social.content.npcs:
		var npc: NpcData = resource as NpcData
		rows.append({"id":npc.npc_id,"name_key":npc.display_name_key,"color":npc.color,
			"points":int(social.friendship.get(npc.npc_id,0)),"maximum":npc.friendship_max})
	result.dog = LifeDogSnapshot.capture(main)
	result.npcs = rows
	return result
