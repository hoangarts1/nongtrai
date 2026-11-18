## Isolated verification tool, never attach to a live Main. No save files are written.
## API: static run_scenario(days=1000,chunk_size=17)->Dictionary.
extends SceneTree

const PROFILE: EcologyProfile = preload("res://data/ecology_profile.tres")
const SAMPLING: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
const LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var days: int = 1000
	var chunk_size: int = 17
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--days=") and argument.trim_prefix("--days=").is_valid_int():
			days = int(argument.trim_prefix("--days="))
		elif argument.begins_with("--chunk=") and argument.trim_prefix("--chunk=").is_valid_int():
			chunk_size = int(argument.trim_prefix("--chunk="))
		else:
			push_error("sim_ecology: expected --days=<positive int> --chunk=<positive int>")
			quit(1)
			return
	var result: Dictionary = run_scenario(days, chunk_size)
	print("[sim_ecology] " + ("PASS " if result.ok else "FAIL ") + JSON.stringify(result, "", true, true))
	quit(0 if result.ok else 1)

static func run_scenario(days: int = 1000, chunk_size: int = 17) -> Dictionary:
	if days <= 0 or chunk_size <= 0:
		return _failure("days/chunk must be positive")
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var clock: Node = tree.root.get_node_or_null("GameClock")
	var registry: Node = tree.root.get_node_or_null("DataRegistry")
	if clock == null or registry == null:
		return _failure("isolated tool requires existing clock/data autoloads")
	var previous: Dictionary = clock.call("serialize")
	var paused: bool = bool(clock.get("paused"))
	clock.set("paused", true)
	clock.call("deserialize", {})
	var result: Dictionary = _simulate(days, chunk_size, clock, registry)
	clock.call("deserialize", previous)
	clock.set("paused", paused)
	return result

static func _simulate(days: int, chunk_size: int, clock: Node, registry: Node) -> Dictionary:
	var crops: Array[Resource] = registry.call("get_all_crops")
	var first: EcologyState = EcologyState.new()
	var reference: EcologyState = EcologyState.new()
	var farm_script: Script = load("res://scripts/domain/farm_grid_state.gd") as Script
	var farm: RefCounted = farm_script.new()
	var reference_farm: RefCounted = farm_script.new()
	var land: LandOwnershipState = LandOwnershipState.new()
	land.configure(LAND)
	var baseline: Dictionary = EcologyLifecycle.calibrate(PROFILE, SAMPLING, farm.serialize(), crops, land.get_owned_regions(), 0)
	if not baseline.ok:
		return _failure("baseline invalid")
	var water: EcologyMetricData = PROFILE.get_metric(&"water_clarity")
	var held_water: float = (water.minimum + water.maximum) / 2.0
	baseline.snapshot.metrics.water_clarity = held_water
	if not first.configure(PROFILE) or not reference.configure(PROFILE) or not first.deserialize(baseline.snapshot) or not reference.deserialize(baseline.snapshot):
		return _failure("initial restore rejected")
	if not first.get_triggered().is_empty():
		return _failure("calibration invented historical crossings")
	var pending: Array[StringName] = []
	first.threshold_crossed.connect(func(id: StringName) -> void: pending.append(id))
	var simulator: RefCounted = (load("res://scripts/domain/day_simulator.gd") as Script).new()
	var stats: Dictionary = {"compared_days": 0, "duplicate_rejections": 0, "roundtrips": 0, "json_scalar_roundings": 0, "upward": 0, "downward": 0, "withered_observations": 0, "harvests": 0, "mature_tree_peak": 0, "species_peak": 0, "expanded": false}
	var crossings: Array[Dictionary] = []
	var ids: Array[StringName] = []
	for crop: CropData in crops:
		ids.append(crop.crop_id)
	ids.sort()
	var season_days: int = int((registry.call("get_season", &"spring") as Resource).get("days_in_season"))
	for start: int in range(0, days, chunk_size):
		for outgoing: int in range(start, mini(days, start + chunk_size)):
			if outgoing == season_days and not land.next_parcel_id().is_empty():
				if not land.grant_next(land.next_parcel_id()):
					return _failure("ownership grant rejected")
				stats.expanded = true
			var care: bool = floori(float(outgoing) / float(season_days)) % 3 != 1
			var cells: Array[Vector2i] = _cells(land.get_owned_regions())
			stats.harvests += _care(farm, cells, ids, care)
			_care(reference_farm, cells, ids, care)
			clock.call("sleep_to_morning")
			var day: int = int(clock.get("day_index"))
			var reservation: Dictionary = first.begin_day(day)
			if not reservation.ok:
				return _failure("daily reservation rejected")
			var completion: Array[Dictionary] = [{}]
			var farm_step: Callable = func(owner: RefCounted) -> void:
				owner.advance_day()
				owner.mark_out_of_season()
			var ecology_step: Callable = func() -> void:
				var sample: Dictionary = EcologySampler.sample(SAMPLING, farm.serialize(), crops, land.get_owned_regions(), first.get_metrics())
				completion[0] = first.finish_day(int(reservation.token), sample.targets) if sample.ok else sample
			simulator.simulate_day(farm, null, null, outgoing, farm_step, ecology_step)
			simulator.simulate_day(reference_farm, null, null, outgoing, farm_step)
			var single: Dictionary = EcologyLifecycle.advance(reference, SAMPLING, day, reference_farm.serialize(), crops, land.get_owned_regions())
			if not completion[0].get("ok", false) or not single.ok or first.serialize() != reference.serialize() or farm.serialize() != reference_farm.serialize():
				return _failure("batch/reserved and individual paths diverged at day %d" % day)
			var sample: Dictionary = single.sample
			if sample.available.water_clarity or float(first.get_metrics().water_clarity) != held_water:
				return _failure("unmeasured water changed")
			stats.mature_tree_peak = maxi(int(stats.mature_tree_peak), int(sample.counts.mature_fruit_trees))
			stats.species_peak = maxi(int(stats.species_peak), int(sample.counts.species))
			for row: Dictionary in farm.serialize().plots:
				if row.withered:
					stats.withered_observations += 1
			var snapshot: Dictionary = first.serialize()
			if not EcologySnapshotCodec.decode(PROFILE, snapshot).ok:
				return _failure("metric/history bounds invalid")
			if first.advance_day(day, sample.targets).ok or first.serialize() != snapshot:
				return _failure("duplicate day mutated state")
			stats.duplicate_rejections += 1
			for id: StringName in pending:
				var active: bool = first.is_threshold_active(id)
				if id == &"clear_water":
					return _failure("held unmeasured water crossed a threshold")
				crossings.append({"day": day, "id": String(id), "active": active})
				stats["upward" if active else "downward"] += 1
			pending.clear()
			if day % season_days == 0:
				var wire: Dictionary = {"ecology": snapshot, "farm": farm.serialize(), "land": land.serialize(), "clock": clock.call("serialize")}
				var parsed: Variant = JSON.parse_string(JSON.stringify(wire, "", true, true))
				if not parsed is Dictionary:
					return _failure("native JSON parse failed")
				var decoded: Dictionary = EcologySnapshotCodec.decode(PROFILE, parsed.ecology)
				if not decoded.ok:
					return _failure("native JSON ecology decode failed")
				for threshold: Dictionary in PROFILE.get_thresholds():
					if (float(snapshot.metrics[threshold.metric_id]) >= float(threshold.value)) != (float(decoded.snapshot.metrics[threshold.metric_id]) >= float(threshold.value)):
						return _failure("JSON flipped threshold side")
				for id: String in snapshot.metrics:
					if snapshot.metrics[id] != decoded.snapshot.metrics[id]:
						stats.json_scalar_roundings += 1
				if not first.deserialize(decoded.snapshot) or not reference.deserialize(decoded.snapshot) or first.serialize() != decoded.snapshot or not pending.is_empty() or decoded.snapshot.triggered != snapshot.triggered:
					return _failure("restore changed decoded values/history or notified")
				farm.deserialize(parsed.farm)
				reference_farm.deserialize(parsed.farm)
				land.deserialize(parsed.land)
				clock.call("deserialize", parsed.clock)
				stats.roundtrips += 1
			stats.compared_days += 1
	return {"ok": true, "days": days, "chunk_size": chunk_size, "stats": stats, "crossings": crossings, "snapshot": first.serialize(), "reference": reference.serialize(), "farm": farm.serialize(), "land": land.serialize(), "water_available": false}

static func _care(farm: RefCounted, cells: Array[Vector2i], ids: Array[StringName], enabled: bool) -> int:
	if not enabled:
		return 0
	var harvests: int = 0
	for index: int in range(mini(cells.size(), SAMPLING.mature_tree_goal + ids.size())):
		var cell: Vector2i = cells[index]
		if farm.can_harvest(cell):
			if farm.harvest_cell(cell).success:
				harvests += 1
		var plot: Dictionary = farm.get_plot(cell)
		if bool(plot.get("withered", false)):
			farm.clear_withered(cell)
			plot = farm.get_plot(cell)
		if String(plot.get("crop_id", "")).is_empty():
			farm.till_cell(cell)
			var id: StringName = StringName(SAMPLING.fruit_tree_ids[index % SAMPLING.fruit_tree_ids.size()]) if index < SAMPLING.mature_tree_goal else ids[index - SAMPLING.mature_tree_goal]
			farm.plant_crop(cell, id)
		farm.water_cell(cell)
	return harvests

static func _cells(regions: Array[Rect2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for region: Rect2i in regions:
		for y: int in range(region.position.y, region.end.y):
			for x: int in range(region.position.x, region.end.x):
				var cell: Vector2i = Vector2i(x, y)
				if not result.has(cell):
					result.append(cell)
	return result

static func _failure(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}
