## DaySimulator — one completed-day path: farm, animals, machines, optional ecology.
## API: simulate_day(farm_state,coop=null,machines=null,completed_day=-1,farm_step=Callable(),ecology_step=Callable()).
class_name DaySimulator
extends RefCounted

func simulate_day(farm_state: FarmGridState, coop: ChickenCoopState = null, machines: Object = null, completed_day: int = -1, farm_step: Callable = Callable(), ecology_step: Callable = Callable()) -> void:
	if farm_state==null:
		return
	var reservation: Dictionary = coop.begin_day(completed_day) if coop!=null else {}
	if coop!=null and not bool(reservation.ok):
		return
	if farm_step.is_valid():
		farm_step.call(farm_state)
	else:
		farm_state.advance_day()
	if coop!=null:
		coop.finish_day(reservation.token)
	if machines!=null:
		machines.call("advance_day")
	if ecology_step.is_valid():
		ecology_step.call()
