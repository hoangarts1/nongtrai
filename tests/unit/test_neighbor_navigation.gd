extends GutTest
const FIXTURE: Script = preload("res://tests/helpers/neighbor_fixture.gd")
const WORLD: NpcWorldData = preload("res://data/npcs/phase8_world.tres")
var f: RefCounted
func before_each() -> void:
	f = FIXTURE.new()
	f.setup(self)
func after_each() -> void:
	f.cleanup()
	await get_tree().process_frame

func test_four_npcs_reach_data_destinations_all_seasons_days_and_obey_rain_night() -> void:
	assert_eq(WORLD.npcs.size(),4)
	var scheduler: NpcSchedule = f.main.npc_system.state.scheduler
	for season: StringName in [&"spring",&"summer",&"autumn",&"winter"]:
		for day: int in range(WORLD.days_per_week):
			for resource: Resource in WORLD.npcs:
				var npc: NpcData = resource as NpcData
				for minute: int in [420,480,720,1020,1140,1200,1500]:
					var target: StringName = scheduler.destination(npc,day,minute,season,false)
					var path: Array[Vector2i] = scheduler.route(scheduler.location_cell(npc.home_location),scheduler.location_cell(target))
					assert_false(path.is_empty(),"%s -> %s" % [npc.npc_id,target])
					var unobstructed: bool = true
					for cell: Vector2i in path:
						for blocked: Rect2i in WORLD.locations.get_solid_regions()+f.main.presentation.get_navigation_blockers():
							if blocked.has_point(cell): unobstructed = false
					assert_true(unobstructed,"Every waypoint avoids actual fixed and supplied-rock blockers")
				assert_eq(scheduler.destination(npc,day,720,season,true),npc.home_location)
				assert_eq(scheduler.destination(npc,day,1500,season,false),npc.home_location)
	assert_eq(scheduler.destination(f.main.npc_system.state.get_npc(&"an"),0,420,&"spring",false),&"an_bakery")
	assert_eq(scheduler.destination(f.main.npc_system.state.get_npc(&"bac_lam"),0,480,&"spring",false),&"bac_lam_workshop")
	assert_eq(scheduler.destination(f.main.npc_system.state.get_npc(&"bac_lam"),0,1020,&"spring",false),&"village_square")

func test_actual_cleared_rock_machine_and_coop_obstacles_merge_without_changing_saved_cells() -> void:
	f.near(&"an")
	var before: Dictionary = f.main.npc_system.state.serialize()
	var cell: Vector2i = Vector2i(3,-4)
	assert_true(f.main.npc_system.state.scheduler.route(Vector2i(3,-5),cell).is_empty())
	assert_true(f.clear_at(cell).ok)
	assert_false(f.main.npc_system.state.scheduler.route(Vector2i(3,-5),cell).is_empty())
	assert_eq(f.main.npc_system.state.serialize(),before)
	var extra: Array[Rect2i] = [Rect2i(-7,5,1,1)]
	f.main.npc_system.set_dynamic_obstacles(extra)
	assert_true(f.main.npc_system.state.scheduler.route(Vector2i(-8,5),Vector2i(-7,5)).is_empty())
	f.main.machine_inventory.add_machine(&"stove",1)
	assert_true(f.main.machine_build.place(&"stove",Vector2i(2,3),0).ok)
	f.main.machine_presentation.refresh()
	assert_true(f.main.npc_system.state.scheduler.route(Vector2i(-8,5),Vector2i(-7,5)).is_empty(),"Machine refresh retains external coop blockers")
	assert_eq(f.main.npc_system.state.serialize(),before)

func test_legacy_one_cell_start_can_exit_but_fixed_water_and_blocked_target_stay_closed() -> void:
	var scheduler: NpcSchedule = NpcSchedule.new()
	scheduler.configure(WORLD)
	var start: Vector2i = Vector2i(-8,5)
	var target: Vector2i = Vector2i(-6,5)
	scheduler.set_dynamic_obstacles([Rect2i(start,Vector2i.ONE)])
	var path: Array[Vector2i] = scheduler.route(start,target)
	assert_false(path.is_empty())
	assert_eq(path[0],start)
	assert_eq(path.back(),target)
	assert_true(scheduler.route(target,start).is_empty())
	scheduler.set_dynamic_obstacles([Rect2i(-8,5,2,2)])
	assert_true(scheduler.route(start,target).is_empty())
	assert_true(scheduler.route(Vector2i.ZERO,target).is_empty())
