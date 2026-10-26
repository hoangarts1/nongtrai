## NpcData — data-only definition of a villager: home, schedule, rain behaviour, friendship.
class_name NpcData
extends Resource

@export var npc_id: StringName = &""
@export var display_name_key: StringName = &""
@export var color: Color = Color.WHITE
@export var home_location: StringName = &""
## &"indoors" = stays home when it rains; &"umbrella" = keeps working under an umbrella (storms always send NPCs home).
@export var rain_behavior: StringName = &"indoors"
## Array of NpcScheduleEntry resources.
@export var schedule: Array[Resource] = []
@export var move_speed: float = 2.5
@export_range(1, 1000) var friendship_max: int = 100
@export var talk_friendship: int = 2
@export var is_merchant: bool = false
