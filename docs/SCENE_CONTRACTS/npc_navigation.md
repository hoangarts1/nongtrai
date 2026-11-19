# NPC derived coop obstacle contract

## Phase7.5h optional extra market visit (D125)

NpcSchedule.destination and NpcSocialState.update_schedule add optional default-empty extra_visit:Dictionary; original five/four arguments remain valid. LifeDirectorNpcBridge supplies only known current-day{day_index,npc_id,location_id}, actual minh/minh_market. It ignores weekday only for that existing entry while retaining applies_to seasons/minutes and original rain/night-first home rule. NpcSystem.refresh_director_schedule reuses current cells/routes; no actor reset/teleport, new destination/stock/price or scene edit. Original proximity/dialogue context and once-per-day MerchantService unchanged. Successful original trade command records captured actual offer quantity/kind; direct programmatic/debug grants do not count.

## AUDIT-F16 modular dialogue integration (D102)

NpcSystem.configure calls dialogue.enable_dialogue(main,self) for existing Main/NpcDialogue only; actors/homes/schedules/quest-book are unchanged. Existing E opens nearby NPC, GUI Tab/Enter/Space and mouse activate real controls, Esc closes. Root's public column/title_label/close_button alias actual choices/name/stable Close; AcceptQuest/DeliverQuest/ConfirmOffer IDs retain old consumer paths. Main/NpcJournal keeps its book branch and standalone NpcPanel.show_content still works. No editor tree/Inspector/InputMap changes.

Runtime contract is docs/SCENE_CONTRACTS/dialogue.md: fresh read-only snapshot plus active nearby NPC/modal/clock checks precede original transaction handlers. request_dialogue_action(id)->bool returns dispatch status; is_dialogue_busy blocks close/shortcut reentry. Locale/inventory/state/schedule changes queue context-checked refresh. UiCoordinator is still sole modal owner; UiLayout widens only dialogue. Ledger/items/coins, social state, NPC navigation and save12 remain owned/restored by their existing systems. Manual cases: approach Minh/Linh and E; accept, add required items, deliver, retry stale request, confirm one daily offer; close with native mouse/Enter/Esc, open journal; switch vi/en and resize. Actual runtime captures and test logs are in the F16 backup named in PROGRESS. Human F5 acceptance remains pending.

NpcSchedule.set_dynamic_obstacles(regions:Array[Rect2i])->void rebuilds its derived grid from original WorldLocations solids plus supplied owned footprint. It does not save positions or add a gameplay owner. NpcSocialState.refresh_routes()->void reroutes from current cells to existing schedule targets even when target identity is unchanged; friendship/targets/cells remain. NpcSystem.set_dynamic_obstacles delegates both. Restore clears stale obstacles before restoring NPC cells, then runtime reapplies actual coop ownership. No scene edits, new layers or actor teleport.

## Phase8.5f separate dog navigation

DogNavigationContext reads existing Resource solids and current machine occupancy/owned land/coop footprints for its own39x39 cache. NpcSchedule/NpcSocialState/NpcSystem and original NPC cells/routes remain untouched. Do not feed dog positions into NPC occupancy or construction blockers; the companion is cosmetic. Current MachinePlacementState occupies MACHINE_SIZE=one cell; dog uses that actual domain footprint, not sprite dimensions.
