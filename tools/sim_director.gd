## Isolated seeded verification only. Never attach/run beside live Main; writes no saves.
## API: run_scenario(days=1000,chunk_size=17,style="balanced",seed=731)->Dictionary.
extends SceneTree

const PROFILE: DirectorProfile = preload("res://data/director_profile.tres")
const ACTIVITY: DirectorActivityConfig = preload("res://data/director_activity_config.tres")
const SAMPLING: EcologySamplingConfig = preload("res://data/ecology_sampling_config.tres")
const LAND: LandExpansionConfig = preload("res://data/land_expansion_config.tres")
const CAN: WateringCanConfig = preload("res://data/watering_can_config.tres")
const STYLES: PackedStringArray = ["gardener", "trader", "balanced", "inactive"]

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var options: Dictionary = {"days": 1000, "chunk": 17, "profile": "balanced", "seed": 731, "budget": 0, "resume": ""}
	for argument: String in OS.get_cmdline_user_args():
		var pair: PackedStringArray = argument.trim_prefix("--").split("=", false, 1)
		if not argument.begins_with("--") or pair.size() != 2 or not options.has(pair[0]) or (pair[0] not in ["profile", "resume"] and not pair[1].is_valid_int()):
			push_error("sim_director: invalid --days/--chunk/--profile/--seed/--budget/--resume option")
			quit(1)
			return
		options[pair[0]] = pair[1] if pair[0] in ["profile", "resume"] else pair[1].to_int()
	var checkpoint: Dictionary = {}
	if not String(options.resume).is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(options.resume))
		if not parsed is Dictionary:
			print("[sim_director] FAIL " + JSON.stringify(_fail("invalid checkpoint JSON")))
			quit(1)
			return
		checkpoint = parsed
	var result: Dictionary = run_scenario(options.days, options.chunk, options.profile, options.seed, checkpoint, options.budget)
	var encoded: String = JSON.stringify(result, "", true, true)
	# Bounded launcher streams text through PowerShell. Megabyte-long single
	# lines make that log reader quadratic; short chunks preserve every byte.
	if encoded.length() > 8192:
		for offset: int in range(0, encoded.length(), 4096):
			print("[sim_director_json] " + encoded.substr(offset, 4096))
		print("[sim_director] " + ("PASS_CHUNKS " if result.ok else "FAIL_CHUNKS ") + str(encoded.length()))
	else:
		print("[sim_director] " + ("PASS " if result.ok else "FAIL ") + encoded)
	quit(0 if result.ok else 1)

static func _fail(reason: String) -> Dictionary:
	return {"ok": false, "reason": reason}

static func run_scenario(days: int = 1000, chunk_size: int = 17, style: String = "balanced", seed: int = 731, checkpoint: Dictionary = {}, budget_days: int = 0) -> Dictionary:
	if days <= 0 or chunk_size <= 0 or budget_days < 0 or not STYLES.has(style):
		return _fail("invalid days/chunk/profile")
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var clock: Node = tree.root.get_node_or_null("GameClock")
	var registry: Node = tree.root.get_node_or_null("DataRegistry")
	var saves: Node = tree.root.get_node_or_null("SaveService")
	if clock == null or registry == null or saves == null:
		return _fail("isolated initialized autoloads required")
	var previous: Dictionary = clock.call("serialize")
	var paused: bool = bool(clock.get("paused"))
	clock.set("paused", true)
	clock.call("deserialize", {})
	var result: Dictionary = _simulate(days, chunk_size, style, seed, clock, registry, saves, checkpoint, budget_days)
	clock.call("deserialize", previous)
	clock.set("paused", paused)
	return result

static func _world(seed: int, enabled: bool) -> Dictionary:
	# Deferred dynamic loading preserves actual autoload-dependent production scripts.
	var farm: RefCounted = (load("res://scripts/domain/farm_grid_state.gd") as Script).new()
	var inventory: RefCounted = (load("res://scripts/domain/inventory_state.gd") as Script).new()
	var wallet: RefCounted = (load("res://scripts/domain/economy/wallet_state.gd") as Script).new(1000000)
	var weather: RefCounted = (load("res://scripts/domain/weather_state.gd") as Script).new()
	weather.configure(PROFILE.weather, seed, 0)
	var merchant: RefCounted = (load("res://scripts/domain/quests/merchant_service.gd") as Script).new()
	merchant.offers = PROFILE.npc_world.offers
	merchant.world_seed = seed
	var ecology: EcologyState = EcologyState.new()
	var land: LandOwnershipState = LandOwnershipState.new()
	land.configure(LAND)
	var activity: DirectorActivityState = DirectorActivityState.new()
	var director: DirectorState = DirectorState.new()
	var can: WateringCanState = WateringCanState.new()
	can.configure(CAN)
	var water: RefCounted = (load("res://scripts/domain/watering_service.gd") as Script).new()
	water.configure(CAN, can, farm)
	if not ecology.configure(PROFILE.ecology) or not activity.configure(ACTIVITY, 0, true) or not director.configure(PROFILE, 0) or not director.set_enabled(enabled, true):
		return {}
	return {"farm": farm, "inventory": inventory, "wallet": wallet, "weather": weather, "merchant": merchant, "ecology": ecology, "land": land, "activity": activity, "director": director, "can": can, "water": water}

static func _observation(world: Dictionary, clock: Node, crops: Array[Resource]) -> Dictionary:
	var sample: Dictionary = EcologySampler.sample(SAMPLING, world.farm.serialize(), crops, world.land.get_owned_regions(), world.ecology.get_metrics())
	if not sample.ok:
		return _fail("invalid sample")
	var raw_clock: Dictionary = clock.call("serialize")
	return DirectorSnapshot.capture(PROFILE, {"day_index": int(raw_clock.day_index), "minute": int(raw_clock.minute), "season": String(raw_clock.season), "year": int(raw_clock.year)}, {"state": world.ecology.serialize(), "available": sample.available}, world.activity.serialize(), world.weather.serialize(), {"enabled": world.director.is_enabled(), "story_unlocked": false, "debug_preview": true, "busy": false})

static func _care(world: Dictionary, style: String, outgoing: int, crops: Array[Resource], clock: Node) -> Dictionary:
	var counts: Dictionary = {}
	var can_start: int = world.can.get_charges()
	var spent: int = 0
	var merchant_offer: MerchantOfferData = world.merchant.get_offer(outgoing, StringName(clock.get("season")))
	var reference_merchant: RefCounted = (load("res://scripts/domain/quests/merchant_service.gd") as Script).new()
	reference_merchant.offers = PROFILE.npc_world.offers
	reference_merchant.world_seed = int(world.weather.world_seed)
	if merchant_offer != reference_merchant.get_offer(outgoing, StringName(clock.get("season"))):
		return _fail("merchant RNG changed")
	var care: bool = style == "gardener" or (style == "balanced" and outgoing % 2 == 0) or (style == "trader" and outgoing % 4 == 0)
	if not care:
		return {"ok": true, "counts": counts, "charges": 0, "start_charges": can_start}
	var owner: Dictionary = world.director.serialize()
	var water_terms: Dictionary = {}
	if bool(owner.enabled) and not owner.active.is_empty():
		var effect: Dictionary = DirectorEffectProjector.project(PROFILE, owner, _observation(world, clock, crops))
		if not effect.ok: return _fail("invalid water projection")
		water_terms = effect.water
	if not world.water.set_effect_terms(water_terms): return _fail("invalid water terms")
	var region: Rect2i = world.land.get_owned_regions()[0]
	var limit: int = mini(region.get_area(), SAMPLING.mature_tree_goal + crops.size())
	for index: int in range(limit):
		var cell: Vector2i = region.position + Vector2i(index % region.size.x, index / region.size.x)
		if world.farm.can_harvest(cell):
			var payload: Dictionary = world.farm.get_harvest_payload(cell)
			if world.inventory.can_add_item(payload.product_item, int(payload.quantity)):
				var picked: Dictionary = world.farm.harvest_cell(cell)
				var added: int = world.inventory.add_item(picked.product_item, int(picked.quantity))
				if not picked.success or added != int(picked.quantity):
					return _fail("harvest receipt mismatch")
				counts.crop_harvested = int(counts.get("crop_harvested", 0)) + added
		var plot: Dictionary = world.farm.get_plot(cell)
		if bool(plot.get("withered", false)):
			world.farm.clear_withered(cell)
			plot = world.farm.get_plot(cell)
		if String(plot.get("crop_id", "")).is_empty():
			if world.farm.till_cell(cell):
				counts.plot_tilled = int(counts.get("plot_tilled", 0)) + 1
			var crop: CropData = crops[index % crops.size()] as CropData
			if index < SAMPLING.mature_tree_goal:
				for entry: CropData in crops:
					if entry.crop_id == StringName(SAMPLING.fruit_tree_ids[index % SAMPLING.fruit_tree_ids.size()]):
						crop = entry
			var season: String = String(clock.get("season"))
			if crop.seasons.is_empty() or crop.seasons.has(season):
				if not world.inventory.has_item(crop.seed_item):
					var item: Resource = (Engine.get_main_loop() as SceneTree).root.get_node("DataRegistry").call("get_item", crop.seed_item)
					var price: int = int(item.get("buy_price"))
					if world.inventory.can_add_item(crop.seed_item, 1) and world.wallet.remove_coins(price, &"simulation_seed"):
						if world.inventory.add_item(crop.seed_item, 1) != 1:
							return _fail("purchase receipt mismatch")
						counts.item_purchased = int(counts.get("item_purchased", 0)) + 1
				if world.inventory.has_item(crop.seed_item) and world.farm.plant_crop(cell, crop.crop_id):
					if not world.inventory.remove_item(crop.seed_item, 1):
						return _fail("plant receipt mismatch")
					counts.crop_planted = int(counts.get("crop_planted", 0)) + 1
		var quote: Dictionary = world.water.can_water(cell)
		if quote.reason in [&"water_empty", &"water_insufficient"]:
			world.can.refill()
		if world.water.water(cell).ok:
			counts.plot_watered = int(counts.get("plot_watered", 0)) + 1
			spent += world.water.get_charge_cost()
	for slot: Dictionary in world.inventory.get_slots():
		var item: Resource = (Engine.get_main_loop() as SceneTree).root.get_node("DataRegistry").call("get_item", slot.item_id)
		if item != null and String(item.get("category")) == "produce" and int(item.get("sell_price")) > 0:
			var quantity: int = int(slot.quantity)
			if world.inventory.remove_item(slot.item_id, quantity):
				world.wallet.add_coins(quantity * int(item.get("sell_price")), &"simulation_sale")
				counts.item_sold = int(counts.get("item_sold", 0)) + quantity
	if style in ["trader", "balanced"] and merchant_offer != null and posmod(outgoing, 7) in [3, 6]:
		var season: StringName = StringName(clock.get("season"))
		if world.merchant.confirm_trade(outgoing, season, true, world.inventory, world.wallet):
			var key: String = "item_purchased" if merchant_offer.kind == "discount" else "item_sold"
			counts[key] = int(counts.get(key, 0)) + merchant_offer.quantity
			if world.merchant.confirm_trade(outgoing, season, true, world.inventory, world.wallet): return _fail("duplicate merchant stock")
	return {"ok": true, "counts": counts, "charges": spent, "start_charges": can_start}

static func _wire(world: Dictionary, clock: Node) -> Dictionary:
	return {"meta": {"save_version": 14}, "clock": clock.call("serialize"), "chicken_coop": ChickenCoopSaveCodec.empty(int(clock.get("day_index"))), "farm": world.farm.serialize(), "inventory": world.inventory.serialize(), "wallet": world.wallet.serialize(), "weather": world.weather.serialize(), "ecology": world.ecology.serialize(), "land_ownership": world.land.serialize(), "watering_can": world.can.serialize(), "director_activity": world.activity.serialize(), "director": world.director.serialize(), "social": {"merchant": world.merchant.serialize()}}

static func _restore(world: Dictionary, wire: Dictionary) -> bool:
	world.farm.deserialize(wire.farm)
	world.inventory.deserialize(wire.inventory)
	world.wallet.deserialize(wire.wallet)
	world.weather.deserialize(wire.weather)
	world.land.deserialize(wire.land_ownership)
	world.can.deserialize(wire.watering_can)
	world.merchant.deserialize(wire.social.merchant)
	return world.ecology.deserialize(wire.ecology) and world.activity.deserialize(wire.director_activity) and world.director.deserialize(wire.director)

static func _rounded_numbers(before: Variant, after: Variant) -> int:
	if before is float and after is float:
		return 1 if before != after else 0
	var count: int = 0
	if before is Dictionary and after is Dictionary:
		for key: Variant in before:
			count += _rounded_numbers(before[key], after[key])
	elif before is Array and after is Array:
		for index: int in range(before.size()):
			count += _rounded_numbers(before[index], after[index])
	return count

static func _simulate(days: int, chunk: int, style: String, seed: int, clock: Node, registry: Node, saves: Node, checkpoint: Dictionary, budget_days: int) -> Dictionary:
	var worlds: Array[Dictionary] = [_world(seed, true), _world(seed, true), _world(seed, false)]
	if worlds.any(func(world: Dictionary) -> bool: return world.is_empty()):
		return _fail("configuration rejected")
	var crops: Array[Resource] = registry.call("get_all_crops")
	crops.sort_custom(func(a: Resource, b: Resource) -> bool: return String(a.get("crop_id")) < String(b.get("crop_id")))
	var simulator: RefCounted = (load("res://scripts/domain/day_simulator.gd") as Script).new()
	var stats: Dictionary = {"days": 0, "roundtrips": 0, "scalar_roundings": 0, "trace_scalar_roundings": 0, "selected": 0, "negative": 0, "positive": 0, "dust_days": 0, "extra_charges": 0, "duplicate_rejections": 0, "pity_checks": 0, "receipts": DirectorActivityCodec.empty_counts(ACTIVITY)}
	var negative: Array[int] = []
	var seasons: Dictionary = {}
	var decisions: PackedStringArray = []
	var first_day: int = 0
	if not checkpoint.is_empty():
		if checkpoint.get("version") != 1 or checkpoint.get("profile") != style or checkpoint.get("seed") != seed or checkpoint.get("target_days") != days or checkpoint.get("chunk") != chunk or not DirectorActivityCodec.valid_integer(checkpoint.get("day")) or int(checkpoint.day) >= days or not checkpoint.get("worlds") is Array or checkpoint.worlds.size() != worlds.size() or not checkpoint.get("stats") is Dictionary or not checkpoint.get("negative") is Array or not checkpoint.get("seasons") is Dictionary or not checkpoint.get("decisions") is Array:
			return _fail("invalid checkpoint envelope")
		first_day = int(checkpoint.day)
		if first_day % PROFILE.seasons[0].days_in_season != 0 or checkpoint.stats.get("days") != first_day or checkpoint.stats.get("duplicate_rejections") != first_day or checkpoint.decisions.size() != first_day:
			return _fail("checkpoint boundary/count mismatch")
		for index: int in range(worlds.size()):
			var raw: Variant = checkpoint.worlds[index]
			if not raw is Dictionary or raw.get("meta", {}).get("save_version") != 14 or raw.get("clock", {}).get("day_index") != first_day:
				return _fail("checkpoint world/day mismatch")
			var decoded: Dictionary = saves.call("_migrate", raw, 14)
			if not DirectorSnapshot._same(decoded.director, raw.director) or not DirectorSnapshot._same(decoded.director_activity, raw.director_activity) or not _restore(worlds[index], decoded):
				return _fail("checkpoint codec/restore rejected")
		clock.call("deserialize", checkpoint.worlds[0].clock)
		stats = DirectorHistoryRules.copy_json(checkpoint.stats)
		for value: Variant in checkpoint.negative:
			if not DirectorActivityCodec.valid_integer(value): return _fail("invalid checkpoint negative day")
			negative.append(int(value))
		seasons = DirectorHistoryRules.copy_json(checkpoint.seasons)
		for decision: Variant in checkpoint.decisions:
			if not decision is String: return _fail("invalid checkpoint decision bytes")
			decisions.append(decision)
		if _wire(worlds[0], clock) != _wire(worlds[1], clock): return _fail("checkpoint paths differ")
	var last_day: int = days if budget_days == 0 else mini(days, first_day + budget_days)
	if last_day != days and last_day % PROFILE.seasons[0].days_in_season != 0:
		return _fail("budget must end at an actual season checkpoint")
	for start: int in range(first_day, last_day, chunk):
		for outgoing: int in range(start, mini(last_day, start + chunk)):
			var receipts: Array[Dictionary] = []
			var reservations: Array[Dictionary] = []
			for world: Dictionary in worlds:
				var receipt: Dictionary = _care(world, style, outgoing, crops, clock)
				if not receipt.ok or (not receipt.counts.is_empty() and not world.activity.record_many(outgoing, receipt.counts).ok):
					return _fail("actual receipt rejected day%d" % outgoing)
				receipts.append(receipt)
				var weather: Dictionary = world.weather.begin_day(outgoing + 1)
				var activity: Dictionary = world.activity.begin_day(outgoing + 1)
				var director: Dictionary = world.director.begin_day(outgoing + 1)
				if not weather.ok or not activity.ok or not director.ok:
					return _fail("day reservation rejected")
				reservations.append({"weather": weather, "activity": activity, "director": director})
			clock.call("sleep_to_morning")
			for index: int in range(worlds.size()):
				var world: Dictionary = worlds[index]
				var token: Dictionary = reservations[index]
				var farm_step: Callable = func(farm: RefCounted) -> void:
					if world.weather.is_rainy(): farm.water_all_crops()
					farm.advance_day()
					farm.mark_out_of_season()
				simulator.simulate_day(world.farm, null, null, outgoing, farm_step)
				var ecology: Dictionary = EcologyLifecycle.advance(world.ecology, SAMPLING, outgoing + 1, world.farm.serialize(), crops, world.land.get_owned_regions())
				if not ecology.ok or not world.weather.finish_day(token.weather.token) or not world.activity.finish_day(token.activity.token).ok:
					return _fail("completed owner mismatch")
				if world.weather.is_rainy(): world.farm.water_all_crops()
				var snapshot: Dictionary = _observation(world, clock, crops) if world.director.is_enabled() else {}
				var advanced: Dictionary = DirectorScheduleRules.advance(world.director.serialize(), outgoing + 1)
				var since: int = int(advanced.enabled_day) if advanced.last_positive_day == null else int(advanced.last_positive_day)
				var evaluation: Dictionary = DirectorCandidateRules.evaluate(PROFILE, snapshot, DirectorScheduleRules.context(advanced)) if index == 0 and bool(snapshot.get("ready", false)) and outgoing + 1 - since >= PROFILE.pity_days else {}
				var choice: Dictionary = world.director.finish_day(token.director.token, snapshot)
				if not choice.ok:
					return _fail("choice rejected day%d: %s" % [outgoing + 1, str(choice)])
				if index == 0:
					if evaluation.get("pity", false):
						stats.pity_checks += 1
						if choice.decision.event.is_empty() or choice.decision.event.is_negative: return _fail("eligible positive pity failed")
					decisions.append(JSON.stringify(choice.decision, "", true, true))
					var event: Dictionary = choice.decision.event
					if not event.is_empty():
						stats.selected += 1
						stats["negative" if event.is_negative else "positive"] += 1
						if event.is_negative:
							var begun: int = int(event.start_day)
							var season: String = str(DirectorSnapshot.calendar(PROFILE, begun).start_day)
							seasons[season] = int(seasons.get(season, 0)) + 1
							if seasons[season] > PROFILE.max_negative_per_season or begun - int(event.decision_day) != 2 or begun - int(advanced.enabled_day) < PROFILE.grace_days or (not negative.is_empty() and begun - negative.back() < PROFILE.min_negative_gap): return _fail("negative bounds/telegraph/grace")
							negative.append(begun)
					var projection: Dictionary = DirectorEffectProjector.project(PROFILE, world.director.serialize(), snapshot)
					if projection.dust_reason == "extra_charge": stats.dust_days += 1
					for id: String in receipts[0].counts: stats.receipts[id] += int(receipts[0].counts[id])
					stats.extra_charges += int(receipts[0].charges) - int(receipts[2].charges)
					if world.director.begin_day(outgoing + 1).ok or world.activity.advance_day(outgoing + 1).ok: return _fail("duplicate accepted")
					stats.duplicate_rejections += 1
			var actual: Dictionary = _wire(worlds[0], clock)
			var scheduled: Array = actual.director.pending + actual.director.active
			var ids: PackedStringArray = []
			for event: Dictionary in scheduled:
				if ids.has(event.event_id) or int(event.end_day) - int(event.start_day) != PROFILE.get_event(StringName(event.event_id)).duration_days: return _fail("duplicate/duration")
				ids.append(event.event_id)
				for other: Dictionary in scheduled:
					if event.event_id != other.event_id and event.mutex_group == other.mutex_group and int(event.start_day) < int(other.end_day) and int(other.start_day) < int(event.end_day): return _fail("mutex overlap")
			# Both native wires have canonical types. Engine deep equality checks
			# every field without an interpreted recursive JSON type walk.
			if actual != _wire(worlds[1], clock): return _fail("individual/batched mismatch day%d" % (outgoing + 1))
			var off: Dictionary = _wire(worlds[2], clock)
			for key: String in ["farm", "weather", "inventory", "wallet", "ecology", "social"]:
				if actual[key] != off[key]: return _fail("off changed core " + key)
			if actual.director_activity.current_day != outgoing + 1 or actual.ecology.day_index != outgoing + 1 or actual.weather.day_index != outgoing + 1: return _fail("day alignment")
			if style == "inactive" and actual.director_activity.current_counts != DirectorActivityCodec.empty_counts(ACTIVITY): return _fail("inactive invented activity")
			if (outgoing + 1) % PROFILE.seasons[0].days_in_season == 0 or outgoing + 1 == days:
				var parsed: Dictionary = JSON.parse_string(JSON.stringify(actual, "", true, true))
				var decoded: Dictionary = saves.call("_migrate", parsed, 14)
				if not DirectorSnapshot._same(decoded.director, parsed.director) or not DirectorSnapshot._same(decoded.director_activity, actual.director_activity): return _fail("save14 changed decoded pair")
				for index: int in range(actual.director.history.size()):
					for field: String in ["event_id", "reason", "seed_used", "rng_state", "day_index"]:
						if not DirectorSnapshot._same(actual.director.history[index][field], decoded.director.history[index][field]): return _fail("save14 changed exact decision/RNG")
				# Native JSON rounds doubles and spells integral doubles differently.
				# The complete decoded wire above must exactly match parsed input;
				# decision identity/seed/RNG stay exact even across that boundary.
				stats.trace_scalar_roundings += _rounded_numbers(actual.director, parsed.director)
				for threshold: Dictionary in PROFILE.ecology.get_thresholds():
					if (float(actual.ecology.metrics[threshold.metric_id]) >= float(threshold.value)) != (float(decoded.ecology.metrics[threshold.metric_id]) >= float(threshold.value)): return _fail("JSON crossed threshold")
				for id: String in actual.ecology.metrics:
					if actual.ecology.metrics[id] != decoded.ecology.metrics[id]: stats.scalar_roundings += 1
				# Both consumers continue from the identical actual decoded checkpoint.
				if not _restore(worlds[0], decoded) or not _restore(worlds[1], decoded): return _fail("decoded continuation rejected")
				var off_parsed: Dictionary = JSON.parse_string(JSON.stringify(off, "", true, true))
				if not _restore(worlds[2], saves.call("_migrate", off_parsed, 14)): return _fail("off restore rejected")
				stats.roundtrips += 1
			stats.days += 1
			if stats.days % 100 == 0: print("[sim_director_progress] %s day%d" % [style, stats.days])
	var next_checkpoint: Dictionary = {}
	if last_day < days:
		var snapshots: Array[Dictionary] = []
		for world: Dictionary in worlds:
			snapshots.append(_wire(world, clock))
		next_checkpoint = {"version": 1, "profile": style, "seed": seed, "target_days": days, "chunk": chunk, "day": last_day, "worlds": snapshots, "stats": stats.duplicate(true), "negative": negative.duplicate(), "seasons": seasons.duplicate(true), "decisions": Array(decisions)}
	return {"ok": true, "complete": last_day == days, "profile": style, "seed": seed, "days": last_day, "target_days": days, "chunk": chunk, "checkpoint": next_checkpoint, "stats": stats, "decision_sha256": "\n".join(decisions).sha256_text(), "director": worlds[0].director.serialize(), "activity": worlds[0].activity.serialize(), "weather": worlds[0].weather.serialize(), "merchant": worlds[0].merchant.serialize(), "negative_per_target_season": seasons, "unavailable": ["woodcutting", "fishing", "water_measurement", "story_unlock"], "continuation": "individual and grouped consumers of identical decoded checkpoints; exact paired decisions and threshold sides checked"}
