## NpcWorldData — declared Phase 8 content, navigation and schedule parameters.
class_name NpcWorldData
extends Resource

@export var npcs: Array[Resource] = []
@export var dialogues: Array[Resource] = []
@export var offers: Array[Resource] = []
@export var locations: WorldLocations
@export var day_night_profile: DayNightProfile
@export var night_moon_energy: float = 0.14
@export var days_per_week: int = 7
@export var interaction_reach: float = 2.0
@export var debug_delivery_quantity: int = 3
