## LifeMorningTasks — fixed informational counts, no automatic actions.
class_name LifeMorningTasks
extends PanelContainer

var heading: Label
var harvest: Label
var water: Label
var sow: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeKeyHint")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)
	heading = LifeTitleParts.label(row,&"NEWS_TASKS",&"LifeDayHeading")
	harvest = LifeTitleParts.label(row,&"",&"LifeText16")
	water = LifeTitleParts.label(row,&"",&"LifeText16")
	sow = LifeTitleParts.label(row,&"",&"LifeText16")

func display(ready: int, needs_water: int, empty: int) -> void:
	heading.text = tr("NEWS_TASKS")
	harvest.text = tr("NEWS_READY") % ready
	water.text = tr("NEWS_WATER") % needs_water
	sow.text = tr("NEWS_EMPTY") % empty
