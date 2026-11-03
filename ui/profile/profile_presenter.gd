## LifeProfilePresenter — draft-to-preview bindings only.
class_name LifeProfilePresenter
extends RefCounted

var _form: LifeTitleProfileForm

func configure(form: LifeTitleProfileForm) -> void:
	_form = form
	form.names.changed.connect(refresh)
	form.choices.changed.connect(refresh)
	form.preview.hair_cycled.connect(cycle)
	refresh()

func refresh(_value: Variant = null) -> void:
	_form.preview.display(_form.get_selection(),_form.player_name.text,_form.farm_name.text)

func cycle(direction: int) -> void:
	var row: LifeProfileChoiceRow = _form.hair_style
	row.select(posmod(row.selected+direction,row.item_count))
