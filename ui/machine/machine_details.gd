## LifeMachineDetails — selected machine/recipe preview from a detached snapshot.
class_name LifeMachineDetails
extends ScrollContainer

var preview: TextureRect
var title: Label
var state: Label
var terms: Label
var output: Label
var requirement: Label

func _ready() -> void:
	custom_minimum_size.x = 270
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var frame: PanelContainer = PanelContainer.new()
	frame.theme_type_variation = &"LifeInvInset"
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(frame)
	var column: VBoxContainer = LifeHudParts.column(frame)
	preview = LifeHudParts.texture(column,null,128)
	preview.custom_minimum_size.y = 144
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	title = LifeMachinePresenter.label(column,&"LifeInvTitle")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state = LifeMachinePresenter.label(column,&"LifeDayHeading")
	# Buffered goods stay above longer requirements/recipe text at the smallest size.
	output = LifeMachinePresenter.label(column,&"LifeDayHeading")
	requirement = LifeMachinePresenter.label(column,&"LifeSecondaryText")
	terms = LifeMachinePresenter.label(column)

func display(model: Dictionary, operation_mode: bool) -> void:
	preview.texture = model.texture as Texture2D
	title.text = tr(String(model.name))
	state.text = LifeMachinePresenter.state_text(model) if operation_mode else tr("MUI_MACHINE_PREVIEW")
	requirement.text = tr("MUI_REQUIREMENT") % [int(model.level),int(model.owned)]
	requirement.text += "\n"+tr("MUI_TEST_LEVEL")
	if operation_mode:
		requirement.text += "\n"+tr("MUI_PLACEMENT") % model.cell
	var recipe: Dictionary = model.recipe
	terms.text = tr("MUI_RECIPE_TERMS").replace("\\n","\n") % [LifeMachinePresenter.entries(recipe.inputs),LifeMachinePresenter.entries(recipe.outputs),int(recipe.days)]
	output.text = tr("UI_MACHINE_OUTPUT") % [LifeMachinePresenter.item_name(StringName(model.output_id)),int(model.output_quantity)] if int(model.output_quantity)>0 else ""
	output.visible = int(model.output_quantity)>0
