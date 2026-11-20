# F03 neighbor introduction plan

## F03 approved verification (2026-11-20)

IMPLEMENTING after F02 3620d2f pushed/full1043of1043. Whole33package approval authorizes this exact99path subset, delegated DATA balance and full-test/commit/push sequence.

Plan: register an/bac_lam with existing an/lam art (DATA alias preserves lam ID), existing two NPCs/coordinates/weekly merchant behavior intact. Add script-built sample workplaces using existing PlaceholderWorld2D, all names/text via vi/en. Master hours: An07:00-18:00 bakery; Lam08:00-17:00 workshop then17:00-19:00 square, existing rain/night-first behavior. Candidate DATA sites: an_home(-8,11), an_bakery(-9,7), bac_lam_home(-9,-7), bac_lam_workshop(-8,-4), village_square(-7,6). Read-only conservative preflight routes5/4/11steps and no prior eligible cleanup cell at those feet; actual engine verification remains pending. No new physical house colliders/scene edits or fabricated stock/repair service.

Acceptance: four registered NPCs/real homes/workplaces/routes and localized existing portrait/dialogue; genuine nearby E conversation with each An/Lam required, repeated An/seeing actors/fake notice/programmatic talk alone cannot finish meet_neighbors. Add introduced marker to existing NpcSocialState (one owner), only after visible guarded conversation settles; hold Main persistence/reset/close/reentry guard through talk and publication. Save18 introduces social.introduced and new NPC/source semantics; pre18 discards injected new introductions, preserves old friendship/history/clearing/rights, all17goldens immutable and new18 actual migration. Seventh supported story goal, other3ChapterI/4M2planned. Derive navigation blockers from actual supplied rock colliders, machine footprints and existing coop regions; sparse DATA polling plus explicit render/clearing/land refresh, no second simulation/day/teleport for valid legacy cells. Existing public methods/IDs preserved.

Risks: intro guard versus initial dialogue rendering, partial/fraction/future-day history, alias validation, dynamic blocker/lifecycle context, native input and vi/en layout. Exact changed-spec old-test rows separately verified with negative coverage/test/assertion counts retained; explicit historical17/16 golden projections remove only later fields and retain full equality. No Inspector/project setting/package setup. Full original launcher/current5sequentialgroups180s each and source/test/golden/real-save gates before scoped commit/push. Current real-save baseline includes the preserved external12:29progress documented in F02.

Exact ALLOW_LIST:

```text
data/art/characters/chibi_character_catalog.tres
data/npcs/phase8_world.tres
data/story/chapter1.tres
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DATA_SCHEMA.md
docs/DECISIONS.md
docs/INPUT_MAP.md
docs/PROGRESS.md
docs/REMAINING_PLAN.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/dialogue.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/neighbors.md
docs/SCENE_CONTRACTS/npc_navigation.md
docs/SCENE_CONTRACTS/story.md
localization/strings_en.csv
localization/strings_vi.csv
scripts/core/data_validator.gd
scripts/core/save_service.gd
scripts/data/character_appearance_catalog.gd
scripts/data/npc_data.gd
scripts/data/npc_world_data.gd
scripts/data/story_config.gd
scripts/domain/quests/neighbor_rules.gd
scripts/domain/quests/neighbor_rules.gd.uid
scripts/domain/quests/npc_schedule.gd
scripts/domain/quests/npc_social_state.gd
scripts/domain/story/story_catalog_validator.gd
scripts/domain/story/story_observation_sampler.gd
scripts/domain/story/story_receipt_rules.gd
scripts/domain/story/story_save_codec.gd
scripts/view/machine_presentation.gd
scripts/view/main.gd
scripts/view/npc_navigation_flow.gd
scripts/view/npc_navigation_flow.gd.uid
scripts/view/npc_system.gd
scripts/view/story/story_runtime.gd
scripts/view/world_presentation.gd
tests/golden_saves/save_v18.json
tests/helpers/neighbor_fixture.gd
tests/helpers/neighbor_fixture.gd.uid
tests/unit/test_ambient_audio_runtime.gd
tests/unit/test_bag_upgrade_flow.gd
tests/unit/test_character_screen.gd
tests/unit/test_chicken_coop_collection.gd
tests/unit/test_chicken_coop_feeding.gd
tests/unit/test_chicken_coop_runtime_save.gd
tests/unit/test_clearing_runtime_save.gd
tests/unit/test_crop_care_save.gd
tests/unit/test_crop_regrow_save.gd
tests/unit/test_crop_stage_runtime.gd
tests/unit/test_day_end_flow.gd
tests/unit/test_day_end_save.gd
tests/unit/test_dog_runtime_save.gd
tests/unit/test_ecology_end_to_end.gd
tests/unit/test_ecology_runtime_save.gd
tests/unit/test_inventory_actions.gd
tests/unit/test_land_save.gd
tests/unit/test_machine_build_lifecycle.gd
tests/unit/test_machine_collection.gd
tests/unit/test_morning_flow.gd
tests/unit/test_neighbor_native.gd
tests/unit/test_neighbor_native.gd.uid
tests/unit/test_neighbor_navigation.gd
tests/unit/test_neighbor_navigation.gd.uid
tests/unit/test_neighbor_rules.gd
tests/unit/test_neighbor_rules.gd.uid
tests/unit/test_neighbor_runtime.gd
tests/unit/test_neighbor_runtime.gd.uid
tests/unit/test_neighbor_save.gd
tests/unit/test_neighbor_save.gd.uid
tests/unit/test_npc_social_save.gd
tests/unit/test_pause_settings.gd
tests/unit/test_profile_creation.gd
tests/unit/test_quest_book.gd
tests/unit/test_recipe_economy.gd
tests/unit/test_save_backup_recovery.gd
tests/unit/test_save_service.gd
tests/unit/test_story_catalog.gd
tests/unit/test_story_end_to_end.gd
tests/unit/test_story_golden_continuation.gd
tests/unit/test_story_localization.gd
tests/unit/test_story_readout.gd
tests/unit/test_story_runtime_save.gd
tests/unit/test_story_state.gd
tests/unit/test_supplied_decor_runtime.gd
tests/unit/test_supplied_objects_runtime.gd
tests/unit/test_title_flow.gd
tests/unit/test_transaction_facades.gd
tests/unit/test_water_source_world.gd
tests/unit/test_watering_runtime_save.gd
tests/unit/test_watering_upgrade_flow.gd
tests/unit/test_weather.gd
tests/unit/test_weather_runtime_save.gd
tools/sim_neighbors.gd
tools/sim_neighbors.gd.uid
tools/run_graphics_tests.ps1
tools/tests/test_graphics_runner.ps1
```

Full pending.


Existing Home_<npc_id> roots remain. New Work_an/Work_bac_lam are passive PlaceholderWorld2D under existing world.objects; Main scene unchanged. New NpcNavigationFlow is a transient RefCounted VIEW helper owned by NpcSystem, not a saved node/second state. Existing dialogue12 components/GUI and CharacterAppearanceCatalog supply portraits.


Full2 original launcher exit1: first two groups249/249 and254/254 passed153.145/127.219s. Third GUT summary reports296/296/57478assert/174.416s, but the whole child including startup/shutdown reached the unchanged180000ms bound and exited124; groups4/5 did not run. This is NOT a passing full run. All raw failed logs/manifest/frozen source/diff retained at D:/godot/game-godot-backups/finish-roadmap-run-20261120-093950/f03-135914/full-attempt2-failed. Approved global measured-split authority amends exact scope97to99paths BEFORE runner edits, adding tools/run_graphics_tests.ps1 and tools/tests/test_graphics_runner.ps1. Keep original base partitions1/2 unchanged, split only base3 in addition to already split base4: six complete sequential nonempty renderer groups,180s each, original discovery/hash/count/capture/failfast/error/orphan gates retained. Small4-7inventories retain four groups,8+six. Also add real direct-load regression/fix for absent or invalid schema metadata: normalize story using the same conservative neighbor history decision before owner restore; current18 save path remains unchanged. Full3 required.

## Implemented F03 behavior and verification

F03 registers An/an and Bac Lam/bac_lam alongside the unchanged Minh/Linh IDs, merchant schedule and legacy coordinates. Existing an/lam sample art supplies world actors and portraits through the explicit bac_lam->lam DATA alias, preserving the original art ID. Four homes and two passive script-built workplaces use existing PlaceholderWorld2D under world.objects; no new physical building collider, stock, service, scene or InputMap edit. DATA places An home(-8,11), bakery(-9,7), Lam home(-9,-7), workshop(-8,-4), square(-7,6). An works07:00-18:00; Lam08:00-17:00 workshop,17:00-19:00 square; original rain/night-first home behavior remains. All player names/place labels/dialogue use actual vi/en Resource keys.

The existing NpcSocialState is the sole social owner. talk() still gives once-per-day friendship/heard history, but cannot itself prove meeting a new neighbor. Only NpcSystem's actual nearby outdoor E conversation, after rendering the active dialogue, records introduced and publishes a guarded conversation_started(npc_id). Its transient receipt, visible context and two distinct validated histories are all required by StoryRuntime; seeing actors, forged notices, friendship alone, raw talk or repeating An cannot finish meet_neighbors. Main save/load/new/title, close and duplicate conversation reject during talk/publication; callback attempts cannot split story/social persistence. Seven ChapterI sources are supported; repairs/mailbox/storage and all four M2 milestones remain planned. No chapter completion or production Director entitlement.

SaveService CURRENT_VERSION18 adds social.introduced to the existing owner, not a new top-level owner. Canonical known unique NPC markers require matching registered heard introduction and a finite nonnegative integral talk day no later than the saved clock. Pre18 migration/direct legacy load discards injected new-neighbor history/markers and meet_neighbors, preserving Minh/Linh, prior progress/rights and clearing17. Current valid history persists; partial/fraction/future proofs cannot manufacture the goal. All17historical golden bytes stay immutable; new18 is actual pinned SaveService migration/readback of17. Historical16/17 equality tests explicitly project out only later fields and restore their original JSON version numbers.

NpcNavigationFlow is a derived RefCounted VIEW cache owned by NpcSystem. It composes actual supplied large-rock colliders, current one-cell MachinePlacementState footprints and the existing external coop regions. Machine refresh/clearing/land signals plus DATA0.25second polling reroute only on canonical blocker changes; no new saved cells, owner or day simulation. An actor whose legacy start becomes a single-cell dynamic obstacle may leave that cell, without teleporting or unblocking fixed/water/multicell obstacles or blocked destinations. Existing owned farm is not blanket-blocked because the original Linh target lies inside the east parcel.

Pinned import1/import2 exit0 with inherited duplicate artUID warnings only. Focused1:2scripts/8of8/66assert/1.945s. Focused2 headless: navigation/save and live locale/Esc passed; native-close matrix failed12assertions because the NEW test checked child.visible after its parent had hidden. Native1 reproduced the same fixture assertion; complete mouse position/global/button-mask events alone did not change it. NpcPanel.close_panels hides the parent, so the corrected test checks both parent.visible=false and child.is_visible_in_tree=false, retaining real native clicks. Native2:2scripts/8of8/171assert/6.467s, no errors/leaks, includes all6rules/CLI cases and both native cases. New navigation cases traverse every four-NPC/four-season/seven-weekday/seven-time route and check actual blockers, rain/night, machine/coop/clearing composition and legacy escape. New save cases exercise actual E introductions, slot/Continue/NewGame, every17historical golden, malformed proof and exact new18 migration. Fresh12vi/en three-size dialogue PNGs; inspected An Vietnamese1152 and Lam English1152. These are automated captures, not human F5 acceptance.

Exact changed-spec compatibility:56rows/43old test files, verified against before-bytes; test function/assertion counts and all negative coverage unchanged. Current outputs17->18, seventh supported goal/four NPC count/canonical empty marker, and historical16/17 projection only. Other530prior test/fixture files remain byte-identical. Protected20real-save baseline and all source SHA checked by the full gate. No golden overwrite, test skip, lower assertion, renderer or180second bound change.

No editor/Inspector/project-setting setup. Run tools/run_tests.bat with pinned4.7.2 and five complete sequential graphics groups,180seconds each. Manual F5: daytime sunny, walk to bakery/workshop, press E near An then Lam; seeing or repeating one is insufficient for J/notebook meet_neighbors. Confirm actual portraits/name/text, mouse Close and Esc, vi/en live labels, four NPC routes around rocks/machines/coop and rain/night home return. Save/load/Continue preserves both introductions/old owners/clearing; NewGame resets. Human F5/tone/FPS/art acceptance remains pending, as do the approved external H1/H2 gates.
