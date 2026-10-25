# <scene_name>.tscn

Path: `scenes/<folder>/<scene_name>.tscn`
Root: `<RootName>` (`<NodeType>`)   Script: `scripts/<...>.gd`   `class_name`: `<Name>`

## Node tree
```
<RootName> (<NodeType>)
├─ <Child> (<NodeType>)            %UniqueName? yes/no
│  └─ ...
```

## @export variables (typed)
| Variable | Type | Assigned to |
|---|---|---|
| `camera` | `Camera3D` | ... |

## Signals
| Signal | Parameters | Emitted by |
|---|---|---|

## Groups
`<group_name>` — why

## Collision (names from `docs/COLLISION_LAYERS.md`)
Layer: `<name>` (n) · Mask: `<names>`

## Notes
Anything an agent must not assume (what is built by hand vs in code, instancing rules, etc.).
