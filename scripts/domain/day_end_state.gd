## DayEndState — replay-safe review/confirm guard, independent of Nodes and clocks.
## API:
##   func review(day: int, automatic: bool) -> bool
##   func confirm(day: int) -> bool
##   func cancel() -> bool
##   func reconcile(day: int) -> void
##   func serialize() -> Dictionary
##   func deserialize(data: Dictionary) -> void
class_name DayEndState
extends RefCounted

enum Phase { IDLE, REVIEW, ADVANCING }
var phase: Phase = Phase.IDLE
var day_index: int = -1
var forced: bool = false
var last_completed_day: int = -1

func review(day: int, automatic: bool) -> bool:
	if phase != Phase.IDLE or day < 0 or day <= last_completed_day:
		return false
	day_index = day
	forced = automatic
	phase = Phase.REVIEW
	return true

func confirm(day: int) -> bool:
	if phase != Phase.REVIEW or day != day_index or day <= last_completed_day:
		return false
	phase = Phase.ADVANCING
	return true

func cancel() -> bool:
	if phase != Phase.REVIEW or forced:
		return false
	phase = Phase.IDLE
	return true

func reconcile(day: int) -> void:
	day = maxi(0,day)
	last_completed_day = mini(last_completed_day,day-1)
	if day > day_index:
		last_completed_day = maxi(last_completed_day,day-1)
		phase = Phase.IDLE
	elif day < day_index:
		phase = Phase.IDLE
		day_index = day-1
		last_completed_day = day-1
	elif phase == Phase.ADVANCING:
		# An incomplete old-day save must be reviewed again, never replayed silently.
		phase = Phase.REVIEW

func serialize() -> Dictionary:
	return {"phase":int(phase),"day_index":day_index,"forced":forced,"last_completed_day":last_completed_day}

func deserialize(data: Dictionary) -> void:
	phase = clampi(DayLedgerState.number(data.get("phase",0)),0,2) as Phase
	day_index = maxi(-1,DayLedgerState.number(data.get("day_index",-1),-1))
	forced = data.get("forced",false) is bool and data.get("forced",false)
	last_completed_day = maxi(-1,DayLedgerState.number(data.get("last_completed_day",-1),-1))
