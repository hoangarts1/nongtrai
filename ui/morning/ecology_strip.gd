## LifeMorningEcologyStrip — actual ecology estimates/counts after committed rollover.
class_name LifeMorningEcologyStrip
extends PanelContainer

var heading: Label
var summary: Label
var water_label: Label
var water_value: Label
var counts: HBoxContainer
var trees: Label
var species: Label

func _ready() -> void:
	LifeTheme.bind(self, &"LifeKeyHint")
	var column: VBoxContainer = VBoxContainer.new()
	add_child(column)
	var row: HBoxContainer = HBoxContainer.new()
	column.add_child(row)
	heading = LifeTitleParts.label(row, &"ECO_NEWS_TITLE", &"LifeText16")
	heading.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	heading.autowrap_mode = TextServer.AUTOWRAP_OFF
	summary = LifeTitleParts.label(row, &"", &"LifeText16")
	water_label = LifeTitleParts.label(row, &"ECO_WATER", &"LifeSecondaryText")
	water_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	water_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	water_value = LifeTitleParts.label(row, &"ECO_UNMEASURED", &"LifeText16")
	water_value.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	water_value.autowrap_mode = TextServer.AUTOWRAP_OFF
	counts = HBoxContainer.new()
	column.add_child(counts)
	trees = LifeTitleParts.label(counts, &"", &"LifeText16")
	species = LifeTitleParts.label(counts, &"", &"LifeText16")
	trees.mouse_filter = Control.MOUSE_FILTER_PASS
	species.mouse_filter = Control.MOUSE_FILTER_PASS

func display(snapshot: Dictionary) -> void:
	var model: Dictionary = EcologyPresenter.describe(snapshot)
	heading.text = tr("ECO_NEWS_TITLE")
	water_label.text = tr("ECO_WATER")
	water_value.text = tr("ECO_UNMEASURED")
	counts.visible = bool(model.get("ok", false))
	if not counts.visible:
		summary.text = String(model.get("message", tr("ECO_WAITING")))
		trees.text = ""
		species.text = ""
		trees.tooltip_text = ""
		species.tooltip_text = ""
		return
	summary.text = String(model.news_summary)
	for value: Dictionary in model.rows:
		if value.id == "tree_cover" or value.id == "biodiversity":
			var label: Label = trees if value.id == "tree_cover" else species
			label.text = String(value.source_text)
			label.tooltip_text = "\n".join(PackedStringArray([value.target_text, value.ease_text, value.hint]))
