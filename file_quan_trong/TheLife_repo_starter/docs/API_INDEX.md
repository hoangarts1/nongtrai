# API INDEX — THE LIFE

Public methods and signals of every system. Agents read THIS instead of scanning code, and update it at the end of every task. Source of truth for each entry is the `## API:` header at the top of the script.

Format:

```
## ClassName  (path/to/script.gd)
- func name(arg: Type) -> ReturnType        — one-line meaning
- signal name(arg: Type)                    — when it fires
- Notes: invariants, who owns the state, edge cases
```

---

(no systems implemented yet — first entries will be `GridMath`, `DetRandom`, `Log` from Phase 0)

<!-- Example of a finished entry (delete when real ones exist):

## EconomyService  (scripts/domain/economy/economy_service.gd)
- func try_spend(amount: int, reason: StringName, key: StringName = &"") -> bool   — false if not enough coins
- func earn(amount: int, reason: StringName, key: StringName = &"") -> void
- signal coins_changed(new_total: int, delta: int, reason: StringName)             — via Events
- Notes: coins are int; every change is written to Ledger with a reason; only this class changes coins.
-->
