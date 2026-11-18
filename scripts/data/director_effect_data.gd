## DirectorEffectData — reversible terms, without an effect executor or world state.
class_name DirectorEffectData
extends Resource

const KINDS: PackedStringArray = ["extra_water_charge", "merchant_visit", "butterfly_accent"]
@export var kind: StringName
@export var extra_charge: int = 0
@export var exempt_metric_id: StringName
@export var exempt_threshold_id: StringName
@export var waive_rain: bool = false
@export var npc_id: StringName
@export var location_id: StringName
@export var accent_color: Color = Color.WHITE

func validation_errors(ecology: EcologyProfile, npcs: NpcWorldData) -> PackedStringArray:
	var errors: PackedStringArray = []
	if not KINDS.has(String(kind)):
		return PackedStringArray(["director effect kind unknown"])
	if kind == &"extra_water_charge":
		if extra_charge <= 0 or extra_charge > DirectorConditionData.INT32_MAX or exempt_metric_id == &"water_clarity" or not DirectorConditionData.threshold_matches(ecology, exempt_metric_id, exempt_threshold_id) or not waive_rain:
			errors.append("director extra water terms require bounded charge and measured canopy/rain counter")
	elif extra_charge != 0 or not exempt_metric_id.is_empty() or not exempt_threshold_id.is_empty() or waive_rain:
		errors.append("director effect has unused water terms")
	if kind == &"merchant_visit":
		var found: bool = false
		if npcs != null and npcs.locations != null and npcs.locations.has_location(location_id):
			for resource: Resource in npcs.npcs:
				var npc: NpcData = resource as NpcData
				if npc != null and npc.npc_id == npc_id and npc.is_merchant:
					for entry: Resource in npc.schedule:
						if entry is NpcScheduleEntry and entry.location_id == location_id:
							found = true
		if not found:
			errors.append("director visitor requires actual merchant and existing schedule destination")
	elif not npc_id.is_empty() or not location_id.is_empty():
		errors.append("director effect has unused visitor terms")
	for value: float in [accent_color.r, accent_color.g, accent_color.b, accent_color.a]:
		if not is_finite(value) or value < 0.0 or value > 1.0:
			errors.append("director accent color must be finite unit RGBA")
	return errors

func terms() -> Dictionary:
	return {"kind": String(kind), "extra_charge": extra_charge, "exempt_metric_id": String(exempt_metric_id), "exempt_threshold_id": String(exempt_threshold_id), "waive_rain": waive_rain, "npc_id": String(npc_id), "location_id": String(location_id), "accent": [accent_color.r, accent_color.g, accent_color.b, accent_color.a]}
