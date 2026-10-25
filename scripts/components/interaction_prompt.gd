## InteractionPrompt — reusable UI prompt for nearby interactions.
## API:
##   func show_prompt(prompt_text: String) -> void
##   func hide_prompt() -> void
class_name InteractionPrompt
extends PanelContainer

@onready var message_label: Label = $Message

func _ready() -> void:
	hide_prompt()

func show_prompt(prompt_text: String) -> void:
	message_label.text = prompt_text
	show()

func hide_prompt() -> void:
	message_label.text = ""
	hide()
