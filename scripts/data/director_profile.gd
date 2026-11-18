## DirectorProfile — explicit prototype policy and DATA references, no gameplay owner.
class_name DirectorProfile
extends Resource

const EVENT_EFFECTS: Dictionary = {"gentle_dust": "extra_water_charge", "merchant_visit": "merchant_visit", "butterfly_bloom": "butterfly_accent"}
const SEASON_IDS: PackedStringArray = ["spring", "summer", "autumn", "winter"]
@export var enabled: bool = false
@export var grace_days: int = 0
@export var pity_days: int = 0
@export var max_negative_per_season: int = 0
@export var min_negative_gap: int = 0
@export var history_limit: int = 0
@export var no_event_weight: float = 0.0
@export var activity_bonus_max: float = 0.0
@export var ecology: EcologyProfile
@export var weather: WeatherProfile
@export var npc_world: NpcWorldData
@export var seasons: Array[Resource] = []
@export var events: Array[Resource] = []

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if ecology == null or not ecology.validation_errors().is_empty() or weather == null or not weather.validation_errors().is_empty() or npc_world == null or npc_world.locations == null:
		return PackedStringArray(["director profile requires valid ecology/weather/NPC DATA"])
	if npc_world.days_per_week <= 0 or npc_world.day_night_profile == null or not is_finite(npc_world.night_moon_energy):
		errors.append("director NPC calendar/lighting DATA invalid")
	for value: int in [grace_days, pity_days, max_negative_per_season, min_negative_gap, history_limit]:
		if value <= 0 or value > DirectorConditionData.INT32_MAX:
			errors.append("director policy day/cap/history bounds must be positive")
	if not is_finite(no_event_weight) or no_event_weight <= 0.0 or not is_finite(activity_bonus_max) or activity_bonus_max < 0.0:
		errors.append("director policy weights must be finite with a positive no-event weight")
	var season_ids: Dictionary = {}
	for resource: Resource in seasons:
		var season: SeasonData = resource as SeasonData
		if season == null or not SEASON_IDS.has(String(season.season_id)) or season.days_in_season <= 0 or season.days_in_season > DirectorConditionData.INT32_MAX or season_ids.has(season.season_id):
			errors.append("director season DATA invalid/duplicate")
		else:
			season_ids[season.season_id] = true
	if season_ids.size() != SEASON_IDS.size():
		errors.append("director requires the complete ordered season calendar")
	else:
		for index: int in range(SEASON_IDS.size()):
			if String((seasons[index] as SeasonData).season_id) != SEASON_IDS[index]:
				errors.append("director calendar must match the existing clock season order")
	var seen: Dictionary = {}
	var total: float = no_event_weight
	for resource: Resource in events:
		var event: DirectorEventData = resource as DirectorEventData
		if event == null:
			errors.append("director event resource missing/wrong class")
			continue
		errors.append_array(event.validation_errors(ecology, npc_world, weather))
		if not EVENT_EFFECTS.has(String(event.id)) or seen.has(event.id):
			errors.append("director prototype event unknown/duplicate")
		else:
			seen[event.id] = true
			if event.effects.size() == 1 and event.effects[0] is DirectorEffectData and String(event.effects[0].kind) != EVENT_EFFECTS[String(event.id)]:
				errors.append("director event/effect binding mismatch")
		if event.is_negative != (event.id == &"gentle_dust"):
			errors.append("director negative flag mismatches prototype")
		total += event.weight + activity_bonus_max
	if seen.size() != EVENT_EFFECTS.size() or not is_finite(total):
		errors.append("director requires exactly three events with finite total weights")
	return errors

func get_event(id: StringName) -> DirectorEventData:
	for resource: Resource in events:
		var event: DirectorEventData = resource as DirectorEventData
		if event != null and event.id == id:
			return event
	return null

func get_translation_keys() -> PackedStringArray:
	var keys: PackedStringArray = []
	for resource: Resource in events:
		if resource is DirectorEventData:
			keys.append_array(resource.get_translation_keys())
	return keys

func frozen_copy() -> DirectorProfile:
	var copy: DirectorProfile = duplicate(true) as DirectorProfile
	copy.ecology = ecology.duplicate(true) as EcologyProfile
	copy.ecology.metrics = []
	for resource: Resource in ecology.metrics:
		var metric: EcologyMetricData = resource.duplicate(true) as EcologyMetricData
		metric.thresholds = (resource as EcologyMetricData).thresholds.duplicate(true)
		copy.ecology.metrics.append(metric)
	copy.weather = weather.duplicate(true) as WeatherProfile
	copy.weather.entries = weather.entries.duplicate(true)
	copy.seasons = []
	for resource: Resource in seasons:
		copy.seasons.append(resource.duplicate(true))
	copy.npc_world = npc_world.duplicate(true) as NpcWorldData
	copy.npc_world.locations = npc_world.locations.duplicate(true) as WorldLocations
	copy.npc_world.locations.locations = npc_world.locations.locations.duplicate(true)
	copy.npc_world.day_night_profile = npc_world.day_night_profile.duplicate(true) as DayNightProfile
	copy.npc_world.day_night_profile.keyframes = npc_world.day_night_profile.keyframes.duplicate(true)
	copy.npc_world.npcs = []
	for resource: Resource in npc_world.npcs:
		var npc: NpcData = resource.duplicate(true) as NpcData
		npc.schedule = []
		for entry: Resource in (resource as NpcData).schedule:
			npc.schedule.append(entry.duplicate(true))
		copy.npc_world.npcs.append(npc)
	copy.events = []
	for resource: Resource in events:
		var event: DirectorEventData = resource.duplicate(true) as DirectorEventData
		event.conditions = []
		event.effects = []
		for condition: Resource in (resource as DirectorEventData).conditions:
			event.conditions.append(condition.duplicate(true))
		for effect: Resource in (resource as DirectorEventData).effects:
			event.effects.append(effect.duplicate(true))
		copy.events.append(event)
	return copy
