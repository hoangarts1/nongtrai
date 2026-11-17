## LifeMachinePresenter — shared-theme construction and localized snapshot formatting.
class_name LifeMachinePresenter
extends RefCounted

static var _textures: Dictionary = {}

const REASONS: Dictionary = {
	&"collection_busy": &"UI_MACHINE_COLLECT_BUSY", &"invalid_state": &"PLC_INVALID",
	&"no_machine": &"UI_MACHINE_COLLECT_NO_MACHINE", &"no_output": &"UI_MACHINE_COLLECT_NO_OUTPUT",
	&"unknown_item": &"UI_MACHINE_COLLECT_UNKNOWN", &"inventory_full": &"UI_MACHINE_COLLECT_FULL",
	&"transfer_failed": &"UI_MACHINE_COLLECT_FAILED", &"house_level_locked": &"MUI_LOCKED",
	&"insufficient_coins": &"MUI_NO_COINS", &"missing_input": &"MUI_MISSING_INPUT",
	&"machine_busy": &"MUI_BUSY", &"machine_not_owned": &"MUI_NOT_OWNED",
	&"cell_unavailable": &"MUI_NO_CELL", &"purchased": &"MUI_PURCHASED",
	&"placed": &"MUI_PLACED", &"started": &"MUI_STARTED", &"removed": &"PLC_RETURNED",
	&"outside_build_region": &"PLC_REGION", &"player_occupied": &"PLC_PLAYER",
	&"out_of_reach": &"PLC_FAR", &"plot_occupied": &"PLC_PLOT",
	&"stale_source": &"PLC_MOVE_STALE", &"moved": &"PLC_MOVED", &"rotated": &"PLC_ROTATED",
	&"invalid_rotation": &"PLC_INVALID", &"occupancy_error": &"PLC_INVALID", &"unknown_machine": &"PLC_INVALID"
}

static func reason(code: StringName) -> String:
	return TranslationServer.translate(REASONS.get(code,&"UI_MACHINE_COLLECT_FAILED"))

static func item_name(id: StringName) -> String:
	var item: ItemData = DataRegistry.get_item(id) as ItemData
	return TranslationServer.translate(item.display_name_key) if item!=null else TranslationServer.translate(&"UI_MACHINE_PRODUCT_UNKNOWN")

static func entries(rows: Array[Dictionary]) -> String:
	var parts: PackedStringArray = []
	for row: Dictionary in rows:
		parts.append("%s × %d" % [item_name(StringName(row.item_id)),int(row.quantity)])
	return ", ".join(parts)

static func state_text(model: Dictionary) -> String:
	var state: StringName = StringName(model.get("state",MachineState.STATUS_IDLE))
	if state==MachineState.STATUS_WORKING:
		return TranslationServer.translate(&"UI_MACHINE_STATE_WORKING") % int(model.remaining)
	return TranslationServer.translate(&"UI_MACHINE_STATE_BLOCKED" if state==MachineState.STATUS_BLOCKED else &"UI_MACHINE_STATE_IDLE")

static func result_text(result: Dictionary) -> String:
	if result.is_empty():
		return ""
	if bool(result.ok) and StringName(result.reason)==&"collected":
		return TranslationServer.translate(&"UI_MACHINE_COLLECT_SUCCESS") % [int(result.quantity),item_name(StringName(result.item_id))]
	return reason(StringName(result.reason))

static func button(parent: Node, key: StringName, action: String, tone: StringName = &"LifeSecondary") -> Button:
	var button: Button = LifePauseParts.button(parent,key,tone)
	button.set_meta(&"machine_action",action)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button

static func label(parent: Node, tone: StringName = &"LifeText18") -> Label:
	return LifePauseParts.label(parent,&"",tone)

static func art(machine: MachineData, working: bool) -> Texture2D:
	var key: String = "%s:%s" % [machine.machine_id,working]
	if _textures.has(key):
		return _textures[key] as Texture2D
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/machines/machines_manifest.json"))
	if not raw is Dictionary:
		return null
	var manifest: Dictionary = raw
	var entry: Dictionary = manifest.get("machines",{}).get(String(machine.machine_id),{})
	var stems: Array = entry.get("files",[])
	var index: int = 1 if working and stems.size()>1 else 0
	if stems.is_empty():
		return null
	var path: String = "%s/%s.png" % [machine.sprite_dir,String(stems[index])]
	var texture: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	_textures[key] = texture
	return texture
