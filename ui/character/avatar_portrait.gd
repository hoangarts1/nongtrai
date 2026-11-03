## LifeCharacterPortrait — shared actual2D renderer, read-only cosmetics.
class_name LifeCharacterPortrait
extends PanelContainer

const CATALOG: CharacterAppearanceCatalog = preload("res://data/art/characters/chibi_character_catalog.tres")
var avatar: PlaceholderAvatar2D
var stage: Control

class PortraitStage extends Control:
	func _draw() -> void:
		var sky: Color = get_theme_color(&"sky",&"LifeTokens")
		var green: Color = get_theme_color(&"green",&"LifeTokens")
		draw_rect(Rect2(Vector2.ZERO,size),sky.lightened(0.45))
		draw_rect(Rect2(Vector2(0,size.y*0.65),Vector2(size.x,size.y*0.35)),green.lightened(0.25))

func _ready() -> void:
	theme_type_variation = &"LifeInvInset"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage = PortraitStage.new()
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.clip_contents = true
	stage.custom_minimum_size = Vector2(64,72)
	add_child(stage)
	avatar = PlaceholderAvatar2D.new()
	stage.add_child(avatar)
	stage.resized.connect(_layout)

func _layout() -> void:
	avatar.position = Vector2(stage.size.x*0.5,stage.size.y*0.92)
	avatar.scale = Vector2.ONE*minf(stage.size.x/60.0,stage.size.y/72.0)
	stage.queue_redraw()

func display_player(selection: Dictionary) -> void:
	avatar.configure_profile({},CATALOG.normalize_player_customization(selection))

func display_npc(id: StringName, fallback: Color) -> void:
	var recipe: Resource = CATALOG.get_npc_appearance(id)
	if recipe != null:
		avatar.configure_profile(recipe.call("to_builder_dictionary"))
	else:
		avatar.configure(fallback)
