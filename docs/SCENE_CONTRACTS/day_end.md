# ISO-4 day-end sheet and flow

## Phase7.1b weather transaction (D86; no scene edits)

Main uses the existing WeatherState instance at actual GameClock day. On a legitimate next morning, reserve captured weather before outgoing-rain/farm callbacks; keep farm->animal->machine ordering, finish the weather day once, apply morning rain, reconcile ledger and then safe autosave/bulletin. Weather busy blocks save/load/new/title/sleep commands during callbacks; duplicate/skipped/stale signals do nothing. Saved3 forecasts remain exact through load/migration, newly needed tail uses DetRandom tag1. Save12 weather day must match saved clock; missing/corrupt weather is explicitly initialized at loaded day without replaying simulation. Existing typed events/views/modal tree/input/Inspector remain unchanged. Bulletin and tomorrow card only read forecast; no view rolls weather.

Manual: record today/three forecasts, sleep once through review, confirm new today equals saved first forecast; save/load and repeat through all three predictions. Compare water/coop/items/coins and ensure no duplicated care/eggs/bookkeeping, one morning bulletin, unchanged rain presentation. Continue/load alone must neither advance a day nor open bulletin. No editor setup required; full automated evidence/current acceptance in PROGRESS.

## D83 safe-point and daily order
Request/confirm/cancel reject Main._purchase_in_progress including source reservations. Main completed-morning callback uses sole DaySimulator farm->animals->machines; no separate machine day listener, no render/load day replay. Ledger labels actual coop/food purchases and rollback as refunded expense. No day-end scene edits.


ISO-9 adds a separate presentation-only MorningBulletin after this flow completes. Main queues the day at the end of its existing day_started handler; LifeMorningFlow waits for is_advancing(), review visibility, sleep and other modal guards to clear. Confirm's existing synchronous completed-morning save finishes before the next process frame. Morning Begin/Escape only dismisses its own view and cannot confirm another day. Restored review remains primary; Continue/load never auto-opens a morning bulletin. This flow/source/domain/save format is unchanged. See morning_bulletin.md.

ISO-6b1 retains the summary tree, signed ledger/refund model and one guarded day transition. Existing crops' frozen first/repeat targets are domain fields saved with v8; manual/forced review must not duplicate growth or harvest. Market transactions annotate current Resource prices while historical saved ledger entries stay their original signed amounts. No fabricated repricing of old history or new modal.

ISO-6a keeps the sheet/flow tree and generic unwatered warning unchanged. Confirm runs one Main -> DaySimulator transition: finished-day care/current rain first, then new-season withering, new weather and morning rain. Tomorrow's rain cannot undo a completed drought wither. v7 persists crop-care counters alongside the unchanged day_ledger/day_end guard. Forced/manual/direct paths remain equivalent; no care runs while review is merely open or cancelled.

Owner approved the ISO-4 plan/ALLOW_LIST, including domain ledger, save v5 and small UI classes. `ui/day_end/day_end_sheet.tscn` is a PanelContainer with LifeDayEndSheet script. Runtime composition uses the shared Theme; native Buttons and ScrollContainers remain real input controls. No mockup PNG is a runtime texture.

Tree: DayEndSheet -> wood frame -> VBox(Header blue Banner, Columns HBox). Left LedgerView (scrolling LedgerRow scenes, income/expense/profit, incomplete-history note, FarmWarning); right TomorrowCard (real next-day/weather forecast, actual tutorial completed count), expanding spacer, Continue Button and Stay Button. Unsupported XP/stamina/event cards are absent. Children are constructed by the small dedicated scripts, with typed fields/setters. Buttons emit confirmed() / cancelled(); the sheet owns no game state.

LifeDayEndPresenter formats actual ledger/state/forecast/farm snapshots. LifeDayEndFlow (Node owned by Main) owns DayLedgerState and DayEndState, connects local wallet deltas and optional successful trade metadata, and drives manual/forced review. It is an application coordinator, not a second simulation path. Main's existing day_started -> DaySimulator path runs once; confirm emits the existing sleep signals around one sleep_to_morning call, finalizes the journal and autosaves at the completed boundary.

New explicit interfaces: GrayBoxWorld.bed_requested() is a local signal emitted on existing bed interaction when a consumer is connected; standalone world retains try_sleep fallback. GameClock.day_end_requested(day_index: int) is emitted at cutoff; hold_day_end(day: int) -> void claims a legal bedtime/cutoff review, release_day_end(day: int) -> void releases manual cancellation, is_day_end_held() -> bool exposes the latch. While held, advance_minutes cannot bypass review. With no claiming consumer the existing immediate cutoff fallback remains. sleep_to_morning/deserialize clear the latch; low-level try_sleep behavior remains compatible.

Main runtime fields: day_end_flow: LifeDayEndFlow; its panel: LifeDayEndSheet, ledger: DayLedgerState, state: DayEndState. Flow methods configure(main), request(automatic=false)->bool, cancel()->bool, confirm()->void, on_morning(day)->void, reset()->void, restore(payload)->void and is_advancing()->bool. Save top-level fields day_ledger/day_end preserve exact serialized state. Review is safe to save; an in-progress rollover is not saved halfway. Restoring same-day review reopens it, restoring a completed/new-day snapshot cannot replay it.

UiCoordinator registers the sheet as a modal at z81 over backdrop z80. It blocks switching to other panels/world actions, permits native UI focus/accept, and routes Escape to manual cancel only. Forced-cutoff Stay/Escape cannot dismiss review. Layout uses a centered responsive large sheet with independently scrollable ledger. Shared Theme/type variations own skin/fonts. vi/en and 1152×648, 1280×720, 1920×1080 require renderer review against reference 13.

The weather_symbol helper draws the actual forecast ID without advancing weather. Static/dynamic captions refresh after locale changes. FarmWarning uses watered/withered plot snapshots and a separate forced message; no invented wither countdown or advice to return when Stay is unavailable.

## Phase6.4b land ledger reasons (D69)

Summary scenes/flow/day order unchanged. Presenter labels actual buy_land expense and buy_land_rollback refund. Ledger treats the new rollback as reduced expense, so a rejected/refunded purchase contributes zero income/expense/profit. No invented quantity, item, earnings, simulation or historical rewrite. Main save v9 adds ownership independently of unchanged day-ledger/day-end payloads.

## Phase6.5g bag ledger reasons (D70)

Scenes/day flow unchanged. Presenter labels buy_bag_upgrade expense and buy_bag_upgrade_rollback refund. The latter reduces expense, so a rejected/refunded purchase has zero income/expense/profit. No new saved ledger shape, fabricated item/quantity, historical rewrite or day simulation.

## Phase6.5h3 watering ledger reasons (D79)

Scenes/day transition/save shape unchanged. Presenter labels buy_watering_upgrade as WATER_UP_LEDGER and buy_watering_upgrade_rollback as END_REFUND. Ledger recognizes rollback as reduced expense, so rejected/refunded purchase adds zero net income/expense. Signed raw entries and legitimate independent transactions remain; no historical rewrite or new simulation.
