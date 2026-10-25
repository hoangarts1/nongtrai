# TASK TEMPLATES — copy, fill, paste into the agent

How a session runs: open a NEW chat/agent session → paste "Session open" → agent summarizes in 5 bullets → paste ONE task → agent PLANS first → you approve → it codes + tests → you run manual tests → review the diff → "Session close" → commit.
Commit BEFORE every task (`git commit -m "before task X"`) and AFTER it passes.

---

## 1. Session open

```
Read AGENTS.md, docs/PROJECT_RULES.md, docs/PROGRESS.md, docs/API_INDEX.md.
In 5 bullets tell me: current milestone, current state, the rules you will follow, risks.
Do NOT write code yet. Then wait for my task.
```

## 2. Task template

```
MILESTONE: <id> <name from docs/ROADMAP.md>
READ-ONLY CONTEXT: <docs/files to read but not modify>
ALLOW_LIST (may create/modify): <exact files>
DO NOT TOUCH: everything else, including all .tscn unless listed
TASK: <one paragraph describing the behavior>
ACCEPTANCE:
 - <measurable bullet>
 - <measurable bullet>
 - headless tests pass (paste the real output)
DELIVERABLES: per docs/PROJECT_RULES.md section 16. PLAN FIRST (files, assumptions, risks) and wait for my approval before coding.
```

## 3. Session close

```
Update docs/PROGRESS.md (done / in progress / known issues / next) and docs/API_INDEX.md for what we changed.
List every file you created or modified. Give me a one-line commit message.
Confirm which tests you ACTUALLY ran and paste their output.
```

## 4. Bug report

```
BUG: <one line>
EXPECTED: <what should happen>        ACTUAL: <what happens>
REPRO: 1) ...  2) ...  3) ...
ERROR LOG (verbatim from the Godot Output/Debugger panel):
<paste>
RELATED FILES: <paths>
CONSTRAINTS: Only modify <file X>. No refactors. First explain the ROOT CAUSE, then propose the minimal fix, then wait for my OK. Add a regression test.
```
After 3 failed attempts: stop, split the task, or restate the spec.

## 5. Review prompt (use a FRESH session that has not seen the code being written)

```
You are a strict reviewer who did not write this code. Review the git diff below against docs/PROJECT_RULES.md and this checklist:
ALLOW_LIST adherence · Godot 3 patterns · static typing · hardcoded gameplay values · domain/view separation · serialize/deserialize present · coins/quantities are int · seeded RNG · node-path chains · tests present and meaningful (not skipped) · tr() for strings · docs updated.
Output a list of concrete defects with file:line, severity (blocker/major/minor) and the minimal fix. Do not rewrite the code.
<paste git diff>
```

## 6. Content prompt (dialogue / quests / items — data only)

```
Using docs/STYLE_GUIDE.md and docs/DATA_SCHEMA.md (DialogueData, QuestData), write the dialogue and quest data for NPC <An> for milestone <M>.
Output ONLY valid CSV/.tres in the schema, with KEY_SNAKE text keys, plus the vi and en translation rows. No code.
Keep each dialogue box <= 120 characters. Do not use the word "AI" in player-facing text.
```

## 7. Tool prompts (headless scripts)

```
Write tools/validate_data.gd. Check: unique ids; all references resolve; icons exist; every name_key/desc_key exists in vi and en;
crop profit per plot-day <= stage cap; recipe value added per game-hour <= stage cap. Exit code != 0 on any error, with file and id in the message.
```
```
Write tools/sim_economy.gd (headless, no Nodes). Simulate D days for strategies: wheat_only, balanced, processor, lazy (plays 3 of 7 days), exploiter (tries arbitrage and hoarding).
Use the real EconomyService/FarmGridState/ShopService classes and data. Output CSV (day, coins, income, plots, machines) and assert invariants:
coins never negative; exploiter <= 1.5x balanced; time to land expansion #1 within <MIN>-<MAX> days.
```

---

## 8. Ready-to-paste first tasks

### Task 0.1 — Repo + project config + headless test

```
MILESTONE: 0.1 Repo + project config + headless test
READ-ONLY CONTEXT: AGENTS.md, docs/PROJECT_RULES.md, docs/DECISIONS.md
ALLOW_LIST: project.godot, tools/run_tests.bat, tools/run_tests.sh, tests/unit/test_smoke.gd, docs/PROGRESS.md, docs/API_INDEX.md, docs/PROJECT_RULES.md (section 1 only)
DO NOT TOUCH: everything else (no scenes, no gameplay code)
TASK: Set up test infrastructure for <GUT|gdUnit4>. I will install the addon manually in the editor — tell me the exact steps for MY pinned Godot version.
Create one smoke test (assert true). Fill in the test command in tools/run_tests.* so it runs ALL tests headless and returns a non-zero exit code on failure.
Ensure `godot --headless --path . --quit` exits 0. Write the exact commands into docs/PROJECT_RULES.md section 1.
ACCEPTANCE:
 - run_tests prints PASS for the smoke test
 - a deliberately failing test (temporary) makes run_tests exit non-zero (show both outputs)
 - the parse-check command exits 0
 - PROGRESS.md updated
```

### Task 0.2 — InputMap, layers, skeleton, autoload stubs, Vietnamese font

```
MILESTONE: 0.2 InputMap + layer names + autoload stubs + font test
READ-ONLY CONTEXT: docs/INPUT_MAP.md, docs/COLLISION_LAYERS.md, docs/ARCHITECTURE.md (section 2), docs/PROJECT_RULES.md
ALLOW_LIST: project.godot, scripts/core/events.gd, scripts/core/settings.gd, scripts/core/data_registry.gd, scripts/core/save_service.gd, scripts/core/game_clock.gd, tests/unit/test_project_config.gd
DO NOT TOUCH: everything else
TASK: Register the input actions from docs/INPUT_MAP.md, the 3D physics layer names from docs/COLLISION_LAYERS.md, and the 5 autoload stubs in the order given
(Events, Settings, DataRegistry, SaveService, GameClock). Each stub has the API header comment and no logic. Add a headless test that checks every action in INPUT_MAP.md exists with the documented name,
and every layer name exists. Tell me the manual steps for the font + Label test string "Thung Lũng Sống ẩn ệ ữ ợ ỡ ằ ẫ".
ACCEPTANCE:
 - the test reports 0 missing actions and 0 missing layers
 - parse check exits 0; autoload order matches ARCHITECTURE section 2
```

### Task 0.3 — GridMath

```
MILESTONE: 0.3 GridMath
READ-ONLY CONTEXT: docs/PROJECT_RULES.md, docs/DECISIONS.md (D13, D14), docs/CODE_PATTERNS.md (section 2), docs/ARCHITECTURE.md
ALLOW_LIST: scripts/util/grid_math.gd, tests/unit/test_grid_math.gd, docs/API_INDEX.md
DO NOT TOUCH: everything else
TASK: Implement static, pure class GridMath (class_name GridMath, extends RefCounted): CELL_SIZE const (1.0); world_to_cell(Vector3) -> Vector2i using floori;
cell_to_world(Vector2i) -> Vector3 returning the CELL CENTER with y = 0; footprint_cells(origin: Vector2i, size: Vector2i, rotation_steps: int) -> Array[Vector2i]
(rotation in 90-degree steps; handle even/odd sizes consistently and document the anchor rule in the header).
ACCEPTANCE:
 - negative coordinates map correctly, e.g. (-0.01, *, -0.01) -> (-1, -1)
 - boundaries: x = 0.999 -> cell 0 ; x = 1.0 -> cell 1
 - cell_to_world(world_to_cell(p)) is within half a cell of p
 - footprint (2,3) rotated 1 step yields 6 unique cells with swapped dimensions
 - tests pass headless (paste output)
```

### Task 0.5 — DetRandom

```
MILESTONE: 0.5 DetRandom + golden tests
READ-ONLY CONTEXT: docs/PROJECT_RULES.md (section 9), docs/CODE_PATTERNS.md (section 5)
ALLOW_LIST: scripts/util/det_random.gd, tests/unit/test_det_random.gd, docs/API_INDEX.md
DO NOT TOUCH: everything else
TASK: Implement DetRandom as in CODE_PATTERNS section 5 (verify against the pinned Godot version). Add tests: same (seed, day, tag) -> same first 10 values; different tag or day -> different sequence;
pin a golden sequence for seed 12345, day 1, TAG_WEATHER (print it once, then hard-code it as the expected value and explain how to regenerate it deliberately).
ACCEPTANCE:
 - determinism tests pass; golden test passes; no use of global randi()/randf() or hash()
```

### Task 1.1 — Camera-relative movement

```
MILESTONE: 1.1 Camera-relative movement
READ-ONLY CONTEXT: docs/SCENE_CONTRACTS/player.md, docs/SCENE_CONTRACTS/gray_box_world.md, docs/INPUT_MAP.md, docs/PROJECT_RULES.md, docs/CODE_PATTERNS.md (section 4)
ALLOW_LIST: scripts/player/player.gd, scripts/player/player_config.gd, tests/unit/test_move_dir.gd
DO NOT TOUCH: all .tscn (the human builds player.tscn per the contract), everything else
TASK: Player (CharacterBody3D) moves with move_up/down/left/right relative to the camera yaw (camera via @export var camera: Camera3D). Speed from a PlayerConfig resource.
Extract the direction math into a pure static function (testable). Use move_and_slide() with no arguments.
ACCEPTANCE:
 - pressing "up" moves the character toward the TOP of the screen
 - diagonal speed equals cardinal speed
 - no movement and no jitter at zero input
 - the direction function is unit-tested for yaw = 0, 45, 90 degrees
```
