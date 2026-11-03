## QuestBookPresenter — formats existing task snapshots, retains visible selection.
class_name QuestBookPresenter
extends RefCounted

static func render(book: LifeQuestBook, snapshot: Dictionary, filter: StringName, key: String, main: Node) -> String:
	var counts: Dictionary = {&"all":snapshot.entries.size(),&"active":0,&"completed":0}
	var visible: Array[Dictionary] = []
	var selected: Dictionary = {}
	for row: Dictionary in snapshot.entries:
		if counts.has(row.status):
			counts[row.status] += 1
		if filter==&"all" or row.status==filter:
			visible.append(row)
			if String(row.key)==key:
				selected = row
	if selected.is_empty() and not visible.is_empty():
		selected = visible[0]
	key = String(selected.get("key",""))
	book.filters.display(filter,counts)
	book.list.display(visible,key)
	book.detail.display(selected,main)
	var people: PackedStringArray = []
	for npc: Dictionary in snapshot.people:
		people.append(TranslationServer.translate(&"UI_NPC_FRIENDSHIP") % [TranslationServer.translate(StringName(npc.name_key)),int(npc.points),int(npc.maximum)])
	book.people.text = "\n".join(people)
	book.hint.text = TranslationServer.translate(&"BOOK_KEYS")
	return key
