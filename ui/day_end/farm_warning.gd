## LifeDayFarmWarning — actual unwatered plots, no invented wither countdown.
class_name LifeDayFarmWarning
extends PanelContainer

var caption: Label

func _ready() -> void:
	LifeTheme.bind(self,&"LifeDayWarning")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption = LifeDayEndParts.wrapped(self,&"LifeDayWarningText")

func display(count: int, forced: bool = false) -> void:
	visible = count > 0
	caption.text = tr("END_UNWATERED_FORCED" if forced else "END_UNWATERED") % count
