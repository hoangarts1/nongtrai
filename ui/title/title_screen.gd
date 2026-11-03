## LifeTitleScreen — reference01 composition and three view-only modes.
class_name LifeTitleScreen
extends LifeHudFrame

enum Mode { TITLE, PROFILE, SETTINGS }
var logo: Label
var tagline: Label
var version: Label
var hint: Label
var latest: LifeLatestSaveCard
var actions: LifeTitleActions
var profile: LifeTitleProfileForm
var settings: LifeTitleSettings
var mode: Mode = Mode.TITLE
var _space: Control
var _version_value: String = ""

func _ready() -> void:
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	var column: VBoxContainer = LifePauseParts.paper(self)
	var banner: PanelContainer = PanelContainer.new()
	banner.theme_type_variation = &"LifeBannerGreen"
	column.add_child(banner)
	logo = LifeTitleParts.label(banner,&"UI_GAME_TITLE",&"LifeTitle")
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline = LifeTitleParts.label(column,&"UI_TITLE_TAGLINE",&"LifeSecondaryText")
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	latest = preload("res://ui/title/latest_save_card.tscn").instantiate() as LifeLatestSaveCard
	column.add_child(latest)
	actions = preload("res://ui/title/title_actions.tscn").instantiate() as LifeTitleActions
	column.add_child(actions)
	profile = preload("res://ui/title/profile_form.tscn").instantiate() as LifeTitleProfileForm
	profile.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(profile)
	settings = preload("res://ui/title/title_settings.tscn").instantiate() as LifeTitleSettings
	settings.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(settings)
	_space = Control.new()
	_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_space)
	var footer: HBoxContainer = HBoxContainer.new()
	column.add_child(footer)
	version = LifeTitleParts.label(footer,&"",&"LifeText16")
	hint = LifeTitleParts.label(footer,&"TITLE_NAV_HINT",&"LifeText16")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	set_mode(Mode.TITLE)

func set_mode(value: Mode) -> void:
	mode = value
	tagline.visible = mode == Mode.TITLE
	latest.visible = mode == Mode.TITLE
	actions.visible = mode == Mode.TITLE
	_space.visible = mode == Mode.TITLE
	profile.visible = mode == Mode.PROFILE
	settings.visible = mode == Mode.SETTINGS

func display_version(value: String) -> void:
	_version_value = value
	version.visible = not value.is_empty()
	version.text = tr("TITLE_VERSION") % value

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and hint != null:
		logo.text = tr("UI_GAME_TITLE").to_upper()
		tagline.text = tr("UI_TITLE_TAGLINE")
		hint.text = tr("TITLE_NAV_HINT")
		display_version(_version_value)
