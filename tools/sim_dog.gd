## Independent companion movement probe; exit0 only after 1000 real adjacent steps agree.
extends SceneTree
const CONFIG: DogConfig = preload("res://data/dog_config.tres")
const STEPS: int = 1000
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var started: int = Time.get_ticks_msec()
	if not OS.get_cmdline_user_args().is_empty():
		print("[sim_dog] rejected unknown fixture/arguments")
		quit(1)
		return
	var single: Dictionary = _simulate(1,false)
	var grouped: Dictionary = _simulate(13,false)
	var resumed: Dictionary = _simulate(17,true)
	if not single.get("ok",false) or not grouped.get("ok",false) or not resumed.get("ok",false) or single.get("trace")!=grouped.get("trace") or single.get("trace")!=resumed.get("trace") or single.get("state")!=resumed.get("state"):
		push_error("sim_dog: movement/checkpoint divergence")
		quit(1)
		return
	print(JSON.stringify({"status":"PASS","steps":STEPS,"adjacent_commits":single.moved,"repairs":single.repairs,"rebuilds":single.rebuilds,"name":single.state.name,"cell_x":single.state.cell_x,"cell_y":single.state.cell_y,"grouped_match":true,"json_match":true,"elapsed_ms":Time.get_ticks_msec()-started}))
	quit(0)
func _simulate(group: int, checkpoint: bool) -> Dictionary:
	var config: DogConfig = CONFIG.frozen_copy()
	var nav: DogNavigation = DogNavigation.new()
	if not nav.configure(config): return {"ok":false}
	var safe: Dictionary = DogFollowRules.nearest_walkable(config,nav,config.world.spawn_cell)
	if not safe.ok: return safe
	var state: DogState = DogState.new()
	if not state.configure(config,safe.cell) or not state.try_set_name("Mây").get("ok",false): return {"ok":false}
	var service: DogMovementService = DogMovementService.new()
	if not service.configure(config,state,nav): return {"ok":false}
	var trace: Array[Dictionary] = []
	var repairs: int = 0
	var moved: int = 0
	var index: int = 0
	var region: Rect2i = config.world.player_region
	var goals: Array[Vector2i] = [region.position,Vector2i(region.end.x-1,region.position.y),region.end-Vector2i.ONE,Vector2i(region.position.x,region.end.y-1)]
	while index<STEPS:
		for _part: int in range(mini(group,STEPS-index)):
			if index%25==0 or index%53==0:
				var blocks: Array[Rect2i] = []
				if index%53==0: blocks.append(Rect2i(state.get_cell(),Vector2i.ONE))
				else: blocks.append(Rect2i(region.position+Vector2i(index%region.size.x,region.size.y/2),Vector2i.ONE))
				if not nav.set_dynamic_obstacles(blocks): return {"ok":false}
				var builds: int = nav.get_rebuild_count()
				if not nav.set_dynamic_obstacles(blocks) or nav.get_rebuild_count()!=builds: return {"ok":false}
			if not nav.is_walkable(state.get_cell()):
				if not service.repair_invalid_origin().get("ok",false): return {"ok":false}
				repairs += 1
			var goal: Vector2i = goals[(index/97)%goals.size()]
			var plan: Dictionary = service.plan(goal,true)
			if not plan.ok: return plan
			var previous: Vector2i = state.get_cell()
			for step_cell: Vector2i in plan.path:
				if not region.has_point(step_cell) or not nav.is_walkable(step_cell) or (step_cell!=previous and DogFollowRules.distance(previous,step_cell)!=1): return {"ok":false}
				previous = step_cell
			var target: Vector2i
			if plan.path.size()>1: target = plan.path[1]
			else:
				var component: Dictionary = nav.reachable(state.get_cell())
				if not component.ok or component.cells.size()<2: return {"ok":false}
				target = component.cells[1]
			var origin: Vector2i = state.get_cell()
			var quote: Dictionary = service.quote_step(target)
			if not quote.ok or not service.step(quote).get("ok",false) or DogFollowRules.distance(origin,state.get_cell())!=1 or not nav.is_walkable(state.get_cell()) or state.get_name()!="Mây": return {"ok":false}
			moved += 1
			trace.append(state.serialize())
			index += 1
			if checkpoint and index==STEPS/2:
				if not state.deserialize(JSON.parse_string(JSON.stringify(state.serialize()))) or not nav.deserialize(JSON.parse_string(JSON.stringify(nav.serialize()))): return {"ok":false}
	return {"ok":moved==STEPS,"moved":moved,"repairs":repairs,"rebuilds":nav.get_rebuild_count(),"trace":trace,"state":state.serialize()}
