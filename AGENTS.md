# AGENTS.md — THE LIFE (Godot 4 cozy farming sim)

Project: a cozy 2D isometric farming and life sim. Godot 4.x, GDScript 2.0 with static typing, 64×32 px tiles and `CharacterBody2D` / `Camera2D` (D33).
Migration status: ISO-1 has converted the active runtime to 2D; automated acceptance is recorded in PROGRESS and human editor playtest remains pending. Existing 3D source/art is retained as historical material, not silently deleted. See `docs/PROGRESS.md` for the current authorized scope.
People: one human developer (product owner, tester, scene builder) and you (the programmer).
Memory: you forget everything between sessions. `docs/PROGRESS.md` is your memory — keep it current.

This file is the short version. The full law is `docs/PROJECT_RULES.md`. If the two disagree, PROJECT_RULES wins; tell the human about the conflict.

---

## 1. Read these first — every session, before writing any code

1. `docs/PROJECT_RULES.md` — engine version, architecture, forbidden patterns
2. `docs/PROGRESS.md` — where we are, what is next (the milestone list is `docs/ROADMAP.md`)
3. `docs/API_INDEX.md` — public APIs of existing systems (read this instead of scanning all code)
4. `docs/ARCHITECTURE.md` — layers, autoloads, event catalog, day-simulation order, save format
5. `docs/SCENE_CONTRACTS/<scene>.md` — for every scene the task touches
6. `docs/DECISIONS.md`, `docs/DATA_SCHEMA.md`, `docs/CODE_PATTERNS.md` — when relevant (camera, time, saving, economy, data, networking)

Then reply with 5 bullets: current milestone, current state, the rules you will follow, risks you see.
**Do not write code until you receive a task.**

## 2. Non-negotiable rules

1. **Scope.** Modify ONLY files in the task's `ALLOW_LIST`. Never rename, move or delete files, ids, signals or public methods unless the task says so. No drive-by refactors.
2. **No invention.** Never invent node paths, input actions, collision layers, resource paths, autoloads, signals or Godot APIs. If something is missing from the docs: STOP and ask, or create a minimal stub and report it.
3. **Godot 4 only.** GDScript 2.0, static typing on every variable, parameter and return. The forbidden Godot 3 patterns are listed in `docs/PROJECT_RULES.md` §5. `move_and_slide()` takes NO arguments.
4. **Three layers, one direction.** DATA (Resources/CSV) → DOMAIN (pure `RefCounted`, no Nodes) → VIEW (scenes/UI). Views never own state. Domain never touches UI.
5. **No gameplay numbers in scripts.** Prices, durations, probabilities, weights live in Resources/CSV. Coins and quantities are `int`, never `float`.
6. **Seeded randomness.** Gameplay randomness uses `DetRandom`. Never global `randi()` / `randf()` for gameplay.
7. **Time by day, not by delta.** Crops/machines use `day_index` and `total_minutes`. Never accumulate `delta` per crop. One simulation path: `DaySimulator.simulate_day()`.
8. **Every stateful domain class** has `serialize()` and `deserialize()` from its first commit. Never save node trees.
9. **Typed signals.** `signal x(a: int)`, `x.emit(a)`, `x.connect(callable)`. No string-based `emit_signal`. Connect signals in code, not only in the editor.
10. **Strings via `tr()`** with `KEY_SNAKE` keys present in `localization/`.
11. **Honest testing.** Never say something is tested unless you ran it. Run the headless tests and paste the real output. Never skip or weaken a test to make it pass.
12. **One milestone at a time.** Do not implement future systems. Preserve working behavior.
13. **Scenes belong to the human.** Do not edit `.tscn` unless it is in the ALLOW_LIST. You write scripts and simple `.tres`; the human builds scenes in the editor following `docs/SCENE_CONTRACTS/`.
14. **Safe terminal.** No `rm -rf`, `git push --force`, `git reset --hard`, or installing packages without asking. Do not run `git commit` / `git push` unless the task says so — propose a one-line commit message instead.
15. **No secrets.** Never write keys, tokens or passwords into any file. Never use or suggest a `service_role` key in the game client.

## 3. Task format you will receive

```
MILESTONE:          <id + name from the roadmap>
READ-ONLY CONTEXT:  <files/docs to read, not modify>
ALLOW_LIST:         <files you may create/modify>
DO NOT TOUCH:       everything else, including all .tscn unless listed
TASK:               <one paragraph of behavior>
ACCEPTANCE:         <measurable bullets>
```

For any task that touches more than one file or any domain system: **plan first** (files to create/modify, assumptions, risks) and wait for approval before coding.

## 4. What you must output for every task

1. Acceptance criteria (restated)
2. Exact list of files created / modified
3. Full contents of each file (or a clear diff)
4. Manual editor steps the human must do (scene tree, Inspector, project settings)
5. How to run it + manual test cases
6. Assumptions and known failure points
7. Updates to `docs/API_INDEX.md` and `docs/PROGRESS.md`
8. Real test output (paste it) and a one-line commit message

## 5. When to stop and ask

- A doc you need is missing or contradicts another doc.
- You would have to touch a file outside the ALLOW_LIST.
- A requirement is ambiguous — ask ONE concise question.
- The same bug has failed 3 fix attempts: stop, explain the root cause, and suggest splitting the task.

## 6. Tone of the product (for any player-facing text)

Warm, simple, gentle. Never use the word "AI" in player-facing text (the in-game name is "Cỗ máy Mùa" / Season Machine). See `docs/STYLE_GUIDE.md`.
