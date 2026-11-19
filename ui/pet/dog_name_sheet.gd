## LifeDogNameSheet - shared paper/frame composition, no persistent state.
class_name LifeDogNameSheet
extends PanelContainer
var form: LifeDogNameForm
func _ready() -> void:
	hide()
	LifeTheme.bind(self, &"LifeHudPaper")
	form = preload("res://ui/pet/dog_name_form.tscn").instantiate() as LifeDogNameForm
	add_child(form)
