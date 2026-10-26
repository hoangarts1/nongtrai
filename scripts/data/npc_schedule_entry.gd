## NpcScheduleEntry — one data-defined time block in an NPC daily schedule.
## API:
##   func applies_to(season: StringName, minute: int) -> bool
class_name NpcScheduleEntry
extends Resource

## Empty means every season.
@export var seasons: PackedStringArray = PackedStringArray()
## GameClock minutes (360 = 06:00, values above 1440 are after midnight).
@export_range(0, 1560) var start_minute: int = 480
@export_range(0, 1560) var end_minute: int = 1080
@export var location_id: StringName = &""

func applies_to(season: StringName, minute: int) -> bool:
	if not seasons.is_empty() and not seasons.has(String(season)):
		return false
	return minute >= start_minute and minute < end_minute
