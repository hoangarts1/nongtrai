## LifeHudQuestCard — pinned checklist, never invents quest amounts or rewards.
class_name LifeHudQuestCard
extends PanelContainer

var rows: VBoxContainer
var progress: Label
var title: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeHudQuest")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var column: VBoxContainer = LifeHudParts.column(self)
	var header: HBoxContainer = HBoxContainer.new()
	column.add_child(header)
	LifeHudParts.texture(header,UiIcons.get_icon(&"journal"),26)
	title = LifeHudParts.label(header,&"LifeHudHeading")
	title.text = tr("HUD_QUEST_TITLE")
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress = LifeHudParts.label(column,&"LifeSmall")
	rows = LifeHudParts.column(column)
	queue_redraw()

func display(keys: Array[StringName], completed: Array[bool]) -> void:
	if rows == null:
		return
	for child: Node in rows.get_children():
		rows.remove_child(child)
		child.free()
	var count: int = completed.count(true)
	title.text = tr("HUD_QUEST_TITLE")
	progress.text = tr("HUD_QUEST_PROGRESS") % [count,keys.size()]
	var first: int = completed.find(false)
	first = maxi(0,mini(first,keys.size()-3))
	for index: int in range(first,mini(first+3,keys.size())):
		var row: HBoxContainer = HBoxContainer.new()
		rows.add_child(row)
		var mark: Label = LifeHudParts.label(row,&"LifeHudCheck" if completed[index] else &"LifeHudHeading")
		mark.text = "✓" if completed[index] else "□"
		mark.custom_minimum_size.x = 24
		var label: Label = LifeHudParts.label(row,&"LifeHudBody")
		label.text = tr(String(keys[index]))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.custom_minimum_size.y = 35

func _draw() -> void:
	var ink: Color = get_theme_color(&"ink",&"LifeTokens")
	var pin: Vector2 = Vector2(size.x*0.5,5)
	draw_circle(pin,8,ink,true,-1,true)
	draw_circle(pin-Vector2(0,1),5,get_theme_color(&"red",&"LifeTokens"),true,-1,true)
