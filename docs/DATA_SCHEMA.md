# DATA SCHEMA — THE LIFE

## Phase7.3c baseline policy (D108)

No new Resource or wire field. EcologyLifecycle calibration uses actual validated owned farm at the supplied day: metrics.tree_cover/biodiversity equal sampler targets, water_clarity equals configured profile initial, triggered empty. Water is always unavailable, including a nonzero saved/configured placeholder. Valid saved component with matching day preserves values/history; missing/malformed/day-mismatched component yields explicit calibration reason, never elapsed-day replay or reward. Invalid context/profile/day yields failure and keeps existing owner. Snapshot/sample results are detached; daily helper delegates existing adjacent-day easing. Game save remains12 until7.3e, no current runtime consumer.

## Phase7.3b farm sampling contract (D107)

data/ecology_sampling_config.tres: EcologySamplingConfig with mature_tree_goal:int=8, species_goal:int=8 (positive int32); fruit_tree_ids=orange/apple/banana, each a known perennial repeat crop; species_aliases maps spring_carrot->carrot, summer_tomato->tomato, summer_corn->corn, autumn_pumpkin->pumpkin, winter_radish->radish, winter_cabbage->cabbage. Both source and terminal target must be known crop IDs. No identity/chain/cycle; other crop IDs retain distinct identities. Catalog is explicit Array[Resource] of unique valid CropData with positive int32 growth_days and nonnegative int32 regrow_days. Existing crop/item/save IDs are unchanged.

Sampler farm wire is {plots:Array[Dictionary]} from FarmGridState.serialize(). Each row requires cell_x,cell_y (int32), crop_id (String/StringName), tilled/regrowing/watered/withered (bool), growth_days/growth_target/consecutive_dry_days/withered_days (nonnegative int32). Integral finite JSON floats are accepted/canonicalized; bool/string/fraction/nonfinite/overflow numbers reject. Nonempty crop must be known, tilled, have positive frozen growth_target; regrowing requires repeat-capable CropData. Empty crop must have zero growth_days/growth_target and false regrowing/withered; a cleared plot may retain its old dry counter. Duplicate logical cells reject, even unowned; unknown/malformed unowned rows also reject atomically. Extra metadata is ignored without mutation. Owned regions are Array[Rect2i] with positive sizes and int32-safe exclusive endpoints; empty array means none, overlaps count once. No clipping/deleting/normalizing the source farm or ownership.

Living owned plants contribute healthy_plants and distinct canonical species, even before maturity. Only configured fruit IDs contribute mature_fruit_trees when growth_days>=frozen growth_target or regrowing=true; withered plants never contribute. tree_cover=min(100,100*mature_fruit_trees/goal), biodiversity=min(100,100*species/goal). current_metrics must contain exactly the shipped profile's finite valid metrics, with no fallback. Water target is current water_clarity, available=false. Success targets/counts/available are detached primitives; failure has only ok=false/reason and no partial data. No standalone snapshot format or game-save component changes; Save12 retains all prior bytes/fields. Consumers must treat unavailable water as unmeasured.

### Full-precision standalone JSON writers

EcologySnapshotCodec preserves the numeric values it receives. A standalone writer should use JSON.stringify(snapshot,"",true,true) (full_precision=true) so a value one floating-point step below25/30/50 is not rounded across a threshold by JSON formatting. Native pinned reflection verified this argument and the additive boundary test proves below/equal classification after full-precision round-trip. No existing SaveService serializer is changed, because ecology is not in game saves yet.

## Phase7.3a ecology DATA and independent wire (D106)

EcologyMetricData exports metric_id,minimum,maximum,initial_value,ease_percent,thresholds[{id,value}]. EcologyProfile.metrics is a nonempty Array[Resource] of distinct valid EcologyMetricData; threshold IDs are unique across the profile. IDs are ASCII snake_case. Finite normalized bounds0<=minimum<maximum<=100, initial within bounds, ease_percent in(0,100], threshold numeric values within metric bounds; booleans and nonnumeric nested values reject. All shipped gameplay numbers are in data/ecology_profile.tres: tree_cover/water_clarity/biodiversity bounds0..100/initial0/ease10, birds30/clear_water50/butterflies25. Sources/weights/world count goals and actual new-game baseline remain deferred.

Standalone snapshot: {day_index:int,metrics:{metric_id:float,...},triggered:Array[String]}. Day accepts int or finite integral JSON float0..9007199254740991, canonical int; metrics must contain exactly configured IDs with finite nonboolean numbers in their configured range. Triggered entries must be unique known string IDs, canonical profile order; may remain when current metrics drop. Unknown top-level metadata drops, unknown/missing metric/threshold IDs reject. No past activity is inferred from loaded levels; load never emits or rewards. Returned numbers/arrays/dictionaries are detached. Initial configure history is empty; it does not fabricate historical crossing for an already-high custom initial value. Active side is derived independently from current value>=threshold. This is standalone codec/state wire only: no SaveService version bump/component/migration/golden or runtime ecology field in7.3a.

## AUDIT-F11 storage transaction, unchanged save12 (D97)

JSON wrapper/migrations/goldens remain unchanged. Success publishes primary and up to3ordered historical copies, using existing history in primary/bak1..3 order (compact holes). Temporary .txn_<monotonic>.oldN/.newN.tmp/.movedN names hold exact bytes, not a new save schema. Existing staging names cause failure rather than overwrite. Normal success/rollback removes own redundant staging files; failed rollback retains them and exposes recovery_paths in a transient write report. A completed family with cleanup failure stays a committed success plus cleanup_pending. No automatic loading of staging files or missing-primary power-cut recovery is added.

## AUDIT-F10 read recovery, unchanged wire12 (D96)

Primary slot_N.json and existing .bak1/.bak2/.bak3 use the same JSON envelope/migration0–12. No new serialized field, report, token or backup format. Automatic read fallback is permitted only when primary exists and fails read/JSON/envelope; future primary blocks downgrade, missing primary blocks resurrection. A valid envelope still delegates field normalization to the existing component codecs. Unknown components are retained through read/migration as before. No file is rewritten by recovery; source index/status/error are detached transient reports only.

## AUDIT-F9 envelope validation foundation (D95)

The save wire remainsv12. SaveEnvelopeCodec.decode(raw,current_version) is standalone: root/meta Dictionaries, missing meta/save_version→0, version exact nonnegative JSON integer within9007199254740991. A supported-shape version above the supplied current version is unsupported_future; bad numeric/type values are invalid_version. Preserve all raw component/unknown fields in a detached copy, without normalization or migration. Empty legacy dictionaries retain the former envelope behavior. No new persistent fields or golden changes; valid envelope is not a guarantee that every component is valid.

## AUDIT-F4 scenery presentation Resource (D90)

SceneryArtCatalog has entries:Array[Dictionary] for29canonical PNG IDs and bands:Array[Dictionary] in order rock/grass_clump/flower/pebble/tuft, plus bucket_count100, hash_multipliers(92837111,689287499), bias314159,size_offset(41,11), sizes[small,medium,large],tall_ids[bush,tree_fruit]. Band ends7/18/22/25/30 and variant offsets are view distribution data, not gameplay probabilities. Entry keys/types in API_INDEX. Only rock_large_* blocks; existing collider geometry remains outside this data migration. Positive finite scale, canvas-bounded finite pivot and exact supplied ID/path metadata required. Facade verifies measured image dimensions against imports. Dictionaries returned to callers are detached. No saved fields/version or registry authority added. F4 does not bind this to the world.

## AUDIT-F1 stage data (D87; no save schema change)

New data/crop_stage_config.tres uses CropStageConfig. stage_count:int=4 matches supplied stage1..4 PNGs; repeat_stage:int=3 is one-based and must be >=1 and <stage_count. The stateless helper converts to zero-based indices only at its API boundary. The normal first cycle spans quarters of the actual frozen growth_target; repeat cycles retain stage3 until actual maturity. No texture, balance or per-crop value is edited.

All existing farm wire fields growth_days/growth_target/regrowing/withered/withered_days/consecutive_dry_days/watered stay identical. Stage/mature are derived; neither is added to JSON. SaveService remainsv12; old goldens/fixtures stay byte-identical. Actual maturity still requires sufficient owner days and a living plot even if image4 is visible during the last quarter. F1 test/verification status is in PROGRESS, not inferred from this schema.

## Phase7.1b weather day wire / tagged RNG (D86)

Supersedes7.1a's pending runtime integration status below. WeatherProfile adds initial_weather_id:StringName; shipped sunny. It must resolve in entries even when weight0. forecast_days3 and every entry/order/probability55/25/15/5/darkness/rain/storm flag stay unchanged. Fresh future roll uses DetRandom.make_rng(world_seed,absolute_day,TAG_WEATHER1). Merchant tag8/algorithm stays. Current initial weather is DATA, not a random draw.

Save v12 weather={world_seed:int,today:String,forecast:Array[String],day_index:int}. Seed admits signed exact-JSON integers +/-9007199254740991; day is nonnegative with day+horizon<=that limit. Finite integral JSON floats canonicalize to int; booleans/strings/fractional/unsafe numbers reject. Known String/StringName IDs and exactly configured forecast count required; known zero-weight choices remain valid. Extra fields drop; output arrays detach. Standalone decode stays3-field; decode_at_day requires4 and optional matching clock.

Migrate11->12 deep-copies and binds valid legacy3 to saved clock.day_index without changing today/seed/any forecast choice/order; all older migrations reach that boundary. Empty/missing weather stays{} at SaveService. Current12 must have valid matching day. Malformed weather warns/normalizes{} with all other components retained; Main uses explicit baseline seed0/initial sunny and future draws at actual loaded day. Repeated valid load never draws. Ordinary WeatherState.deserialize invalid input retains existing owner instead. New/tail generation intentionally differs from legacy arithmetic RNG; the first three valid saved pre-rolls continue unchanged, only needed new tail uses tag1.

weather_rng_v12.json is a captured pinned4.7.2 RNG golden (30 signed/large seed/day vectors, tag1 weather and tag8 merchant draws); source capture/log retained externally. save_v12.json copies v11 with only metadata12/weather.day_index30. Old save_v1..v11 and weather_snapshot_v11 compatibility fixture remain unchanged. Watering introduction10 and coop ownership11 still apply. Tokens/busy/events/debug view state never serialize; save only at committed safe point.


## Phase7.1a weather-profile and snapshot contract (D85)

WeatherProfile adds forecast_days:int, shipped=3. Existing four ordered weather entries retain IDs sunny/cloudy/rain/storm, weights55/25/15/5, darkness0/.12/.24/.34 and rain/storm flags. Profile validation rejects empty/duplicate/non-string/non-ASCII-snake IDs, noninteger/negative/unsafe weights, nonpositive or unsafe total, nonpositive/unsafe horizon, nonfinite/out-of-unit-interval darkness, nonboolean flags and storm without rain. MAX_WEIGHT_TOTAL2147483647 is a numeric integrity bound. Zero weight is permitted when total is positive.
Existing wire shape remains {world_seed:int,today:String,forecast:Array[String]}. Pure WeatherSnapshotCodec requires all fields and known IDs, exact profile horizon, Array/PackedStringArray container. Seed accepts signed int/integral JSON float within +/-9007199254740991, canonicalizes to int; no bool/string/fraction/nonfinite/range coercion. Valid StringName IDs canonicalize to String. Known zero-weight IDs remain valid saved forecasts; choices never reroll. Unknown extra fields drop; result is detached. Invalid input returns {ok:false,errors:PackedStringArray}, never partial/default weather.
Fixture tests/fixtures/weather_snapshot_v11.json derives from actual unchanged golden11 weather; it is a codec sample, not an RNG golden. This helper is not runtime-connected: WeatherState/Main/SaveService/savev11 and old malformed-load behavior remain unchanged until separately planned integration. No last-day field, migration, fallback, new weather ID/probability/seasonal mechanic or additional saved state is introduced. Metadata forecast_days is not yet consumed by legacy WeatherState.


## Phase6.7 recipe-validation policy (D84)

New data/recipe_economy_config.tres owns max_value_added_per_game_hour_by_unlock_level={1:15,2:40,3:120} and game_hours_per_day=24. Owner explicitly approved associating these ceilings with existing RecipeData.unlock_house_level for VALIDATION ONLY. This supersedes ambiguous use of the older generic stage table for recipes; it does not create a runtime house/player-stage progression system. Recipe duration_days remains actual production data: one day converts to24 game hours for value comparison, regardless of waking hours or real-time speed.
Gate: sum(outputs.sell_price*quantity)-sum(inputs.sell_price*quantity) <= configured_cap * duration_days *24. Use current ItemData opportunity sell values, not historical sample prices or often-zero buy values. Enforce positive integer quantities/durations, nonnegative integer prices, valid/unique IDs/references/reciprocal machine links, actual machine slot limits and current exactly-one-output support. Reject missing tiers and checked int64 product/sum overflow; do not round fractional excess away.
Existing recipes/items/machines and every price/unlock/duration stay unchanged. All seven temp outputs remain buy0/sell0 and cannot be treated as positively balanced sale products. Normal gate may pass their nonpositive added value while reporting zero-sale output count. Deliberate copied output yielding361 above tier1 one-day360 bound fails. No .tres fixture writes or live registry mutation. Current crop Resource ceiling80, all old goldens and savev11 remain unchanged; no new save schema.


## Phase6.6d purchased coop component / save v11 (D83)

Approved700-coin bundle includes4 hens; separate food20/egg30/wheat42 unchanged. New ChickenCoopSiteConfig Resource data/chicken_coop_site.tres stores site_id home_coop, purchase_price700, initial_hens4, footprint Rect2i(10,14,2,2), entrance(10,13), axis-aligned access_route[(3,6),(6,6),(6,8),(7,8),(7,13),(10,13)], clearance1 and actual world/land/coop_config references. Validate bounds, positive integer terms/capacity, disjoint static/water/farmland geometry and clear actual route; shoulders clear passive scenery only. Price not embedded in gameplay scripts. No existing world/NPC/land/animal/item Resource changes.
Root savev11 field: chicken_coop={owned:bool,coop:{current_day:int,hen_count:int,fed_hens:int,pending_eggs:int}}. Stable inner codec unchanged; wrappers validate exact day against saved clock, numeric whole safe integer range, hens<=capacity, fed<=hens, owned requires positive hens; unowned requires0 hens/fed/eggs. Integral JSON floats canonicalize to ints. Unknown extra component fields drop. Missing/wrong/inconsistent animal component warns and defaults unowned/empty at saved day. Old v1-v10 always gets that default even if a forged unknown coop field was supplied. Valid other progress remains.
Tokens, reservation counts, collision/navigation geometry, modal selection and busy flags never serialize; do not save during a reservation. New empty games get0 hens/food; the700 purchase supplies the approved4 once. Every fed hen produces configured1 egg at exactly one completed-day transition; missed feed produces0 and never kills hens. Full bag retains whole pending egg buffer. Version11 golden added; v1-v10 goldens untouched. Water introduction remainsv10, so existing partial/empty upgraded water values survive current v11 migration/runtime restore.


## Phase6.6c food data and feeding reservation (D82)

Owner explicitly selected separate feed buy20/egg sell30. New chicken_feed.tres ItemData: ID chicken_feed, keys ITEM_CHICKEN_FEED_NAME/ITEM_CHICKEN_FEED_DESCRIPTION, category material, max_stack99, buy_price20, sell_price0, empty visual paths with generic fallback. Egg30, autumn_wheat42 and all old crop/recipe/balance Resources stay unchanged. Price is prepared DATA; current SeedShop lists seeds only, so no store availability is claimed.

ChickenCoopConfig adds required feed_item_id:StringName, shipped=&chicken_feed. Numeric hen_capacity4/feed_per_hen1/eggs_per_fed_hen1 stay. Pure validation checks nonempty identity and old integer bounds; tools/validate_data.gd verifies identity resolves among logical ItemData, all required keys, and unchanged18 historical visual assets. New food is a fallback logical item like egg, not an invented3D asset. No save schema change follows from this Resource configuration field.

feeding_quote returns actual ID/required units/current day/positive unfed hens. begin_feeding returns opaque identity and captures requested hens; it grants none yet. A truthful whole InventoryState.remove_item bool determines finish: true commits captured hens; false grants0 and releases. Config/ref changes during notifications cannot change the already authorized debit or strand paid hens. Shared busy excludes either operation across facades/raw mutation; old collection reason remains collection_busy, feeding uses feeding_busy.

Standalone wire shape stays {current_day,hen_count,fed_hens,pending_eggs}; tokens/reserved counts never serialize. Paid daily feed retains fed_hens on valid JSON restore; only legitimate completed day produces eggs. Currentv10 inventory can persist registered food/remaining stock without new fields/goldens/migration; the coop itself remains outside actual game saves. Never persist busy diagnostic snapshot. No full-inventory rollback, free food/coin grant or player-facing feeding/world/shop feature is added.


## Phase6.6b egg ItemData and transient transfer protocol (D81)

New data/items/egg.tres: item_id=egg, display_name_key=ITEM_EGG_NAME, description_key=ITEM_EGG_DESCRIPTION, category=produce, max_stack99, buy_price0, sell_price30 from the documented product table. No custom model/icon is assigned; current generic icon fallback is used. Both locales contain the two new keys. DataRegistry and validator logical-item set include egg; historical visual validation retains exactly its18 old item paths, not a guessed egg3D asset.

ChickenCoopState wire data remains {current_day,hen_count,fed_hens,pending_eggs}; reservation token and reserved quantity never serialize. During transfer pending buffer is reserved/cleared and state is_busy; configure/deserialize/raw feed/day/take/other reservations cannot mutate it. Only matching opaque identity plus valid untransferred amount may settle. This busy snapshot is not a safe persistence boundary; runtime lifecycle/save integration is deferred. Valid completed idle codec behavior and all old goldens remain.

Normal collected result reports item_id/quantity/remaining0 after one complete InventoryState grant. Failed whole-capacity preflight preserves both owners. A zero-grant rejecting double restores all reserved eggs; a valid partial-grant fault retains actual added eggs and restores only untransferred remainder, reporting partial_transfer explicitly. No fabricated quantity or global inventory rollback. The command assumes existing InventoryState's truthful added-count contract; invalid settlement remains locked/fail-closed instead of releasing a duplicate buffer.

Existing inventory slots/savev10 already support registered egg IDs/quantities with no schema/version/migration change. Only collected bag stacks persist; no coop field is added to game saves. Generic selling where supported reads30 from ItemData; no sale/shop source change. Wheat42/current crop balance and historical wheat20 feed-profit assumptions are unchanged and still not mapped to a player feeding command.


## Phase6.6a standalone chicken-coop data/codec (D80)

New data/chicken_coop_config.tres exports hen_capacity=4, feed_per_hen=1, eggs_per_fed_hen=1 from the documented coop rules. Values live only in the Resource; missing/zero/negative/unsafe terms or full-herd feed/egg products beyond JSON exact integer precision are invalid. No new price, feed ItemData/icon binding, registry entry, buffer balance cap or actual herd grant.

ChickenCoopState standalone wire shape: {current_day:int,hen_count:int,fed_hens:int,pending_eggs:int}. All are nonnegative ≤9007199254740991; hen_count≤configured capacity, fed_hens≤hen_count. Configure with explicit valid day/herd before deserialize. All four keys are required; valid integral JSON floats canonicalize to ints. Unknown extra keys ignored, never serialized. Any missing/wrong-type/null/bool/string/collection/nonintegral/nonfinite/negative/oversized/inconsistent known field rejects the entire payload with warning and retains prior snapshot; no partial grant/clamp or output loss. Invalid initialization is inert empty; invalidated config blocks commands while retaining fields. Config references/ready flag do not enter wire data.

feed is an internal authorization primitive over hen counts only and returns configured required feed_units; no item is removed here. advance_day accepts exactly current_day, buffers actual fed-hen yield once and clears daily feed. No feed means zero eggs and no deaths. Pending eggs persist across days; integer overflow blocks a command before mutation. Exact take_eggs returns documented egg token and entire current amount once, not a registered ItemData/bag transfer. Runtime purchase/feeding/collection/save integration is not implemented by this codec.

Existing master table uses wheat20/egg30 economics, but current registered autumn_wheat sells42. Do not silently equate/reprice that item or promise the historical10 profit. Mapping/balance remain a future owner decision. SaveService.CURRENT_VERSION remains10; no animal field/golden/migration or game-save change, all older progress preserved.


## Phase6.5h3 upgrade presentation and ledger metadata (D79)

No Resource value or save schema/version change. Existing data/watering_can_config.tres remains base20, target40, price200; runtime UI uses the actual configured terms and existing domain command. Successful upgrade preserves0/partial/full remaining water; only existing source refill fills current capacity. Main saves/restores upgraded40 and actual charges through unchanged savev10. No saved upgrade flag, panel/quote/result/busy or new owner; all goldens stay.

Both locales add18 WATER_UP_ keys: ACTION, TITLE, DESCRIPTION, CAPACITY (two ints), PRICE/WALLET/REMAINING (one int each), BACK, CONFIRM, AVAILABLE, SUCCESS, COMPLETE, NO_COINS, STALE, BUSY, REFUND, INVALID, LEDGER. Validator requires all18. Existing Theme/native controls reused; no asset changes.

Existing buy_watering_upgrade negative debit is expense. Existing buy_watering_upgrade_rollback positive refund reduces expense, never adds income. Day-end label is WATER_UP_LEDGER / END_REFUND. Signed ledger entries and serialization format remain unchanged; independent real transactions remain. Later80/600/1800 mapping remains deferred, not inferred.


## Phase6.5h2b game-save v10 and water display (D78)

Top-level watering_can:{capacity:int,charges:int} is added to SaveService/Main payloads; CURRENT_VERSION10, new migrate_9_to_10 deep-copies the previous save. Oldformats1..9 had no water owner: initialize base_capacity/base_capacity from data/watering_can_config.tres (currently20/20) regardless of any forged earlier field. Old golden files remain unchanged; new save_v10.json preserves v9 sample progress and adds20/13 with metadata10. Upgrade40/200 Resource and state codec are unchanged; known40 capacity can load but no purchase UI is introduced.

Currentv10 missing/wrong-type can data goes through existing WateringCanState.deserialize({}) and restores empty base, never a legacy grant. Known20/40 partial/full/empty quantities persist; malformed/nonintegral/unknown values remain conservative, excess valid charges clamp. SaveService reuses the existing codec as a temporary read validator and returns canonical integer water fields; no second persistent state owner. Raw JSON numeric variants are converted by that codec to authoritative ints. Direct legacy _load_payload without new metadata uses explicit fresh legacy default; real SaveService rejects unsupported/malformed envelopes as before. No saved source/Node/UI/busy/revision field.

Main new game explicitly creates full base. Load/Continue/slot switching, dirty/autosave/title and completed day-end preserve actual quantities; rain/bulk/overnight do not debit/reset manual water. Only real manual watering success debits1 through existing WateringService. Source refill is free and instantaneous at actual dry banks after authorization; no new cost/reach/cooldown/balance value is invented. Source geometry/IDs/world/camera/ownership data stay unchanged.

New six vi/en keys: WATER_CAN_COUNT (two integer placeholders), WATER_CAN_EMPTY, WATER_REFILL_HINT, WATER_REFILLED, WATER_CAN_FULL, WATER_REFILL_UNAVAILABLE. Existing watering_can icon/Theme caption variation is reused; display strings/numbers live in CSV/Resources. Low-level state refill remains trusted internal mutation, not player permission. D71 replacement revision still guards older debit refunds and is excluded from save.

## Phase6.5h2a fixed water sources and expanded bounds (D77)

`data/water_sources.tres`: WaterSourceConfig references the existing world Resource. sources:Array[WaterSourceData], clearance_cells=1; water/shore/path/well Color palette. Each entry has unique snake_case source_id, kind well/stream/pond, localized display_name_key, positive Rect2i region within playable bounds, label_cell inside region, and nonempty orthogonal in-bounds access_waypoints:Array[Vector2i]. Well footprint is exactly1×1. Resource checks reject malformed geometry before domain operations; domain checks reject overlap with other sources, original solids (except exact old well), base/planned farmland, anchors or submerged/protected approach cells; last approach cell must be dry adjacent bank.

| ID | Kind / region | Label / dry approach end | Name key |
|---|---|---|---|
| home_well | well / (8,9,1,1) | (8,9) / (7,9) | WATER_SOURCE_WELL |
| forest_stream | stream / (-16,-7,2,14) | (-15,0) / (-14,6) | WATER_SOURCE_STREAM |
| east_pond | pond / (16,8,4,4) | (17,9) / (15,9) | WATER_SOURCE_POND |

All routes begin(3,6), outside the original farm: well via(6,6),(6,8),(7,8); stream directly west; pond via(6,6),(6,8),(15,8). Existing player spawn(3,3) reaches this shared point through ordinary passable farm. Clearance reserves passive scenery only, grants no land or interaction.

IsometricWorldConfig actual map_region=(-40,-40,85,85), player_region=(-18,-18,39,39), new scenery_region=(-20,-20,43,43). All are positive/nested in map; region values are logical cells. Camera center(-2368,-1120)..(2496,1312) comes from actual grid projection; pan(-2600,-1400)..(2600,1400), existing five zoom/default/follow/offset unchanged. Generic Resource defaults remain legacy-sized for compatibility; the active .tres owns expanded values.

WorldLocations adds optional water_sources; original solid_rects retained. get_solid_regions returns a detached deduplicated list; exact(8,9,1,1) well prop reused. Current NPC nav_region/target IDs unchanged. None of this static data is saved: savev9 and existing progress remain unchanged, no can charges/refill/HUD is activated. No source geometry is duplicated in save/state/renderer logic.

## D72-C1 camera data and offline art contracts (D73)

IsometricWorldConfig exports camera_pan_min Vector2(-1400,-800) and camera_pan_max Vector2(1400,800), moving inherited presentation constants into its Resource. Components must be finite, minima strictly below maxima, with zero included for player-centered reset. Camera center/follow/offset/map/player/interaction data and inherited five zoom levels/default0.5 are unchanged. These are VIEW parameters, not save/gameplay balance.

Offline generated draft files (not live renderer bindings): assets/buildings/cottage_2x.png160x140, market_2x.png140x128, shipping_bin_2x.png96x88; assets/characters/farmer_sheet_2x.png256x64 (four64px frames); assets/ui/frame_wood_9slice.png96x96. DataValidator.validate_isometric_2d_assets checks actual PNG bytes/dimensions. The active procedural avatar/world/frame components continue preserving six appearance choices and shared Theme.

Generator optional --output-root affects only offline output location, default res://assets. Two user:// regenerations must match each other and inherited source bytes; write/dir failure must return nonzero. Existing source images/import metadata are not rewritten by the completion task. No new data IDs/item values/save field/version; Main staysv9. Camera pan and cosmetic animation state remain transient.

## Phase6.5h1 watering config and standalone serialization (D71)

New WateringCanConfig at data/watering_can_config.tres: base_capacity20, upgrade_capacity40, upgrade_price200. Owner explicitly approved assigning200 to the first20->40 transition; ambiguous later600/1800 prices and80 capacity remain unassigned/deferred. Upgrade preserves remaining water. Pure Resource validation requires positive capacities/price, strictly increasing target and values <=9007199254740991 (external JSON precision bound, not gameplay balance). All quantities/coins remain integers.

Standalone can wire format is {capacity:int,charges:int}. Configure creates fresh20/20. Deserialize accepts known20/40 capacity and finite integral JSON numbers only; absent/malformed charges become0, excessive valid integer charges clamp to capacity, unknown/malformed capacity restores empty base20/0. Invalid configuration/unconfigured state remains0/0 and unusable. Missing saved charges are distinct from fresh initialization; future old-save migration is not inferred here.

The refill replacement revision is transient and excluded from JSON; real refill/configure/deserialize invalidate earlier reservation credits, whereas consumption and capacity-only upgrade preserve the revision. Only trusted internal commands use raw refill/refund. No Node/Resource/pixel/UI or purchased flag is saved.

Payment reasons buy_watering_upgrade and buy_watering_upgrade_rollback are explicit domain command metadata. This slice does not wire wallet commands into Main, change current ledger classification or add player-facing purchase/refill UI. Main/SaveService still usev9 with no watering field; old goldens remain byte-identical. Later integration must add a deliberate migration/default rather than claiming these standalone round trips are a game save.

## Phase6.5g first bag tier (D70; save remains v9)

New data/bag_upgrade_config.tres (BagUpgradeConfig) exports base -> existing inventory_config.tres, additional_slots=12, purchase_price=300. Base remains40/8columns/5visible rows. Target is configured base capacity plus increment (=52). The progression master-plan stage1 supplied +12/300; D70 explicitly adapts this to the newer40-slot baseline. No later price/tier or watering interpretation.

BagUpgradeConfig.validation_errors() is pure data validation: positive/matching base dimensions, positive integer increment/price, and target within shared MAX_CAPACITY4096. InventoryState.MAX_SAVED_SLOTS aliases that unchanged external-input integrity bound; it is not a gameplay upgrade. This keeps DataValidator --script mode independent of autoload-dependent InventoryState/WalletState service compilation.

No saved field or version is added: existing inventory:{capacity:int,slots:Array} stores the52 result. Capacity>=target means complete and cannot be charged for this tier. Larger legacy bags keep their capacity/stacks; intermediate capacity raises to the shown52 target for the same shown300 price. Never shrink/truncate. Existing clear() retains capacity; Main New Game deliberately resets40/empty before starter seeds. Historical goldens stay unchanged, and actual v9 integration tests keep land/crop/machine/job/wallet fields.

Signed ledger reasons buy_bag_upgrade / buy_bag_upgrade_rollback identify payment/refund; failed refunded operations have no fabricated income. UI quote/result/expected-capacity/busy state is transient, never saved. Current Resource values and ownership are authoritative at confirmation.

## Phase6.4b game save v9 and parcel captions (D69)

ExpansionParcelData adds optional display_name_key:StringName. Shipped first_east.tres uses LAND_EAST_NAME in vi/en; synthetic domain fixtures need no caption. IDs/geometry/prices and LandExpansionConfig are unchanged. New translations are included in the existing data-validator localization gate.

Save v9 adds top-level land_ownership:{owned_parcels:Array[String]}. Base36 cells are implicit in the Resource; only the known ordered purchased prefix is serialized. Main configures the existing state before guarded deserialize and rebuilds permissions/passive scenery. Missing/wrong-type ownership defaults safely to base; domain rejects malformed/unknown/non-prefix grants with warnings. No saved UI/Node/pixel geometry.

migrate_8_to_9 deep-copies existing fields and explicitly sets purchased rights empty, even if an old payload happens to contain a field of that name. It does not infer a purchase from old crops/machines. Existing out-of-base tilled plots and placed machines remain usable through the explicit compatibility policy without granting surrounding empty land. v1-v8 golden files are unchanged; save_v9.json preserves the v8 sample plus farm_east_1 ownership and version9. Prior foundation-only/v8 notes below are historical.

Land purchase ledger reasons are buy_land (negative actual price) and buy_land_rollback (positive refund treated as reduced expense). Refunds never become earnings. Ownership pricing remains integer-only, Resource-backed and unchanged from D68.

## Phase6.4a expansion Resources and standalone state (D68)

Approved mapping: data/land_expansion/first_east.tres -> ExpansionParcelData, parcel_id farm_east_1, region Rect2i(6,0,6,6). data/land_expansion_config.tres -> LandExpansionConfig with initial_region Rect2i(0,0,6,6), ordered typed parcel array containing only that Resource, base_cost500, growth_numerator11, growth_denominator5, rounding_step50. It references existing data/isometric_world_config.tres and data/npcs/phase8_world.tres for bounds/static exclusions. Existing land_parcels.tres remains the separate legacy placement-lock list; no IDs/coordinates there change.

Price order is1-based: nearest50 of500*(11/5)^(n-1), positive ties rounded upward, using only checked integers/GCD reduction. The first five quotes are500/1100/2400/5300/11700; later formula examples do not register later parcels. Invalid integer parameters/order or unsafe intermediate/rounding overflow return explicit failure, never free/negative/wrapped costs. A quote can fail when exact intermediate rational arithmetic exceeds signed64-bit storage even if an approximate final price might fit; no floating approximation or gameplay cap is silently introduced.

Standalone LandOwnershipState serializes {owned_parcels: Array[String]} as a known catalog prefix. configure precedes deserialize; malformed field types/unknown IDs/duplicates/out-of-order grants are ignored with warnings. Base cells need no saved grant; cells outside configured owned regions never unlock. No Node/Resource/pixel/UI state is serialized.

This is not a new game-save field/version: Main/SaveService remain unchanged atv8. Runtime integration must add authoritative ownership plus migration/goldens/tool/build/scenery/UI wiring in a later approved slice. The proposed east36-cell region fits world/player/static solids but is not cleared/reachable-certified for farming: existing scenery and linh_stream waypoint remain. No player-facing purchase is exposed yet.

## Phase6.5f transient relocation context (D67)

No Resource or save schema/version change. Move mode keeps an unsaved detached dictionary with current typed machine_id:StringName, cell:Vector2i and rotation:int from get_placement. Request validates those fields and exact equality with the actual placement before every preview/command. Identical fungible equipment has no placement-instance ID; no persistent identity is added. Original placement/job/owned-count payloads and v1-v8 goldens remain.

Different-cell move updates the existing cell/rotation/occupancy through D65 and clears only verified empty source/destination jobs after success; failure rolls snapshots back. Stock/bag/wallet/crops remain. Same-cell idle rotation/no-op preserves jobs, even at an older cropped/outside-region source because it occupies no new cell. Preview, cancellation and interruption never reserve/remove the original machine. Transient source/ghost/status/result are not serialized.

## Phase6.5e placement configuration (D66, 2026-11-04)

`data/machine_build_config.tres` uses `scripts/data/machine_build_config.gd` (MachineBuildConfig Resource), exporting `allowed_region: Rect2i`. Current value Rect2i(0,0,6,6) restricts new mouse placement to cells0–5 on each axis, the existing reserved farm footprint. Validation requires positive dimensions and enclosure by the actual world map. Reach is read from the existing IsometricWorldConfig; footprint/valid rotations remain the existing placement constants. No machine/crop/recipe/price/land data is changed.

The request adapter contains references/context only, with no persistent state or serialization. Selected machine/cell/rotation, preview/result, ghost, lazy controls and input-release gate are transient VIEW state. Save-v8 placement/job/owned-count rows and all v1-v8 goldens remain unchanged. Cancel/interruption never reserves stock; successful placement/idle return updates only existing owners. Old placements outside this region remain saved and can be returned when nearby/idle. No automatic plot conversion, orphan repair, refund or new schema.

## Phase6.5d placement/job lifecycle (D65, 2026-11-04)

Save version8 and all existing field/row shapes remain unchanged. An empty idle job means status idle, empty recipe/output/planned-output IDs, zero remaining days and zero output/planned quantities, with a registered machine ID and matching logical cell. Only such rows can be removed after a successful build command. Valid empty destination rows may belong to previously removed equipment; preview validates them before placement and cleanup validates their emptiness independently after replacement. Active/buffered/corrupt/orphan rows remain stored on a rejected edit; there is no load-time repair or migration.

Different-cell idle move clears the old/destination empty rows while preserving the placement's machine ID, selected valid rotation and total owned count. Returning an idle machine grants exactly one existing machine count and clears only its empty job. New placement cannot reattach a prior active output. Rotation/same-cell move preserves the complete job row. Cleanup failure rolls back placement/owned/job snapshots, and the transient collection guard blocks edits while output is reserved. No wallet/item/day/balance/resource change or new saved UI state is introduced.

## Phase 6.1 machine processing (D57, 2026-11-04)

- `MachineData` resources live in `data/machines/` and use the supplied seven machine IDs. `sprite_dir` points to `assets/machines/<id>/`; the manifest provides idle, work_a and work_b stems plus the 128x152 canvas and `(64,120)` pivot. The `1x` files are retained for later VIEW use.
- `RecipeData` resources live in `data/recipes/`. `inputs` and `outputs` are arrays of `{item_id, quantity}` dictionaries; `duration_days`, `machine_ids` and `unlock_house_level` are data-owned.
- `MachineState` is a serializable domain object with `machine_id`, logical `cell`, `recipe_id`, `days_remaining`, `status` (`idle`, `working`, `blocked`) and one output buffer. It consumes inputs only after all requirements pass, advances on completed game days, and never loses output when blocked.
- Phase6.5b/D63 registers the existing processed-output IDs as ItemData and localizes their approved interim labels; their IDs remain unchanged in recipes, buffers and bag saves. Final art/trade prices remain deferred.

## Phase6.5b processed output items (D63, 2026-11-04)

Each Resource is `data/items/<item_id>.tres`, category `other`, max_stack99, buy_price0/sell_price0, existing generic icon fallback, shared `ITEM_PROCESSED_DESCRIPTION`. No eating/XP/stamina/trade effect is introduced. Quantity/duration/input values remain owned by the unchanged recipes.

| Existing item_id | display_name_key | vi / en |
|---|---|---|
| temp_carrot_meal | ITEM_TEMP_CARROT_MEAL | Món cà rốt / Carrot meal |
| temp_wheat_flour | ITEM_TEMP_WHEAT_FLOUR | Bột mì / Wheat flour |
| temp_roasted_coffee | ITEM_TEMP_ROASTED_COFFEE | Cà phê rang / Roasted coffee |
| temp_corn_bread | ITEM_TEMP_CORN_BREAD | Bánh ngô / Corn bread |
| temp_dried_chili | ITEM_TEMP_DRIED_CHILI | Ớt khô / Dried chili |
| temp_pickled_cabbage | ITEM_TEMP_PICKLED_CABBAGE | Bắp cải muối / Pickled cabbage |
| temp_orange_juice | ITEM_TEMP_ORANGE_JUICE | Nước cam / Orange juice |

Safe collection requires a ready buffer matching the registered single-output recipe and whole-quantity bag capacity. Inventory entries keep `{item_id, quantity}`; MachineState/MachineOperationService payloads and SaveService version8 are unchanged. A successful transfer empties the job buffer and stores the same ID/quantity in inventory. Full/unknown/invalid failures preserve both owners. The `_collecting` flag, UI feedback/focus/selected cell are transient and never saved. Old v1-v8 goldens remain unchanged.

## Machine Shop ownership (D58, 2026-11-04)

- `MachineData.purchase_price` stores the temporary shop price: stove 250, mill 350, press 450, barrel 500, oven 600, dryer 700, roaster 900. `unlock_house_level` stores 1, 1, 2, 2, 2, 2 and 3 respectively.
- `MachineInventory` serializes as `{"machines": [{"machine_id": "stove", "quantity": 1}]}`. Counts are positive integers and unlimited by design.
- Save payloads add `machine_inventory`; `SaveService` retains it at save version 8 and migration defaults it to `{}` for older saves.

## Phase 6.2 placement (D59, 2026-11-04)

- `data/land_parcels.tres` owns the locked-cell list. Domain code does not embed parcel coordinates.
- Machine placement rows serialize as `{"machine_id": "stove", "cell": "2,3", "rotation": 90}`. All current machine footprints are `1x1`; rotation is logical metadata only until directional sprites exist.
- Save payloads add `machine_placements`; old saves default to an empty placement list without a save-version bump.

## Phase 6.3 build mode domain (D60, 2026-11-04)

- `MachineBuildService` is a stateless command adapter over the serializable placement state. It does not add machine data, prices, recipes or save fields.
- Move and rotate operations preserve the current `1x1` footprint, reject locked or occupied cells and restore the original placement on failure.
- Removing a machine is the approved return-to-inventory behavior. Coin refunds, ghost previews and rendering remain outside this domain slice.

## Phase 6.4 machine operation (D61, 2026-11-04)

- `machine_operations` is an added save payload containing serialized `MachineState` rows keyed by their logical placement cells. Missing data defaults to an empty object.
- The runtime registers the seven supplied recipe Resources through `DataRegistry`; no recipe balance or output ID is changed.

## Phase 6.5 machine presentation

- Machine visuals are view-only children under the world Objects layer. Their authoritative identity remains `{machine_id, cell, rotation}` in `MachinePlacementState`; the sprite uses the manifest's `pivot_2x` and does not save pixel coordinates.
- Mouse selection is converted through `GrayBoxWorld.pick_cell()` and is never persisted.

## ISO-6b1 implemented crop balance / save v8 (D42)

Current gameplay values for new sowing and market quotes:

| Crop | First cared-for days | Repeat days | Seed buy | Produce unit sale | Yield |
|---|---:|---:|---:|---:|---:|
| spring_carrot | 3 | 0 | 20 | 35 | 2 |
| summer_tomato | 5 | 2 | 35 | 72 | 2 |
| turnip | 4 | 0 | 25 | 45 | 2 |
| summer_corn | 7 | 0 | 35 | 100 | 2 |

Other five crops and all IDs/stack limits/seasons/care/art are unchanged. Seed resale values are unchanged. Current-MVP crop return ceiling is 80 coins/plot-day in data/crop_economy_config.tres, explicitly approved instead of the historical starter example 18 below. Validate (yield*unit_sale - seed_buy) <= ceiling*growth_days and, for repeating crops, yield*unit_sale <= ceiling*regrow_days, with positive/bounded inputs and integer arithmetic. Existing unit-sale > seed-buy and slower-crop price invariants remain. No other economic/recipe ceiling is changed. Ideal 28-watered-day tomato picks are days 5,7,...,27: 24 produce, net 1693; this is provisional approved balance, not a final-playtest claim.

farm.plots add growth_target: int and regrowing: bool. New planting freezes first-growth Resource duration; tomato harvest resets growth_days=0, growth_target=2, regrowing=true, preserving crop/cell/moisture/dry streak. Other crops retain removal behavior. Missing care/season/wither rules apply in every cycle; full inventory blocks the action before changing phase. There is no seed cost or automatic watering at repeat harvest.

v7 -> v8 assigns prior first-growth targets from data/crop_migration_v7.tres and regrowing=false while retaining all previous fields. Historical targets: turnip2, carrot3, pea3, tomato4, corn4, wheat3, pumpkin5, radish3, cabbage4. Old mature plants stay mature and immature plants keep their remaining growth days; new sowing uses the new table, repeat cycles use the current repeat duration. v1–v7 fixtures stay read-only; v8 fixture contains an active repeat crop and an old-target withered mature crop. Direct domain restore without a target defaults to current data; version-aware SaveService migration supplies historical targets for old saves.

FarmSaveCodec retains care/coordinate/ID validation and validates new targets against the current/historical first duration or exact repeat duration. Invalid/unsafe targets fall back to current data; repeat flags are strict booleans and only allowed on repeating crops. Copies preserve source snapshots, and decode returns explicit success/failure. A native-int32 bound protects wire coordinates/growth; economy rule bounds protect int64 products, not gameplay progression limits. Growth/coin/quantity state stays int.

Fertilizer effect/item and house-level corn gating remain unfinished, awaiting their own usable systems/specification; corn availability is unchanged in this slice. No fake shop entry or upgrade is created.

## ISO-6a implemented daily care / save v7 (D41)

- CropData.max_consecutive_dry_days: int = 0 by default; every shipped crop Resource explicitly supplies 2. Water-requiring crops must have a positive threshold; water_need=0 ignores dry care. Existing growth_days/yield_qty/seasons/IDs and all prices remain unchanged pending ISO-6b.
- farm.plots entries add consecutive_dry_days: int. New planting initializes 0; manual/rain care resets 0; an unwatered finished day increments toward the crop threshold and pauses growth. At threshold the existing withered flag becomes true. Ripe plants still need care. Withered plants never grow, receive water, revive or yield; clearing/replanting starts new care state.
- Current-day rain is resolved before the single finished-day farm simulation; new weather/rain is applied after it to surviving morning plants. No delta/timer growth or second sleep path.
- Save v7 migration initializes unknown old dry history to 0 without changing any old plot field, slot, balance, ledger, guard or profile/social/weather/clock progress. v1–v6 goldens stay read-only. v7 golden covers dry=1 living and dry=2 withered mature plots. Missing counters also default 0 during direct domain restore.
- Restored counter must be numeric, finite and integral; invalid types/fractions/NaN/infinity warn and default 0. Negative values clamp to 0, excessive values to the Resource threshold; reaching threshold sets terminal withering. Water-free/empty plots clamp to 0. Unknown crops/invalid rows and nonintegral/nonfinite/outside-int32 coordinates/growth are warned and skipped; malformed whole plot arrays retain previous farm. Valid neighbours survive; no broad top-level save rewrite.

## ISO-5 implemented inventory/save v6 additions (D40)

- data/inventory_config.tres (InventoryConfig): default_capacity=40, columns=8, visible_rows=5; positive integers, capacity must equal columns × rows. Explicit small-capacity constructors retain their meaning.
- ItemData adds category: StringName in seed/produce/tool/material/other (default other), description_key: StringName (optional, localized when present). Current resources only add metadata; prices/max_stack/ids/icons remain unchanged. Tool/material filters are empty because no such item stacks exist.
- v5 -> v6 floors inventory.capacity to configured default while retaining larger legitimate capacities and every slot in the same order. All prior clock/player/farm/profile/wallet/quest/social/day_ledger/day_end fields remain. v1–v5 fixtures are read-only; save_v6.json is new. Revision is transient, never saved.
- Inventory restore accepts registered IDs and positive finite JSON-safe integer quantities, retains oversized legacy stacks, and expands a too-small declared capacity to fit valid contents. Invalid entries are warned/dropped; invalid array shape, more than 4096 rows or aggregate beyond 9007199254740991 retains previous inventory. These are integrity bounds, not gameplay upgrades. Sort is stable category/id order without merging; discard validates exact row identity/count/revision and removes only confirmed integer quantity.

Every gameplay value lives here (as a schema) and in `data/` or `data_src/` (as content). Scripts contain no gameplay numbers.

## ISO-4 implemented save v5 additions (D39)

- day_ledger: {day_index: int, complete: bool, entries: Array[Dictionary]}. Each entry is {amount: int, reason: String, item_id: String, quantity: int}. Amount is an actual signed wallet delta, not a price recalculation. Starting balance and zero/load notifications are excluded. Negative changes are expense; positive refund/minh_rollback reverse expense; other positive changes are income. Profit = income - net expense = sum of deltas. An incomplete old-day refund can make net expense negative; it remains a refund, not income. Trade metadata annotates existing cash only; partial/refunded purchases stay generic when quantities cannot be proved.
- Journal outputs are copies. It resets at morning, marks unknown/corrupt/truncated history complete=false, and bounds external data to 4096 entries and JSON-safe magnitude/absolute aggregate 9007199254740991. These are integrity bounds, not price/earning rules. Invalid numbers/array shapes/reasons are dropped safely. Item Resource lookup remains in VIEW; pure domain classes do not consult Nodes.
- day_end: {phase: int, day_index: int, forced: bool, last_completed_day: int}. Phase 0 idle, 1 review, 2 advancing. Live writes are idle/review only. Restore reconciles with the clock: same-day advancing requires review, completed new-day payload becomes idle, future/corrupt completion metadata cannot block the current day. Invalid manual daytime review is dismissed safely; forced Stay/Escape cannot release review.
- v4 -> v5 preserves all prior fields and creates empty/incomplete history for the saved day plus idle review; wallet balance cannot reconstruct transaction history. Old fixtures remain read-only, new save_v5.json is a review example. Loading an older snapshot intentionally restores that timeline; the guard prevents duplicate confirmation within it, not deliberate rollback to an earlier save.
- Newest-save selection preserves fractional saved_utc. Exact ties prefer the later saved clock day so slot 0's completed morning wins over slot 1's old review. Existing atomic save/backup mechanics remain. No crop price/growth, inventory capacity or prior wire field changes.
Class sketches below are shapes; the agent checks syntax against the pinned Godot version (e.g. exporting typed `Array`/`Dictionary` varies by version). Where an `Array[Dictionary]` is awkward in the Inspector, use a small child Resource (e.g. `RecipeIO {item, qty}`).

## 1. Rules

- Ids: `StringName`, `snake_case`, unique per type, never renamed (use the `deprecated_ids` map + a save migration if unavoidable).
- Asset file name == data id (section 3). Do not invent paths.
- Display text via translation keys (`name_key`, `desc_key`), never raw strings.
- Big tables (prices, recipes, order templates) are CSV in `data_src/`; a script generates `.tres`, or `DataRegistry` loads CSV directly. Things that reference an icon/scene use `.tres`.
- `DataValidator` (headless, `tools/validate_data.gd`) fails the build on: duplicate id, missing reference, missing icon, missing translation key (vi or en), value out of range, profit over stage cap (section 4).

## 2. Design order (build them in this order)

1. `ItemData`  2. `CropData`  3. `ToolData` (+ `ToolAction`)  4. `RecipeData`  5. `BuildingData`  6. `WeatherStateData` + `SeasonData`  7. `EcologyMetricData`  8. `DirectorEventData` (+ `Condition`/`Effect`)  9. `NPCData`, `DialogueData`, `QuestData`  10. `ShopData`, `OrderTemplateData`  11. `MomentData`

## 3. Schemas

```gdscript
# ItemData
class_name ItemData
extends Resource
@export var id: StringName
@export var name_key: String              # e.g. "ITEM_WHEAT_NAME"
@export var desc_key: String
@export var category: StringName          # crop | product | seed | tool | decor | quest
@export var stack_max: int = 99
@export var base_value: int = 0           # coins, int
@export var icon: Texture2D
@export var tags: PackedStringArray

# CropData
class_name CropData
extends Resource
@export var id: StringName
@export var seed_item: StringName
@export var product_item: StringName
@export_range(1, 999) var yield_qty: int = 1  # current shipped starter crops use 2
@export var growth_days: int = 3          # watered/rained days needed to mature
@export var regrow_days: int = 0          # 0 = harvest once
@export var planting_item: StringName     # seed | cutting | sapling | sucker
@export var planting_item_buy_price: int = 0
@export var produce_sell_price: int = 0
@export var perennial: bool = false
@export var seasons: Array[StringName]    # &"spring", &"summer", &"autumn", &"winter"
@export var water_need: int = 1
@export var max_consecutive_dry_days: int = 0
@export var stage_textures: Array[Texture2D]
@export var wilted_textures: Array[Texture2D]
@export var pivot: Vector2
@export var stage_scene_ids: Array[StringName]   # models per growth stage
@export var quality_rule_id: StringName   # used from Phase 11

# RecipeData
class_name RecipeData
extends Resource
@export var id: StringName
@export var machine_id: StringName
@export var inputs: Array[Dictionary]     # [{"item": &"wheat", "qty": 2}]
@export var outputs: Array[Dictionary]
@export var duration_minutes: int = 60    # GAME minutes
@export var unlock_flag: StringName

# BuildingData
class_name BuildingData
extends Resource
@export var id: StringName
@export var scene_id: StringName
@export var footprint: Vector2i = Vector2i(1, 1)
@export var cost: int = 0
@export var slots: int = 0
@export var allowed_terrain: Array[StringName]
@export var unlock_flag: StringName

# DirectorEventData
class_name DirectorEventData
extends Resource
@export var id: StringName
@export var tags: Array[StringName]
@export var conditions: Array[Resource]   # DirectorCondition child resources
@export var effects: Array[Resource]      # DirectorEffect child resources (timed, reversible)
@export var weight: float = 1.0           # float is fine: it is a weight, not money/quantity
@export var cooldown_days: int = 7
@export var max_per_season: int = 2
@export var is_negative: bool = false
@export var telegraph_days: int = 2       # days of forewarning (0 for a pleasant surprise)
@export var counter_hint_key: String      # how the player can respond
@export var explanation_key: String       # why it happened
```

Outlines for the remaining types (agents write the full class in the matching milestone):

| Type | Key fields |
|---|---|
| `ToolData` | id, name_key, icon, `tool_action: ToolAction`, tier, reach_cells, params |
| `WeatherStateData` | id, season probabilities, effects (water/day, walkability, audio), `forecastable: bool` |
| `SeasonData` | id, days_in_season (28), crops/decor/activities |
| `EcologyMetricData` | id, sources + weights (counts in the world), decay/ease speed (%/day), thresholds → unlock ids |
| `NPCData` | id, name_key, job, schedule [(from,to,place,activity)], dialogue ids, quest ids, preferred items |
| `DialogueData` | nodes: text_key, choices, conditions (flags/quest/season/ecology), actions (start_quest, reward, set_flag) |
| `QuestData` | id, objectives measured by Events, rewards, unlocks, prerequisites |
| `ShopData` | id, stock [(item, price, unlock_flag)], always-available basic seeds |
| `OrderTemplateData` | requester, requirement ranges (item, qty_min–max), deadline days, reward factor range, cap, optional non-coin reward table |
| `MomentData` | id, condition (ecology/quest/weather/hour), effect (VFX id, music, camera, dialogue), once/cooldown, seen flag |

## 4. Starter numbers (a starting point — real values come from `tools/sim_economy.gd` and playtests)

Assumptions: 1 game day = 12 real minutes; 28 days/season; start with 200 coins, watering can 20 cells, inventory 24 slots, 8 tillable plots.

### Crops

Current shipped crop resources set `yield_qty = 2`: one consumed seed yields two product items when a mature plant is harvested. This player-requested output increase intentionally changes current balance; no price was changed in this interaction task, so a later data-only balance pass must revise the example profit targets below.

| id | seasons | growth_days | regrow | seed price | yield | product base_value | profit / plot-day |
|---|---|---|---|---|---|---|---|
| `wheat` | spring, summer, autumn | 2 | — | 8 | 1 | 20 | (20-8)/2 = 6.0 |
| `carrot` | spring, autumn | 3 | — | 15 | 1 | 45 | (45-15)/3 = 10.0 |
| `corn` | spring, summer | 4 | — | 30 | 1 | 90 | (90-30)/4 = 15.0 |
| `tomato` | summer, autumn | 5 | every 2 days | 40 | 1 per pick | 55 | 11-day cycle: 4 picks × 55 = 220 − 40 = 180 → 16.4 |

(Profit per plot-day ignores the player's watering/travel effort, so caps are safety nets, not real income.)

### Products and recipes

| id | base_value |
|---|---|
| `flour` | 55 |
| `bread` | 150 |
| `egg` | 30 |

| recipe | machine | inputs | output | duration (game min) | value added / game hour |
|---|---|---|---|---|---|
| `recipe_flour` | mill | 2 wheat (40) | 1 flour (55) | 90 | (55−40)/1.5 = 10.0 |
| `recipe_bread` | bakery oven | 2 flour (110) | 1 bread (150) | 180 | (150−110)/3 = 13.3 |

Chicken coop: 4 hens, feed 1 wheat/hen/day → 1 egg/hen/day. Hens not fed produce nothing and never die.

### Stage caps used by `DataValidator` (profit per plot-day for crops / value added per game hour for recipes)

| Stage | Crops ≤ | Recipes ≤ |
|---|---|---|
| GĐ1 new player | 18 | 15 |
| GĐ2 farm owner | 30 | 40 |
| GĐ3 businessperson | 60 | 120 |

### Progression & sinks (starter targets)

| Stage | Days | Income / game day (target) | Spend goals |
|---|---|---|---|
| GĐ1 | 1–7 | 40–150 | inventory +12 slots (300), land expansion #1 (500) |
| GĐ2 | 8–30 | 150–500 | mill (600), bakery oven (900), coop (700), expansion #2 (1,100) |
| GĐ3 | 31–80 | 500–1,500 | expansions #3–#4, greenhouse (6,000), bridge project (8,000) |
| GĐ4 | 80–200 | 1,500–4,000 | plaza (25,000), festivals, landmark buildings |
| GĐ5 | 200+ | open | decoration, cosmetics, collections, large projects |

Land expansion cost: `round_to_50(500 × 2.2^(n−1))` → 500, 1,100, 2,400, 5,300, 11,700…
Watering can 20 → 40 → 80 cells: 200, 600, 1,800. Inventory 24 → 36 → 48 → 60 slots.

### Saturation pricing (anti "one best crop")

Each item has `sold_pressure` (int). Selling 1 → `pressure += 1`. Each day: `pressure = max(0, pressure − 3)`. Price factor = `max(0.6, 1 − 0.02 × max(0, pressure − 5))`. Sell price = `floor(base_value × factor)`. Parameters are data. Show a price-trend arrow to the player so it never feels like a hidden penalty.

### Weather probabilities per day (MVP)

| Season | sunny | light rain |
|---|---|---|
| spring | 70% | 30% |
| summer | 75% | 25% |
| autumn | 70% | 30% |

(Fog, heavy rain, heatwave, snow come later; each weather has a `forecastable` flag.)

### Ecology thresholds (examples)

`biodiversity ≥ 25` → butterflies/bees · `tree_cover ≥ 30` → birds · `water_clarity ≥ 50` → clear water + new fish · two metrics ≥ 60 → fireflies · all three ≥ 80 → WOW moment "valley reborn". Each metric = smoothed function of world counts (living mature trees vs target, cleared stream cells vs total, flower cells / species count); the current value eases toward the target by 5–10% per day.

### NPC schedule examples

An: bakery 07:00–18:00, home 18:00–21:00 · Lâm: workshop 08:00–17:00, tavern evening · Linh: forest 10:00–17:00, stream in the morning · Minh: market 17:00–22:00 on days 3 and 6 of every 7-day week.

### Orders (`OrderTemplateData`)

Formula, not "AI": reward = `round(total base_value × seeded factor in [1.15, 1.5])`, hard cap `2.0 × total base_value`. 3–5 orders/day, expire without penalty. Seed = `mix(world_seed, day, TAG_ORDERS)`.

## 5. Asset naming (filename == data id)

| Kind | Pattern | Example |
|---|---|---|
| Character model | `chr_<name>.glb` | `chr_player_base.glb` |
| Environment | `env_<name>_<nn>.glb` | `env_tree_oak_01.glb` |
| Building | `bld_<name>_lv<n>.glb` | `bld_bakery_lv1.glb` |
| Prop | `prop_<name>_<variant>.glb` | `prop_fence_wood_a.glb` |
| Crop stages | `crp_<crop_id>_s<n>.glb` | `crp_wheat_s0.glb … s3` |
| VFX scene | `fx_<name>.tscn` | `fx_rain_drop.tscn` |
| Material | `mat_<name>.tres` | `mat_grass_a.tres` |
| Icon | `icon_item_<item_id>.png` | `icon_item_wheat.png` |
| SFX | `sfx_<name>_<nn>.ogg` | `sfx_hoe_hit_01.ogg` |
| Ambience | `amb_<place>_<time>.ogg` | `amb_forest_day.ogg` |
| Music | `mus_<name>.ogg` | `mus_farm_morning.ogg` |

Import hints (node/animation name suffixes in Blender; verify the list in the docs of the pinned version): `-col`, `-convcol`, `-colonly`, `-noimp`, `-loop`.

## C2 visual metadata (implemented)

`ItemData` now optionally carries `model_path: String` and `icon_path: String` for generated presentation. They are not inventory data: saves continue to serialize only item IDs/quantities and all economy/crop data continues to resolve through the existing stable IDs. C2 uses `assets/generated/models/farming/item_<item_id>.tscn` and `assets/generated/icons/item_<item_id>.png` rather than the aspirational GLB/icon naming examples above.

`FarmingArtCatalog` is a visual-only Resource at `data/art/farming/chibi_farming_catalog.tres`. It maps existing crop IDs to silhouette families and data-owned stage scales/colors; it contains no crop balance, timing, yield, save or world-state fields.

## C3 visual metadata (implemented)

`WorldArtCatalog` is a visual-only Resource at `data/art/world/chibi_world_catalog.tres`. It owns stable generated world asset IDs, asset categories, palette roles, non-interactive exterior placement vectors and a maximum count for ambient visual effects. It has no farm grid, crop/economy/quest/NPC schedule/navigation data, collision layer, input action, time/weather authority or saved-state field. Existing `GameClock` season/time and `WeatherState` rain are observed by `WorldSeasonFx` only for display selection.

Generated source scenes retain C0 palette/shader intent. In the current `DayNightProfile` world renderer, C3 may create a local readable material override for a toon piece; this is not catalog data, does not modify a shared source asset, and never adds a save field or a gameplay color rule.
