## SeasonData — data for one playable season.
extends Resource
class_name SeasonData

@export var season_id: StringName = &"spring"
@export var display_name_key: StringName = &"SEASON_SPRING"
@export_range(1, 999) var days_in_season: int = 28
@export var grass_color: Color = Color.WHITE
@export var weather_profile_key: StringName = &"spring"
@export var starter_seed: StringName = &"turnip_seed"
