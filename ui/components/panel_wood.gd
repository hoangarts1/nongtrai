## LifePanelWood — reusable wood/paper frame; caller owns its content.
class_name LifePanelWood
extends PanelContainer

func _ready() -> void:
	LifeTheme.bind(self,&"LifeWood")
