# GLOSSARY — THE LIFE

| Term | Meaning |
|---|---|
| Agent | an AI coding tool that writes/edits code in the IDE and can run commands |
| `ALLOW_LIST` | the files an agent may create/modify in one task |
| Autoload | a Godot script/scene loaded globally (singleton) |
| Cell (ô) | one logical grid unit, `Vector2i`, 1 × 1 m on the XZ plane |
| Cỗ máy Mùa / Season Machine | the in-world brass weather machine at the observation station (player-facing name) |
| Coin faucet / sink | where coins come from / where they are spent |
| `day_index` | number of the game day, starting at 0 |
| `DaySimulator` | runs `simulate_day()` in a fixed order (see ARCHITECTURE §5) |
| Decision trace | recorded reason why `EventDirector` picked an event |
| Determinism | same inputs + seed → same result |
| Domain / View | pure logic without Nodes / the display layer |
| Dormant | out-of-season crop: stops growing, is not lost |
| Ecology (sinh thái) | metrics `tree_cover`, `water_clarity`, `biodiversity`… that the world reacts to |
| `EventDirector` | rule-based, weighted event chooser (formerly "Eco-AI Director") |
| Footprint | cells a building occupies (`Vector2i`) |
| Gate | quality gate: A after Phase 4, B after Phase 9 |
| Golden test / save | test or save file that pins a known-good output / schema version |
| Gray-box | placeholder geometry (boxes, capsules) before real art |
| Headless | running Godot without a window, from the command line |
| Idempotency key | a key that makes repeating a request have effect only once |
| Ledger (sổ cái) | immutable log of every coin change |
| Local-authoritative | the player's machine owns the world data |
| Milestone | one small roadmap task with acceptance criteria (e.g. 4.1) |
| `MomentData` | data for a WOW moment with conditions and effects |
| Occluder | an object hiding the player (needs dithering/fade) |
| `OccupancyMap` | which cell is occupied by what |
| Orthographic | a camera with no perspective |
| Pity timer | guarantees a positive event after a long streak without one |
| Pre-roll | choosing a random outcome ahead of time by seed and saving it |
| Resource (`.tres`) | Godot data object editable in the Inspector |
| RLS | Row-Level Security in the backend database |
| Save-scum | reloading a save to re-roll a random outcome |
| Scene contract | written description of a scene's nodes, exports, signals, layers |
| Spike | short experiment answering one technical question |
| Telegraph | forewarn an event (forecast) |
| `tool_hit` | moment in a tool animation when it touches the target; emits a signal |
| `ToolAction` | Resource implementing the effect of one tool |
| `total_minutes` | `day_index * 1440 + minute_of_day` |
| Vertical slice | a small but complete piece showing the core experience |
| `WorldState` | the object that groups all domain state |
