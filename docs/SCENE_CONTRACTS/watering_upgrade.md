# Phase6.5h3 watering-can upgrade (owner-approved)

Existing Bag footer has a separate watering_upgrade_button:Button and watering_upgrade_requested(). The second footer row holds wrapping hints plus this entry; capacity/sort/bag upgrade first row remains. Reuse LifeHudShortcutColumn spacing so the native button fits while all five default grid rows remain visible. Controller defers request_watering_upgrade() only from active Bag with no discard prompt. No existing scene/InputMap/Theme/art change.

Main owns watering_upgrade_config:WateringCanConfig (existing Resource), watering_upgrade:WateringCanUpgradeService (existing domain command over actual can/wallet) and watering_upgrade_flow:WateringUpgradeFlow (transient adapter only). Configure flow before inventory/UiCoordinator. busy joins existing shared purchase safe-point guard; lifecycle close never returns to Bag. New Game/load keep the same actual can instance; savev10 already stores capacity/charges. No new persistent state owner or schema.

New explicitly approved minimal scene wrappers:
- ui/watering_upgrade/watering_upgrade_screen.tscn: PanelContainer with LifeWateringUpgradeScreen (LifeHudFrame).
- watering_upgrade_summary.tscn: VBoxContainer with LifeWateringUpgradeSummary.
- watering_upgrade_footer.tscn: VBoxContainer with LifeWateringUpgradeFooter.

Runtime tree Main/WateringUpgrade -> shared wood/paper VBox -> Header(Banner,Close), Summary(capacity,remaining,description,price,availability), Footer(wallet,feedback,Back,Confirm). Native Buttons; existing Theme/font and responsive centered820×540 maximum with64×48 viewport margins. Lazy ensure_built() creates children. Screen signals closed(), backed(), purchased(expected_capacity:int); footer confirmed(), backed(). Snapshot/presenter format detached actual owners and Resource terms; no purchase/refill during rendering.

Flow API configure(main:Node), open(), close(), back_to_bag(), purchase(expected_capacity:int), refresh()->void. Only active Bag can open, not discard/sleep/day advance/another transaction. Quote checks capacity/target/price again before existing service validates/debits/grants/refunds. Charges stay unchanged; source refill remains separate. Coalesced wallet/water/locale refresh; completed entry disables. UiCoordinator registers panel z81/backdrop80, owns pause/Player lock/day-end priority and Escape; native focus/accept arrows pass through. Explicit Back safely reopens Bag; generic close/load/title do not. Runtime.refresh updates actual HUD/dirty after completed can changes. Insufficient funds still display configured target/price.

Ledger uses existing buy_watering_upgrade and buy_watering_upgrade_rollback reasons. Rollback reduces expense, never income; raw signed entries/save shape remain. No later tier or balance change.
