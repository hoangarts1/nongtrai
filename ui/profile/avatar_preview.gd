## LifeProfileAvatarPreview — actual2D player renderer in a decorative UI stage.
class_name LifeProfileAvatarPreview
extends VBoxContainer

signal hair_cycled(direction: int)
var avatar: PlaceholderAvatar2D
var stage: Control
var previous_button: Button
var next_button: Button
var player_caption: Label
var farm_caption: Label
var style_caption: Label
var _selection: Dictionary = {}
var _player: String = ""
var _farm: String = ""

class GardenStage extends Control:
	func _draw() -> void:
		var sky: Color = get_theme_color(&"sky",&"LifeTokens")
		var green: Color = get_theme_color(&"green",&"LifeTokens")
		var paper: Color = get_theme_color(&"paper",&"LifeTokens")
		draw_rect(Rect2(Vector2.ZERO,size),sky.lightened(0.35))
		draw_rect(Rect2(Vector2(0,size.y*0.57),Vector2(size.x,size.y*0.43)),green.lightened(0.15))
		draw_circle(Vector2(size.x*0.12,size.y*0.63),size.x*0.35,green.lightened(0.3),true,-1,true)
		draw_circle(Vector2(size.x*0.85,size.y*0.67),size.x*0.32,green.lightened(0.23),true,-1,true)
		draw_circle(Vector2(size.x*0.20,size.y*0.18),18,paper,true,-1,true)
		draw_circle(Vector2(size.x*0.26,size.y*0.18),24,paper,true,-1,true)

func _ready() -> void:
	var frame: LifeHudFrame = LifeProfileParts.frame(self)
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage = GardenStage.new()
	stage.custom_minimum_size = Vector2(200,220)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.clip_contents = true
	frame.add_child(stage)
	avatar = PlaceholderAvatar2D.new()
	stage.add_child(avatar)
	previous_button = LifeTitleParts.button(stage,&"PROFILE_PREVIOUS")
	next_button = LifeTitleParts.button(stage,&"PROFILE_NEXT")
	previous_button.size_flags_horizontal = Control.SIZE_FILL
	next_button.size_flags_horizontal = Control.SIZE_FILL
	previous_button.pressed.connect(func() -> void: hair_cycled.emit(-1))
	next_button.pressed.connect(func() -> void: hair_cycled.emit(1))
	stage.resized.connect(_layout)
	var hint_plate: PanelContainer = PanelContainer.new()
	hint_plate.theme_type_variation = &"LifeKeyHint"
	add_child(hint_plate)
	style_caption = LifeTitleParts.label(hint_plate,&"",&"LifeText16")
	style_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var name_plate: PanelContainer = PanelContainer.new()
	name_plate.theme_type_variation = &"LifeKeyHint"
	add_child(name_plate)
	player_caption = LifeProfileParts.caption(name_plate)
	var farm_plate: PanelContainer = PanelContainer.new()
	farm_plate.theme_type_variation = &"LifeKeyHint"
	add_child(farm_plate)
	farm_caption = LifeProfileParts.caption(farm_plate)
	display({},"","")

func _layout() -> void:
	avatar.position = Vector2(stage.size.x*0.5,stage.size.y*0.9)
	avatar.scale = Vector2.ONE*minf(stage.size.x/60.0,stage.size.y/72.0)
	previous_button.position = Vector2(8,(stage.size.y-44)*0.5)
	next_button.position = Vector2(stage.size.x-60,(stage.size.y-44)*0.5)
	previous_button.size = Vector2(52,44)
	next_button.size = Vector2(52,44)
	stage.queue_redraw()

func display(selection: Dictionary, player_text: String, farm_text: String) -> void:
	_selection = selection.duplicate(true)
	_player = player_text
	_farm = farm_text
	var normalized: Dictionary = LifeProfileChoices.CATALOG.call("normalize_player_customization",selection)
	avatar.configure_profile({},normalized)
	player_caption.text = player_text if not player_text.is_empty() else tr("UI_DEFAULT_PLAYER")
	farm_caption.text = farm_text if not farm_text.is_empty() else tr("UI_DEFAULT_FARM")
	player_caption.tooltip_text = player_caption.text
	farm_caption.tooltip_text = farm_caption.text
	style_caption.text = tr("PROFILE_CYCLE_HINT") % tr("UI_APPEARANCE_HAIR_%s" % String(normalized.hair_style).to_upper())
	previous_button.tooltip_text = tr("PROFILE_PREV_HAIR")
	next_button.tooltip_text = tr("PROFILE_NEXT_HAIR")

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and farm_caption != null:
		previous_button.text = tr("PROFILE_PREVIOUS")
		next_button.text = tr("PROFILE_NEXT")
		display(_selection,_player,_farm)
