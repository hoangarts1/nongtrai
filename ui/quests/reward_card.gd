## LifeQuestReward — current Resource terms only, never a payout button.
class_name LifeQuestReward
extends PanelContainer

var coins: Label
var item: Label
var note: Label
var icon: TextureRect

func _ready() -> void:
	theme_type_variation = &"LifeKeyHint"
	var body: VBoxContainer = LifeHudParts.column(self)
	coins = LifeTitleParts.label(body,&"",&"LifeDayHeading")
	var row: HBoxContainer = HBoxContainer.new()
	body.add_child(row)
	icon = LifeHudParts.texture(row,null)
	icon.custom_minimum_size = Vector2(32,32)
	item = LifeTitleParts.label(row,&"")
	note = LifeTitleParts.label(body,&"",&"LifeText16")

func display(row: Dictionary) -> void:
	coins.visible = int(row.get("coins",0))>0
	coins.text = tr("UI_WALLET_COINS") % int(row.get("coins",0))
	var id: StringName = StringName(row.get("reward_item",&""))
	var data: Resource = DataRegistry.get_item(id)
	item.visible = data!=null and int(row.get("reward_quantity",0))>0
	icon.visible = item.visible
	if item.visible:
		item.text = tr("BOOK_ITEM_REWARD") % [tr(String(data.get("display_name_key"))),int(row.reward_quantity)]
		icon.texture = LifeInventoryIcon.for_item(id)
	note.text = tr("BOOK_REWARD_TERMS" if coins.visible or item.visible else "BOOK_NO_REWARD")
