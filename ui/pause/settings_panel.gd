## LifeSettingsPanel — four settings pages with fixed native tabs/actions.
class_name LifeSettingsPanel
extends LifeHudFrame

signal applied()
signal defaulted()
var tabs: Array[Button] = []
var audio: LifeAudioSettings
var game: LifeGameSettings
var controls: LifeControlsHelp
var graphics: VBoxContainer
var apply_button: Button
var default_button: Button
var status: Label
var active_tab: int = 0
var _pages: Array[Control] = []
var _graphics_rows: Array[CheckButton] = []
var _graphics_note: Label
var _scroll: ScrollContainer
var _status_key: StringName = &"PAUSE_DRAFT_NOTE"
const TAB_KEYS: Array[StringName] = [&"PAUSE_AUDIO",&"PAUSE_GRAPHICS",&"PAUSE_CONTROLS",&"PAUSE_GAME"]
const GRAPHICS_KEYS: Array[StringName] = [&"PAUSE_FULLSCREEN",&"PAUSE_FONT_SIZE"]

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	var bar: HBoxContainer = HBoxContainer.new()
	column.add_child(bar)
	for index: int in range(TAB_KEYS.size()):
		var button: Button = LifePauseParts.button(bar,TAB_KEYS[index],&"LifeTab")
		button.toggle_mode = true
		button.pressed.connect(select_tab.bind(index))
		tabs.append(button)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_scroll)
	var body: VBoxContainer = LifeHudParts.column(_scroll)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	audio = preload("res://ui/pause/audio_settings.tscn").instantiate() as LifeAudioSettings
	body.add_child(audio)
	graphics = VBoxContainer.new()
	body.add_child(graphics)
	for key: StringName in GRAPHICS_KEYS:
		_graphics_rows.append(LifePauseParts.unavailable(graphics,key))
	_graphics_note = LifePauseParts.label(graphics,&"PAUSE_UNAVAILABLE",&"LifeText16")
	controls = preload("res://ui/pause/controls_help.tscn").instantiate() as LifeControlsHelp
	body.add_child(controls)
	game = preload("res://ui/pause/game_settings.tscn").instantiate() as LifeGameSettings
	body.add_child(game)
	_pages.assign([audio,graphics,controls,game])
	status = LifePauseParts.label(column,_status_key,&"LifeText16")
	var actions: HBoxContainer = HBoxContainer.new()
	column.add_child(actions)
	default_button = LifePauseParts.button(actions,&"PAUSE_DEFAULT")
	default_button.pressed.connect(func() -> void: defaulted.emit())
	apply_button = LifePauseParts.button(actions,&"PAUSE_APPLY",&"LifePrimary")
	apply_button.pressed.connect(func() -> void: applied.emit())
	select_tab(0)

func select_tab(index: int) -> void:
	active_tab = clampi(index,0,_pages.size()-1)
	for current: int in range(_pages.size()):
		_pages[current].visible = current == active_tab
		tabs[current].set_pressed_no_signal(current == active_tab)
		tabs[current].theme_type_variation = &"LifePrimary" if current == active_tab else &"LifeSecondary"
	_scroll.scroll_vertical = 0

func show_status(key: StringName) -> void:
	_status_key = key
	status.text = tr(String(key))

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and status != null:
		for index: int in range(tabs.size()):
			tabs[index].text = tr(String(TAB_KEYS[index]))
		for index: int in range(_graphics_rows.size()):
			LifePauseParts.refresh_unavailable(_graphics_rows[index],GRAPHICS_KEYS[index])
		_graphics_note.text = tr("PAUSE_UNAVAILABLE")
		default_button.text = tr("PAUSE_DEFAULT")
		apply_button.text = tr("PAUSE_APPLY")
		status.text = tr(String(_status_key))
