## Localized, detached presentation only. Translation keys are validated at startup.
class_name LifeStoryPresenter
extends RefCounted
const KEYS: PackedStringArray = ["STORY_ENTRY","STORY_BACK","STORY_PROGRESS","STORY_OBJECTIVES","STORY_MILESTONES","STORY_DONE","STORY_READY","STORY_PLANNED","STORY_WAITING","STORY_KEYS","STORY_PAGES","STORY_READ","STORY_UNREAD","STORY_LOCKED","STORY_PAGE_LINK","STORY_CONFIRM","STORY_CANCEL","STORY_STALE"]
static func text(key: StringName) -> String:
	return TranslationServer.translate(key)
static func describe(snapshot: Dictionary) -> Dictionary:
	if not bool(snapshot.get("ok",false)): return {"ok":false,"message":text(&"STORY_WAITING")}
	var result: Dictionary = snapshot.duplicate(true)
	result.title = text(StringName(snapshot.title_key))
	result.description = text(StringName(snapshot.description_key))
	result.progress = text(&"STORY_PROGRESS") % [snapshot.done_count,snapshot.total_count]
	for field: String in ["objectives","milestones"]:
		for row: Dictionary in result[field]:
			row.title = text(StringName(row.title_key))
			row.description = text(StringName(row.description_key))
			row.status = text(&"STORY_PLANNED" if row.planned else (&"STORY_DONE" if row.done else &"STORY_READY"))
	for page: Dictionary in result.pages:
		page.title = text(StringName(page.title_key))
		page.body = text(StringName(page.body_key)) if page.available else ""
		page.status = text(&"STORY_LOCKED" if not page.available else (&"STORY_READ" if page.read else &"STORY_UNREAD"))
	return result
