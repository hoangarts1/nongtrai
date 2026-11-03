## LifeInventoryScreen — reference-06 composition of small read-only Controls.
class_name LifeInventoryScreen
extends VBoxContainer

var tabs: LifeInventoryTabs
var filters: LifeInventoryFilters
var items: LifeInventoryGrid
var detail: LifeInventoryDetail
var discard: LifeInventoryDiscard
var footer: LifeInventoryFooter
var body: HBoxContainer

func _ready() -> void:
	LifeTheme.bind(self,&"LifeInvColumn")
	tabs = preload("res://ui/inventory/common_tabs.tscn").instantiate() as LifeInventoryTabs
	add_child(tabs)
	var frame: LifeHudFrame = LifeHudFrame.new()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(frame)
	var paper: PanelContainer = PanelContainer.new()
	paper.theme_type_variation = &"LifeHudPaper"
	frame.add_child(paper)
	body = HBoxContainer.new()
	body.theme_type_variation = &"LifeInvColumns"
	paper.add_child(body)
	var left: VBoxContainer = LifeHudParts.column(body)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.6
	filters = preload("res://ui/inventory/filter_bar.tscn").instantiate() as LifeInventoryFilters
	left.add_child(filters)
	items = preload("res://ui/inventory/item_grid.tscn").instantiate() as LifeInventoryGrid
	left.add_child(items)
	footer = preload("res://ui/inventory/capacity_footer.tscn").instantiate() as LifeInventoryFooter
	left.add_child(footer)
	var right: PanelContainer = PanelContainer.new()
	right.theme_type_variation = &"LifeInvInset"
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	detail = preload("res://ui/inventory/detail_card.tscn").instantiate() as LifeInventoryDetail
	right.add_child(detail)
	discard = preload("res://ui/inventory/discard_prompt.tscn").instantiate() as LifeInventoryDiscard
	right.add_child(discard)
