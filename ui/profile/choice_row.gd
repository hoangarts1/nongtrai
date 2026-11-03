## LifeProfileChoiceRow — six native style/swatch choices; transient selection only.
class_name LifeProfileChoiceRow
extends VBoxContainer

signal selected_changed(index: int)
var selected: int = 0
var buttons: Array[Button] = []
var item_count: int:
	get:
		return buttons.size()
var _styles: PackedStringArray = []
var _colors: Array[Color] = []
var _key: StringName
var _caption: Label
var _grid: GridContainer

func _ready() -> void:
	_caption = LifeTitleParts.label(self,&"",&"LifeDayHeading")
	_grid = GridContainer.new()
	add_child(_grid)

func configure_styles(styles: PackedStringArray) -> void:
	_styles = styles.duplicate()
	_key = &"UI_APPEARANCE_HAIR_STYLE"
	_grid.columns = 3
	for index: int in range(styles.size()):
		var button: Button = LifeTitleParts.button(_grid,&"")
		button.toggle_mode = true
		button.clip_text = true
		button.pressed.connect(select.bind(index))
		buttons.append(button)
	_refresh()
	select(0)

func configure_colors(colors: Array[Color], key: StringName) -> void:
	_colors = colors.duplicate()
	_key = key
	_grid.columns = 6
	for index: int in range(colors.size()):
		var button: LifeProfileSwatch = preload("res://ui/profile/choice_swatch.tscn").instantiate() as LifeProfileSwatch
		button.paint = colors[index]
		_grid.add_child(button)
		button.pressed.connect(select.bind(index))
		buttons.append(button)
	_refresh()
	select(0)

func select(index: int) -> void:
	if buttons.is_empty():
		return
	var previous: int = selected
	selected = clampi(index,0,buttons.size()-1)
	for current: int in range(buttons.size()):
		buttons[current].set_pressed_no_signal(current == selected)
		buttons[current].theme_type_variation = &"LifePrimary" if current == selected else &"LifeSecondary"
		buttons[current].queue_redraw()
	if previous != selected:
		selected_changed.emit(selected)

func get_item_metadata(index: int) -> Variant:
	return _styles[index] if not _styles.is_empty() else index

func get_item_text(index: int) -> String:
	return tr("UI_APPEARANCE_HAIR_%s" % _styles[index].to_upper()) if not _styles.is_empty() else tr("UI_APPEARANCE_OPTION_NUMBER") % [tr(String(_key)),index+1]

func _refresh() -> void:
	_caption.text = tr(String(_key))
	for index: int in range(buttons.size()):
		buttons[index].tooltip_text = get_item_text(index)
		if not _styles.is_empty():
			buttons[index].text = get_item_text(index)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and not buttons.is_empty():
		_refresh()
