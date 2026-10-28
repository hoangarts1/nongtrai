# Scene contract — farming_art_lineup.tscn

## Purpose

`tools/farming_art_lineup.tscn` is an isolated C2 visual-review scene. It is not instanced by the game and has no save, input, collision, economy or simulation authority.

## Ownership

- Root `ChibiFarmingLineup` uses `scripts/art/chibi/farming_art_lineup.gd` and owns review-only camera, lights, floor, caption and generated model children.
- `ChibiFarmingLineup.build_lineup()` builds the deterministic overview; `set_focus_group(group_id)` switches among the overview, nine crop stage groups, three item groups and one tool group.
- `set_review_view(view_index, night)` controls the four day/night review angles. It never changes a gameplay camera or scene node.
- `tools/art/chibi/farming_art_review_runner.gd` owns PNG capture under ignored `screenshots/chibi-farming/`.

## Invariants

- It loads only generated C2 assets, C0 palette/material helpers and the C2 art catalogue.
- It must run with a normal graphics renderer; it is not a headless test substitute.
- Generated assets retain grounded pivots, finite bounds and catalogue triangle budgets. A failing asset should fail tooling/tests rather than create an approximation at runtime.
