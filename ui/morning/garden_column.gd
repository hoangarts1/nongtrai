## LifeMorningGarden — real onboarding/farm snapshot, no event calendar.
class_name LifeMorningGarden
extends VBoxContainer

var heading: Label
var scroll: ScrollContainer
var body: VBoxContainer
var progress: Label
var hints: Label
var status: Label
var unavailable: Label

func _ready() -> void:
	heading = LifeTitleParts.label(self,&"NEWS_TODAY",&"LifeDayHeading")
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	body = LifeHudParts.column(scroll)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress = LifeTitleParts.label(body,&"",&"LifeDayHeading")
	hints = LifeTitleParts.label(body,&"")
	status = LifeTitleParts.label(body,&"")
	unavailable = LifeTitleParts.label(body,&"NEWS_EVENTS_UNAVAILABLE",&"LifeText16")

func display(snapshot: Dictionary) -> void:
	heading.text = tr("NEWS_TODAY")
	progress.text = tr("NEWS_QUEST_PROGRESS") % [int(snapshot.completed),int(snapshot.total)]
	var lines: PackedStringArray = []
	for key: StringName in snapshot.quests:
		if lines.size() >= 3:
			break
		lines.append("• "+tr(String(key)))
	hints.text = "\n".join(lines) if not lines.is_empty() else tr("NEWS_QUEST_DONE")
	status.text = tr("NEWS_GARDEN_STATUS") % [int(snapshot.ready),int(snapshot.water),int(snapshot.empty),int(snapshot.withered)]
	unavailable.text = tr("NEWS_EVENTS_UNAVAILABLE")
