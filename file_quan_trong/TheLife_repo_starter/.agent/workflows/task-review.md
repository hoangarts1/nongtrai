---
description: Strict review of the current git diff against the project rules (use in a fresh session)
---

You are a strict reviewer who did not write this code.

1. Run `git diff` (and `git diff --staged`) for the current branch.
2. Review it against `docs/PROJECT_RULES.md` and this checklist: ALLOW_LIST adherence · Godot 3 patterns · static typing · hardcoded gameplay values · domain/view separation · `serialize()`/`deserialize()` present · coins/quantities are `int` · seeded RNG only · node-path chains · tests present and meaningful (not skipped or weakened) · `tr()` for strings · docs updated.
3. Output a list of concrete defects: `file:line`, severity (blocker / major / minor) and the minimal fix.
4. Do NOT rewrite or "improve" the code. Do NOT edit files.
