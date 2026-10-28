# SCENE CONTRACTS

One file per important scene. A contract is the written promise between the human (who builds the scene in the Godot editor) and the agent (who writes the scripts). It exists because agents cannot see the editor: Inspector assignments, editor-only signal connections and node paths are invisible to them.

Rules
- The human builds the scene to match the contract. The agent uses ONLY nodes, exports, signals and groups listed in it.
- Missing something? The agent asks, or writes a stub and reports it. Never guess a node path.
- If the human changes a scene, update its contract in the same commit.
- Use `%UniqueName` for nodes referenced by scripts in the same scene; use typed `@export var x: Type` for cross-scene references.

Files
- `art_lineup.md` — isolated C0 chibi calibration/review tool scene; not part of gameplay
- `farming_art_lineup.md` — isolated C2 crop/item/tool review tool scene; not part of gameplay
- `_TEMPLATE.md` — copy for every new scene
- `gray_box_world.md` — draft for roadmap tasks 0.4 → 1.x
- `player.md` — draft for roadmap tasks 1.1 → 1.5
