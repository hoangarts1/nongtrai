## LifeUiGallery — standalone localized component/state review; no gameplay controllers.
## API:
##   func get_sections() -> Dictionary
##   func rebuild() -> void
class_name LifeUiGallery
extends Control

const COMPONENTS: Dictionary = {
	"panel": preload("res://ui/components/panel_wood.tscn"),
	"banner": preload("res://ui/components/banner.tscn"),
	"primary": preload("res://ui/components/btn_primary.tscn"),
	"secondary": preload("res://ui/components/btn_secondary.tscn"),
	"danger": preload("res://ui/components/btn_danger.tscn"),
	"accent": preload("res://ui/components/btn_accent.tscn"),
	"round": preload("res://ui/components/btn_round_hud.tscn"),
	"slot": preload("res://ui/components/item_slot.tscn"),
	"progress": preload("res://ui/components/progress_bar_styled.tscn"),
	"toggle": preload("res://ui/components/toggle_on_off.tscn"),
	"slider": preload("res://ui/components/slider_styled.tscn"),
	"hearts": preload("res://ui/components/heart_row.tscn"),
	"hint": preload("res://ui/components/key_hint.tscn"),
	"pill": preload("res://ui/components/pill.tscn"),
	"tag": preload("res://ui/components/tag.tscn"),
	"coins": preload("res://ui/components/coin_label.tscn"),
	"tabs": preload("res://ui/components/tab_bar.tscn"),
	"icon": preload("res://ui/components/icon_placeholder.tscn")
}
var _content: VBoxContainer
var _sections_grid: GridContainer
var _scroll: ScrollContainer
var _sections: Dictionary = {}

func _ready() -> void:
	name = "UIGallery"
	LifeTheme.bind(self)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(_reflow)
	rebuild()
	if OS.get_cmdline_user_args().has("--capture-ui-gallery"):
		call_deferred("_capture")

func get_sections() -> Dictionary:
	return _sections.duplicate()

func rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_sections.clear()
	var background: ColorRect = ColorRect.new()
	background.name = "Background"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = get_theme_color(&"wood",&"LifeTokens").darkened(0.3)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin: MarginContainer = MarginContainer.new()
	margin.name = "Margin"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.theme_type_variation = &"LifeGalleryMargin"
	add_child(margin)
	_scroll = ScrollContainer.new()
	_scroll.name = "Scroll"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(_scroll)
	_content = VBoxContainer.new()
	_content.name = "Content"
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.theme_type_variation = &"LifeGalleryColumn"
	_scroll.add_child(_content)
	var banner: LifeBanner = _instance("banner",_content) as LifeBanner
	banner.set_caption(&"UI_KIT_TITLE")
	_label(_content,&"UI_KIT_SAMPLES",&"LifeSecondaryText")
	_sections_grid = GridContainer.new()
	_sections_grid.name = "Sections"
	_sections_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sections_grid.theme_type_variation = &"LifeGalleryGrid"
	_content.add_child(_sections_grid)
	_build_buttons(_section("buttons",&"UI_KIT_BUTTONS"))
	_build_slots(_section("slots",&"UI_KIT_ITEMS"))
	_build_tokens(_section("tokens",&"UI_KIT_COLORS"))
	_build_inputs(_section("inputs",&"UI_KIT_INPUTS"))
	_build_badges(_section("badges",&"UI_KIT_BADGES"))
	_build_fonts(_section("fonts",&"UI_KIT_FONTS"))
	_build_icons(_section("icons",&"UI_KIT_ICONS"))
	var frame: VBoxContainer = _section("frame",&"UI_KIT_FRAME")
	var nested: PanelContainer = _instance("panel",frame) as PanelContainer
	_label(nested,&"UI_KIT_FRAME_NOTE",&"LifeSecondaryText")
	var tabs: VBoxContainer = _section("tabs",&"UI_KIT_TABS",_content)
	_instance("tabs",tabs)
	_reflow()

func _section(id: String, title: StringName, parent: Node = null) -> VBoxContainer:
	var panel: LifePanelWood = _instance("panel",parent if parent != null else _sections_grid) as LifePanelWood
	panel.name = "Section_"+id
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var column: VBoxContainer = VBoxContainer.new()
	column.name = "Content"
	column.theme_type_variation = &"LifeGalleryColumn"
	panel.add_child(column)
	_label(column,title,&"LifeHeading")
	_sections[id] = panel
	return column

func _instance(id: String, parent: Node) -> Control:
	var scene: PackedScene = COMPONENTS[id] as PackedScene
	var component: Control = scene.instantiate() as Control
	parent.add_child(component)
	return component

func _label(parent: Node, key: StringName, variation: StringName = &"") -> Label:
	var label: Label = Label.new()
	label.text = tr(String(key))
	label.theme_type_variation = variation
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func _build_buttons(parent: Node) -> void:
	for kind: String in ["primary","secondary","danger","accent"]:
		_label(parent,StringName("UI_KIT_"+kind.to_upper()),&"LifeSmall")
		var grid: GridContainer = GridContainer.new()
		grid.columns = 2
		grid.theme_type_variation = &"LifeGalleryGrid"
		parent.add_child(grid)
		for state: StringName in [&"normal",&"hover",&"pressed",&"disabled"]:
			var button: LifeButtonBase = _instance(kind,grid) as LifeButtonBase
			button.name = "%s_%s" % [kind,state]
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.set_caption(StringName("UI_KIT_STATE_"+String(state).to_upper()))
			button.set_preview_state(state)

func _build_slots(parent: Node) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	parent.add_child(row)
	for index: int in range(4):
		var slot: LifeItemSlot = _instance("slot",row) as LifeItemSlot
		slot.name = "Slot_%d" % index
		if index > 0:
			slot.set_item(&"spring_carrot",7,&"ITEM_SPRING_CARROT")
		slot.set_state(index as LifeItemSlot.SlotState)
	for tone: StringName in [&"green",&"blue",&"gold"]:
		var bar: LifeProgressBar = _instance("progress",parent) as LifeProgressBar
		bar.set_tone(tone)
		bar.set_displayed_value(78 if tone==&"green" else (45 if tone==&"blue" else 30),100)
	for count: int in [0,3,5]:
		var hearts: LifeHeartRow = _instance("hearts",parent) as LifeHeartRow
		hearts.set_hearts(count)

func _build_inputs(parent: Node) -> void:
	for enabled: bool in [true,false]:
		var toggle: LifeToggle = _instance("toggle",parent) as LifeToggle
		toggle.button_pressed = enabled
	for value: float in [30,70]:
		var slider: LifeSlider = _instance("slider",parent) as LifeSlider
		slider.value = value
	var row: GridContainer = GridContainer.new()
	row.columns = 3
	parent.add_child(row)
	for action: StringName in [&"open_inventory",&"open_journal",&"pause"]:
		var button: LifeBtnRoundHud = _instance("round",row) as LifeBtnRoundHud
		button.set_hint(action)

func _build_badges(parent: Node) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	parent.add_child(row)
	for action: StringName in [&"interact",&"rotate_ccw",&"pause"]:
		var hint: LifeKeyHint = _instance("hint",row) as LifeKeyHint
		hint.set_action(action)
	var pill: LifePill = _instance("pill",parent) as LifePill
	pill.set_value(3)
	var coins: LifeCoinLabel = _instance("coins",parent) as LifeCoinLabel
	coins.set_coins(1240)
	_instance("tag",parent)
	var main: LifeTag = COMPONENTS["tag"].instantiate() as LifeTag
	main.tone = &"main"
	main.text_key = &"UI_KIT_MAIN"
	parent.add_child(main)

func _build_tokens(parent: Node) -> void:
	for token: StringName in [&"ink",&"wood",&"paper",&"green",&"yellow",&"red",&"sky",&"coin"]:
		var row: HBoxContainer = HBoxContainer.new()
		parent.add_child(row)
		var swatch: ColorRect = ColorRect.new()
		swatch.custom_minimum_size = Vector2(36,28)
		swatch.color = get_theme_color(token,&"LifeTokens")
		row.add_child(swatch)
		var label: Label = Label.new()
		label.text = "%s · #%s" % [tr("UI_KIT_TOKEN_"+String(token).to_upper()),swatch.color.to_html(false).to_upper()]
		label.theme_type_variation = &"LifeSmall"
		row.add_child(label)

func _build_fonts(parent: Node) -> void:
	_label(parent,&"UI_GAME_TITLE",&"LifeTitle")
	_label(parent,&"UI_KIT_VI_SAMPLE",&"LifeText18")
	_label(parent,&"UI_KIT_VI_SAMPLE",&"LifeSecondaryText")
	_label(parent,&"UI_KIT_FONT_NOTE",&"LifeSmall")
	for tone: StringName in [&"green",&"red",&"blue"]:
		var banner: LifeBanner = _instance("banner",parent) as LifeBanner
		banner.set_caption(&"UI_KIT_BANNER")
		banner.set_tone(tone)
		banner.caption.theme_type_variation = &"LifeHeading"

func _build_icons(parent: Node) -> void:
	var grid: GridContainer = GridContainer.new()
	grid.columns = 4
	grid.theme_type_variation = &"LifeGalleryGrid"
	parent.add_child(grid)
	for id: String in ["COIN","HEART","ENERGY","SUN","RAIN","MOON","HOE","WATER","SICKLE","BASKET","CARROT","TOMATO","TURNIP","CORN","PUMPKIN","WOOD","STONE","STRAW","BAG","QUEST","CALENDAR","MAP","MARKET","GIFT"]:
		var cell: VBoxContainer = VBoxContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(cell)
		var icon: LifeIconPlaceholder = _instance("icon",cell) as LifeIconPlaceholder
		icon.text_key = StringName("UI_KIT_ICON_"+id)
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_label(cell,icon.text_key,&"LifeSmall")

func _reflow() -> void:
	if _sections_grid != null:
		_sections_grid.columns = 3 if size.x >= 1000 else (2 if size.x >= 700 else 1)

func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		printerr("[ui_gallery] a graphics renderer is required")
		get_tree().quit(1)
		return
	for frame: int in range(8):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	for mode: String in ["top","middle","bottom"]:
		_scroll.scroll_vertical = 0 if mode=="top" else int(_scroll.get_v_scroll_bar().max_value * (0.5 if mode=="middle" else 1.0))
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var path: String = "user://ui_gallery_%s_%d_%s.png" % [TranslationServer.get_locale(),int(size.x),mode]
		var image: Image = get_viewport().get_texture().get_image()
		if image == null or image.is_empty() or image.save_png(path) != OK:
			printerr("[ui_gallery] capture failed")
			get_tree().quit(1)
			return
		print("[ui_gallery] wrote "+ProjectSettings.globalize_path(path))
	get_tree().quit()
