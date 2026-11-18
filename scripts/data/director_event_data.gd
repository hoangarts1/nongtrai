## DirectorEventData — typed definition of one bounded, explained event.
class_name DirectorEventData
extends Resource

@export var id: StringName
@export var tags: PackedStringArray = []
@export var conditions: Array[Resource] = []
@export var effects: Array[Resource] = []
@export var weight: float = 0.0
@export var cooldown_days: int = 0
@export var max_per_season: int = 0
@export var is_negative: bool = false
@export var telegraph_days: int = 0
@export var duration_days: int = 0
@export var mutex_group: StringName
@export var activity_affinities: PackedStringArray = []
@export var title_key: StringName
@export var explanation_key: StringName
@export var counter_hint_key: StringName

func validation_errors(ecology: EcologyProfile, npcs: NpcWorldData, weather: WeatherProfile) -> PackedStringArray:
	var errors: PackedStringArray = []
	if not EcologyMetricData.valid_id(id) or not EcologyMetricData.valid_id(mutex_group):
		errors.append("director event requires valid id/mutex group")
	if not is_finite(weight) or weight < 0.0:
		errors.append("director event weight must be finite/nonnegative")
	for value: int in [cooldown_days, duration_days]:
		if value <= 0 or value > DirectorConditionData.INT32_MAX:
			errors.append("director event duration/cooldown must be positive bounded days")
	if max_per_season < 0 or max_per_season > DirectorConditionData.INT32_MAX or (is_negative and max_per_season == 0):
		errors.append("director negative event needs a bounded positive season cap")
	if telegraph_days < 0 or weather == null or telegraph_days > weather.forecast_days or (is_negative and telegraph_days == 0):
		errors.append("director event telegraph must fit saved forecast and precede negative effects")
	if cooldown_days < duration_days:
		errors.append("director event cooldown must prevent self overlap")
	for key: StringName in [title_key, explanation_key, counter_hint_key]:
		if not DirectorConditionData.text_key(key):
			errors.append("director event requires title/explanation/counter keys")
	var seen: Dictionary = {}
	for tag: String in tags:
		if not EcologyMetricData.valid_id(tag) or seen.has(tag):
			errors.append("director event tag invalid/duplicate")
		seen[tag] = true
	seen.clear()
	for activity: String in activity_affinities:
		if not DirectorActivityConfig.SOURCE_IDS.has(activity) or seen.has(activity) or is_negative:
			errors.append("director affinity must reference a unique positive activity")
		seen[activity] = true
	if conditions.is_empty() or effects.size() != 1:
		errors.append("director prototype requires conditions and exactly one effect")
	for resource: Resource in conditions:
		var condition: DirectorConditionData = resource as DirectorConditionData
		if condition == null:
			errors.append("director condition resource missing/wrong class")
		else:
			errors.append_array(condition.validation_errors(ecology))
	for resource: Resource in effects:
		var effect: DirectorEffectData = resource as DirectorEffectData
		if effect == null:
			errors.append("director effect resource missing/wrong class")
		else:
			errors.append_array(effect.validation_errors(ecology, npcs))
	return errors

func get_translation_keys() -> PackedStringArray:
	return PackedStringArray([String(title_key), String(explanation_key), String(counter_hint_key)])
